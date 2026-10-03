;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius build locked)
  ;; Only available in the wrappers, not when the channel is compiled
  #:autoload (landlock) (%landlock-read-access
                         landlock-path
                         landlock-port
                         landlock-exec)
  #:use-module (ice-9 match)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:use-module (web uri)
  #:export (home-path
            config-path
            cache-path
            mail-directory
            user-directory
            read-only
            read-write
            base-rules
            graphics-rules
            device-rules
            font-rules
            config-rules
            state-rules
            argument-rules
            option-path-rules
            url-arguments?
            dns-rules
            tcp-rules
            gnupg-rules
            exec-locked))

(define %read '(read-file read-dir))

(define %write
  '(write-file truncate make-reg make-dir make-sym remove-file remove-dir refer))

(define (mkdir-p directory)
  (unless (file-exists? directory)
    (mkdir-p (dirname directory))
    (mkdir directory)))

(define (home-path name)
  (string-append (getenv "HOME") "/" name))

(define (xdg-path variable default name)
  (string-append (or (getenv variable) (home-path default)) "/" name))

(define (config-path name)
  (xdg-path "XDG_CONFIG_HOME" ".config" name))

(define (cache-path name)
  (xdg-path "XDG_CACHE_HOME" ".cache" name))

(define (state-path name)
  (xdg-path "XDG_STATE_HOME" ".local/state" name))

(define (runtime-path name)
  (string-append (getenv "XDG_RUNTIME_DIR") "/" name))

(define (mail-directory)
  (or (getenv "MAILDIR") (home-path "Mail")))

(define (user-directory name default)
  "Return the XDG user directory NAME, such as \"DOWNLOAD\", or DEFAULT, both
in the home directory."
  (let* ((prefix (string-append "XDG_" name "_DIR=\"$HOME/"))
         (file (config-path "user-dirs.dirs"))
         (line (and (file-exists? file)
                    (find (cut string-prefix? prefix <>)
                          (string-split (call-with-input-file file
                                          get-string-all)
                                        #\newline)))))
    (home-path (if line
                   (string-trim-right (string-drop line (string-length prefix))
                                      #\")
                   default))))

(define (read-only path)
  (landlock-path path %read #:optional? #t))

(define* (read-write path #:key create?)
  "Allow reading and changing anything beneath PATH, creating it as a
directory first if CREATE?."
  (when create?
    (mkdir-p path))
  (landlock-path path (append %read %write) #:optional? #t))

(define (base-rules)
  "Rules every program needs: the store, /etc, a few devices and its own
/proc entry."
  (list (landlock-path "/gnu/store" %landlock-read-access)
        (read-only "/etc")
        (landlock-path "/dev/null" '(read-file write-file))
        (read-only "/dev/urandom")
        (landlock-path (string-append "/proc/" (number->string (getpid)))
                       (cons 'write-file %read))))

(define (graphics-rules)
  "Rules for rendering with the GPU."
  (list (landlock-path "/dev/dri" '(read-file write-file read-dir ioctl-dev)
                       #:optional? #t)
        (read-only "/sys")))

(define (device-rules . devices)
  "Allow using those of DEVICES that exist."
  (map (cut landlock-path <> '(read-file write-file ioctl-dev) #:optional? #t)
       devices))

(define (font-rules)
  (list (read-only "/var/cache/fontconfig")
        (read-only (config-path "fontconfig"))
        (read-only (cache-path "fontconfig"))))

(define (config-rules name)
  "Read access to the configuration directory NAME."
  (list (read-only (config-path name))))

(define (state-rules name)
  "Write access to the state directory NAME, which is created."
  (list (read-write (state-path name) #:create? #t)))

(define (url? argument)
  (and (string-contains argument "://")
       (not (string-prefix? "file://" argument))))

(define (url-arguments? arguments)
  (any url? arguments))

(define (argument-path argument)
  (cond ((string-prefix? "file://" argument)
         (uri-decode (string-drop argument (string-length "file://"))))
        ((string-prefix? "-" argument) #f)
        (else argument)))

(define (argument-rules arguments)
  "Read access to the files and directories among ARGUMENTS, which may also be
file:// URIs."
  (filter-map (lambda (argument)
                (let ((path (argument-path argument)))
                  (and path
                       (file-exists? path)
                       (read-only path))))
              arguments))

(define (option-value option)
  "Return the value of OPTION, KEY=VALUE or a bare value, without a unix:
prefix."
  (let ((value (match (string-index option #\=)
                 (#f option)
                 (index (string-drop option (1+ index))))))
    (if (string-prefix? "unix:" value)
        (string-drop value (string-length "unix:"))
        value)))

(define (file-name? value)
  (and (string-prefix? "/" value)
       (not (string-any char-whitespace? value))))

(define (option-paths argument)
  "Return the file names in ARGUMENT, a file name or comma-separated options
as QEMU takes them."
  (filter file-name? (map option-value (string-split argument #\,))))

(define (path-rule path)
  "Allow using PATH as its type requires: reading and writing a file, using a
device or a socket, or creating a socket."
  (match (and=> (false-if-exception (stat path)) stat:type)
    ('regular (landlock-path path '(read-file write-file truncate)))
    ('char-special (landlock-path path '(read-file write-file ioctl-dev)))
    ('directory (read-only path))
    ('socket (landlock-path (dirname path) '(resolve-unix)))
    (_ (landlock-path (dirname path) '(make-sock resolve-unix remove-file)
                      #:optional? #t))))

(define (option-path-rules arguments)
  "Rules for the file names in ARGUMENTS, which take QEMU's syntax."
  (map path-rule
       (remove (cut string-prefix? "/gnu/store/" <>)
               (append-map option-paths arguments))))

(define (dns-rules)
  "Rules for name resolution, through nscd or DNS servers."
  (list (landlock-path "/var/run/nscd" '(resolve-unix) #:optional? #t)
        (landlock-port 53 '(connect-send-udp))))

(define (tcp-rules . ports)
  "Allow TCP connections to PORTS."
  (map (cut landlock-port <> '(connect-tcp)) ports))

(define (gnupg-rules)
  "Rules for running gpg, which talks to gpg-agent."
  (list (read-write (or (getenv "GNUPGHOME") (home-path ".gnupg")))
        (landlock-path (runtime-path "gnupg") '(resolve-unix) #:optional? #t)))

(define (share-socket! socket name announce!)
  "Hard-link SOCKET into the directory NAME of its own, so that the program
needs no access to the other sockets in XDG_RUNTIME_DIR, call ANNOUNCE! with
the link and return the rules for it.  Return no rules if SOCKET is missing."
  (if (file-exists? socket)
      (let* ((directory (runtime-path (string-append "locked/" name)))
             (shared (string-append directory "/" (basename socket)))
             (new (string-append shared "." (number->string (getpid)))))
        (mkdir-p directory)
        (link socket new)
        (rename-file new shared)
        (announce! shared)
        (list (landlock-path directory '(resolve-unix))))
      '()))

(define (share-wayland!)
  (let ((display (or (getenv "WAYLAND_DISPLAY") "wayland-0")))
    (share-socket! (if (string-prefix? "/" display)
                       display
                       (runtime-path display))
                   "wayland"
                   (cut setenv "WAYLAND_DISPLAY" <>))))

(define (share-pipewire!)
  (share-socket! (runtime-path "pipewire-0")
                 "pipewire"
                 (lambda (shared)
                   (setenv "PIPEWIRE_RUNTIME_DIR" (dirname shared))
                   (setenv "PIPEWIRE_REMOTE" (basename shared)))))

(define (private-runtime-directory! program)
  "Point XDG_RUNTIME_DIR to a directory of PROGRAM's own and return the rules
for it."
  (let ((directory (runtime-path (string-append "locked/runtime/"
                                                (basename program)))))
    (setenv "XDG_RUNTIME_DIR" directory)
    (list (read-write directory #:create? #t))))

(define* (exec-locked program arguments rules
                      #:key wayland? pipewire? runtime-directory?
                      (environment '()))
  "Execute PROGRAM with ARGUMENTS, allowing only RULES and nothing on the
network, no signals and no abstract sockets outside the sandbox.  WAYLAND? and
PIPEWIRE? give it access to the compositor and to PipeWire,
RUNTIME-DIRECTORY? a private XDG_RUNTIME_DIR.  ENVIRONMENT is an alist of
variables to set."
  (unsetenv "DISPLAY")
  ;; A shared shader cache would let the program poison other programs
  (setenv "MESA_SHADER_CACHE_DISABLE" "true")
  (for-each (match-lambda
              ((name . value) (setenv name value)))
            environment)
  ;; The sockets are found in XDG_RUNTIME_DIR before it is replaced
  (let* ((socket-rules (append (if wayland? (share-wayland!) '())
                               (if pipewire? (share-pipewire!) '())))
         (runtime-rules (if runtime-directory?
                            (private-runtime-directory! program)
                            '())))
    (landlock-exec (append rules socket-rules runtime-rules)
                   (cons program arguments)
                   #:scope '(signal abstract-unix-socket))))

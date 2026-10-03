;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius build locked)
  ;; Only available in the wrappers, not when the channel is compiled
  #:autoload (landlock) (%landlock-read-access landlock-path landlock-exec)
  #:use-module (srfi srfi-1)
  #:export (base-rules
            graphics-rules
            font-rules
            config-rules
            argument-rules
            exec-locked))

(define (xdg-directory variable default name)
  (string-append (or (getenv variable)
                     (string-append (getenv "HOME") "/" default))
                 "/" name))

(define (read-only path)
  (landlock-path path '(read-file read-dir) #:optional? #t))

(define (base-rules)
  "Rules every program needs: the store, /etc, a few devices and its own
/proc entry."
  (list (landlock-path "/gnu/store" %landlock-read-access)
        (read-only "/etc")
        (landlock-path "/dev/null" '(read-file write-file))
        (read-only "/dev/urandom")
        (read-only (string-append "/proc/" (number->string (getpid))))))

(define (graphics-rules)
  "Rules for rendering with the GPU."
  (list (landlock-path "/dev/dri" '(read-file write-file read-dir ioctl-dev)
                       #:optional? #t)
        (read-only "/sys")))

(define (font-rules)
  (list (read-only "/var/cache/fontconfig")
        (read-only (xdg-directory "XDG_CONFIG_HOME" ".config" "fontconfig"))
        (read-only (xdg-directory "XDG_CACHE_HOME" ".cache" "fontconfig"))))

(define (config-rules name)
  "Read access to the configuration directory NAME."
  (list (read-only (xdg-directory "XDG_CONFIG_HOME" ".config" name))))

(define (argument-rules arguments)
  "Read access to the files and directories among ARGUMENTS."
  (filter-map (lambda (argument)
                (and (not (string-prefix? "-" argument))
                     (file-exists? argument)
                     (read-only argument)))
              arguments))

(define (connect-wayland!)
  "Connect to the compositor and pass the connection on in WAYLAND_SOCKET, so
that the program needs no access to the sockets in XDG_RUNTIME_DIR."
  (let* ((display (or (getenv "WAYLAND_DISPLAY") "wayland-0"))
         (path (if (string-prefix? "/" display)
                   display
                   (string-append (getenv "XDG_RUNTIME_DIR") "/" display)))
         (connection (socket AF_UNIX SOCK_STREAM 0)))
    (connect connection AF_UNIX path)
    (setenv "WAYLAND_SOCKET" (number->string (port->fdes connection)))
    (unsetenv "WAYLAND_DISPLAY")))

(define* (exec-locked program arguments rules #:key wayland?)
  "Execute PROGRAM with ARGUMENTS, allowing only RULES and no network, signals
or abstract sockets outside the sandbox."
  (when wayland?
    (connect-wayland!))
  (unsetenv "DISPLAY")
  ;; A shared shader cache would let the program poison other programs
  (setenv "MESA_SHADER_CACHE_DISABLE" "true")
  (landlock-exec rules (cons program arguments)
                 #:scope '(signal abstract-unix-socket)))

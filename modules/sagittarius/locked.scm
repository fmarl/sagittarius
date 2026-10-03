;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (sagittarius packages guile-xyz)
  #:export (locked-command
            locked-package))

(define* (locked-command command target rules
                         #:key wayland? pipewire? runtime-directory?
                         (environment '()))
  "Return COMMAND and a program running TARGET with the rules returned by
RULES, a gexp of a procedure taking the command-line arguments.  The other
arguments are those of exec-locked."
  (cons command
        (program-file
         command
         (with-extensions (list guile-landlock)
           (with-imported-modules '((sagittarius build locked))
             #~(begin
                 (use-modules (sagittarius build locked))
                 (let ((arguments (cdr (command-line))))
                   (exec-locked #$target arguments (#$rules arguments)
                                #:wayland? #$wayland?
                                #:pipewire? #$pipewire?
                                #:runtime-directory? #$runtime-directory?
                                #:environment '#$environment))))))))

(define* (locked-package original commands
                         #:key (name (string-append (package-name original)
                                                    "-locked")))
  "Return a package providing COMMANDS, built with locked-command from those
of ORIGINAL.  It keeps the data in share/ of ORIGINAL and the desktop entries
that start one of COMMANDS."
  (package
    (name name)
    (version (package-version original))
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils)
                       (ice-9 ftw)
                       (ice-9 regex)
                       (ice-9 textual-ports)
                       (srfi srfi-1)
                       (srfi srfi-26))

          (define names '#$(map car commands))
          (define programs (list #$@(map cdr commands)))
          (define share (string-append #$original "/share"))
          (define original-bin (string-append #$original "/bin/"))
          (define bin (string-append #$output "/bin/"))

          (define (starts-command? entry)
            (let ((text (call-with-input-file entry get-string-all)))
              (any (lambda (name)
                     (string-match (string-append (regexp-quote original-bin)
                                                  (regexp-quote name)
                                                  "( |$)")
                                   text))
                   names)))

          (define (install-commands)
            (mkdir-p bin)
            (for-each (lambda (name program)
                        (symlink program (string-append bin name)))
                      names programs))

          (define (link-data)
            (mkdir-p (string-append #$output "/share"))
            (for-each (lambda (entry)
                        (symlink (string-append share "/" entry)
                                 (string-append #$output "/share/" entry)))
                      (scandir share
                               (negate (cut member <>
                                            '("." ".." "applications"))))))

          (define (desktop-entries)
            (let ((directory (string-append share "/applications")))
              (if (file-exists? directory)
                  (filter starts-command? (find-files directory "\\.desktop$"))
                  '())))

          (define (install-desktop-entries)
            (let ((applications (string-append #$output "/share/applications"))
                  (entries (desktop-entries)))
              (unless (null? entries)
                (mkdir-p applications)
                (for-each (lambda (entry)
                            (let ((target (string-append applications "/"
                                                         (basename entry))))
                              (copy-file entry target)
                              (substitute* target
                                (((regexp-quote original-bin)) bin))))
                          entries))))

          (install-commands)
          (when (file-exists? share)
            (link-data)
            (install-desktop-entries)))))
    (home-page (package-home-page original))
    (synopsis (package-synopsis original))
    (description
     (string-append (package-description original)
                    "\n\nThis variant runs the program confined by Landlock."))
    (license (package-license original))))

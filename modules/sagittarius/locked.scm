;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (ice-9 match)
  #:use-module (sagittarius packages guile-xyz)
  #:export (locked-program
            locked-package))

(define (locked-program name exp)
  "Return the program NAME running EXP with (sagittarius build locked)."
  (program-file name
                (with-extensions (list guile-landlock)
                  (with-imported-modules '((sagittarius build locked))
                    #~(begin
                        (use-modules (sagittarius build locked))
                        #$exp)))))

(define* (locked-package original programs
                         #:key (name (string-append (package-name original)
                                                    "-locked")))
  "Return a package whose commands are PROGRAMS, an alist of command names and
programs from locked-program, wrapping those of ORIGINAL.  It keeps the data
in share/ of ORIGINAL and the desktop entries that start one of PROGRAMS."
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
                       (ice-9 match)
                       (ice-9 regex)
                       (ice-9 textual-ports)
                       (srfi srfi-1))

          (define original-bin (string-append #$original "/bin/"))
          (define bin (string-append #$output "/bin/"))
          (define applications (string-append #$output "/share/applications"))

          (define (starts-wrapped-command? entry)
            (let ((text (call-with-input-file entry get-string-all)))
              (any (lambda (command)
                     (string-match (string-append (regexp-quote original-bin)
                                                  (regexp-quote command)
                                                  "( |$)")
                                   text))
                   '#$(map car programs))))

          (mkdir-p bin)
          (for-each (match-lambda
                      ((command . program)
                       (symlink program (string-append bin command))))
                    (list #$@(map (match-lambda
                                    ((command . program)
                                     #~(cons #$command #$program)))
                                  programs)))

          (let ((share (string-append #$original "/share")))
            (when (file-exists? share)
              (mkdir-p (string-append #$output "/share"))
              (for-each (lambda (entry)
                          (symlink (string-append share "/" entry)
                                   (string-append #$output "/share/" entry)))
                        (scandir share
                                 (lambda (entry)
                                   (not (member entry
                                                '("." ".." "applications"))))))))

          (let ((entries (string-append #$original "/share/applications")))
            (when (file-exists? entries)
              (for-each (lambda (entry)
                          (let ((target (string-append applications "/"
                                                       (basename entry))))
                            (mkdir-p applications)
                            (copy-file entry target)
                            (substitute* target
                              (((regexp-quote original-bin)) bin))))
                        (filter starts-wrapped-command?
                                (find-files entries "\\.desktop$"))))))))
    (home-page (package-home-page original))
    (synopsis (package-synopsis original))
    (description
     (string-append (package-description original)
                    "\n\nThis variant runs the program confined by Landlock."))
    (license (package-license original))))

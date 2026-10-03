;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked mail)
  #:use-module (gnu packages mail)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public mu-locked
  (locked-package
   mu
   `(("mu"
      . ,(locked-program
          "mu"
          #~(let ((arguments (cdr (command-line))))
              (exec-locked #$(file-append mu "/bin/mu")
                           arguments
                           (append (base-rules)
                                   (list (read-write (or (getenv "MAILDIR")
                                                         (home-path "Mail")))
                                         (read-write (cache-path "mu")
                                                     #:create? #t)
                                         ;; mu4e saves attachments there and
                                         ;; opens them from temporary files
                                         (read-write (user-directory
                                                      "DOWNLOAD" "Downloads"))
                                         (read-write (or (getenv "TMPDIR")
                                                         "/tmp")))))))))))

(define-public mbsync-locked
  (locked-package
   isync
   `(("mbsync"
      . ,(locked-program
          "mbsync"
          #~(let ((arguments (cdr (command-line))))
              (exec-locked #$(file-append isync "/bin/mbsync")
                           arguments
                           (append (base-rules)
                                   (dns-rules)
                                   (tcp-rules 143 993)
                                   (argument-rules arguments)
                                   ;; For PassCmd decrypting with gpg
                                   (gnupg-rules)
                                   (list (read-only (home-path ".mbsyncrc"))
                                         (read-only (config-path "isyncrc"))
                                         (read-write (or (getenv "MAILDIR")
                                                         (home-path "Mail"))
                                                     #:create? #t))))))))
   #:name "mbsync-locked"))

(define-public msmtp-locked
  (locked-package
   msmtp
   `(("msmtp"
      . ,(locked-program
          "msmtp"
          #~(let ((arguments (cdr (command-line))))
              (exec-locked #$(file-append msmtp "/bin/msmtp")
                           arguments
                           (append (base-rules)
                                   (dns-rules)
                                   (tcp-rules 25 465 587)
                                   (argument-rules arguments)
                                   ;; For passwordeval decrypting with gpg
                                   (gnupg-rules)
                                   (config-rules "msmtp")
                                   (state-rules "msmtp")
                                   (list (read-only
                                          (home-path ".msmtprc")))))))))))

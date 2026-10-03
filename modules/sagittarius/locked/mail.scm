;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked mail)
  #:use-module (gnu packages mail)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public mu-locked
  (locked-package
   mu
   (list (locked-command "mu" (file-append mu "/bin/mu")
                         #~(lambda _
                             (append (base-rules)
                                     (list (read-write (mail-directory))
                                           (read-write (cache-path "mu")
                                                       #:create? #t)
                                           ;; mu4e saves attachments there
                                           ;; and opens them from /tmp
                                           (read-write (user-directory
                                                        "DOWNLOAD" "Downloads"))
                                           (read-write (or (getenv "TMPDIR")
                                                           "/tmp")))))))))

(define-public mbsync-locked
  (locked-package
   isync
   (list (locked-command "mbsync" (file-append isync "/bin/mbsync")
                         #~(lambda (arguments)
                             (append (base-rules)
                                     (dns-rules)
                                     (tcp-rules 143 993)
                                     (argument-rules arguments)
                                     ;; For PassCmd decrypting with gpg
                                     (gnupg-rules)
                                     (list (read-only (home-path ".mbsyncrc"))
                                           (read-only (config-path "isyncrc"))
                                           (read-write (mail-directory)
                                                       #:create? #t))))))
   #:name "mbsync-locked"))

(define-public msmtp-locked
  (locked-package
   msmtp
   (list (locked-command "msmtp" (file-append msmtp "/bin/msmtp")
                         #~(lambda (arguments)
                             (append (base-rules)
                                     (dns-rules)
                                     (tcp-rules 25 465 587)
                                     (argument-rules arguments)
                                     ;; For passwordeval decrypting with gpg
                                     (gnupg-rules)
                                     (config-rules "msmtp")
                                     (state-rules "msmtp")
                                     (list (read-only
                                            (home-path ".msmtprc")))))))))

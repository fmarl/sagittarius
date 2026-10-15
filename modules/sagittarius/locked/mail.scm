;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked mail)
  #:use-module (gnu packages mail)
  #:use-module (guix gexp)
  #:use-module (guix-cage locked))

(define-public mu-locked
  (make-locked-package
   mu
   (list (locked-command
           (name "mu")
           (program (file-append mu "/bin/mu"))
           (rules (list %mail-directory
                        (xdg-cache "mu")
                        ;; mu4e saves attachments there
                        (xdg-user-directory "DOWNLOAD" "Downloads")))
           ;; For the files it passes to mu4e
           (temporary-directory? #t)
           (deny-write-execute? #t)))))

(define-public mbsync-locked
  (make-locked-package
   isync
   (list (locked-command
           (name "mbsync")
           (program (file-append isync "/bin/mbsync"))
           (rules (list %dns
                        (tcp-ports 143 993)
                        %argument-files
                        ;; For PassCmd decrypting with gpg
                        %gnupg
                        (home-file ".mbsyncrc")
                        (xdg-config "isyncrc")
                        %mail-directory))
           (deny-write-execute? #t)))
   #:name "mbsync-locked"
   ;; isync's own starts with a lower-case letter
   #:description "Mbsync synchronizes mailboxes in both directions.  It
supports Maildir and IMAP."))

(define-public msmtp-locked
  (make-locked-package
   msmtp
   (list (locked-command
           (name "msmtp")
           (program (file-append msmtp "/bin/msmtp"))
           (rules (list %dns
                        (tcp-ports 25 465 587)
                        %argument-files
                        ;; For passwordeval decrypting with gpg
                        %gnupg
                        (xdg-config "msmtp")
                        (xdg-state "msmtp")
                        (home-file ".msmtprc")))
           (temporary-directory? #t)
           (deny-write-execute? #t)))))

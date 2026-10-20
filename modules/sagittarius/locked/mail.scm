;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked mail)
  #:use-module (gnu packages mail)
  #:use-module (guix gexp)
  #:use-module (guix-cage locked))

(define %password-command
  ;; secret decrypts the password with sops and gpg
  (list %shell
        (home-file ".local/bin/secret" '(read execute))
        (home-file ".config/sops/secrets.yaml")
        %gnupg))

(define-public mu-locked
  (make-locked-package
   mu
   (list (locked-command
           (name "mu")
           (program (file-append mu "/bin/mu"))
           (rules (list %mail-directory
                        (xdg-cache "mu")
                        ;; mu4e saves attachments there
                        (xdg-user-directory "DOWNLOAD" "Downloads")
                        ;; mu4e reads the files that mu writes there
                        %shared-temporary-directory))
           (deny-write-execute? #t)))))

(define-public mbsync-locked
  (make-locked-package
   isync
   (list (locked-command
           (name "mbsync")
           (program (file-append isync "/bin/mbsync"))
           (rules (cons* %dns
                         (tcp-ports 993)
                         (home-file ".mbsyncrc")
                         (xdg-config "isyncrc")
                         %mail-directory
                         %password-command))
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
           (rules (cons* %dns
                         (tcp-ports 465)
                         (home-file ".msmtprc")
                         (xdg-config "msmtp")
                         (xdg-state "msmtp")
                         %temporary-directory
                         %password-command))
           (deny-write-execute? #t)))))

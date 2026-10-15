;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked gnupg)
  #:use-module (gnu packages gnupg)
  #:use-module (guix gexp)
  #:use-module (guix-cage locked))

(define-public pinentry-bemenu-locked
  (make-locked-package
   pinentry-bemenu
   (list (locked-command
           (name "pinentry-bemenu")
           (program (file-append pinentry-bemenu "/bin/pinentry-bemenu"))
           (rules (list %fonts))
           (wayland 'full)
           (runtime-directory? #t)
           (executes? #f)
           (deny-write-execute? #t)))))

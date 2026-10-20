;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked image-viewers)
  #:use-module (gnu packages image-viewers)
  #:use-module (guix gexp)
  #:use-module (guix-cage locked))

(define-public imv-locked
  (make-locked-package
   imv
   (list (locked-command
           (name "imv")
           (program (file-append imv "/bin/imv-wayland"))
           (rules (list %graphics
                        %fonts
                        %wayland
                        (xdg-config "imv")
                        %argument-files))
           (executes? #f)
           (deny-write-execute? #t)))))

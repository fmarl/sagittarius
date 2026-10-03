;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked image-viewers)
  #:use-module (gnu packages image-viewers)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public imv-locked
  (locked-package
   imv
   (list (locked-command "imv" (file-append imv "/bin/imv-wayland")
                         #~(lambda (arguments)
                             (append (base-rules)
                                     (graphics-rules)
                                     (font-rules)
                                     (config-rules "imv")
                                     (argument-rules arguments)))
                         #:wayland? #t))))

;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked pdf)
  #:use-module (gnu packages pdf)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public zathura-locked
  (locked-package
   zathura
   ;; zathura-sandbox adds its own seccomp filter
   (list (locked-command "zathura" (file-append zathura "/bin/zathura-sandbox")
                         #~(lambda (arguments)
                             (append (base-rules)
                                     (font-rules)
                                     (config-rules "zathura")
                                     (config-rules "gtk-3.0")
                                     (argument-rules arguments)))
                         #:wayland? #t
                         #:environment '(("NO_AT_BRIDGE" . "1"))))))

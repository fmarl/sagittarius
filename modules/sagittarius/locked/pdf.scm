;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked pdf)
  #:use-module (gnu packages pdf)
  #:use-module (guix gexp)
  #:use-module (guix-cage locked))

(define-public zathura-locked
  (make-locked-package
   zathura
   ;; zathura-sandbox adds its own seccomp filter
   (list (locked-command
           (name "zathura")
           (program (file-append zathura "/bin/zathura-sandbox"))
           (rules (list %fonts
                        %wayland
                        (xdg-config "zathura")
                        (xdg-config "gtk-3.0")
                        %argument-files))
           (environment '(("NO_AT_BRIDGE" . "1")))
           (executes-others? #f)
           (deny-write-execute? #t)))))

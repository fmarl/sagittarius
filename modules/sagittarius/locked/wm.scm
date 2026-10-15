;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked wm)
  #:use-module (gnu packages window-management)
  #:use-module (guix gexp)
  #:use-module (guix-cage locked))

(define-public swaybg-locked
  (make-locked-package
   swaybg
   (list (locked-command
           (name "swaybg")
           (program (file-append swaybg "/bin/swaybg"))
           (rules (list %fonts
                        %shm
                        %argument-files))
           (wayland 'full)
           (executes? #f)))))

(define-public mako-locked
  (make-locked-package
   mako
   (list (locked-command
           (name "mako")
           (program (file-append mako "/bin/mako"))
           (rules (list %fonts
                        (xdg-config "mako")
                        %shm))
           (wayland 'full)
           (dbus '("--own=org.freedesktop.Notifications"))))))

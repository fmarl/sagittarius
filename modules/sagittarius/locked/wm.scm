;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked wm)
  #:use-module (gnu packages window-management)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public swaybg-locked
  (locked-package
   swaybg
   (list (locked-command "swaybg" (file-append swaybg "/bin/swaybg")
                         #~(lambda (arguments)
                             (append (base-rules)
                                     (font-rules)
                                     ;; For its buffers, from shm_open
                                     (list (read-write "/dev/shm"))
                                     (argument-rules arguments)))
                         #:wayland? #t))))

(define-public mako-locked
  (locked-package
   mako
   (list (locked-command "mako" (file-append mako "/bin/mako")
                         #~(lambda _
                             (append (base-rules)
                                     (font-rules)
                                     (config-rules "mako")
                                     (dbus-rules)
                                     ;; For its buffers, from shm_open
                                     (list (read-write "/dev/shm"))))
                         #:wayland? #t))))

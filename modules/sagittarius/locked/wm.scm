;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked wm)
  #:use-module (gnu packages wm)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public swaybg-locked
  (locked-package
   swaybg
   `(("swaybg"
      . ,(locked-program
          "swaybg"
          #~(let ((arguments (cdr (command-line))))
              (exec-locked #$(file-append swaybg "/bin/swaybg")
                           arguments
                           (append (base-rules)
                                   (font-rules)
                                   ;; For its buffers, from shm_open
                                   (list (read-write "/dev/shm"))
                                   (argument-rules arguments))
                           #:wayland? #t)))))))

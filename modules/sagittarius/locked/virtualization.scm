;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked virtualization)
  #:use-module (gnu packages virtualization)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public qemu-locked
  (locked-package
   qemu
   `(("qemu-system-x86_64"
      . ,(locked-program
          "qemu-system-x86_64"
          #~(let ((arguments (cdr (command-line))))
              (exec-locked #$(file-append qemu "/bin/qemu-system-x86_64")
                           arguments
                           (append (base-rules)
                                   (device-rules "/dev/kvm" "/dev/vhost-vsock")
                                   (list (read-only "/sys"))
                                   (option-path-rules arguments)))))))))

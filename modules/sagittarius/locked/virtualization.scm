;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked virtualization)
  #:use-module (gnu packages virtualization)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-locked-rules (sagittarius build locked virtualization)
  %qemu)

(define-public qemu-locked
  (make-locked-package
   qemu
   (list (locked-command
           (name "qemu-system-x86_64")
           (program (file-append qemu "/bin/qemu-system-x86_64"))
           (rules (list (devices "/dev/kvm" "/dev/vhost-vsock")
                        (read-only "/sys")
                        %qemu))
           (preserved-environment-variables
            (cons "QEMU_*" %default-preserved-environment-variables))))))

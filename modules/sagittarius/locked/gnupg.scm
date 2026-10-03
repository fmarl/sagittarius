;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked gnupg)
  #:use-module (gnu packages gnupg)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public pinentry-bemenu-locked
  (locked-package
   pinentry-bemenu
   (list (locked-command "pinentry-bemenu"
                         (file-append pinentry-bemenu "/bin/pinentry-bemenu")
                         #~(lambda _
                             (append (base-rules) (font-rules)))
                         #:wayland? #t
                         ;; bemenu keeps its buffers in XDG_RUNTIME_DIR
                         #:runtime-directory? #t))))

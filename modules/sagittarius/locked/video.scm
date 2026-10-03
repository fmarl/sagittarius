;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked video)
  #:use-module (gnu packages video)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public mpv-locked
  (locked-package
   mpv
   (list (locked-command "mpv" (file-append mpv "/bin/mpv")
                         #~(lambda (arguments)
                             (append (base-rules)
                                     (graphics-rules)
                                     (font-rules)
                                     (config-rules "mpv")
                                     (state-rules "mpv")
                                     (list (read-write (cache-path "mpv")
                                                       #:create? #t))
                                     (argument-rules arguments)
                                     (if (url-arguments? arguments)
                                         (append (dns-rules)
                                                 (tcp-rules 80 443))
                                         '())))
                         #:wayland? #t
                         #:pipewire? #t))))

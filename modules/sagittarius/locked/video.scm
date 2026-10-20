;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked video)
  #:use-module (gnu packages video)
  #:use-module (guix gexp)
  #:use-module (guix-cage locked))

(define-public mpv-locked
  (make-locked-package
   mpv
   (list (locked-command
           (name "mpv")
           (program (file-append mpv "/bin/mpv"))
           (rules (list %gui
                        %pipewire
                        (xdg-config "mpv")
                        (xdg-state "mpv")
                        (xdg-cache "mpv")
                        %argument-files
                        (when-arguments
                         '(urls (extensions ".m3u" ".m3u8" ".pls"))
                         %dns (tcp-ports 80 443))))
           (preserved-environment-variables
            (cons "MPV_*" %default-preserved-environment-variables))
           (deny-write-execute? #t)))))

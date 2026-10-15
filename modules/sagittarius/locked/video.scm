;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked video)
  #:use-module (gnu packages video)
  #:use-module (guix gexp)
  #:use-module (sagittarius locked))

(define-public mpv-locked
  (make-locked-package
   mpv
   (list (locked-command
           (name "mpv")
           (program (file-append mpv "/bin/mpv"))
           (rules (list %graphics
                        %fonts
                        (xdg-config "mpv")
                        (xdg-state "mpv")
                        (xdg-cache "mpv")
                        %argument-files
                        (when-network-arguments
                         #:playlists '(".m3u" ".m3u8" ".pls")
                         %dns (tcp-ports 80 443))))
           (wayland 'restricted)
           (pipewire? #t)
           (preserved-environment-variables
            (cons "MPV_*" %default-preserved-environment-variables))
           (deny-write-execute? #t)))))

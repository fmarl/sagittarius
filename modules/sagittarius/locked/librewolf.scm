;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius locked librewolf)
  #:use-module (gnu packages librewolf)
  #:use-module (guix gexp)
  #:use-module (guix-cage locked))

(define-public librewolf-locked
  (make-locked-package
   librewolf
   (list (locked-command
           (name "librewolf")
           (program (file-append librewolf "/bin/librewolf"))
           (rules (list %gui
                        %shm
                        %pulseaudio
                        %dns
                        (tcp-ports 80 443)
                        (xdg-config "librewolf" '(read write))
                        (xdg-cache "librewolf")
                        (xdg-config "gtk-3.0")
                        (xdg-user-directory "DOWNLOAD" "Downloads")
                        %temporary-directory
                        %argument-files
                        (dbus "--own=io.gitlab.librewolf.*"
                              "--own=org.mpris.MediaPlayer2.firefox.*"
                              "--talk=org.freedesktop.Notifications")))
           (preserved-environment-variables
            (cons "MOZ_*" %default-preserved-environment-variables))
           (allowed-syscall-groups '(user-namespaces))))))

;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2023 Giacomo Leidi <goodoldpaul@autistici.org>
;;; Copyright © 2025 Benjamin Slade <slade@lambda-y.net>
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages vpn)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages networking)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (sagittarius build-system chromium-binary)
  #:use-module ((guix licenses) #:prefix license:))

(define-public mullvad-vpn-desktop
  (package
    (name "mullvad-vpn-desktop")
    (version "2026.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/mullvad/mullvadvpn-app/releases/"
                           "download/" version "/MullvadVPN-" version
                           "_amd64.deb"))
       (file-name (string-append name "-" version "-x86_64-linux.deb"))
       (sha256
        (base32 "1jhsjf707mv3i29i1r62cb6dml5n4n2s48h9as40d1w0mrryxiiq"))))
    (build-system chromium-binary-build-system)
    (arguments
     (list
      #:validate-runpath? #f ;TODO: fails on wrapped binary and included other files
      #:wrapper-plan
      #~(append
         (list "usr/bin/mullvad"
               "usr/bin/mullvad-daemon"
               "usr/bin/mullvad-exclude")
         (map (lambda (file)
                (string-append "opt/Mullvad VPN/" file))
              '("chrome-sandbox"
                "chrome_crashpad_handler"
                "libEGL.so"
                "libffmpeg.so"
                "libGLESv2.so"
                "libvk_swiftshader.so"
                "libvulkan.so.1"
                "mullvad-gui"
                "resources/mullvad-problem-report"
                "resources/mullvad-setup")))
      #:install-plan
      #~'(("opt/" "/share")
          ("usr/bin/" "/bin")
          ("usr/lib/" "/lib")
          ("usr/local/share/" "/share")
          ("usr/share/" "/share"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'binary-unpack 'delete-problem-report
            (lambda _
              ;; Replaced by a symlink to resources/mullvad-problem-report.
              (delete-file "usr/bin/mullvad-problem-report")))
          (add-before 'install 'patch-assets
            (lambda _
              (let ((old-exe "/opt/Mullvad VPN/mullvad-vpn"))
                (patch-shebang (string-append "." old-exe))
                (substitute* "usr/share/applications/mullvad-vpn.desktop"
                  (("^Icon=mullvad-vpn")
                   (string-append "Icon=" #$output "/share/icons/hicolor"
                                  "/1024x1024/apps/mullvad-vpn.png"))
                  (((string-append "^Exec=" old-exe))
                   (string-append "Exec=" #$output "/bin/mullvad-vpn"))))))
          (add-before 'install-wrapper 'symlink-entrypoint
            (lambda _
              (let* ((bin (string-append #$output "/bin"))
                     (exe (string-append bin "/mullvad-vpn"))
                     (share (string-append #$output "/share/Mullvad VPN"))
                     (resources (string-append share "/resources")))
                (symlink (string-append resources "/mullvad-problem-report")
                         (string-append bin "/mullvad-problem-report"))
                (symlink (string-append share "/mullvad-vpn") exe)
                (wrap-program exe
                  `("MULLVAD_DISABLE_UPDATE_NOTIFICATION" = ("1"))
                  `("LD_LIBRARY_PATH" = (,share)))
                (wrap-program (string-append bin "/mullvad-daemon")
                  `("MULLVAD_RESOURCE_DIR" = (,resources)))))))))
    (inputs (list iputils libnotify))
    (supported-systems '("x86_64-linux"))
    (home-page "https://mullvad.net")
    (synopsis "Mullvad VPN client app for desktop")
    (description
     "This package provides the desktop client for the Mullvad VPN service:
a graphical interface, the @command{mullvad} command-line tool and the
@command{mullvad-daemon} background service.")
    (license license:gpl3)))

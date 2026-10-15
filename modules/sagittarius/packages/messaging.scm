;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2021, 2022 PantherX OS Team <team@pantherx.org>
;;; Copyright © 2022-2025 John Kehayias <john.kehayias@protonmail.com>
;;; Copyright © 2023 Giacomo Leidi <goodoldpaul@autistici.org>
;;; Copyright © 2025, 2026 Ashish SHUKLA <ashish.is@lostca.se>
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages messaging)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (sagittarius build-system chromium-binary)
  #:use-module ((guix licenses) #:prefix license:))

(define-public signal-desktop
  (package
    (name "signal-desktop")
    (version "8.30.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://updates.signal.org/desktop/apt/pool/s/"
                           name
                           "/"
                           name
                           "_"
                           version
                           "_amd64.deb"))
       (sha256
        (base32 "0jg5rd0347rg9lspp3h6g4yywnc2sw08hp2yx0cb7x2riybbhp34"))))
    (build-system chromium-binary-build-system)
    (arguments
     (list
      ;; Fails on the wrapped binary and the other bundled files.
      #:validate-runpath? #f
      #:wrapper-plan
      #~'(("lib/Signal/signal-desktop" (("out" "/lib/Signal"))))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'binary-unpack 'setup-cwd
            (lambda _
              (copy-recursively "usr/" ".")
              (rename-file "opt/" "lib")
              (delete-file-recursively "usr")
              (substitute* "share/applications/signal-desktop.desktop"
                (("/opt/Signal/")
                 (string-append #$output "/bin/"))
                ;; Match the lowercase application ID so the icon shows.
                (("StartupWMClass=Signal")
                 "StartupWMClass=signal"))))
          (add-after 'install 'symlink-binary-file
            (lambda _
              (mkdir-p (string-append #$output "/bin"))
              (symlink (string-append #$output "/lib/Signal/signal-desktop")
                       (string-append #$output "/bin/signal-desktop"))))
          ;; Keep the database key in the Secret Service, not in config.json.
          (add-after 'install-wrapper 'use-libsecret
            (lambda _
              (substitute* (string-append #$output "/bin/signal-desktop")
                (("\"\\$@\"")
                 "--password-store=gnome-libsecret \"$@\"")))))))
    (supported-systems '("x86_64-linux"))
    (properties '((release-monitoring-url . "https://github.com/signalapp/Signal-Desktop/releases")))
    (home-page "https://signal.org/")
    (synopsis "Private messenger using the Signal protocol")
    (description
     "Signal Desktop is an Electron application that links with Signal on
Android or iOS.  This package stores its database key in the Secret Service.")
    (license license:agpl3)))

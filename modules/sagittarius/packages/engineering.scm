;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages engineering)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (guix build-system cargo)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public solidcraft
  (package
    (name "solidcraft")
    (version "0.20.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/tangency-labs/solidcraft")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0siakg52kda559p8cyijg6ymh7g7v36icdb56h4504dlxfar22z6"))))
    (build-system cargo-build-system)
    (arguments
     (list
      #:rust rust-1.95
      #:install-source? #f
      #:tests? #f
      #:cargo-build-flags ''("--release" "-p" "solidcraft" "-p"
                             "solidcraft-cli")
      #:cargo-install-paths ''("apps/solidcraft" "apps/solidcraft-cli")
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'build 'use-system-zstd
            (lambda _
              (setenv "ZSTD_SYS_USE_PKG_CONFIG" "1")))
          (add-after 'install 'install-desktop-files
            (lambda _
              (let ((linux "assets/platforms/linux/ai.storyteller.solidcraft")
                    (share (string-append #$output "/share")))
                (install-file (string-append linux ".desktop")
                              (string-append share "/applications"))
                (mkdir-p (string-append share "/mime/packages"))
                (copy-file (string-append linux ".mime.xml")
                           (string-append share "/mime/packages/"
                                          "ai.storyteller.solidcraft.xml"))
                (copy-recursively "assets/icons/app/linux/exports/hicolor"
                                  (string-append share "/icons/hicolor")))))
          (add-after 'install 'remove-alias
            (lambda _
              ;; Forwards to solidcraft-cli under the project's former name.
              (delete-file (string-append #$output "/bin/solvecraft-cli"))))
          (add-after 'install-desktop-files 'wrap-programs
            (lambda* (#:key inputs #:allow-other-keys)
              ;; winit, wgpu and rfd dlopen these libraries; the CLI renders
              ;; snapshots through wgpu as well.
              (let ((path (map (lambda (library)
                                 (dirname (search-input-file inputs
                                                             (string-append
                                                              "lib/" library))))
                               '("libwayland-client.so" "libxkbcommon.so"
                                 "libEGL.so"
                                 "libvulkan.so"
                                 "libdbus-1.so"
                                 "libX11.so"
                                 "libXcursor.so"
                                 "libXi.so"
                                 "libXrandr.so"
                                 "libX11-xcb.so"
                                 "libxcb.so"))))
                (for-each (lambda (program)
                            (wrap-program (string-append #$output "/bin/"
                                                         program)
                              `("LD_LIBRARY_PATH" prefix
                                ,path)))
                          '("solidcraft" "solidcraft-cli"))))))))
    (native-inputs (list pkg-config))
    (inputs (append (list bash-minimal
                          dbus
                          libx11
                          libxcb
                          libxcursor
                          libxi
                          libxkbcommon
                          libxrandr
                          mesa
                          vulkan-loader
                          wayland
                          `(,zstd "lib"))
                    (cargo-inputs 'solidcraft
                                  #:module '(sagittarius packages rust-crates))))
    (home-page "https://solidcraft.io")
    (synopsis "Parametric 3D CAD application")
    (description
     "SolidCraft is a parametric 3D CAD application written in Rust.")
    (license (list license:expat license:asl2.0))))

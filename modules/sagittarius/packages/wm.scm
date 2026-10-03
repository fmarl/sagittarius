;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages wm)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages man)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages zig)
  #:use-module (guix build-system asdf)
  #:use-module (guix build-system zig)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (sagittarius packages zig-xyz))

(define %river-zig-dependencies
  ;; Dependencies as named in build.zig.zon.
  '("pixman" "translate_c" "wayland" "wlroots" "xkbcommon"))

(define-public river-0.4
  (package
    (name "river")
    (version "0.4.8")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/river/river")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0xj31k5hjdll01rq0z47r61whc3zcv0krwcfczcdhx9cvp4qd8xy"))))
    (build-system zig-build-system)
    (arguments
     (list
      #:zig zig-0.16
      #:install-source? #f
      #:zig-release-type "safe"
      #:zig-build-flags
      #~(list "-Dpie"
              "-Dxwayland"
              "--search-prefix"
              #$(this-package-input "libinput-minimal")
              "--search-prefix"
              #$(this-package-input "eudev"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-path
            (lambda _
              (substitute* "build.zig"
                (("/bin/sh")
                 (which "sh")))))
          (add-after 'unpack 'prepare-build.zig.zon
            #$(rename-zon-dependencies %river-zig-dependencies))
          (add-before 'build 'revert-build.zig.zon
            #$(rename-zon-dependencies %river-zig-dependencies #:revert? #t))
          (add-after 'install 'install-wayland-session
            (lambda _
              (install-file "contrib/river.desktop"
                            (string-append #$output
                                           "/share/wayland-sessions")))))))
    (inputs (list libevdev
                  eudev
                  zig-translate-c
                  zig-wayland-for-river-0.4
                  zig-wlroots-for-river-0.4
                  zig-xkbcommon-for-river-0.4
                  libinput-minimal))
    (native-inputs (list pkg-config scdoc))
    (home-page "https://isaacfreund.com/software/river/")
    (synopsis "Dynamic tiling Wayland compositor")
    (description
     "River is a dynamic tiling Wayland compositor with flexible runtime
configuration.  It can run nested in an X11/Wayland session or also directly
from a tty using KMS/DRM.")
    (license license:gpl3)))

(define-public nucleotide
  (let ((commit "cb7f9c52e8cd5bbe8fbc5797595f310867dca058")
        (revision "0"))
    (package
      (name "nucleotide")
      (version (git-version "0.2" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://codeberg.org/fmarl/nucleotide")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0nswx8arks72yfps5cbnpr3665l7p2z61hxh8qmlsk80dbi3fbp3"))))
      (build-system asdf-build-system/sbcl)
      (arguments
       (list
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'create-asdf-configuration 'build-program
              (lambda* (#:key outputs #:allow-other-keys)
                (build-program
                 (string-append #$output "/bin/nucleotide")
                 outputs
                 #:dependencies '("nucleotide" "slynk" "slynk/mrepl")
                 #:dependency-prefixes
                 (list #$output #$(this-package-input "sbcl-slynk"))
                 #:compress? #t
                 #:entry-program
                 '((sb-ext:disable-debugger)
                   (nucleotide:start-repl-server :port 4005)
                   (nucleotide:start-wm)
                   (sb-thread:join-thread
                    (nucleotide::wm-thread nucleotide:*wm*))
                   0)))))))
      (inputs (list sbcl-slynk))
      (native-inputs (list sbcl))
      (synopsis "Hackable Wayland window manager")
      (description
       "Nucleotide is a hackable Wayland window manager written in Common Lisp.
It starts a Slynk REPL server on port 4005 through which it can be inspected
and modified while running.")
      (home-page "https://codeberg.org/fmarl/nucleotide")
      (license license:gpl3))))

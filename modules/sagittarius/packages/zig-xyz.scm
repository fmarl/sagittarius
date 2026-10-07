;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages zig-xyz)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages window-management)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages zig)
  #:use-module (gnu packages zig-xyz)
  #:use-module (guix build-system zig)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix search-paths)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:export (rename-zon-dependencies))

(define (zig-package-name dependency)
  "Return the name of the package providing the build.zig.zon DEPENDENCY,
e.g. \"zig-translate-c\" for \"translate_c\"."
  (string-append "zig-" (string-map (lambda (c)
                                      (if (char=? c #\_) #\- c))
                                    dependency)))

(define* (rename-zon-dependencies dependencies #:key revert?)
  "Return a phase that renames DEPENDENCIES in build.zig.zon to the names of
their packages, or back to their original names when REVERT? is true.

'zig-build-system' stores each dependency under the name of its package, but
build.zig refers to the original names, which must be restored before
building."
  (let ((renames
         (map (lambda (dependency)
                (let ((field (string-append "." dependency))
                      (package-field (string-append
                                      ".@\"" (zig-package-name dependency) "\"")))
                  (if revert?
                      (cons package-field field)
                      (cons field package-field))))
              dependencies)))
    #~(lambda _
        (for-each (lambda (rename)
                    (substitute* "build.zig.zon"
                      (((string-append "\\" (car rename)))
                       (cdr rename))))
                  '#$renames))))

(define wlroots-X11
  (package
    (inherit wlroots)
    (name "wlroots-X11")
    (arguments
     (substitute-keyword-arguments (package-arguments wlroots)
       ((#:configure-flags flags #~'())
        #~(cons "-Dbackends=['drm', 'libinput', 'x11']" #$flags))))
    (propagated-inputs (modify-inputs (package-propagated-inputs wlroots)
                         (prepend xcb-util-renderutil)))))

(define-public zig-xkbcommon-for-river-0.4
  (let ((commit "2f3ecd857bad2418cda36c56b794b5a5310391fb")
        (revision "2"))
    (package
      (name "zig-xkbcommon")
      (version (git-version "0.4.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://codeberg.org/ifreund/zig-xkbcommon")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "18cjrv4gzyihs6cvr1djkb74lj76yn84p65s71ihp11fywzjc2fd"))))
      (build-system zig-build-system)
      (arguments
       (list
        #:zig zig-0.16
        #:skip-build? #t))
      (propagated-inputs (list libxkbcommon))
      (synopsis "Zig bindings for libxkbcommon")
      (description
       "This package provides Zig bindings for @code{libxkbcommon}.")
      (home-page "https://codeberg.org/ifreund/zig-xkbcommon")
      (license license:expat))))

(define-public zig-wayland-for-river-0.4
  (let ((commit "3c6da94905ac1b27fe7792709e1b05cc55052d5a")
        (revision "1"))
    (package
      (name "zig-wayland")
      (version (git-version "0.6.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://codeberg.org/ifreund/zig-wayland")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "10chjkhahkjpl9wn308qdasa955rnipsmlrzp3wryl2rv16chvyy"))))
      (build-system zig-build-system)
      (arguments
       (list
        #:zig zig-0.16
        #:zig-release-type "safe"
        #:zig-build-flags
        #~(list "-Denable-tests")
        #:zig-test-flags
        #~(list "-Denable-tests")
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'configure 'fix-cross-compilation
              (lambda _
                (substitute* "build.zig"
                  (("pkg-config")
                   (getenv "PKG_CONFIG"))))))))
      (propagated-inputs (list wayland wayland-protocols))
      (native-inputs (list pkg-config wayland))
      (synopsis "Zig Wayland bindings and protocol scanner")
      (description
       "This package provides Zig bindings for @code{wayland} and a
@code{Scanner} interface.")
      (home-page "https://codeberg.org/ifreund/zig-wayland")
      (license license:expat))))

(define-public zig-wlroots-for-river-0.4
  (let ((commit "7a18c03dca6afa0d80bd9e3a0619e5e5ccd18e20")
        (revision "1")
        (dependencies '("pixman" "wayland" "xkbcommon")))
    (package
      (name "zig-wlroots")
      (version (git-version "0.20.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://codeberg.org/ifreund/zig-wlroots")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "16cy0a65jddfhsvgvcmbj5ln7wx37nia6j6rr062k272dhkwgz3i"))))
      (build-system zig-build-system)
      (arguments
       (list
        #:zig zig-0.16
        #:zig-release-type "fast"
        #:zig-build-flags
        #~(list "-Denable-tests")
        #:zig-test-flags
        #~(list "-Denable-tests")
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'prepare-build.zig.zon
              #$(rename-zon-dependencies dependencies))
            (add-before 'build 'revert-build.zig.zon
              #$(rename-zon-dependencies dependencies
                                         #:revert? #t)))))
      (propagated-inputs (list wlroots-X11 zig-pixman
                               zig-wayland-for-river-0.4
                               zig-xkbcommon-for-river-0.4))
      (native-inputs (list pkg-config))
      (synopsis "Zig bindings for wlroots")
      (description "This package provides Zig bindings for @code{wlroots}.")
      (home-page "https://codeberg.org/ifreund/zig-wlroots")
      (license license:expat))))

(define-public zig-arocc
  ;; No releases yet; this is the commit required by zig-translate-c.
  (let ((commit "5f5a050569a95ecc40a426f0c3666ae7ef987ede")
        (revision "0"))
    (package
      (name "zig-arocc")
      (version (git-version "0.0.1" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/Vexu/arocc")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "073ky6pbs9z9v0vnjs972pxvrhx5jja0g31hv6d4irdifm4p9ikz"))))
      (build-system zig-build-system)
      (arguments
       (list
        #:zig zig-0.16
        #:zig-build-flags
        #~(list (string-append "-Dgcc-install-prefix="
                               #$gcc-toolchain))
        #:phases
        #~(modify-phases %standard-phases
            (add-before 'check 'use-local-cache
              (lambda _
                ;; Aro looks for its builtin headers in an "include" directory
                ;; above its executable, so the tests need the cache inside
                ;; the source tree.
                (setenv "ZIG_LOCAL_CACHE_DIR"
                        (string-append (getcwd) "/.zig-cache"))))
            ;; Aro does not implement C_INCLUDE_PATH and LIBRARY_PATH yet,
            ;; so pass their directories as -I and -L options.
            (add-after 'install 'wrap-program
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((arocc (string-append #$output "/bin/arocc"))
                      (wrapped-file (string-append #$output "/bin/.arocc-real"))
                      (sh (search-input-file inputs "/bin/sh")))
                  (rename-file arocc wrapped-file)
                  (call-with-output-file arocc
                    (lambda (port)
                      (format port
                       "#!~a
set -f
args=()
IFS=:
for d in $C_INCLUDE_PATH; do [ -n \"$d\" ] && args+=(\"-I$d\"); done
for d in $LIBRARY_PATH; do [ -n \"$d\" ] && args+=(\"-L$d\"); done
unset IFS
set +f
exec -a \"${0##*/}\" \"~a\" \"${args[@]}\" \"$@\"~%"
                       sh
                       (canonicalize-path wrapped-file))))
                  (chmod arocc #o755)))))))
      (search-paths
       (list $C_INCLUDE_PATH $LIBRARY_PATH))
      (native-search-paths
       search-paths)
      (inputs (list gcc-toolchain bash-minimal))
      (home-page "https://github.com/Vexu/arocc")
      (synopsis "C compiler written in Zig")
      (description
       "Aro is a C compiler written in Zig with a complete implementation of
multiple C standards.")
      (license license:expat))))

(define-public zig-translate-c
  (package
    (name "zig-translate-c")
    (version "1.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/ziglang/translate-c")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0hjzgskrxzqy1c3smg2iqbd7834g9s2nckzswnl4ll5qy6xpgmmm"))))
    (build-system zig-build-system)
    (arguments
     (list
      #:zig zig-0.16))
    (propagated-inputs (list zig-arocc))
    (home-page "https://codeberg.org/ziglang/translate-c")
    (synopsis "Zig library for translating C code into Zig code")
    (description
     "translate-c is a Zig library maintained by the Zig Software Foundation
that translates C code into Zig.  It is meant to replace the C translation
built into the Zig compiler.")
    (license license:expat)))

;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2023, 2025 Giacomo Leidi <goodoldpaul@autistici.org>
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius build-system chromium-binary)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages kerberos)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xml)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix build-system)
  #:use-module (guix packages)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module ((sagittarius build-system binary)
                #:select ((lower . binary-lower)
                          binary-build
                          %binary-build-system-modules))
  #:export (%chromium-binary-build-system-modules
            chromium-binary-build
            chromium-binary-build-system))

;; Commentary:
;;
;; Standard build procedure for Chromium based binary packages.  This is
;; implemented as an extension of `binary-build-system'.
;; Copied and modified from the nonguix project.
;;
;; Code:

(define (add-input-labels . inputs)
  "Return INPUTS, each a package or a list of a package and an output,
labeled with their package names."
  (map (match-lambda
         ((package output)
          (list (package-name package) package output))
         (package
          (list (package-name package) package)))
       inputs))

(define %chromium-binary-build-system-modules
  `((sagittarius build chromium-binary-build-system)
    ,@%binary-build-system-modules))

(define (chromium-inputs)
  "Return the inputs needed by Chromium based binaries."
  (add-input-labels
   alsa-lib
   at-spi2-core
   bash-minimal
   cairo
   cups
   dbus
   eudev
   expat
   fontconfig
   freetype
   `(,gcc "lib")
   glib
   gtk+
   libdrm
   libnotify
   librsvg
   libsecret
   libx11
   libxcb
   libxcomposite
   libxcursor
   libxdamage
   libxext
   libxfixes
   libxi
   libxkbcommon
   libxkbfile
   libxrandr
   libxrender
   libxshmfence
   libxtst
   mesa
   mit-krb5
   nspr
   nss
   pango
   pulseaudio
   sqlcipher
   xcb-util
   xcb-util-image
   xcb-util-keysyms
   xcb-util-renderutil
   xcb-util-wm
   xdg-utils                            ;for xdg-open and xdg-email commands
   zlib))

(define* (lower name #:key (inputs '()) #:allow-other-keys #:rest arguments)
  "Return the bag of `binary-build-system' for NAME, with the inputs needed by
Chromium based binaries added."
  (and=> (apply binary-lower name
                #:inputs (append inputs (chromium-inputs))
                (strip-keyword-arguments '(#:inputs) arguments))
         (lambda (binary-bag)
           (bag
             (inherit binary-bag)
             (build chromium-binary-build)
             (arguments
              `(,@(bag-arguments binary-bag)
                #:wrap-inputs ,(alist-delete "source"
                                             (bag-host-inputs binary-bag))))))))

(define (wrapper-plan->patchelf-plan wrapper-plan inputs)
  "Return a PATCHELF-PLAN adding INPUTS to the RPATH of each file in
WRAPPER-PLAN.  Entries of WRAPPER-PLAN are file names or lists of a file name
and additional inputs."
  #~(let ((patchelf-inputs '#$(map car inputs)))
      (map (lambda (entry)
             (if (list? entry)
                 (list (car entry) (append patchelf-inputs (cadr entry)))
                 (list entry patchelf-inputs)))
           #$wrapper-plan)))

(define* (chromium-binary-build name inputs
                                #:key wrap-inputs
                                (wrapper-plan ''())
                                (patchelf-plan ''())
                                (phases
                                 '(@ (sagittarius build
                                                     chromium-binary-build-system)
                                     %standard-phases))
                                (imported-modules
                                 %chromium-binary-build-system-modules)
                                (modules
                                 '((sagittarius build
                                                chromium-binary-build-system)
                                   ((sagittarius build binary-build-system)
                                    #:select (binary-build))
                                   (guix build utils)))
                                #:allow-other-keys
                                #:rest arguments)
  "Build SOURCE with 'binary-build', adding WRAP-INPUTS to the RPATH of the
files in WRAPPER-PLAN.  PATCHELF-PLAN is used only when WRAPPER-PLAN is empty."
  (apply binary-build name inputs
         #:patchelf-plan (if (equal? wrapper-plan ''())
                             patchelf-plan
                             (wrapper-plan->patchelf-plan wrapper-plan
                                                          wrap-inputs))
         #:phases phases
         #:imported-modules imported-modules
         #:modules modules
         (strip-keyword-arguments '(#:wrap-inputs #:wrapper-plan
                                    #:patchelf-plan #:phases
                                    #:imported-modules #:modules)
                                  arguments)))

(define chromium-binary-build-system
  (build-system
    (name 'chromium-binary)
    (description "The Chromium based binary build system")
    (lower lower)))

;;; chromium-binary.scm ends here

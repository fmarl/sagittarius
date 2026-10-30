;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages microvms)
  #:use-module (gnu packages librewolf)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module ((sagittarius vms librewolf)
                #:select ((librewolf-vm . librewolf-microvm)))
  #:use-module ((guix licenses) #:prefix license:))

(define-public librewolf-vm
  (package
    (name "librewolf-vm")
    (version (package-version librewolf))
    (source
     #f)
    (build-system trivial-build-system)
    (arguments
     (list
      #:modules '((guix build utils))
      #:builder
      #~(begin
          (use-modules (guix build utils))
          (mkdir-p (string-append #$output "/bin"))
          (symlink #$librewolf-microvm
                   (string-append #$output "/bin/librewolf-vm")))))
    (home-page "https://codeberg.org/fmarl/sagittarius")
    (synopsis "LibreWolf in a microvm")
    (description
     "This package provides @command{librewolf-vm}, which runs LibreWolf in a
microvm of its own that shares nothing with the host but Wayland and
forgets its downloads when it exits.")
    (license license:gpl3+)))

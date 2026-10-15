;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages glib)
  #:use-module (gnu packages apparmor)
  #:use-module (gnu packages glib)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public dbus-apparmor
  (hidden-package
   (package/inherit dbus
     (arguments
      (substitute-keyword-arguments (package-arguments dbus)
        ((#:configure-flags flags)
         #~(cons "-Dapparmor=enabled"
                 #$flags))))
     (inputs
      (modify-inputs (package-inputs dbus)
        (prepend libapparmor))))))

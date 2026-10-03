;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius services vpn)
  #:use-module (guix gexp)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu services shepherd)
  #:use-module (sagittarius packages vpn)
  #:export (mullvad-configuration
            mullvad-configuration?
            mullvad-configuration-package
            mullvad-service-type))

(define-configuration/no-serialization mullvad-configuration
  (package
   (file-like mullvad-vpn-desktop)
   "Package providing @command{mullvad-daemon}."))

(define (mullvad-shepherd-service config)
  (list (shepherd-service
         (provision '(mullvad))
         (requirement '(networking))
         (documentation "Mullvad VPN daemon")
         (start #~(make-forkexec-constructor
                   (list #$(file-append (mullvad-configuration-package config)
                                        "/bin/mullvad-daemon"))
                   #:log-file "/var/log/mullvad-daemon.log"))
         (stop #~(make-kill-destructor)))))

(define mullvad-service-type
  (service-type
   (name 'mullvad)
   (description "Mullvad VPN daemon")
   (extensions
    (list (service-extension shepherd-root-service-type
                             mullvad-shepherd-service)))
   (default-value (mullvad-configuration))))

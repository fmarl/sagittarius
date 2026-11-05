;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius vms pi)
  #:use-module (gnu)
  #:use-module (sagittarius packages pi)
  #:use-module (guix-microvm base)
  #:use-module (guix-microvm microvm)
  #:export (%pi-system
            pi-vm))

(use-package-modules base compression curl less linux rust-apps
                     version-control)

(define %pi-system
  (operating-system
    (inherit %base-vm)
    (host-name "pi")
    (packages (append (list pi
                            git
                            gnu-make
                            ripgrep
                            fd
                            curl
                            less
                            gzip
                            procps)
                      %base-packages))
    (services %microvm-base-services)))

(define pi-vm
  (microvm
    (operating-system %pi-system)
    (secrets '("ANTHROPIC_API_KEY"
               "OPENAI_API_KEY"
               "GEMINI_API_KEY"
               "MISTRAL_API_KEY"
               "OPENROUTER_API_KEY"))))

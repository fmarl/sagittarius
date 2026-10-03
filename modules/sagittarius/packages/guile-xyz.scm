;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages guile-xyz)
  #:use-module (gnu packages guile)
  #:use-module (guix build-system guile)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public guile-landlock
  (let ((commit "dce8cdeef8b0246659dee10291acd93d6573c199")
        (revision "0"))
    (package
      (name "guile-landlock")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/fmarl/guile-landlock")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0fwb16az5934rbm3j60v3fhrnam7bwwazjgpxv4n53gavcxfiij2"))))
      (build-system guile-build-system)
      (arguments
       (list #:source-directory "src"))
      (native-inputs (list guile-3.0))
      (home-page "https://github.com/fmarl/guile-landlock")
      (synopsis "Guile bindings for the Landlock sandboxing API")
      (description
       "Guile-Landlock restricts filesystem, network and IPC access of Guile
programs and the programs they execute using Linux's Landlock.")
      (license license:gpl3+))))

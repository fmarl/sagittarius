;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages wm)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages xdisorg)
  #:use-module (guix build-system asdf)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public nucleotide
  (let ((commit "6a985a18ddc66af779b7d30f9c73e723d2a033e6")
        (revision "2"))
    (package
      (name "nucleotide")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://codeberg.org/fmarl/nucleotide")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1n754zrwrqnj7hmjf45fxj6mrywsl7bs3if5c494z6f7j7xin2p3"))))
      (build-system asdf-build-system/sbcl)
      (arguments
       (list
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'set-libxkbcommon
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "src/keys.lisp"
                  (("\"libxkbcommon.so.0\"")
                   (format #f "~s"
                           (search-input-file inputs "lib/libxkbcommon.so.0"))))))
            (add-after 'create-asdf-configuration 'build-program
              (lambda* (#:key outputs #:allow-other-keys)
                (build-program (string-append #$output "/bin/nucleotide")
                               outputs
                               #:dependencies '("nucleotide" "slynk"
                                                "slynk/mrepl")
                               #:dependency-prefixes (list #$output
                                                           #$(this-package-input
                                                              "sbcl-slynk"))
                               #:compress? #t
                               #:entry-program '((nucleotide::main))))))))
      (native-inputs (list sbcl sbcl-fiveam))
      (inputs (list libxkbcommon sbcl-slynk))
      (synopsis "Hackable Wayland window manager")
      (description
       "Nucleotide is a hackable Wayland window manager for the river compositor,
written in Common Lisp.")
      (home-page "https://codeberg.org/fmarl/nucleotide")
      (license license:gpl3+))))

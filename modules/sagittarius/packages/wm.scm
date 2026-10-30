;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages wm)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xdisorg)
  #:use-module (guix build-system asdf)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public nucleotide
  (package
    (name "nucleotide")
    (version "0.5.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/fmarl/nucleotide")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0n7n9n2zsiavqg7k7fwx290c7sir24scrbir3mha79d6xaxalnvn"))))
    (build-system asdf-build-system/sbcl)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
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
                             #:entry-program '((nucleotide::main)))))
          (add-after 'build-program 'install-waybar-module
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((waybar (string-append #$output "/share/nucleotide/waybar")))
                (install-file "examples/waybar/which-key" waybar)
                (substitute* (string-append waybar "/which-key")
                  (("\\$\\{JQ:-jq\\}")
                   (string-append "${JQ:-"
                                  (search-input-file inputs "/bin/jq") "}")))))))))
    (native-inputs (list libxkbcommon sbcl sbcl-fiveam))
    (inputs (list jq sbcl-slynk zsh))
    (synopsis "Hackable Wayland window manager")
    (description
     "Nucleotide is a hackable Wayland window manager for the river compositor,
written in Common Lisp.")
    (home-page "https://codeberg.org/fmarl/nucleotide")
    (license license:gpl3+)))

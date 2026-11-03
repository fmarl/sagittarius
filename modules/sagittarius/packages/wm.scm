;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages wm)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xdisorg)
  #:use-module (guix build-system asdf)
  #:use-module (guix build-system cargo)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public nucleotide
  (package
    (name "nucleotide")
    (version "0.5.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://codeberg.org/fmarl/nucleotide")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "12wr35lv97vckzvcnw2j95ymc5iix6zpml9mb68nh281k76bvk5z"))))
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

(define-public nucleotide-monitor
  (let ((commit "3023cc197d9d850967b2245e9111e70f572fcc8a")
        (revision "0"))
    (package
      (name "nucleotide-monitor")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/fmarl/nucleotide-utils")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1c8hxwls25c4g3frypw36khx932z12b5r3rl7frldidlydzzij3k"))))
      (build-system cargo-build-system)
      (arguments
       (list
        #:install-source? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'chdir
              (lambda _
                (chdir "nucleotide-monitor"))))))
      (native-inputs (list pkg-config))
      (inputs (cons libxkbcommon
                    (cargo-inputs 'nucleotide-monitor
                                  #:module '(sagittarius packages rust-crates))))
      (synopsis "Layer-shell panels for the nucleotide window manager")
      (description
       "nucleotide-monitor shows the keys that can follow a prefix and an
overview of all windows with thumbnails for the nucleotide window manager.")
      (home-page "https://github.com/fmarl/nucleotide-utils")
      (license license:gpl3+))))

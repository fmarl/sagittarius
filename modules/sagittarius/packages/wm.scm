;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages wm)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (guix build-system asdf)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:))

(define %nucleotide-entry-program
  '((sb-ext:disable-debugger)
    (nucleotide:start-repl-server :port 4005)
    (nucleotide:start-wm)
    (sb-thread:join-thread (nucleotide::wm-thread nucleotide:*wm*))
    0))

(define-public nucleotide
  (let ((commit "cb7f9c52e8cd5bbe8fbc5797595f310867dca058")
        (revision "0"))
    (package
      (name "nucleotide")
      (version (git-version "0.2" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://codeberg.org/fmarl/nucleotide")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0nswx8arks72yfps5cbnpr3665l7p2z61hxh8qmlsk80dbi3fbp3"))))
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
                               #:entry-program '#$%nucleotide-entry-program))))))
      (inputs (list sbcl-slynk))
      (native-inputs (list sbcl))
      (synopsis "Hackable Wayland window manager")
      (description
       "Nucleotide is a hackable Wayland window manager written in Common Lisp.
It starts a Slynk REPL server on port 4005 through which it can be inspected
and modified while running.")
      (home-page "https://codeberg.org/fmarl/nucleotide")
      (license license:gpl3)
      (properties '((pinned . "No releases yet"))))))

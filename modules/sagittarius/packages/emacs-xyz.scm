;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages emacs-xyz)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages version-control))

(define-public emacs-pi
  (let ((commit "f389f5ccd23f64aeb9a5e5090a5ef0e6028f934f")
        (revision "0"))
    (package
      (name "emacs-pi")
      (version (git-version "0.1.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/fmarl/pi.el")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1g1gmywzrzfyfn3zzhipr2jc49c47y42mim98jmb0w1xxbk92iy1"))))
      (build-system emacs-build-system)
      (arguments
       (list
        #:test-command
        #~(list "emacs"
                "-Q"
                "--batch"
                "-L"
                "."
                "-l"
                "pi-test.el"
                "-f"
                "ert-run-tests-batch-and-exit")
        #:phases
        #~(modify-phases %standard-phases
            ;; The sockets of the tests would exceed the 108 bytes of a
            ;; socket path in the build directory.
            (add-before 'check 'shorten-temporary-directory
              (lambda _
                (setenv "TMPDIR" "/tmp")))
            (add-after 'install 'install-extension
              (lambda _
                (for-each (lambda (file)
                            (install-file file
                                          (string-append #$output
                                           "/share/pi/extensions/emacs-bridge")))
                          '("emacs-bridge/index.ts" "emacs-bridge/bridge.ts")))))))
      (native-inputs (list emacs-magit git-minimal/pinned))
      (home-page "https://github.com/fmarl/pi.el")
      (synopsis "Emacs interface to the Pi coding agent")
      (description
       "This package lets Emacs and the Pi coding agent work together.  Emacs
sends prompts, the region and files to the Pi of its project and shows what
Pi is doing in the mode line.  The Pi extension in
@file{share/pi/extensions/emacs-bridge} lets Pi read what is open in Emacs
and open files there.")
      (license license:gpl3+))))

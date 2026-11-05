;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages claude-code)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (sagittarius build-system binary))

(define-public claude-code
  (package
    (name "claude-code")
    (version "2.1.318")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://registry.npmjs.org/@anthropic-ai/"
                           "claude-code-linux-x64/-/claude-code-linux-x64-"
                           version ".tgz"))
       (sha256
        (base32 "0ksmklpyizh0mvf926b8cbqpmxcpxacvsm8rpdcjkggms0xmwk9a"))))
    (build-system binary-build-system)
    (arguments
     (list
      ;; Stripping would remove the .bun section with the JavaScript.
      #:strip-binaries? #f
      ;; An RPATH crashes the binary, and the loader finds libc without one.
      #:validate-runpath? #f
      #:patchelf-plan
      #~'(("claude"))
      #:install-plan
      #~'(("claude" "libexec/claude-code/"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'wrap
            (lambda _
              (let ((claude (string-append #$output
                                           "/libexec/claude-code/claude")))
                (wrap-program claude
                  `("DISABLE_AUTOUPDATER" =
                    ("1")))
                (mkdir-p (string-append #$output "/bin"))
                (symlink claude
                         (string-append #$output "/bin/claude"))))))))
    (inputs (list bash-minimal))
    (supported-systems '("x86_64-linux"))
    (home-page "https://github.com/anthropics/claude-code")
    (synopsis "Coding assistant for the terminal")
    (description "Claude Code is Anthropic's coding assistant.  It
reads and edits code and runs commands in the terminal.")
    (license ((@@ (guix licenses) license)
              "Nonfree" "file://LICENSE.md"
              "Anthropic Commercial Terms of Service"))))

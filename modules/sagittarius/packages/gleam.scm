(define-module (sagittarius packages gleam)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages rust-crates))

(define-public gleam
  (package
    (name "gleam")
    (version "1.14.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/gleam-lang/gleam")
              (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "03878m1sg8r6d4xdmrca3fbppv4lghvhkxyvqjfax5n37svkj298"))))
    (build-system cargo-build-system)
    (arguments
     (list #:install-source? #f
           #:cargo-install-paths ''("gleam-bin")))
    (native-inputs (list git-minimal))
    (inputs (cargo-inputs 'gleam))
    (home-page "https://gleam.run/")
    (synopsis "Type-safe functional language")
    (description
     "Gleam is a type-safe, impure functional programming language that compiles
to Erlang or Javascript.")
    (license license:asl2.0)))

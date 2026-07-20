(define-module (sagittarius packages python)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-build)
  #:use-module (guix build-system pyproject)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix gexp))

(define-public python-virtme-ng
  (package
    (name "python-virtme-ng")
    (version "1.41")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/arighi/virtme-ng")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0dpim9675p15ja993gj1xh7dq79dgh1w9lp0ym2yryfd7wsbc7zx"))))
    (build-system pyproject-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'sanity-check))))
    (propagated-inputs (list python-argcomplete python-requests))
    (native-inputs (list python-argcomplete python-argparse-manpage
                         python-requests python-setuptools))
    (home-page "https://github.com/arighi/virtme-ng")
    (synopsis
     "Build and run a kernel inside a virtualized snapshot of your live system")
    (description
     "Build and run a kernel inside a virtualized snapshot of your live system.")
    (license #f)))

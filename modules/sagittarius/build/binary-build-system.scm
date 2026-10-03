;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2019 Julien Lepiller <julien@lepiller.eu>
;;; Copyright © 2022 Attila Lendvai <attila@lendvai.name>
;;; Copyright © 2023 Giacomo Leidi <goodoldpaul@autistici.org>
;;; Copyright © 2024 Ashish SHUKLA <ashish.is@lostca.se>
;;; Copyright © 2025 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius build binary-build-system)
  #:use-module ((guix build gnu-build-system) #:prefix gnu:)
  #:use-module ((guix build copy-build-system) #:prefix copy:)
  #:use-module (guix build utils)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:export (%standard-phases
            binary-build))

;; Commentary:
;;
;; Builder-side code of the standard binary build procedure.
;; Copied and modified from the nonguix project.
;;
;; Code:

(define* (patchelf #:key inputs outputs patchelf-plan #:allow-other-keys)
  "Set the interpreter and the RPATH of files as per the PATCHELF-PLAN.

The PATCHELF-PLAN elements are lists of:

- The file to patch.
- The inputs (as strings) to include in the rpath, e.g. \"mesa\".  An input
  can also be a list of its name and the sub-directory to use instead of
  \"/lib\".

Both executables and dynamic libraries are accepted.
The inputs are optional when the file is an executable."
  (define* (rpath-entry name #:optional (sub-directory "/lib"))
    (match (or (assoc-ref outputs name) (assoc-ref inputs name))
      (#f (error (format #f "`~a' not found among the inputs nor the outputs."
                         name)))
      (directory (string-append directory sub-directory))))

  (define (patch-binary interpreter binary runpath)
    (unless (string-contains binary ".so")
      ;; Use `system*' and not `invoke' since this may raise an error if
      ;; library does not end with .so.
      (system* "patchelf" "--set-interpreter" interpreter binary))
    (unless (null? runpath)
      (invoke "patchelf" "--set-rpath"
              (string-join (map (match-lambda
                                  ((name sub-directory)
                                   (rpath-entry name sub-directory))
                                  (name
                                   (rpath-entry name)))
                                runpath)
                           ":")
              binary)))

  (invoke "patchelf" "--version")
  (when (pair? patchelf-plan)
    (let ((interpreter (car (find-files (assoc-ref inputs "libc")
                                        "ld-linux.*\\.so"))))
      (for-each (match-lambda
                  ((binary runpath)
                   (patch-binary interpreter binary runpath))
                  ((binary)
                   (patch-binary interpreter binary '())))
                patchelf-plan))))

(define (deb-file? file)
  (string-suffix? ".deb" file))

(define (unpack-deb deb-file)
  "Extract the data archive of DEB-FILE into the current directory, then
delete DEB-FILE."
  (define members ".deb-members")

  (mkdir members)
  (with-directory-excursion members
    (invoke "ar" "x" deb-file))
  (invoke "tar" "xvf" (car (find-files members "^data\\.tar")))
  (delete-file-recursively members)
  (delete-file deb-file))

(define (binary-unpack . _)
  "When the unpacked source consists of a single .deb file, extract its
contents into the \"binary\" directory and change to it."
  (match (remove (lambda (file)
                   (string=? (basename file) "environment-variables"))
                 (find-files (getcwd)))
    (((? deb-file? deb-file))
     (mkdir "binary")
     (chdir "binary")
     (unpack-deb deb-file))
    ((file)
     (format #t "Unknown file type: ~a~%" (basename file)))
    (_ #t)))

(define %standard-phases
  (modify-phases copy:%standard-phases
    (add-after 'unpack 'binary-unpack binary-unpack)
    (add-before 'install 'patchelf patchelf)))

(define* (binary-build #:key inputs (phases %standard-phases)
                       #:allow-other-keys #:rest args)
  "Build the given package, applying all of PHASES in order."
  (apply gnu:gnu-build #:inputs inputs #:phases phases args))

;;; binary-build-system.scm ends here

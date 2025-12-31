;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2025 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius packages clojure)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages bootstrap)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages readline)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module (guix build utils)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (sagittarius build-system binary))

(define-public clojure-lsp
  (package
    (name "clojure-lsp")
    (version "2025.11.28-12.47.43")
    (source
     (origin
       (method url-fetch/zipbomb)
       (uri (string-append "https://github.com/clojure-lsp/clojure-lsp"
                           "/releases/download/"
                           version
                           "/clojure-lsp-native-linux-"
                           (cond
                             ((target-aarch64?)
                              "aarch64")
                             ((target-x86-64?)
                              "amd64"))
                           ".zip"))
       (sha256
        (base32 (cond
                  ((target-aarch64?)
                   "0gy1va0bkrkhffbpl99m1x306ivyhj4jm586sxw3vha5qqb0k61i")
                  ((target-x86-64?)
                   "03fdmzf2jg0p4xfq1db26c4p1k12g318ra5fxh519314127kf8b0"))))))
    (build-system binary-build-system)
    (arguments
     (list
      #:install-plan `'(("./clojure-lsp" "/bin/"))
      #:patchelf-plan (if (target-aarch64?)
                          `'(("clojure-lsp" ("gcc" "libc" "zlib"))) #f)
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'chmod
            (lambda _
              (chmod "./clojure-lsp" #o755))))))
    (inputs (list (list gcc "lib") zlib))
    (supported-systems '("aarch64-linux" "x86_64-linux"))
    (home-page "https://github.com/clojure-lsp/clojure-lsp")
    (synopsis "Clojure & ClojureScript Language Server (LSP) implementation")
    (description
     "This package provides a Language Server for Clojure and ClojureScript
languages.  The goal of this project is to bring great editing tools for
Clojure/Clojurescript to all editors and programatically via its CLI and API.
It aims to work alongside you to help you navigate, identify and fix errors,
perform refactors and more.")
    (license license:expat)))

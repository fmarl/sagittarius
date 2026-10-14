;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(use-modules (gnu packages)
             (guix discovery)
             (guix packages)
             (guix profiles)
             (srfi srfi-1))

(define %package-modules
  (let ((root (find (lambda (directory)
                      (file-exists?
                       (string-append directory "/sagittarius/packages")))
                    %load-path)))
    (all-modules (list (cons root "sagittarius/packages")))))

(packages->manifest
 (fold-packages (lambda (package result)
                  (if (assq 'pinned (package-properties package))
                      result
                      (cons package result)))
                '()
                %package-modules))

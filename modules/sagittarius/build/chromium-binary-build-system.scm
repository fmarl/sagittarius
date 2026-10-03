;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2023 Giacomo Leidi <goodoldpaul@autistici.org>
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius build chromium-binary-build-system)
  #:use-module ((sagittarius build binary-build-system) #:prefix binary:)
  #:use-module (guix build utils)
  #:use-module (ice-9 ftw)
  #:export (%standard-phases))

;; Commentary:
;;
;; Builder-side code of the Chromium binary build procedure.
;; Copied and modified from the nonguix project.
;;
;; Code:

(define* (install-wrapper #:key inputs outputs #:allow-other-keys)
  "Wrap the executables in the \"bin\" directory of the \"out\" output so that
they find the libraries and programs of INPUTS."
  (let* ((output (assoc-ref outputs "out"))
         (bin (string-append output "/bin"))
         (fontconfig-minimal (assoc-ref inputs "fontconfig-minimal"))
         (nss (assoc-ref inputs "nss"))
         (wrap-inputs (map cdr inputs)))
    (for-each
     (lambda (exe)
       (format #t "Wrapping ~a~%" exe)
       (wrap-program exe
         `("FONTCONFIG_PATH" ":" prefix
           (,(string-append fontconfig-minimal "/etc/fonts") ,output))
         `("PATH" ":" prefix
           (,@(search-path-as-list '("bin" "sbin" "libexec") wrap-inputs)
            ,bin))
         `("LD_LIBRARY_PATH" ":" prefix
           (,@(search-path-as-list '("lib") wrap-inputs)
            ,(string-append nss "/lib/nss")
            ,output))
         ;; Let Electron (>= 28) choose between Wayland and X11.
         `("ELECTRON_OZONE_PLATFORM_HINT" = ("auto"))))
     (map (lambda (exe) (string-append bin "/" exe))
          (scandir bin (lambda (exe) (not (string-prefix? "." exe))))))))

(define %standard-phases
  (modify-phases binary:%standard-phases
    (add-after 'install 'install-wrapper install-wrapper)))

;;; chromium-binary-build-system.scm ends here

;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius build locked grants)
  #:use-module (srfi srfi-9)
  #:export (grant
            grant-rules
            grant-variables
            %no-grant))

(define-record-type <grant>
  (grant rules variables)
  grant?
  (rules     grant-rules)
  (variables grant-variables))                  ;alist

(define %no-grant (grant '() '()))

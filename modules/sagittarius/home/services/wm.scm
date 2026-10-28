;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius home services wm)
  #:use-module (guix gexp)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:export (home-nucleotide-service-type
            home-nucleotide-configuration
            home-nucleotide-configuration?
            home-nucleotide-configuration-settings
            home-nucleotide-configuration-entries
            nucleotide-autostart
            nucleotide-bind
            nucleotide-rule
            nucleotide-spawn))

(define (nucleotide-spawn program . arguments)
  `(spawn ,program ,@arguments))

(define (nucleotide-autostart program . arguments)
  `(autostart ,program ,@arguments))

(define (nucleotide-bind key action)
  "Bind KEY, like \"Mod+Shift+C\", to ACTION, a nucleotide command like
(close-window) as an S-expression."
  (when (string? action)
    (error "nucleotide action is a string, not an S-expression:" action))
  `(bind ,key ,action))

(define (plist-keys plist)
  (match plist
    (() '())
    ((key _ . rest) (cons key (plist-keys rest)))))

(define (check-plist plist keys what)
  (unless (and (even? (length plist))
               (every (lambda (key) (memq key keys)) (plist-keys plist)))
    (error (string-append "nucleotide rule " what " takes only these keys:")
           keys plist)))

(define (nucleotide-rule patterns . actions)
  "Apply ACTIONS, like #:float #t, to new windows whose properties match
PATTERNS, a list like (#:app-id \"mpv\") of strings or Lisp predicates."
  (check-plist patterns '(#:app-id #:title) "patterns")
  (check-plist actions '(#:float #:workspace #:output #:fullscreen) "actions")
  `(rule ,patterns ,@actions))

(define-configuration/no-serialization home-nucleotide-configuration
  (defaults?
   (boolean #t)
   "Whether to bind the default keys of nucleotide.")
  (settings
   (list '())
   "Lisp forms after the defaults in @file{init.lisp}: S-expressions, strings
of Lisp code, or file-like objects to load.")
  (entries
   (list '())
   "Programs to start, key bindings and window rules, as returned by
@code{nucleotide-autostart}, @code{nucleotide-bind} and
@code{nucleotide-rule}."))

;; Common Lisp strings know only these two escapes.
(define (lisp-string text)
  (string-append "\""
                 (string-concatenate
                  (map (lambda (char)
                         (if (memv char '(#\\ #\"))
                             (string #\\ char)
                             (string char)))
                       (string->list text)))
                 "\""))

(define (join-lisp sexps)
  (match sexps
    (() '())
    ((first . rest)
     (append (sexp->lisp first)
             (append-map (lambda (sexp)
                           (cons " " (sexp->lisp sexp)))
                         rest)))))

(define (sexp->lisp sexp)
  (match sexp
    (#t '("t"))
    ((or #f ()) '("nil"))
    ((? keyword?)
     (list (string-append ":" (symbol->string (keyword->symbol sexp)))))
    ((? symbol?) (list (symbol->string sexp)))
    ((? string?) (list (lisp-string sexp)))
    ((? char?) (list (object->string sexp)))
    ((? number?) (list (number->string sexp)))
    ((? file-like?) (list "\"" sexp "\""))
    ((? vector?) `("#(" ,@(join-lisp (vector->list sexp)) ")"))
    (('quote form) (cons "'" (sexp->lisp form)))
    ((? list?) `("(" ,@(join-lisp sexp) ")"))
    ((head . tail)
     `("(" ,@(sexp->lisp head) " . " ,@(sexp->lisp tail) ")"))))

(define (lines sexps)
  "SEXPS one per line, keywords on the line of their value."
  (match sexps
    (() '())
    (((? keyword? key) value . rest)
     (cons (list key value) (lines rest)))
    ((sexp . rest)
     (cons (list sexp) (lines rest)))))

(define (form->lisp form)
  (match form
    (((? symbol? head) first second third . rest)
     `("(" ,@(join-lisp (list head first))
       ,@(append-map (lambda (line)
                       (cons "\n  " (join-lisp line)))
                     (lines (cons* second third rest)))
       ")\n"))
    (_
     (append (sexp->lisp form) '("\n")))))

(define (setting->form setting)
  (if (file-like? setting)
      `(load ,setting)
      setting))

(define (nucleotide-forms config)
  (define entries
    (home-nucleotide-configuration-entries config))

  (define (tagged tag)
    (filter-map (match-lambda
                  ((entry-tag . payload)
                   (and (eq? entry-tag tag) payload)))
                entries))

  (for-each (match-lambda
              ((tag . _)
               (unless (memq tag '(autostart bind rule))
                 (error "unknown nucleotide entry:" tag))))
            entries)
  (append (if (home-nucleotide-configuration-defaults? config)
              '((use-defaults))
              '())
          (map setting->form (home-nucleotide-configuration-settings config))
          `((setf *autostart-programs* ',(tagged 'autostart)))
          (map (match-lambda
                 ((key action)
                  `(bind ,key ,action)))
               (tagged 'bind))
          (map (match-lambda
                 ((patterns . actions)
                  `(rule ,patterns ,@actions)))
               (tagged 'rule))))

(define (nucleotide-config-file config)
  (apply mixed-text-file "init.lisp"
         (append-map (lambda (form)
                       (if (string? form)
                           (list form "\n")
                           (form->lisp form)))
                     (nucleotide-forms config))))

(define home-nucleotide-service-type
  (service-type
    (name 'home-nucleotide)
    (extensions
     (list (service-extension home-xdg-configuration-files-service-type
                              (lambda (config)
                                `(("nucleotide/init.lisp"
                                   ,(nucleotide-config-file config)))))))
    (compose concatenate)
    (extend (lambda (config entries)
              (home-nucleotide-configuration
                (inherit config)
                (entries (append (home-nucleotide-configuration-entries config)
                                 entries)))))
    (default-value (home-nucleotide-configuration))
    (description "Generate the nucleotide configuration.")))

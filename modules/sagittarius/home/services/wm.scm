;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius home services wm)
  #:use-module (guix gexp)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:export (home-nucleotide-configuration
            home-nucleotide-configuration?
            home-nucleotide-configuration-settings
            home-nucleotide-configuration-entries
            home-nucleotide-service-type
            nucleotide-autostart
            nucleotide-bind
            nucleotide-spawn))

(define (nucleotide-spawn program . arguments)
  `(spawn ,program ,@arguments))

(define (nucleotide-autostart program . arguments)
  `(autostart ,program ,@arguments))

(define (nucleotide-bind key action)
  "Bind KEY to ACTION, Lisp code as a string or an action returned by
nucleotide-spawn."
  `(bind ,key ,action))

(define-configuration/no-serialization home-nucleotide-configuration
  (settings
   (list '())
   "Lisp code, as strings or file-like objects, at the top of
@file{init.lisp}.")
  (entries
   (list '())
   "Programs to start and key bindings, as returned by
@code{nucleotide-autostart} and @code{nucleotide-bind}."))

(define (lisp-string value)
  (match value
    ((? string?)
     (list (object->string value)))
    (_
     (list "\"" value "\""))))

(define (lisp-strings values)
  (append-map (lambda (value)
                (cons " " (lisp-string value)))
              values))

(define %modifiers
  '(("Shift" . ":shift")
    ("Ctrl" . ":ctrl")
    ("Alt" . ":alt")
    ("Mod" . ":super")
    ("Super" . ":super")))

(define %keysyms
  '(("Return" . ":return")
    ("Print" . ":print")
    ("Delete" . ":delete")
    ("XF86MonBrightnessUp" . "#x1008ff02")
    ("XF86MonBrightnessDown" . "#x1008ff03")
    ("XF86AudioLowerVolume" . "#x1008ff11")
    ("XF86AudioMute" . "#x1008ff12")
    ("XF86AudioRaiseVolume" . "#x1008ff13")
    ("XF86AudioMicMute" . "#x1008ffb2")))

(define (keysym key)
  (cond
   ((= (string-length key) 1)
    (string-append "#\\" (string-downcase key)))
   ((assoc-ref %keysyms key))
   (else
    (error "unknown nucleotide key" key))))

(define (modifier name)
  (or (assoc-ref %modifiers name)
      (error "unknown nucleotide modifier" name)))

(define (action->lisp action)
  (match action
    ((? string?)
     (list action))
    (('spawn . command)
     `("(spawn (list" ,@(lisp-strings command) "))"))))

(define (bind->lisp key action)
  (match (reverse (string-split key #\+))
    ((key . modifiers)
     `("\n  (("
       ,(string-join (map modifier (reverse modifiers)) " ")
       ") " ,(keysym key) " "
       ,@(action->lisp action)
       ")"))))

(define (autostart->lisp command)
  `("\n    (" ,@(cdr (lisp-strings command)) ")"))

(define (nucleotide-config-file config)
  (define entries
    (home-nucleotide-configuration-entries config))

  (define (tagged tag)
    (filter-map (match-lambda
                  ((entry-tag . payload)
                   (and (eq? entry-tag tag) payload)))
                entries))

  (for-each (match-lambda
              ((tag . _)
               (unless (memq tag '(autostart bind))
                 (error "unknown nucleotide entry:" tag))))
            entries)
  (apply mixed-text-file "init.lisp"
         (append (home-nucleotide-configuration-settings config)
                 '("\n(defparameter *autostart-programs*\n  '(")
                 (append-map autostart->lisp (tagged 'autostart))
                 '("))\n\n(define-keybinds (wm)")
                 (append-map (match-lambda
                               ((key action)
                                (bind->lisp key action)))
                             (tagged 'bind))
                 '(")\n"))))

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

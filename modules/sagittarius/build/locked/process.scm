;;; SPDX-License-Identifier: GPL-3.0-or-later
;;; Copyright © 2026 Florian Marrero Liestmann <f.m.liestmann@fx-ttr.de>

(define-module (sagittarius build locked process)
  #:use-module (ice-9 ftw)
  #:use-module (ice-9 match)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 threads)
  #:use-module (srfi srfi-1)
  #:export (inherit-across-exec!
            spawn-detached
            detach-from-terminal!))

(define (inherit-across-exec! port)
  ;; Revealed descriptors stay open across exec
  (port->fdes port))

(define (close-fdes-except keep)
  (for-each (lambda (fd)
              (unless (memv fd keep)
                (false-if-exception (close-fdes fd))))
            (filter-map string->number (scandir "/proc/self/fd"))))

(define (spawn-detached fd program . arguments)
  "Run PROGRAM detached, with only the standard descriptors and FD."
  (match (primitive-fork)
    (0
     (catch #t
       (lambda ()
         (match (primitive-fork)
           (0
            (close-fdes-except (list 0 1 2 fd))
            (apply execl program program arguments))
           (_ #t)))
       (const #f))
     (primitive-_exit 0))
    (pid
     (waitpid pid))))

(define (legacy-tiocsti?)
  (let ((file "/proc/sys/dev/tty/legacy_tiocsti"))
    (or (not (file-exists? file))
        (not (string=? "0" (string-trim-both
                            (call-with-input-file file get-string-all)))))))

(define (forward-signals-and-exit pid)
  (for-each (lambda (signal)
              (sigaction signal
                (lambda (signal)
                  (false-if-exception (kill pid signal)))))
            (list SIGINT SIGTERM SIGHUP SIGQUIT))
  ;; The handlers only run while this thread waits in Scheme
  (let ((status (join-thread (call-with-new-thread
                              (lambda ()
                                (cdr (waitpid pid)))))))
    (exit (or (status:exit-val status)
              (+ 128 (status:term-sig status))))))

(define (detach-from-terminal!)
  "Leave the terminal if the program could inject input with TIOCSTI."
  (when (and (legacy-tiocsti?)
             (any isatty? (list (current-input-port) (current-output-port)
                                (current-error-port))))
    (match (primitive-fork)
      (0 (setsid))
      (pid (forward-signals-and-exit pid)))))

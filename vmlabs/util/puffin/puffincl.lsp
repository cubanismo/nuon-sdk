; puffincl.lsp

; load the standard xlisp files
(load "xlinit.lsp")

; load the standard puffin files
(load "puffin.lsp")

(define (step &optional (p *mpe*))
  (p 'step-loop)
  (values))

; a simple single stepper
(define-method (c-mpe 'step-loop)
  (let loop ((state? #t))
    (when state?
      (self 'display-state)
      (format #t "~&")
      (let ((pc (self 'pc)))
        (multiple-value-bind (file line count)
                             (self 'find-line-number pc)
          (when file
            (format #t "~&")
            (display-source file line count)))))
    (format t "~&[s to step]")
    (let ((cmd (read)))
      (case cmd
        (s (self 'step)
           (self 'wait-for-halt)
           (loop #t))
        (o (self 'step-over)
           (self 'wait-for-halt)
           (loop #t))
        (g (self 'run)
           (self 'wait-for-halt)
           (loop #f))
        (r (loop #t))
        (q self)
        (e (let ((expr (read)))
             (fresh-line)
             (write (self 'runtime-eval expr))
             (loop #f)))
	(p (select-processor (read)))
        (? (step-help)
           (loop #f))
        (else ; treat anything else as an expression to evaluate
          (fresh-line)
          (write (self 'runtime-eval cmd))
          (loop #f))))))

(define (step-help)
  (format #t "\
e <expr>  evaluate expression
g         go
o         step over
p <n>     select processor
q         quit
r         redraw state
s         step
?         this help text

Anything else is taken as an expression to evaluate.
"))

(define-method (c-mpe 'display-state)
  (self 'display)
  (self 'request-watch-forms)
  (values))

; uiglue.lsp callbacks

(define (gg-running n))

(define (gg-halt-on-line n addr reason file line count offset))

(define (gg-halt n addr reason))

(define (gg-select-processor-on-line n addr file line count offset))

(define (gg-select-processor n addr))

(define (gg-set-breakpoint-on-line! n addr file line))

(define (gg-set-breakpoint! n addr))

(define (gg-clear-breakpoint-on-line! n addr file line))

(define (gg-clear-breakpoint! n addr))

(define (gg-refresh n file))

(define (gg-update-pixel x y color))

(define (gg-clear-graphics))

(define (gg-report-dma-exception))

(define (gg-browse n id))

(define (gg-browse-clear! n id))

(define (gg-browse-entry n parent-id id name value can-open? open? size start end))

(define (gg-browse-update n id value))

(define (gg-browse-remove n id))

(define (gg-watch-display n id name type fmt value))

(define (gg-watch-remove n id))

(define (gg-define-bitfield name fields))

; start the debugger
(start-debugger)
;;; A TIMER class

(define-class timer
  (instance-variables
    name
    call-count
    total-ticks
    reference-running-count
    reference-debug-count))

(define (make-timer &optional (tname (string-append
                                       "timer-"
                                       (symbol->string (gensym)))))
  (timer 'new tname))

(define-method (timer 'initialize tname)
  (set! name tname)
  (set! call-count 0)
  (self 'reset-total!)
  self)

(define-method (timer 'charge-call!)
  (set! call-count (+ call-count 1)))

(define-method (timer 'start!)
  (self 'charge-call!)
  (self 'resume!)
  self)

(define-method (timer 'resume!)
  (multiple-value-bind (stall-count packet-count running-count debug-count)
                       (&p 'info)
    (set! reference-running-count running-count)
    (set! reference-debug-count debug-count))
  self)

(define-method (timer 'stop!)
  (multiple-value-bind (stall packet-count running-count debug-count)
                       (&p 'info)
    (let* ((elapsed-running (- running-count reference-running-count))
           (elapsed-debug (- debug-count reference-debug-count))
           (elapsed-ticks (- elapsed-running elapsed-debug)))
      (set! total-ticks (+ total-ticks elapsed-ticks))
      (set! reference-running-count running-count)
      (set! reference-debug-count debug-count)))
  total-ticks)

(define-method (timer 'total-ticks)
  total-ticks)

(define-method (timer 'reset-total!)
  (set! total-ticks 0)
  (self 'resume!)
  self)

(define-method (timer 'display &optional (s *standard-output*))
  (format s "~A: total-ticks = ~A, called ~A times ~%" name total-ticks call-count)
  (values))

; C-BREAKPOINT

(define-class c-breakpoint
  (instance-variables
    i-processor
    i-address
    i-symbol
    i-breakpoint?
    i-condition
    i-condition-string
    i-count
    i-current-count
    i-before-method
    i-before-method-string
    i-after-method
    i-after-method-string
    i-read?
    i-write?))

(define-method (c-breakpoint 'initialize &key processor address symbol breakpoint? condition count before after read? write?)
  (set! i-processor processor)
  (set! i-address address)
  (set! i-symbol symbol)
  (set! i-breakpoint? breakpoint?)
  (if condition
    (multiple-value-bind (str fcn)
                         (i-processor 'compile-method condition)
      (set! i-condition-string str)
      (set! i-condition fcn))
    (set! i-condition #f))
  (set! i-count count)
  (set! i-current-count 0)
  (if before
    (multiple-value-bind (str fcn)
                         (i-processor 'compile-method before)
      (set! i-before-method-string str)
      (set! i-before-method fcn))
    (set! i-before-method #f))
  (if after
    (multiple-value-bind (str fcn)
                         (i-processor 'compile-method after)
      (set! i-after-method-string str)
      (set! i-after-method fcn))
    (set! i-after-method #f))
  (set! i-read? read?)
  (set! i-write? write?)
  self)

(define-method (c-breakpoint 'address)
  i-address)

(define-method (c-breakpoint 'symbol)
  i-symbol)

(define-method (c-breakpoint 'breakpoint?)
  i-breakpoint?)

(define-method (c-breakpoint 'condition)
  i-condition-string)

(define-method (c-breakpoint 'before)
  i-before-method-string)

(define-method (c-breakpoint 'after)
  i-after-method-string)

(define-method (c-breakpoint 'read?)
  i-read?)

(define-method (c-breakpoint 'write?)
  i-write?)

(define-method (c-breakpoint 'break?)
  (and i-breakpoint?                        ; if it is a breakpoint
       (or (self 'unconditional?)           ; that has no count or condition
           (self 'break-on-count?)          ; or has a count that has been reached
           (self 'break-on-condition?))))   ; or has a condition that is true

(define-method (c-breakpoint 'unconditional?)
  (not (or i-count i-condition)))

(define-method (c-breakpoint 'break-on-condition?)
  (if i-condition
    (i-processor 'call-method i-condition)
    #f))

(define-method (c-breakpoint 'count?)
  i-count)

(define-method (c-breakpoint 'break-on-count?)
  (if i-count
    (begin
      (set! i-current-count (1+ i-current-count))
      (if (>= i-current-count i-count)
        (begin
          (set! i-current-count 0)
          #t)
        #f))
     #f))

(define-method (c-breakpoint 'settings)
  (list :address i-address
        :symbol i-symbol
        :breakpoint? i-breakpoint?
        :condition (and i-condition i-condition-string)
        :count i-count
        :before (and i-before-method i-before-method-string)
        :after (and i-after-method i-after-method-string)
        :read? i-read?
        :write? i-write?))

(define-method (c-breakpoint 'change! &key (breakpoint? #f bpt?)
                                           (address #f addr?)
                                           (condition #f cnd?)
                                           (count #f cnt?)
                                           (before #f bfr?)
                                           (after #f aft?)
                                           (read? #f rd?)
                                           (write? #f wr?))
  (when bpt?
    (set! i-breakpoint? breakpoint?))
  (when addr?
    (set! i-address address))
  (when cnd?
    (if condition
      (multiple-value-bind (str fcn)
                           (i-processor 'compile-method condition)
        (set! i-condition-string str)
        (set! i-condition fcn))
      (set! i-condition #f)))
  (when cnt?
    (set! i-count count)
    (set! i-current-count 0))
  (when bfr?
    (if before
      (multiple-value-bind (str fcn)
                           (i-processor 'compile-method before)
        (set! i-before-method-string str)
        (set! i-before-method fcn))
      (set! i-before-method #f)))
  (when aft?
    (if after
      (multiple-value-bind (str fcn)
                           (i-processor 'compile-method after)
        (set! i-after-method-string str)
        (set! i-after-method fcn))
      (set! i-after-method #f)))
  (when rd?
    (set! i-read? read?))
  (when wr?
    (set! i-write? write?))
  self)

(define-method (c-breakpoint 'show-breakpoint &optional (s *standard-output*))
  (if i-symbol
    (format s "Breakpoint: ~A" i-symbol)
    (format s "Breakpoint")))

(define-method (c-breakpoint 'set-breakpoint! &key symbol condition count)
  (set! i-breakpoint? #t)
  (when symbol
    (set! i-symbol symbol))
  (if condition
    (multiple-value-bind (str fcn)
                         (i-processor 'compile-method condition)
      (set! i-condition-string str)
      (set! i-condition fcn))
    (set! i-condition #f))
  (set! i-count count)
  (set! i-current-count 0)
  self)

(define-method (c-breakpoint 'clear-breakpoint!)
  (set! i-breakpoint? #f)
  (set! i-condition #f)
  (not (or i-before-method i-after-method)))

(define-method (c-breakpoint 'before-method)
  i-before-method)

(define-method (c-breakpoint 'set-before-method! &key symbol method)
  (when symbol
    (set! i-symbol symbol))
  (multiple-value-bind (str fcn)
                       (i-processor 'compile-method method)
    (set! i-before-method-string str)
    (set! i-before-method fcn))
  self)

(define-method (c-breakpoint 'clear-before-method!)
  (set! i-before-method #f)
  (not (or i-breakpoint? i-after-method)))

(define-method (c-breakpoint 'after-method)
  i-after-method)

(define-method (c-breakpoint 'set-after-method! &key symbol method)
  (when symbol
    (set! i-symbol symbol))
  (multiple-value-bind (str fcn)
                       (i-processor 'compile-method method)
    (set! i-after-method-string str)
    (set! i-after-method fcn))
  self)

(define-method (c-breakpoint 'clear-after-method!)
  (set! i-after-method #f)
  (not (or i-breakpoint? i-before-method)))

; C-MPE

(define-method (c-mpe 'startup-breakpoint? addr)
  (and i-startup-breakpoint (= addr i-startup-breakpoint)))

(define-method (c-mpe 'set-startup-breakpoint! addr)
  (self 'target-set-breakpoint! addr)
  (set! i-startup-breakpoint addr)
  (set! i-pending-run? #f)
  self)

(define-method (c-mpe 'clear-startup-breakpoint!)
  (when i-startup-breakpoint
    (self 'target-clear-breakpoint! i-startup-breakpoint)
    (set! i-startup-breakpoint #f))
  self)

(define-method (c-mpe 'compile-method method)
  (if (string? method)
    (values method
            (let ((expr (read-from-string method)))
              (self 'compile-with-register-bindings expr)))
    (values (let ((s (make-string-output-stream)))
              (pp1 method s)
              (get-output-stream-string s))
            (self 'compile-with-register-bindings method))))

(define-method (c-mpe 'call-method method-fcn)
  (fluid-let ((*mpe* self)
              (&p self)
              (&d self))
    (method-fcn)))

(define-method (c-mpe 'find-breakpoint addr)
  (find addr i-breakpoints :key (lambda (x) (x 'address))))

(define-method (c-mpe 'internal-add-breakpoint &rest args &key address)
  (let ((b (apply c-breakpoint 'new args)))
    (self 'target-set-breakpoint! address)
    (%gg-set-breakpoint! self address)
    (push! b i-breakpoints)
    b))

(define-method (c-mpe 'internal-remove-breakpoint b)
  (let ((addr (b 'address)))
    (self 'target-clear-breakpoint! addr)
    (set! i-breakpoints (remove b i-breakpoints))
    self))

;+
; (c-mpe 'breakpoint? addr)
; Is there a breakpoint at the specified address?  If the address is a symbol,
; the value of the symbol is used as the address.
;-
(define-method (c-mpe 'breakpoint? addr)
  (when (string? addr)
    (set! addr (self 'find-symbol-address addr)))
  (if addr
    (let ((b (self 'find-breakpoint addr)))
      (and b (b 'breakpoint?)))
        #f))

;+
; (c-mpe 'set-breakpoint! addr)
; Set a breakpoint at the specified address.  If the address is a symbol,
; the value of the symbol is used as the address.
;-
(define-method (c-mpe 'set-breakpoint! addr &rest args)
  (let ((symbol #f))
    (when (string? addr)
      (set! symbol addr)
      (set! addr (self 'find-symbol-address symbol)))
        (if addr
      (let ((b (self 'find-breakpoint addr)))
        (if b
          (apply b 'set-breakpoint! :symbol symbol args)
          (apply self 'internal-add-breakpoint :processor self
                                               :address addr
                                               :symbol symbol
                                               :breakpoint? #t
                                               args))
        self)
          #f)))

;+
; (c-mpe 'clear-breakpoint! addr)
; Clear the breakpoint at the specified address.  If the address is a symbol,
; the value of the symbol is used as the address.
;-
(define-method (c-mpe 'clear-breakpoint! addr)
  (when (string? addr)
    (set! addr (self 'find-symbol-address addr)))
  (if addr
    (let ((b (self 'find-breakpoint addr)))
      (if b
        (self 'internal-clear-breakpoint! b)
        #f))
        #f))

(define-method (c-mpe 'internal-clear-breakpoint! b)
  (let ((addr (b 'address)))
    (when (b 'clear-breakpoint!)
      (self 'internal-remove-breakpoint b))
    (%gg-clear-breakpoint! self addr)
    self))

;+
; (c-mpe 'clear-all-breakpoints!)
; Clear all breakpoints associated with this mpe.
;-
(define-method (c-mpe 'clear-all-breakpoints!)
  (map (lambda (b) (self 'internal-clear-breakpoint! b)) i-breakpoints)
  self)

;+
; (c-mpe 'map-over-breakpoints fcn)
;-
; Map a function over each active breakpoint.
(define-method (c-mpe 'map-over-breakpoints fcn)
  (map (lambda (b) (fcn b)) i-breakpoints))

(define-method (c-mpe 'reset-all-breakpoints!)
  (self 'map-over-breakpoints (lambda (b) (self 'target-set-breakpoint! (b 'address))))
  (when i-data-breakpoint
    (self 'internal-set-data-breakpoint!))
  self)

(define-method (c-mpe 'find-breakpoint addr)
  (find addr i-breakpoints :key (lambda (x) (x 'address))))

;+
; (c-mpe 'show-breakpoints)
; Show all breakpoints associated with this mpe.
;-
(define-method (c-mpe 'show-breakpoints &optional (s *standard-output*))
  (map (lambda (b)
         (let ((address (b 'address))
               (symbol (b 'symbol)))
           (if symbol
             (format s "~&~A: ~X" symbol address)
             (format s "~&~X" address))))
       i-breakpoints)
  (values))

;+
; (setbp addrs &key condition count)
; Set a breakpoint at the specified address.
;-
(define-macro (setbp addr &rest args)
  `(*mpe* 'set-breakpoint! ,addr ,@args))

;+
; (clearbp addrs...)
; Clear breakpoints at the specified addresses.
;-
(define (clearbp &rest addrs)
  (if addrs
    (map (lambda (addr) (*mpe* 'clear-breakpoint! addr))
         addrs)
    (*mpe* 'clear-all-breakpoints!))
  (values))

;+
; (showbp)
; Show all breakpoints.
;-
(define (showbp)
  (*mpe* 'show-breakpoints))

(define-method (c-mpe 'add-methods)
  (let loop ((i 0))
    (multiple-value-bind (addr method)
                         (self 'get-before-method i)
      (when addr
        (self 'add-before-method! addr method)
        (loop (1+ i)))))
  (let loop ((i 0))
    (multiple-value-bind (addr method)
                         (self 'get-after-method i)
      (when addr
        (self 'add-after-method! addr method)
        (loop (1+ i)))))
  self)

;+
; (c-mpe 'add-before-method! addr method)
; Add a before method at the specified address.  If the address is a symbol,
; the value of the symbol is used as the address.
;-
(define-method (c-mpe 'add-before-method! addr method)
  (let ((symbol #f))
    (when (string? addr)
      (set! symbol addr)
      (set! addr (self 'find-symbol-address symbol)))
        (if addr
      (let ((b (self 'find-breakpoint addr)))
        (if b
          (b 'set-before-method! :symbol symbol :method method)
          (self 'internal-add-breakpoint :processor self
                                         :address addr
                                         :symbol symbol
                                         :before method)))
          #f)))

;+
; (c-mpe 'remove-before-method! addr)
; Remove a before method at the specified address.  If the address is a symbol,
; the value of the symbol is used as the address.
;-
(define-method (c-mpe 'remove-before-method! addr)
  (when (string? addr)
    (set! addr (self 'find-symbol-address addr)))
  (if addr
    (let ((b (self 'find-breakpoint addr)))
      (if b
        (begin
          (when (b 'clear-before-method!)
            (self 'internal-remove-breakpoint! addr))
          #t)
        #f))
        #f))

;+
; (c-mpe 'add-after-method! addr method)
; Add an after method at the specified address.  If the address is a symbol,
; the value of the symbol is used as the address.
;-
(define-method (c-mpe 'add-after-method! addr method)
  (let ((symbol #f))
    (when (string? addr)
      (set! symbol addr)
      (set! addr (self 'find-symbol-address symbol)))
        (if addr
      (let ((b (self 'find-breakpoint addr)))
        (if b
          (b 'set-after-method! :symbol symbol :method method)
          (self 'internal-add-breakpoint :processor self
                                         :address addr
                                         :symbol symbol
                                         :after method)))
          #f)))

;+
; (c-mpe 'remove-after-method! addr)
; Remove an after method at the specified address.  If the address is a symbol,
; the value of the symbol is used as the address.
;-
(define-method (c-mpe 'remove-after-method! addr)
  (when (string? addr)
    (set! addr (self 'find-symbol-address addr)))
  (if addr
    (let ((b (self 'find-breakpoint addr)))
      (if b
        (begin
          (when (b 'clear-after-method!)
            (self 'internal-remove-breakpoint! addr))
          #t)
        #f))
        #f))

(define-macro (before addr &rest body)
  `(begin
    (*mpe* 'add-before-method! ,addr '(begin ,@body))
    (values)))

(define (remove-before addr)
  (*mpe* 'remove-before-method! addr)
  (values))

(define-macro (after addr &rest body)
  `(begin
    (*mpe* 'add-after-method! ,addr '(begin ,@body))
    (values)))

(define (remove-after addr)
  (*mpe* 'remove-after-method! addr)
  (values))

(define-method (c-mpe 'break addr)
  (if (self 'startup-breakpoint? addr)
    (if i-pending-run?
      (begin
        (set! i-pending-run? #f)
        (self 'run))
      (self 'halt addr "Start"))
    (let ((b (self 'find-breakpoint addr)))
      (if b
        (let ((before-method (b 'before-method))
              (after-method (b 'after-method)))
          (when before-method
            (self 'call-method before-method))
          (if (or (not (self 'running?)) (b 'break?))
            (let ((s (make-string-output-stream)))
              (b 'show-breakpoint s)
              (self 'halt addr (get-output-stream-string s)))
            (if after-method
              (begin
                (set! i-pending-after-method after-method)
                (set! i-pending-run? #t)
                (self 'internal-step))
              (self 'internal-run))))
        (self 'halt addr "Coded breakpoint")))))

(define-method (c-mpe 'data-breakpoint)
  i-data-breakpoint)

(define-method (c-mpe 'internal-set-data-breakpoint!)
  (let ((enables (logior (if (i-data-breakpoint 'read?) mpectl-dardbrken-set mpectl-dardbrken-clr)
                         (if (i-data-breakpoint 'write?) mpectl-dawrbrken-set mpectl-dawrbrken-clr))))
    (self 'store-scalar! dabreak-address (i-data-breakpoint 'address))
    (self 'store-scalar! mpectl-address enables)))

(define-method (c-mpe 'set-data-breakpoint! addr &rest args)
  (let ((symbol #f))
    (when (string? addr)
      (set! symbol addr)
      (set! addr (self 'find-symbol-address symbol)))
    (if addr
      (begin
        (set! i-data-breakpoint (apply c-breakpoint 'new :processor self
                                                         :breakpoint? #t
                                                         :address addr
                                                         :symbol symbol
                                                         args))
        (self 'internal-set-data-breakpoint!))
      #f)))

(define-method (c-mpe 'clear-data-breakpoint!)
  (self 'store-scalar! mpectl-address (logior mpectl-dawrbrken-clr mpectl-dardbrken-clr))
  (set! i-data-breakpoint #f)
  self)

(define-method (c-mpe 'data-break addr)
  (format #t "~%dabreak: ~X" addr)
  (let ((b i-data-breakpoint))
    (format #t "~%dabreak: ~X, ~S" addr b)
	(b 'show)
    (if b
      (if (b 'break?)
        (let ((s (make-string-output-stream)))
          (b 'show-breakpoint s)
          (self 'halt addr (get-output-stream-string s)))
        (self 'internal-run))
      (self 'halt addr "Data address break"))))



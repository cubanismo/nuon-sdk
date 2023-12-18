(define-class c-watch-form
  (class-variables
    (v-next-id 1))
  (instance-variables
    i-processor
    i-id
    i-symbol
    i-base-name
    i-name
    i-address
    i-type
    i-increment
    i-local?
    i-use-cache?
    i-fetch
    i-store!
    i-fracbits
    i-format
    i-popup-format
    i-count
    i-indirect?))

(define-method (c-watch-form 'initialize processor symbol &rest args)
  (set! i-processor processor)
  (set! i-symbol symbol)
  (let ((addr-or-reg (or (and (number? symbol) symbol)
                         (processor 'find-symbol symbol)
                         (processor 'find-register-by-name symbol))))
    (if addr-or-reg
      (begin
        (if (number? addr-or-reg)
          (begin
            (set! i-base-name (if (number? symbol)
                                (format #f "0x~X" symbol)
                                symbol))
            (set! i-address addr-or-reg))
          (let ((reg-name (addr-or-reg 'name)))
            (set! i-base-name (if (string=? symbol reg-name)
                                symbol
                                (format #f "~A <~A>" symbol reg-name)))
            (set! i-address (addr-or-reg 'address))))
        (set! i-id v-next-id)
        (set! v-next-id (1+ v-next-id))
        (processor 'add-watch-form! self)
        (apply self 'setup args)
        self)
      #f)))

(define-method (c-watch-form 'setup &key (format 'hex)
                                         (popup-format #f)
				         (fracbits *default-fracbits*)
                                         (count 1)
                                         (local? #t)
                                         (use-cache? #f)
                                         (indirect? #f))
  ; change the parameters
  (self 'change :format format
                :popup-format popup-format
                :fracbits fracbits
                :count count
                :local? local?
                :use-cache? use-cache?
                :indirect? indirect?))

(define-method (c-watch-form 'change &key ((:format fmt) 'unspecified)
                                          (popup-format 'unspecified)
				          (fracbits 'unspecified)
                                          (count 'unspecified)
                                          (local? 'unspecified)
                                          (use-cache? 'unspecified)
                                          (indirect? 'unspecified))
  ; save the parameters
  (unless (eq? fmt 'unspecified)
    (set! i-format fmt))
  (unless (eq? popup-format 'unspecified)
    (set! i-popup-format popup-format))
  (unless (eq? fracbits 'unspecified)
    (set! i-fracbits (if fracbits
                       (if (number? fracbits)
                         fracbits
                         (i-processor 'runtime-eval fracbits))
                       *default-fracbits*)))
  (unless (eq? count 'unspecified)
    (set! i-count (if (number? count)
                    count
                    (i-processor 'runtime-eval count))))
  (unless (eq? local? 'unspecified)
    (set! i-local? local?))
  (unless (eq? use-cache? 'unspecified)
    (set! i-use-cache? use-cache?))
  (unless (eq? indirect? 'unspecified)
    (set! i-indirect? indirect?))

  ; determine the watch name
  (set! i-name (if i-indirect? (format #f "*~A" i-base-name) i-base-name))

  ; determine the address type
  (set! i-type (address-type i-address :key local?))

  ; setup fetch and store functions
  (if i-local?
    (if i-use-cache?
      (begin
        (set! fetch
          (lambda (a)
            (i-processor 'fetch-data-scalar a)))
        (set! store!
          (lambda (a v)
            (i-processor 'store-data-scalar! a v))))
      (begin
        (set! fetch
          (lambda (a)
            (i-processor 'fetch-scalar a)))
        (set! store!
          (lambda (a v)
            (i-processor 'store-scalar! a v)))))
    (let ((p (i-processor 'mmp)))
      (set! fetch
        (lambda (a)
          (p 'fetch-scalar a)))
      (set! store!
        (lambda (a v)
          (p 'store-scalar! a v)))))

  ; compute the address increment
  (if (and (not i-indirect?)                              ; not indirect?
           (= (logand i-address #xffff0000) #x20500000)   ; register?
           (/= (logand i-address #xffffffe0) #x20500800)) ; and not commxmit or commrecv?
    (set! i-increment 16) ; most registers are on vector boundries
    (set! i-increment 4)) ; and everything else is on scalar boundries

  ; request the initial value
  (self 'request-value)
  self)

(define (address-type addr &key (local? #t))
  (case (logand addr #xf0000000)
    (#x00000000 "reserved")
    (#x10000000 "reserved")
    (#x20000000 (let* ((mpe-n (quotient (- addr #x20000000) #x00800000))
                       (offset (remainder (- addr #x20000000) #x00800000))
                       (type
                         (case (logand offset #x00f00000)
                           (#x00000000 "dtrom")
                           (#x00100000 "dtram")
                           (#x00200000 "irom")
                           (#x00300000 "iram")
                           (#x00400000 (if (= (logand offset #x00080000) 0)
                                         "dtags"
                                         "itags"))
                           (#x00500000 "register")
                           (#x00600000 "reserved")
                           (#x00700000 "reserved")
                           (else       (format #f "bug ~X" offset)))))
                  (if local?
                    (if (= mpe-n 0)
                      type
                      (format #f "mpe~A-space" mpe-n))
                    (format #f "mpe~A-~A" mpe-n type))))
    (#x30000000 "reserved")
    (#x40000000 "sdram")
    (#x50000000 "sdram")
    (#x60000000 "sdram")
    (#x70000000 "sdram")
    (#x80000000 "system-ram")
    (#x90000000 "system-rom")
    (#xa0000000 "system-rom")
    (#xb0000000 "reserved")
    (#xc0000000 "reserved")
    (#xd0000000 "reserved")
    (#xe0000000 "reserved")
    (#xf0000000 (let ((top-bits (logand addr #xff000000)))
                  (cond ((= top-bits #xf0000000)
                         "rom")
                        ((= top-bits #xff000000)
                         "other-bus-io")
                        (else
                         "reserved"))))))

(define-method (c-watch-form 'id)
  i-id)

(define-method (c-watch-form 'symbol)
  i-symbol)

(define-method (c-watch-form 'name)
  i-name)

(define-method (c-watch-form 'settings)
  (list
    :format i-format
    :popup-format i-popup-format
    :fracbits i-fracbits
    :count i-count
    :local? i-local?
    :use-cache? i-use-cache?
    :indirect? i-indirect?))

(define-method (c-watch-form 'request-value)
  (let* ((addr (if i-indirect? (fetch i-address) i-address))
         (max-addr (+ addr (* i-count i-increment)))
         (n (i-processor 'unit-number)))
    (let loop ((addr addr) (name i-name))
      (when (< addr max-addr)
        (let* ((value (fetch addr))
               (value-string
                 (if value
                   (case i-format
                     (hex
                       (format #f "~X" value))
                     (binary
                       (format-binary value i-fracbits))
                     (decimal
                       (format #f "~A" value))
                     (real
                       (format-real value i-fracbits))
                     (ascii
                       (format-ascii value))
                     (else
                       (if (procedure? i-format)
		         (i-format value)
                         (format #f "unknown format ~S" i-format))))
                    "********")))
          (gg-watch-display n i-id name i-type i-format value-string)
          (loop (+ addr i-increment) #f))))
    self))

(define (format-watch-value fmt value)
  i-value)

(define-method (c-watch-form 'set-value! offset value)
  (let ((addr (+ i-address (* offset i-increment))))
    (if i-use-cache?
	  (i-processor 'store-data-scalar! addr value)
	  (i-processor 'store-scalar! addr value))
    (self 'request-value)))

(define (format-binary value fracbits)
  (let ((s (make-string-output-stream)))
    (write-bits value fracbits s)
    (read-char s) ; skip the leading space
    (get-output-stream-string s)))

(define *unprintable-character* #\.)

(define (format-ascii value)
  (let ((s (make-string-output-stream)))
    (let loop ((value value) (i 32))
      (when (> i 0)
        (let* ((byte (lsh value -24))
               (char (if (and (>= byte #x20) (<= byte #x7e))
                       (integer->char byte)
                       *unprintable-character*)))
          (write-char char s))
        (loop (ash value 8) (- i 8))))
    (get-output-stream-string s)))

(define (format-real value fracbits)
  (format #f "~S" (32bits->real value :fracbits fracbits)))

(define (watch-form-id form)
  (form 'id))

(define (watch-form-symbol form)
  (form 'symbol))

(define-method (c-mpe 'find-watch-form id)
  (let ((key-fcn (if (string? id)
                   watch-form-symbol
                   watch-form-id)))
    (find id i-watch-forms :key key-fcn)))

(define-method (c-mpe 'add-watch-form! form)
  (set! i-watch-forms (cons form i-watch-forms))
  self)

(define-method (c-mpe 'remove-watch-form! id)
  (let ((key-fcn (if (string? id)
                   watch-form-symbol
                   watch-form-id))
        (n (self 'unit-number))
        (value #f))
    (let loop ((forms i-watch-forms))
      (when forms
        (let ((form (car forms)))
          (when (eqv? id (key-fcn form))
            (gg-watch-remove n (form 'id))
            (set! value #t))
          (loop (cdr forms)))))
    (set! i-watch-forms (remove id i-watch-forms :key key-fcn))
    value))

(define-method (c-mpe 'watch id &rest args)
  (apply c-watch-form 'new self id args))

; add a watch expression
(define-macro (watch id &rest args)
  `(*mpe* 'watch ,id ,@args))

(define-method (c-mpe 'watch-change! id &rest args)
  (let ((form (self 'find-watch-form id)))
    (apply form 'change args)))

; change an existing watch expression
(define-macro (watch-change id &rest args)
  `(*mpe* 'watch-change ,id ,@args))

(define-method (c-mpe 'watch-settings id)
  (let ((form (self 'find-watch-form id)))
    (and form (form 'settings))))

(define-method (c-mpe 'unwatch id)
  (self 'remove-watch-form! id))

; remove a watch expression
(define-macro (unwatch id)
  `(*mpe* 'unwatch ,id))

(define-method (c-mpe 'set-watch-value! id offset value)
  (let ((form (self 'find-watch-form id)))
    (if form
      (form 'set-value! offset value)
      #f)))

(define-method (c-mpe 'request-watch-forms)
  (let loop ((forms (reverse i-watch-forms)))
    (when forms
      ((car forms) 'request-value)
      (loop (cdr forms))))
  self)

(define (define-bitfield name &rest fields)
  (gg-define-bitfield name fields)
  (values))


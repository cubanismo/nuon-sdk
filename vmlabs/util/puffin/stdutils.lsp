(format #t "~%stdutils.lsp loaded")

(define (hex x) (format #t "~%~X" x) (values))
(define (hexstring x) (format #f "~X" x))

(define (set-ticks)
  (multiple-value-bind (stall-count packet-count running-count debug-count)
                       (&p 'info)
  ((&p 'register 0) 'set-value! (round (/ running-count 54)))))


;;; string address in r1, length in r2, print to console

(define (display_string &optional (port *standard-output*))
  (display-string ((&p 'register 1) 'value)
                  ((&p 'register 2) 'value)
                  port))

(define (display-string addr count &optional (port *standard-output*))
  (let loop ((addr addr)
             (count count))
    (when (> count 0)
      (let ((output-count (display-scalar addr count port)))
        (loop (+ addr output-count)
              (- count output-count))))
    (values)))

(define (display-scalar addr count &optional (port *standard-output*))
  (let* ((scalar-addr (logand addr #xfffffffc))
         (next-scalar-addr (+ scalar-addr 4)))
    (let loop ((next-addr addr)
               (next-count count)
               (scalar (lsh (&p 'fetch-scalar scalar-addr)
                            (* (- addr scalar-addr) 8))))
      (if (and (> next-count 0)
               (< next-addr next-scalar-addr))
        (let ((byte (lsh (logand scalar #xff000000) -24)))
          (display (integer->char byte) port)
          (loop (+ next-addr 1)
                (- next-count 1)
                (lsh scalar 8)))
        (- count next-count)))))

;;;; various routines in support of fprintf()

(define (open-binary-update-file filename)
  (let ((p (open-update-file filename 'binary)))
    (if (port? p) ; if it doesn't already exist...
      p
      (let ((temp (open-output-file filename))) ; ...create it
        (close-port temp) ; close it
        (open-update-file filename 'binary))))) ; and reopen it for update

(define (write_bytes)
  (let ((filename-addr ((&p 'register 0) 'value))
        (addr ((&p 'register 1) 'value))
        (count ((&p 'register 2) 'value))
        (offset ((&p 'register 3) 'value)))
    (let ((filename (read-zero-terminated-string filename-addr)))
      (if (or (string=? filename "stdout")
              (string=? filename "stderr"))
        (display-string addr count)
        (write-bytes addr count filename offset)))))

(define (write-bytes addr count filename offset)
  (let ((port (open-binary-update-file filename)))
    (if (not (port? port))
      #f
      (begin
        (set-file-position! port offset 0)
        (let loop ((addr addr)
                   (count count))
          (when (> count 0)
            (let ((output-count (write-bytes-from-scalar addr count port)))
              (loop (+ addr output-count)
                    (- count output-count))))
          (begin
            (close-port port)
            #t))))))

(define (write-bytes-from-scalar addr count port)
  (let* ((scalar-addr (logand addr #xfffffffc))
         (next-scalar-addr (+ scalar-addr 4)))
    (let loop ((next-addr addr)
               (next-count count)
               (scalar (lsh (&p 'fetch-scalar scalar-addr)
                            (* (- addr scalar-addr) 8))))
      (if (and (> next-count 0)
               (< next-addr next-scalar-addr))
        (let ((byte (lsh (logand scalar #xff000000) -24)))
          (write-byte byte port)
          (loop (+ next-addr 1)
                (- next-count 1)
                (lsh scalar 8)))
      (- count next-count)))))

(define-class mpe-byte-source
  (instance-variables
    (mpe last-scalar-addr last-scalar addr)))

(define-method (mpe-byte-source 'initialize address 
                                &optional (processor *mpe*))
  (set! mpe processor)
  (set! addr address)
  (set! last-scalar-addr (logand address #xfffffffc))
  (set! last-scalar (mpe 'fetch-scalar last-scalar-addr))
  self)

(define-method (mpe-byte-source 'next)
  (let ((delta (- addr last-scalar-addr)))
    (if (> delta 3)
      (begin
        (inc! last-scalar-addr 4)
        (set! addr last-scalar-addr)
        (set! delta 0)
        (set! last-scalar (mpe 'fetch-scalar last-scalar-addr))))
    (inc! addr)
    (logand #xff (lsh last-scalar (- (* 8 delta) 24)))))

(define (make-byte-source addr &optional (mpe *mpe*))
  (mpe-byte-source 'new addr mpe))


(define (read-zero-terminated-string addr)
  (let ((s (make-string-output-stream))
        (bytestream (make-byte-source addr)))
    (let loop ((byte (bytestream 'next)))
      (if (zero? byte)
        (get-output-stream-string s)
        (begin
          (format s "~A" (integer->char byte))
          (loop (bytestream 'next)))))))

(define (read-string addr count)
  (let ((source (make-byte-source addr))
        (str (make-string count)))
    (dotimes (i count str)
      (string-set! str i (integer->char (source 'next))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; memory stuff

(define (show-mem x num)
  (if (> num 0)
      (begin
       (format #t "~%~X: ~X  ~X  ~X  ~X" x
	       (&p 'fetch-scalar x)
	       (&p 'fetch-scalar (+ x 4))
	       (&p 'fetch-scalar (+ x 8))
	       (&p 'fetch-scalar (+ x 12)))
       (show-mem (+ x 16) (- num 16)))))

(define (show-data-mem x num)
  (if (> num 0)
      (begin
       (format #t "~%~X: ~X  ~X  ~X  ~X" x
	       (&p 'fetch-data-scalar x)
	       (&p 'fetch-data-scalar (+ x 4))
	       (&p 'fetch-data-scalar (+ x 8))
	       (&p 'fetch-data-scalar (+ x 12)))
       (show-data-mem (+ x 16) (- num 16)))))

(define (show-instruction-mem x num)
  (if (> num 0)
      (begin
       (format #t "~%~X: ~X  ~X  ~X  ~X" x
	       (&p 'fetch-instruction-scalar x)
	       (&p 'fetch-instruction-scalar (+ x 4))
	       (&p 'fetch-instruction-scalar (+ x 8))
	       (&p 'fetch-instruction-scalar (+ x 12)))
       (show-instruction-mem (+ x 16) (- num 16)))))

(define (mpe-mem-read loc)
  (*mpe* 'fetch-scalar loc))

(define (mpe-mem-store! loc val)
  (*mpe* 'store-scalar! loc val))

(define (mmp-mem-read loc)
  (*mmp* 'fetch-scalar loc))

(define (mmp-mem-store! loc val)
  (*mmp* 'store-scalar! loc val))

(define (filedump addr numscalars filename &key comment)
  (let ((p (open-append-file filename)))
    (if (not (port? p))
      (error "unable to open append file"))
    (if comment (format p "~A~%" comment))
    (let loop ((loc addr) (count numscalars))
      (if (zero? count)
        (close-output-port p)
        (let ((val (*mpe* 'fetch-scalar loc)))
          (format p "~X:  ~X~%" addr val)
          (loop (+ loc 4) (- count 1)))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Used mostly with Emulator

(define (step-to! addr)
  (*mpe* 'run)
  (let ((pcexec (*mpe* 'find-register-by-name "pcexec")))
    (let loop ()
      (when (*mpe* 'running?)
        (unless (= addr (pcexec 'value))
          (*mpe* 'clock-mmp)
          (loop))))
    (*mpe* 'stop)
    (gui-update-display)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|

    (set-register! sym data [sym data]...)

where:
    sym is one of 'r0 .. 'r31 and data is a single number
or
    sym is one of 'v0 .. 'v7 and data is a sequence of up to 4 numbers
or
    sym is ANY settable register, e.g. 'xyctl, 'acshift, and so on,
    and data is a value to write into it
or
    sym is 'mpe and data is a number (usefully in the range 0 .. 3)
    which sets the mpe for subsequent register assignments
or
    sym is one of 'mpe0 .. 'mpe3 and there is no data; the effect
    here is the same as above.

The default (active) MPE is restored at the end of the operations.

For example:

  (set-register! 'r0 #xdeadbeef 'acshift 5 'mpe 3 'v2 10 20 30 'mpe2 'r7 -1)

sets the hex number DEADBEEF into register 0, and loads 5 into
acshift of the default (currently active) MPE, then switches to MPE3
and sets the first three registers of its vector register 2 (i.e.
scalar registers 8, 9, and 10) to 10, 20, and 30, respectively, then
switches to MPE2 and sets its register 7 to -1.

The related function

    (get-register sym)

can be used with ANY readable register symbol, e.g. 'pcexec, for the
current MPE only; it returns the value contained therein.

|#

(define (register-number sym)
  (string->number (substring (symbol->string sym) 1)))

(define (set-register! &rest args)
  (let ((default-processor-number (&p 'unit-number)))
    (let loop ((remaining args))
      (if (null? remaining)
        (select-processor default-processor-number)
        (let ((sym (first remaining)))
          (case sym
            ((r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16
              r17 r18 r19 r20 r21 r22 r23 r24 r25 r26 r27 r28 r29 r30 r31)
              (let ((reg (&p 'register (register-number sym))))
                (reg 'set-value! (second remaining))
                (loop (list-tail remaining 2))))
            ((v0 v1 v2 v3 v4 v5 v6 v7)
              (let ((regnum (* 4 (register-number sym)))
                    (rem1 (rest remaining)))
                (let ((num1 (first rem1)))
                  (if (not (number? num1))
                    (loop rem1)
                    (let ((reg (&p 'register regnum)))
                      (reg 'set-value! num1)
                      (let* ((rem2 (rest rem1))
                             (num2 (first rem2)))
                        (if (not (number? num2))
                          (loop rem2)
                          (let ((reg (&p 'register (+ regnum 1))))
                            (reg 'set-value! num2)
                            (let* ((rem3 (rest rem2))
                                   (num3 (first rem3)))
                              (if (not (number? num3))
                                (loop rem3)
                                (let ((reg (&p 'register (+ regnum 2))))
                                  (reg 'set-value! num3)
                                  (let* ((rem4 (rest rem3))
                                         (num4 (first rem4)))
                                    (if (not (number? num4))
                                      (loop rem4)
                                      (let ((reg (&p 'register (+ regnum 3))))
                                        (reg 'set-value! num4)
                                        (loop (rest rem4))))))))))))))))
            (mpe (let ((num (second remaining)))
                   (select-processor num)
                   (loop (list-tail remaining 2))))
            (mpe0 (select-processor 0) (loop (rest remaining)))       
            (mpe1 (select-processor 1) (loop (rest remaining)))       
            (mpe2 (select-processor 2) (loop (rest remaining)))       
            (mpe3 (select-processor 3) (loop (rest remaining)))
            (else (let* ((regname (string-downcase (symbol->string sym)))
                         (reg (&p 'find-register-by-name regname)))
                    (if (not reg)
                      (begin
                        (format #t "~%Unrecognized register: ~A~%" sym)
                        (values))
                      (let ((num (second remaining)))
                        (reg 'set-value! num)
                        (loop (list-tail remaining 2))))))))))))

(define (get-register sym)
  (let ((regname (string-downcase (symbol->string sym))))
    (let ((reg (&p 'find-register-by-name regname)))
      (if (not reg)
        (begin 
          (format #t "~%Unrecognized register: ~A~%" sym)
          #f)
        (reg 'value)))))


;;;;;;;;;;;;;;;; various memory writing utilities

#|
Two new functions are being added to allow convenient entering of
data into RAM. WRITE-SCALARS! allows you to enter one to several
scalars into RAM at a specified starting address: for example,

     (write-scalars! #x20100000 1 17 #xdeadbeef)

writes a 1 into location #x20100000 (the start of local RAM), a
17 into #x20100004, and #xdeadbeef into #x20100008.

The second function, WRITE-SCALAR-RAM!, is useful for setting a
specified region of memory either to a constant or to a series
of values defined by a procedure. For example, to zero the first
hundred scalar locations of local RAM, use:

     (write-scalar-ram! #x20100000 100 0)

To initialize the first hundred scalar locations of System RAM to 
the sequence 0, 1, 2, ..., 99, use:

     (write-scalar-ram! #x80000000 100 (lambda (i) i))

Given a table for storing the first 500 Fibonacci numbers (i.e., 
the sequence 0, 1, 1, 2, 3, 5, 8, ... where each term after the
first two is the sum of the two preceding terms):

     FibTable:  ds.s    500

We can initialize this table as follows:

     (define (fib n) 
       (if (= n 0)
         0
         (if (= n 1)
           1 
           (+ (fib (- n 1)) 
              (fib (- n 2))))))

     (write-scalar-ram! ~FibTable 500 fib)
|#

(define (write-scalars! addr &rest scalars)
  (let loop ((scalars scalars) (addr addr))
    (if (not (null? scalars))
      (let ((scalar (first scalars)))
        (&p 'store-scalar! addr scalar)
        (loop (rest scalars) (+ addr 4))))))

(define (write-scalar-ram! addr numscalars datum-or-proc)
  (if (procedure? datum-or-proc)
    (dotimes (i numscalars)
      (&p 'store-scalar! (+ addr (* 4 i)) (datum-or-proc i)))
    (dotimes (i numscalars)
      (&p 'store-scalar! (+ addr (* 4 i)) datum-or-proc))))

;;;;;;;;;;;;;;; a Date class

(load "date.lsp")

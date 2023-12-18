; C-BROWSER

(define-class c-browser
  (instance-variables
    i-processor
    i-open?
    i-entries
    i-next-id
    i-id))

(define-method (c-browser 'initialize processor id)
  (set! i-processor processor)
  (set! i-open? #f)
  (set! i-entries '())
  (set! i-next-id 1)
  (set! i-id id)
  self)

(define-method (c-browser 'remove!)
  (i-processor 'remove-browser! i-id)
  (let loop ((entries i-entries))
    (when entries
      ((car entries) 'remove!)
      (loop (cdr entries))))
  self)

(define-method (c-browser 'new-id)
  (let ((new-id (format #f "~A-~A" i-id i-next-id)))
    (set! i-next-id (1+ i-next-id))
    new-id))

(define-method (c-browser 'id)
  i-id)

(define-method (c-browser 'processor)
  i-processor)

(define-method (c-browser 'open)
  (if i-entries
    (self 'update!)
    (self 'add-entries!))
  (set! i-open? #t)
  self)

(define-method (c-browser 'open?)
  i-open?)

(define-method (c-browser 'size-and-range)
  #f)

(define-method (c-browser 'close)
  (set! i-open? #f)
  self)

(define-method (c-browser 'add-entries!)
  self)

(define-method (c-browser 'set-address! addr)
  self)

(define-method (c-browser 'remove-entry! id)
  (let loop ((old-entries i-entries) (new-entries '()))
    (if old-entries
      (let ((entry (car old-entries)))
        (if (string=? id (entry 'id))
          (begin
            (entry 'remove!)
            (loop (cdr old-entries) new-entries))
          (loop (cdr old-entries) (cons entry new-entries))))
      (set! i-entries (reverse new-entries))))
  self)
  
(define-method (c-browser 'remove-entry-by-name! name)
  (let loop ((old-entries i-entries) (new-entries '()))
    (if old-entries
      (let ((entry (car old-entries)))
        (if (string=? name (entry 'name))
          (begin
            (entry 'remove!)
            (loop (cdr old-entries) new-entries))
          (loop (cdr old-entries) (cons entry new-entries))))
      (set! i-entries (reverse new-entries))))
  self)

(define-method (c-browser 'find-browser id)
  (if (string=? id i-id)
    self
	(let ((id-prefix (string-append i-id "-"))
		  (id-prefix-length (1+ (string-length i-id))))
	  (if (string=? id id-prefix :end1 id-prefix-length :end2 id-prefix-length)
	    (let* ((index (string-search "-" id :start2 id-prefix-length))
               (browser-id (if index (substring id 0 index) id))
	  	       (entry (self 'find-entry browser-id)))
          (if entry
	        (let ((value-browser (entry 'value-browser)))
	          (if value-browser
	            (if index
		          (value-browser 'find-browser id)
			      value-browser)
		        #f))
	        #f))
		#f))))

(define-method (c-browser 'find-entry id)
  (find id i-entries :key (lambda (e) (e 'id))))

(define-method (c-browser 'find-entry-by-name name)
  (find name i-entries :key (lambda (e) (e 'name))))

(define-method (c-browser 'clear!)
  (gg-browse-clear! (i-processor 'unit-number) i-id)
  (set! i-entries '())
  self)

(define-method (c-browser 'update!)
  (when i-open?
    (let loop ((entries i-entries))
      (when entries
        (let ((entry (car entries)))
          (entry 'update!)
          (loop (cdr entries))))))
  self)

; C-GLOBAL-SYMBOL-BROWSER

(define-class c-global-symbol-browser
  (superclass c-browser))

(define-method (c-global-symbol-browser 'initialize processor id)
  (super 'initialize processor id)
  (i-processor 'add-browser id self)
  self)

(define-method (c-global-symbol-browser 'add-entry name address type)
  (c-browser-entry 'new :browser self
                        :name name
                        :address address
                        :type type))

(define-method (c-global-symbol-browser 'add-symbol-entry name)
  (multiple-value-bind (value overlay class type)
                       (i-processor 'find-symbol name)
    (if (eq? class 'address)
      (let ((entry (self 'add-entry name value type)))
        (set! i-entries (append i-entries (list entry)))
        entry)
      #f)))

; C-LOCAL-SYMBOL-BROWSER
      
(define-class c-local-symbol-browser
  (superclass c-browser)
  (instance-variables
    i-function-addr
    i-frame-base))

(define-method (c-local-symbol-browser 'initialize processor id)
  (super 'initialize processor id)
  (i-processor 'add-browser id self)
  (set! i-function-addr #f)
  (set! i-open? #t) ; always open
  self)

(define-method (c-local-symbol-browser 'update!)
  (let ((pc (i-processor 'pc))
        (fp (i-processor 'fp)))
    (self 'browse-stack-frame pc fp)))              

(define-method (c-local-symbol-browser 'set-frame! n)
  (multiple-value-bind (pc fp)
                       (i-processor 'frame n)
    (if pc
      (begin
        (self 'browse-stack-frame pc fp)
        pc)
      #f)))

(define-method (c-local-symbol-browser 'browse-stack-frame pc fp)
  (let ((fun-addr (i-processor 'set-current-block! pc)))
    (if fun-addr
	  (begin
	    (unless (and i-function-addr (= i-function-addr fun-addr))
          (self 'clear!))
	    (self 'update-entries! fp))
	  (self 'clear!))
    (set! i-function-addr fun-addr)
    (gg-browse (i-processor 'unit-number) i-id)))

(define-method (c-local-symbol-browser 'update-entries! fp)

  ; save the base of the stack frame
  (set! i-frame-base fp)                 

  ; check each of the local symbol names
  (let loop ((names (i-processor 'get-local-symbol-names))
             (old-entries i-entries)
			 (keep-entries '())
			 (add-entries '())
             (new-entries '()))

    ; check the next name
    (if names
      (let ((name (car names)))

        ; look up the symbol
        (multiple-value-bind (value overlay class type)
                             (i-processor 'find-symbol name)
          
		  ; make sure the symbol was found
          (if value

            ; get the address of the symbol
            (let ((addr (self 'symbol-address value overlay class)))
              
			  ; make sure the symbol had a valid address
              (if addr

                ; check for an existing entry
                (let ((entry (self 'find-entry-by-name name)))

				  ; is this the same entry?
                  (if (and entry (entry 'same-entry? addr type))

                    ; update and keep existing entry
                    (begin
					  (entry 'update!)
					  (loop (cdr names)
                            (remove entry old-entries)
                            (cons entry keep-entries)
						    add-entries
						    (cons entry new-entries)))

                    ; add new entry
                    (let ((entry (c-browser-entry 'new :browser self
                                                       :name name
                                                       :address addr
                                                       :type type)))
                      (loop (cdr names)
                            old-entries
							keep-entries
							(cons entry add-entries)
                            (cons entry new-entries)))))

                ; symbol had an invalid address
                (loop (cdr names)
					  old-entries
					  keep-entries
					  add-entries
					  new-entries)))

            ; can't find the symbol
            (loop (cdr names)
			      old-entries
				  keep-entries
				  add-entries
				  new-entries))))

      ; store the new entry list and remove old entries
      (begin
        (when old-entries
          (gg-dformat "~%removing ~S" old-entries))
        (when keep-entries
          (gg-dformat "~%keeping ~S" keep-entries))
		(when add-entries
          (gg-dformat "~%adding ~S" add-entries))
        (map (lambda (e) (e 'remove!)) old-entries)
        (set! i-entries (reverse new-entries)))))

  self)

(define-method (c-local-symbol-browser 'frame-base)
  i-frame-base)

(define-method (c-local-symbol-browser 'open-entry i)
  self)

(define-method (c-local-symbol-browser 'set-entry-value! i value)
  self)

(define-method (c-local-symbol-browser 'symbol-address value overlay class)
  (case class
    (address value)
    (register value)
    (frame (+ value (self 'frame-base)))
    (else #f)))

; C-AGGREGATE-BROWSER

(define-class c-aggregate-browser
  (superclass c-browser)
  (instance-variables
    i-address))

(define-method (c-aggregate-browser 'initialize processor id address)
  (super 'initialize processor id)
  (set! i-address address)
  self)

(define-method (c-aggregate-browser 'address)
  i-address)

(define-method (c-aggregate-browser 'set-address! address)
  (let ((delta (- address i-address)))
    (let loop ((entries i-entries))
      (when entries
	    (let ((entry (car entries)))
	      (entry 'set-address! (+ (entry 'address) delta))
		  (loop (cdr entries)))))
    (set! i-address address)
    self))

; C-STRUCT-UNION-BROWSER

(define-class c-struct-union-browser
  (superclass c-aggregate-browser)
  (instance-variables
    i-members))

(define-method (c-struct-union-browser 'initialize processor id address tag)
  (super 'initialize processor id address)
  (set! i-members (processor 'get-tag-members tag))
  self)

; C-STRUCT-BROWSER

(define-class c-struct-browser
  (superclass c-struct-union-browser))

(define-method (c-struct-browser 'add-entries!)
  (let loop ((members i-members)
             (new-entries '()))
    (if members
      (let ((member (car members)))
        (let ((name (first member))
              (offset (second member))
              (type (third member))
              (bits (fourth member)))
          (let ((entry (if bits
                         (let ((addr (+ i-address (* (quotient offset 32) 4)))
                               (bit-offset (remainder offset 32)))
                           (c-browser-entry 'new :browser self
                                                 :name name
                                                 :address addr
                                                 :type type
                                                 :bit-offset bit-offset
                                                 :bit-count bits))
                         (let ((addr (+ i-address offset)))
                           (c-browser-entry 'new :browser self
                                                 :name name
                                                 :address addr
                                                 :type type)))))
            (loop (cdr members)
                  (cons entry new-entries)))))
      (set! i-entries (reverse new-entries))))
  self)

; C-UNION-BROWSER

(define-class c-union-browser
  (superclass c-struct-union-browser))

(define-method (c-union-browser 'add-entries!)
  (let loop ((members i-members)
             (new-entries '()))
    (if members
      (let ((member (car members)))
        (let ((name (first member))
              (offset (second member))
              (type (third member))
              (bits (fourth member)))
          (let ((entry (if bits
                         (c-browser-entry 'new :browser self
                                               :name name
                                               :address i-address
                                               :type type
                                               :bit-offset 0
                                               :bit-count bits)
                         (c-browser-entry 'new :browser self
                                               :name name
                                               :address i-address
                                               :type type))))
            (loop (cdr members)
                  (cons entry new-entries)))))
      (set! i-entries (reverse new-entries))))
  self)

; C-ARRAY-BROWSER

(define-class c-array-browser
  (superclass c-aggregate-browser)
  (instance-variables
    i-size
    i-start i-end
    i-element-size
    i-element-type))

(define-method (c-array-browser 'initialize processor id address size e-size e-type)
  (super 'initialize processor id address)
  (set! i-size size)
  (set! i-start 0)
  (set! i-end (-1+ size))
  (set! i-element-size e-size)
  (set! i-element-type e-type)
  self)

(define-method (c-array-browser 'add-entries!)
  (let loop ((addr i-address)
             (new-entries '())
             (i i-start))
    (if (<= i i-end)
      (let ((entry (c-browser-entry 'new :browser self
                                         :name (format #f "[~S]" i)
                                         :address addr
                                         :type i-element-type)))
        (loop (+ addr i-element-size)
              (cons entry new-entries)
              (1+ i)))
      (set! i-entries (reverse new-entries))))
  self)

(define-method (c-array-browser 'size-and-range)
  (values i-size i-start i-end))

(define-method (c-array-browser 'set-range! start end)
  (set! i-start start)
  (set! i-end end)
  (when i-open?
    (self 'clear!)
    (self 'add-entries!))
  self)

; C-POINTER-BROWSER

(define-class c-pointer-browser
  (superclass c-array-browser)
  (instance-variables
    i-pointer-address))

(define-method (c-pointer-browser 'initialize processor id address e-size e-type)
  (let ((target-addr (processor 'fetch-data-scalar address)))
	(super 'initialize processor id target-addr 1 e-size e-type)
	(set! i-pointer-address address)
    self))

(define-method (c-pointer-browser 'update!)
  (let ((target-addr (i-processor 'fetch-data-scalar i-pointer-address)))
    (self 'set-address! target-addr)
	(super 'update!)))

; C-BROWSER-ENTRY

(define-class c-browser-entry
  (instance-variables
    i-browser
    i-name
    i-address
    i-bit-shift
    i-bit-count
    i-type
    i-id
    i-value-browser))

(define-method (c-browser-entry 'initialize &key browser name address type bit-offset bit-count)
  (set! i-browser browser)
  (set! i-name name)
  (set! i-address address)
  (set! i-type type)
  (set! i-bit-shift (and bit-offset (- (+ bit-offset bit-count) 32)))
  (set! i-bit-count bit-count)
  (set! i-id (browser 'new-id))
  (when (browse? type)
    (set! i-value-browser (self 'make-browser i-id)))
  (self 'add!)
  self)

(define-method (c-browser-entry 'print &optional (s *standard-output*))
  (format s "#<Browser-Entry-~S>" i-name)
  (values))

(define-method (c-browser-entry 'remove!)
  (when i-value-browser
    (i-value-browser 'remove!))
  self)

(define-method (c-browser-entry 'value-browser)
  i-value-browser)

(define-method (c-browser-entry 'address)
  i-address)

(define-method (c-browser-entry 'set-address! addr)
  (set! i-address addr)
  (when i-value-browser
    (i-value-browser 'set-address! addr))
  self)

(define-method (c-browser-entry 'same-entry? address type)
  (and (= i-address address) (i-type 'same? type)))

(define-method (c-browser-entry 'add!)
  (let ((n ((i-browser 'processor) 'unit-number))
        (parent-id (i-browser 'id))
        (value-str (self 'value-string))
        (can-open? (self 'can-open?))
        (open? (self 'open?)))
    (multiple-value-bind (size start end)
                         (self 'size-and-range)
      (gg-browse-entry n
                       parent-id
                       i-id
                       i-name
					   i-address
                       value-str
                       can-open?
                       open?
                       size
                       start
                       end))
    self))

(define-method (c-browser-entry 'update!)
  (let ((n ((i-browser 'processor) 'unit-number))
        (value-str (self 'value-string)))
    (gg-browse-update n i-id value-str)
	(when i-value-browser
	  (i-value-browser 'update!))
    self))

(define-method (c-browser-entry 'remove!)
  (let ((n ((i-browser 'processor) 'unit-number)))
    (gg-browse-remove n i-id)
    (when i-value-browser
      (i-value-browser 'remove!))
    self))

(define-method (c-browser-entry 'name)
  i-name)

(define-method (c-browser-entry 'id)
  i-id)

(define-method (c-browser-entry 'can-open?)
  (not (null? i-value-browser)))

(define-method (c-browser-entry 'open?)
  (and i-value-browser (i-value-browser 'open?)))
   
(define-method (c-browser-entry 'size-and-range)
  (and i-value-browser (i-value-browser 'size-and-range)))
   
(define-method (c-browser-entry 'make-browser id)
  (let ((p (i-browser 'processor)))
    (make-browser p id i-address i-type)))

(define-method (c-browser-entry 'value-string)
  (let ((specifier (i-type 'specifier)))
    (case (specifier-type specifier)
      (null           "<null>")
      (void           "<void>")
      (char           (self 'format-char #t))
      (short          (self 'format-short #t))
      (int            (self 'format-int #t))
      (long           (self 'format-long #t))
      (float          (self 'format-float))
      (double         (self 'format-double))
      (struct         (self 'format-address))
      (union          (self 'format-address))
      (enum           (self 'format-int #f))
      (unsigned-char  (self 'format-char #f))
      (unsigned-short (self 'format-short #f))
      (unsigned-int   (self 'format-int #f))
      (unsigned-long  (self 'format-long #f))
      (pointer        (self 'format-pointer (second specifier)))
      (array          (self 'format-array (second specifier) (third specifier)))
      (function       (self 'format-address))
      (else           #f))))

(define (register? addr)
  (= (logand addr #xffff0000) #x20500000))

(define-method (c-browser-entry 'format-char sign-extend?)
  (let ((processor (i-browser 'processor))
        (scalar-addr (logand i-address #xfffffffc)))
    (format #f "0x~X" (if i-bit-shift
                        (self 'extract-bits scalar-addr sign-extend?)
                        (let ((scalar (processor 'fetch-data-scalar scalar-addr)))
						  (if (register? i-address)
						    (logand scalar #xff)
						    (let ((char-offset (- 3 (logand i-address 3))))
                              (logand (lsh scalar (* char-offset -8)) #xff))))))))

(define-method (c-browser-entry 'format-short sign-extend?)
  (let ((processor (i-browser 'processor))
        (scalar-addr (logand i-address #xfffffffc)))
    (format #f "0x~X" (if i-bit-shift
                        (self 'extract-bits scalar-addr sign-extend?)
                        (let ((scalar (processor 'fetch-data-scalar scalar-addr)))
						  (if (register? i-address)
						    (logand scalar #xff)
							(let ((short-offset (- 1 (lsh (logand i-address 2) -1))))
                              (logand (lsh scalar (* short-offset -16)) #xffff))))))))

(define-method (c-browser-entry 'format-int sign-extend?)
  (self 'format-long sign-extend?))

(define-method (c-browser-entry 'format-long sign-extend?)
  (let ((processor (i-browser 'processor)))
    (format #f "0x~X" (if i-bit-shift
                        (self 'extract-bits i-address sign-extend?)
                        (processor 'fetch-data-scalar i-address)))))

(define-method (c-browser-entry 'extract-bits addr sign-extend?)
  (let* ((processor (i-browser 'processor))
         (scalar (processor 'fetch-data-scalar addr))
		 (value (if (> i-bit-shift 0)
			     (let ((scalar-2 (processor 'fetch-data-scalar (+ addr 4))))
				   (logior (lsh scalar i-bit-shift)
						   (lsh scalar-2 (- i-bit-shift 32))))
				 (lsh scalar i-bit-shift)))
         (mask (- (lsh 1 i-bit-count) 1)))
    (if sign-extend?
      (let ((sign-bit (lsh 1 (-1+ i-bit-count))))
        (if (= (logand value sign-bit) 0)
          (logand value mask)
          (logior value (lognot mask))))
      (logand value mask))))

(define-method (c-browser-entry 'format-float)
  (let* ((processor (i-browser 'processor))
         (float (processor 'fetch-data-scalar i-address)))
    (format #f "~A" (32bits->float float))))

(define-method (c-browser-entry 'format-double)
  (let* ((processor (i-browser 'processor))
         (double1 (processor 'fetch-data-scalar i-address))
         (double2 (processor 'fetch-data-scalar (+ i-address 4))))
    (format #f "~A" (64bits->double double2 double1))))

(define-method (c-browser-entry 'format-pointer type)
  (let* ((processor (i-browser 'processor))
         (ptr (processor 'fetch-data-scalar i-address)))
    (if (eq? (type 'specifier) 'char)
      (let ((string-value (processor 'fetch-string ptr)))
        (format #f "0x~X ~S" ptr string-value))
      (format #f "0x~X" ptr))))

(define-method (c-browser-entry 'format-array size type)
  (if (eq? (type 'specifier) 'char)
    (let* ((processor (i-browser 'processor))
           (string-value (processor 'fetch-string i-address)))
      (format #f "0x~X ~S" i-address string-value))
    (format #f "0x~X" i-address)))

(define-method (c-browser-entry 'format-address)
  (format #f "0x~X" i-address))

(define-method (c-browser-entry 'set-value! value)
  (and
    (let ((specifier (i-type 'specifier)))
      (case (specifier-type specifier)
        (char           (self 'set-char! value))
        (short          (self 'set-short! value))
        (int            (self 'set-int! value))
        (long           (self 'set-long! value))
        (float          (self 'set-float! value))
        (double         (self 'set-double! value))
        (enum           (self 'set-int! value))
        (unsigned-char  (self 'set-char! value))
        (unsigned-short (self 'set-short! value))
        (unsigned-int   (self 'set-int! value))
        (unsigned-long  (self 'set-long! value))
        (pointer        (self 'set-pointer! value))
        (array          #f)
        (else           #f)))
    (self 'update!)))

(define-method (c-browser-entry 'set-char! value)
  (if i-bit-shift
    (self 'set-bits! value)
    (let* ((processor (i-browser 'processor))
           (scalar-addr (logand i-address #xfffffffc))
           (scalar (processor 'fetch-data-scalar scalar-addr))
           (new-value (case (logand i-address 3)
                        (0 (logior (logand #xff000000 (lsh value 24))
                                   (logand #x00ffffff scalar)))
                        (1 (logior (logand #x00ff0000 (lsh value 16))
                                   (logand #xff00ffff scalar)))
                        (2 (logior (logand #x0000ff00 (lsh value 8))
                                   (logand #xffff00ff scalar)))
                        (3 (logior (logand #x000000ff value)
                                   (logand #xffffff00 scalar))))))
      (processor 'store-data-scalar! i-address new-value)
      self)))

(define-method (c-browser-entry 'set-short! value)
  (if i-bit-shift
    (self 'set-bits! value)
    (let* ((processor (i-browser 'processor))
           (scalar-addr (logand i-address #xfffffffc))
           (scalar (processor 'fetch-data-scalar scalar-addr))
           (new-value (case (logand i-address 2)
                        (0 (logior (logand #xffff0000 (lsh value 16))
                                   (logand #x0000ffff scalar)))
                        (2 (logior (logand #x0000ffff value)
                                   (logand #xffff0000 scalar))))))
      (processor 'store-data-scalar! i-address new-value)
      self)))

(define-method (c-browser-entry 'set-int! value)
  (self 'set-long! value))

(define-method (c-browser-entry 'set-long! value)
  (if i-bit-shift
    (self 'set-bits! value)
    (let ((processor (i-browser 'processor)))
      (processor 'store-data-scalar! i-address value)
      self)))

(define-method (c-browser-entry 'set-bits! value)
  (let* ((processor (i-browser 'processor))
         (scalar (processor 'fetch-data-scalar i-address))
         (mask (lsh (- (lsh 1 i-bit-count) 1) (- i-bit-shift)))
         (new-value (logior (logand value mask)
                            (logand scalar (lognot mask)))))
    (processor 'store-data-scalar! i-address new-value)))

(define-method (c-browser-entry 'set-float! value)
  (let ((processor (i-browser 'processor)))
    (processor 'store-data-scalar! i-address (float->32bits value))
    self))

(define-method (c-browser-entry 'set-double! value)
  (let ((processor (i-browser 'processor)))
    (multiple-value-bind (double1 double2)
                         (double->64bits value)
      (processor 'store-data-scalar! i-address double1)
      (processor 'store-data-scalar! (+ i-address 4) double2))
    self))

(define-method (c-browser-entry 'set-pointer! value)
  (self 'set-long! value))

; FUNCTIONS

(define (browse? type)
  (let ((specifier (type 'specifier)))
    (and (list? specifier)
         (case (first specifier)
           (struct  #t)
           (union   #t)
           (pointer #t)
           (array   #t)
           (else    #f)))))

(define (specifier-type specifier)
  (if (symbol? specifier)
    specifier
    (car specifier)))

(define (make-browser processor id addr type)
;(format #t "~%make-browser ~S ~S ~S ~S" processor id addr type)
  (let ((specifier (type 'specifier)))
    (case (specifier-type specifier)
      (struct  (c-struct-browser 'new processor id addr (second specifier)))
      (union   (c-union-browser 'new processor id addr (second specifier)))
      (array   (browse-array processor id addr specifier))
      (pointer (browse-pointer processor id addr specifier))
      (else    #f))))

(define (browse-array processor id addr type-specifier)
  (let* ((size (second type-specifier))
         (element-type (third type-specifier))
         (element-size (element-type 'size)))
     (c-array-browser 'new processor id addr size element-size element-type)))

(define (browse-pointer processor id addr type-specifier)
  (let* ((target-type (second type-specifier))
         (target-size (target-type 'size)))
     (c-pointer-browser 'new processor id addr target-size target-type)))

; Extra C-MPE Methods

(define-method (c-mpe 'add-browser id browser)
  (set! i-browsers (cons browser i-browsers))
  self)

(define-method (c-mpe 'find-browser id)
  (let* ((index (string-search "-" id))
         (browser-id (if index (substring id 0 index) id)))
    (let loop ((browsers i-browsers))
      (if browsers
        (let ((browser (car browsers)))
          (if (string=? browser-id (browser 'id))
	        (if index
		      (browser 'find-browser id)
			  browser)
            (loop (cdr browsers))))
        #f))))

(define-method (c-mpe 'find-browser-entry id)
  (let ((index (string-search "-" id :from-end? #t)))
    (if index
      (let* ((browser-id (substring id 0 index))
             (browser (self 'find-browser browser-id)))
        (if browser
          (browser 'find-entry id)
          #f))
      #f)))

(define-method (c-mpe 'remove-browser! id)
  (set! i-browsers (remove id i-browsers :key (lambda (b) (b 'id))))
  self)

(define-method (c-mpe 'refresh-browsers)
  (map (lambda (b) (b 'update!)) i-browsers)
  self)

(define-method (c-mpe 'frame n)
  (let loop ((n n)
             (pc (self 'pc))
             (fp (self 'fp)))
    (if (> n 0)
      (if (= fp 0)
        #f
        (let ((new-pc (self 'fetch-data-scalar (+ fp 4)))
              (new-fp (self 'fetch-data-scalar (+ fp 8))))
          (if (and new-pc new-fp (not (= fp new-fp)))
            (loop (-1+ n) new-pc new-fp)
            #f)))
      (values pc fp))))

(define-method (c-mpe 'frame-address n)
  (multiple-value-bind (pc fp)
                       (self 'frame n)
    (if pc
      (self 'label-and-offset-string pc)
      #f)))

(define-method (c-mpe 'label-and-offset-string addr)
  (multiple-value-bind (label offset)
                       (self 'find-label-and-offset addr)
    (if label
      (if (= offset 0)
        (format #f "~A" label)
        (format #f "~A+~X" label offset))
      (format #f "~X" addr))))

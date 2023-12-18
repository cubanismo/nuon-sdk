; the default mmp
(define *mmp* #f)
(define &m #f)

(define-class c-mmp
  (instance-variables
    i-handle
    i-processors
    i-last-loader
    i-last-load-path
    i-load-processor))

(define (setup-debugger &key port)
  (if port
    (let ((handle (connect-mmp port)))
      (if handle
        (begin
          (set! *mmp* (c-mmp 'new :handle handle))
          (*mmp* 'select-processor 0)
          *mmp*)
        #f))
    #f))

(define-method (c-mmp 'initialize &key handle)
  (set! i-handle handle)
  (set! i-last-loader #f)
  (let ((count (self 'mpe-count)))
    (set! i-processors (make-vector count))
    (dotimes (i count)
      (vector-set! i-processors i (c-mpe 'new :mmp self
                                              :unit-number i
                                              :handle (get-mpe i-handle i))))
    (mmp-start i-handle)
    self))

(define-method (c-mmp 'print &optional (s *standard-output*))
  (format s "#<MMP>")
  (values))

(define-method (c-mmp 'handle)
  i-handle)

(define-method (c-mmp 'mpe-count)
  (mmp-mpe-count i-handle))

(define-method (c-mmp 'mpe i)
  (vector-ref i-processors i))

(define-method (c-mmp 'find-mmp-from-handle handle)
  *mmp*)

(define-method (c-mmp 'find-mpe-from-handle handle)
  (let ((count (self 'mpe-count)))
    (let loop ((i 0))
      (if (< i count)
        (let ((p (self 'mpe i)))
          (if (foreign-pointer-eq? handle (p 'handle))
	    p
	    (loop (1+ i))))
        #f))))

(define-method (c-mmp 'chip?)
  #t)

(define-method (c-mmp 'fetch-scalar addr)
  (mmp-fetch-scalar i-handle addr))

(define-method (c-mmp 'store-scalar! addr value)
  (mmp-store-scalar! i-handle addr value))

(define-method (c-mmp 'read-scalars-from-file addr count file)
  (mmp-read-scalars-from-file i-handle addr count file))

(define-method (c-mmp 'write-scalars-to-file addr count file)
  (mmp-write-scalars-to-file i-handle addr count file))

(define-method (c-mmp 'run-all)
  (dotimes (i (self 'mpe-count))
    ((self 'mpe i) 'run))
  self)

(define-method (c-mmp 'stop-all)
  (dotimes (i (self 'mpe-count))
    ((self 'mpe i) 'stop))
  self)

(define-method (c-mmp 'reset)
  (mmp-stop)
  (reset-mmp i-handle)
  (mmp-start i-handle)
  (sleep 5000) ; sleep for five seconds
  (dotimes (i (self 'mpe-count))
    ((self 'mpe i) 'reset))
  self)

(define-method (c-mmp 'reset-all-breakpoints)
  (dotimes (i (self 'mpe-count))
	((self 'mpe i) 'reset-all-breakpoints!))
  self)

(define (restart &optional (processor *mmp*))
  (processor 'restart)
  (values))

(define-method (c-mmp 'restart)
  (if i-last-loader
    (begin
	  (mmp-stop)
	  (init-mmp i-handle)
	  (mmp-start i-handle)
	  (sleep 5000) ; sleep for five seconds
	  (dotimes (i (self 'mpe-count))
		((self 'mpe i) 'restart))
      (if (i-last-loader i-last-load-path :processor i-last-processor)
        (begin
		  (self 'reset-all-breakpoints)
          #t)
        #f))
    #f))

(define-method (c-mmp 'set-last-load! loader path &optional (processor *mpe*))
  (set! i-last-loader loader)
  (set! i-last-load-path path)
  (set! i-last-processor processor)
  self)

(define (load-debug-file file &key (processor *mpe*))
  (fluid-let ((*mpe* processor)
              (&p processor))
    (load file)))

(define (select-processor i &optional (processor *mmp*))
  (processor 'select-processor i))

(define-method (c-mmp 'select-processor i)
  (set! *mmp* self)
  (set! *default-mmp* self)         ; for backward compatibility
  (set! *default-debugger* self)    ; for backward compatibility
  (set! &m self)
  (dotimes (i (self 'mpe-count))
    (let ((sym (intern (format #f "&P~A" i)))
          (p (self 'mpe i)))
      (set-symbol-value! sym p)))
  ((self 'mpe i) 'select)
  self)

;+
; (write-image name &optional x-size y-size &key base mode)
; Write an image from display memory to a .pcx file.  The x-size and
; y-size parameters default to the display height and width.  The
; base defaults to the start of external ram and the mode defaults
; to *display-mode*.
;-
(define (write-image name &optional (x-size *display-width*)
				    (y-size *display-height*)
			  &key (base *external-ram-base*)
                               (mode *display-mode*))
  (p 'write-image-to-file base x-size y-size name mode))

(define-method (c-mmp 'write-image-to-file addr x-size y-size filename &optional (mode 4))
  (write-image-to-file filename i-handle addr x-size y-size mode))

;+
; (write-raw-image name &optional x-size y-size &key base mode)
; Write an image from display memory to a .pcx file.  The x-size and
; y-size parameters default to the display height and width.  The
; base defaults to the start of external ram and the mode defaults
; to *display-mode*.
; This function differs from write-image in that no color space
; conversion is performed; the Y component of colors is written into
; the green channel of the output image, Cr into the red, and Cb
; into the blue.
;-
(define (write-raw-image name &optional (x-size *display-width*)
				    (y-size *display-height*)
			  &key (base *external-ram-base*)
                               (mode *display-mode*))
  (p 'write-raw-image-to-file base x-size y-size name mode))

(define-method (c-mmp 'write-raw-image-to-file addr x-size y-size filename &optional (mode 4))
  (write-raw-image-to-file filename i-handle addr x-size y-size mode))


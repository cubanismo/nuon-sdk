; puffin.lsp - puffin initialization

(format #t "~%Puffin debugger support loading...")

; enable the compiler debug mode
; turns off tail recursion and function inlining

(set-debug-mode! #f) ; disable for now

;+
; *step-over-interrupts* is set to #t to cause the single step functions to
; automatically step over interrupts. To disable this feature, set this to #f.
;-
(define *step-over-interrupts* #t)

;+
; *detect-conflicts* is set to #t to cause instruction conflicts to be detected.
; To disable this feature, set this to #f.
;-
(define *detect-conflicts* #t)

;+
; *display-warnings* is set to #t to display llama warning messages during a
; load-source-file call. To disable this feature, set this to #f.
;-
(define *display-warnings* #t)

;+
; *display-info* is set to #t to display llama informational messages during a
; load-source-file call. To disable this feature, set this to #f.
;-
(define *display-info* #t)

;+
; *default-fracbits* determines the default number of fracbits in a watch.
; The default is 16.
;-
(define *default-fracbits* 16)

; display eight digits for hex numbers
(define *hexnum-format* "%08lx")

; get the port or ip address for remote debugging
(define *debug-port* (get-environment-variable "MD_PORT"))

; default to no debugging output
(define *gg-debugging* #f)

; if true use the bios loader on mpe3
(define *use-bios-loader?* #f)

; load the nuon support
(load "mmp.lsp")
(load "mpe.lsp")
(load "register.lsp")
(load "break.lsp")
(load "watch.lsp")
(load "browser.lsp")
(load "uiglue.lsp")
(load "compat.lsp")
(load "stdutils.lsp")

; load user customization file
(load "user.lsp")

; setup the debugger
(define (start-debugger)
  (let ((files (puffin-options)))
    (gg-message "Connecting to ~A" *debug-port*)
    (if (setup-debugger :port *debug-port*)
      (begin
	    (when files
		  (gg-message "Loading files: ~S" files)
          (puffin-loader files))
        #t)
      (begin
        (if *debug-port*
          (gg-message "Can't connect to ~A" *debug-port*)
          (gg-message "MD_PORT is not set to a development system IP address"))
        #f))))

; process puffin command line options
(define (puffin-options)
  (let loop ((n 1) (files '()))
    (let ((arg (getarg n)))
      (if arg
        (if (char=? (string-ref arg 0) #\-)
          (cond ((string=? arg "-ip")
                 (set! *debug-port* (getarg (1+ n)))
                 (loop (+ n 2) files))
                ((string=? arg "-emulator")
                 (set! *debug-port* #f)
                 (loop (1+ n) files))
				((string=? arg "-n")
				 (set! *use-bios-loader?* #t)
				 (loop (1+ n) files))
                (else
                  (error "unknown option: ~A" arg)))
          (loop (1+ n) (cons arg files)))
        (reverse files)))))

; load the files mentioned on the command line
(define (puffin-loader files)
  (let loop ((files files))
    (when files
      (let ((file (car files)))
        (unless (char=? (string-ref file 0) #\-)
          (format #t "~&; Loading '~A'" file)
          (multiple-value-bind (root ext)
                               (get-root-file-name file)
            (when (not (if ext
                         (cond ((or (string-ci=? ext "d")
                                    (string-ci=? ext "lsp"))
                                (load file))
                               ((or (string-ci=? ext "a")
                                    (string-ci=? ext "s"))
                                (load-source-file file))
                               ((string-ci=? ext "mpo")
                                (load-object-file file))
                               ((string-ci=? ext "cof")
                                (load-object-file file))
                               (else
                                (load-object-file file)))
                          (load-object-file file)))
              (display " -- failed"))))
        (loop (cdr files))))))

;+
; UTILITY FUNCTIONS
;-

;+
; (real->32bits value &key fracbits)
; Convert a real value to a 32 bit fixed point value with the specified
; number of fracbits.
;-
(define (real->32bits val &key (fracbits 16))
  (let* ((int (floor val))
         (frac (- val int)))
    (+ (ash int fracbits) (floor (* frac (expt 2 fracbits))))))

;+
; (32bits->real value &key fracbits)
; Convert a 32 bit fixed point value with the specified number of fracbits
; to a real.
;-    
(define (32bits->real val &key (fracbits 16))
  (/ val (expt 2 fracbits)))

;+
; (64bits->real value-high value-low &key fracbits)
; Convert a 64 bit fixed point value with the specified number of fracbits
; to a real.
;-
(define (64bits->real val-high val-low &key (fracbits 32))
  (real-64 val-high val-low fracbits))

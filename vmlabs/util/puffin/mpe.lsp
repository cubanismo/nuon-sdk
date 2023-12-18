; the default mpe
(define *mpe* #f)
(define &p #f)

; mpe memory map
(define *internal-memory-base*  #x20000000)
(define *local-rom-base*        #x20000000)
(define *local-ram-base*        #x20100000)
(define *instruction-rom-base*  #x20200000)
(define *instruction-ram-base*  #x20300000)
(define *local-reg-base*        #x20500000)

; external memory map
(define *external-ram-base*     #x40000000)
(define *system-ram-base*       #x80000000)

; register addresses
(define mpectl-address       #x20500000) ; mpectl
(define fp-address           #x205004e0) ; r30
(define pc-address           #x20500070) ; pcexec
(define dabreak-address      #x205002f0) ; dabreak

; mpectl bits
(define mpectl-dawrbrken-set #x00000080)
(define mpectl-dawrbrken-clr #x00000040)
(define mpectl-dardbrken-set #x00000020)
(define mpectl-dardbrken-clr #x00000010)

; halt hook reason bits
(define hh-Halt              #x00000001)
(define hh-Step              #x00000002)
(define hh-Break             #x00000004)
(define hh-DABreak           #x00000008)
(define hh-MemWrPortConflict #x00000010)
(define hh-MulWrPortConflict #x00000020)
(define hh-BilinearAddress   #x00000040)
(define hh-DataAddressError  #x00000080)
(define hh-InstAddressError  #x00000100)
(define hh-MainDMAError      #x00000200)
(define hh-OtherDMAError     #x00000400)
(define hh-CoprocDMAError    #x00000800)
(define hh-CoprocessorError  #x00001000)
(define hh-RegWrConflict     #x20000000)
(define hh-RdPortConflict    #x40000000)
(define hh-InternalError     #x80000000)

(define-class c-mpe
  (instance-variables
    i-mmp
    i-unit-number
    i-handle
    i-source-path
    i-watch-forms
    i-breakpoints
    i-data-breakpoint
    i-startup-breakpoint
    i-pending-after-method
    i-pending-run?
    i-browsers
    i-local-symbol-browser
    i-find-disassembly-lines?
    i-disassembly-line-numbers
    i-disassembly-reverse-line-numbers
    i-file-references
    i-file-reference-states
    i-register-table
    i-register-address-table
    i-register-environment
    i-last-stepper
    i-started?
    i-running?))

(define-method (c-mpe 'initialize &key mmp unit-number handle)
  (set! i-mmp mmp)
  (set! i-unit-number unit-number)
  (set! i-handle handle)
  (set! i-source-path '())
  (set! i-watch-forms '())
  (set! i-breakpoints '())
  (set! i-startup-breakpoint #f)
  (set! i-data-breakpoint #f)
  (set! i-file-references '())
  (set! i-file-reference-states '())
  (set! i-browsers '())
  ;(set! i-register-environment (the-environment))
  (set! i-local-symbol-browser (c-local-symbol-browser 'new self "root"))
  (set! i-disassembly-line-numbers (make-table))
  (set! i-disassembly-reverse-line-numbers (make-table))
  (set! i-register-table (make-table))
  (set! i-register-address-table (make-table))
  (set! i-register-environment (self 'make-register-environment))
  (self 'reset)
  self)

(define-method (c-mpe 'print &optional (s *standard-output*))
  (format s "#<MPE-~A>" i-unit-number)
  (values))

(define-method (c-mpe 'reset)
  (set! i-startup-breakpoint #f)
  (set! i-pending-after-method #f)
  (set! i-pending-run? #f)
  (set! i-find-disassembly-lines? #f)
  (empty-table! i-disassembly-line-numbers)
  (empty-table! i-disassembly-reverse-line-numbers)
  (set! i-last-stepper #f)
  (set! i-started? #f)
  (self 'set-run-state! (self 'internal-running?))
  (when i-running?
    (gg-running i-unit-number))
  self)

(define-method (c-mpe 'restart)
  (set! i-source-path '())
  (set! i-watch-forms '())
  (set! i-breakpoints '())
  (set! i-startup-breakpoint #f)
  (set! i-data-breakpoint #f)
  (set! i-file-references '())
  (set! i-file-reference-states '())
  (set! i-browsers '())
  (self 'reset))

(define-method (c-mpe 'mmp)
  i-mmp)

(define-method (c-mpe 'unit-number)
  i-unit-number)

(define-method (c-mpe 'handle)
  i-handle)

(define-method (c-mpe 'select)
  (set! *mpe* self)
  (set! *default-mpe* self)             ; for backward compatibility
  (set! *default-mpe-debugger* self)    ; for backward compatibility
  (set! &d self)                        ; for backward compatibility
  (set! &p self)
  (unless i-running?
    (self 'refresh-state!))
  (%gg-select-processor self)
  self)

(define-method (c-mpe 'compile-with-register-bindings expr)
  (compile expr i-register-environment))

(define-method (c-mpe 'pc)
  (self 'fetch-scalar pc-address))

(define-method (c-mpe 'fp)
  (self 'fetch-scalar fp-address))

(define-method (c-mpe 'fetch-scalar addr)
  (mpe-fetch-scalar i-handle addr))

(define-method (c-mpe 'fetch-data-scalar addr)
  (mpe-fetch-data-scalar i-handle addr))

(define-method (c-mpe 'fetch-instruction-scalar addr)
  (mpe-fetch-instruction-scalar i-handle addr))

(define-method (c-mpe 'store-scalar! addr value)
  (mpe-store-scalar! i-handle addr value))

(define-method (c-mpe 'store-data-scalar! addr value)
  (mpe-store-data-scalar! i-handle addr value))

(define-method (c-mpe 'store-instruction-scalar! addr value)
  (mpe-store-instruction-scalar! i-handle addr value))

(define-method (c-mpe 'fetch-string addr &rest args)
  (apply mpe-fetch-string i-handle addr args))

(define-method (c-mpe 'translate-data-address addr)
  (mpe-translate-data-address i-handle addr))

(define-method (c-mpe 'translate-instruction-address addr)
  (mpe-translate-instruction-address i-handle addr))

(define-method (c-mpe 'translate-overlay-address overlay addr)
  (mpe-translate-overlay-address i-handle overlay addr))

(define-method (c-mpe 'translate-loaded-overlay-address addr)
  (mpe-translate-loaded-overlay-address i-handle addr))

(define-method (c-mpe 'read-scalars-from-file addr count file)
  (mpe-read-scalars-from-file i-handle addr count file))

(define (read-scalars-from-file addr count file-name)
  (let ((port (open-input-file filename 'binary)))
    (if port
      (begin
        (&p 'read-scalars-from-file addr count port)
        (close-port port)
        #t)
      #f)))

(define-method (c-mpe 'write-scalars-to-file addr count file)
  (mpe-write-scalars-to-file i-handle addr count file))

(define (write-scalars-to-file addr count file-name)
  (let ((port (open-output-file filename 'binary)))
    (if port
      (begin
        (&p 'write-scalars-to-file addr count port)
        (close-port port)
        #t)
      #f)))

(define-method (c-mpe 'start-address)
  (mpe-get-start-address i-handle))

(define-method (c-mpe 'set-start-address! addr)
  (mpe-set-start-address! i-handle addr))

(define-method (c-mpe 'running?)
  i-running?)

(define-method (c-mpe 'set-run-state! state)
  (set! i-running? state)
  self)

(define (run &optional (processor *mpe))
  (processor 'run)
  (values))

(define-method (c-mpe 'run)
  (let* ((pc (self 'pc))
         (addr (or (self 'translate-loaded-overlay-address pc) pc))
         (b (self 'find-breakpoint addr)))
    (if b
      (let ((before-method (b 'before-method))
            (after-method (b 'after-method)))
        (when before-method
          (self 'call-method before-method))
        (if after-method
          (begin
            (set! i-pending-after-method after-method)
            (set! i-pending-run? #t)
            (self 'internal-step))
          (self 'internal-run)))
      (self 'internal-run))
    (gg-running i-unit-number)
    self))

(define (stop &optional (processor *mpe))
  (processor 'stop)
  (values))

(define-method (c-mpe 'stop)
  (self 'internal-stop)
  (self 'refresh-state!)
  (self 'halt (self 'pc) "Stop")
  self)

(define (step &optional (processor *mpe))
  (processor 'step)
  (values))

(define-method (c-mpe 'step)
  (self 'single-step 'internal-step)
  (gg-running i-unit-number)
  self)

(define (step-over &optional (processor *mpe))
  (processor 'step-over)
  (values))

(define-method (c-mpe 'step-over)
  (self 'single-step 'internal-step-over)
  (gg-running i-unit-number)
  self)

(define-method (c-mpe 'single-step stepper)
  (let* ((pc (self 'pc))
         (addr (or (self 'translate-loaded-overlay-address pc) pc))
         (b (self 'find-breakpoint addr)))
    (when b
      (let ((before-method (b 'before-method))
            (after-method (b 'after-method)))
        (when before-method
          (self 'call-method before-method))
        (when after-method
          (set! i-pending-after-method after-method)
          (set! i-pending-run? #f))))
    (set! i-last-stepper (lambda () (self stepper *step-over-interrupts*)))
    (unless i-find-disassembly-lines?
      (let* ((start-addr (self 'pc))
             (end-addr (self 'find-next-line-address start-addr)))
        (when end-addr
          (self 'set-step-range! start-addr end-addr))))
    (self stepper *step-over-interrupts*)
    self))

(define-method (c-mpe 'set-step-range! start end)
  (mpe-set-step-range! i-handle start end))

(define-method (c-mpe 'keep-stepping? addr)
  (if i-find-disassembly-lines?
    #f
    (if i-last-stepper
      (multiple-value-bind (file name)
                           (self 'find-source-function addr)
        (if file
          (multiple-value-bind (file line count)
                               (self 'find-source-line-number addr)
            (if file
              #f
              (let ((end-addr (self 'find-next-line-address addr)))
                (when end-addr
                  (self 'set-step-range! addr end-addr))
                (gg-dformat "~%Auto step in ~A" name)
                (i-last-stepper)
                #t)))
          #f))
      #f)))

(define-method (c-mpe 'complete-step addr)
  (unless (self 'keep-stepping? addr)
    (let ((after-method i-pending-after-method))
      (set! i-last-stepper #f)
      (if after-method
        (begin
          (set! i-pending-after-method #f)
          (self 'call-method after-method)
          (if i-pending-run?
            (begin
              (set! i-pending-run? #f)
              (self 'run))
            (self 'halt addr "Stop")))
        (self 'halt addr "Step")))))

(define (wait-for-halt &optional (processor *mpe))
  (processor 'wait-for-halt))

(define-method (c-mpe 'wait-for-halt)
  (while i-running?
    (idle))
  self)

(define-method (c-mpe 'packet-info addr)
  (mpe-packet-info i-handle addr))
  
(define-method (c-mpe 'source-path)
  i-source-path)

(define (set-source-path! path &optional (processor *mpe*))
  (processor 'set-source-path! path))

(define-method (c-mpe 'set-source-path! path)
  (set! i-source-path path)
  (values))

(define-method (c-mpe 'find-source-file file)
  (if (file-exists? file)
    (let ((relative-path (relative-path? file)))
      (if relative-path
        (combine-path-with-filename (convert-slashes (getcwd)) relative-path)
        file))
    (multiple-value-bind (file-path file-root)
                         (split-path-from-filename file)
      (let loop ((path (self 'source-path)))
        (if path
          (let ((full-name (combine-path-with-filename (car path) file-root)))
            (if (file-exists? full-name)
              full-name
              (loop (cdr path))))
          #f)))))

(define (file-exists? file)
  (let ((f (open-input-file file)))
    (if f
      (begin
        (close-input-port f)
        #t)
      #f)))

(define (relative-path? file)
  (cond ((string=? (substring file 0 2) "./") (substring file 2))
        ((string=? (substring file 0 1) "/") #f)
        ((string=? (substring file 1 2) ":/") #f)
        (#t file)))

(define-method (c-mpe 'setup-file-references)
  (let ((files (self 'internal-get-file-references)))
    (set! i-file-references (make-vector (length files)))
    (set! i-file-reference-states (make-vector (length files)))
    (let loop ((files files) (i 0))
      (when files
        (let ((file (car files)))
	  (if (and file (/= (string-length file) 0))
	    (multiple-value-bind (tag name)
                                 (separate-tag-from-name file)
              (if (self 'include-file? name)
                (let* ((full-path (self 'find-source-file name))
                       (name (or full-path name)))
                  (vector-set! i-file-references i (if tag
                                                     (format #f "*~A*~A" tag name)
                                                     name))
                  (vector-set! i-file-reference-states i #t))
                (vector-set! i-file-reference-states i #f)))
            (vector-set! i-file-reference-states i #f))
          (loop (cdr files) (1+ i)))))
    self))

(define (separate-tag-from-name file)
  (if (char=? (string-ref file 0) #\*)
    (let* ((tag-end (string-search "*" file :start2 1))
                   (tag (if tag-end
                              (substring file 1 tag-end)
                                  #f))
                   (name (if tag-end
                                   (substring file (1+ tag-end))
                                   (substring file 1))))
          (values tag name))
        (values #f file)))

(define-method (c-mpe 'include-file? name)
  (and (/= (string-length name) 0) ; because of eric's hack in coffload.c
       (self 'source-file? name)))

(define-method (c-mpe 'source-file? name)
  (let ((ext-offset (string-search "." name :from-end? #t)))
    (and ext-offset
         (let ((ext (substring name ext-offset)))
           (member ext '(".c" ".cpp" ".s" ".i" ".a"))))))   

(define-method (c-mpe 'valid-file-reference? file)
  (and i-file-reference-states
       (>= file 0)
       (< file (vector-length i-file-reference-states))
       (vector-ref i-file-reference-states file)))

(define-method (c-mpe 'get-file-references)
  i-file-references)

(define-method (c-mpe 'get-file-reference file)
  (and i-file-references
       (>= file 0)
       (< file (vector-length i-file-references))
       (or (vector-ref i-file-references file) "")))

(define-method (c-mpe 'set-file-reference-state! file state)
  (and i-file-reference-states
       (>= file 0)
       (< file (vector-length i-file-reference-states))
       (vector-set! i-file-reference-states file state)))

(define-method (c-mpe 'refresh-state!)
  (self 'load-register-values)
  (self 'initialize-instruction-decoder)
  self)

(define-method (c-mpe 'load-register-values)
  (mpe-load-register-values i-handle)
  self)

(define-method (c-mpe 'register-address name)
  (mpe-register-address i-handle name))

(define-method (c-mpe 'initialize-instruction-decoder)
  (mpe-init-instruction-decoder i-handle))

(define (load-source-file name &key (processor *mpe*)
                                    (use-fast-loader? #t)
                                    (ignore-before-after? #f)
                                    (load-debugging-info? #t)
                                    (load-code? #t)
                                    (initialize? #t)
                                    (run? #f))
  (processor 'load-source-file name :use-fast-loader? use-fast-loader?
                                    :ignore-before-after? ignore-before-after?
                                    :load-debugging-info? load-debugging-info?
                                    :load-code? load-code?
                                    :initialize? initialize?
                                    :run? run?))

(define (load-and-run-source-file name &rest args)
  (apply load-source-file name :run? #t args))
                              
(define-method (c-mpe 'load-source-file name &key (use-fast-loader? #t)
                                                  (ignore-before-after? #f)
                                                  (load-debugging-info? #t)
                                                  (load-code? #t)
												  (use-bios-loader? (self 'use-bios-loader?))
                                                  (initialize? #t)
                                                  (run? #f))
  (let ((object-name (assemble-file name)))
    (if object-name
      (self 'load-object-file object-name :use-fast-loader? use-fast-loader?
                                          :ignore-before-after? ignore-before-after?
                                          :load-debugging-info? load-debugging-info?
                                          :load-code? load-code?
										  :use-bios-loader? use-bios-loader?
                                          :initialize? initialize?
                                          :run? run?)
      #f)))

(define (assemble-file file)
  (let ((bin-file (make-binary-file-name file))
        (err-file (make-error-file-name file)))
    (if (string-ci=? file bin-file)
      (begin
        (format #t "~&File already assembled: ~S" file)
        file)
      (begin
        (format #t "~&Assembling: ~S" file)
        (let* ((cmd (make-assembler-command file bin-file err-file))
               (sts (run-program cmd)))
          (if sts
            (let ((f (open-input-file err-file)))
              (when f
                (let ((err (read f)))
                  (when (not (eof-object? err))
                    (show-error err)
                    (let loop ()
                      (let ((err (read f)))
                        (unless (eof-object? err)
                          (show-error err)
                          (loop)))))
                  (close-port f)
                  (if (eof-object? err)
                    (values 1 "assembler internal error")
                    (values-list err))))
              bin-file)
            #f))))))

(define (make-binary-file-name name)
  (string-append (get-root-file-name name) ".mpo"))

(define (make-error-file-name name)
  (string-append (get-root-file-name name) ".err"))

(define (get-root-file-name name)
  (let ((ext-offset (string-search "." name :from-end? #t)))
    (if ext-offset
      (values (substring name 0 ext-offset)
              (substring name (+ ext-offset 1)))
      name)))

(define (make-assembler-command src-file bin-file err-file)
  (format #f "llama -fmpo -o \"~A\" -e \"~A\" \"~A\"" bin-file err-file src-file))

(define (show-error err)
  (let ((status (first err))
        (text (second err))
        (file (third err))
        (line (fourth err)))
    (case status
      (1 (list-error "Error" text file line))
      (2 (list-error "Error" text file line))
      (3 (list-error "Error" text file line))
      (4 (when *display-warnings*
           (list-error "Warning" text file line)))
      (5 (when *display-info*
           (list-error "Info" text file line))))))

(define (list-error tag text file line)
  (format #t "~&~A: ~A" tag text)
  (when file
    (format #t ", File: ~A" file)
    (when line
      (format #t ", Line: ~A" line))))

(define (display-error text file line)
  (format #t "~&Error: ~A" text)
  (when file
    (display-source file line)))

(define (display-source file start &optional (count 1))
  (let ((fname (*mpe* 'get-file-reference file)))
    (display-lines fname start count)
    (values)))

(define (load-object-file name &key (processor *mpe*)
                                    (use-fast-loader? #t)
                                    (ignore-before-after? #f)
                                    (load-debugging-info? #t)
                                    (load-code? #t)
									(use-bios-loader? (processor 'use-bios-loader?))
                                    (initialize? #t)
                                    (run? #f))
  (processor 'load-object-file name :use-fast-loader? use-fast-loader?
                                    :ignore-before-after? ignore-before-after?
                                    :load-debugging-info? load-debugging-info?
                                    :load-code? load-code?
									:use-bios-loader? use-bios-loader?
                                    :initialize? initialize?
                                    :run? run?))

(define (load-and-run-object-file name &rest args)
  (apply load-object-file name :run? #t args))

(define (load-symbols name &key (processor *mpe*))
  (load-object-file name :processor processor 
                         :load-debugging-info? #t
                         :load-code? #f
						 :initialize? #f
						 :run? #f))

(define-method (c-mpe 'load-object-file name &key (use-fast-loader? #t)
                                                  (ignore-before-after? #f)
                                                  (load-debugging-info? #t)
                                                  (load-code? #t)
												  (use-bios-loader? (self 'use-bios-loader?))
                                                  (initialize? #t)
                                                  (run? #f))
  (multiple-value-bind (success? error error-text)
                       (self 'internal-load-object-file name
                             :use-fast-loader? use-fast-loader?
                             :ignore-before-after? ignore-before-after?
                             :load-debugging-info? load-debugging-info?
                             :load-code? load-code?
							 :use-bios-loader? use-bios-loader?)
    (if success?
      (begin
        (format #t "~%Loaded ~S" name)
        (self 'setup-file-references)
        (self 'add-methods)
        (if run?
          (self 'run)
          (when initialize?
            (let ((start (self 'start-address)))
              (when start
                (self 'set-startup-breakpoint! start)
                (self 'internal-run) ; to fill the pipeline
                (gg-running i-unit-number)))))
        (gg-refresh i-unit-number name)
        #t)
      (values #f error error-text))))

(define-method (c-mpe 'use-bios-loader?)
  (and (= i-unit-number 3) *use-bios-loader?*))

(define (reload-object-file &key (processor *mpe*)
						  	     (initialize? #t)
                                 (run? #f))
  (processor 'reload-object-file :initialize? initialize?
								 :run? run?))

(define-method (c-mpe 'reload-object-file &key (initialize? #t)
											   (run? #f))
  (multiple-value-bind (success? error error-text)
                       (self 'internal-reload-object-file)
    (if success?
      (begin
        (format #t "~%Reloaded object file")
        (if run?
          (self 'run)
          (when initialize?
            (let ((start (self 'start-address)))
              (when start
                (self 'set-startup-breakpoint! start)
                (self 'internal-run) ; to fill the pipeline
                (gg-running i-unit-number)))))
        (gg-refresh i-unit-number name)
        #t)
      (values #f error error-text))))

(define-method (c-mpe 'find-line-number addr &optional (offset? #f))
  (if i-find-disassembly-lines?
    (self 'find-disassembly-line-number addr)
    (multiple-value-bind (file line count offset)
                         (self 'find-source-line-number addr offset?)
      (if file
        (values file line count offset)
        (self 'find-disassembly-line-number addr)))))

(define-method (c-mpe 'find-source-line-number addr &optional (offset? #f))
  (multiple-value-bind (file line count offset)
                       (self 'internal-find-line-number addr offset?)
    (if (and file (self 'valid-file-reference? file))
      (values file line count offset)
      #f)))

(define-method (c-mpe 'find-disassembly-line-number addr)
  (let ((info (table-ref i-disassembly-line-numbers addr)))
    (if info
      (values 'disassembly (car info) (cdr info))
      #f)))

(define-method (c-mpe 'find-next-line-address addr)
  (multiple-value-bind (file line count)
                       (self 'find-next-line-number addr)
    (if (and file (self 'valid-file-reference? file))
      (self 'find-address-from-line-number file line)
      #f)))

(define-method (c-mpe 'find-address-from-line-number file line)
  (if (and (number? file) (self 'valid-file-reference? file))
    (self 'internal-find-address-from-line-number file line)
    (table-ref i-disassembly-reverse-line-numbers line)))

(define-method (c-mpe 'find-source-function addr)
  (multiple-value-bind (file name)
                       (self 'find-function addr)
    (if (and file (self 'valid-file-reference? file))
      (values file name)
      #f)))

(define-method (c-mpe 'enable-disassembly state)
  (set! i-find-disassembly-lines? state))
    
(define-method (c-mpe 'disassemble-to-string start count)
  (let ((s (make-string-output-stream)))
    (self 'disassemble start count s)
    (get-output-stream-string s)))

(define-method (c-mpe 'disassemble start count &optional (port *standard-output*))
  (let ((packet-line #f)
        (line 1))
    (empty-table! i-disassembly-line-numbers)
    (empty-table! i-disassembly-reverse-line-numbers)
    (let loop ((count count)
               (packet-addr start)
               (addr start)
               (in-packet? #f))

      ; disassemble each instruction
      (when (> count 0)

        ; find any labels for this address
        (multiple-value-bind (names offset)
                             (self 'find-symbols-nearest-address addr)
          (when (and names (= offset 0))
            (format port "~%~A" (car names))
            (dolist (name (cdr names))
              (format port ", ~A" name))
            (format port ":")
            (inc! line)))

        ; set the line number for the start of the next packet
        (unless packet-line
          (set! packet-line line))

        ; disassemble the instruction at this address
        (multiple-value-bind (instructions size end-of-packet?)
                             (self 'disassemble-instruction packet-addr addr)

          ; handle disassembled instructions
          (if instructions
            (let ((multiple? (> (length instructions) 1)))

              ; check for the start of a new packet
              (if (or in-packet? (and end-of-packet? (not multiple?)))
                (format port "~%~X   ~A" addr (car instructions))
                (format port "~%~X { ~A" addr (car instructions)))
              (inc! line)

              ; handle additional (dec) instructions
              (dolist (instruction (cdr instructions))
                (format port "~%           ~A" instruction)
                (inc! line))

              ; check for the end of packet
              (when end-of-packet?

                ; check for the end of a multiple instruction packet
                (when (or in-packet? multiple?)
                  (format port "~%         }")
                  (inc! line))

                (let ((info (cons packet-line (- line packet-line))))
                  (table-set! i-disassembly-line-numbers packet-addr info)
                  (table-set! i-disassembly-reverse-line-numbers packet-line packet-addr)
                  (set! packet-line #f))))

            ; no valid instruction at this address
            (let ((inst (self 'fetch-scalar addr)))
              (format port "~%~X   " addr)
              (fluid-let ((*hexnum-format* "%04lx"))
                (format port "<unknown: ~X>" (lsh inst -16)))
              (set! size 2)
              (set! end-of-packet? #t)
              (inc! line)))

          ; advance to the next instruction
          (let ((next-addr (+ addr size)))
            (loop (-1+ count)
                  (if end-of-packet? next-addr packet-addr)
                  next-addr
                  (not end-of-packet?))))))
    (values)))

(define-method (c-mpe 'disassemble-instruction pc addr)
  (mpe-disassemble-instruction i-handle pc addr))

(define (set-scope! name)
  (*mpe* 'set-current-block! (*mpe* 'find-symbol name)))

(define-method (c-mpe 'set-current-block! addr)
  (mpe-set-current-block! i-handle addr))

(define-method (c-mpe 'get-local-symbol-names)
  (mpe-get-local-symbol-names i-handle))

(define (find-symbol name &optional (processor *mpe*))
  (processor 'find-symbol name))

(define-method (c-mpe 'find-symbol name)
  (multiple-value-bind (value overlay class type)
                       (self 'find-symbol-trying-c-name name)
    (if value
      (if (string? value)
        (self 'find-register-by-name value)
        (values value overlay class type))
      #f)))

(define-method (c-mpe 'find-symbol-trying-c-name name)
  (multiple-value-bind (value overlay class type-handle)
                       (mpe-find-symbol i-handle name)
    (if value
	  (values value overlay class (make-type type-handle))
	  (multiple-value-bind (value overlay class type-handle)
                           (mpe-find-symbol i-handle (string-append "_" name))
        (if value
	      (values value overlay class (make-type type-handle))
		  #f)))))

(define-method (c-mpe 'find-symbol-address name)
  (multiple-value-bind (value overlay)
                       (self 'find-symbol name)
    (if value
      (if overlay
        (let ((overlay-addr (self 'translate-overlay-address overlay value)))
          (if overlay-addr
            overlay-addr
            #f))
        value)
      #f)))

(define-method (c-mpe 'find-symbol-or-register pname)
  (multiple-value-bind (value overlay class type)
                       (self 'find-symbol pname)
      (if value
        (if (eq? class 'register)
          (self 'find-register-by-address value)
          value)
        (self 'find-register-by-name pname))))        

(define-method (c-mpe 'find-symbols-nearest-address addr)
  (mpe-find-symbols-nearest-address i-handle addr))

(define-method (c-mpe 'find-label-and-offset addr)
  (multiple-value-bind (file name base)
                       (self 'find-function addr)
    (if file
      (values name (- addr base))
      (multiple-value-bind (symbols offset)
                           (self 'find-symbols-nearest-address addr)
        (if symbols
          (values (car symbols) offset)
          #f)))))

(define-method (c-mpe 'find-type name)
  (let ((type-handle (mpe-find-type i-handle name)))
    (and type-handle (make-type type-handle))))

(define-method (c-mpe 'get-tag-members name)
  (map (lambda (m) (apply (lambda (name offset type-handle &rest more)
                            (list* name offset (make-type type-handle) more)) m))
    (mpe-get-tag-members i-handle name)))

(define-method (c-mpe 'get-before-method n)
  (mpe-get-before-method i-handle n))

(define-method (c-mpe 'get-after-method n)
  (mpe-get-after-method i-handle n))

(define-method (c-mpe 'find-next-line-number addr)
  (mpe-find-next-line-number i-handle addr))

(define-method (c-mpe 'find-function addr)
  (mpe-find-function i-handle addr))

(define (c expr)
  (*mpe* 'get-value expr))

(define-method (c-mpe 'get-value expr)
  (mpe-get-value i-handle (self 'fp) expr))

(define (load-binary-file addr name &key (processor *mpe*)
                                         (initialize? #t)
                                         (use-fast-loader? #t))
  (processor 'load-binary-file addr name :initialize? initialize?
                                         :use-fast-loader? use-fast-loader?))

(define-method (c-mpe 'load-binary-file addr name &key (initialize? #t)
                                                       (use-fast-loader? #t))
  (mpe-load-binary-file i-handle addr name :initialize? initialize?
                                           :use-fast-loader? use-fast-loader?))

(define-method (c-mpe 'halt addr reason)
  (multiple-value-bind (file line count offset)
                       (self 'find-line-number addr #t)
    (self 'clear-startup-breakpoint!)
    (self 'set-run-state! #f)
    (%gg-halt self addr reason file line count offset)))

; halt hook dispatch table
(define *halt-hook-dispatch*
  `((,hh-memwrportconflict .    *memwrportconflict-hook*)
    (,hh-mulwrportconflict .    *mulwrportconflict-hook*)
    (,hh-rdportconflict .       *rdportconflict-hook*)
    (,hh-regwrconflict .        *regwrconflict-hook*)
    (,hh-dataaddresserror .     *data-addresserror-hook*)
    (,hh-instaddresserror .     *inst-addresserror-hook*)
    (,hh-MainDMAError .         *maindmaerror-hook*)
    (,hh-OtherDMAError .        *otherdmaerror-hook*)
    (,hh-CoprocDMAError .       *coprocdmaerror-hook*)
    (,hh-CoprocessorError .     *coprocessorerror-hook*)
    (,hh-internalerror .        *internalerror-hook*)
    (,hh-halt .                 *halt-hook*)
    (,hh-step .                 *step-hook*)
    (,hh-break .                *break-hook*)
    (,hh-dabreak .              *dabreak-hook*)))

; called by debugger on halt conditions
(define (halt-hook handle unit-number reason addr data)
  (if (< unit-number 0)
    (system-halt addr reason)
    (let ((p (*mmp* 'mpe unit-number)))
      (when p
        (p 'refresh-state!)
        (unless (let loop ((table *halt-hook-dispatch*))
                  (if table
                    (let ((bit (caar table))
                          (handler (cdar table)))
                      (if (not (zero? (logand bit reason)))
                        (begin
                          ((symbol-value handler) p addr data)
                          #t)
                        (loop (cdr table))))
                    #f))
          (p 'halt addr (format nil "Unknown exception #x~X" reason)))))))

(define (system-halt addr reason)
  (gg-report-dma-exception))

(define (*halt-hook* p addr data)
  (p 'halt addr "Halt"))

(define (*step-hook* p addr data)
  (p 'complete-step addr))

(define (*break-hook* p addr data)
  (p 'break addr))

(define (*dabreak-hook* p addr data)
  (p 'data-break addr))

(define (*memwrportconflict-hook* p addr data)
  (if *detect-conflicts*
    (p 'halt addr (format nil "Memory write port conflict"))))

(define (*mulwrportconflict-hook* p addr data)
  (if *detect-conflicts*
    (p 'halt addr (format nil "Multiplier write port conflict"))))

(define (*rdportconflict-hook* p addr data)
  (if *detect-conflicts*
    (p 'halt addr (format nil "Shared read port conflict"))))

(define (*regwrconflict-hook* p addr data)
  (if *detect-conflicts*
    (p 'halt addr (format nil "Register write conflict"))))

(define (*data-addresserror-hook* p addr data)
  (p 'halt addr (format nil "Data address error")))

(define (*inst-addresserror-hook* p addr data)
  (p 'halt addr (format nil "Instruction address error")))

(define (*maindmaerror-hook* p addr data)
  (p 'halt addr (format nil "Main bus dma error")))

(define (*otherdmaerror-hook* p addr data)
  (p 'halt addr (format nil "Other bus dma error")))

(define (*coprocdmaerror-hook* p addr data)
  (p 'halt addr (format nil "Coprocessor dma error")))

(define (*coprocessor-hook* p addr data)
  (p 'halt addr (format nil "Coprocessor error")))

(define (*internalerror-hook* p addr data)
  (p 'halt addr (format nil "Internal error")))

; target functions

(define-method (c-mpe 'target-set-breakpoint! addr)
  (mpe-set-breakpoint! i-handle addr))

(define-method (c-mpe 'target-clear-breakpoint! addr)
  (mpe-clear-breakpoint! i-handle addr))

; internal functions

(define-method (c-mpe 'internal-running?)
  (mpe-running? i-handle))

(define-method (c-mpe 'internal-run)
  (self 'set-run-state! #t)
  (mpe-run i-handle)
  self)

(define-method (c-mpe 'internal-step &optional (step-over-interrupts? #t))
  (self 'set-run-state! #t)
  (mpe-step i-handle step-over-interrupts?)
  self)

(define-method (c-mpe 'internal-step-over &optional (step-over-interrupts? #t))
  (self 'set-run-state! #t)
  (mpe-step-over i-handle step-over-interrupts?)
  self)

(define-method (c-mpe 'internal-stop)
  (self 'set-run-state! #f)
  (mpe-stop i-handle)
  self)

(define-method (c-mpe 'internal-get-file-reference n)
  (mpe-get-file-reference i-handle n))

(define-method (c-mpe 'internal-get-file-references)
  (let loop ((files '()) (n 0))
    (let ((file (mpe-get-file-reference i-handle n)))
      (if file
        (loop (cons file files) (+ n 1))
        (reverse files)))))

(define-method (c-mpe 'internal-find-line-number addr &optional (offset? #f))
  (self 'set-current-block! addr)
  (mpe-find-line-number i-handle addr offset?))

(define-method (c-mpe 'internal-find-address-from-line-number file line)
  (mpe-find-address-from-line-number i-handle file line))

(define-method (c-mpe 'internal-load-object-file name &rest args)
  (apply mpe-load-object-file i-handle name args))

(define-method (c-mpe 'internal-reload-object-file)
  (mpe-reload-object-file i-handle))

(define-class c-type
  (instance-variables
    i-handle))

(define (make-type handle)
  (c-type 'new handle))

(define-method (c-type 'initialize handle)
  (set! i-handle handle)
  self)

(define-method (c-type 'handle)
  i-handle)

(define-method (c-type 'specifier)
  (let ((specifier (mpe-get-type-specifier i-handle)))
    (if (symbol? specifier)
      specifier
      (map (lambda (s) (if (foreign-pointer? s 'type-handle)
                         (make-type s)
                         s))
        specifier))))

(define-method (c-type 'size)
  (mpe-get-type-size i-handle))

(define-method (c-type 'same? other)
  (foreign-pointer-eq? i-handle (other 'handle)))
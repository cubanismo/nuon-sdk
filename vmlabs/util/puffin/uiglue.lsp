; uiglue.lsp
; GUI Glue functions for Puffin.
(set! *gg-debugging* #f)

; (gg-load-debug-file path)
; Load a debug (lisp) file.
(define (gg-load-debug-file path)
  (let ((p *mpe*))
    (*mmp* 'set-last-load! load-debug-file path p)
    (load-debug-file path :processor p)))

; (gg-load-source-file path &optional n)
; Load a source (llama) file.
; The optional parameter is the mpe number.
(define (gg-load-source-file path &optional n)
  (let ((p (%gg-get-processor n)))
    (*mmp* 'set-last-load! load-source-file path p)
    (load-source-file path :processor p)))

; (gg-load-object-file path &optional n)
; Load an object file.
; The optional parameter is the mpe number.
(define (gg-load-object-file path &optional n)
  (let ((p (%gg-get-processor n)))
    (*mmp* 'set-last-load! load-object-file path p)
    (load-object-file path :processor p)))

; (gg-load-symbols path &optional n)
; Load a the symbols from an object file.
; The optional parameter is the mpe number.
(define (gg-load-symbols path &optional n)
  (let ((p (%gg-get-processor n)))
    (*mmp* 'set-last-load! load-symbols path p)
    (load-symbols path :processor p)))

; (gg-reload-object-file &optional n)
; Reload the data/code from the last object file loaded.
; The optional parameter is the mpe number.
(define (gg-reload-object-file &optional n)
  (let ((p (%gg-get-processor n)))
    (reload-object-file :processor p)))

; (gg-load-binary-file path &optional n)
; Load a binary data file.
; The optional parameter is the mpe number.
(define (gg-load-binary-file path &optional n)
  (let ((p (%gg-get-processor n)))
    (load-binary-file path :processor p)))

; (gg-restart)
; Reload the last file loaded by any of the above load functions.
(define (gg-restart)
  (*mmp* 'restart))

; (gg-reset)
; Reset the mmp.
(define (gg-reset)
  (*mmp* 'reset))

; (gg-step &optional n)
; Single step an mpe.
; The optional parameter is the mpe number.
(define (gg-step &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'step)))

; (gg-step-over &optional n)
; Single step an mpe stepping over subroutines.
; The optional parameter is the mpe number.
(define (gg-step-over &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'step-over)))

; (gg-running? &optional n)
; Check to see if an mpe is running.
; The optional parameter is the mpe number.
(define (gg-running? &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'running?)))

; (gg-run &optional n)
; Start an mpe running.
; The optional parameter is the mpe number.
(define (gg-run &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'run)))

; (gg-stop &optional n)
; Stop an mpe from running.
; The optional parameter is the mpe number.
(define (gg-stop &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'stop)))

; (gg-run-all)
; Start all mpes running.
(define (gg-run-all)
  (*mmp* 'run-all))

; (gg-stop-all)
; Stop all mpes from running.
(define (gg-stop-all)
  (*mmp* 'stop-all))

(define (gg-address file line &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'find-address-from-line-number file line)))

; (gg-toggle-breakpoint-on-line! file line &optional n)
; Toggle a breakpoint on the specified line in the specified file.
; The optional parameter is the mpe number.
(define (gg-toggle-breakpoint-on-line! file line &optional n)
(gg-dformat "~%MPE ~S toggle breakpoint: file ~S, line ~S" n file line)
  (let* ((p (%gg-get-processor n))
         (addr (p 'find-address-from-line-number file line)))
    (if addr
      (begin
        (if (p 'breakpoint? addr)
          (p 'clear-breakpoint! addr)
          (p 'set-breakpoint! addr))
        #t)
      #f)))

; (gg-toggle-breakpoint! addr &optional n)
; Toggle a breakpoint at the specified address.
; The optional parameter is the mpe number.
(define (gg-toggle-breakpoint! addr &optional n)
(gg-dformat "~%MPE ~S toggle breakpoint: addr ~X" n addr)
  (let ((p (%gg-get-processor n)))
    (if (p 'breakpoint? addr)
      (p 'clear-breakpoint! addr)
      (p 'set-breakpoint! addr))))

; (gg-breakpoint-settings n addr)
; Get the settings associated with the breakpoint at the specified address.
; n is the mpe number
; addr is the address of the breakpoint
(define (gg-breakpoint-settings n addr)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-breakpoint addr)))
    (when b
      (b 'settings))))

; (gg-breakpoint-condition n addr)
; Get the condition associated with the breakpoint at the specified address.
; n is the mpe number
; addr is the address of the breakpoint
(define (gg-breakpoint-condition n addr)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-breakpoint addr)))
    (when b
      (b 'condition))))

; (gg-breakpoint-before n addr)
; Get the before method associated with the breakpoint at the specified address.
; n is the mpe number
; addr is the address of the breakpoint
(define (gg-breakpoint-before n addr)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-breakpoint addr)))
    (when b
      (b 'before))))

; (gg-breakpoint-after n addr)
; Get the after method associated with the breakpoint at the specified address.
; n is the mpe number
; addr is the address of the breakpoint
(define (gg-breakpoint-after n addr)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-breakpoint addr)))
    (when b
      (b 'after))))

; (gg-breakpoint-change! n addr &rest args)
; Change the settings associated with the breakpoint at the specified address.
; n is the mpe number
; addr is the address of the breakpoint
; args is the set of keyword arguments for the settings to be changed
; these arguments include :breakpoint?, :condition, :count, :before and :after
(define (gg-breakpoint-change! n addr &rest args)
(gg-dformat "~%MPE ~S breakpoint change: addr ~X ~S" n addr args)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-breakpoint addr)))
    (when b
      (apply b 'change! args))))

; (gg-refresh-all-breakpoints &optional n)
; Call gg-set-breakpoint-on-line! or gg-set-breakpoint! for each active
; source breakpoint. The optional parameter is the mpe number.
(define (gg-refresh-all-breakpoints &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'map-over-breakpoints
      (lambda (b)
        (let ((addr (b 'address)))
          (%gg-announce-line-number p addr gg-set-breakpoint-on-line!))))))

; (gg-breakpoint i &optional n)
; Get the specified breakpoint from the specified mpe.
; The optional parameter is the mpe number.
(define (gg-breakpoint i &optional n)
  (let* ((p (%gg-get-processor n))
         (breakpoints (p 'map-over-breakpoints identity))
         (b (list-ref breakpoints i)))
    (if b
      (let* ((addr (b 'address))
             (addr-str (p 'label-and-offset-string addr)))
        (multiple-value-bind (file line count offset)
                             (p 'find-line-number addr #t)
          (if file
            (list addr addr-str file line offset)
            (list addr addr-str))))
      #f)))

; (gg-clear-all-breakpoints! &optional n)
; Clear all breakpoints for the specified mpe.
; The optional parameter is the mpe number.
(define (gg-clear-all-breakpoints! &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'clear-all-breakpoints!)))

; (gg-set-data-breakpoint! addr &optional n)
; set the data breakpoint at the specified address.
; The optional parameter is the mpe number.
(define (gg-set-data-breakpoint! addr &optional n)
(gg-dformat "~%MPE ~S set data breakpoint: addr ~X" n addr)
  (let ((p (%gg-get-processor n)))
	(p 'set-data-breakpoint! addr :read? #t :write? #t)))

; (gg-clear-data-breakpoint! &optional n)
; Clear the data breakpoint.
; The optional parameter is the mpe number.
(define (gg-clear-data-breakpoint! &optional n)
(gg-dformat "~%MPE ~S clear data breakpoint" n)
  (let ((p (%gg-get-processor n)))
	(p 'clear-data-breakpoint!)))

; (gg-data-breakpoint-settings n)
; Get the settings associated with the data breakpoint.
; n is the mpe number
(define (gg-data-breakpoint-settings n)
  (let* ((p (%gg-get-processor n))
         (b (p 'data-breakpoint)))
    (when b
      (b 'settings))))

; (gg-data-breakpoint-condition n)
; Get the condition associated with the data breakpoint.
; n is the mpe number
(define (gg-data-breakpoint-condition n)
  (let* ((p (%gg-get-processor n))
         (b (p 'data-breakpoint)))
    (when b
      (b 'condition))))

; (gg-data-breakpoint-change! n &rest args)
; Change the settings associated with the breakpoint.
; n is the mpe number
; args is the set of keyword arguments for the settings to be changed
; these arguments include :breakpoint?, :condition, :count, :before and :after
(define (gg-data-breakpoint-change! n &rest args)
  (let* ((p (%gg-get-processor n))
         (b (p 'data-breakpoint)))
    (when b
	  (format #t "~%change ~S" args)
      (apply b 'change! args)
	  (p 'internal-set-data-breakpoint!))))

; (gg-get-file-reference i &optional n)
; Get the specified file reference.
; The optional parameter is the mpe number.
(define (gg-get-file-reference i &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'get-file-reference i)))

; (gg-set-file-reference! i &optional n)
; Set the specified file reference.
; The optional parameter is the mpe number.
(define (gg-set-file-reference! i &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'set-file-reference-state! i #t)))

; (gg-clear-file-reference! i &optional n)
; Clear the specified file reference.
; The optional parameter is the mpe number.
(define (gg-clear-file-reference! i &optional n)
  (let ((p (%gg-get-processor n)))
    (p 'set-file-reference-state! i #f)))

; (gg-register name &optional n)
; Get the value of an mpe register
; The optional parameter is the mpe number
(define (gg-register name &optional n)
  (let* ((p (%gg-get-processor n))
         (addr (p 'register-address name)))
    (p 'fetch-scalar addr)))

; (gg-set-register! name value &optional n)
; Get the value of an mpe register
; The optional parameter is the mpe number
(define (gg-set-register! name value &optional n)
  (let* ((p (%gg-get-processor n))
         (addr (p 'register-address name)))
    (p 'store-scalar! addr value)))

; (gg-refresh-registers &optional n)
; Refresh the cached register values
; The optional parameter is the mpe number
(define (gg-refresh-registers &optional n)
  (let* ((p (%gg-get-processor n)))
    (p 'load-register-values)))

; (gg-make-browser n id)
; Make a new browser with the specified id.
; n is the mpe number
; id is the id
(define (gg-make-browser n id)
  (let ((p (%gg-get-processor n)))
    (let ((b (c-global-symbol-browser 'new p id)))
      (b 'open)
      b)))

; (gg-make-local-symbol-browser n id)
; Make a new local symbol browser with the specified id.
; n is the mpe number
; id is the id
(define (gg-make-local-symbol-browser n id)
  (let ((p (%gg-get-processor n)))
    (c-local-symbol-browser 'new p id)))

; (gg-browse-add-symbol n id name)
; Add a symbol to a browser.
; n is the mpe number
; id is the id of the browser
; name is the name of the symbol
(define (gg-browse-add-symbol n id name)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-browser id)))
    (b 'add-symbol-entry name)))

; (gg-browse-remove-entry n id)
; Remove an entry from a browser.
; n is the mpe number
; id is the id of the browser
; entry-id is the id of the entry to remove
(define (gg-browse-remove-entry n id)
  (let ((p (%gg-get-processor n))
        (offset (string-search "-" id :from-end? #t)))
    (if offset
      (let* ((browser-id (substring id 0 offset))
             (b (p 'find-browser browser-id)))
        (b 'remove-entry! id))
      #f)))

; (gg-browse-add-address n id addr type)
; Add an address to a browser
; n is the mpe number
; id is the id of the browser
; addr is the address
; type is the data type
(define (gg-browser-add-address n id addr type)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-browser id)))
    (b 'add-entry (format #f "0x~X" addr) addr type)))

; (gg-browse-frame n id frame-n)
; Browse a specified stack frame
; n is the mpe number
; id is the id of the browser
; frame-n is the frame number
(define (gg-browse-frame n id frame-n)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-browser id)))
(gg-dformat "~%MPE ~S browse frame: ~S ~S" n id frame-n)
    (b 'set-frame! frame-n)))

; (gg-frame n frame-n)
; Get the function and offset for a specified stack frame
; n is the mpe number;
; frame-n is the frame number
(define (gg-frame n frame-n)
  (let ((p (%gg-get-processor n)))
    (p 'frame-address frame-n)))

; (gg-browse-refresh n)
; Refresh the browsers associated with an mpe.
; n is the mpe number
(define (gg-browse-refresh n)
  (let ((p (%gg-get-processor n)))
(gg-dformat "~%MPE ~S browse refresh" n)
    (p 'refresh-browsers)))

; (gg-browse-toggle-entry n id)
; Toggle a browser entry.
; n is the mpe number
; id is the id string of the browser entry to open or close
(define (gg-browse-toggle-entry n id)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-browser id)))
(gg-dformat "~%MPE ~S browse toggle ~S" n id)
    (when b
      (if (b 'open?)
        (b 'close)
        (b 'open)))))

; (gg-browse-range n start end)
; Set the range of an array browser.
; n is the mpe number
; id is the3 id string of the browser
; start is the start of the range
; end is the end of the range
(define (gg-browse-range n id start end)
(gg-dformat "~%MPE ~S browse range: id ~S, start ~S, end ~S" n id start end)
  (let* ((p (%gg-get-processor n))
         (b (p 'find-browser id)))
    (when b
      (b 'set-range! start end))))

; (gg-browse-set-value! n id value)
; Set the value of a browser entry.
; n is the mpe number
; id is the id of the browser entry
; value is the new value
(define (gg-browse-set-value! n id value)
  (let* ((p (%gg-get-processor n))
         (entry (p 'find-browser-entry id)))
    (when entry
      (entry 'set-value! value))))

; (gg-request-watch-forms n)
; Request the watch entries for an mpe.
; n is the mpe number
(define (gg-request-watch-forms n)
  (let ((p (%gg-get-processor n)))
    (p 'request-watch-forms)))

; (gg-watch n name &key format popup-format fracbits count local? use-cache? indirect?)
; Setup a watch variable.
; n is the mpe number
; name is the variable name string
; format is 'hex, 'binary, 'decimal, 'ascii or 'real
; popup-format is "<field>..." where field is <name>.<start>:<end>.<printf-format>
; fracbits is the number of fracbits
; count is the item count
; local? is #t for local addresses and #f for global
; use-cache? is #t to use the data cache and #f otherwise
; indirect? is #t for pointers and #f otherwise
; for example:
; (gg-watch 0 "foo" :format 'real :fracbits 8 :count 3)
; this will display three values starting at "foo" as
; a real numbers with 8 fracbits
(define (gg-watch n name &rest args)
(format #t "~%gg-watch ~S" args)
  (let ((p (%gg-get-processor n))
        (name (%gg-convert-number name)))
    (apply p 'watch name args)))

; (gg-watch-popup-format n id)
; Get the popup format string for a watch entry
; n is the mpe number
; id is the id of the watch entry
(define (gg-watch-popup-format n id)
  (let ((settings (gg-watch-settings n id)))
    (cadr (member :popup-format settings))))


; (gg-watch-format n id)
; Get the format string for a watch entry
; n is the mpe number
; id is the id of the watch entry
(define (gg-watch-format n id)
  (let ((settings (gg-watch-settings n id)))
    (cadr (member :format settings))))

; (gg-watch-fracbits n id)
; Get the fracbits for a watch entry
; n is the mpe number
; id is the id of the watch entry
(define (gg-watch-fracbits n id)
  (let ((settings (gg-watch-settings n id)))
    (cadr (member :fracbits settings))))


; (gg-watch-count n id)
; Get the count for a watch entry
; n is the mpe number
; id is the id of the watch entry
(define (gg-watch-count n id)
  (let ((settings (gg-watch-settings n id)))
    (cadr (member :count settings))))


; (gg-watch-local? n id)
; Get the local flag for a watch entry
; n is the mpe number
; id is the id of the watch entry
(define (gg-watch-local? n id)
  (let ((settings (gg-watch-settings n id)))
    (cadr (member :local? settings))))

; (gg-watch-use-cache? n id)
; Get the use-cache flag for a watch entry
; n is the mpe number
; id is the id of the watch entry
(define (gg-watch-use-cache? n id)
  (let ((settings (gg-watch-settings n id)))
    (cadr (member :use-cache? settings))))


; (gg-watch-indirect? n id)
; Get the indirect flag for a watch entry
; n is the mpe number
; id is the id of the watch entry
(define (gg-watch-indirect? n id)
  (let ((settings (gg-watch-settings n id)))
    (cadr (member :indirect? settings))))


; (gg-watch-settings n id)
; Get the settings for a watch entry.
; n is the mpe number
; id is the id of the watch entry
(define (gg-watch-settings n id)
  (let ((p (%gg-get-processor n)))
    (p 'watch-settings id)))

; (gg-watch-change! n id &key format popup-format fracbits count local? use-cache? indirect?)
; Setup a watch variable.
; n is the mpe number
; id is the id of the watch entry to change
; format is 'hex, 'binary, 'decimal, 'ascii or 'real
; popup-format is "<field>..." where field is <name>.<start>:<end>.<printf-format>
; fracbits is the number of fracbits
; count is the item count
; local? is #t for local addresses and #f for global
; use-cache? is #t to use the data cache and #f otherwise
; indirect? is #t for pointers and #f otherwise
(define (gg-watch-change! n id &rest args)
  (let ((p (%gg-get-processor n)))
    (apply p 'watch-change! id args)))

; (gg-unwatch n id)
; Remove a watch variable.
(define (gg-unwatch n id)
  (let ((p (%gg-get-processor n)))
    (p 'unwatch id)))

; (gg-set-watch-value! n id offset value)
; Set the value of a watch variable.
; n is the mpe number
; id is the id of the watch entry to change
; offset is the scalar offset from the base address
; value is the new value
(define (gg-set-watch-value! n id offset value-string)
  (let ((p (%gg-get-processor n))
        (value (read-from-string (format #f "#x~A" value-string))))
    (p 'set-watch-value! id offset value)))

; (gg-disassemble n addr count)
; Disassemble instructions starting at a specified address.
; n is the mpe number.
; addr is the starting address
; count is the instruction count
(define (gg-disassemble n addr count)
  (let ((p (%gg-get-processor n)))
    (gg-dformat "~%MPE ~A disassemble ~X ~S" n addr count)
    (p 'disassemble-to-string addr count)))

; (gg-enable-disassembly n state)
; Enable stepping through diassembled code.
; n is the mpe number
; state - use #t for enabling and #f for disabling
(define (gg-enable-disassembly n state)
  (let ((p (%gg-get-processor n)))
    (gg-dformat "~%MPE ~A enable disassembly ~S" n state)
    (p 'enable-disassembly state)))

; (gg-line-number n addr)
; Return line number information associated with an address
; n is the mpe number
; addr is the address
(define (gg-line-number n addr)
  (let ((p (%gg-get-processor n)))
    (multiple-value-bind (file line count offset)
                         (p 'find-line-number addr #t)
      (gg-dformat "~%MPE ~A line number ~X -> ~S ~S ~S ~S" n addr file line count offset)
      (list file line count offset))))

; (gg-symbol n name)
; Return the address associated with a symbol
; n is the mpe number
; name is the symbol name string
(define (gg-symbol n name)
  (let ((p (%gg-get-processor n)))
     (p 'find-symbol name)))

; interfaces to mpe.lsp

; (%gg-halt p addr reason file line count)
; Called by mpe.lsp when an mpe halts.
(define (%gg-halt p addr reason file line count offset)
  (let ((n (p 'unit-number)))
    (if file
      (gg-halt-on-line n addr reason file line count offset)
      (gg-halt n addr reason))))

; (%gg-select-processor p)
; Called by mpe.lsp when a new processor is selected.
(define (%gg-select-processor p)
  (let ((pc (p 'pc))
        (n (p 'unit-number)))
    (let ((overlay-pc (p 'translate-loaded-overlay-address pc)))
      (when overlay-pc
        (set! pc overlay-pc)))
    (multiple-value-bind (file line count offset)
                         (p 'find-line-number pc #t)
      (if file
        (gg-select-processor-on-line n pc file line count offset)
        (gg-select-processor n pc)))))

; (%gg-set-breakpoint! p addr)
; Set a breakpoint at the specified address.
(define (%gg-set-breakpoint! p addr)
  (let ((n (p 'unit-number)))
    (%gg-announce-line-number p addr gg-set-breakpoint-on-line!)))

; (%gg-clear-breakpoint! p addr)
; Clear a breakpoint at the specified address.
(define (%gg-clear-breakpoint! p addr)
  (let ((n (p 'unit-number)))
    (%gg-announce-line-number p addr gg-clear-breakpoint-on-line!)))

; dummy callbacks

(define (gg-message &rest args)
  (fresh-line)
  (apply format #t args))

(define (gg-running n)
  (format #t "~%MPE ~S running" n))

(define (gg-halt-on-line n addr reason file line count offset)
  (format #t "~%MPE ~S halted, addr: 0x~X, reason: ~S, file: ~S, line: ~S, count: ~S, offset: ~S"
    n addr reason file line count offset))

(define (gg-halt n addr reason)
  (format #t "~%MPE ~S halted, addr: 0x~X, reason: ~S" n addr reason))

(define (gg-select-processor-on-line n addr file line count offset)
  (format #t "~%Select processor ~S, addr: 0x~X, file: ~S, line: ~S, count: ~S, offset: ~S" n addr file line count offset))

(define (gg-select-processor n addr)
  (format #t "~%Select processor ~S, addr: 0x~X" n addr))

(define (gg-set-breakpoint-on-line! n addr file line)
  (format #t "~%MPE ~S set breakpoint, addr: 0x~X, file: ~S, line: ~S"
    n addr file line))

(define (gg-set-breakpoint! n addr)
  (format #t "~%MPE ~S set breakpoint, addr: 0x~X" n addr))

(define (gg-clear-breakpoint-on-line! n addr file line)
  (format #t "~%MPE ~S clear breakpoint, addr: 0x~X, file: ~S, line: ~S"
    n addr file line))

(define (gg-clear-breakpoint! n addr)
  (format #t "~%MPE ~S clear breakpoint, addr: 0x~X" n addr))

(define (gg-refresh n file)
  (format #t "~%MPE ~S refresh ~S" n file))

(define (gg-update-pixel x y color)
  (format #t "~%Update pixel [~S,~S] = 0x~X" x y color))

(define (gg-clear-graphics)
  (format #t "~%Clear graphics"))

(define (gg-report-dma-exception)
  (format #t "~%Report DMA exception"))

(define (gg-browse n id)
  (format #t "~%MPE ~S browse ~S" n id))

(define (gg-browse-clear! n id)
  (format #t "~%MPE ~S browse clear ~S" n id))

(define (gg-browse-entry n parent-id id name value can-open? open? size start end)
  (format #t "~%MPE ~S browse entry, parent-id ~S, id ~S, name ~S, value ~S, can-open? ~S, open? ~S, size ~S, start ~S, end ~S"
          n parent-id id name value can-open? open? size start end))

(define (gg-browse-update n id value)
  (format #t "~%MPE ~S browse update, id ~S, value ~S" n id value))

(define (gg-browse-remove n id)
  (format #t "~%MPE ~S browse remove, id ~S" n id))

(define (gg-watch-display n id name type fmt value)
  (format #t "~%MPE ~S watch display, id ~S, name ~S, type ~S, format ~S, value ~S" n id name type fmt value))

(define (gg-watch-remove n id)
  (format #t "~%MPE ~S watch remove ~S" n id))

(define (gg-define-bitfield name fields)
  (format #t "~%define bitfield ~S ~S" name fields))

; internal routines

(define (%gg-get-processor n)
  (if n
    (*mmp* 'mpe n)
    *mpe*))

(define (%gg-convert-number n)
  (if (string? n)
    (let ((first (char n 0))
          (first2 (if (>= (string-length n) 2) (substring n 0 2) "")))
      (cond ((string-ci=? first2 "#x")
             (read-from-string n))
            ((string-ci=? first2 "0x")
             (read-from-string (string-append "#x" (substring n 2))))
            ((char=? first #\$)
             (read-from-string (string-append "#x" (substring n 1))))
            ((char-numeric? first)
             (read-from-string n))
            (else
             n)))
    n))

(define (%gg-announce-line-number p addr fcn)
  (multiple-value-bind (file line count)
                       (p 'find-source-line-number addr)
    (when file
      (fcn (p 'unit-number) addr file line)))
  (multiple-value-bind (file line count)
                       (p 'find-disassembly-line-number addr)
    (when file
      (fcn (p 'unit-number) addr file line))))

; debug output function
(define (gg-dformat &rest args)
  (when *gg-debugging*
    (apply format #t args)))

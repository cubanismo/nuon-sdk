;; puffintk.lsp

; load the xlisptk files
(load "xlisptk.lsp")

; load the standard puffin files
(load "puffin.lsp")

; load the user customization file
(load "user2k.lsp")

; start the gui
(tcl-load "puffintk.tcl")

(define (message-box text)
  (let ((w (tk-toplevel text)))
    (let ((label (tk-label w :text text))
          (ok (tk-button w :text "OK"
                           :command tk-set-modal-trigger!)))
      (tk-pack label)
      (tk-pack ok)
      (ok 'focus)
      (w 'modal)
      (tk-destroy w)
      #t)))

(define (text-input-box text)
  (let ((w (tk-toplevel text)))
    (let ((label (tk-label w :text text))
          (entry (tk-entry w))
          (frame (tk-frame w))
          (result #f))
      (let ((cancel
             (tk-button frame :text "Cancel"
                              :command tk-set-modal-trigger!))
            (ok
             (tk-button frame :text "OK"
                              :command (lambda ()
                                         (tk-set-modal-trigger!)
                                         (set! result #t)))))
        (tk-pack cancel :side "left" :expand "yes")
        (tk-pack ok :side "left" :expand "yes")
        (tk-pack label)
        (tk-pack entry)
        (tk-pack frame)
        (entry 'focus)
        (w 'modal)
        (let ((input-text (entry 'get)))
          (tk-destroy w)
          (and result input-text))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GG CALLBACKS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (gg-message &rest args)
  (fresh-line)
  (apply format #t args)
  (flush-output)
  (tcl "update"))

(define (gg-halt n addr reason)
(gg-dformat "~%MPE ~S halt: addr ~X, reason ~S" n addr reason)
  (gg-request-watch-forms n)
  (gg-browse-refresh n)
  (tcl "halt " (tcl-quote n) " "
               (tcl-quote addr) " "
               (tcl-quote reason)))

(define (gg-halt-on-line n addr reason file line count offset)
(gg-dformat "~%MPE ~S halt: addr ~X, reason ~S, file ~S, line ~S, count ~S, offset ~S" n addr reason file line count offset)
  (gg-request-watch-forms n)
  (gg-browse-refresh n)
  (tcl "updateSourceWindow " (tcl-quote n) " "
                             (tcl-quote addr) " "
                             (tcl-quote reason) " "
                             (tcl-quote file) " "
                             (tcl-quote line) " "
                             (tcl-quote count)))

(define (gg-set-breakpoint-on-line! n addr file line)
(gg-dformat "~%MPE ~S set breakpoint: addr ~X. file ~S, line ~S" n addr file line)
  (tcl "setBP " (tcl-quote n) " "
                (tcl-quote addr) " "
                (tcl-quote file) " "
                (tcl-quote line)))

(define (gg-clear-breakpoint-on-line! n addr file line)
(gg-dformat "~%MPE ~S clear breakpoint: addr ~X, file ~S, line ~S" n addr file line)
  (tcl "clearBP " (tcl-quote n) " "
                  (tcl-quote addr) " "
                  (tcl-quote file) " "
                  (tcl-quote line)))

(define (gg-refresh n file)
(gg-dformat "~%MPE ~S refresh ~S" n file)
  (tcl "mpeRefresh " (tcl-quote n) " "
                     (tcl-quote file)))

(define (gg-browse n id)
(gg-dformat "~%MPE ~S browse ~S" n id)
  (tcl "varBrowse " (tcl-quote n) " "
                    (tcl-quote id)))

(define (gg-browse-entry n parent-id id name addr value can-open? open? size start end)
(gg-dformat "~%MPE ~S browse entry, parent-id ~S, id ~S, name ~S, addr ~S, value ~S, can-open? ~S, open? ~S, size ~S, start ~S, end ~S"
         n parent-id id name addr value can-open? open? size start end)
  (tcl "varBrowseEntry " (tcl-quote n) " "
			 (tcl-quote parent-id) " "
                         (tcl-quote id) " {"
                         (tcl-quote name) "} "
			 (tcl-quote addr) " "
                         (tcl-quote value) " "
                         (tcl-quote can-open?) " "
                         (tcl-quote size) " "
                         (tcl-quote start) " "
                         (tcl-quote end)))

(define (gg-browse-update n id value)
(gg-dformat "~%MPE ~S browse update, id ~S, value ~S" n id value)
  (tcl "varBrowseUpdate " (tcl-quote n) " "
			  (tcl-quote id) " "
			  (tcl-quote value)))

(define (gg-browse-remove n id)
(gg-dformat "~%MPE ~S browse remove, id ~S" n id)
  (tcl "varBrowseRemove " (tcl-quote n) " "
			  (tcl-quote id)))


(define (gg-watch-display n id name type fmt value)
(gg-dformat "~%MPE ~S watch display ~S ~S ~S ~S ~S" n id name type fmt value)
  (tcl "watchUpdate " (tcl-quote n) " "
                      (tcl-quote id) " "
                      (tcl-quote name) " "
                      (tcl-quote type) " "
                      (tcl-quote fmt) " "
                      (tcl-quote value)))

(define (gg-define-bitfield name fields)
  (tcl "SetRegisterBitfield " (tcl-quote name) " "
                              "{" (tcl-quote-list fields) "}"))

(define (gg-browse-clear! n id)
(gg-dformat "~%MPE ~S browse clear ~S" n id)
  (tcl "varBrowseClear " (tcl-quote n) " "
                    (tcl-quote id)))

(define (gg-running n)
(gg-dformat "~%MPE ~S running" n)
  (tcl "mpeStartsRunning " (tcl-quote n)))

; start the debugger
(start-debugger)

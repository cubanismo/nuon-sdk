;;;;
;;;; EASY XLISP/TK WIDGET LIBRARY
;;;; by VM Labs
;;;;


(define dummy-tk-variable (tk-variable% 'new))
(dummy-tk-variable 'set-value! 0)

;;; C-WIDGET

(define-class c-widget
  (instance-variables
    i-parent
    i-tag
    i-tk-widget))

(define-method (c-widget 'initialize &key parent tag)
  (when parent
    (parent 'add-child self)
    (set! i-tag tag)
    (set! i-parent parent))
  self)

(define-method (c-widget 'tk-widget)
  i-tk-widget)

(define-method (c-widget 'get-value)
  (i-tk-widget 'get-value))

(define-method (c-widget 'set-value! v)
  (i-tk-widget 'set-value! v)
  self)

(define-method (c-widget 'tag) i-tag)

(define-method (c-widget 'get-parent) i-parent)

(define-method (c-widget 'configure-all &rest args)
    (apply self 'configure args)
)

(define-method (c-widget 'configure &rest args)
    (apply i-tk-widget 'configure args)
)


;; MAKE-TK-VARIABLE

(define (make-tk-variable) 
	(tk-variable% 'new))


;;; C-CONTAINER

(define-class c-container
  (superclass c-widget)
  (instance-variables
    i-children))

(define-method (c-container 'initialize &key parent tag)
  (super 'initialize :parent parent :tag tag)
  (set! i-children '())
  self)

(define-method (c-container 'add-child child)
  (set! i-children (cons child i-children))
  (set! parent (self 'get-parent))
  (when parent
	  (parent 'add-child child))
  self)

(define-method (c-container 'get-value)
  (map (lambda (w) (w 'tag-value)) i-children))

(define-method (c-container 'get-children-alist)
    (map (lambda (w) (cons (w 'tag) w)) i-children)
)

(define-method (c-container 'get-child tag)
    (cdr (assoc tag (self 'get-children-alist)))
)

(define-method (c-container 'configure-all &rest args)
    (apply self 'configure args)
    (for-each (lambda (w) (apply w 'configure-all args)) i-children)
)


;;; C-FRAME

(define (make-frame &rest args)
  (apply c-frame 'new args))

(define-class c-frame
  (superclass c-container))

(define-method (c-frame 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 
			(border 1)
			(relief 'sunken) 
			(width 0) 
			(height 0)
			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne))

  (super 'initialize :tag tag :parent parent)

  (set! i-tk-widget (tk-frame (parent 'tk-widget)
			      :width width
			      :height height
			      :relief relief
                              :border border))

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	(tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))
  self)

; -> added so frames children get reported..
(define-method (c-frame 'tag-value) 
  (cons (self 'tag) (self 'get-value)))

(define-method (c-frame 'get-value) ())


;;; C-DIALOG-BOX

(define (make-dialog-box &rest args)
  (apply c-dialog-box 'new args))

(define-class c-dialog-box
  (superclass c-container))

(define-method (c-dialog-box 'initialize &key title)
  (super 'initialize :parent #f)
  (set! i-tk-widget (tk-toplevel title))
  self)


;;; C-CONTROL

(define-class c-control
  (superclass c-widget)
  (instance-variables
    i-tag))

(define-method (c-control 'initialize &key tag parent)
  (super 'initialize :parent parent)
  (set! i-tag tag)
  self)

(define-method (c-control 'tag-value)
  (cons i-tag (self 'get-value)))

(define-method (c-control 'tag) i-tag)



;;; C-CONTROL-FRAME


(define (make-control-frame &rest args)
  (apply c-frame 'new args))

(define-class c-control-frame
  (superclass c-container)
  (instance-variables
    i-tag))

(define-method (c-control-frame 'initialize &key tag parent
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 
			(border 1)
			(relief 'sunken) 
			(width 0) 
			(height 0)
			grid 
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne))
  (super 'initialize :tag tag :parent parent)
  (set! i-tag tag)

  (set! i-tk-widget (tk-frame (parent 'tk-widget)
			      :width width
			      :height height
			      :relief relief
                              :border border))

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	(tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))
  self)

(define-method (c-control-frame 'tag-value)
  (cons i-tag (self 'get-value)))

(define-method (c-control-frame 'tag) i-tag)


;;; C-SCALE

(define (make-scale &rest args)
  (apply c-scale 'new args))

(define-class c-scale
  (superclass c-control)
  (instance-variables
    i-variable))

(define-method (c-scale 'initialize &key tag parent label 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0)

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			width
			length
			sliderlength
			(variable (tk-variable% 'new))
			(orient "horizontal")
			initial-value from to handler)
  (super 'initialize :tag tag :parent parent)
  (set! i-variable variable) 



  (set! i-tk-widget
		(tk-scale (parent 'tk-widget)
                              :from from
                              :to to
                              :showvalue "true"
                              :orient orient
                              :label label
			      :length length
			      :sliderlength sliderlength
			      :width width
			      :variable variable
                              :command handler))



  (when initial-value
    (i-tk-widget 'set-value! initial-value))

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	 (tk-pack i-tk-widget :side side :anchor anchor :fill fill :expand expand
			:padx padx :pady pady :ipadx ipadx  :ipady ipady))


  (set! font-name (tcl (i-tk-widget 'tk-name) " configure -font"))
  (set! i (tcl "string last " (tcl-quote "{") " " (tcl-quote font-name)))
  (set! font-name (tcl "string range " (tcl-quote font-name) " " i " end"))
  (set! font-name (tcl "string trimright " (tcl-quote font-name) " " (tcl-quote "}")))
  (set! string-width (tcl "font measure " (tcl-quote font-name) " " (tcl-quote label)))

  (set! w (tcl "winfo reqwidth " (i-tk-widget 'tk-name)))

  (when (< (string->number w) (string->number string-width))
	  (i-tk-widget 'configure :length string-width))
  self)

(define-method (c-scale 'set-value! value)
    (i-tk-widget 'set-value! value)
)
(define-method (c-scale 'get-value)
    (i-tk-widget 'get-value)
)


;;; C-SCALE-WITH-BUTTONS

(define (make-scale-with-buttons &rest args)
  (apply c-scale-with-buttons 'new args))

(define-class c-scale-with-buttons
  (superclass c-control)
  (instance-variables
    i-tk-frame-widget
    i-tk-scale-widget))

(define-method (c-scale-with-buttons 'initialize &key tag parent label 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0)

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			width
			length
			sliderlength
			variable
			(orient "horizontal")
			initial-value from to handler)

  (super 'initialize :tag tag :parent parent)
  (set! i-tk-frame-widget (make-frame
        :tag tag 
        :parent parent
	:anchor anchor :side side :fill fill :expand expand :padx padx :pady pady
	:ipadx ipadx :ipady ipady))

  (make-button :tag (string->symbol (format #f "~S_button_L" tag)) :parent i-tk-frame-widget :padx 1 :ipadx 1 :text "<" :button-padx -4 :button-pady -4 :side 'left :anchor 'se :handler (lambda () (self 'left-button)))
   
  (set! i-tk-scale-widget
	(if variable
		(make-scale   :tag (string->symbol (format #f "~S_scale" tag))
			      :parent i-tk-frame-widget
			      :padx 0
			      :ipadx 0
			      :pady 1
			      :ipady 1
			      :side 'left
                              :from from
                              :to to
                              :showvalue "true"
                              :orient orient
                              :label label
			      :length length
			      :sliderlength sliderlength
			      :width width
			      :variable variable
                              :handler handler)
		(make-scale   :tag (string->symbol (format #f "~S_scale" tag))
			      :parent i-tk-frame-widget
			      :padx 0
			      :ipadx 0
			      :pady 1
			      :ipady 1
			      :side 'left
                              :from from
                              :to to
                              :showvalue "true"
                              :orient orient
                              :label label
			      :length length
			      :sliderlength sliderlength
			      :width width
                              :handler handler)))


  (make-button :tag (string->symbol (format #f "~S_button_R" tag)) :parent i-tk-frame-widget :padx 1 :ipadx 1 :text ">" :button-padx -4 :button-pady -4 :side 'right :anchor 'sw :handler (lambda () (self 'right-button)))
  (when initial-value
    (i-tk-scale-widget 'set-value! initial-value))

  self)

(define-method (c-scale-with-buttons 'set-value! value)
    (i-tk-scale-widget 'set-value! value))

(define-method (c-scale-with-buttons 'get-value)
    (i-tk-scale-widget 'get-value))

(define-method (c-scale-with-buttons 'right-button)
     (set! value (i-tk-scale-widget 'get-value))
     (set! value (+ value 1))
     (i-tk-scale-widget 'set-value! value))

(define-method (c-scale-with-buttons 'left-button)
     (set! value (i-tk-scale-widget 'get-value))
     (set! value (- value 1))
     (i-tk-scale-widget 'set-value! value))


;;; C-SCROLLBAR

(define (make-scrollbar &rest args)
  (apply c-scrollbar 'new args))

(define-class c-scrollbar
  (superclass c-control))

(define-method (c-scrollbar 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0)

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			(orient 'vertical)
			scrollx scrolly)

  (super 'initialize :tag tag :parent parent)

  (set! i-tk-widget
    (if scrollx
      (tk-scrollbar (parent 'tk-widget) :orient orient :scrollx scrollx)
      (tk-scrollbar (parent 'tk-widget) :orient orient :scrolly scrolly)))

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	  (tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))
  self)

; fix it:
(define-method (c-scrollbar 'get-value)
	())


;;; C-POPUP-MENU

(define (make-popup-menu &rest args)
  (apply c-popup-menu 'new args))
        
(define-class c-popup-menu
  (superclass c-control)
  (instance-variables
    i-label-list))

(define-method (c-popup-menu 'initialize tag parent label initial-value label-list)
  (superclass 'initialize :tag tag :parent parent)
  (set! i-label-list label-list)
  self)



;;; C-LABEL

(define (make-label &rest args)
  (apply c-label 'new args))

(define-class c-label
  (superclass c-control))

(define-method (c-label 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			font
			fg
			bg
			(justify 'left)
			width
			height
			relief
			(text "")
			variable)
  (super 'initialize :tag tag :parent parent)

    (set! i-tk-widget 
        (if variable
            (tk-label (parent 'tk-widget) :textvar variable :anchor anchor :width width
		:height height :font font :fg fg :justify justify :relief relief)
            (tk-label (parent 'tk-widget) :text text :anchor anchor :width width
		:height height :font font :fg fg :justify justify :relief relief)
        )
    )

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	  (tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))
  self)

(define-method (c-label 'get-value)
	())
;;;;

;;; C-RADIO-BUTTON

(define (make-radio-button &rest args)
  (apply c-radio-button 'new args))

(define-class c-radio-button
  (superclass c-control)
  (instance-variables
    i-variable))

(define-method (c-radio-button 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 2) 
			(pady 2)
			(ipadx 0) 
			(ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			font
			fg
			bg
			justify
			width
			height
			(text "")
			(value "1")
                        (variable (tk-variable% 'new))
		        (handler (lambda () (format #t "~%Default Radio Button Handler"))))


  (super 'initialize :tag tag :parent parent)
  (set! i-variable variable)

  (set! i-tk-widget (tk-radiobutton (parent 'tk-widget)
			            :value value
                                    :text text
				    :font font
				    :fg fg
				    :bg bg
				    :width width	
				    :height height
				    :justify justify
                                    :variable variable
                                    :command handler))

   (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	  (tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))
  self)


(define-method (c-radio-button 'set-value! value)
  (i-variable 'set-value! value)
  self)

(define-method (c-radio-button 'get-value)
    (i-variable 'get-value))


;;; C-RADIO-BUTTON-GROUP

(define (make-radio-button-group &rest args)
  (apply c-radio-button-group 'new args))
    
(define-class c-radio-button-group
  (superclass c-frame)
  (instance-variables
    i-variable
    i-value-list
    i-handler))


(define-method (c-radio-button-group 'initialize &key 
		tag parent 
		label-list 
		value-list 
		initial-value
	        label
		(anchor 'n)  
		(side 'top) 
		(fill 'none) 
		(expand 'no)
		(padx 2) 
		(pady 2)
		(ipadx 0) 
		(ipady 0) 
		(border 1)
		(relief 'sunken)
		(sub-anchor 'w)
		(sub-side 'top)
		(sub-padx 0) 
		(sub-pady 0)
		(sub-ipadx 0) 
		(sub-ipady 0) 

		font
		fg
		bg
		justify
		width
		height

		(handler (lambda (v) (format #t "~%Default Radio Button Handler. Value: ~S." v))))

  (super 'initialize 
        :tag tag 
        :parent parent
		:anchor anchor :side side :fill fill :expand expand :padx padx :pady pady
		:ipadx ipadx :ipady ipady :border border :relief relief)

  (set! i-variable (tk-variable% 'new))
  (set! i-handler handler)
  (set! i-value-list value-list)


  (when label
    (make-label
        :parent self
        :tag (string->symbol (format #f "~S_label" tag))
        :anchor sub-anchor
        :side   sub-side
        :padx   sub-padx
        :pady   sub-pady
        :ipadx  sub-ipadx
        :ipady  sub-ipady
        :text   label
    )
  )


   (let loop ((n 0) (label-li label-list) (value-li value-list))
    (when label-li
       (make-radio-button 
            :tag (string->symbol (format #f "~S_button_~S" tag n))
            :parent self
            :text (car label-li) 
            :value n
            :variable i-variable 
            :anchor sub-anchor 
            :side sub-side
            :padx sub-padx
            :pady sub-pady
            :ipadx sub-ipadx
            :ipady sub-ipady
	    :fg fg
	    :bg bg
	    :justify justify
	    :font font
	    :width width
	    :height height
            :handler (lambda () (i-handler (self 'get-value)))
       )
       (loop (+ 1 n) (cdr label-li) (cdr value-li))))

  (when initial-value
	  (self 'set-value! initial-value))

  self)


(define-method (c-radio-button-group 'get-value)
  (set! index (i-variable 'get-value))
  (set! n (string->number index))
  (list-ref i-value-list n))

(define-method (c-radio-button-group 'set-value! v)
  (set! n 0)
  (let loop ((value-li i-value-list))
	(if value-li
		(when (NOT (EQUAL? (car value-li) v))
			(set! n (+ n 1))
			(loop (cdr value-li)))
		(set! n 0)))
  (i-variable 'set-value! n)
  self)

;;; C-CHECK-BUTTON

(define (make-check-button &rest args)
  (apply c-check-button 'new args))

(define-class c-check-button
  (superclass c-control)
  (instance-variables
    i-variable))

(define-method (c-check-button 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 2) 
			(pady 2)
			(ipadx 0) 
			(ipady 0)

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)
 
			fg 
			bg
			font
			justify
			width
			height		
			(text "")
	                (variable (tk-variable% 'new))
			(handler (lambda () (format #t "~%Default Check Button Handler"))))

  (super 'initialize :tag tag :parent parent)
  (set! i-variable variable)
  (set! i-tk-widget
        (tk-checkbutton
            (parent 'tk-widget)
	    :fg fg
	    :bg bg
	    :font font
	    :justify justify
	    :width width
	    :height height
            :text text
            :command handler
   	    :variable i-variable
        )
    )

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	  (tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))

  self)

(define-method (c-check-button 'set-value! value)
  (i-variable 'set-value! value)
  self)

(define-method (c-check-button 'get-value)
    (i-variable 'get-value))

;;; C-CHECK-BUTTON-GROUP

(define (make-check-button-group &rest args)
  (apply c-check-button-group 'new args))
    
(define-class c-check-button-group
  (superclass c-frame)
  (instance-variables
    i-n
    i-tk-check-widget
    i-label-list
    i-variable-list))


(define-method (c-check-button-group 'initialize &key 
		tag parent 
		label-list 
		variable-list
	        label
		initial-value
		(anchor 'n)  
		(side 'top) 
		(fill 'none) 
		(expand 'no)
		(padx 2) 
		(pady 2)
		(ipadx 0) 
		(ipady 0) 
		(border 1)
		(relief 'sunken)
		(sub-anchor 'w)
		(sub-side 'top)
		(sub-padx 0) 
		(sub-pady 0)
		(sub-ipadx 0) 
		(sub-ipady 0) 
	
		fg 
		bg
		font
		justify
		width
		height

		(handler (lambda (n v) (format #t "~%Default Check Button Handler. Button: ~S Value: ~S." n v))))

  (super 'initialize 
        :tag tag 
        :parent parent
		:anchor anchor :side side :fill fill :expand expand :padx padx :pady pady
		:ipadx ipadx :ipady ipady :border border :relief relief)

  (set! i-handler handler)
  (set! i-label-list label-list)
  (set! i-variable-list variable-list)
  (set! i-n 0)

  (when label
    (make-label
        :parent self
        :tag (string->symbol (format #f "~S_label" tag))
        :anchor sub-anchor
        :side   sub-side
        :padx   sub-padx
        :pady   sub-pady
        :ipadx  sub-ipadx
        :ipady  sub-ipady
	:fg fg
	:bg bg
	:font font
	:justify justify
        :text   label
    )
  )
  
  (when (NULL? variable-list)
   (let loop ((label-li label-list))
    (when label-li	
	(set! i-variable-list (cons (tk-variable% 'new) i-variable-list))
	(loop (cdr label-li)))))

   (set! variable-list i-variable-list)

   (let loop ((n 0) (label-li label-list) (variable-li variable-list))
    (when label-li
       (set! i-n (+ i-n 1))
       (make-check-button 
            :tag (string->symbol (format #f "~S_button_~S" tag n))
            :parent self
            :text (car label-li) 
            :variable (car variable-li)
            :anchor sub-anchor 
            :side sub-side
            :padx sub-padx
            :pady sub-pady
            :ipadx sub-ipadx
            :ipady sub-ipady
	    :fg fg
	    :bg bg
	    :font font
	    :justify justify
	    :width width
	    :height height
            :handler (lambda () (i-handler n (STRING=? ((car variable-li) 'get-value) "1")))
       )
       (loop (+ 1 n) (cdr label-li) (cdr variable-li))))

  (when initial-value
	(self 'set-value! initial-value))
  self)


(define-method (c-check-button-group 'get-nth-box index)
  (set! var (list-ref i-variable-list index))
  (STRING=? (var 'get-value) "1"))

(define-method (c-check-button-group 'set-nth-box index)
   (set! var (list-ref i-variable-list index))
   (var 'set-value! "1")
  #t)  

(define-method (c-check-button-group 'clear-nth-box index)
  (set! var (list-ref i-variable-list index))
  (var 'set-value! "0") 
 #f)  

(define-method (c-check-button-group 'toggle-nth-box index)
  (set! var (list-ref i-variable-list index))
  (set! r #f)
  (if (STRING=? (var 'get-value) "1")
	(begin (set! r #f) (var 'set-value! "0"))
	(begin (set! r #t) (var 'set-value! "1")))
  r)

(define-method (c-check-button-group 'get-value)
	(set! vector (make-vector i-n))
	(set! n 0)
	(while (< n i-n) 
		(if (self 'get-nth-box n)
			(vector-set! vector n #t)
			(vector-set! vector n #f))
		(set! n (+ n 1)))
	vector)


(define-method (c-check-button-group 'set-value! vector)
	(set! n 0)
	(while (< n i-n) 
		(if (vector-get vector n)
			(self 'set-nth-box n)
			(clear 'set-nth-box n))
		(set! n (+ n 1)))
	vector)



;;; C-BUTTON

(define (make-button &rest args)
  (apply c-button 'new args))

(define-class c-button
  (superclass c-control))

(define-method (c-button 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 4) 
			(pady 4)
			(ipadx 0) 
			(ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			button-padx
			button-pady

			fg
			bg
			font
			image
			justify
			width 
			height
			(text " ")
			(handler (lambda () (format #t "~%Default Button Handler"))))

  (super 'initialize :tag tag :parent parent)

  


  (if image
     (begin (set! img (tk-photo :file image))
     (set! i-tk-widget (tk-button (parent 'tk-widget)
				:width width
				:height height
				:justify justify
				:bg bg
				:fg fg
				:font font
				:image img
				:padx button-padx
				:pady button-pady
		   		:command handler)))
     (set! i-tk-widget (tk-button (parent 'tk-widget)
				:width width
				:height height
				:justify justify
				:bg bg
				:fg fg
				:font font
   	                        :text text
				:padx button-padx
				:pady button-pady
		   		:command handler)))

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	  (tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))
  self)

(define-method (c-button 'get-value)
	())


;;; C-ENTRY

(define (make-entry &rest args)
  (apply c-entry 'new args))

(define-class c-entry
  (superclass c-control))

(define-method (c-entry 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 
			(sub-anchor 'w)
			(sub-side 'top)
			(sub-padx 0) 
			(sub-pady 0)
			(sub-ipadx 0) 
			(sub-ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			fg
			bg
			font
			justify
			width 
			(variable (tk-variable% 'new))
			wrap
			(text ""))
  (super 'initialize :tag tag :parent parent)


;  (when text
;   (make-label
;        :parent self
;        :tag (string->symbol (format #f "~S_label" tag))
;        :anchor sub-anchor
;        :side   sub-side
;        :padx   sub-padx
;        :pady   sub-pady
;        :ipadx  sub-ipadx
;        :ipady  sub-ipady
;        :text   text
;    ))

  (if variable
	  (set! i-tk-widget (tk-entry  (parent 'tk-widget)
				:fg fg
				:bg bg
				:font font
				:justify justify
				:width width
				:wrap wrap
				:variable variable
                              :text text))
	  (set! i-tk-widget (tk-entry (parent 'tk-widget)
				:fg fg
				:bg bg
				:font font
				:justify justify
				:width width
				:wrap wrap
                              :text text)))


  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	  (tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))

  self)

(define-method (c-entry 'get-value)
  (i-tk-widget 'get))

(define-method (c-entry 'set-value! entry)
  (i-tk-widget 'delete 0 'end)
  (i-tk-widget 'insert 0 entry))





;;; C-ENTRY2

(define (make-entry-box &rest args)
  (apply c-entry-box 'new args))

(define-class c-entry-box
  (superclass c-control-frame))

(define-method (c-entry-box 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 
			(sub-anchor 'w)
			(sub-side 'top)
			(sub-padx 0) 
			(sub-pady 0)
			(sub-ipadx 0) 
			(sub-ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			fg
			bg
			(border 0)
			font
			justify
			width 
			(variable (tk-variable% 'new))
			wrap
			(text ""))
  (super 'initialize :tag tag :parent parent :border border
		:anchor anchor :side side :fill fill :expand expand :padx padx :pady pady
		:ipadx ipadx :ipady ipady )


  (when text
   (make-label
        :parent self
        :tag (string->symbol (format #f "~S_label" tag))
        :anchor 'nw 	; sub-anchor
        :side   'left 	; sub-side
        :padx   sub-padx
        :pady   sub-pady
        :ipadx  sub-ipadx
        :ipady  sub-ipady
        :text   text
    ))

     (set! i-tk-widget (tk-entry (self 'tk-widget)
				:tag (string->symbol (format #f "~S_entry" tag))
				:fg fg
				:bg bg
				:font font
				:justify justify
				:width width
				:wrap wrap
				:variable variable
                              :text text))

	  (tk-pack i-tk-widget  :anchor 'nw :side 'left :fill 'y :expand '1         
		:padx   sub-padx
	        :pady   sub-pady
	        :ipadx  sub-ipadx
        	:ipady  sub-ipady)


  self)

(define-method (c-entry-box 'get-value)
  (i-tk-widget 'get))

(define-method (c-entry-box 'set-value! entry)
  (i-tk-widget 'delete 0 'end)
  (i-tk-widget 'insert 0 entry))

;;; C-TEXT

(define (make-text &rest args)
  (apply c-text 'new args))

(define-class c-text
  (superclass c-control))

(define-method (c-text 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			(text ""))
  (super 'initialize :tag tag :parent parent)
  (set! i-tk-widget (tk-text (parent 'tk-widget)
                              :text text))

(define-method (c-text 'entry)
  (i-tk-widget 'get))

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	  (tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))
  self)




;;; C-LISTBOX

(define (make-listbox &rest args)
  (apply c-listbox 'new args))

(define-class c-listbox
  (superclass c-control)
  (instance-variables
    i-value-list
    i-item-list
    i-current-index
    i-handler))

(define-method (c-listbox 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			fg
			bg
			font
			width 
			height

			xscrollbar
			yscrollbar
			
			initial-value
			value-list
			item-list
			(handler (lambda (v) (format #t "~%Default List Box Handler. Value: . ~S" v))))
  (super 'initialize :tag tag :parent parent)

  (set! i-value-list value-list)
  (set! i-item-list item-list)
  (set! i-handler handler)
  (set! i-tk-widget (tk-listbox (parent 'tk-widget)
				:fg fg
				:bg bg
				:font font
				:width width
				:height height
				:selectMode 'single
				:yscrollbar yscrollbar
				:command (lambda () (self 'select-cb))
                 	))


   (let loop ((n 0) (item-li item-list))
    (when item-li
		(i-tk-widget 'insert n (car item-li))
       (loop (+ 1 n) (cdr item-li))))

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	  (tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))
  (set! i-current-index 0)
  (when initial-value
	  (self 'set-value! initial-value))

  self)


(define-method (c-listbox 'insert index item &key value)
 (set! new-list ())
 (when i-value-list
	(let loop ((n 0) (value-li i-value-list))
		(when value-li
			(when (= n index)
				(set! element (list value))
				(set! new-list (append new-list element)))
			(set! element (list (car value-li)))
			(set! new-list (append new-list element))
		(loop (+ 1 n) (cdr value-li))))
        (set! i-value-list new-list))
 (set! new-list ())
  (when i-item-list
	(let loop ((n 0) (item-li i-item-list))
		(when item-li
			(when (= n index)
				(set! element (list item))
				(set! new-list (append new-list element)))
			(set! element (list element (car item-li)))
			(set! new-list (append new-list element))
		(loop (+ 1 n) (cdr item-li))))
        (set! i-item-list new-list))

  (i-tk-widget 'insert index item)
i-item-list)

(define-method (c-listbox 'delete index)
  (i-tk-widget 'delete index))

(define-method (c-listbox 'select-cb)
  (set! i-current-index (string->number (i-tk-widget 'get-value)))
  (i-handler (self 'get-value))
)



(define-method (c-listbox 'get-value)
  (set! index i-current-index)
  (if i-value-list
	(set! r (list-ref i-value-list index))
	(set! r index))
  r)


(define-method (c-listbox 'get-value-index)
 i-current-index)

(define-method (c-listbox 'set-value! v)
  (if i-value-list
	(begin
	  (set! n 0)
	  (let loop ((value-li i-value-list))
		(when value-li
			(when (NOT (EQUAL? (car value-li) v))
				(set! n (+ n 1))
				(loop (cdr value-li)))))
;			(set! n 0)))
   	  (set! i-current-index n)
	  (i-tk-widget 'set-value! n))
	  
       (i-tk-widget 'set-value! v))
  self)



(define-method (c-listbox 'set-value-index! index)
  (i-tk-widget 'set-value! index))

(define-method (c-listbox 'yview index)
  (i-tk-widget 'yview index))




;;; C-LISTBOX-WITH-SLIDER

(define (make-listbox-with-slider &rest args)
  (apply c-listbox-with-slider 'new args))

(define-class c-listbox-with-slider
  (superclass c-frame)
  (instance-variables
    i-tk-list-widget
    i-tk-scrollbar-widget
    i-handler))

(define-method (c-listbox-with-slider 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			fg
			bg
			font
			width 
			height

			(selectMode 'single)
			initial-value
			item-list
			(handler (lambda (v) (format #t "~%Default List Box Handler. Value: . ~S" v))))
  (super 'initialize :tag tag :parent parent :border 0)
  (set! i-handler handler)

  (set! i-tk-list-widget (make-listbox   :tag (string->symbol (format #f "~S_list" tag))
				:parent self
				:side 'left
				:fg fg
				:bg bg
				:font font
				:width width
				:height height
				:initial-value initial-value
				:item-list item-list
				:selectMode selectMode
				:handler i-handler
                 	))
	(set! i-tk-scrollbar-widget (make-scrollbar :tag (string->symbol (format #f "~S_slider" tag))
				:parent self
				:fg fg
				:bg bg
				:expand 'yes
				:fill 'y
				:side 'right :anchor 'nw
				:scrolly (i-tk-list-widget 'tk-widget)))


	(i-tk-list-widget 'configure :yscrollbar (i-tk-scrollbar-widget 'tk-widget))
	(when initial-value
		(i-tk-list-widget 'yview initial-value))
  self)


(define-method (c-listbox-with-slider 'insert index item)
  (i-tk-list-widget 'insert index item))

(define-method (c-listbox-with-slider 'delete index)
  (i-tk-list-widget 'delete index))

(define-method (c-listbox-with-slider 'get-value)
  (string->number (i-tk-list-widget 'get-value )))

(define-method (c-listbox-with-slider 'set-value! index)
  (i-tk-widget 'set-value! index))

;;;

(define (make-list-selection-box &rest args)
  (apply c-list-selection-box 'new args))

(define-class c-list-selection-box
  (superclass c-frame)
  (instance-variables
    i-tk-list-widget
    i-tk-label-widget
    i-tk-value-widget
    i-tk-innerframe-widget
    i-tk-scrollbar-widget
    i-value-variable
    i-item-list
    i-handler))

(define-method (c-list-selection-box 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			fg
			bg
			font
			width 
			(height 3)

			text
			
			(selectMode 'single)
			initial-value
			value-list
			item-list
			(handler (lambda (v) (format #t "~%Default List Box Handler. Value: . ~S" v))))
  (super 'initialize :tag tag :parent parent :border 1)
  (set! i-handler handler)
  (set! i-item-list item-list)

  (set! d-frame (make-frame :tag (string->symbol (format #f "~S_frame" tag)) :parent self :border 0 :side 'bottom))

  (set! i-tk-list-widget (make-listbox   :tag (string->symbol (format #f "~S_list" tag))
				:parent d-frame
				:side 'left
				:anchor 'w
				:fg fg
				:bg bg
				:font font
				:width width
				:height height
				:initial-value initial-value
				:item-list item-list
				:value-list value-list
				:selectMode selectMode
				:handler (lambda (v) (self 'select-cb v))
                 	))

	
	(set! i-tk-scrollbar-widget (make-scrollbar :tag (string->symbol (format #f "~S_slider" tag))
				:parent d-frame
				:fg fg
				:bg bg
				:expand 'yes
				:fill 'y
				:side 'right :anchor 'e
				:scrolly (i-tk-list-widget 'tk-widget)))


   (i-tk-list-widget 'configure :yscrollbar (i-tk-scrollbar-widget 'tk-widget))

  (set! i-value-variable (tk-variable% 'new))
;  (i-value-variable 'set-value! (list-ref i-item-list initial-value))

  (set! i-tk-label-widget (make-label :tag (string->symbol (format #f "~S_label" tag)) :parent self :padx 1 :ipadx 1 :text text :side 'left :anchor 'nw))
  (set! i-tk-innerframe-widget (make-frame :tag (string->symbol (format #f "~S_innerframe" tag)) :parent self :padx 2 :ipadx 2 :side 'left :anchor 'nw :relief 'sunken :fill 'x :expand 'yes))
  (set! i-tk-value-widget (make-label :tag (string->symbol (format #f "~S_value" tag)) :parent i-tk-innerframe-widget :padx 1 :ipadx 1  :side 'left :anchor 'n  :variable i-value-variable :justify 'left))

	(when initial-value
		(self 'set-value! initial-value))
  self)


(define-method (c-list-selection-box 'insert index item &key value)
  (i-tk-list-widget 'insert index item :value value))

(define-method (c-list-selection-box 'delete index)
  (i-tk-list-widget 'delete index))



(define-method (c-list-selection-box 'get-value)
 (i-tk-list-widget 'get-value ))


(define-method (c-list-selection-box 'get-value-index)
 (i-tk-list-widget 'get-value-index ))

(define-method (c-list-selection-box 'set-value! value)
  (i-tk-list-widget 'set-value! value)
  (set! index (self 'get-value-index))
  (i-value-variable 'set-value! (list-ref i-item-list index))
  (i-tk-list-widget 'yview index)
  self)

(define-method (c-list-selection-box 'select-cb v)
  (set! n (self 'get-value-index))
  (i-value-variable 'set-value! (list-ref i-item-list n))
  (lambda () (i-handler v))
)

;;; c-message-box


(define (make-message-box &rest args)
  (apply c-message-box 'new args))

(define-class c-message-box)

(define-method (c-message-box 'initialize &key (message "TK-Message Box") (title "Message Box") (icon 'info) (type 'ok))

  (tk-message-box :message message :title title :icon icon :type type)
  self)





;;; C-OPTION-MENU

(define (make-option-menu &rest args)
  (apply c-option-menu 'new args))

(define-class c-option-menu
  (superclass c-control)
  (instance-variables
    i-variable
    i-item-list
    i-tk-frame-widget
    i-tk-label-widget
    i-tk-value-widget
    i-tk-button-widget
    i-tk-menu-widget))

(define-method (c-option-menu 'initialize &key tag parent label 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0)

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)

			text
			width
			item-list
			initial-value
			(variable (tk-variable% 'new))
			handler)

  (super 'initialize :tag tag :parent parent)

  (set! i-tk-frame-widget (make-frame
        :tag tag 
        :parent parent
	:anchor anchor :side side :fill fill :expand expand :padx padx :pady pady
	:ipadx ipadx :ipady ipady))
  (set! i-variable variable)
  (set! i-item-list item-list)
  (set! i-tk-label-widget (make-label :tag (string->symbol (format #f "~S_label" tag)) :parent i-tk-frame-widget :padx 1 :ipadx 1 :text text :side 'left :anchor 'e))
  (when initial-value
	(i-variable 'set-value! initial-value))

  (set! i-tk-button-widget (tk-optionmenu (i-tk-frame-widget 'tk-widget) i-variable item-list))

  (tk-pack i-tk-button-widget)
  self)

(define-method (c-option-menu 'set-value! value)
	(i-variable 'set-value! value)
)

(define-method (c-option-menu 'get-value)
	(i-variable 'get-value)
)

(define-method (c-option-menu 'get-itemlist)
	i-item-list)



;;; C-CANVAS

(define (make-canvas &rest args)
  (apply c-canvas 'new args))

(define-class c-canvas
  (superclass c-control))

(define-method (c-canvas 'initialize &key tag parent 
			(anchor 'n)  
			(side 'top) 
			(fill 'none) 
			(expand 'no)
			(padx 0) 
			(pady 0)
			(ipadx 0) 
			(ipady 0) 

			grid
			(column 0)
			(columnspan 1)
			(row 0)
			(rowspan 1)
			(sticky 'ne)


 		bg borderwidth closeenough confine cursor (height 0) highlightbackground
		highlightcolor highlightthickness insertbackground insertborderwidth
		insertofftime insertontime relief scrollincrement scrollregion 
		selectbackground selectforeground selectborderwidth takefocus (width 0) xscrollincrement
		yscrollincrement xscrollbar yscrollbar
			)
  (super 'initialize :tag tag :parent parent)

    (set! i-tk-widget 

            (tk-canvas (parent 'tk-widget) 
		:bg bg :borderwidth borderwidth :closeenough closeenough
		:confine confine :cursor cursor :height height 
		:highlightbackground highlightbackground
		:highlightcolor highlightcolor :highlightthickness highlightthickness
		:insertbackground insertbackground :insertborderwidth insertborderwidth
		:insertofftime insertofftime :insertontime insertontime
		:relief relief :scrollincrement scrollincrement :scrollregion scrollregion 
		:selectbackground selectbackground :selectforeground selectforeground
		:selectborderwidth selectborderwidth :takefocus takefocus
		:width width :xscrollincrement xscrollincrement
		:yscrollincrement yscrollincrement :xscrollbar xscrollbar 
		:yscrollbar yscrollbar)
    )

  (if grid
	(tk-grid i-tk-widget :column column :columnspan columnspan :row row :rowspan rowspan
			:sticky sticky :padx padx :pady pady :ipadx ipadx 
			:ipady ipady)
	  (tk-pack i-tk-widget  :anchor anchor :side side :fill fill 
			:expand expand :padx padx :pady pady :ipadx ipadx 
			:ipady ipady))
  self)

(define-method (c-canvas 'get-value)
	())

(define-method (c-canvas 'poly coord-list &key fill outline smooth splinesteps stipple width)
	(i-tk-widget 'poly coord-list :fill fill :outline outline :smooth smooth 
		:splinesteps splinesteps :stipple stipple :width width))


(define-method (c-canvas 'line coord-list &key fill arrow capstyle jointstyle smooth splinesteps stipple width)
	(i-tk-widget 'line coord-list :fill fill :capstyle capstyle :jointstyle jointstyle 
		:smooth smooth :splinesteps splinesteps :stipple stipple :width width))

(define-method (c-canvas 'arc x0 y0 x1 y1 &key fill outline  stipple width extent outlinestipple start style)
	(i-tk-widget 'arc x0 y0 x1 y1 :fill fill :outline outline 
		:stipple stipple :width width :extent extent :outlinestipple outlinestipple :start start
		:style style))

(define-method (c-canvas 'oval x0 y0 x1 y1 &key fill outline  stipple width)
	(i-tk-widget 'oval x0 y0 x1 y1 :fill fill :outline outline 
		:stipple stipple :width width))

(define-method (c-canvas 'rect x0 y0 x1 y1 &key fill outline  stipple width)
	(i-tk-widget 'rect x0 y0 x1 y1 :fill fill :outline outline 
		:stipple stipple :width width))

(define-method (c-canvas 'text x y text-str &key fill stipple width font justify anchor)
	(i-tk-widget 'text x y text-str :fill fill :font font :justify justify 
		:anchor anchor :stipple stipple :width width))

(define-method (c-canvas 'move who x y)
	(i-tk-widget 'move who x y))


(define-method (c-canvas 'postscript filename &key colormode height pageanchor pageheight
	pagewidth pagex pagey rotate width x y)
	(i-tk-widget 'postscript filename :colormode colormode :height height :pageanchor pageanchor
	:pageheight pageheight :pagewidth pagewidth :pagex pagex :pagey pagey :rotate rotate
	:x x :y y))

;;; c-file-selector-box


(define (make-file-selector-box &rest args)
  (apply c-file-selector-box 'new args))

(define-class c-file-selector-box)

(define-method (c-file-selector-box 'initialize type &key parent title initialdir initialfile defaultextension filetypes)
  (if (eq? type 'save)
	  (tk-get-save-file :parent parent :title title :initialdir initialdir :initialfile initialfile :defaultextension defaultextension
		:filetypes filetypes)
	  (tk-get-open-file :parent parent :title title :initialdir initialdir :initialfile initialfile :defaultextension defaultextension
		:filetypes filetypes))
  self)


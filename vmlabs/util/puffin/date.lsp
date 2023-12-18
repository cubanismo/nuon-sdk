#|
date.lsp -- first attempt at a Date class in XLisp.
11/7/94 (mh)

Based on formulas in the book "Astronomical Formulae for Calculators",
Third Edition, by Jean Meeus.

|#

(define-class date
  (instance-variables
    julian-day-number
    year
    month       ; 1..12
    day         ; 1..31
    hour        ; 0..23
    minute      ; 0..59
    second      ; 0..59
    )
  (class-variables
    (timezone "PST")
    (timezone-hours 8)
    )
  )

#|
Define accessors to return local values by default, with an option to
return values corresponding to GMT.
|#

(define-method (date 'year &key gmt)
  (if gmt
    (self 'get-variable 'year)
    (let ((d (self 'copy)))
      (d 'add-hours! (- timezone-hours))
      (d 'get-variable 'year))))

(define-method (date 'month &key gmt)
  (if gmt
    (self 'get-variable 'month)
    (let ((d (self 'copy)))
      (d 'add-hours! (- timezone-hours))
      (d 'get-variable 'month))))

(define-method (date 'day &key gmt)
  (if gmt
    (self 'get-variable 'day)
    (let ((d (self 'copy)))
      (d 'add-hours! (- timezone-hours))
      (d 'get-variable 'day))))

(define-method (date 'hour &key gmt)
  (if gmt
    (self 'get-variable 'hour)
    (let ((d (self 'copy)))
      (d 'add-hours! (- timezone-hours))
      (d 'get-variable 'hour))))

(define-method (date 'minute &key gmt)
  (self 'get-variable 'minute))

(define-method (date 'second &key gmt)
  (self 'get-variable 'second))

(define-method (date 'set-year! y &key gmt)
  (if gmt
    (begin
      (set! year (round y))
      (self 'update-from-cd))
    (begin
      (self 'add-hours! (- timezone-hours))
      (set! year (round y))
      (self 'update-from-cd)
      (self 'add-hours! timezone-hours))))

(define-method (date 'set-month! m &key gmt)
  (if gmt
    (begin
      (set! month (round m))
      (self 'update-from-cd))
    (begin
      (self 'add-hours! (- timezone-hours))
      (set! month (round m))
      (self 'update-from-cd)
      (self 'add-hours! timezone-hours))))

(define-method (date 'set-month-by-name! name &key gmt)
  (let ((m (case name
             (("January" "Jan") 1)
             (("February" "Feb") 2)
             (("March" "Mar") 3)
             (("April" "Apr") 4)
             ("May" 5)
             (("June" "Jun") 6)
             (("July" "Jul") 7)
             (("August" "Aug") 8)
             (("September" "Sep") 9)
             (("October" "Oct") 10)
             (("November" "Nov") 11)
             (("December" "Dec") 12)
             (else (error "Bad month name: ~A" name)))))
    (if gmt
      (begin
        (set! month m)
        (self 'update-from-cd))
      (begin
        (self 'add-hours! (- timezone-hours))
        (set! month m)
        (self 'update-from-cd)
        (self 'add-hours! timezone-hours)))))

(define-method (date 'set-day! d &key gmt)
  (if gmt
    (begin
      (set! day (round d))
      (self 'update-from-cd))
    (begin
      (self 'add-hours! (- timezone-hours))
      (set! day (round d))
      (self 'update-from-cd)
      (self 'add-hours! timezone-hours))))

(define-method (date 'set-hour! h &key gmt)
  (if gmt
    (begin
      (set! hour (round h))
      (self 'update-from-cd))
    (begin
      (self 'add-hours! (- timezone-hours))
      (set! hour (round h))
      (self 'update-from-cd)
      (self 'add-hours! timezone-hours))))

(define-method (date 'set-minute! m &key gmt)
  (if gmt
    (begin
      (set! minute (round m))
      (self 'update-from-cd))
    (begin
      (self 'add-hours! (- timezone-hours))
      (set! minute (round m))
      (self 'update-from-cd)
      (self 'add-hours! timezone-hours))))

(define-method (date 'set-second! s &key gmt)
  (if gmt
    (begin
      (set! second s)
      (self 'update-from-cd))
    (begin
      (self 'add-hours! (- timezone-hours))
      (set! second s)
      (self 'update-from-cd)
      (self 'add-hours! timezone-hours))))

(define-method (date 'set-local-time! hour &optional (min 0) (sec 0))
  (self 'add-hours! (- timezone-hours))
  (self 'set-variable! 'hour (round hour))
  (self 'set-variable! 'minute (round min))
  (self 'set-variable! 'second sec)
  (self 'update-from-cd)
  (self 'add-hours! timezone-hours))


(define-method (date 'julian-date)
  julian-day-number)

(define-method (date 'copy)
  (let ((d (date 'new)))
    (d 'from-julian-date julian-day-number)))

(define (julian-date->calendar-date jd) ; ==> (values yr mon day hr min sec)
  (let* ((jd+ (+ jd 0.5))
         (z (floor jd+))
         (f (- jd+ z))
         (A (if (< z 2299161)
              z
              (let ((alpha (floor (/ (- z 1867216.25) 36524.25))))
                (- (+ z 1 alpha) (floor (/ alpha 4))))))
         (B (+ A 1524))
         (C (floor (/ (- B 122.1) 365.25)))
         (D (floor (* 365.25 C)))
         (E (floor (/ (- B D) 30.6001)))
         (mon (if (< E 13.5)
                (- E 1)
                (- E 13)))
         (yr (if (> mon 2.5)
               (- C 4716)
               (- C 4715)))
         (realday (- (+ B F) (+ D (floor (* 30.6001 E)))))
         (day (floor realday))
         (realhour (* 24 (- realday day)))
         (hr (floor realhour))
         (realmin (* 60 (- realhour hr)))
         (min (floor realmin))
         (realsec (* 60 (- realmin min)))
         (sec (floor realsec)))
    (values yr mon day hr min sec)))
         
;;; For typing:
(define jd->cd julian-date->calendar-date)

(define (calendar-date->julian-date yr mon day hr min sec)
  (let* ((y (if (> mon 2)
              yr
              (- yr 1)))
         (m (if (> mon 2)
              mon
              (+ mon 12)))
         (realmin (+ min (/ sec 60.0)))
         (realhour (+ hr (/ realmin 60.0)))
         (realday (+ day (/ realhour 24.0)))
         (funny (+ yr (/ mon 100.0) (/ realday 100000.0)))
         (A (if (>= funny 1582.1015)
              (floor (/ y 100.0))
              0))
         (B (if (>= funny 1582.1015)
              (- (+ 2 (floor (/ A 4.0)))
                 A)
              0)))
    (+ (floor (* 365.25 y))
       (floor (* 30.6001 (+ m 1)))
       realday
       1720994.5
       B)))

(define cd->jd calendar-date->julian-date)

(define-method (date 'from-calendar yr mon da 
                     &optional (hr 0) (min 0) (sec 0))
  (set! year yr
        month mon
        day da
        hour hr
        minute min
        second sec
        julian-day-number (cd->jd yr mon da hr min sec))
  self)

(define-method (date 'from-julian-date jd)
  (set! julian-day-number jd)
  (self 'update-from-jd)
  self)

(define-method (date 'from-now)
  (let ((jd-1970 2440587.5)
        (sec-per-day (* 60.0 60.0 24.0))
        (delta-from-1970 (get-time)))
    (let ((jd (+ jd-1970 (/ delta-from-1970 sec-per-day))))
      (multiple-value-bind (yr mon da hr min sec) (jd->cd jd)
        (set! year yr
              month mon
              day da
              hour hr
              minute min
              second sec
              julian-day-number jd))))
    self)


(define-method (date 'day-name &key gmt)
  (let ((d (self 'copy)))
    (unless gmt (d 'add-hours! (- timezone-hours)))
    (d 'set-variable! 'hour 0)
    (d 'set-variable! 'minute 0)
    (d 'set-variable! 'second 0)
    (d 'update-from-cd)
    (let* ((jd-at-0-hours (d 'julian-date))
           (n (round (+ jd-at-0-hours 1.5)))
           (rem (remainder n 7)))
      (day-name rem))))


(define (day-name daynum) 
  (case daynum
    (0 "Sunday")
    (1 "Monday")
    (2 "Tuesday")
    (3 "Wednesday")
    (4 "Thursday")
    (5 "Friday")
    (6 "Saturday")
    (else "???")))

(define-method (date 'month-name &key gmt)
  (month-name (self 'month :gmt gmt)))

(define (month-name month-num)
  (case month-num
    (1 "January")
    (2 "February")
    (3 "March")
    (4 "April")
    (5 "May")
    (6 "June")
    (7 "July")
    (8 "August")
    (9 "September")
    (10 "October")
    (11 "November")
    (12 "December")
    (else "???")))

(define-method (date 'timezone-name)
  timezone)

(define-method (date 'timezone-hours)
  timezone-hours)

(define-method (date 'date-string &key gmt)
  (format nil "~A ~A ~A, ~A" 
    (substring (self 'day-name :gmt gmt) 0 3)
    (substring (self 'month-name :gmt gmt) 0 3) 
    (self 'day :gmt gmt) 
    (self 'year :gmt gmt)))

(define-method (date 'time-string &key gmt)
  (format nil "~A:~A:~A ~A" (self 'hour :gmt gmt) (self 'minute) 
                            (self 'second) (if gmt "GMT" timezone)))

(define-method (date 'time-and-date-string &key gmt)
  (string-append (self 'time-string :gmt gmt) 
                 "  " 
                 (self 'date-string :gmt gmt)))

(define-method (date 'update-from-jd)
  (multiple-value-bind (yr mon da hr min sec) (jd->cd julian-day-number)
    (set! year yr
          month mon
          day da
          hour hr
          minute min
          second sec))
  self)

(define-method (date 'update-from-cd)
  (set! julian-day-number (cd->jd year month day hour minute second))
  (self 'update-from-jd))

(define-method (date 'add-days! days)
  (set! julian-day-number (+ julian-day-number days))
  (self 'update-from-jd)
  self)

(define-method (date 'add-hours! hours)
  (inc! hour hours)
  (self 'update-from-cd)
  self)

(define-method (date 'add-minutes! minutes)
  (inc! minute minutes)
  (self 'update-from-cd)
  self)

(define-method (date 'add-months! months)
  (let ((years (quotient months 12))
        (mons (remainder months 12)))
    (inc! year years)
    (inc! month mons)
    (if (< month 1)
      (begin 
        (inc! month 12)
        (decf year))
      (if (> month 12)
        (begin
          (decf month 12)
          (inc! year))))
    (self 'update-from-cd)))

(define-method (date 'add-years! years)
  (inc! year years)
  (self 'update-from-cd))

(define (make-current-date)
  (let ((d (date 'new)))
    (d 'from-now)
    d))

(define-method (date 'earlier-than? d)
  (< julian-day-number (d 'julian-date)))

(define-method (date 'later-than? d)
  (> julian-day-number (d 'julian-date)))

(define-method (date 'not-earlier-than? d)
  (>= julian-day-number (d 'julian-date)))

(define-method (date 'not-later-than? d)
  (<= julian-day-number (d 'julian-date)))

(define-method (date 'between? d1 d2)
  (let ((a (d1 'julian-date))
        (b (d2 'julian-date)))
    (if (< a b)
      (<= a julian-day-number b)
      (<= b julian-day-number a))))

(define-method (date 'strictly-between? d1 d2)
  (let ((a (d1 'julian-date))
        (b (d2 'julian-date)))
    (if (< a b)
      (< a julian-day-number b)
      (< b julian-day-number a))))

#|
The following assumes a string in the form "12/31/94" or "12/31/1994"
or even "12/31" (which infers current year). The DATE returned corresponds
to 0 hours in local time, unless the keyword GMT is #t, in which case
the returned DATE is 0 hours GMT.
|#

(define (make-date-from-string str &key gmt)
  (let ((index-1 (string-search "/" str)))
    (if (not index-1)
      #f
      (let ((month (read-from-string (substring str 0 index-1)))
            (year ((make-current-date) 'year))
            (day nil)
            (str2 (substring str (1+ index-1))))
        (let ((index-2 (string-search "/" str2)))
          (if (not index-2)
            (set! day (read-from-string str2))
            (let ((str3 (substring str2 (1+ index-2))))
              (set! day (read-from-string (substring str2 0 index-2)))
              (set! year (read-from-string str3))
              (if (< year 100)
                (inc! year 1900))))
          (let ((d (date 'new)))
            (d 'set-variable! 'year year)
            (d 'set-variable! 'month month)
            (d 'set-variable! 'day day)
            (d 'set-variable! 'hour (if gmt 0 (d 'timezone-hours)))
            (d 'set-variable! 'minute 0)
            (d 'set-variable! 'second 0)
            (d 'update-from-cd)
            d))))))

(define (make-date year month day &optional (hour 0) (min 0) (sec 0))
  (let ((d (date 'new)))
    (d 'set-variable! 'year year)
    (d 'set-variable! 'month month)
    (d 'set-variable! 'day day)
    (d 'set-variable! 'hour (round hour))
    (d 'set-variable! 'minute (round min))
    (d 'set-variable! 'second (round sec))
    (d 'update-from-cd)
    (d 'add-hours! (d 'timezone-hours)) ;uggh. SWNT.
    d))

(define-method (date 'print &optional (stream *standard-output*))
  (format stream "#<Object:DATE ~A>" (self 'time-and-date-string)))
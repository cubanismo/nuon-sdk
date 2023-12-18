(define basic-load load)

(define (load name)
  (let ((off (string-search "." name)))
    (if off
      (let ((ext (substring name off)))
        (if (string-ci=? ext ".fsl")
          (load-fasl-file name)
          (basic-load name)))
      (or (load-fasl-file (string-append name ".fsl"))
          (basic-load (string-append name ".lsp"))))))
   
(define (compile-file iname)
  (let* ((oname (string-append (get-root-file-name iname) ".fsl"))
         (ifile (open-input-file iname))
         (ofile (open-output-file oname))
         (sts #f))
    (when (and ifile ofile)
      (let loop ((expr (read ifile)))
        (when (not (eof-object? expr))
          (let ((compiled-expr (compile expr)))
            (fasl-write-procedure compiled-expr ofile))
          (loop (read ifile))))
      (set! sts #t))
    (when ifile (close-port ifile))
    (when ofile (close-port ofile))
    sts))

(define (get-root-file-name name)
  (let ((ext-offset (string-search "." name)))
    (if ext-offset
      (substring name 0 ext-offset)
      name)))

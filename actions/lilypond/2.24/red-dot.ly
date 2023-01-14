
\version "2.20.0"

#(set-global-staff-size 20)

#(define (add-dot text?)
  (lambda (grob)
      (let* ((layout (ly:grob-layout grob))
             (props (layout-extract-page-properties layout))
             (font
               (ly:paper-get-font layout
                 (cons '((font-encoding . fetaMusic)) props)))
             ;; Get the stencil-procedure from ly:grob-basic-properties.
             ;; If any, use it to create the stencil.
             (function (assoc-get 'stencil (ly:grob-basic-properties grob)))
             (stencil (if function (function grob) point-stencil))
             ;; Get the grob-name and create a text-stencil.
             ;; Read out the y-length for later translate.
             (grob-name-proc
                (lambda (x) (assq-ref (ly:grob-property x 'meta) 'name)))
             (grob-name (grob-name-proc grob))
             (grob-string (if (symbol? grob-name)
                              (symbol->string grob-name)
                              "no name"))
             (ref-text-stil (grob-interpret-markup grob
                                  (markup
                                     #:with-color red
                                     #:normal-text
                                     #:abs-fontsize 6
                                     (string-append "   " grob-string))))
             (ref-text-stil-length
                (interval-length (ly:stencil-extent ref-text-stil Y)))
             (grob-string-stil (if text? (grob-interpret-markup grob
                                  (markup
                                     #:with-dimensions '(0 . 0) '(0 . 0)
                                     #:stencil
                                     ref-text-stil))
                                     point-stencil
                                     ))
             ;; Create a red-dot-stencil
             (dot (ly:font-get-glyph font "dots.dot"))
             (red-dot (ly:stencil-in-color dot 1 0 0))
             (red-dot-length
                (interval-length (ly:stencil-extent red-dot X)))
             (red-dot-stil
                (ly:stencil-translate-axis red-dot (/ red-dot-length -2) X)))

      ;; If there's a grob with stencil-procedure and a valid stencil is
      ;; created, add the red-dot-stil and an optional text-stencil.
      (if (and function (ly:stencil? stencil) (grob::is-live? grob))
          (ly:grob-set-property! grob 'stencil
            (ly:stencil-add
              stencil
              red-dot-stil
              (if text?
                (ly:stencil-translate-axis
                  (ly:stencil-rotate
                    grob-string-stil
                    90 0 0)
                    (/ ref-text-stil-length 2)
                    X)
                point-stencil)))))))

% needs to be here for 2.16.2
#(define-public (symbol-list-or-symbol? x)
  (if (list? x)
      (every symbol? x)
      (symbol? x)))

#(define (add-red-dot-to-grobs text? l)
 ;; possible values for l:
 ;;   'all-grobs (adds red-dots to all grobs, where possible)
 ;;          this will naturally cause collisions,
 ;;   a single grob-name, must be a symbol,
 ;;   a list of grob-names,
 ;;   anything else (returns the unchanged original stencil)
 ;;  TODO: How to apply it once?
  (let ((grobs-to-consider
          (cond ((eq? l 'all-grobs)
                  all-grob-descriptions)
                ((symbol? l)
                  (list (assoc l all-grob-descriptions)))
                ((list? l)
                  (map
                    (lambda (grob)
                      (assoc grob all-grob-descriptions))
                      l))
                (else '()))))
  (lambda (context)
   (let loop ((x grobs-to-consider))
    (if (not (null? x))
     (let ((grob-name (caar x)))
      (ly:context-pushpop-property
         context
         grob-name
         'after-line-breaking
         (add-dot text?))
      (loop (cdr x))))))))

printRefpoint =
#(define-music-function (text? s-or-l)(boolean?
symbol-list-or-symbol?)
"
 Will add a red dot (and an optional text) to the stencil's ref-point of the
 specified grob(s).
 Valid input for s-or-l:
      @code{'all-grobs}, (adds red-dots to all grobs, where possible), this will
          naturally cause collisions
      a single grob-name, must be a symbol,
      a list of grob-names.
 The additional text may be activated by @code{##t}.
 To avoid bleeding-overs any context has to be initiated explicitly.
"
#{
        \applyContext #(add-red-dot-to-grobs text? s-or-l)
#})

%% For single use:

#(define addDot
  (lambda (grob)
      (let* ((function (assoc-get 'stencil (ly:grob-basic-properties grob)))
             (stencil (if function (function grob) point-stencil))
             (layout (ly:grob-layout grob))
             (props (layout-extract-page-properties layout))
             (font
               (ly:paper-get-font layout
                 (cons '((font-encoding . fetaMusic)) props)))
             (dot (ly:font-get-glyph font "dots.dot"))
             (red-dot (ly:stencil-in-color dot 1 0 0))
             (red-dot-length (interval-length (ly:stencil-extent red-dot X)))
             (red-dot-stil
                (ly:stencil-translate-axis red-dot (/ red-dot-length -2) X)))

      (if (and function (ly:stencil? stencil) (grob::is-live? grob))
          (ly:grob-set-property! grob 'stencil
            (ly:stencil-add
              stencil
              red-dot-stil))))))

%% Overriding grobs must be defined separately.
%% Don't forget to specify the context if necessary.
onceRedScript = \once \override Script #'after-line-breaking = #addDot

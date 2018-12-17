;;;SortByComposer takes the IndexEntry data sorts them by composer and creates and index PDF FIXME take last ascii word of composer not first.
(use-modules (ice-9 ftw))
(let ((str "")(tag "IndexEntry")(list-of-entries '()) (thefile #f) (transpose #f) (title #f) (composer #f) (comment #f) (incipit #f) (instruments '())(startdir ""))
    (define DenemoIndexEntries '())
    (define (create-lilypond data)
        (if data
            (begin
                (set! thefile (assq-ref data 'thefile))
                (set! transpose (assq-ref data 'transpose))
                (set! title (assq-ref data 'title))
                (set! composer (assq-ref data 'composer))
                (set! comment (assq-ref data 'comment))
                (set! incipit (assq-ref data 'incipit))
                (set! instruments (assq-ref data 'instruments))
                
                (set! str (string-append str
                        "\\noPageBreak\\markup \"" composer ": " title "\"\n"
                        "\\noPageBreak\\markup {instrumentation:"  (string-join instruments ", ") "}\n"
                        (if (string-null? comment) "" (string-append "\\noPageBreak\\markup\\bold\\italic {\"Comment:" comment "\"}\n"))                                                    
                        transpose "\n"
                        incipit "\n\\noPageBreak\\incipit\n"
                         "\\noPageBreak\\markup {\\with-url #'\"scheme:(d-OpenNewWindow \\\"" thefile "\\\")\" \"Filename: ." (substring thefile (string-prefix-length startdir thefile)) "\"}\n"
                        "\\markup {\\column {\\draw-hline}}")))))
    (define (comparison a b)
        (define comp1 (assq-ref a 'composer))
        (define comp2 (assq-ref b 'composer))
        (define sub1 #f)
        (define sub2 #f)
        (set! sub1 (string-match "[a-zA-Z]+" (string-reverse comp1))) 
        (set! sub2 (string-match "[a-zA-Z]+" (string-reverse comp2))) 
        
        (if sub1
            (set! sub1 (match:substring sub1)))

       (if sub2
            (set! sub2 (match:substring sub2)))

        (if (and sub1 (> (string-length sub1) 2))
            (set! comp1 (string-reverse sub1)))
        (if (and sub2 (> (string-length sub2) 2))
            (set! comp2 (string-reverse sub2)))
            
        (string-ci< comp1 comp2))

;;;;actual procedure        

  (let ((data (d-DirectiveGet-movementcontrol-data tag)))
        (if data
         (begin
            (set! startdir (d-DirectiveGet-movementcontrol-data (string-append tag "StartDir")))
            (if (not startdir)
                (set! startdir ""))
            (set! DenemoIndexEntries (eval-string data))
            (disp "Before sorting there are " (length DenemoIndexEntries) " index entries\n")
            (set! DenemoIndexEntries (sort! DenemoIndexEntries comparison))
            (disp "After sorting there are " (length DenemoIndexEntries) " index entries\n")
            (map  create-lilypond DenemoIndexEntries)
            (d-SetSaved #f)
            (d-DirectivePut-movementcontrol-postfix tag 
                                (string-append str                      
                                "\n\\noPageBreak\\markup {\\column {\\draw-hline}}\\noPageBreak\\markup {\\center-column {\\vspace #2 }}\\noPageBreak\\markup\\huge{"
                                 (_ "End of Index. Number of entries ") (number->string (length DenemoIndexEntries)) ".}"))
            (d-DirectivePut-movementcontrol-data tag (format #f "'~s" DenemoIndexEntries)))
        (d-WarningDialog (_ "Create index first")))))
    

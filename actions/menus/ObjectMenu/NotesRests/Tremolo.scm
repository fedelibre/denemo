;;;Tremolo
(let ((duration #f) (dur #f)(stripes #f)(tag "Tremolo")(params #f))
 (if (Note?)
  (begin
    (if (d-Directive-chord? tag)
        (let ((choice (RadioBoxMenu 
                        (cons (_ "Edit") 'edit) 
                        (cons (_ "Object Inspector") 'help)                         
                        (cons (_ "Delete") 'delete))))
                     (set! params 'finished)
                    (case choice
                         ((edit)
                           (set! params #f))
                        ((help)
                           (d-DisplayCurrentObject))
                          ((delete)
                            (d-SetSaved #f)
                            (d-DirectiveDelete-chord tag))))) 
      (if  (not params)
            (let ((choice (RadioBoxMenu 
                            (cons (_ "divide π  1/8") 'eighth) 
                            (cons (_ "divideπ‘ 1/16") 'sixteenth)
                            (cons  (_ "divide π£ 1/32 ") 'thir)
                            (cons  (_ "divide π£ 1/64") 'six)
                            (cons  (_ "divide π£ 1/128") 'hun))))    
                     (case choice
                            ((eighth)
                                (set! dur ":8")(set! stripes "πͺ"))
                            ((sixteenth)
                                (set! dur ":16")(set! stripes "π«"))
                            ((thir)
                                (set! dur ":32")(set! stripes "π¬"))
                             ((six)
                                 (set! dur ":64")(set! stripes "πͺπ«"))   
                            ((hun)
                                (set! dur ":128")(set! stripes "π«π«")))
              (if (string? dur)
                 (begin    
                    (d-SetSaved #f) 
                    (d-DirectivePut-chord-display tag stripes)
                    (d-DirectivePut-chord-postfix tag dur)))))
  		(d-RefreshDisplay))
  (d-WarningDialog (_ "Cursor must be on a note or chord for tremolo"))))

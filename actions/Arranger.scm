;;(if (and (= 1 (d-GetMovement)) (not (d-Directive-header? "ScoreTitle")))
;;(SetHeaderField "title" "Untitled"))
;;(d-DirectiveDelete-scoreheader "ScoreTagline")

(define (InitializeTypesetting)
  (d-PushPosition)
  (d-CheckScore)
  (if (not CheckScore::return)
    (let ((ok #f))
      (d-InfoDialog (_ "Score Check: Error in this measure"))
      (set! ok (RadioBoxMenu (cons (_ "Print Anyway") "y") (cons (_ "Cancel") "n")))
            (if (equal? ok "n")
                (begin
                    (d-PopPushPosition);;goes to the position on the top of the stack, replacing the top of the stack with the position before it went
                    (d-PopPosition);;goes to the error position that was pushed
                    (exit)))))
    (d-PopPosition))
(d-LimitInterSystemSpace 1.2)
;;(d-NormalBeamEndings)
;(d-PointAndClick)

(if DenemoPref_newbie
    (d-MouseInsertion))

(display "New Arranger Profile\n")
(d-SetSaved #t)

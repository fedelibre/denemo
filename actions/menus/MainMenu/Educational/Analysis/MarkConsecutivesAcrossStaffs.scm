;;;MarkConsecutivesAcrossStaffs
(let ((tag "MarkConsecutivesAcrossStaffs")(consecutives '()))
  (define (mark-position pos)
      (define musobj (caar (cdr pos)))
      (d-GoToPosition  #f #f (musobj.measure musobj) (musobj.horizontal musobj))
      (d-DirectivePut-chord-graphic tag "CrossSign"))
(if (d-GetSaved)
	(begin
		(d-MoveToStaffUp)
		(d-MoveToBeginning)
		(d-DirectiveDelete-chord tag)
		(while (d-NextChord) (d-DirectiveDelete-chord tag))
		(d-MoveToBeginning)
		(set! consecutives  (MapToAbstractionMovement (CreateAbstractionMovement) AM::consecutive5th AM::consecutive8th))
		;(disp "consecs " consecutives " \n")
		(d-InfoDialog (string-append (number->string (length consecutives)) " consecutives were found"))
		(d-MoveToMovementBeginning)
		(for-each mark-position consecutives))
	(d-WarningDialog (_ "Score must be saved first"))))

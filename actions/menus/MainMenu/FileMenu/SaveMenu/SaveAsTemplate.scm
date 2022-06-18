;;SaveAsTemplate
(let ((warning #f))
	(define (clear-first-measure)
		(define (do-staff)
			(while (Music?)
				(d-DeleteObject))
			(while (d-NextObjectInMeasure)
					(while (Music?)
						(d-DeleteObject))))
		(do-staff)
		(while (MoveDownStaffOrVoice)
			(do-staff)))
    (d-GoToPosition 1 1 1 1)
    (if (not (EmptyMeasure?))
        (if (d-GetSaved)
            (let ((choice (RadioBoxMenu (cons (_ "Remove All Music?") 'remove) (cons (_ "Keep Music?") 'keep))))
                (case choice
                    ((remove)
                        (begin
                            (clear-first-measure)
                            (d-MoveToMeasureRight)
                            (d-DeleteFromCursorToEnd 'all)
                            (let loop () 
                                (if (d-NextMovement)
                                    (begin 
                                    	(d-DeleteMovement)
                                    	(d-GoToPosition 1 1 1 1) 
                                    	 (loop))))))))
            (set! warning (string-append (_ "Cancelled: ") (_ "Score is not saved")))))
    (if warning
        (d-WarningDialog warning)
        (d-SaveTemplate)))

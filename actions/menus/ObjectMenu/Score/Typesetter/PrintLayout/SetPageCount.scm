;;;SetPageCount
(let* ((tag "SetPageCount")(count (d-GetUserInput (_ "Total Page Count") (_ "Give Pages Required\n(0 for optimal): ") "4")))
	(if (not (d-Directive-score? tag))
			(begin
				(d-DirectivePut-score-prefix tag "")
				(d-DirectivePut-score-display tag (_ "Page Count"))))
		
			(if (and count (string->number count)) 
				(begin
					(if  (> (string->number count) 0)
						(begin
							(d-DirectivePut-score-prefix tag (string-append "\\paper { page-count=" count "}"))
							(d-DirectivePut-score-display tag (string-append (_ ": Page Count") count)))
						(d-WarningDialog (_ "Optimal Page Count Set")))	
					(d-SetSaved #f))
				(d-WarningDialog (_ "Cancelled"))))

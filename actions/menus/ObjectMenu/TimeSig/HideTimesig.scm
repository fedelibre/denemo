;;;HideTimesig
(let ((tag "HideTimesig")(params HideTimesig::params))
	(if (Timesignature?)
		(if (d-Directive-timesig? tag)
		    (d-DirectiveDelete-timesig tag)
		    (begin
		        (d-DirectivePut-timesig-prefix tag  (string-append  "\\once \\override Staff.TimeSignature #'stencil = ##f"  ))
		        (d-DirectivePut-timesig-gy tag 60)
		        (d-DirectivePut-timesig-graphic tag "\n⋃\nDenemo\n24")
			(if (not params)(SetDirectiveConditional "timesig" tag))))
		 (begin 
			(if (d-Directive-timesig? tag)
				(d-DirectiveDelete-timesig tag)
				(begin
					(d-DirectivePut-timesig-prefix tag  (string-append  "\\once \\override Staff.TimeSignature #'stencil = ##f"  ))
					(d-DirectivePut-timesig-gy tag 60)
					(d-DirectivePut-timesig-graphic tag "\n⋃\nDenemo\n24")
					(if (not params)(SetDirectiveConditional "timesig" tag))))))
	(d-SetSaved #f))

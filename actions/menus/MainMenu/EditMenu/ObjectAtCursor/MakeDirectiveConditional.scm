;;;MakeDirectiveConditional
(let ()
   (if (d-Directive-standalone?)
		(begin 
			(if (Appending?)(d-MoveCursorLeft))
			(SetDirectiveConditional "standalone" (d-DirectiveGetForTag-standalone)))
		(if (Music?) 
			(let ((tag/type (d-ChooseTagAtCursor)))
				(if tag/type 
					(SetDirectiveConditional (if (cdr tag/type) "note" "chord")   (car tag/type))
					(d-WarningDialog (_ "Cancelled"))))
			(if (Clef?)
				(SetDirectiveConditional "clef" (d-ChooseTagAtCursor))
				(if (Timesignature?)
					(SetDirectiveConditional "timesig" (d-ChooseTagAtCursor))
					(if (Keysignature?)
						(SetDirectiveConditional "keysig" (d-ChooseTagAtCursor))))))))

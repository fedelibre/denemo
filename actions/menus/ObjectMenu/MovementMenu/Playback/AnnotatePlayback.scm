;AnnotatePlayback
(define-once AnnotatePlayback::timings '())
(define-once AnnotatePlayback::positions '())

(let ((params AnnotatePlayback::params)(tag "AnnotationPlayback")(choice #f)(menu '()))
	(define (FindAudioAnnotations)
		(d-MoveToBeginning)
		;(disp "list is " (reverse AnnotatePlayback::timings) " a list? " (list?  AnnotatePlayback::timings))
		(for-each 
			(lambda (thetime)   
				(while (and (d-NextChord) (<= (d-GetMidiOnTime) thetime)))
				(set! AnnotatePlayback::positions (cons (GetPosition) AnnotatePlayback::positions)))
			(reverse AnnotatePlayback::timings)))
			
	(define (InsertAudioAnnotations)
		(d-MoveToBeginning)
		;(disp "pos list is " (reverse AnnotatePlayback::positions) " a list? " (list?  AnnotatePlayback::positions))
		(for-each 
			(lambda (position)   
				(apply d-GoToPosition position)
				(d-DirectivePut-standalone-graphic tag "CrossSign"))
			(reverse AnnotatePlayback::positions))
			(d-MoveToBeginning))
			
	(define (DeleteAnnotationMarkers)
				(d-PushPosition)
				(d-MoveToBeginning)
				(while (d-NextObject)
					(d-DirectiveDelete-standalone tag))
				(d-PopPosition))
	(define (PlayContext)
		(d-PushPosition)
		(while (d-NextObjectInMeasure))
		(DenemoSetPlaybackEnd)
		(d-MoveToMeasureLeft)
		(DenemoSetPlaybackStart)
		;(apply d-GoToPosition (GetPosition));gets the start of the bar in view while playing
		(d-Play "(d-PopPosition)"))

;;;;procedure starts here
	(if (not params)
		(set! menu (list (cons (_ "Play and Annotate") 'annotate))))
	(if (not (null? AnnotatePlayback::positions))
		(begin
			(set! menu (cons (cons (_ "Insert Annotation Markers") 'insert) menu))))
	(set! menu (cons (cons (_ "Move & Play Next Annotation") 'forward) menu))
	(if (d-Directive-standalone? tag)
		(begin
			(set! menu (cons (cons (_ "Label Annotation") 'label) menu))
			(set! menu (cons (cons (_ "Delete Annotation") 'delete) menu))))	
	(set! menu (cons (cons (_ "Clear Annotation Markers") 'clear) menu))
	(set! menu (cons (cons (_ "Help") 'help) menu))
	(set! menu (cons (cons (_ "Finish/Cancel") 'finish) menu))
	(set! choice (TitledRadioBoxMenuList (_ "Playback Annotation") (reverse menu)))
	(case choice
				((annotate)
					(d-PushPosition)		
					(d-DenemoPlayCursorToEnd)
					(set! AnnotatePlayback::timings '())
					(set! AnnotatePlayback::positions '())
					(let loop ()
						(define key (d-GetKeypress))
						(define time (d-AudioIsPlaying))
						(if (and time (equal? key "space"))
							(begin
							    (Help::TimedNotice (string-append  "<span font_desc=\"16\" foreground=\"blue\">" (_ "Marked ") "</span>") 800)
								(set! AnnotatePlayback::timings (cons  time  AnnotatePlayback::timings))
								(loop))))
					(d-Stop)
					;(disp  "Timings " AnnotatePlayback::timings "\n")
					(FindAudioAnnotations)
					(set! AnnotatePlayback::positions (reverse  AnnotatePlayback::positions))
					(d-PopPosition)
					(if (null? AnnotatePlayback::positions)
						(d-AnnotatePlayback)
						(d-AnnotatePlayback 'continue)))
				((insert)
					(InsertAudioAnnotations)
					(set! AnnotatePlayback::positions '())
					(d-AnnotatePlayback 'continue))
				((clear)
					(DeleteAnnotationMarkers)
					(d-AnnotatePlayback 'continue))
				((label)
					(if (d-Directive-standalone? tag)
						(d-DirectivePut-standalone-display tag (d-GetUserInput (_ "Give label for this annotation"))))
					(d-AnnotatePlayback 'continue))	
				((delete)
					(if (d-Directive-standalone? tag)
						(d-DirectiveDelete-standalone tag))
					(d-AnnotatePlayback 'continue))					
				((forward)
					(while (and (d-NextObject) (not (d-Directive-standalone? tag))))
					(if (d-Directive-standalone? tag)
						(PlayContext)
						(begin
							(d-WarningDialog (_ "No more Playback Annotations markers"))
							(d-MoveToBeginning)
							(d-AnnotatePlayback 'continue))))
				((finish)
						(d-InfoDialog (_ "Finished")))	
				((help)
					(d-InfoDialog (_ "This command allows you to mark moments during playback for further study.
Choosing Play and Annotate allows you to mark moments as you listen by pressing the space bar or left-clicking in the Print View or the Source View.
Right-clicking in the Print or Source View or pressing a key other than space stops the play whereupon you can choose Insert Annotation Markers to insert marks \"x\" into the current staff.
Then use Move and Play to play a couple of bars at the next annotation - you can label the mark with a comment, edit the score etc, before moving on to the next.
Marks can be deleted just like any other object or the Clear All Marks option can be chosen to finish.")))))

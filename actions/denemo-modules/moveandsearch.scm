;Find the next object that returns #t from the given test function. Don't write the function in parentheses, just give the name (except you give a function that returns a name :))
(define (FindNextObjectAllStaffs test?) 
	(let loopy ()
	(if (d-NextObject)
		(if (test?)
			#t ; object found. Stop
			(loopy)) ; not the droids you're looking for, move on
		(if (d-MoveToStaffDown); no next object possible
			(begin (d-MoveToBeginning) ; lower staff found
				(if (test?)
					#t; object found. Stop
					(loopy))) ; first object of lower staff is not a member, start search again.
			#f) ; no staff left, final end.
	); if end
	));loopy end

(define  (FindNextObjectAllColumns test?)
	(if (not (MeasureEnd?))
		(d-MoveCursorRight))
	(let loop ()
		(if (MeasureEnd?)
			(if (d-GoToPosition #f (1+ (d-GetStaff)) #f 1) ; try to go a staff down
				(loop) ; there is a staff down. Loop again
				(begin ; there is no staff down. 
					(if (d-GoToPosition #f 1 (1+ (d-GetMeasure)) 1) ; try to go to the next column
						(loop) ; there is a next column. Loop again
						#f))) ; there is none, end of the movement. End of the script
			(if (test?) 
				#t ; object found. stop				
				(begin 
					(d-MoveCursorRight)
					(loop))))))

(define  (FindPrevObjectAllColumns test?)
	(define (step)
		(if (not (MeasureBeginning?))
			(d-MoveCursorLeft)
			(if (d-GoToPosition #f (1- (d-GetStaff)) #f 1) ; try to go a staff up
				(GoToMeasureEnd)
				(if (and (MoveToColumnEnd) (d-GoToPosition #f #f (1- (d-GetMeasure)) 1)) ; no staff above.  try to go to the previous column					
					(GoToMeasureEnd)
					#f)))) ; no previous column
	;;Body	
	(step)
	(let loop ()	
		(if (test?)
			#t
			(if (step)
				(loop)
				(begin (d-MoveToMovementBeginning) #f))))); Beginning of Movement, end of search

;TODO: Rewrite to not use their own loop but the other functions in this file.
(define (PrevDirectiveOfTag tag)
  (let loop ()
    (if (d-PrevStandaloneDirective)
       (if (not (d-Directive-standalone? tag))
	   (loop)
	   #t
	   )
       #f)))

;TODO: Rewrite to not use their own loop but the other functions in this file.       
(define (NextDirectiveOfTag tag)
  (let loop ()
    (if (d-NextStandaloneDirective)
       (if (not (d-Directive-standalone? tag))
	   (loop)
	   #t
	   )
       #f)))

; GoToMeasureEnd: Move right until "appending" or "none" which is the Measure End
(define (GoToMeasureEnd)
  (let loop ()
    (if  (or (None?) (Appending?))
	#t
	(begin (d-MoveCursorRight) (loop)))))

; GoToMeasureBeginning
(define (GoToMeasureBeginning)
  (if (d-MoveToMeasureLeft)
	(d-MoveToMeasureRight)  
	(d-MoveToBeginning)))

; Go to the first staff, same measure. Handle crossing unequal staff length.
(define (MoveToColumnStart)
	(define measure (d-GetMeasure)) ; to make shure we stay in the same column all the time.
	(RepeatUntilFail d-MoveToStaffUp)
	(d-GoToPosition #f #f measure #f))
	
(define (MoveToColumnEnd)
	(define measure (d-GetMeasure)) ; to make shure we stay in the same column all the time.
	(RepeatUntilFail d-MoveToStaffDown)
	(d-GoToPosition #f #f measure #f))
	
(define (GetPosition)
	(list (d-GetMovement) (d-GetStaff) (d-GetMeasure)(d-GetHorizontalPosition)))
	
(define (Probe test moveinstruction)
	(define return #f)
	(d-PushPosition)	
	(if (moveinstruction)
		(set! return (test)))
	(d-PopPosition)
	return)
(define (ProbePosition test movement staff measure horizontalposition)
	 (Probe test (lambda () (d-GoToPosition movement staff measure horizontalposition))))
(define (ProbePreviousMeasure test)
	(Probe test d-MoveToMeasureLeft))
(define (ProbeNextMeasure test)
	(Probe test d-MoveToMeasureRight))
(define (ProbeNextObject test)
	(Probe test d-NextObject))
(define (ProbePreviousObject test)
	(Probe test d-PreviousObject))
(define (ProbeNextNote test)
	(Probe test d-NextNote))
(define (ProbePreviousNote test)
	(Probe test d-PreviousNote))

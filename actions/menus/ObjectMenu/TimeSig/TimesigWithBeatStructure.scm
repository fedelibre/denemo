;;;TimesigWithBeatStructure
(let ((tag "SetBeamExceptions") (spec '()) (start (and (= (d-GetMeasure) 1) (or (not (d-GetStartTick)) (zero? (d-GetStartTick))))))
    (GoToMeasureBeginning)
    (if (and (not start) (not (Timesignature?)))
        (begin
            (d-InsertTimeSig (d-GetPrevailingTimesig))
            (d-MoveCursorLeft)))
    (set! spec (assoc-set! spec 'delete d-DirectiveDelete-timesig))
    (set! spec (assoc-set! spec 'get d-DirectiveGet-timesig-data))
    (set! spec (assoc-set! spec 'put d-DirectivePut-timesig-data))
    (set! spec (assoc-set! spec 'proc d-DirectivePut-timesig-prefix))
    (set! spec (assoc-set! spec 'layout ""))
    (set! spec (assoc-set! spec 'tag tag))
    (d-SetBeamExceptions spec)
	(if (d-Directive-timesig? tag)
		(d-DirectivePut-timesig-display tag (_ "Beam"))))

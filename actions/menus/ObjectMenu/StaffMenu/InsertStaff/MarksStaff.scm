;;MarksStaff
(let ((tag "MarksStaff"))
    (if (not (d-Directive-staff? tag))
        (begin
            (d-SetSaved #f)
            (d-PushPosition)
            (while (d-MoveToStaffUp))
            (d-AddBefore)
            (d-StaffProperties (string-append "denemo_name=" ""))
            (d-DirectivePut-clef-graphic tag "\nM\nDenemo\n48")
            (d-DirectivePut-clef-gy tag 36)
            (d-DirectivePut-clef-override tag (logior DENEMO_OVERRIDE_GRAPHIC DENEMO_OVERRIDE_LILYPOND ))
            (d-DirectivePut-keysig-override tag  (logior DENEMO_OVERRIDE_GRAPHIC DENEMO_OVERRIDE_LILYPOND ) )
            (d-DirectivePut-timesig-override tag DENEMO_OVERRIDE_LILYPOND )
            (d-StaffType "Dynamics")
            (d-DirectivePut-voice-override tag   (logior DENEMO_OVERRIDE_GRAPHIC DENEMO_OVERRIDE_LILYPOND ))
            (d-MuteStaff #t)
            (d-PopPosition)
            (d-MoveToStaffDown))
   	 (d-InfoDialog (_ "This staff is purely for holding marks that should appear once at the top of the system - avoiding having to put the marks in each part. It must have a blank part name, so that it is typeset with every part. The marks should be spaced using either dummy notes or spacers.
   WARNING: Do not place clef changes or other non-duration items in this staff - it may trigger the creation of a separate staff on typesetting!"))))

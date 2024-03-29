;;DynamicsStaff
(let ((tag "DynamicsStaff")
		(interactive (not (eq? DynamicsStaff::params 'noninteractive)))
	    (name (d-StaffProperties "query=denemo_name"))
		(center #f))
    (if (not (d-Directive-staff? tag))
        (begin
            (d-SetSaved #f)
            (d-PushPosition)
            (if interactive
				(begin
					(set! center  (RadioBoxMenu (cons (_"Centered Between Staffs") #f)
												(cons (_ "Attached to Current Staff") " \\override VerticalAxisGroup.staff-affinity = #UP ")))			
					(d-NewStructuredStaff)))
            (d-InitialClef "Alto")
            (d-SetStaffRangeHi 0)
            (d-SetStaffRangeLo 0)
            (d-StaffProperties (string-append "denemo_name=" name))
            (d-SetColorOfStaff #x20A0E000)
            (d-SetLinesInStaff 1)
            (d-ShortenStaffHeight 40)
            (if interactive
                (d-StartUpStems))
            (d-DirectivePut-clef-graphic tag "\nD\nDenemo\n48")
            (d-DirectivePut-clef-gy tag 36)
            (d-DirectivePut-clef-override tag (logior DENEMO_OVERRIDE_GRAPHIC DENEMO_OVERRIDE_LILYPOND ))
            (d-DirectivePut-keysig-override tag  (logior DENEMO_OVERRIDE_GRAPHIC DENEMO_OVERRIDE_LILYPOND))
            (d-DirectivePut-timesig-override tag DENEMO_OVERRIDE_LILYPOND)
            
            (d-StaffType "Dynamics")
            (if center
				(begin
					(d-DirectivePut-staff-prefix tag  center)
					(d-DirectivePut-staff-override tag  (logior DENEMO_ALT_OVERRIDE DENEMO_OVERRIDE_AFFIX))))
            (d-DirectivePut-voice-override tag   (logior DENEMO_OVERRIDE_GRAPHIC DENEMO_OVERRIDE_LILYPOND ))
            (d-StaffMasterVolume #f)
            (d-PopPosition)
            (d-MoveToStaffDown)
            (d-CursorToNote "c'")
            (GoToMeasureEnd)))
    (if (not DynamicsStaff::params) (d-InfoDialog (_ "This line (\"staff\") is for holding cresc. dim hairpins and dynamic markings so that they can be positioned (using dummy notes, colored blue) and will align with each other. Create this between the staffs for a piano work or on any staff where alignment of hairpins and dynamic marks is needed.\nWARNING: Do not place clef changes or other non-duration items in this staff - it may trigger the creation of a separate staff on typesetting!\nThis Dynamics \"staff\" must have the same part name as the staff the dynamics should appear on."))))



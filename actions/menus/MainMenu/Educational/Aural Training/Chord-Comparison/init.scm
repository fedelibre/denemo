
(define ChordComparison::Major (cons "Major" "c e g"))
(define ChordComparison::Minor (cons "Minor" "c ees g"))
(define ChordComparison::Augmented (cons "Augmented" "c e gis"))
(define ChordComparison::Diminished (cons "Diminished" "c ees ges"))
(define ChordComparison::Major7 (cons "Major7" "c e g b"))
(define ChordComparison::Dominant7 (cons "Dominant7" "c e g bes"))
(define ChordComparison::Minor7 (cons "Minor7" "c ees g bes"))
(define ChordComparison::HalfDiminished7 (cons "HalfDiminished7" "c ees ges bes"))
(define ChordComparison::Diminished7 (cons "Diminished7" "c ees ges beses"))


(define ChordComparison::ChordPossibilities (list ChordComparison::Major ChordComparison::Minor))

(define ChordComparison::HighestNote 80)
(define ChordComparison::LowestNote 55)
(define ChordComparison::ChordChordComparison::LowestNote 60)
(define ChordComparison::ChordQuality 0)
(define ChordComparison::ArpTimer 0)
(define TransposedChordNotes '())
(define ChordComparison::score 0)



(let ((time (gettimeofday)))
  (set! *random-state*
    (seed->random-state (+ (car time)
      (cdr time)))))

(define (ChordComparison::gotoEnd)
  (d-CursorRight)
  (if (d-NextObject)
    (ChordComparison::gotoEnd) 
    (d-CursorRight)))

(define (ChordComparison::gotoLastObject)
  (d-CursorRight)
  (if (d-NextObject)
    (ChordComparison::gotoLastObject)))

(define (ChordComparison::lilyname->midikey lilyname)
  (let (
  		(naturual_notenum '(0 2 4 5 7 9 11))
  		(accidental 0) 
  		(octave 48) 
  		(notename 0) 
  		(notenum 0) 
  		(loop 0))
      (set! notename
	(lambda (char)
          (modulo (- (char->integer char) 99) 7)))
      (set! loop 
        (lambda (x)
          (if (< x (string-length lilyname))
	    (begin
	      (if (= x 0) (set! notename (notename (string-ref lilyname x))))
	      (if (> x 0) 
	        (begin
		  (if (equal? #\i (string-ref lilyname x))
		    (set! accidental (+ accidental 1)))
		  (if (equal? #\e (string-ref lilyname x))
		    (set! accidental (- accidental 1)))
		  (if (equal? #\' (string-ref lilyname x))
		    (set! octave (+ octave 12)))
		  (if (equal? #\, (string-ref lilyname x))
		    (set! octave (- octave 12)))))
		(loop (+ 1 x)))
			  );end of if
		      )
		    );end of loop
	      (loop 0)
    (set! notenum (list-ref naturual_notenum notename))
    (+ (+ octave notenum) accidental)      
	    );end of let
	  )


(define (ChordComparison::midinum->lilyname num)
  (let ( 	(octave 0) 
  		(notename "")
  		(OctaveString "")
  		(sharplist '("c" "cis" "d" "dis" "e" "f" "fis" "g" "gis" "a" "ais" "b"))
  				)
  (set! octave (- (quotient num 12) 4))
  (set! notename (list-ref sharplist (remainder num 12)))
  (if (> octave 0)
    (set! OctaveString (string-pad "" (abs octave) #\'))
    (set! OctaveString (string-pad "" (abs octave) #\,)))
  (string-append notename OctaveString)
))

(define (ChordComparison::showscore)
 (d-DirectivePut-score-display "ChordComparison::GameScore" (string-append "<b>Score: </b>" (number->string ChordComparison::score))))

(define (ChordComparison::GetRandom)
  (set! ChordComparison::ChordChordComparison::LowestNote (random ChordComparison::HighestNote))
  (if (> ChordComparison::LowestNote ChordComparison::ChordChordComparison::LowestNote)
    (ChordComparison::GetRandom) ))

(define (ChordComparison::GetChordQuality)
  (car (list-ref ChordComparison::ChordPossibilities ChordComparison::ChordQuality)))
  
(define (ChordComparison::GetChordSpelling)
  (cdr (list-ref ChordComparison::ChordPossibilities ChordComparison::ChordQuality)))

(define (ChordComparison::GetNewChord)
  (ChordComparison::GetRandom)  
  (set! ChordComparison::ChordQuality (random (length ChordComparison::ChordPossibilities))))

(define (ChordComparison::GetIntervalList)
 (let (
 	(SetOctave 0)
	(IntervalList 0)
	(ChordNoteList '())
 	)
(set! SetOctave 
  (lambda (lilystring)
    (- (ChordComparison::lilyname->midikey lilystring) 48)))
  (set! ChordNoteList (string-split (ChordComparison::GetChordSpelling) #\space))
  (set! IntervalList (map SetOctave ChordNoteList))
  IntervalList
  ))

(define (ChordComparison::PlayChord note)
  (PlayNote (number->string (+ ChordComparison::ChordChordComparison::LowestNote note)) 1000))

(define (ChordComparison::Play)  
  (map ChordComparison::PlayChord (ChordComparison::GetIntervalList)))

(define (ChordComparison::ArpegChord note)
  (let ( (newnote "") )
    (set! newnote (number->string (+ ChordComparison::ChordChordComparison::LowestNote note)))
    (d-OneShotTimer ChordComparison::ArpTimer (string-append "(PlayNote " "\"" newnote "\"" " 1000)"))
    )
  (set! ChordComparison::ArpTimer (+ ChordComparison::ArpTimer 1000)))

(define (ChordComparison::PlayArpeggio)
  (map ChordComparison::ArpegChord (ChordComparison::GetIntervalList))
  (set! ChordComparison::ArpTimer 0))

(define (ChordComparison::OfferChord)
  (ChordComparison::showscore)
  (ChordComparison::GetNewChord)
  (usleep 10000)
  (ChordComparison::Play))

(if (not (defined? 'Transpose::init))
  (begin
    (d-LoadCommand "/MainMenu/EditMenu/Transpose/SetTransposeIntervalFromNote")
    (d-InitializeScript "SetTransposeIntervalFromNote")))

(define (ChordComparison::TransposeChord notestring lilyname)
  (set! Transpose::Note lilyname)
    (Transpose::SetTransposeInterval Transpose::Note)
  (set! TransposedChordNotes (string-split (Transpose::TransposeNoteList notestring) #\space))
  )
  ;(set! TransposedChordNotes (Transpose::TransposeNoteList notestring)))

(define (ChordComparison::AddNoteToChord notes)
  (ChordComparison::gotoLastObject)
  (d-ChangeChordNotes notes))

(define (ChordComparison::DrawAnimatedArpeggio)
  (let ( (addnotes 0)
         (tindex 0)
         (currentnotes "")
       )
  (set! addnotes
    (lambda (note)
      (begin
        (set! currentnotes (string-append currentnotes " " note))
        (d-OneShotTimer tindex (string-append "(ChordComparison::AddNoteToChord " "\"" currentnotes "\"" ")"))
	(if (not (string=? note ""))
          (d-OneShotTimer tindex (string-append "(PlayNote " "\"" (number->string (ChordComparison::lilyname->midikey note)) "\"" " 1000)")))
        (set! tindex (+ tindex 1000))
	            )))
  (set! tindex 0)
  (ChordComparison::gotoEnd)
  (d-CursorToNote (list-ref TransposedChordNotes 0))
  (d-Insert0)
  (map addnotes TransposedChordNotes)
				))

;TODO perhaps inherit this from EducationGames
(define (ChordComparison::PlaceAnswerStatus gfx)
  (begin
    (d-DirectivePut-note-minpixels "ChordComparison::tick" 30)
    (d-DirectivePut-note-gx "ChordComparison::tick" -10)
    (d-DirectivePut-note-gy "ChordComparison::tick" 40)
    (d-DirectivePut-note-graphic "ChordComparison::tick" gfx)))

;;;;;;;;; callback when user chooses a chord
(define (ChordComparison::chordchosen chord)
  (ChordComparison::TransposeChord (ChordComparison::GetChordSpelling)
    (ChordComparison::midinum->lilyname ChordComparison::ChordChordComparison::LowestNote))
  (ChordComparison::DrawAnimatedArpeggio)
  (ChordComparison::gotoEnd)
  (if  (string=? (ChordComparison::GetChordQuality) chord)
    (begin
      (set! ChordComparison::score (+ ChordComparison::score 1))
      (ChordComparison::PlaceAnswerStatus "CheckMark")
      )
    (begin
      (set! ChordComparison::score (- ChordComparison::score 1))
      (ChordComparison::PlaceAnswerStatus "CrossSign")
  ))
  (d-OneShotTimer (* 1000 (length TransposedChordNotes)) "(ChordComparison::OfferChord)")
  )

(define (ChordComparison::createbuttons chord)
  (CreateButton (string-append "ChordComparison::" (car chord))  (string-append " <span font_desc=\"22\" foreground=\"blue\">" (car chord)  "</span>"))
    (d-SetDirectiveTagActionScript  (string-append "ChordComparison::" (car chord)) (string-append "(ChordComparison::chordchosen \"" (car chord) "\")")))

;;;;main procedure to call for ChordComparison
(define (ChordComparison::ChordComparison chordlist) 

  (set! ChordComparison::ChordPossibilities chordlist)
  (CreateButton "ChordComparison::GameScore" "<span font_desc=\"22\">Click to start</span>")
  (d-SetDirectiveTagActionScript "ChordComparison::GameScore" "(ChordComparison::OfferChord)")

  (map ChordComparison::createbuttons ChordComparison::ChordPossibilities)

  (CreateButton "ChordComparison::replay" "<span font_desc=\"22\">Re-Play</span>")
  (d-SetDirectiveTagActionScript "ChordComparison::replay" "(ChordComparison::Play)" )

  (CreateButton "ChordComparison::play_arpeggio" "<span font_desc=\"22\">Arpeggio</span>")
  (d-SetDirectiveTagActionScript "ChordComparison::play_arpeggio" "(ChordComparison::PlayArpeggio)" )
)



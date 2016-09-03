;;;;ChordEntry
(define-once ChordEntry::active #f)
(if ChordEntry::active
   (begin ;;;;Filter is already running stop it
      (disp "Turning off Chord without pedal entry\n")
      (d-InputFilterNames (_ "No MIDI Filter"))

      (set! ChordEntry::active #f)
      (d-PutMidi 0)
      (d-SetBackground #xFFFFFF))
   
  (let  ((ons '())) ;;;;Filter is not already running so run it
    (define (noteOn? midi)
      (= #x90 (bit-extract midi 0 8)))
    (define (noteOff? midi)
      (= #x80 (bit-extract midi 0 8)))
    (define (add-note note)
      (d-InsertNoteInChord (d-GetNoteForMidiKey note))  
      (PlayNote (number->string note) 400))
    
    (define (GetChords)
      (let loop ()
        (let* (
               (midi (d-GetMidi))
               (velocity (bit-extract midi 16 24))
               (note (bit-extract midi 8 16))
               (command (bit-extract midi 0 8)))  
          (cond
               ((noteOn? midi)
                    (if (null? ons)
                        (begin
                            (d-PutMidi midi)
                            (if (not (Appending?))
                                (d-PrevChord)))
                        (add-note note))
                    (set! ons (cons note ons))
                    (loop))
               ((noteOff? midi)       
                    (set! ons (delq note ons))
                    (if (null? ons)
                         (d-NextChord))
                    (loop))
               ((or (zero? midi) (and  (= command #xE0) (> note 32)))
                    (d-SetBackground #xFFFFFF)
                    (disp "Abandoning getting chords\n"))
               (else (d-PutMidi midi)))))) ;;; end of GetChords

    ;;;;;;;; actual code
    (set! ChordEntry::active #t)
    (d-InputFilterNames (_ "Chord entry without pedal"))
    (d-SetBackground #xC0E0E0)
    (GetChords)))

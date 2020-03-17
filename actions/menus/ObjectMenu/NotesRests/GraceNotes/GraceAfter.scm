;;GraceAfter
(let ((tag "GraceAfter"))
(if 	(d-Directive-chord? tag)
	(d-DirectiveDelete-chord tag)
	(begin
 		(d-DirectivePut-chord-prefix tag "\\GraceAfter ")
 		(d-DirectivePut-chord-display tag (_ "GraceAfter"))
 		(d-DirectivePut-chord-override tag DENEMO_OVERRIDE_AFFIX)
 		(d-DirectivePut-score-prefix tag "GraceAfter = #(define-music-function (parser location note graces) (ly:music? ly:music?)
			 (if (null? (ly:music-property graces 'element))
			     (begin
			      (ly:warning \"No grace notes follow this note the afterGrace will be ignored.\")
			      (make-music
				      'SequentialMusic 
				      'elements
				      (list note graces)))
			     (let ((thegraces  (ly:music-property (list-ref (ly:music-property 
				                             (ly:music-property graces 'element) 'elements) 1) 'elements)))
				(define gracenotes (make-music 'GraceMusic 'element (make-music
				                'SequentialMusic
				                'elements
				                thegraces)))
				  
				   (make-music
				      'SimultaneousMusic 
				      'elements
				      (list
				         note 
				        (make-music
				         'SequentialMusic
				          'elements
				          (list
				                 (make-music
				                      'SkipMusic
				                      'duration
				                      (ly:make-duration 0 0 3/16))
				                    gracenotes)))))))")
  		(d-DirectivePut-score-override tag DENEMO_OVERRIDE_AFFIX)
		(d-SetSaved #f))))

 (define (Dynamics::Put graphic lily)
(d-DirectivePut-chord-graphic "Dynamic"  graphic)
(d-DirectivePut-chord-gx "Dynamic"  -10)
(d-DirectivePut-chord-gy "Dynamic"  30)
(d-DirectivePut-chord-postfix "Dynamic"  lily)
(d-DirectivePut-chord-minpixels  "Dynamic" 20)
(d-RefreshDisplay))
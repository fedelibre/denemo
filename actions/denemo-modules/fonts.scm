;;; Emmentaler rests
(define REST0 "")
(define REST1 "")

(define REST2 "")
(define REST3 "")
(define REST4 "")
(define REST5 "")
(define REST6 "")
(define REST7 "")

(define Rest0  (string-append "\n" REST0 "\nemmentaler"))
(define Rest1  (string-append "\n" REST1 "\nemmentaler"))
(define Rest2  (string-append "\n" REST2 "\nemmentaler"))
(define Rest3  (string-append "\n" REST3 "\nemmentaler"))
(define Rest4  (string-append "\n" REST4 "\nemmentaler"))
(define Rest5  (string-append "\n" REST5 "\nemmentaler"))
(define Rest6  (string-append "\n" REST6 "\nemmentaler"))
(define Rest7  (string-append "\n" REST7 "\nemmentaler"))
(define Rests (vector Rest0 Rest1 Rest2 Rest3 Rest4 Rest5 Rest6 Rest7 ))

;;; Articulation Symbols
(define DENEMO_STACCATO "")
(define DENEMO_STACCATISSIMO "")
(define DENEMO_ACCENT  "")
(define DENEMO_EXPRESSIVO "")
(define DENEMO_MARCATO "")
(define DENEMO_TENUTO "")
(define DENEMO_PORTATO "")
(define DENEMO_UPBOW "")
(define DENEMO_DOWNBOW "")
(define DENEMO_THUMB "")
(define DENEMO_LHEEL "")
(define DENEMO_RHEEL "")
(define DENEMO_HARMONIC "")
(define DENEMO_SNAPPIZZICATO "")
(define DENEMO_ARPEGGIO "")
(define DENEMO_ARPEGGIATODOWN "\xF0\x9D\x86\x84")
(define DENEMO_ARPEGGIATOUP "\xF0\x9D\x86\x83")
(define DENEMO_STOPPED "")
(define DENEMO_PLUSNOTEHEAD "")
(define DENEMO_FERMATA "")
(define DENEMO_SHORTFERMATA "")
(define DENEMO_LONGFERMATA "")
(define DENEMO_VERYLONGFERMATA "")
;;; Ornamentation Symbols
(define DENEMO_UPPRALL "\xEE\x86\x90")
(define DENEMO_MORDENT "")
(define DENEMO_TRILL "")
(define DENEMO_TURN "")
(define DENEMO_PRALLMORDENT "")
(define DENEMO_PRALLPRALL "")
(define DENEMO_PRALL "")
(define DENEMO_UPPRALL "")
(define DENEMO_DOWNPRALL "")
(define DENEMO_UPMORDENT "")
(define DENEMO_DOWNMORDENT "")
(define DENEMO_PRALLDOWN "")
(define DENEMO_PRALLUP "")
(define DENEMO_LINEPRALL "")
(define DENEMO_SIGNUMCONGRUENTIAE "")
(define DENEMO_REVERSETURN "")
;(define DENEMO_ARPEGGIO "")
;(define DENEMO_GRACE "")
;;; Control Flow
(define DENEMO_SEGNO "")
(define DENEMO_CODA "")
(define DENEMO_VARCODA "")

(define LG-Staccato (string-append "\n" DENEMO_STACCATO "\nemmentaler"))
(define LG-Staccatissimo (string-append "\n" DENEMO_STACCATISSIMO "\nemmentaler"))
(define LG-Accent (string-append "\n" DENEMO_ACCENT "\nemmentaler"))
(define LG-Expressivo (string-append "\n" DENEMO_EXPRESSIVO "\nemmentaler"))
(define LG-Marcato (string-append "\n" DENEMO_MARCATO "\nemmentaler"))
(define LG-Tenuto (string-append "\n" DENEMO_TENUTO "\nemmentaler"))
(define LG-Expressivo (string-append "\n" DENEMO_EXPRESSIVO "\nemmentaler"))
(define LG-Portato (string-append "\n" DENEMO_PORTATO "\nemmentaler"))
(define LG-UpBow (string-append "\n" DENEMO_UPBOW "\nemmentaler"))
(define LG-DownBow (string-append "\n" DENEMO_DOWNBOW "\nemmentaler"))
(define LG-Thumb (string-append "\n" DENEMO_THUMB "\nemmentaler"))
(define LG-Lheel (string-append "\n" DENEMO_LHEEL "\nemmentaler"))
(define LG-Rheel (string-append "\n" DENEMO_RHEEL "\nemmentaler"))
(define LG-Harmonic (string-append "\n" DENEMO_HARMONIC "\nemmentaler"))
(define LG-Snappizzicato (string-append "\n" DENEMO_SNAPPIZZICATO "\nemmentaler"))
(define LG-Arpeggio (string-append "\n" DENEMO_ARPEGGIO "\nemmentaler"))
(define LG-ArpeggiatoDown (string-append "\n" DENEMO_ARPEGGIATODOWN "\nemmentaler"))
(define LG-ArpeggiatoUp (string-append "\n" DENEMO_ARPEGGIATOUP "\nemmentaler"))
(define LG-Stopped (string-append "\n" DENEMO_STOPPED "\nemmentaler"))
(define LG-PlusNoteHead (string-append "\n" DENEMO_PLUSNOTEHEAD "\nemmentaler"))
(define LG-Fermata (string-append "\n" DENEMO_FERMATA "\nemmentaler"))
(define LG-ShortFermata (string-append "\n" DENEMO_SHORTFERMATA "\nemmentaler"))
(define LG-LongFermata (string-append "\n" DENEMO_LONGFERMATA "\nemmentaler"))
(define LG-VeryLongFermata (string-append "\n" DENEMO_VERYLONGFERMATA "\nemmentaler"))
(define LG-Upprall (string-append "\n" DENEMO_UPPRALL "\nemmentaler"))
(define LG-Mordent (string-append "\n" DENEMO_MORDENT "\nemmentaler"))
(define LG-Trill (string-append "\n" DENEMO_TRILL "\nemmentaler"))
(define LG-Turn (string-append "\n" DENEMO_TURN "\nemmentaler"))
(define LG-PrallMordent (string-append "\n" DENEMO_PRALLMORDENT "\nemmentaler"))
(define LG-PrallPrall (string-append "\n" DENEMO_PRALLPRALL "\nemmentaler"))
(define LG-Prall (string-append "\n" DENEMO_PRALL "\nemmentaler"))
(define LG-UpPrall (string-append "\n" DENEMO_UPPRALL "\nemmentaler"))
(define LG-DownPrall (string-append "\n" DENEMO_DOWNPRALL "\nemmentaler"))
(define LG-UpMordent (string-append "\n" DENEMO_UPMORDENT "\nemmentaler"))
(define LG-DownMordent (string-append "\n" DENEMO_DOWNMORDENT "\nemmentaler"))
(define LG-PrallDown (string-append "\n" DENEMO_PRALLDOWN "\nemmentaler"))
(define LG-PrallUp (string-append "\n" DENEMO_PRALLUP "\nemmentaler"))
(define LG-LinePrall (string-append "\n" DENEMO_LINEPRALL "\nemmentaler"))
(define LG-Signumcongruentiae (string-append "\n" DENEMO_SIGNUMCONGRUENTIAE"\nemmentaler"))
(define LG-ReverseTurn (string-append "\n" DENEMO_REVERSETURN "\nemmentaler"))
;(define LG-Arpeggio (string-append "\n" DENEMO_ARPEGGIO "\nemmentaler"))
;(define LG-Grace (string-append "\n" DENEMO_GRACE "\nemmentaler"))
(define LG-Segno (string-append "\n" DENEMO_SEGNO "\nemmentaler"))
(define LG-Coda (string-append "\n" DENEMO_CODA "\nemmentaler"))
(define LG-Varcoda (string-append "\n" DENEMO_VARCODA "\nemmentaler"))


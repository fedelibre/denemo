
%% LilyPond file generated by Denemo version 0.8.19

%%http://www.gnu.org/software/denemo/

\version "2.10"
\paper {
}
#(set-default-paper-size "a4"
)
#(set-global-staff-size 18)

\header{
}

Barline = |

% The music follows

MvmntIVoiceI =  {
          r4 cis'' r8. r16 r8 r \barNumberCheck #10
         R1*4/4 %{r1%} \Barline
         a'4 bes'8. c''16 d''2 \bar "|."
}



        MvmntIVoiceITimeSig = \time 4/4 
MvmntIVoiceIKeySig = \key aes \minor
 MvmntIVoiceIClef = \clef "G"
MvmntIVoiceIProlog = { \MvmntIVoiceITimeSig \MvmntIVoiceIKeySig \MvmntIVoiceIClef}
MvmntIVoiceIMusic =  {\MvmntIVoiceIProlog \MvmntIVoiceI}
MvmntIVoiceIContext = \context Voice = VoiceIMvmntI  {\MvmntIVoiceIMusic}
MvmntIStaffI = \new Staff  << {
                \MvmntIVoiceIContext
                }
                >>



\score {
<< <<
\MvmntIStaffI
>>
>>
\layout{
        }
\header{
        }

}




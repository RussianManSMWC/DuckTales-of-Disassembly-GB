Layout_TitleScreen_02_6198:
dwb $9840
db 20
db $6E,$91,$92,$93,$94,$95,$6E,$97
db $98,$99,$9A,$9A,$9C,$6E,$9E,$9F
db $80,$81,$82,$83

dwb $9860
db 20
db $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7
db $A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
db $84,$85,$86,$87

dwb $9880
db 20
db $CC,$B1,$B2,$B3,$B4,$B5,$B6,$B7
db $B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
db $88,$89,$8A,$8B

dwb $98A0
db 20
db $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7
db $C8,$C9,$CA,$CB,$6E,$CD,$CE,$CF
db $8C,$8D,$9D,$90

dwb $98C0
db 11
db $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7
db $D8,$D9,$9B

;difficulty options
dwb $9907
db 4
db "EASY"

dwb $9927
db 6
db "NORMAL"

dwb $9947
db 9
db "DIFFICULT"

;copyright text starts here
dwb $99A1
db 17
db "© THE WALT DISNEY"

dwb $99C1
db 18
db "COMPANY / PRODUCED"

dwb $99E3
db 14
db "BY 1990 CAPCOM"                                         ;not to be confused with 1991 CAPCOM

db StripeImageWriteCommand_Stop
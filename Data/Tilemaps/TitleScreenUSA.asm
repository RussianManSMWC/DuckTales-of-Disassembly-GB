Layout_TitleScreen_02_6198:
dwb $9800
db 6
db $6E,$6E,$6E,$81,$82,$83

dwb $9820
db 6
db $6E,$6E,$6E,$91,$92,$93

dwb $9840
db 16
db $6E,$6E,$A0,$A1,$A2,$A3,$A4,$6E
db $6E,$A7,$A8,$A9,$AA,$AB,$AC,$6E

dwb $9860
db 20
db $6E,$6E,$B0,$B1,$B2,$B3,$B4,$6E
db $6E,$B7,$B8,$B9,$BA,$BB,$BC,$BD
db $BE,$BF,$94,$6E

dwb $9880
db 20
db $6E,$6E,$C0,$C1,$C2,$C3,$C4,$C5
db $C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD
db $CE,$CF,$85,$6E

dwb $98A0
db 18
db $6E,$80,$D0,$D1,$D2,$D3,$D4,$D5
db $D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD
db $DE,$DF

dwb $98C0
db 18
db $6E,$90,$E0,$E1,$E2,$E3,$E4,$E5
db $E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED
db $EE,$EF

dwb $98E0
db 12
db $6E,$84,$F0,$F1,$F2,$F3,$F4,$F5
db $F6,$F7,$F8,$F9

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
dwb $9981
db 17
db "© THE WALT DISNEY"

dwb $99A1
db 18
db "COMPANY / PRODUCED"

dwb $99C1
db 18
db "BY CAPCOM CO.,LTD./"

dwb $99E1
db 18
db "CAPCOM U.S.A..,INC."

dwb $9A00
db 20
db "LICENSED BY NINTENDO"

dwb $9A23
db 15
db "OF AMERICA INC."

db StripeImageWriteCommand_Stop
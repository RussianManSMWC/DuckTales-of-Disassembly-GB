Layout_TitleScreen_02_6198:
db $98,$00
db 6
db $6E,$6E,$6E,$81,$82,$83

db $98,$20
db 6
db $6E,$6E,$6E,$91,$92,$93

db $98,$40
db 16
db $6E,$6E,$A0,$A1,$A2,$A3,$A4,$6E
db $6E,$A7,$A8,$A9,$AA,$AB,$AC,$6E

db $98,$60
db 20
db $6E,$6E,$B0,$B1,$B2,$B3,$B4,$6E
db $6E,$B7,$B8,$B9,$BA,$BB,$BC,$BD
db $BE,$BF,$94,$6E

db $98,$80
db 20
db $6E,$6E,$C0,$C1,$C2,$C3,$C4,$C5
db $C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD
db $CE,$CF,$85,$6E

db $98,$A0
db 18
db $6E,$80,$D0,$D1,$D2,$D3,$D4,$D5
db $D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD
db $DE,$DF

db $98,$C0
db 18
db $6E,$90,$E0,$E1,$E2,$E3,$E4,$E5
db $E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED
db $EE,$EF

db $98,$E0
db 12
db $6E,$84,$F0,$F1,$F2,$F3,$F4,$F5
db $F6,$F7,$F8,$F9

;difficulty options
db $99,$07
db 4
db "EASY"

db $99,$27
db 6
db "NORMAL"

db $99,$47
db 9
db "DIFFICULT"

;copyright text starts here
db $99,$81
db 17
db "© THE WALT DISNEY"

db $99,$A1
db 18
db "COMPANY / PRODUCED"

db $99,$C1
db 18
db "BY CAPCOM CO.,LTD./"

db $99,$E1
db 18
db "CAPCOM U.S.A..,INC."

db $9A,$00
db 20
db "LICENSED BY NINTENDO"

db $9A,$23
db 15
db "OF AMERICA INC."

db StripeImageWriteCommand_Stop
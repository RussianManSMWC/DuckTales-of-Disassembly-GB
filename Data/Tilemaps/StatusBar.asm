Layout_StatusBar_02_62BD:
dwb $9C00
db $01
db $4D

dwb $9C13
db $01
db $4F

dwb $9C20
db $01
db $68

dwb $9C33
db $01
db $78

;HP/TIME line
dwb $9C40
db $14
db $68
db "HP ",$4C,$4C,$4C
db "   "                                                    ;space between time and HP
db "TIME 000 "                                              ;shows 000 time by default
db $78

dwb $9C60
db $01
db $5D

dwb $9C61
db $92
db $5E

dwb $9C73
db $01
db $5F

dwb $9C02
db $08
db "TOTAL  $"

dwb $9C22
db $08
db "P. 0"                                                   ;zero lives by default (naturally gets replaced later)
db "   "                                                    ;space between lives and current dollar count
db "$"

db StripeImageWriteCommand_Stop
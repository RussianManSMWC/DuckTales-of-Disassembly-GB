Layout_StatusBar_02_62BD:
db $9C,$00
db $01
db $4D

db $9C,$13
db $01
db $4F

db $9C,$20
db $01
db $68

db $9C,$33
db $01
db $78

;HP/TIME line
db $9C,$40
db $14
db $68
db "HP ",$4C,$4C,$4C
db "   "                                                    ;space between time and HP
db "TIME 000 "                                              ;shows 000 time by default
db $78

db $9C,$60
db $01
db $5D

db $9C,$61
db $92
db $5E

db $9C,$73
db $01
db $5F

db $9C,$02
db $08
db "TOTAL  $"

db $9C,$22
db $08
db "P. 0"                                                   ;zero lives by default (naturally gets replaced later)
db "   "                                                    ;space between lives and current dollar count
db "$"

db StripeImageWriteCommand_Stop
SECTION "bank 3", ROMX, BANK[3]

POINTERS_03_4000:
dw Graphics_PlayerSprites1_03_4320
dw Graphics_PlayerSprites2_03_46CF
dw Graphics_AmazonSprites1_03_4AA3
dw Graphics_AmazonSprites2_03_4E7B
dw Graphics_SupportingCharacters_03_525D
dw Graphics_AfricanMinesSprites_03_55F6
dw Graphics_HimalayasAndTransylvaniaSprites2_03_59CD
dw Graphics_HimalayasSprites_03_5D97
dw Graphics_AmazonTileset_03_6151
dw Graphics_HimalayasTileset_03_6525
dw Graphics_TransylvaniaTileset_03_68BE
dw Graphics_AfricanMinesTileset_03_6C9A
dw Graphics_MoonTileset_03_704C
dw Graphics_EnglishFontAndStatusBar_03_7424
dw Graphics_TitleScreen_03_7768
dw Graphics_Ending_03_7AA3
dw DATA_03_7DE9                                             ;stripe data starts here
dw DATA_03_7E30
dw DATA_03_7E61
dw Message_EndingNephews_03_7ED3
dw Message_EndingScroogeMessage_03_7F42

CODE_03_402A:
JP CODE_03_7FB1

CODE_03_402D:
JP CODE_03_7E1C

;currently unknown, but it doesn't look like graphics...
DATA_03_4030:
db $08
db $08,$04,$6E,$12,$13,$12,$13
db $12,$13,$10,$11,$08,$04,$7F,$06
db $07,$16,$17,$7F,$7F,$10,$11,$6E
db $6E,$16,$17,$26,$27,$36,$37,$26
db $47,$56,$57,$44,$27,$54,$55,$26
db $27,$45,$46,$6A,$6B,$7A,$7B,$6C
db $6D,$7C,$7D,$10,$10,$11,$11,$74
db $75,$12,$13,$76,$77,$16,$17,$6F
db $6F,$10,$10,$11,$6F,$11,$6F,$6F
db $11,$10,$12,$11,$6F,$02,$10,$11
db $6F,$13,$10,$08,$05,$6F,$11,$6F
db $11,$08,$05,$56,$00,$00,$6E,$57
db $56,$6E,$57,$47,$6E,$56,$47,$6E
db $46,$46,$56,$08,$04,$7E,$07,$17
db $06,$07,$02,$03,$7F,$7F,$06,$6F
db $16,$17,$6F,$46,$17,$07,$06,$6F
db $06,$6F,$6F,$46,$6F,$46,$56,$57
db $16,$17,$57,$47,$17,$07,$08,$04
db $01,$56,$57,$06,$6F,$57,$47,$6F
db $46,$08,$04,$26,$6E,$6E,$10,$10
db $00,$00,$10,$16,$07,$77,$06,$77
db $17,$6E,$17,$6E,$6E,$11,$6E,$11
db $11,$07,$11,$06,$08,$20,$00,$10
db $11,$01,$01,$14,$15,$10,$11,$15
db $15,$11,$11,$04,$05,$10,$11,$04
db $05,$11,$11,$08,$04,$7F,$63,$51
db $7F,$73,$63,$7F,$63,$73,$7F,$51
db $63,$73,$63,$51,$63,$73,$7F,$7F
db $54,$08,$04,$7F,$13,$04,$05,$05
db $15,$04,$05,$14,$04,$04,$05,$05
db $04,$08,$04,$15,$76,$12,$76,$12
db $13,$77,$13,$77,$13,$67,$13,$67
db $62,$63,$72,$74,$63,$64,$75,$73
db $72,$6E,$72,$6E,$6E,$73,$6E,$73
db $34,$35,$35,$34,$66,$12,$66,$12
db $02,$03,$01,$01,$04,$05,$14,$15
db $08,$04,$01,$20,$21,$30,$31,$22
db $23,$32,$33,$42,$43,$52,$53,$60
db $61,$70,$71,$62,$63,$72,$73,$64
db $65,$74,$75,$72,$73,$66,$67,$74
db $75,$76,$77,$72,$73,$72,$73,$74
db $75,$74,$75,$60,$62,$70,$71,$72
db $61,$70,$71,$66,$6F,$76,$6F,$70
db $71,$04,$05,$14,$15,$04,$05,$14
db $15,$46,$47,$05,$23,$15,$33,$14
db $15,$14,$15,$15,$33,$15,$33,$14
db $15,$44,$45,$15,$33,$45,$03,$76
db $6F,$76,$6F,$67,$6F,$77,$6F,$21
db $21,$31,$31,$21,$22,$31,$32,$05
db $05,$45,$45,$66,$67,$66,$67,$76
db $77,$76,$77,$26,$27,$7F,$37,$7F
db $64,$7F,$74,$65,$7F,$75,$7F,$7F
db $7F,$32,$33,$65,$7F,$53,$33,$7F
db $64,$32,$52,$22,$23,$7F,$74,$22
db $23,$75,$7F,$7F,$27,$7F,$7F,$40
db $41,$50,$6E,$26,$27,$36,$37,$46
db $47,$6E,$6E,$56,$57,$6E,$6E,$04
db $05,$15,$15,$02,$03,$04,$05,$00
db $65,$04,$05,$36,$37,$00,$00,$7F
db $7F,$20,$21,$7F,$7F,$22,$23,$7F
db $7F,$04,$05,$06,$07,$42,$43,$06
db $07,$52,$53,$06,$07,$60,$61,$08
db $68,$00,$04,$05,$6E,$00,$46,$47
db $56,$57,$04,$05,$66,$67,$08,$04
db $00,$11,$11,$6E,$6E,$08,$5C,$00
db $20,$21,$30,$31,$22,$23,$32,$33
db $44,$45,$04,$05,$54,$55,$04,$05
db $34,$35,$44,$45,$04,$05,$14,$15
db $34,$35,$34,$35,$14,$15,$14,$15
db $15,$33,$15,$33,$44,$45,$54,$55
db $08,$04,$15,$04,$05,$15,$15,$08
db $18,$00,$6E,$24,$66,$24,$25,$6E
db $25,$67,$7F,$34,$7F,$34,$35,$7F
db $35,$7F,$6E,$24,$6E,$24,$25,$6E
db $25,$6E,$7E,$34,$7E,$34,$35,$7E
db $35,$7E,$17,$24,$17,$24,$25,$11
db $25,$11,$EC,$ED,$FC,$FD,$EE,$EF
db $FE,$FF,$EE,$EF,$FE,$FF,$EE,$EF
db $FE,$FF,$EE,$EF,$FE,$FF,$08,$08
db $00,$EE,$EF,$FE,$FF,$02,$03,$7F
db $7F,$22,$23,$7F,$7F,$7F,$10,$7F
db $13,$44,$7F,$54,$7F,$02,$12,$7F
db $7F,$11,$03,$08,$06,$7F,$42,$43
db $7F,$7F,$42,$01,$7F,$74,$00,$43
db $75,$7F,$7F,$7F,$45,$55,$61,$62
db $71,$72,$60,$61,$70,$71,$62,$60
db $72,$70,$66,$60,$76,$70,$61,$67
db $71,$77,$40,$41,$50,$51,$06,$07
db $16,$17,$08,$0C,$00,$08,$04,$7E
db $07,$17,$06,$07,$6E,$6E,$16,$17
db $12,$13,$12,$13,$06,$07,$16,$17
db $40,$41,$64,$65,$64,$65,$64,$65
db $50,$51,$54,$55,$40,$41,$50,$51
db $08,$04,$7F,$08,$04,$6E,$08
db $00

Graphics_PlayerSprites1_03_4320:
incbin "Data/Graphics/PlayerSprites1.bin"

Graphics_PlayerSprites2_03_46CF:
incbin "Data/Graphics/PlayerSprites2.bin"

Graphics_AmazonSprites1_03_4AA3:
incbin "Data/Graphics/AmazonSprites1.bin"

Graphics_AmazonSprites2_03_4E7B:
incbin "Data/Graphics/AmazonSprites2.bin"

Graphics_SupportingCharacters_03_525D:
incbin "Data/Graphics/SupportingCharacters.bin"

Graphics_AfricanMinesSprites_03_55F6:
incbin "Data/Graphics/AfricanMinesSprites.bin"

;both himalayas part 2 and transylvania part 2 for the same price... of 2!
Graphics_HimalayasAndTransylvaniaSprites2_03_59CD:
incbin "Data/Graphics/HimalayasAndTransylvaniaSprites2.bin"

Graphics_HimalayasSprites_03_5D97:
incbin "Data/Graphics/HimalayasSprites.bin"

Graphics_AmazonTileset_03_6151:
incbin "Data/Graphics/AmazonTileset.bin"

Graphics_HimalayasTileset_03_6525:
incbin "Data/Graphics/HimalayasTileset.bin"

Graphics_TransylvaniaTileset_03_68BE:
incbin "Data/Graphics/TransylvaniaTileset.bin"

Graphics_AfricanMinesTileset_03_6C9A:
incbin "Data/Graphics/AfricanMinesTileset.bin"

Graphics_MoonTileset_03_704C:
incbin "Data/Graphics/MoonTileset.bin"

Graphics_EnglishFontAndStatusBar_03_7424:
incbin "Data/Graphics/EnglishFontAndStatusBar.bin"

Graphics_TitleScreen_03_7768:
incbin "Data/Graphics/TitleScreen.bin"

Graphics_Ending_03_7AA3:
incbin "Data/Graphics/Ending.bin"

DATA_03_7DE9:
db $99,$25
db 7
db $C8,$C9,$CA,$CB,$7F,$7F,$7F

db $99,$45
db 7
db $D8,$D9,$DA,$DB,$CC,$CD,$CE

db $99,$65
db 7
db $E8,$E9,$EA,$EB,$DC,$DD,$DE

db $99,$85
db 7
db $7F,$FB,$CF,$EF,$EC,$ED,$EE

db $99,$A5
db 7
db $7F,$7F,$DF,$FF,$FC,$FD,$FE

db StripeImageWriteCommand_Stop

CODE_03_7E1C:
LD HL, $99C0
LD A, $04
LD C, A

LOOP_03_7E22:
LD B, $20

LOOP_03_7E24:
LD [HL+], A
XOR $01
DEC B
JR NZ, LOOP_03_7E24
XOR $01
DEC C
JR NZ, LOOP_03_7E22
RET

DATA_03_7E30:
db $98,$22
db 9|StripeImageCommand_Repeat
db $36

db $98,$42
db 1
db $35

db $98,$4A
db 1
db $37

db $98,$62
db 1
db $35

db $98,$6A
db 1
db $37

db $98,$82
db 1
db $35

db $98,$8A
db 1
db $37

db $98,$A2
db 1
db $35

db $98,$AA
db 1
db $37

db $98,$C2
db 1
db $35

db $98,$CA
db 1
db $37

db $98,$E2
db 9|StripeImageCommand_Repeat
db $72

db StripeImageWriteCommand_Stop

DATA_03_7E61:
db $98,$04
db 12|StripeImageCommand_Repeat
db $36

db $98,$24
db 12
db $35,$6E,$6E,$6E,$81,$82,$83,$6E
db $6E,$6E,$6E,$37

db $98,$44
db 12
db $35,$6E,$6E,$6E,$91,$92,$93,$6E,
db $6E,$6E,$6E,$37

db $98,$64
db 12
db $35,$6E,$6E,$A0,$A1,$A2,$A3,$A4
db $6E,$6E,$6E,$37

db $98,$84
db 12
db $35,$6E,$6E,$B0,$86,$87,$88,$89
db $8A,$8B,$6E,$37

db $98,$A4
db 12
db $35,$6E,$6E,$6E,$96,$97,$98,$99
db $9A,$9B,$6E,$37

db $98,$C4
db 12
db $35,$6E,$6E,$FC,$8C,$8D,$8E,$8F
db $AD,$AE,$6E,$37

db $98,$E4
db 12
db $35,$6E,$6E,$AF,$9C,$9D,$9E,$9F
db $FE,$FF,$6E,$37

db $99,$04
db 12|StripeImageCommand_Repeat
db $72

db StripeImageWriteCommand_Stop

;ending messages
include "Data/EndingMessages/EndingNephews.asm"
include "Data/EndingMessages/EndingScrooge.asm"

;load ending messages
CODE_03_7FB1:
LD A, $80                                                   ;message type = ending message.
LD [CurrentMessageType], A

LDH A, [$FF94]
AND $01
LD HL, POINTERS_03_4000+(19*2)                              ;loads message from nephews.
RST $28
LD H, D
LD L, E
LD A, $99
LD [$C1B0], A

LD A, $41
LD [$C1B1], A

LD A, $01
LD [$C1B2], A

XOR A
LD [$C1B4], A
RET

;entity data. I think these are actually scripts of some kind.
;here's some bare documentation (to be improved/sorted (e.g. turn data into proper command macros)
;command $00 - no arguments
;command $01 - no arguments (does nothing, unused)
;command $02 - 1 byte worth of arguments
;command $03 - 1 byte worth of arguments
;command $04 - no arguments
;command $05 - no arguments
;command $06 - no arguments
;command $07 - no arguments
;command $08 - no arguments
;command $09 - 1 byte worth of arguments
;command $0A - no arguments
;command $0B - no arguments
;command $0C - no arguments
;command $0D - no arguments
;command $0E - no arguments
;command $0F - no arguments (stop for a frame)
;command $10 - 2 bytes worth of arguments (pointer)
;command $11 - no arguments
;command $12 - 1 byte worth of arguments
;command $13 - 1 byte worth of arguments
;command $14 - 2 bytes worth of arguments (pointer)
;command $15 - 2 bytes worth of arguments (pointer)
;command $16 - 1 byte worth of arguments
;command $17 - no arguments
;command $18 - no arguments
;command $19 - 2 bytes worth of arguments (pointer)
;command $1A - 1 byte worth of arguments
;command $1B - no arguments
;command $1C - 1 byte worth of arguments
;command $1D - no arguments
;command $1E - 1 byte worth of arguments
;command $1F - 3 bytes worth of arguments (pointer, then value)
;command $20 - 1 byte worth of arguments
;command $21 - 1 byte worth of arguments
;command $22 - no arguments
;command $23 - no arguments
;command $24 - no arguments
;command $25 - no arguments
;command $26 - no arguments
;command $27 - no arguments
;command $28 - 1 byte worth of arguments
;command $29 - 1 byte worth of arguments
;command $2A - 1 byte worth of arguments
;command $2B - 1 byte worth of arguments
;command $2C - no arguments
;command $2D - no arguments
;command $2E - no arguments
;command $2F - 1 byte worth of arguments
;command $30 - no arguments
;command $31 - no arguments
;command $32 - no arguments
;command $33 - no arguments
;command $34 - no arguments
;command $35 - no arguments
;command $36 - no arguments
;command $37 - 3 bytes worth of arguments (value, then pointer)
;command $38 - at least 1 byte worth of arguments. if equal or above $0F, then takes 2 more bytes (pointer). otherwise depends on the executed pointer from $00-$0F:
;0 through 5 - no arguments
;6 - 1 byte worth of arguments
;7 through 9 - no arguments
;
;command $39 - 1 byte worth of arguments
;
;if only bit 6 is enabled, the rest of bits set a timer, halt execution until timer runs out
;if only bit 7 is enabled, execute some code (usually taking 2 bytes worth of arguments (pointer)
;
;if bits 6 AND 7 are enabled, constant jump, the byte is counted as high byte of destination, and the byte immediately after is low byte (in data, marked as dwb DATA | $C000
DATA_00_2535:
db $34

DATA_00_2536:
db $37,$3E
dw DATA_00_2540

db $37,$3F
dw DATA_00_2540

dwb DATA_00_2536 | $C000

DATA_00_2540:
db $12,$04

DATA_00_2542:
db $08
db $0E
db $0F

db $38,$02

db $81
dw DATA_00_254E

db $14
dw DATA_00_2542

db $11

DATA_00_254E:
db $05
db $11

DATA_00_2550:
db $1A,$10
db $21,$01

db $37,$3E
dw DATA_00_3163

db $34

DATA_00_2559:
db $37,$3F
dw DATA_00_2563

db $37,$3E
dw DATA_00_2563

dwb DATA_00_2559 | $C000

DATA_00_2563:
db $12,$04

DATA_00_2565:
db $08
db $0F

db $81
dw DATA_00_2571

DATA_00_256A:
db $0E
db $08
db $0F

db $14
dw DATA_00_2565

db $11

DATA_00_2571:
db $80 | $20
dw DATA_00_256A

db $03,$FA

dwb DATA_00_2563 | $C000

DATA_00_2578:
db $1A,$06

db $10
dw DATA_00_3146

db $60

DATA_00_257E:
db $16,$40
db $1A,$02

DATA_00_2582:
db $30
db $08
db $08
db $0E
db $0F

db $80 | $20
dw DATA_00_2582

db $31
db $32
db $05

DATA_00_258D:
db $37,$41
dw DATA_00_259F

db $37,$42
dw DATA_00_259F

db $37,$43
dw DATA_00_259F

db $37,$40
dw DATA_00_259F

dwb DATA_00_258D | $C000

DATA_00_259F:
db $39,SFX_Boulder
db $12,$03

DATA_00_25A3:
db $08
db $38,$02

db $80 | $20
dw DATA_00_2582

db $08

db $80 | $01
dw DATA_00_25B2

db $08

db $14
dw DATA_00_25A3

db $11

DATA_00_25B2:
db $05
db $11

DATA_00_25B4:
db $1A,$10
db $21,$02,$1C

db $34

db $81
dw DATA_00_313B

db $31,$34,$17

DATA_00_25C0:
db $13,$02

DATA_00_25C2:
db $37,$44
dw DATA_00_2563

db $37,$45
dw DATA_00_2563

db $37,$46
dw DATA_00_2563

db $37,$45
dw DATA_00_2563

db $15
dw DATA_00_25C2
db $81
dw DATA_00_25C0

db $16,$6A
db $58

db $19
dw DATA_00_25E3

db $16,$6B
db $60

dwb DATA_00_25C0 | $C000

DATA_00_25E3:
db $1A,$02
db $39,SFX_SpearThrow
db $16,$36
db $26

DATA_00_25EA:
db $08
db $08
db $08
db $08

db $A1
dw DATA_00_25EA

db $00

;piranha plant from Amazon
DATA_00_25F2:
db $1A,$22
db $21,$02,$1C
db $40
db $34

db $37,$2B
dw DATA_00_3163

DATA_00_25FD:
db $16,$2B
db $48

db $A2
dw DATA_00_25FD

;player close, start biting animation
db $16,$31
db $4C

db $16,$32
db $48

db $84
dw DATA_00_260E

dwb DATA_00_25FD | $C000

;scripting for when player lands on top of it. gets bitten and spat out after
DATA_00_260E:
db $39,SFX_PlantCatch
db $16,$32
db $05
db $7F                                                      ;wait a bit

db $39,SFX_PlantSpit
db $38,$07
db $1B
db $16,$47
db $4C
db $1A
db $22
dwb DATA_00_25FD | $C000

DATA_00_2620:
db $1C,$50
db $21,$02
db $38,$02
db $34
db $02
db $04

db $9C
dw DATA_00_262E

db $02
db $08

DATA_00_262E:
db $07
db $37,$5B
dw DATA_00_3163

DATA_00_2633:
db $BC
dw DATA_00_2639

db $02
db $F8
db $07

DATA_00_2639:
db $12,$06

DATA_00_263B:
db $16,$5B
db $48
db $16,$5C
db $48

db $14
dw DATA_00_263B

db $BC
dw DATA_00_264A

db $02
db $08
db $07

DATA_00_264A:
db $16,$34

db $39,SFX_Snake
db $12,$02

DATA_00_2650:
db $16,$34
db $4C
db $16,$35
db $4C

db $14
dw DATA_00_2650

dwb DATA_00_2633 | $C000

DATA_00_265B:
db $16,$8C

DATA_00_265D:
db $44,$27

dwb DATA_00_265D | $C000

DATA_00_2661:
db $1C,$30
db $21,$03

db $19
dw DATA_00_265B

DATA_00_2668:
db $16,$6C
db $50

db $83
dw DATA_00_2676

db $16,$6D
db $50

db $83
dw DATA_00_2676

dwb DATA_00_2668 | $C000

DATA_00_2676:
db $03,$02

db $10
dw DATA_00_268D

db $03,$FE

db $10
dw DATA_00_268D

db $12,$04

DATA_00_2682:
db $16,$6C
db $50
db $16,$6D
db $50

db $14
dw DATA_00_2682

dwb DATA_00_2668 | $C000

DATA_00_268D:
db $12,$02

DATA_00_268F:
db $16,$6C

db $07
db $07
db $0F

db $07
db $07
db $0F

db $07
db $07
db $0F

db $16,$6D
db $07
db $07
db $0F

db $07
db $07
db $0F

db $07
db $07
db $0F

db $14
dw DATA_00_268F

db $11

DATA_00_26A9:
db $1A,$10
db $21,$01
db $1C,$22
db $34
db $17

DATA_00_26B1:
db $16,$1E
db $0B
db $0F

db $07
db $39,SFX_Bee
db $16,$1A
db $0B
db $0F

db $07
db $39,SFX_Bee

dwb DATA_00_26B1 | $C000

DATA_00_26C1:
db $21,$01
db $16,$22
db $32
db $26

DATA_00_26C7:
db $12,$02

DATA_00_26C9:
db $37,$22
dw DATA_00_26D8

db $37,$23
dw DATA_00_26D8

db $14
dw DATA_00_26C9

db $43
db $05

dwb DATA_00_26C7 | $C000

DATA_00_26D8:
db $13,$04

DATA_00_26DA:
db $07
db $0F

db $15
dw DATA_00_26DA

db $11

DATA_00_26E0:
db $21,$03

db $37,$24
dw DATA_00_3146

db $03,$02

db $37,$37
dw DATA_00_26FC

db $37,$38
dw DATA_00_26FC

DATA_00_26F0:
db $32
db $04

DATA_00_26F2:
db $37,$37
dw DATA_00_2707

db $37,$38
dw DATA_00_2707

dwb DATA_00_26F2 | $C000

DATA_00_26FC:
db $13,$04

DATA_00_26FE:
db $08
db $0F

db $0F

db $08
db $0F

db $15
dw DATA_00_26FE

db $11

DATA_00_2707:
db $13,$04

DATA_00_2709:
db $0C
db $0F

db $08
db $0F

db $82
dw DATA_00_2715

db $15
dw DATA_00_2709

db $31
db $11

DATA_00_2715:
db $16,$24
db $30

db $0E
db $0F

db $08
db $0F

db $80 | $20
dw DATA_00_2715

db $13,$04

DATA_00_2721:
db $16,$39
db $48
db $16,$3A
db $48

db $15
dw DATA_00_2721

db $03,$FE

db $37,$37
dw DATA_00_26FC

db $37,$38
dw DATA_00_26FC

db $31
dwb DATA_00_26F0 | $C000

;Entity
DATA_00_2737:
db $1A,$00
db $18
db $2B,$89
db $03,$FA

db $10
dw DATA_00_3141

db $48
db $17

db $1F
dw DATA_00_277B
db $01

db $37,$5D
dw DATA_00_2767

db $19
dw DATA_00_2786

db $10
dw DATA_00_2767

db $10
dw DATA_00_2767

db $48
db $37,$48
dw DATA_00_2767

db $10
dw DATA_00_2767

db $10
dw DATA_00_2767

db $19
dw DATA_00_2786

DATA_00_2762:
db $10
dw DATA_00_2767

dwb DATA_00_2762 | $C000

DATA_00_2767:
db $12,$02

DATA_00_2769:
db $07
db $0F

db $07
db $0F

db $9B
dw DATA_00_2780

db $07
db $0F

db $0E
db $0F

db $9B
dw DATA_00_2780

db $14
dw DATA_00_2769

db $11

DATA_00_277B:
db $19
dw DATA_00_2780
dwb DATA_00_314B | $C000

DATA_00_2780:
db $7F,$7F,$7F,$7F

dwb DATA_00_2737 | $C000

DATA_00_2786:
db $1A,$80
db $2B,$62
db $16,$1F
db $4C
db $16,$20
db $46
db $16,$21
db $46
db $00

;Entity
DATA_00_2794:
db $1F
dw DATA_00_27F0
db $01

db $21,$02
db $1C,$30
db $03,$FA
db $07

db $31

DATA_00_27A0:
db $37,$25
dw DATA_00_27AA

db $37,$26
dw DATA_00_27AA

dwb DATA_00_27A0 | $C000

DATA_00_27AA:
db $48
db $83
dw DATA_00_27AF

db $11

DATA_00_27AF:
db $32
db $26

DATA_00_27B1:
db $12,$02

DATA_00_27B3:
db $37,$25
dw DATA_00_27E0

db $37,$26
dw DATA_00_27E0

db $14
dw DATA_00_27B3

db $19
dw DATA_00_27E9

db $16,$2C
db $03,$FC
db $12,$04

DATA_00_27C7:
db $10
dw DATA_00_27D9

db $14
dw DATA_00_27C7

db $16,$27

DATA_00_27CF:
db $10
dw DATA_00_27D9

db $A0
dw DATA_00_27CF

db $05
db $31
dwb DATA_00_27B1 | $C000

DATA_00_27D9:
db $09,$08
db $09,$08
db $0E
db $0F
db $11

DATA_00_27E0:
db $13,$04

DATA_00_27E2:
db $07
db $0F
db $07
db $15
dw DATA_00_27E2
db $11

DATA_00_27E9:
db $03,$10
db $07
db $16,$1B
db $4C
db $00

DATA_00_27F0:
db $16,$2C
dwb DATA_00_314B | $C000

;Entity
DATA_00_27F4:
db $21,$04
db $1C,$44
db $48

db $37,$79
dw DATA_00_3163

DATA_00_27FD:
db $44

db $AA
dw DATA_00_27FD

db $34

DATA_00_2802:
db $37,$79
dw DATA_00_280C

db $37,$6E
dw DATA_00_280C

dwb DATA_00_2802 | $C000

DATA_00_280C:
db $13,$08

DATA_00_280E:
db $0E

db $AA
dw DATA_00_282E

db $08
db $0F

db $81
dw DATA_00_281B

db $15
dw DATA_00_280E

db $11

DATA_00_281B:
db $16,$49
db $48
db $16,$5E
db $48

db $19
dw DATA_00_2835

db $16,$4A
db $48
db $16,$7A
db $48
db $16,$63
db $48
db $11

DATA_00_282E:
db $05

DATA_00_282F:
db $0E
db $08
db $08
db $0F

dwb DATA_00_282F | $C000

DATA_00_2835:
db $1A,$80
db $29,$FF
db $16,$16
db $07
db $07

dwb DATA_00_2F25 | $C000

;Entity
DATA_00_283F:
db $1A,$10
db $21,$03
db $60

db $37,$6F
dw DATA_00_3163

db $34

DATA_00_2849:
db $16,$6F
db $03,$FC

DATA_00_284D:
db $08
db $09,$01
db $0F

db $08
db $0E
db $08

db $A0
dw DATA_00_284D

db $16,$4B
db $44

dwb DATA_00_2849 | $C000

;Entity
DATA_00_285C:
db $37,$19
dw DATA_00_3146

db $48

DATA_00_2861:
db $0E
db $07
db $07
db $0F

db $07
dwb DATA_00_2861 | $C000

DATA_00_2868:
db $21,$03
db $48

db $34

db $37,$4D
dw DATA_00_3163

DATA_00_2870:
db $37,$4C
dw DATA_00_2563

db $37,$4D
dw DATA_00_2563

db $37,$4E
dw DATA_00_2563

db $37,$4D
dw DATA_00_2563

dwb DATA_00_2870 | $C000

;Entity
DATA_00_2882:
db $21,$02
db $33
db $12,$02

DATA_00_2887:
db $37,$2D
dw DATA_00_28A3

db $37,$2E
dw DATA_00_28A3

db $14
dw DATA_00_2887

db $03,$FF
db $12,$02

DATA_00_2896:
db $37,$2D
dw DATA_00_28A3

db $37,$2E
dw DATA_00_28A3

db $14
dw DATA_00_2896

dwb DATA_00_2882 | $C000

DATA_00_28A3:
db $07
db $0F

db $07
db $0F

db $07
db $0F

db $07
db $0F
db $11

;Entity
DATA_00_28AC:
db $21,$02
db $50

db $37,$50
dw DATA_00_3163

db $34

DATA_00_28B4:
db $12,$04

DATA_00_28B6:
db $37,$4F
dw DATA_00_28C4

db $37,$50
dw DATA_00_28C4

db $14
dw DATA_00_28B6

db $05
dwb DATA_00_28B4 | $C000

DATA_00_28C4:
db $08
db $0F

db $08
db $08
db $0F

db $08
db $08
db $0F

db $08
db $11

;Entity
DATA_00_28CE:
db $21,$03
db $31
db $02,$02
db $04
db $05

db $17

DATA_00_28D6:
db $37,$70
dw DATA_00_291D

db $83
dw DATA_00_28E4

db $37,$71
dw DATA_00_291D

db $A3
dw DATA_00_28D6

DATA_00_28E4:
db $33

DATA_00_28E5:
db $09,$02

db $A0
dw DATA_00_28E5

DATA_00_28EA:
db $16,$51
db $03,$FD

DATA_00_28EE:
db $08
db $09,$02
db $0F

db $0E
db $A0
dw DATA_00_28EE

db $81
dw DATA_00_2904

db $44
db $39,SFX_MetalPunch

db $16,$52
db $44
db $16,$72
db $48

dwb DATA_00_28EA | $C000

DATA_00_2904:
db $03,$FF
db $16,$71

DATA_00_2908:
db $08

db $81
dw DATA_00_2908

db $31

DATA_00_290D:
db $37,$70
dw DATA_00_291D

db $81
dw DATA_00_2904

db $37,$71
dw DATA_00_291D

db $81
dw DATA_00_2904

dwb DATA_00_290D | $C000

DATA_00_291D:
db $08
db $08
db $0F

db $08
db $0F

db $08
db $08
db $0F

db $11

;Entity
DATA_00_2926:
db $1A,$06
db $16,$3B
db $02,$FF

DATA_00_292C:
db $38,$08
db $12,$20

DATA_00_2930:
db $08
db $38,$02

db $14
dw DATA_00_2930

dwb DATA_00_292C | $C000

;Entity
DATA_00_2938:
db $1A,$06
db $32

db $37,$3B
dw DATA_00_3146

DATA_00_293F:
db $08
db $0F

db $A1
dw DATA_00_293F

DATA_00_2944:
db $30
db $0F
dwb DATA_00_2944 | $C000

;Entity
DATA_00_2948:
db $2B,$20

DATA_00_294A:
db $10
dw DATA_00_3141

db $1A,$02

db $39,SFX_Ghost
db $34
db $33

db $16,$53

DATA_00_2955:
db $09,$08

db $A9
dw DATA_00_2955

db $31

DATA_00_295B:
db $0D
db $0F

db $07
db $0F

dwb DATA_00_295B | $C000

;Entity
DATA_00_2961:
db $1C,$30
db $21,$02

db $37,$3C
dw DATA_00_3163

db $34
db $05

DATA_00_296B:
db $1A,$80
db $16,$3C
db $7F
db $60
db $1A,$00
db $05

DATA_00_2974:
db $37,$56
dw DATA_00_297E

db $37,$57
dw DATA_00_297E

dwb DATA_00_2974 | $C000

;Entity
DATA_00_297E:
db $12,$04

DATA_00_2980:
db $08
db $08
db $0E

db $81
dw DATA_00_298A

db $14
dw DATA_00_2980

db $11

DATA_00_298A:
db $16,$73

db $19
dw DATA_00_299A

db $03,$FD

DATA_00_2991:
db $09,$02
db $0E

db $A0
dw DATA_00_2991

db $31
dwb DATA_00_296B | $C000

DATA_00_299A:
db $29,$FF
db $02,$F8
db $07

db $10
dw DATA_00_315A

db $00

;Entity
DATA_00_29A3:
db $21,$03

db $1F
dw DATA_00_29F7
db $01

db $19
dw DATA_00_29ED

db $2E

DATA_00_29AD:
db $10
dw DATA_00_29E1

db $32

db $8E
dw DATA_00_29B6

db $02,$FF

DATA_00_29B6:
db $26

db $37,$61
dw DATA_00_29D8

db $37,$62
dw DATA_00_29D8

db $37,$61
dw DATA_00_29D8

db $10
dw DATA_00_29E1

db $05
db $37,$61
dw DATA_00_29D8

db $37,$62
dw DATA_00_29D8

db $37,$61
dw DATA_00_29D8

db $10
dw DATA_00_29E1

dwb DATA_00_29AD | $C000

DATA_00_29D8:
db $07
db $07
db $07
db $07
db $07
db $07
db $07
db $07
db $11

DATA_00_29E1:
db $12,$03

DATA_00_29E3:
db $16,$5F
db $48
db $16,$60
db $48

db $14
dw DATA_00_29E3

db $11

DATA_00_29ED:
db $03,$10
db $07
db $20,$01
db $1A,$06
db $16,$17
db $24

DATA_00_29F7:
db $03,$08

db $07
db $41
db $39,SFX_16
db $12,$04

DATA_00_29FF:
db $16,$54
db $44
db $16,$55
db $44

db $14
dw DATA_00_29FF

db $16,$33

dwb DATA_00_314B | $C000

;Entity
DATA_00_2A0C:
db $1A,$06

db $37,$7E
dw DATA_00_3163

DATA_00_2A12:
db $37,$7B
dw DATA_00_2A24

db $37,$7C
dw DATA_00_2A24

db $37,$7D
dw DATA_00_2A24

db $37,$7E
dw DATA_00_2A24

dwb DATA_00_2A12 | $C000

DATA_00_2A24:
db $44
db $86
dw DATA_00_2A29

db $11

DATA_00_2A29:
db $42
db $38,$07

DATA_00_2A2C:
db $37,$7B
dw DATA_00_2A4B

db $37,$7C
dw DATA_00_2A4B

db $37,$7D
dw DATA_00_2A4B

db $37,$7E
dw DATA_00_2A4B

dwb DATA_00_2A2C | $C000

DATA_00_2A3E:
db $30
db $31

DATA_00_2A40:
db $0E
db $08
db $0F

db $08
db $08
db $0F

db $08
db $08

db $A0
dw DATA_00_2A40

DATA_00_2A4B:
db $02,$FF
db $12,$04

DATA_00_2A4F:
db $A0
dw DATA_00_2A3E

db $07
db $14
dw DATA_00_2A4F

db $11

DATA_00_2A57:
db $19
dw DATA_00_2A5C

dwb DATA_00_314B | $C000

DATA_00_2A5C:
db $10
dw DATA_00_2D6D

db $1D
db $22
db $16,$0F

dwb DATA_00_2E3B | $C000

;Entity
DATA_00_2A65:
db $10
dw DATA_00_2D47

db $1E,$0C
db $2A,$18
db $2B,$60
db $1A,$00

db $1F
dw DATA_00_2A57
db $04

db $16,$67
db $12,$08

DATA_00_2A78:
db $18
db $42
db $17
db $42

db $14
dw DATA_00_2A78

DATA_00_2A7F:
db $34
db $03,$F9

db $10
dw DATA_00_2A93

db $05
db $12,$02

DATA_00_2A88:
db $16,$67
db $48
db $16,$68
db $48

db $14
dw DATA_00_2A88

dwb DATA_00_2A7F | $C000

DATA_00_2A93:
db $0E
db $08
db $0F

db $08
db $0F

db $81
dw DATA_00_2AB2

DATA_00_2A9B:
db $08
db $0F

db $09,$01

db $A0
dw DATA_00_2A93

db $31
db $2C
db $12,$14

DATA_00_2AA6:
db $08
db $08
db $0F

db $08
db $0F

db $81
dw DATA_00_2AB5

DATA_00_2AAE:
db $14
dw DATA_00_2AA6

db $11

DATA_00_2AB2:
db $05

dwb DATA_00_2A9B | $C000

DATA_00_2AB5:
db $05
dwb DATA_00_2AAE | $C000

DATA_00_2AB8:
db $19
dw DATA_00_2ABD

dwb DATA_00_314B | $C000

DATA_00_2ABD:
db $10
dw DATA_00_2D6D

db $1D

db $22
db $16,$10

dwb DATA_00_2E3B | $C000

;Entity
DATA_00_2AC6:
db $98
dw DATA_00_2CCC

db $10
dw DATA_00_2D47

db $1E,$0D

db $2A,$18
db $2B,$68
db $1A,$00

db $1F
dw DATA_00_2AB8
db $04

db $34
db $17

DATA_00_2ADA:
db $1A,$02

db $10
dw DATA_00_315A

db $34
db $18
db $48
db $16
db $5A
db $12,$08

DATA_00_2AE6:
db $18
db $42

db $17
db $42
db $14
dw DATA_00_2AE6

db $1A,$08

db $03,$FF
db $30
db $12,$05

DATA_00_2AF4:
db $37,$74
dw DATA_00_2B47

db $37,$75
dw DATA_00_2B47

db $14
dw DATA_00_2AF4

db $31
db $34
db $12,$08

DATA_00_2B03:
db $37,$74
dw DATA_00_2B3A

db $37,$75
dw DATA_00_2B3A

db $14
dw DATA_00_2B03

db $03,$01
db $30

DATA_00_2B11:
db $08
db $08

db $A0
dw DATA_00_2B11

db $31
db $34
db $10
dw DATA_00_315A

db $16
db $5A
db $7F
db $60
db $39,SFX_0D

db $19
dw DATA_00_2B2C

db $19
dw DATA_00_2B31

db $19
dw DATA_00_2B33

dwb DATA_00_2ADA | $C000

DATA_00_2B2C:
db $03,$FF
db $30
dwb DATA_00_2B33 | $C000

DATA_00_2B31:
db $03,$FF

DATA_00_2B33:
db $16
db $2A,$1A
db $02,$07

DATA_00_2B38:
dwb (DATA_00_2B38-1) | $C000                                ;seems to loop to $07, which is a part of a command 

DATA_00_2B3A:
db $13,$04

DATA_00_2B3C:
db $0C
db $0F
db $08
db $0F

db $81
dw DATA_00_2B4E

DATA_00_2B43:
db $15
dw DATA_00_2B3C
db $11

DATA_00_2B47:
db $08
db $08
db $0F

db $08
db $08
db $0F
db $11

DATA_00_2B4E:
db $05
dwb DATA_00_2B43 | $C000

DATA_00_2B51:
db $19
dw DATA_00_2B56

dwb DATA_00_314B | $C000

DATA_00_2B56:
db $10
dw DATA_00_2D6D

db $1D
db $22
db $16,$11

dwb DATA_00_2E3B | $C000

;Entity
DATA_00_2B5F:
db $10
dw DATA_00_2D47

db $1E,$0D
db $2A,$40
db $2B,$68
db $16,$69
db $1A,$00

db $1F
dw DATA_00_2B51
db $04

DATA_00_2B70:
db $32
db $8E
dw DATA_00_2B76

db $02
db $FF

DATA_00_2B76:
db $26
db $16,$69
db $17
db $13,$02

DATA_00_2B7C:
db $03,$FB
db $12,$0B

DATA_00_2B80:
db $09,$02
db $0F

db $0E
db $0F

db $14
dw DATA_00_2B80

db $15
dw DATA_00_2B7C

db $16,$59
db $03,$04

DATA_00_2B8F:
db $08

db $A0
dw DATA_00_2B8F

db $31
db $1A,$02

DATA_00_2B96:
db $37,$58
dw DATA_00_2BA0

db $37,$59
dw DATA_00_2BA0

dwb DATA_00_2B96 | $C000

DATA_00_2BA0:
db $2D
db $2D
db $2D
db $2D
db $2D
db $2D

db $8B
dw DATA_00_2BAA

db $11

DATA_00_2BAA:
db $1A,$08

dwb DATA_00_2B70 | $C000

DATA_00_2BAE:
db $19
dw DATA_00_2BB3

dwb DATA_00_314B | $C000

DATA_00_2BB3:
db $10
dw DATA_00_2D6D

db $1D
db $22
db $16,$12

dwb DATA_00_2E3B | $C000

;Entity
DATA_00_2BBC:
db $10
dw DATA_00_2D47

db $1E,$0D
db $1C,$45
db $2A,$6C
db $2B,$60
db $1A,$00

db $1F
dw DATA_00_2BAE
db $04

db $02,$FF
db $12,$04

DATA_00_2BD1:
db $16,$80
db $17,$48
db $16,$81
db $48

db $14
dw DATA_00_2BD1

DATA_00_2BDB:
db $12,$02

DATA_00_2BDD:
db $03,$FB
db $16,$80
db $48
db $16,$81
db $48
db $16,$82

DATA_00_2BE7:
db $10
dw DATA_00_2C0F

db $10
dw DATA_00_2C0F

db $0E

dwb DATA_00_2BE7 | $C000

DATA_00_2BF0:
db $39,SFX_Quake
db $16,$81
db $60

db $14
dw DATA_00_2BDD

db $16,$80
db $48
db $16,$88
db $50

db $19
dw DATA_00_2C1F

db $19
dw DATA_00_2C19

db $19
dw DATA_00_2C1C

db $16,$80
db $2C
db $5F
db $7F
db $05
dwb DATA_00_2BDB | $C000

DATA_00_2C0F:
db $07
db $80
dw DATA_00_2BF0

db $07
db $0F

db $80
dw DATA_00_2BF0

db $11

DATA_00_2C19:
db $50
dwb DATA_00_2C1F | $C000

DATA_00_2C1C:
db $70
dwb DATA_00_2C1F | $C000                                    ;yeah, that was worth 2 bytes

DATA_00_2C1F:
db $36
db $1A,$02
db $2B,$20
db $16,$29
db $33
db $30

DATA_00_2C28:
db $07
db $07
db $07
db $0F

dwb DATA_00_2C28 | $C000

DATA_00_2C2E:
db $19
dw DATA_00_2C33

dwb DATA_00_314B | $C000

DATA_00_2C33:
db $10
dw DATA_00_2D6D

db $1D
db $22
db $16,$13

dwb DATA_00_2E3B | $C000

;Entity
DATA_00_2C3C:
db $10
dw DATA_00_2D47

db $1E,$0E
db $2B,$68
db $1A,$00

db $1F
dw DATA_00_2C2E
db $04

DATA_00_2C49:
db $2A,$3C
db $17,$16
db $76
db $30
db $12,$04

DATA_00_2C51:
db $33
db $07
db $47
db $03,$FF
db $07
db $45

db $14
dw DATA_00_2C51

db $31

db $8E
dw DATA_00_2C8A

db $02,$FE

db $8E
dw DATA_00_2C66

db $02,$02

DATA_00_2C66:
db $26
db $31
db $12,$03

DATA_00_2C6A:
db $37,$77
dw DATA_00_2C85

db $37,$78
dw DATA_00_2C85

db $14
dw DATA_00_2C6A

db $05
db $12,$03

DATA_00_2C78:
db $37,$77
dw DATA_00_2C85

db $37,$78
dw DATA_00_2C85

db $14
dw DATA_00_2C78

dwb DATA_00_2C49 | $C000

DATA_00_2C85:
db $07,$07,$07,$07
db $11

DATA_00_2C8A:
db $02,$FF

db $8E
dw DATA_00_2C90

db $32

DATA_00_2C90:
db $26
db $16,$87
db $03,$FB

DATA_00_2C95:
db $10
dw DATA_00_2CA9

db $10
dw DATA_00_2CA9

db $09,$02

db $80
dw DATA_00_2CAE

db $10
dw DATA_00_2CA9

db $10
dw DATA_00_2CA9

db $0E

dwb DATA_00_2C95 | $C000

DATA_00_2CA9:
db $08

db $80
dw DATA_00_2CAE

db $11

DATA_00_2CAE:
db $05
db $03,$FC
db $07

DATA_00_2CB2:
db $10
dw DATA_00_2CC3

db $80
dw DATA_00_2C49

db $09,$01

db $10
dw DATA_00_2CC3

db $80
dw DATA_00_2C49

db $0E

dwb DATA_00_2CB2 | $C000

DATA_00_2CC3:
db $80
dw DATA_00_2C49

db $08
db $11

DATA_00_2CC8:
db $38,$00

dwb DATA_00_314B | $C000

;Entity
DATA_00_2CCC:
db $10
dw DATA_00_2D47

db $1E,$0E
db $1C,$45
db $2B,$2C
db $1A,$00

db $1F
dw DATA_00_2CC8
db $04

DATA_00_2CDB:
db $36
db $34
db $16,$7F

db $10
dw DATA_00_2CF9

db $19
dw DATA_00_2D03

db $1A,$08
db $16,$89
db $7F
db $7F
db $4F

db $10
dw DATA_00_2CF9

db $1A,$80
db $12,$7F

DATA_00_2CF3:
db $18

db $14
dw DATA_00_2CF3

dwb DATA_00_2CDB | $C000

DATA_00_2CF9:
db $12,$08

DATA_00_2CFB:
db $18
db $44
db $17
db $44

db $14
dw DATA_00_2CFB

db $11

DATA_00_2D03:
db $1A,$00
db $60
db $34
db $03,$01
db $2B,$20

DATA_00_2D0B:
db $37,$1C
dw DATA_00_2D2C

db $37,$1D
dw DATA_00_2D2C

dwb DATA_00_2D0B | $C000

DATA_00_2D15:
db $03,$FF

DATA_00_2D17:
db $37,$1C
dw DATA_00_2D37

db $37,$1D
dw DATA_00_2D37

dwb DATA_00_2D17 | $C000

DATA_00_2D21:
db $31

DATA_00_2D22:
db $37,$1C
dw DATA_00_2D42

db $37,$1D
dw DATA_00_2D42

dwb DATA_00_2D22 | $C000

DATA_00_2D2C:
db $12,$04

DATA_00_2D2E:
db $09,$08

db $97
dw DATA_00_2D15

db $14
dw DATA_00_2D2E

db $11

DATA_00_2D37:
db $12,$04

DATA_00_2D39:
db $07
db $0F

db $97
dw DATA_00_2D21

db $14
dw DATA_00_2D39

db $11

DATA_00_2D42:
db $0B
db $41
db $0B
db $41
db $11

DATA_00_2D47:
db $1A,$06
db $18
db $16,$08

DATA_00_2D4C:
db $0F

db $AF
dw DATA_00_2D4C

db $7F
db $5F
db $2A,$00

db $19
dw DATA_00_2D5F

db $2A,$90

db $19
dw DATA_00_2D5F

db $39,Music_Boss
db $11

DATA_00_2D5F:
db $1A,$80
db $03,$10
db $2B,$20
db $12,$0A

DATA_00_2D67:
db $20,$01
db $07

db $14
dw DATA_00_2D67

DATA_00_2D6D:
db $1A,$80
db $2A,$40
db $2B,$70
db $7F

dwb DATA_00_315A | $C000

;entity
DATA_00_2D76:
db $10
dw DATA_00_2D90

db $1A,$00

db $10
dw DATA_00_2DA0

dwb DATA_00_2EC9 | $C000

DATA_00_2D80:
db $1A,$06

db $10
dw DATA_00_2D90

db $10
dw DATA_00_315A

db $16,$04

db $10
dw DATA_00_2DA0

db $35

dwb DATA_00_2E79 | $C000

DATA_00_2D90:
db $1A,$06

db $38,$02

db $02,$08
db $03,$08
db $07
db $16,$28

DATA_00_2D9B:
db $48

db $AD
dw DATA_00_2D9B

db $11

DATA_00_2DA0:
db $34
db $03,$F8
db $07
db $31

DATA_00_2DA5:
db $08
db $0F

db $80
dw DATA_00_2DA5

DATA_00_2DAA:
db $0E
db $09,$02
db $0F

db $09,$02

db $A0
dw DATA_00_2DAA

db $11

DATA_00_2DB4:
db $10
dw DATA_00_2DDE

dwb DATA_00_294A | $C000

DATA_00_2DB9:
db $10
dw DATA_00_2DDE

db $30
db $03,$E0
db $07
db $31

dwb DATA_00_25F2 | $C000

DATA_00_2DC3:
db $10
dw DATA_00_2DDE

db $30
db $19
dw DATA_00_2DD7

db $4E
db $8E
dw DATA_00_313B

db $32

db $19
dw DATA_00_2DD7

db $4E
db $8E
dw DATA_00_313B

db $05

DATA_00_2DD7:
db $10
dw DATA_00_315A

db $16,$01
dwb DATA_00_2E3C | $C000

DATA_00_2DDE:
db $1A,$80

DATA_00_2DE0:
db $48
db $B9
dw DATA_00_2DE0

db $02,$08
db $07
db $11

DATA_00_2DE8:
db $10
dw DATA_00_2DED

dwb DATA_00_2E36 | $C000

DATA_00_2DED:
db $1A,$06
db $23

dwb DATA_00_315A | $C000

DATA_00_2DF2:
db $10
dw DATA_00_2DED

dwb DATA_00_2E69 | $C000

DATA_00_2DF7:
db $10
dw DATA_00_2DED

dwb DATA_00_2E6F | $C000

;Entity
DATA_00_2DFC:
db $10
dw DATA_00_2DED

dwb DATA_00_2E75 | $C000

;Entity
DATA_00_2E01:
db $10
dw DATA_00_2DED

dwb DATA_00_2E7B | $C000

;Entity
DATA_00_2E06:
db $9F
dw DATA_00_2DF7

db $10
dw DATA_00_2DED

dwb DATA_00_2E84 | $C000

;Entity
DATA_00_2E0E:
db $10
dw DATA_00_2DED

dwb DATA_00_2E8A | $C000

;Entity
DATA_00_2E13:
db $10
dw DATA_00_2DED

dwb DATA_00_2E67 | $C000

DATA_00_2E18:
db $18
db $16,$18

dwb DATA_00_2E2A | $C000

DATA_00_2E1D:
db $18
db $16,$01

dwb DATA_00_2E2A | $C000

DATA_00_2E22:
db $18
db $16,$05

dwb DATA_00_2E2A | $C000

DATA_00_2E27:
db $18
db $16,$03

DATA_00_2E2A:
db $38,$0A
db $03,$05
db $07

db $17
db $30
db $31

dwb DATA_00_2E4D | $C000

;Entity
DATA_00_2E34:
db $1D
db $22

DATA_00_2E36:
db $16,$18
db $02,$04
db $07

DATA_00_2E3B:
db $30

DATA_00_2E3C:
db $1A,$82
db $03,$FD
db $07

db $08
db $08
db $0E

db $08
db $08
db $0E

db $08
db $08
db $0E

db $08
db $08
db $0E

DATA_00_2E4D:
db $1A,$03

DATA_00_2E4F:
db $10
dw DATA_00_2E62

db $80
dw DATA_00_2E5C

db $0E

db $10
dw DATA_00_2E62

db $A0
dw DATA_00_2E4F

DATA_00_2E5C:
db $0F

db $8C
dw DATA_00_2E5C

dwb DATA_00_2ED4 | $C000

DATA_00_2E62:
db $80
dw DATA_00_2E5C

db $08
db $11

DATA_00_2E67:
db $1D,$22

DATA_00_2E69:
db $16,$01
dwb DATA_00_2E3B | $C000

DATA_00_2E6D:
db $1D,$22

DATA_00_2E6F:
db $16,$00
dwb DATA_00_2E3B | $C000

DATA_00_2E73:
db $1D,$22

DATA_00_2E75:
db $16,$05
dwb DATA_00_2E3B | $C000

DATA_00_2E79:
db $1D,$22

DATA_00_2E7B:
db $16,$03
dwb DATA_00_2E3B | $C000

DATA_00_2E7F:
db $9F
dw DATA_00_2E6D

db $1D,$22

DATA_00_2E84:
db $16,$06
dwb DATA_00_2E3B | $C000

DATA_00_2E88:
db $1D,$22

DATA_00_2E8A:
db $16,$02
dwb DATA_00_2E3B | $C000

DATA_00_2E8E:
db $9E
dw DATA_00_313B

db $1D,$22

db $16,$07
dwb DATA_00_2E3B | $C000

DATA_00_2E97:
db $93
dw DATA_00_313B

db $1A,$01
db $16,$0A

DATA_00_2E9E:
db $7F

dwb DATA_00_2E9E | $C000

DATA_00_2EA1:
db $92
dw DATA_00_313B

db $1D,$22
db $16,$0C

dwb DATA_00_2E3B | $C000

DATA_00_2EAA:
db $92
dw DATA_00_313B

db $1D,$22
db $16,$0D

dwb DATA_00_2E3B | $C000

DATA_00_2EB3:
db $92
dw DATA_00_313B

db $1D,$22
db $16,$0B

dwb DATA_00_2E3B | $C000

DATA_00_2EBC:
db $94
dw DATA_00_313B

db $1D,$22
db $16,$0E

dwb DATA_00_2E3B | $C000

DATA_00_2EC5:
db $16,$07
db $48
db $00

;Entity $00
DATA_00_2EC9:
db $10
dw DATA_00_315A

db $00

;Entity $01
DATA_00_2ECD:
db $10
dw DATA_00_315A

db $1A,$01
db $16,$01

DATA_00_2ED4:
db $7F
db $7F
db $12,$10

DATA_00_2ED8:
db $18
db $43
db $17
db $43

db $14
dw DATA_00_2ED8

db $00

DATA_00_2EE0:
db $10
dw DATA_00_315A

db $1A,$01
db $16,$03

dwb DATA_00_2ED4 | $C000

;Entity
DATA_00_2EE9:
db $16,$14
db $02,$02
db $04
db $03,$FE

DATA_00_2EF0:
db $81
dw DATA_00_2EC9

db $07

db $85
dw DATA_00_2EC5

db $07
db $80
dw DATA_00_2EC9

db $07

dwb DATA_00_2EF0 | $C000

DATA_00_2EFE:
db $20,$00
dwb DATA_00_2EC9 | $C000

DATA_00_2F02:
db $20,$00
db $48
db $16,$17

dwb DATA_00_2F0B | $C000

;Entity
DATA_00_2F09:
db $16,$15

DATA_00_2F0B:
db $02,$02
db $04
db $03,$FD

DATA_00_2F10:
db $81
dw DATA_00_2EC9

db $85
dw DATA_00_2EC5

db $07
db $07

db $80
dw DATA_00_2EC9

db $85
dw DATA_00_2EC5

db $0E
db $07

dwb DATA_00_2F10 | $C000

;Entity
DATA_00_2F22:
db $02,$02
db $04

DATA_00_2F25:
db $16,$16
db $31

DATA_00_2F28:
db $81
dw DATA_00_2EC9

db $0E
db $A0
dw DATA_00_2EC9

db $08

db $85
dw DATA_00_2EC5

db $08

dwb DATA_00_2F28 | $C000

;Entity
DATA_00_2F36:
db $1A,$80

DATA_00_2F38:
db $02,$01

db $10
dw DATA_00_2F44

db $02,$FF

db $10
dw DATA_00_2F44

dwb DATA_00_2F38 | $C000

DATA_00_2F44:
db $12,$0C

DATA_00_2F46:
db $16,$8A
db $0A
db $39,SFX_LaunchpadHelicopter
db $0F

db $07
db $16,$8B

db $0A
db $0F
db $07

db $16,$8A
db $0A

db $87 ;?
db $0F
db $07
db $16,$8B

db $0A
db $0F
db $07

db $14
dw DATA_00_2F46

db $11

DATA_00_2F61:
db $9A
dw DATA_00_313B

db $1A,$06
db $37,$66
dw DATA_00_313C

db $28,$10

dwb DATA_00_3138 | $C000

DATA_00_2F6E:
db $1A,$80
db $13,$04

DATA_00_2F72:
db $12,$04

DATA_00_2F74:
db $10
dw DATA_00_2F85

db $14
dw DATA_00_2F74

db $19
dw DATA_00_2F8C

db $15
dw DATA_00_2F72

DATA_00_2F80:
db $10
dw DATA_00_2F85

dwb DATA_00_2F80  | $C000

DATA_00_2F85:
db $16,$64
db $50
db $16,$65
db $50
db $11

DATA_00_2F8C:
db $1A,$01
db $39,SFX_11

db $02,$03

db $8E
dw DATA_00_2F97

db $02,$FD

DATA_00_2F97:
db $43
db $07

db $8E
dw DATA_00_2F97

db $30
db $2B,$20
db $16,$05
db $33

DATA_00_2FA2:
db $07
db $0F

dwb DATA_00_2FA2 | $C000

DATA_00_2FA6:
db $1A,$80

db $B3
dw DATA_00_2FF9

db $95
dw DATA_00_2FF6

db $2F,$0A

DATA_00_2FB0:
db $48

db $B6
dw DATA_00_2FB0

db $2A,$01
db $32
db $05
db $05
db $12,$04

DATA_00_2FBB:
db $16,$84
db $48
db $16,$83
db $48

db $14
dw DATA_00_2FBB

db $19
dw DATA_00_2FCA

DATA_00_2FC7:
db $7F

dwb DATA_00_2FC7 | $C000

DATA_00_2FCA:
db $16,$08
db $02,$03

DATA_00_2FCE:
db $08

db $A1
dw DATA_00_2FCE

db $03,$10
db $02,$10
db $07
db $30
db $2B,$50
db $12,$04

DATA_00_2FDC:
db $10
dw DATA_00_315A

db $29,$D2
db $07

db $14
dw DATA_00_2FDC

db $02,$10
db $07
db $30
db $2B,$50
db $12,$04

DATA_00_2FED:
db $10
dw DATA_00_315A

db $29,$D3
db $07

db $14
dw DATA_00_2FED

DATA_00_2FF6:
db $2F,$0F
db $00

DATA_00_2FF9:
db $2F,$0A
db $00

DATA_00_2FFC:
db $9E
dw DATA_00_313B

db $2F,$00
db $1A,$04

db $1F
dw DATA_00_300F
db $01

db $03,$FE
db $07
db $31
db $16,$3D

dwb DATA_00_3138 | $C000

DATA_00_300F:
db $12,$04

DATA_00_3011:
db $0E
db $07
db $07

db $14
dw DATA_00_3011

DATA_00_3017:
db $0E
db $08

db $A0
dw DATA_00_3017

db $03,$FC
db $07
db $31
db $02,$02
db $26

DATA_00_3023:
db $0E
db $08

db $A1
dw DATA_00_3023

db $28
db $07
db $48
db $02,$18
db $07
db $2B,$60
db $31

db $10
dw DATA_00_3049

db $02,$10
db $07

db $10
dw DATA_00_3049

db $2B,$70
db $02,$F0

db $10
dw DATA_00_3049

db $07

db $10
dw DATA_00_3049

db $2F,$05

dwb DATA_00_2E8E | $C000

DATA_00_3049:
db $29,$00
dwb DATA_00_315A | $C000

DATA_00_304D:
db $90
dw DATA_00_313B

db $1A,$06

db $37,$2F
dw DATA_00_3163

db $10
dw DATA_00_313C

db $28,$80

dwb DATA_00_3138 | $C000

DATA_00_305D:
db $91
dw DATA_00_313B

db $94
dw DATA_00_313B

db $2F,$14
db $1A,$06

db $37,$30
dw DATA_00_3163

db $10
dw DATA_00_313C

db $28,$40

dwb DATA_00_3138 | $C000

DATA_00_3072:
db $1A,$06
db $18

db $37,$44
dw DATA_00_313C

db $28,$0B

db $00

DATA_00_307C:
db $32

db $38,$0F
dw DATA_00_3081                                             ;???

DATA_00_3081:
db $7F
db $05

db $38,$10
dw DATA_00_3087                                             ;???

DATA_00_3087:
db $7F
db $05

db $38,$11
dw DATA_00_308D                                             ;???

DATA_00_308D:
db $7F
db $05

db $38,$12
dw DATA_00_3093                                             ;???

DATA_00_3093:
db $7F
db $05

db $38,$13
dw DATA_00_3099                                             ;???

DATA_00_3099:
db $7F
db $12,$0A

DATA_00_309C:
db $48

db $38,$05

db $14
dw DATA_00_309C

db $38,$00

db $00                                                      ;inaccessible?

DATA_00_30A5:
db $03,$FC

DATA_00_30A7:
db $10
dw DATA_00_29D8

db $0E

dwb DATA_00_30A7 | $C000

DATA_00_30AD:
db $32
db $26
db $16,$8D
db $7F

db $19
dw DATA_00_30DF

db $13,$04

DATA_00_30B7:
db $30
db $03,$FC
db $12,$09

DATA_00_30BC:
db $07
db $07
db $07
db $0E
db $0F

db $14
dw DATA_00_30BC

db $15
dw DATA_00_30B7

db $7F
db $7F
db $02,$FF
db $31
db $12,$60

DATA_00_30CE:
db $07

db $14
dw DATA_00_30CE

db $30
db $03,$FF
db $12,$18

DATA_00_30D7:
db $07
db $14
dw DATA_00_30D7

db $38,$00

dwb DATA_00_3138 | $C000                                    ;inaccessible?

DATA_00_30DF:
db $2A,$44
db $2B,$50

DATA_00_30E3:
db $19
dw DATA_00_30E9

db $44
dwb DATA_00_30E3 | $C000

DATA_00_30E9:
db $38,$09
db $16,$00

DATA_00_30ED:
db $10
dw DATA_00_2C85

db $0E

dwb DATA_00_30ED | $C000

DATA_00_30F3:
db $1A,$80
db $17
db $03,$FF
db $16,$85
db $28,$0C
db $7F
db $12,$26

DATA_00_30FF:
db $37,$86
dw DATA_00_310D

db $37,$85
dw DATA_00_310D

db $14
dw DATA_00_30FF

db $31

dwb DATA_00_30FF | $C000

DATA_00_310D:
db $13,$04

DATA_00_310F:
db $38,$03
db $0F

db $15
dw DATA_00_310F

db $11

DATA_00_3116:
db $1A,$06
db $16,$04

DATA_00_311A:
db $0F

db $9D
dw DATA_00_3128

db $A8
dw DATA_00_311A

db $38,$06,Player_State_TreasureRaceFreeze
db $38,$00

dwb DATA_00_3138 | $C000                                    ;inaccessible?

DATA_00_3128:
db $38,$06,Player_State_TreasureRaceFreeze

db $32
db $12,$10

DATA_00_312E:
db $07
db $0F

db $14
dw DATA_00_312E

db $28,$0D
db $7F
db $38,$01

DATA_00_3138:
db $7F
dwb DATA_00_3138 | $C000 

DATA_00_313B:
db $00

DATA_00_313C:
db $44

db $A8
dw DATA_00_313C

db $11

DATA_00_3141:
db $44

db $A3
dw DATA_00_3141

db $11

DATA_00_3146:
db $44

db $A2
dw DATA_00_3146

db $11

DATA_00_314B:
db $17
db $03,$FB
db $32
db $06
db $0F

db $39,SFX_EnemyDefeat

DATA_00_3153:
db $07
db $0E
db $0F

dwb DATA_00_3153 | $C000 

DATA_00_3158:
dw $2550                                                    ;doesn't appear to be a pointer, currently unknown

DATA_00_315A:
db $39,SFX_Destruction
db $16,$08
db $48
db $16,$09
db $48
db $11

DATA_00_3163:
db $18

db $80
dw DATA_00_316F

db $03,$08

DATA_00_3169:
db $09,$08

db $A0
dw DATA_00_3169

db $31

DATA_00_316F:
db $17
db $11

DATA_00_3171:
db $80
dw DATA_00_3180

DATA_00_3174:
db $31
db $30

DATA_00_3176:
db $0E
db $08
db $38,$04

db $A0
dw DATA_00_3176

db $08

DATA_00_317E:
dwb DATA_00_315A | $C000

DATA_00_3180:
db $02,$02
db $04

DATA_00_3183:
db $08
db $08
db $38,$04

db $A0
dw DATA_00_3174

db $A1
dw DATA_00_3183

dwb DATA_00_315A | $C000

DATA_00_318F:
db $10
dw DATA_00_31B6

db $1A,$06
db $50
db $29,$9F
db $33
db $12,$10

DATA_00_319A:
db $07
db $0F

db $14
dw DATA_00_319A

db $29,$DF
db $18
db $7F

dwb DATA_00_318F | $C000

DATA_00_31A5:
db $10
dw DATA_00_31B6

db $1A,$02
db $52
db $29,$9F

DATA_00_31AD:
db $0E
db $08
db $08
db $0F

db $80
dw DATA_00_2EC9

dwb DATA_00_31AD | $C000

DATA_00_31B6:
db $1A,$80
db $16,$15
db $18

DATA_00_31BB:
db $42

db $A2
dw DATA_00_31BB

db $17
db $11

POINTERS_00_31C1:
dw DATA_00_2EC9
dw DATA_00_2ECD
dw DATA_00_2EE0
dw DATA_00_2EE9
dw DATA_00_2F09
dw DATA_00_2F22
dw DATA_00_313B                                             ;\unused
dw DATA_00_313B                                             ;/
dw DATA_00_31A5
dw DATA_00_318F
dw DATA_00_313B                                             ;\unused
dw DATA_00_313B                                             ;|
dw DATA_00_313B                                             ;/
dw DATA_00_307C
dw DATA_00_30AD
dw DATA_00_30F3
dw DATA_00_2DE8
dw DATA_00_2DF2
dw DATA_00_2DF7
dw DATA_00_2DFC
dw DATA_00_2E01
dw DATA_00_2E06
dw DATA_00_2E0E
dw DATA_00_2E13
dw DATA_00_2E34
dw DATA_00_2E67
dw DATA_00_2E6D
dw DATA_00_2E73
dw DATA_00_2E79
dw DATA_00_2E7F
dw DATA_00_2E88
dw DATA_00_2E8E
dw DATA_00_2E97
dw DATA_00_2EA1
dw DATA_00_2EAA
dw DATA_00_2EB3
dw DATA_00_2EBC
dw DATA_00_2FA6
dw DATA_00_2F61
dw DATA_00_2FFC
dw DATA_00_2D76
dw DATA_00_2D80
dw DATA_00_2DC3
dw DATA_00_2DB9
dw DATA_00_2DB4
dw DATA_00_3072
dw DATA_00_313B                                             ;\unused
dw DATA_00_313B                                             ;/
dw DATA_00_2550
dw DATA_00_2578
dw DATA_00_25B4
dw DATA_00_25F2
dw DATA_00_2620
dw DATA_00_2661
dw DATA_00_26A9
dw DATA_00_2535
dw DATA_00_26C1
dw DATA_00_26E0
dw DATA_00_2737
dw DATA_00_257E
dw DATA_00_2794
dw DATA_00_27F4
dw DATA_00_283F
dw DATA_00_2868
dw DATA_00_285C
dw DATA_00_2882
dw DATA_00_28AC
dw DATA_00_28CE
dw DATA_00_2938
dw DATA_00_2926
dw DATA_00_2948
dw DATA_00_2961
dw DATA_00_29A3
dw DATA_00_2A0C
dw DATA_00_313B                                             ;\unused
dw DATA_00_313B                                             ;|
dw DATA_00_313B                                             ;|
dw DATA_00_313B                                             ;|
dw DATA_00_313B                                             ;|
dw DATA_00_313B                                             ;/
dw DATA_00_2A65
dw DATA_00_2AC6
dw DATA_00_2B5F
dw DATA_00_2BBC
dw DATA_00_2C3C
dw DATA_00_2CCC                                             ;unused (the pointer itself)
dw DATA_00_3116
dw DATA_00_313B                                             ;unused
dw DATA_00_2F36
dw DATA_00_304D
dw DATA_00_2F6E
dw DATA_00_313B                                             ;unused
dw DATA_00_305D
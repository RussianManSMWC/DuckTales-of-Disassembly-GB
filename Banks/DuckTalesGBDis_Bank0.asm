;A disassembly of Duck Tales for the Game Boy

;used to execute code pointers right after the the jump
SECTION "rst 00", ROM0[$0]
ADD A, A                                                    ;double A
POP HL                                                      ;will not return to where we executed the pointer (so taht we don't break the game)

CODE_00_0002:
RST $18
LD E, [HL]
INC HL
LD D, [HL]
LD H, D
LD L, E
JP HL

db $00,$00,$00,$00,$00,$00,$00

;used to execute code pointers right after the jump and after that jump into code stored in DE
;input A - pointer to execute
SECTION "rst 10", ROM0[$10]
ADD A, A                                                    ;double A
POP HL
PUSH DE
JR CODE_00_0002

db $00,$00,$00

;skip A bytes for HL.
SECTION "rst 18", ROM0[$18]
ADD A, L
LD L, A
RET NC

INC H
RET

db $00,$00,$00

;used to fetch a value from a table.
;input HL - table, A - offset
SECTION "rst 20",ROM0[$20]
ADD A, L
LD L, A
JR NC, CODE_00_0025
INC H                                                       ;handle high byte

CODE_00_0025:
LD A, [HL]
RET

db $00

SECTION "rst 28",ROM0[$28]
CODE_00_0028:
ADD A, A
RST $18
LD E, [HL]
INC HL
LD D, [HL]
RET

db $00,$00

;a quick way to store contents of DE into HL, then move onto next byte for both DE and HL
SECTION "rst 30",ROM0[$30]
LD A, [DE]
LD [HL+], A
INC DE
RET

db $00,$00,$00,$00

;a quick way to set bank 1
SECTION "rst 38",ROM0[$38]
SetBankAndBackup 1                                          ;Map bank 1 to $4000-$7FFF, and remember it
RET

SECTION "VBlank_Interrupt", ROM0[$40]
JP VBlank_00_0195

db $00,$00,$00,$00,$00

SECTION "HBlank_Interrupt", ROM0[$48]                     ;So-called "STAT" or LDC Status [lets simply call it hblank, cuz it's basically that]
JP HBlank_00_0236

db $00,$00,$00,$00,$00

SECTION "TimerInterrupt",  ROM0 [$50]
RETI                                                      ;unused

db $00,$00,$00,$00,$00,$00,$00

SECTION "SerialInterrupt",  ROM0 [$58]
RETI                                                      ;unused

db $00,$00,$00,$00,$00,$00,$00

SECTION "JoyInterrupt",  ROM0 [$60]
RETI                                                      ;unused

db $00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00

db $00,$00,$00,$00,$00,$00,$00,$00

SECTION "Entry",  ROM0 [$100]
NOP
JP RESET_00_0150

SECTION "Header",  ROM0 [$104]
incbin "NintendoLogo.bin"

db "DUCK TALES",$00,$00,$00,$00,$00                         ;title
db $00                                                      ;Game Boy game (not game boy color only or game boy color enhanced)
db $00,$00                                                  ;new license (this game was made before that was a thing)
db $00                                                      ;Super Game Boy flag (made before Super Game Boy, so no extra features)
db $01		                                    ;Cart type = ROM. nothing fancy.
db $01		                                    ;ROM size = 64KB
db $00                                                      ;extra RAM = none
db $01                                                      ;region = non-japan
db $08                                                      ;old licensee = Capcom
db $00                                                      ;version 1.0 so to speak
db $1C                                                      ;header checksum
db $A3,$DD                                                  ;global checksum

include "CharacterSet.asm"

SECTION "Main", ROM0 [$150]
RESET_00_0150:
DI                                                          ;disable interrupt
CALL CODE_00_3737

LD SP, $DFFF
CALL CODE_00_3796

LD HL, $C000
LD BC, $1FF0
CALL ClearRAM_00_37E0

LD HL, $FF8A                                                ;clear some HRAM
LD BC, $0075
CALL ClearRAM_00_37E0

CALL ClearTilemap_00_37E8

CALL CODE_00_0183

LDH [Register_BackgroundPalette], A                         ;init palettes
LDH [Register_SpritePalette0], A                            ;
LDH [Register_SpritePalette1], A                            ;

LD A, Interrupt_VBlank
LDH [Reg_InterruptsEnabler], A

CALL EnableLCDAndRender_00_3750
EI
JP CODE_00_0257

CODE_00_0183:
SetBankAndBackup 2

CALL InitSoundRegisters_JMP_02_402F

SetBankAndBackup 1                                          ;why this when SetProgramBank1 exists?
RET

VBlank_00_0195:
PUSH AF                                                     ;standard value pushing procedure
PUSH BC
PUSH DE
PUSH HL
LDH A, [Reg_LCDControlAndRender]                            ;if we're not even showing anything...
BitA LCDControlEnable                                       ;
JR Z, CODE_00_020F                                          ;skip buffer stuff

CALL OAMUploadCode                                          ;upload OAM
CALL BufferedDraw_00_388A                                   ;draw from the buffer

LD A, [$C1A9]                                               ;enable status bar?
AND A
JR Z, CODE_00_01C0

LDH A, [Reg_LCDControlAndRender]
OR LCDBackgroundTilemapSelect
LDH [Reg_LCDControlAndRender], A

LD A, $40
LDH [Reg_LCDStatus], A

LD A, $1F
LDH [Register_LCDYCompare], A
LDH A, [Reg_InterruptsEnabler]
OR Interrupt_HBlank                                         ;enable horizontal blank
LDH [Reg_InterruptsEnabler], A
EI                                                          ;enable interrupts

CODE_00_01C0:
XOR A
LDH [Register_CameraXPosition], A

LD A, [CurrentMessage]                                      ;check if we're displaying a message
AND A                                                       ;
JR Z, CODE_00_01CB                                          ;

LD A, $20                                                   ;move camera to the message box (it's drawn below status bar to give an illusion of it replacing the status bar. clever!

CODE_00_01CB:
LDH [Register_CameraYPosition], A

LD A, [$C631]
LD [CameraPositionX], A

LD A, [$C633]
LD [CameraPositionY], A

LD A, [$DF71]
AND A
JR Z, CODE_00_020F

LD A, [FrameCounter]
BIT 3, A
JR Z, CODE_00_020F

LD HL, CurrentLand                                          ;check if we are in... Amazon, African Mines or Moon.
BIT 0, [HL]
JR NZ, CODE_00_01F4

LD A, $75
LD [CameraPositionY], A
JR CODE_00_0204

CODE_00_01F4:
BIT 2, A
JR NZ, CODE_00_01FF

LD A, $DC
LD [CameraPositionX], A
JR CODE_00_0204

CODE_00_01FF:
LD A, $E4
LD [CameraPositionX], A

CODE_00_0204:
LD A, [FrameCounter]
AND $07
JR NZ, CODE_00_020F

LD A, $0E
LDH [SFXQueue], A

CODE_00_020F:
CALL ReadJoypadInputs_00_3765

LD A, 2
LD [MBC1Bank], A                                            ;set bank to 2

CALL CODE_02_4029

LDH A, [CurrentProgramBank]                                 ;restore bank to whatever it was before the interrupt
LD [MBC1Bank], A
LDH [CurrentProgramBank], A                                 ;what?? why are we storing backed up bank into the backup?

LD HL, FrameCounter                                         ;
INC [HL]                                                    ;increment frame counter
JR NZ, CODE_00_0229                                         ;

INC HL                                                      ;
INC [HL]                                                    ;high byte

CODE_00_0229:
LDH A, [VBlankWaitCounter]                                  ;check if we're supposed to wait for VBlank
AND A                                                       ;
JR Z, CODE_00_0231                                          ;if not, nothing happens

DEC A                                                       ;
LDH [VBlankWaitCounter], A                                  ;decrease

CODE_00_0231:
POP HL
POP DE
POP BC
POP AF
RETI

HBlank_00_0236:
PUSH AF
LDH A, [Reg_LCDStatus]                                      ;
BIT 2, A                                                    ;checks if hit speicific horizontal line
JR Z, CODE_0255                                             ;nothing happens if haven't

LDH A, [Reg_InterruptsEnabler]                         ;
AND $FF^Interrupt_HBlank                                    ;disable h-blank
LDH [Reg_InterruptsEnabler], A                         ;

LD A, [CameraPositionY]
SUB $10
LDH [Register_CameraYPosition], A

LD A, [CameraPositionX]
LDH [Register_CameraXPosition], A

LDH A, [Reg_LCDControlAndRender]
AND $FF^LCDBackgroundTilemapSelect                          ;finished rendering status bar, render the background from now on
LDH [Reg_LCDControlAndRender], A

CODE_0255:
POP AF
RETI

;transition into game mode
CODE_00_0257:
LD SP, $DFFF                                                ;stack
CALL CODE_00_3737
CALL ClearTilemap_00_37E8

SetProgramBank1
CALL CODE_01_7AC6

LD A, [GameMode]                                            ;
AND $03
ExecutePointers                                             ;execute code right after this

;game pointers
dw TitleScreenCode_00_0272                                  ;
dw CODE_00_02B6                                             ;level select (maybe even other scenes?)
dw CODE_00_0620                                             ;gameplay (and ending cutscenes)
dw CODE_00_0348                                             ;unused pointer

;title screen
TitleScreenCode_00_0272:
LD DE, POINTERS_02_4000+(0*2)
CALL ProcessStripeImageFromBank2_00_032A                    ;draw title screen

LD HL, DATA_01_7A97                                         ;load title screen graphics
CALL CODE_00_38A7

CALL TitleScreenInit_01_7C5F

LD A, $00
LD [FrameCounter], A

LOOP_00_0286:
CALL CODE_00_029F

LD A, [FrameCounter]
CP $40                                                      ;wait for 64 frames before the game can be started
JR C, LOOP_00_0286

LOOP_00_0290:
CALL CODE_00_029F
JR NC, LOOP_00_0290                                         ;check if pressed start

SetProgramBank1                                             ;
JP StartGameFromTitleScreen_01_7C87                         ;will change game mode to land select and a few other prep things

;cursor data for the title screen.
;first byte - amount of options on a single column
;second byte - amount of columns. note that the game does not have programming for handling multiple columns of options, rendering this useless.
;then follows option X and Y position arrays. must be the same amount as respective options/columns
TitleScreen_CursorData_00_0299:
db $03,$00                                                  ;example: 3 options on a single column
db $28                                                      ;since there's only 1 column, the x-position is consistent
db $40,$48,$50                                              ;three different y-positions based on cursor selection

;title screen code
CODE_00_029F:
CALL WaitFrame_00_075A
CALL CODE_00_0FE5

SetProgramBank1
CALL DisplayCursorSprite_01_7DFF                            ;the priority has the cursor display at the wrong position for a single frame

LD HL, TitleScreen_CursorData_00_0299
LD A, [SelectedDifficulty]
CALL HandleCursorPrep_00_0789                               ;handle changing between difficulty options
LD [SelectedDifficulty], A
RET

CODE_00_02B6:
LD HL, DATA_01_7A9D
CALL CODE_00_38A7

LD HL, DATA_01_7AB7
CALL SetPalettes_01_7ABC

LD DE, POINTERS_02_4000+(2*2)                               ;build status bar
CALL ProcessStripeImageFromBank2_00_032A

LD A, Music_StageSelect
CALL QueueSoundPrep_00_072B

LD A, [$C627]
BIT 7, A
JP NZ, CODE_00_0348
CALL EnableLCDAndRender_00_3750

CODE_00_02D8:
LD DE, POINTERS_02_4000+(3*2)                               ;build the land select monitor
CALL ProcessStripeImageFromBank2_00_032A

XOR A
LD [CurrentLand], A

LD A, $00                                                   ;??? A is already 0!
LD [FrameCounter], A

LOOP_00_02E7:
CALL CODE_00_0312
LD A, [FrameCounter]
CP $40
JR C, LOOP_00_02E7

CODE_00_02F1:
CALL CODE_00_0312
JR NC, CODE_00_02F1

CODE_00_02F6:
LD HL, MoneyCurrent                                         ;clear current money count
LD BC, $0004                                                ;
CALL ClearRAM_00_37E0                                       ;
LD [$C627], A

LD A, $02                                                   ;GAME
LD [GameMode], A
JP CODE_00_0257

;cursor data for the level select, same format as title screen. may as well copy the format.
;first byte - amount of options on a single column
;second byte - amount of columns. note that the game does not have programming for handling multiple columns of options, rendering this useless.
;then follows option X and Y position arrays. must be the same amount as respective options/columns
DATA_00_030A:
db $05,$00
db $18
db $50,$58,$60,$68,$70

CODE_00_0312:
CALL WaitFrame_00_075A

SetProgramBank1
CALL CODE_01_7DD0
CALL DisplayCursorSprite_01_7DFF

LD HL, DATA_00_030A
LD A, [CurrentLand]
CALL HandleCursorPrep_00_0789
LD HL, CurrentLand

LD [HL+], A
RET

;get a pointer from bank 2 and process the stripe data from there
;input DE - location of said pointer
ProcessStripeImageFromBank2_00_032A:
CALL SetProgramBank2_00_0337

CODE_00_032D:
LD A, [DE]                                                  ;get pointer
LD L, A                                                     ;
INC DE                                                      ;
LD A, [DE]                                                  ;
LD H, A                                                     ;
CALL ProcessStripeImage_00_3800                             ;DRAW

SetProgramBank1                                             ;set program bank to 1 after we're done
RET                                                         ;

;Set $4000-$7FFF to bank 2
SetProgramBank2_00_0337:
SetBankAndBackup 2
RET                                                         ;

;get a pointer from bank 3 and process the stripe data from there
ProcessStripeImageFromBank3_00_033F:
LD A, 3
LD [MBC1Bank], A
LDH [CurrentProgramBank], A
JR CODE_00_032D

CODE_00_0348:
LD DE, POINTERS_02_4000+(4*2)

LD A, [$C627]
CP $FF
JR NZ, CODE_00_0355

LD DE, POINTERS_02_4000+(18*2)

CODE_00_0355:
CALL ProcessStripeImageFromBank2_00_032A

CALL SetProgramBank2_00_0337                                ;set program bank to 2 (remember, bank 1 is set after calling ProcessStripeImageFromBank2)

LD A, [POINTERS_02_4000+(5*2)]                              ;get level names pointer
LD L, A                                                     ;

LD A, [POINTERS_02_4000+(5*2)+1]                            ;
LD H, A                                                     ;

LD A, [CurrentLand]                                               ;current land
RST $28

LD H, D
LD L, E
CALL ProcessStripeImage_00_3800                             ;draw the level name

CALL EnableLCDAndRender_00_3750

SetProgramBank1

CALL CODE_01_7E12

LD HL, LandBeatenFlags
LD B, $05

LOOP_00_0378:
LD A, [HL+]
AND A
JP Z, CODE_00_02D8
DEC B
JR NZ, LOOP_00_0378

LD DE, POINTERS_02_4000+(16*2)                              ;clear money count
CALL ProcessStripeImageFromBank2_00_032A                    ;

LD DE, POINTERS_02_4000+(6*2)                               ;all land clear!!! string
CALL ProcessStripeImageFromBank2_00_032A                    ;will draw it

LD A, 128                                                   ;wait 128 frames...
CALL WaitForVBlank_372E                                     ;

LD DE, POINTERS_02_4000+(16*2)                              ;clear those strings
CALL ProcessStripeImageFromBank2_00_032A                    ;

XOR A
LD [$C627], A

LD B, $44
LD C, $80
LD D, $0D
CALL CODE_00_361E

CODE_00_03A4:
CALL WaitFrame_00_075A
CALL CODE_00_0FE5
LD A, [$C627]
AND A
JR Z, CODE_00_03A4
CALL CODE_00_05F7

LD DE, POINTERS_02_4000+(7*2)                               ;load message from glomgold
CALL ProcessStripeImageFromBank2_00_032A

CALL CODE_00_075F

LD A, CurrentLand_DraculaDuckManor                          ;get sent to transylvania for a third time
LD [CurrentLand], A
JP CODE_00_02F6

CODE_00_03C4:
LD A, [FrameCounter]
AND $03
RET NZ

LD A, $06
CALL QueueSoundPrep_00_072B
RET

CODE_00_03D0:
SetProgramBank1
PUSH DE
CALL DisableRender_00_3757
CALL CODE_00_3737
POP DE
LD BC, $0240
JP CODE_01_7C42

CODE_00_03DF:
LD B, $80
CALL CODE_00_0455
CALL CODE_00_3737
CALL SetProgramBank2_00_0337
LD BC, $0D02
CALL CODE_00_38E7

SetProgramBank1

LD [$C630], A
CALL CODE_01_7D33

CALL EnableLCDAndRender_00_3750

LD B, $60
LD C, $4E
LD D, $0F
CALL CODE_00_361E

LD B, $20
CALL CODE_00_0455
CALL CODE_00_06EE

CALL CODE_01_7D01

CODE_00_040E:
CALL CODE_00_044C
CALL CODE_00_0DC6
LD A, [$C627]
BIT 7, A
JR NZ, CODE_00_0428
BIT 1, A
JR NZ, CODE_00_043D

LD A, [$C201]                                 ;if the player accidently fell off or climbed down offscreen during the final race...
CP $98                                                      ;
JR NC, CODE_00_0438                                         ;fail said race

JR CODE_00_040E

CODE_00_0428:
XOR A
LDH [CurrentMusic], A

LD A, $21
CALL QueueSoundPrep_00_072B

LD A, $F0
CALL WaitForVBlank_372E
JP CODE_00_054F

CODE_00_0438:
LD A, $0D                                                   ;failed race message
LD [CurrentMessage], A

CODE_00_043D:
CALL CODE_00_06EE

LD A, $05
LD [$C627], A

XOR A
LD [$C630], A
JP CODE_00_0257


CODE_00_044C:
CALL WaitFrame_00_075A
CALL CODE_00_0FE5
JP CODE_00_0462

CODE_00_0455:
PUSH BC
CALL CODE_00_044C
POP BC
DEC B
JR NZ, CODE_00_0455
RET

CODE_00_045E:
SetProgramBank1
JP CODE_01_7CA2

CODE_00_0462:
LD A, [$C8F8]
AND A
RET NZ

LD A, [$C627]
BIT 7, A
JR NZ, CODE_00_0483
LD A, [FrameCounter]
AND $3F
JR NZ, CODE_00_0483

LD DE, Timer+1                                              ;timer -1
LD HL, DATA_00_0769+3
CALL SubstractFrom4ByteCounter_00_395D
JR NC, CODE_00_0483

CALL CODE_00_16D4

CODE_00_0483:
LD A, [FrameCounter]
AND $03
RET Z
CP $01
JR Z, CODE_00_0493
CP $02
JR Z, CODE_00_04AB
JR CODE_00_04AF

CODE_00_0493:
LD DE, $9C0A

CODE_00_0496:
LD HL, MoneyTotal

LD B, $04
CALL ExtractDigits_JMP_00_04C2

LD B, $08
CALL RemoveLeadingZeroes_JMP_00_04C6

LD HL, CounterUpdateBuffer
LD B, $08
JP DrawStripeImage_00_380F

CODE_00_04AB:
SetProgramBank1
JP CODE_01_7B42

CODE_00_04AF:
SetProgramBank1
JP CODE_01_7B6D

;unused code
SetProgramBank1
JP CODE_01_7BB4

;number tiles, from 0 to 9
DigitTiles_00_04B7:
db "0","1","2","3","4","5","6","7","8","9"

;empty space for some reason.
db " "

ExtractDigits_JMP_00_04C2:
SetProgramBank1
JP ExtractDigits_01_7BF9

RemoveLeadingZeroes_JMP_00_04C6:
SetProgramBank1
JP RemoveLeadingZeroes_01_7C1F

CODE_00_04CA:
SetBankAndBackup 3
LD HL, DATA_03_4030
LD DE, $CE1F
CALL CODE_00_3929

SetProgramBank1
CALL CODE_01_7AF3

CODE_00_04DE:
LD A, [$C634]
LD H, A

LD A, [$C633]
LD L, A

CODE_00_04E6:
PUSH HL

SetProgramBank1
CALL CODE_01_7B1A

LD A, [$C630]
AND A
CALL Z, CODE_00_38A7

POP HL
CALL CODE_00_085D
LD A, H
CP $01
JR NZ, CODE_00_0526
LD A, [CurrentLand]
OR L
JR NZ, CODE_00_050F
LD A, [$CA1D]
BIT 6, A
JR Z, CODE_00_0526
LD A, $1E
CALL CODE_00_07B6
JR CODE_00_0526

CODE_00_050F:
LD A, [CurrentLand]
CP $04
JR NZ, CODE_00_0526

LD A, L
AND A
JR NZ, CODE_00_0526
LD A, [$CA1D]
BIT 4, A
JR NZ, CODE_00_0526
LD A, $19
CALL CODE_00_07B6

CODE_00_0526:
LD A, [$C632]
LD D, A
LD A, [$C631]
SUB $30
LD E, A
JR NC, CODE_00_0533
DEC D

CODE_00_0533:
LD A, $FD
LD [$C63E], A
LD C, $10

CODE_00_053A:
CALL CODE_00_089F
LD A, [$C63E]
INC A
LD [$C63E], A
LD A, E
ADD A, $10
LD E, A
JR NC, CODE_00_054B
INC D

CODE_00_054B:
DEC C
JR NZ, CODE_00_053A
RET

CODE_00_054F:
LD D, $7F
CALL CODE_00_03D0
CALL CODE_01_7AC6
CALL CODE_00_05F7

LD DE, POINTERS_03_4000+(16*2)
CALL ProcessStripeImageFromBank3_00_033F

SetBankAndBackup 3
CALL CODE_03_402D

LD HL, DATA_01_7AA3
CALL CODE_00_38A7

CALL EnableLCDAndRender_00_3750
CALL CODE_01_7D46
LD D, $6E
CALL CODE_00_03D0
CALL CODE_00_05F7
LD A, $E1
LDH [Register_BackgroundPalette], A

LD HL, DATA_01_7AA9
CALL CODE_00_38A7

LD DE, POINTERS_02_4000+(17*2)
CALL ProcessStripeImageFromBank2_00_032A

CALL EnableLCDAndRender_00_3750
CALL CODE_01_7D84
CALL CODE_00_075F
LD D, $6E
CALL CODE_00_03D0
CALL CODE_00_05F7

XOR A
LD [CurrentOAMSlot], A

LD A, $E4
LDH [Register_BackgroundPalette], A

LD HL, DATA_01_7AAF
CALL CODE_00_38A7

CALL EnableLCDAndRender_00_3750

LD DE, POINTERS_03_4000+(17*2)
CALL ProcessStripeImageFromBank3_00_033F

LD A, $10
CALL WaitForVBlank_372E

CALL CODE_01_7DBA

XOR A
CALL CODE_00_05FF
CALL CODE_00_075F
LD HL, Buffer_DataCount

LD BC, $0103
CALL ClearRAM_00_37E0

LD D, $6E
CALL CODE_00_03D0
CALL CODE_00_05F7

LD HL, DATA_01_7AAF
CALL CODE_00_38A7
CALL EnableLCDAndRender_00_3750

LD A, $10
CALL WaitForVBlank_372E

LD DE, POINTERS_03_4000+(18*2)
CALL ProcessStripeImageFromBank3_00_033F

LD A, $01
CALL CODE_00_05FF

LD A, Music_TitleTheme                                      ;title theme at the end of the game
CALL QueueSoundPrep_00_072B                                 ;

LOOP_00_05F4:
JP LOOP_00_05F4                                             ;the game just locks at the ending screen. END

CODE_00_05F7:
SetProgramBank1

XOR A
LD [CurrentOAMSlot], A
JP CODE_01_7C30

CODE_00_05FF:
LDH [$FF94], A

LD A, $02
LD [MessageCharacterTimer], A

LD HL, CurrentMessageType
LD BC, $0028                                                ;clear some message box related RAM
CALL ClearRAM_00_37E0

SetBankAndBackup 3                                          ;set program bank 3
CALL CODE_03_402A
JP LOOP_00_3B1A

DATA_00_061C:
db $00,$00,$05,$00

CODE_00_0620:
LD HL, $C627
BIT 0, [HL]
JR Z, CODE_00_0639
RES 0, [HL]
LD A, [PlayerLives]
SUB $01                                                     ;minus one life.
LD [PlayerLives], A
JR NC, CODE_00_0639

CALL EnableLCDAndRender_00_3750
JP RESET_00_0150                                            ;game over = restart the game

CODE_00_0639:
LD DE, POINTERS_02_4000+(1*2)
CALL ProcessStripeImageFromBank2_00_032A                    ;draw status bar

SetProgramBank1
LD A, $02
LD [$C8F8], A

CALL CODE_00_04CA

XOR A
LD [$C8F8], A

CALL CODE_00_074E

LD HL, DATA_01_7AB9
CALL SetPalettes_01_7ABC

LD A, $01
LD [$C1A9], A
CALL EnableLCDAndRender_00_3750

XOR A
LDH [CurrentMusic], A
LDH [SFXQueue], A
LD [Player_State], A
LD [$CA01], A
LD [$CA00], A
LD [$DF54], A
LD [Player_InvincibilityTimer], A
LD [$DF71], A

LD A, [PlayerHealthMax]
LD [PlayerHealth], A

LD HL, DATA_00_061C
LD DE, $CA0E
LD BC, $0004
CALL TransferData_00_37F7

CODE_00_0686:
LD A, $01
CALL WaitForVBlank_372E

LD HL, $C1FD
LDH A, [JoypadInputPress]
BitA JoypadInput_Start
JR Z, CODE_00_069D

LD A, [HL]
XOR $01
LD [HL], A

LD A, $06
CALL QueueSoundPrep_00_072B

CODE_00_069D:
BIT 0, [HL]
JR NZ, CODE_00_0686

LDH A, [JoypadInputPress]                                   ;check if pressed select
BitA JoypadInput_Select                                     ;
JR Z, CODE_00_06BD                                          ;

LD A, [MoneyTotal]                                          ;
CP $03                                                      ;check if have 3 millions
JR C, CODE_00_06BD                                          ;

LD DE, MoneyTotal+3
LD HL, HealthRefillValue_00_0785+3
CALL SubstractFrom4ByteCounter_00_395D                      ;pay 3 million dollars

LD A, [PlayerHealthMax]                                     ;restore player's health.
LD [PlayerHealth], A

CODE_00_06BD:
CALL SetLevelMusicPrep_00_0725
CALL CODE_00_0FE5
CALL CODE_00_0DC6
CALL CODE_00_0462

SetProgramBank1
LD A, [$C627]
BIT 7, A
JP NZ, CODE_00_045E
BIT 0, A
JR Z, CODE_00_06DE
LD A, $A0
CALL WaitForVBlank_372E
JP CODE_00_0257

CODE_00_06DE:
CALL CODE_00_39AA
JP C, CODE_00_0257

LD A, [CurrentMessage]                                      ;check if we should display a message
AND A
CALL NZ, CODE_00_06EE

JP CODE_00_0686


CODE_00_06EE:
SetProgramBank1
CALL CODE_01_7E6E
CALL CODE_00_0FE5
CALL SetProgramBank2_00_0337

LD BC, $0903
CALL CODE_00_38E7

SetProgramBank1
CALL DisplayMessage_00_3AD5
JP C, CODE_00_0257

LD A, [$C1A6]
SWAP A
AND $0F
LD [MBC1Bank], A
LDH [CurrentProgramBank], A

LD A, [$C1A6]
AND $0F
LD B, A
LD C, $03
CALL CODE_00_38E7

XOR A
LD [Player_State], A

SetProgramBank1
CALL CODE_01_7E94
RET

SetLevelMusicPrep_00_0725:
CALL SetProgramBank2_00_0337
JP SetLevelMusic_JMP_02_4026

;i think this is sound effect related
;input A - sound effect or music to queue.
QueueSoundPrep_00_072B:
PUSH HL
PUSH BC
LD B, A                                                     ;input A move into B for the subroutine

LDH A, [CurrentProgramBank]                                 ;save bank
PUSH AF                                                     ;

SetBankAndBackup 2
CALL QueueSound_JMP_02_4032

POP AF
LD [MBC1Bank], A                                            ;restore bank
LDH [CurrentProgramBank], A

POP BC
POP HL
RET

DATA_00_0744:
db $01,$20,$00,$44,$00,$00,$87,$D3
db $00,$33

CODE_00_074E:
LD HL, DATA_00_0744
LD DE, $C200
LD BC, $000A
JP TransferData_00_37F7

;wait a single frame for VBlank, used for sync
WaitFrame_00_075A:
LD A, $01
JP WaitForVBlank_372E

;Wait until A or B had been pressed. Used for message box,
CODE_00_075F:
CALL WaitFrame_00_075A

LDH A, [JoypadInputPress]
AND JoypadInput_A|JoypadInput_B
JR Z, CODE_00_075F
RET

;various counter values
;first byte - millions and tens millions
;second byte - tens thousands and hundred thousands
;third byte - thousands and hundreds
;fourth byte - tens and ones

DATA_00_0769:
db $00,$00,$00,$01

DATA_00_076D:
db $00,$00,$10,$00

DATA_00_0771:
db $00,$00,$20,$00

DATA_00_0775:
db $00,$01,$00,$00

;money values that are added by items.
DATA_00_0779:
db $00,$05,$00,$00

;used for the statue's toll
StatuePayValue_00_077D:
db $00,$30,$00,$00

;legendary treasure's value
LegendaryTreasureValue_00_0781:
db $01,$00,$00,$00

;used to refill health by pressing select
HealthRefillValue_00_0785:
db $03,$00,$00,$00

;handle cursor matters
HandleCursorPrep_00_0789:
LD B, A                                                     ;store current choice
CALL SetProgramBank2_00_0337
CALL HandleCursor_JMP_02_402C

SetProgramBank1
LD A, B                                                     ;get potentially new choice
RET

DATA_00_0793:
db $02,$D5,$C6,$71,$E6,$02,$D5,$C6
db $00,$00,$04,$AC,$C8,$52,$52,$04
db $AC,$C8,$D2,$D3,$02,$6E,$C7,$64
db $65,$02,$EA,$C7,$64,$65,$01,$8E
db $C8,$D2,$D3

CODE_00_07B6:
PUSH BC
PUSH DE
PUSH HL
LD HL, DATA_00_0793
RST $20
LD B, A
INC HL
LD A, [HL+]
LD E, A
LD A, [HL+]
LD D, A

CODE_00_07C3:
LD A, [HL+]
LD [DE], A
INC DE
LD A, [HL-]
LD [DE], A
LD A, E
ADD A, $09
LD E, A
JR NC, CODE_00_07CF
INC D

CODE_00_07CF:
DEC B
JR NZ, CODE_00_07C3
POP HL
POP DE
POP BC
RET



CODE_00_07D6:
PUSH DE
PUSH HL
LD D, E
LD E, B
LD A, C
CALL CODE_00_0AE1
LD C, D
LD D, H
LD E, L
JP CODE_00_09EA


CODE_00_07E4:
PUSH DE
PUSH HL
LD E, B
LD A, C
CALL CODE_00_0AE1
LD A, [HL]
BIT 3, C
JR NZ, CODE_00_07F2
SWAP A

CODE_00_07F2:
AND $0F
POP HL
POP DE
RET



CODE_00_07F7:
LD A, [$C633]
LD L, A
LDH A, [$FF8D]
ADD A, L
SUB $10
AND $F0
LDH [$FF8D], A
LD A, [$C632]
LD H, A
LD A, [$C631]
LD L, A
LDH A, [$FF8E]
RST $18
LD A, L
AND $F0
LD L, A
LDH [$FF8E], A
RET



CODE_00_0816:
CALL CODE_00_07F7
LD D, H
LD E, L
CALL CODE_00_0837
LDH A, [$FF8D]
SWAP A
AND $07
JR Z, CODE_00_082D
LD B, A
XOR A

CODE_00_0828:
ADD A, $0A
DEC B
JR NZ, CODE_00_0828

CODE_00_082D:
RST $18

SetBankAndBackup 1                                          ;we have a perfectly fine RST $38!

LD A, [HL]
RET

CODE_00_0837:
SWAP D
LD A, E
AND $F0
SWAP A
OR D
LD HL, $C650
LD DE, $0050
LD C, $00

CODE_00_0847:
CP $0A
JR C, CODE_00_0851
SUB $0A
ADD HL, DE
INC C
JR CODE_00_0847

CODE_00_0851:
LD D, $00
LD E, A
ADD HL, DE
LD [$C63F], A
LD A, C
LD [$C63D], A
RET

CODE_00_085D:
PUSH HL
SLA L
RL H
LD B, H
LD A, [$C64C]
LD L, A
LD A, [$C64D]
LD H, A
LD A, B
RST $28
LD H, D
LD L, E
LD DE, $C650
CALL CODE_00_3929
POP HL
RET

CODE_00_0877:
PUSH BC
PUSH HL
LD B, $00
LD C, [HL]
SLA C
RL B
SLA C
RL B

SetBankAndBackup 3

LD HL, $CE1F
ADD HL, BC
LD BC, $0004
CALL TransferData_00_37F7

SetBankAndBackup 1

POP HL
POP BC
RET

CODE_00_089F:
LD A, D
BIT 7, A
RET NZ

CP $05
RET NC

PUSH BC
PUSH DE
PUSH HL

SetBankAndBackup 1

LD A, H
LDH [$FFA3], A
LD A, L
LDH [$FFA2], A
LDH [$FF8D], A
LD A, E
LDH [$FF8E], A
CALL CODE_00_37B6
CALL CODE_00_0837
LD DE, $C8D0
LD B, $08

CODE_00_08C6:
LD A, [HL]
LD [DE], A
INC DE
LD A, $0A
RST $18
DEC B
JR NZ, CODE_00_08C6
CALL CODE_00_0EB4
LD HL, $C8D0
LD DE, $C8D8
LD B, $08

CODE_00_08DA:
CALL CODE_00_0877
INC HL
DEC B
JR NZ, CODE_00_08DA
LDH A, [$FF8F]
LD D, A
LDH A, [$FF90]
LD E, A
LD HL, $C8D0
LD B, $08

CODE_00_08EC:
CALL CODE_00_0956
INC HL
LD A, E
ADD A, $40
LD E, A
JR NC, CODE_00_08F7
INC D

CODE_00_08F7:
DEC B
JR NZ, CODE_00_08EC
LD HL, $C8D8
LD B, $10

CODE_00_08FF:
PUSH BC
LD B, $02
CALL DrawStripeImage_00_380F
LDH A, [$FF90]
ADD A, $20
LDH [$FF90], A
JR NC, CODE_00_0912
LDH A, [$FF8F]
INC A
LDH [$FF8F], A

CODE_00_0912:
POP BC
DEC B
JR NZ, CODE_00_08FF
POP HL
POP DE
POP BC
RET


db $00,$00,$00,$00,$01,$01,$01,$01
db $02

;unknown
db $02


db $03,$03,$04,$09,$05,$07,$00,$00
db $11,$11,$00,$11,$11,$00,$AA,$AA
db $CC,$CC,$DD,$DD,$EE,$EE,$00,$FF
db $0B,$0B,$B0,$B0,$22,$22,$33,$33
db $44,$44,$55,$55,$66,$66,$99,$99
db $00,$08,$00,$80,$08,$11,$80,$11

;unknown
db $77,$77



CODE_00_0956:
LD A, [HL]
LDH [$FF94], A
SWAP A
AND $0F
PUSH HL
LD HL, $091A
RST $20
LD C, A
POP HL
LDH A, [$FF94]
AND $F0
CP $30
JR Z, CODE_00_097E
CP $B0
JR Z, CODE_00_0987
CP $D0
JR Z, CODE_00_099E
CP $E0
JR Z, CODE_00_09C9
CP $F0
JR Z, CODE_00_09D2
JR CODE_00_09DB

CODE_00_097E:
LDH A, [$FF94]
CP $34
JR C, CODE_00_09DB
INC C
JR CODE_00_09DB

CODE_00_0987:
LDH A, [$FF94]
CP $BC
JR C, CODE_00_09DB
LD C, $11
JR Z, CODE_00_09DB
INC C
CP $BD
JR Z, CODE_00_09DB
INC C
CP $BE
JR Z, CODE_00_09DB
INC C
JR CODE_00_09DB

CODE_00_099E:
LDH A, [$FF94]
CP $D8
JR NC, CODE_00_09AB
BIT 0, A
JR Z, CODE_00_09DB
INC C
JR CODE_00_09DB

CODE_00_09AB:
INC C
INC C
CP $D9
JR C, CODE_00_09DB
INC C
CP $DA
JR C, CODE_00_09DB
INC C
CP $DB
JR C, CODE_00_09DB
INC C
CP $DC
JR C, CODE_00_09DB
INC C
CP $DF
JR NZ, CODE_00_09DB
LD C, $01
JR CODE_00_09DB

CODE_00_09C9:
LDH A, [$FF94]
CP $EB
JR C, CODE_00_09DB
INC C
JR CODE_00_09DB

CODE_00_09D2:
LDH A, [$FF94]
CP $F4
JR C, CODE_00_09DB
INC C
JR CODE_00_09DB

CODE_00_09DB:
PUSH DE
PUSH HL
SRL D
RR E
LD A, E
LD DE, $C8FD
ADD A, E
LD E, A
JR NC, CODE_00_09EA
INC D

CODE_00_09EA:
LD A, C
ADD A, A
LD HL, $092A
RST $18
LD A, [HL+]
LD [DE], A
LD A, E
ADD A, $10
LD E, A
JR NC, CODE_00_09F9
INC D

CODE_00_09F9:
LD A, [HL]
LD [DE], A
POP HL
POP DE
RET



CODE_00_09FE:
LDH [$FF96], A
PUSH BC
PUSH DE
PUSH HL
XOR A
LD [$CA0D], A
LD A, [$C1A2]
AND A
JR NZ, CODE_00_0A23
LD [TileDetectionArray+253], A
LD [$CA00], A
LD [$CA05], A
LD [$CA06], A
LD HL, $C208
RES 7, [HL]
LD HL, $CA0D
LD [HL], $03

CODE_00_0A23:
LD HL, $CA0D
LD A, [$C601]
LD D, A
LD A, [$C603]
ADD A, [HL]
LD E, A
LD A, [$C609]
AND $0F
SLA A
SLA A
SUB [HL]
LDH [$FF9A], A
SLA A
LDH [$FF94], A
LD A, [$C609]
SWAP A
AND $0F
SLA A
SLA A
LDH [$FF9B], A
SLA A
LDH [$FF95], A
XOR A
LDH [$FF98], A
LD B, $03
LDH A, [$FF96]
BIT 0, A
JR NZ, CODE_00_0A70
BIT 1, A
JR NZ, CODE_00_0A73
DEC D
DEC D
LDH A, [$FF95]
ADD A, D
LD D, A
LDH A, [$FF96]
BIT 2, A
JR NZ, CODE_00_0A79
BIT 3, A
JR NZ, CODE_00_0A7C
RET


CODE_00_0A70:
DEC D
JR CODE_00_0A80

CODE_00_0A73:
LDH A, [$FF95]
ADD A, D
LD D, A
JR CODE_00_0A80

CODE_00_0A79:
DEC E
JR CODE_00_0A80

CODE_00_0A7C:
LDH A, [$FF94]
ADD A, E
LD E, A

CODE_00_0A80:
LD A, D
LDH [$FF8D], A
LD A, E
LDH [$FF8E], A
CALL CODE_00_0AD2
CALL CODE_00_0AFB
DEC B
JR Z, CODE_00_0AA6
LDH A, [$FF96]
AND $03
JR Z, CODE_00_0A9C
LDH A, [$FF9A]
LDH [$FF94], A
DEC E
JR CODE_00_0A7C

CODE_00_0A9C:
LDH A, [$FF9B]
CPL
INC A
LDH [$FF95], A
INC D
INC D
JR CODE_00_0A73

CODE_00_0AA6:
LD HL, $FF98
LD A, [$C1A2]
LD B, A
LD A, [$CA05]
OR B
JR NZ, CODE_00_0ACB
LDH A, [$FF96]
CP $02
JR NZ, CODE_00_0ACB
LD A, [HL]
AND A
JR Z, CODE_00_0ACB
CP $02
JR NC, CODE_00_0ACB
LD A, [Player_PogoFlag]
AND A
JR Z, CODE_00_0ACB
XOR A
LD [Player_PogoFlag], A

CODE_00_0ACB:
LD A, $00
CP [HL]
POP HL
POP DE
POP BC
RET



CODE_00_0AD2:
LD A, D
CP $10
JR NC, CODE_00_0ADB
LD A, $14
JR CODE_00_0AE1

CODE_00_0ADB:
CP $90
JR C, CODE_00_0AE1
LD A, $8C


CODE_00_0AE1:
PUSH DE
SUB $10
AND $F8
SLA A
LD HL, $C8FD
RST $18
LD A, [$C631]
ADD A, E
LD C, A
SWAP A
AND $0F
LD E, A
LD D, $00
ADD HL, DE
POP DE
RET

CODE_00_0AFB:
PUSH DE
LD A, [HL]
BIT 3, C
JR NZ, CODE_00_0B03
SWAP A

CODE_00_0B03:
AND $0F
ExecutePointersWithDestination CODE_00_0B29

dw CODE_00_0B30
dw CODE_00_0B32
dw CODE_00_0B3F
dw CODE_00_0B43
dw CODE_00_0B47
dw CODE_00_0B4B
dw CODE_00_0B4F
dw CODE_00_0B30                                             ;unused pointer (duplicate)
dw CODE_00_0B5E
dw CODE_00_0B53
dw CODE_00_0B70
dw CODE_00_0B85
dw CODE_00_0B9D
dw CODE_00_0BB0
dw CODE_00_0BBD
dw CODE_00_0BE2

CODE_00_0B29:
LD HL, $FF98
ADD A, [HL]
LD [HL], A
POP DE
RET

CODE_00_0B30:
XOR A
RET


CODE_00_0B32:
LD A, $01
RET


db $00,$03,$00,$04,$00,$05,$01,$04
db $02

;unknown
db $05


CODE_00_0B3F:
LD C, $00
JR CODE_00_0B55

CODE_00_0B43:
LD C, $02
JR CODE_00_0B55

CODE_00_0B47:
LD C, $04
JR CODE_00_0B55

CODE_00_0B4B:
LD C, $06
JR CODE_00_0B55

CODE_00_0B4F:
LD C, $08
JR CODE_00_0B55

CODE_00_0B53:
LD C, $0C

CODE_00_0B55:
CALL CODE_00_0BEE
LD A, $01
LD [$CA05], A
RET


CODE_00_0B5E:
LD A, [$C1A2]
AND A
JR NZ, CODE_00_0B6E
LD A, B
CP $02
JR NZ, CODE_00_0B6E
LD A, $01
LD [$CA08], A

CODE_00_0B6E:
XOR A
RET


CODE_00_0B70:
LD A, [$C1A2]
AND A
JR NZ, CODE_00_0B32
LD A, $01
LD [$CA04], A
LD A, [$C208]
OR $80
LD [$C208], A
XOR A
RET


CODE_00_0B85:
LD A, [$C1A2]
AND A
JR NZ, CODE_00_0B9B
LDH A, [$FF96]
AND $03
JR Z, CODE_00_0B9B
LD A, B
CP $02
JR NZ, CODE_00_0B9B
LD A, $01
LD [TileDetectionArray+253], A

CODE_00_0B9B:
XOR A
RET


CODE_00_0B9D:
LD A, [$C1A2]
AND A
JR NZ, CODE_00_0BAD
LDH A, [$FF96]
CP $02
JR NZ, CODE_00_0BAD
LD HL, $C9FE
INC [HL]

CODE_00_0BAD:
LD A, $01
RET


CODE_00_0BB0:
LD A, [$C1A2]
AND A
JP NZ, CODE_00_0B32
LD A, $01
LD [TileDetectionArray+255], A
RET


CODE_00_0BBD:
LD A, [$C1A2]
AND A
JR NZ, CODE_00_0BDF
LDH A, [$FF96]
AND $03
JR Z, CODE_00_0BDF
LD A, B
CP $02
JR NZ, CODE_00_0BDF
LD A, [Player_PogoFlag]
AND A
JR Z, CODE_00_0BDA
LDH A, [$FF96]
BIT 1, A
JR NZ, CODE_00_0BDF

CODE_00_0BDA:
LD A, $01
LD [$CA00], A

CODE_00_0BDF:
LD A, $01
RET


CODE_00_0BE2:
LD A, [$C1A2]
AND A
JR NZ, CODE_00_0BEC
INC A
LD [$CA01], A

CODE_00_0BEC:
XOR A
RET



CODE_00_0BEE:
LD A, [$C1A2]
AND A
JR Z, CODE_00_0BF8
POP AF
LD A, $01
RET


CODE_00_0BF8:
LD A, [$CA05]
AND A
RET NZ

LDH A, [$FF96]
AND $03
JR Z, CODE_00_0C15
BIT 1, A
RET Z

LDH A, [$FF98]
AND A
RET NZ

LD A, [Player_PogoFlag]
AND A
RET Z

LD A, C
LD [$CA06], A
JR CODE_00_0C3C

CODE_00_0C15:
LD A, B
CP $01
JR NZ, CODE_00_0C29
LDH A, [$FF98]
AND A
RET NZ

LD A, [$CA0C]
AND A
JR Z, CODE_00_0C31
DEC A
LD [$CA0C], A
RET


CODE_00_0C29:
CP $03
RET NZ

LD A, $40
LD [$CA0C], A

CODE_00_0C31:
LD A, [$DF5E]
CP $04
RET NZ

LD A, C
INC A
LD [$CA06], A

CODE_00_0C3C:
PUSH BC
LDH A, [$FF8E]
LD B, A
LD A, [$C631]
LD C, A
ADD A, B
AND $F0
SUB C
LD B, A
LDH A, [$FF8D]
AND $F0
LD C, A
LD A, [$CA06]
CP $0C
JR C, CODE_00_0C63
AND $01
ADD A, $01
LD HL, $CA09
LD [HL+], A
LD A, C
LD [HL+], A
LD A, B
LD [HL+], A
JR CODE_00_0C79

CODE_00_0C63:
LDH A, [$FF94]
PUSH AF
LD A, [$CA06]
LD HL, $0B35
RST $20
LD D, A
LD A, $01
LD [$CA06], A
CALL CODE_00_361E
POP AF
LDH [$FF94], A

CODE_00_0C79:
CALL CODE_00_0816
LDH [$FF9C], A
POP BC
JR CODE_00_0C91


CODE_00_0C81:
LDH [$FF9C], A
CP $9F
JR NZ, CODE_00_0C8E
CALL Z, CODE_00_0816
LDH [$FF9C], A
JR CODE_00_0C91

CODE_00_0C8E:
CALL CODE_00_07F7


CODE_00_0C91:
CALL CODE_00_37B6
LD HL, $FF9C
LDH A, [$FF8F]
LD D, A
LDH A, [$FF90]
LD E, A
CALL CODE_00_0956
LD HL, $FF9C
LD DE, $FF9E
CALL CODE_00_0877
LD HL, $FF9E
LD C, $02

CODE_00_0CAE:
PUSH BC
LD B, $02
CALL DrawStripeImage_00_380F
LDH A, [$FF90]
ADD A, $20
LDH [$FF90], A
JR NC, CODE_00_0CC1
LDH A, [$FF8F]
INC A
LDH [$FF8F], A

CODE_00_0CC1:
POP BC
DEC C
JR NZ, CODE_00_0CAE
RET



CODE_00_0CC6:
LD A, [FrameCounter]
AND $03
CP $03
JR Z, CODE_00_0CDF
LD A, [$CA04]
AND A
JP NZ, CODE_00_0B70
LD A, [$C208]
AND $7F
LD [$C208], A
RET


CODE_00_0CDF:
LD A, [$C1A2]
AND A
RET NZ

PUSH BC
PUSH DE
PUSH HL
XOR A
LD [$CA08], A
LD [$CA00], A
LD [TileDetectionArray+255], A
LD [$CA04], A
LD HL, $C209
LD A, [HL]
AND $0F
SLA A
SLA A
LDH [$FFA0], A
LD A, [HL]
SWAP A
AND $0F
SLA A
SLA A
SLA A
LDH [$FFA2], A
LD A, [$C201]
LD D, A
LD A, [$C203]
LD E, A
DEC D
LDH A, [$FFA0]
ADD A, E
LD E, A
LD A, $01
LDH [$FF96], A
CALL CODE_00_0D31
INC D
LDH A, [$FFA2]
ADD A, D
LD D, A
LD A, $02
LDH [$FF96], A
CALL CODE_00_0D31
POP HL
POP DE
POP BC
RET



CODE_00_0D31:
CALL CODE_00_0AD2
LD A, [HL]
BIT 3, C
JR NZ, CODE_00_0D3B
SWAP A

CODE_00_0D3B:
AND $0F
CP $08
JR NZ, CODE_00_0D44
JP CODE_00_0B5E

CODE_00_0D44:
CP $0A
JR NZ, CODE_00_0D4B
JP CODE_00_0B70

CODE_00_0D4B:
CP $0D
JR NZ, CODE_00_0D52
JP CODE_00_0BB0

CODE_00_0D52:
CP $0E
JR NZ, CODE_00_0D5B
LD B, $02
JP CODE_00_0BBD

CODE_00_0D5B:
RET



CODE_00_0D5C:
PUSH BC
LD B, D
LD A, [$C632]
SWAP A
LD D, A
LD A, [$C631]
AND $0F
LD E, A
LD A, [$C631]
AND $F0
SWAP A
OR D
LD C, $00

CODE_00_0D74:
CP $0A
JR C, CODE_00_0D7D
SUB $0A
INC C
JR CODE_00_0D74

CODE_00_0D7D:
SWAP A
OR E
JR Z, CODE_00_0D8C
SCF
LD A, B
DEC A
BIT 1, A
JR NZ, CODE_00_0DC4
CCF
JR CODE_00_0DC4

CODE_00_0D8C:
SetBankAndBackup 1

LD A, [$C634]
LD H, A
LD A, [$C633]
SLA A
RL H
SLA H
SLA H
LD A, C
SRL A
ADD A, H
LD E, A
LD D, $00
LD A, [$C64A]
LD L, A
LD A, [$C64B]
LD H, A
ADD HL, DE
LD A, [HL]
BIT 0, C
JR NZ, CODE_00_0DBF
SRL A
SRL A
SRL A
SRL A

CODE_00_0DBF:
SRL A
DEC B
JR NZ, CODE_00_0DBF

CODE_00_0DC4:
POP BC
RET



CODE_00_0DC6:
LD HL, $C8F8
LD A, [HL]
AND A
JR NZ, CODE_00_0DF6
LD HL, $C647
LD DE, $C634
LD A, [DE]
AND $0F
CP [HL]
RET NZ

DEC HL
DEC DE
LD A, [DE]
AND $F0
CP [HL]
RET NZ

DEC HL
DEC DE
LD A, [DE]
AND $0F
CP [HL]
RET NZ

DEC HL
DEC DE
LD A, [DE]
AND $F0
CP [HL]
RET NZ

LD A, [$C627]
SET 2, A
LD [$C627], A
RET


CODE_00_0DF6:
BIT 0, [HL]
JR Z, CODE_00_0E33
LD [HL], $00
LD HL, $C631
LD A, [$C8F9]
ADD A, [HL]
LD [HL+], A
LD A, [$C8FA]
ADC A, [HL]
LD [HL], A
LD A, [$C631]
AND $0F
RET NZ

LD BC, $00C0
LD A, [$C8FA]
BIT 7, A
JR Z, CODE_00_0E1C
LD BC, $FFD0

CODE_00_0E1C:
LD A, [$C631]
ADD A, C
LD E, A
LD A, [$C632]
ADC A, B
LD D, A
LD A, [$C634]
LD H, A
LD A, [$C633]
LD L, A
CALL CODE_00_089F
JR CODE_00_0E9E

CODE_00_0E33:
BIT 1, [HL]
RET Z

BIT 7, [HL]
JR NZ, CODE_00_0E61
LD BC, $0080
LD A, [$C8FA]
BIT 7, A
JR Z, CODE_00_0E47

LD BC, OAMUploadCode

CODE_00_0E47:
LD A, [$C633]
ADD A, C
LD L, A
LD A, [$C634]
ADC A, B
LD H, A
CALL CODE_00_04E6
LD A, [$C8F8]
OR $80
LD [$C8F8], A
LD A, $40
LD [$C8FB], A

CODE_00_0E61:
LD DE, $0002
LD HL, $FFFF
LD A, [$C8FA]
BIT 7, A
JR Z, CODE_00_0E74
LD DE, $FFFE
LD HL, $0001

CODE_00_0E74:
LD A, [$C633]
ADD A, E
LD [$C633], A
LD A, [$C634]
ADC A, D
LD [$C634], A
LD A, [FrameCounter]
BIT 0, A
JR Z, CODE_00_0E8B
SLA L

CODE_00_0E8B:
LD A, [$C201]
ADD A, L
LD [$C201], A
LD A, [$C202]
ADC A, H
LD [$C202], A
LD HL, $C8FB
DEC [HL]
RET NZ


CODE_00_0E9E:
XOR A
LD [$C8F8], A
LD [$C8F9], A
LD [$C8FA], A
RET

;unknown
db $00


db $D8,$D9,$DA,$DB,$DC

;unknown
db $00,$00


db $DF,$DF

;unknown
db $DF



CODE_00_0EB4:
LD A, [$C64F]
LD H, A
LD A, [$C64E]
LD L, A
LDH A, [$FFA2]
LD C, A
LDH A, [$FFA3]
SLA C
RL A
SWAP A
RST $18
LD A, [$C63D]
RST $28
LD H, D
LD L, E
LD A, H
AND A
RET Z

XOR A
LDH [$FFA0], A

CODE_00_0ED4:
LDH A, [$FFA0]
AND A
RET NZ

LD A, [$C63F]
LD B, A

CODE_00_0EDC:
LD A, [HL+]
LDH [$FF94], A
AND $0F
CP B
JR Z, CODE_00_0EEA
BIT 7, [HL]
RET NZ

INC HL
JR CODE_00_0EDC

CODE_00_0EEA:
LD E, $FF
BIT 7, [HL]
JR Z, CODE_00_0EF4
LD A, $01
LDH [$FFA0], A

CODE_00_0EF4:
LD A, [HL+]
AND $7F
CP $10
JR NC, CODE_00_0F19
PUSH HL
LD HL, $0EA9
RST $20
LD B, A
LDH A, [$FF94]
SWAP A
AND $0F
LD HL, $C8D0
RST $18
LD [HL], B
POP HL
DEC HL
LD A, [HL+]
AND $7F
LD B, A
CP $08
JR C, CODE_00_0ED4
PUSH HL
JR CODE_00_0F60

CODE_00_0F19:
PUSH HL
LD B, A
LD A, [CurrentLand]                                         ;check if we're in "Dracula Duck's Manor"
CP $05
JR Z, CODE_00_0F2B

LD HL, LandBeatenFlags
RST $20
POP HL
PUSH HL
AND A
JR Z, CODE_00_0F43

CODE_00_0F2B:
LD A, B
CP $23
JR Z, CODE_00_0F3A
CP $30
JR C, CODE_00_0F5C
CP $68
JR NC, CODE_00_0F5C
JR CODE_00_0F60

CODE_00_0F3A:
LD A, [$CA1D]
BIT 3, A
JR NZ, CODE_00_0F5C
JR CODE_00_0F60

CODE_00_0F43:
LD A, B
CP $30
JR NC, CODE_00_0F60
LD A, [$C64E]
SUB L
LD E, A
LD A, [$C64F]
SBC A, H
LD D, A
SRL D
RR E
LD D, $C5
LD A, [DE]
AND A
JR NZ, CODE_00_0F60

CODE_00_0F5C:
POP HL
JP CODE_00_0ED4

CODE_00_0F60:
LD D, B
LD A, [$C8F8]
BIT 1, A
JR Z, CODE_00_0F78
LD A, [$C63E]
CP $0A
JR NC, CODE_00_0F71
LDH A, [$FF94]

CODE_00_0F71:
AND $0F
SWAP A
LD B, A
JR CODE_00_0F83

CODE_00_0F78:
LD B, $C0
LD A, [$C8FA]
BIT 7, A
JR Z, CODE_00_0F83
LD B, $D0

CODE_00_0F83:
LDH A, [$FF94]
AND $F0
ADD A, $10
LD C, A
CALL CODE_00_361E
POP HL
JP CODE_00_0ED4

;AN UNUSED RETURN OPCODE!!! WOW, HUGE DISCOVERY
RET

CODE_00_0F92:
LD HL, $C200
LD BC, $C600
LD A, [$C1A2]
LD D, A
LD L, A
CALL CODE_00_0FB4
LD L, D
INC H
JR CODE_00_0FB4


CODE_00_0FA4:
LD HL, $C600
LD BC, $C200
LD A, [$C1A2]
LD D, A
LD C, A
CALL CODE_00_0FB4
LD C, D
INC B

CODE_00_0FB4:
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
LD A, [HL+]
LD [BC], A
INC C
RET

CODE_00_0FE5:
XOR A
LD [$C1A2], A
LD [CurrentOAMSlot], A

SetBankAndBackup 1

CODE_00_0FF3:
LD HL, $C200
LD A, [$C1A2]
OR L
LD L, A

LD A, [HL]
AND $7F
JR Z, CODE_00_1023
LD E, A
CALL CODE_00_0F92

LD A, E
ExecutePointersWithDestination CODE_00_1011

dw CODE_00_1033                                             ;unused pointer
dw CODE_00_118A
dw CODE_00_1A28
dw CODE_00_104D

CODE_00_1011:
CALL CODE_00_10B6
LD A, [$C1A2]
AND A
CALL NZ, CODE_00_0FA4

LD A, [$C600]
BIT 7, A
CALL Z, CODE_01_7EA0

CODE_00_1023:
LD A, [$C8F8]
BIT 1, A
JR NZ, CODE_00_1033

LD HL, $C1A2
LD A, [HL]
ADD A, $10
LD [HL], A
JR NC, CODE_00_0FF3

CODE_00_1033:
LD HL, OAM_Y

LD A, [CurrentOAMSlot]
ADD A, L
LD L, A

LOOP_00_103B:
CP $A0                                                      ;loop until stored to all OAM tiles
RET NC

LD [HL], $00                                                ;off this OAM tile

ADD A, $04                                                  ;next OAM slot
LD L, A
JR LOOP_00_103B

db $00,$A6,$00,$B6,$00,$A5,$00,$B5

CODE_00_104D:
XOR A
LD [$C605], A
LD A, [FrameCounter]
CP $10
RET NC

LD A, $01
LD [$C605], A
RET

CODE_00_105D:
LD A, [$C8F8]
BIT 1, A
RET NZ

XOR A
LD [$CA07], A
LD A, $08
CALL CODE_00_09FE
JR C, CODE_00_10B0
LD D, $04
LD A, [$C203]
CP $88
RET NC
CP $44
JR NC, CODE_00_109F
JR CODE_00_1099

CODE_00_107C:
LD A, [$C8F8]
BIT 1, A
RET NZ

XOR A
LD [$CA07], A
LD A, $04
CALL CODE_00_09FE
JR C, CODE_00_10B0
LD D, $03
LD A, [$C203]
CP $08
RET C

CP $44
JR C, CODE_00_109F

CODE_00_1099:
LD HL, $C203
JP CODE_00_1183

CODE_00_109F:
CALL CODE_00_0D5C
JR NC, CODE_00_1099


CODE_00_10A4:
LD A, $01
LD [$C8F8], A
LD HL, $C8F9
LD [HL], C
INC HL
LD [HL], B
RET

CODE_00_10B0:
LD A, $01
LD [$CA07], A
RET

CODE_00_10B6:
LD A, [$C8F8]
BIT 0, A
RET Z

LD A, [$C1A2]
AND A
RET Z

LD A, [$C600]
AND A
RET Z

LD HL, $C603
LD BC, $0010

CODE_00_10CC:
LD A, [$C8FA]
AND A
JR NZ, CODE_00_10DE
DEC [HL]
ADD HL, BC
DEC [HL]
LD A, [HL]
CP $C0
RET C

CP $CE
RET NC

JR CODE_00_10E8

CODE_00_10DE:
INC [HL]
ADD HL, BC
INC [HL]
LD A, [HL]
CP $C2
RET C

CP $D0
RET NC

CODE_00_10E8:
LD A, B
AND A
RET NZ

JP CODE_00_36D8

CODE_00_10EE:
LD B, $FF
LD A, [$C8F8]
BIT 1, A
RET NZ

XOR A
LD [$CA03], A
LD A, $01
CALL CODE_00_09FE
JR NC, CODE_00_1107
LD A, $01
LD [$CA03], A
RET

CODE_00_1107:
LD A, [$C201]
CP $F0
RET NC

LD A, [Player_State]
CP $03
JR NZ, CODE_00_114E

LD A, [$C201]
CP $20
LD D, $01
JR C, CODE_00_1155
JR CODE_00_114E


CODE_00_111F:
LD B, $00
LD A, [$C8F8]
BIT 1, A
RET NZ

XOR A
LD [$CA02], A
LD [TileDetectionArray+254], A
LD A, $02
CALL CODE_00_09FE
JR NC, CODE_00_113B

LD A, $01
LD [$CA02], A
RET

CODE_00_113B:
LD A, [$C201]
CP $F0
JR NC, CODE_00_114E
LD A, [$C201]
CP $A0
RET NC

CP $80
LD D, $02
JR NC, CODE_00_1155

CODE_00_114E:
LD HL, $C201
CALL CODE_00_1183
RET

CODE_00_1155:
CALL CODE_00_0D5C
JR NC, CODE_00_114E
LD A, $02
LD [$C8F8], A
LD A, B
LD [$C8FA], A
LD A, [$C630]
AND A
RET NZ

LD HL, $C210
LD BC, $00F0
CALL ClearRAM_00_37E0

LD HL, $C310
LD BC, $00F0
CALL ClearRAM_00_37E0

LD HL, OAM_Y
LD BC, $00A0
JP ClearRAM_00_37E0

CODE_00_1183:
CALL CODE_00_37AE
LD A, [HL]
ADD A, C
LD [HL], A
RET

CODE_00_118A:
LD HL, $DF4F
INC [HL]
LD A, [Player_State]
CP $08
JP Z, CODE_00_16D4

LD HL, CODE_00_1203
PUSH HL
LD A, $01
LD [$C200], A

LD HL, Player_InvincibilityTimer
LD A, [HL]
AND A
JR Z, CODE_00_11C0

LD A, [$DF4F]
AND $01
JR NZ, CODE_00_11AE
DEC [HL]

CODE_00_11AE:
LD A, [HL]
CP $02
JR NC, CODE_00_11B7
XOR A
LD [HL], A
LDH [CurrentMusic], A

CODE_00_11B7:
AND $01
RET NZ

LD A, $81
LD [$C200], A
RET

CODE_00_11C0:
LD A, [$DF54]
AND A
JR NZ, CODE_00_11F5
LD A, [$CA00]
AND A
RET Z

LD A, $05
CALL QueueSoundPrep_00_072B

LD A, $06
LD [Player_State], A


CODE_00_11D5:
LD A, $80
LD [$DF54], A

CALL CODE_00_1417
LD [Player_PogoFlag], A
LD [$CA00], A

LD HL, PlayerHealth
DEC [HL]

LD A, [SelectedDifficulty]                                  ;check if difficulty is EZ
AND A                                                       ;
JR Z, CODE_00_11EE                                          ;

DEC [HL]                                                    ;double damage (so every sphere is one hitpoint instead of two)

CODE_00_11EE:
LD A, [HL]                                                  ;check if zero health
AND A                                                       ;
RET NZ                                                      ;

POP HL                                                      ;oops.
JP CODE_00_16D4                                             ;

CODE_00_11F5:
AND $04
JR NZ, CODE_00_11FE

LD A, $81
LD [$C200], A

CODE_00_11FE:
LD HL, $DF54
DEC [HL]
RET

CODE_00_1203:
LD A, [Player_State]
AND A
JR Z, CODE_00_1217
CP $05
JR Z, CODE_00_1217

XOR A
LD [$DF63], A
LD [$DF64], A

LD A, [Player_State]

CODE_00_1217:
ExecutePointersWithDestination CODE_00_123D

;player states!
dw CODE_00_12C3
dw CODE_00_17AE
dw CODE_00_17ED
dw CODE_00_189C
dw CODE_00_148D
dw CODE_00_1747
dw CODE_00_1783
dw CODE_00_1725
dw CODE_00_16D4                                             ;unused pointer
dw CODE_00_1763
dw CODE_00_15E1
dw CODE_00_162E
dw CODE_00_168B
dw CODE_00_159B
dw CODE_00_16C3
dw CODE_00_15D5
dw CODE_00_123D

CODE_00_123D:
CALL CODE_00_0CC6

CODE_00_1240:
LD HL, DATA_00_19D0
LD A, [Player_AnimationFrame]
SLA A
SLA A
LD C, A
LD B, $00
ADD HL, BC
LD A, [HL+]
LD [$C205], A

LD A, [HL+]
LD [$C209], A

LD A, [HL+]
LD [$C206], A

LD A, [HL]
LD [$C207], A
RET

CODE_00_125F:
LD A, [TileDetectionArray+255]
AND A
JR NZ, CODE_00_1277

CODE_00_1265:
LD BC, $0001
JP CODE_00_105D

CODE_00_126B:
LD A, [TileDetectionArray+255]
AND A
JR NZ, CODE_00_1277


CODE_00_1271:
LD BC, $FFFF
JP CODE_00_107C

CODE_00_1277:
LD HL, $DF63
INC [HL]
LD A, [HL]
CP $0A
RET C

DEC [HL]
RET

CODE_00_1281:
LD A, [$DF63]
CP $00
RET Z

LD A, [$DF4F]
AND $07
JR NZ, CODE_00_1292
LD HL, $DF63
DEC [HL]

CODE_00_1292:
LD HL, $DF64
LD A, [HL]
CP $00
JR Z, CODE_00_12AB
DEC [HL]
RET NZ

LD A, [$DF63]
CP $FF
JR Z, CODE_00_12AD
LD B, A
LD A, $06
SUB B
JR Z, CODE_00_12AB
JR NC, CODE_00_12AD

CODE_00_12AB:
LD A, $01

CODE_00_12AD:
LD [$DF64], A
LD A, [$C208]
AND $20
JR NZ, CODE_00_12BD
LD BC, $0001
JP CODE_00_105D

CODE_00_12BD:
LD BC, $FFFF
JP CODE_00_107C

CODE_00_12C3:
LDH A, [JoypadInputHolding]
BitA JoypadInput_Right                                      ;check if holding right
JR Z, CODE_00_12D0

CALL CODE_00_125F

XOR A                                                       ;x-flip?
LD [$C208], A

CODE_00_12D0:
LDH A, [JoypadInputHolding]
BitA JoypadInput_Left                                       ;check if holding left
JR Z, CODE_00_12DE

CALL CODE_00_126B

LD A, $20
LD [$C208], A

CODE_00_12DE:
CALL CODE_00_1281

LD HL, $DF62
DEC [HL]
LD A, [HL]
CP $FF
JR NZ, CODE_00_131F

XOR A
LD [HL], A

LD A, [TileDetectionArray+253]
AND A
JR Z, CODE_00_131F

LDH A, [JoypadInputHolding]                                 ;check if holding up (for climbing)
BitA JoypadInput_Up
JR Z, CODE_00_131F

CALL CODE_00_1967
CALL CODE_00_1907

XOR A
LD [Player_PogoFlag], A
LD HL, $C203
LD A, [HL]
LD [$DF61], A
ADD A, $03
AND $F0
LD B, A
LD A, [$C208]
AND A
JR Z, CODE_00_1318
LD A, B
ADD A, $08
LD B, A

CODE_00_1318:
LD [HL], B

LD A, $03
LD [Player_State], A
RET

CODE_00_131F:
LD A, [$DF52]
AND A
JR NZ, CODE_00_1329
XOR A
CALL CODE_00_18F6

CODE_00_1329:
LD A, [$CA01]
AND A
JP NZ, CODE_00_16D4

LD A, [$DF65]
AND A
JP NZ, CODE_00_1346

LD A, [$CA02]
AND A
JP Z, CODE_00_1422

LD A, [$C201]
AND $FC
LD [$C201], A

CODE_00_1346:
XOR A
LD [$DF65], A

XOR A                                                       ;A is already zero...
LD [$DF52], A

LD A, [Player_State]
CP $05
RET Z

LD A, [$DF54]
CP $68
RET NC

LD A, [Player_PogoFlag]
AND A
JR Z, CODE_00_138C
LD A, [$CA02]
AND A
JR Z, CODE_00_136B
LD A, $02
CALL QueueSoundPrep_00_072B

CODE_00_136B:
LD A, [TileDetectionArray+254]
AND A
JR Z, CODE_00_1377

LD A, $07
LD [Player_State], A
RET


CODE_00_1377:
LDH A, [JoypadInputHolding]                                 ;holding B?
BitA JoypadInput_B
JR Z, CODE_00_1388                                          ;

LD A, $02
LD [Player_State], A
CALL CODE_00_1417
JP CODE_00_17ED

CODE_00_1388:
XOR A
LD [Player_PogoFlag], A

CODE_00_138C:
LD A, $00
LD [Player_AnimationFrame], A

LDH A, [JoypadInputHolding]
AND JoypadInput_Right|JoypadInput_Left
JR Z, CODE_00_13A0
LD BC, $DF53
LD HL, DATA_00_199A
CALL CODE_00_1979

CODE_00_13A0:
LD A, [$DF5B]
AND A
JR Z, CODE_00_13B4
XOR A
LD [$DF5B], A
LD A, $01
CALL QueueSoundPrep_00_072B
LD A, $01
LD [$DF5C], A

CODE_00_13B4:
LD A, [$DF5C]
AND A
JR Z, CODE_00_13C5
LD BC, $DF5C
LD HL, DATA_00_19AB
CALL CODE_00_1979
JR CODE_00_13C9

CODE_00_13C5:
XOR A
LD [$DF5B], A

CODE_00_13C9:
LD A, [$DF5E]
AND A
JP NZ, CODE_00_148D
LD A, [$CA07]
AND A
JR Z, CODE_00_13E4
LD A, $01
LD [$DF5F], A
LD A, $04
LD [Player_State], A
XOR A
LD [$CA07], A

CODE_00_13E4:
LD A, [Player_State]
CP $0C
JR Z, CODE_00_13FE
LDH A, [JoypadInputHolding]
BitA JoypadInput_Down
JR Z, CODE_00_13FE

LD A, $05
LD [Player_State], A

LD A, $01
LD [$DF5D], A
JP CODE_00_1747

CODE_00_13FE:
LDH A, [JoypadInputHolding]
BitA JoypadInput_A
CALL Z, CODE_00_1417

LD A, [$DF59]
AND A
JR NZ, RETURN_00_1416

LDH A, [JoypadInputHolding]
BitA JoypadInput_A
JR Z, RETURN_00_1416

LD A, $01
LD [Player_State], A

RETURN_00_1416:
RET

CODE_00_1417:
XOR A
LD [$DF55], A
LD [$DF56], A
LD [$DF59], A
RET


CODE_00_1422:
XOR A
LD [Player_State], A
LD A, $0C
LD [Player_AnimationFrame], A

LD A, $01
LD [$DF5B], A

LD A, [Player_PogoFlag]
AND A
JR Z, CODE_00_143B

LD A, $02
LD [Player_AnimationFrame], A

CODE_00_143B:
LD A, [$DF5E]
AND A
JR NZ, CODE_00_144E

LDH A, [JoypadInputHolding]
BitA JoypadInput_B                                          ;check if holding B in air
JR Z, CODE_00_1453

LD A, $01                                                   ;we're using pogo cane
LD [Player_PogoFlag], A
JR CODE_00_1457

CODE_00_144E:
LD A, $03
LD [Player_AnimationFrame], A

CODE_00_1453:
XOR A                                                       ;
LD [Player_PogoFlag], A                                     ;NOT using pogo cane

CODE_00_1457:
LD A, [$DF54]
AND A
JR Z, CODE_00_1466
CP $68
JR C, CODE_00_1466
LD A, $0F
LD [Player_AnimationFrame], A

CODE_00_1466:
LD A, [$DF52]
CP $04
JR NC, CODE_00_1478
LD A, [$DF4F]
AND $03
JR NZ, CODE_00_1478
LD HL, $DF52
INC [HL]

CODE_00_1478:
LD A, [$C201]
CP $80
JR C, CODE_00_1482
CALL CODE_00_1907

CODE_00_1482:
LD A, [$DF52]
CALL CODE_00_18F6
LD A, [$DF5E]
AND A
RET Z

CODE_00_148D:
CALL CODE_00_1576
LD A, [$DF5E]
CP $04
JP Z, CODE_00_155D
CP $03
JP Z, CODE_00_1544
CP $02
JR Z, CODE_00_1515

LDH A, [JoypadInputHolding]
AND JoypadInput_Right|JoypadInput_Left
JP Z, CODE_00_158C

LD A, [$DF5E]
CP $01
JP Z, CODE_00_14CA
LD A, [$DF5F]
AND A
JR Z, CODE_00_14C1
LD BC, $DF5F
LD HL, DATA_00_19AF
CALL CODE_00_1979
JR CODE_00_14FB

CODE_00_14C1:
LD A, $01
LD [$DF5E], A
XOR A
LD [$DF5F], A

CODE_00_14CA:
LD BC, $DF5F
LD HL, DATA_00_19B4
CALL CODE_00_1979
LD A, [$DF59]
AND A
JR NZ, CODE_00_14E4
XOR A
CALL CODE_00_18F6
LD A, [$CA02]
AND A
JP Z, CODE_00_1596

CODE_00_14E4:
LDH A, [JoypadInputHolding]
BitA JoypadInput_B
JR Z, CODE_00_14FB

LD A, $04
CALL QueueSoundPrep_00_072B

LD A, $02
LD [$DF5E], A

LD A, $01
LD [$DF5F], A
JR CODE_00_1515

CODE_00_14FB:
LDH A, [JoypadInputHolding]
BitA JoypadInput_A

CALL Z, CODE_00_1417

LD A, [$DF59]
AND A
JR NZ, CODE_00_1513

LDH A, [JoypadInputHolding]
BitA JoypadInput_A
JR Z, CODE_00_1513

LD A, $01
LD [Player_State], A

CODE_00_1513:
JR CODE_00_1576

CODE_00_1515:
LD A, [$DF5F]
AND A
JR Z, CODE_00_1526
LD BC, $DF5F
LD HL, DATA_00_19BA
CALL CODE_00_1979
JR CODE_00_1576

CODE_00_1526:
LD A, [$CA05]
AND A
JR NZ, CODE_00_1538
LD A, $03
LD [$DF5E], A
LD A, $09
CALL QueueSoundPrep_00_072B
JR CODE_00_153D

CODE_00_1538:
LD A, $04
LD [$DF5E], A

CODE_00_153D:
LD A, $01
LD [$DF5F], A
JR CODE_00_1576

CODE_00_1544:
LD A, [$DF5F]
AND A
JR Z, CODE_00_1555
LD BC, $DF5F
LD HL, DATA_00_19C6
CALL CODE_00_1979
JR CODE_00_1576

CODE_00_1555:
LD A, $10
LD [$DF5E], A
JP CODE_00_158C

CODE_00_155D:
LD A, [$DF5F]
AND A
JR Z, CODE_00_156E
LD BC, $DF5F
LD HL, DATA_00_19C0
CALL CODE_00_1979
JR CODE_00_1576

CODE_00_156E:
LD A, $20
LD [$DF5E], A
JP CODE_00_158C


CODE_00_1576:
LDH A, [JoypadInputHolding]
BitA JoypadInput_Right
JR Z, CODE_00_1580

LD A, $08
JR CODE_00_1588

CODE_00_1580:
LDH A, [JoypadInputHolding]
BitA JoypadInput_Left
JR Z, CODE_00_158C

LD A, $04

CODE_00_1588:
CALL CODE_00_09FE
RET C


CODE_00_158C:
XOR A
LD [$DF5E], A
LD A, [Player_State]
CP $01
RET Z

CODE_00_1596:
XOR A
LD [Player_State], A
RET

CODE_00_159B:
LD BC, $DF53
LD HL, DATA_00_199A
CALL CODE_00_1979
LD HL, $C203
LD E, [HL]
LD D, $03
LD A, [$C208]
AND $20
JR NZ, CODE_00_15B8
DEC [HL]
LD BC, $0001
INC D
JR CODE_00_15BC

CODE_00_15B8:
INC [HL]
LD BC, $FFFF

CODE_00_15BC:
LD A, [$DF4F]
AND $01
JR NZ, CODE_00_15C4
LD [HL], E

CODE_00_15C4:
PUSH HL
PUSH DE
CALL CODE_00_0D5C
POP DE
POP HL
JR NC, CODE_00_15D0
JP CODE_00_10A4

CODE_00_15D0:
XOR A
LD [Player_State], A
RET

;player during message state
CODE_00_15D5:
LD A, $00
LD [Player_AnimationFrame], A

LD A, [MessageQueue]                                        ;
LD [CurrentMessage], A                                      ;will display this message
RET                                                         ;

CODE_00_15E1:
LDH A, [JoypadInputPress]
BitA JoypadInput_A
JR Z, CODE_00_15EC

XOR A
LD [Player_State], A
RET

CODE_00_15EC:
LD B, $28
LD C, $0B
LD A, [$C208]
BIT 5, A
JR NZ, CODE_00_15F9
LD C, $02

CODE_00_15F9:
CALL CODE_00_1618
LD A, $12
LD [Player_AnimationFrame], A

CODE_00_1601:
LD HL, $C305
CALL CODE_00_1612
LD A, [HL]
AND A
RET Z

BIT 7, A
JP Z, CODE_00_1265
JP CODE_00_1271

CODE_00_1612:
LD A, [$DF67]
OR L
LD L, A
RET

CODE_00_1618:
CALL CODE_00_1622
INC HL
LD A, [HL]
ADD A, C
LD [$C203], A
RET

CODE_00_1622:
LD HL, $C201
CALL CODE_00_1612
LD A, [HL+]
ADD A, B
LD [$C201], A
RET


CODE_00_162E:
LD A, [$C201]
CP $80
JR C, CODE_00_1638
JP CODE_00_16D4

CODE_00_1638:
LD B, $FE
LD C, $09
CALL CODE_00_1618

LD A, $15
LD [Player_AnimationFrame], A

LD HL, $C305
CALL CODE_00_1612

LD A, [HL]
AND A
JR NZ, CODE_00_1660

LDH A, [JoypadInputPress]
BitA JoypadInput_A
RET Z

CALL CODE_00_1612

XOR A
LD [Player_State], A

LD A, $0C
CALL CODE_00_18FB
RET

CODE_00_1660:
LD BC, $FFFF
CALL CODE_00_10A4
LD HL, $C200
LD A, $01
LD [HL], A

LDH A, [JoypadInputHolding]
BitA JoypadInput_Down
JR Z, CODE_00_1676

;pogo out?
LD A, $81
LD [HL], A
RET

CODE_00_1676:
LD A, [$C203]
LD B, A
LD A, [$C201]
ADD A, $04
LD C, A
CALL CODE_00_07E4
AND A
RET Z

LD A, $01
LD [$CA00], A
RET

CODE_00_168B:
LDH A, [JoypadInputHolding]
AND $FF^JoypadInput_Down                                    ;check if holding anything but d-pad down
JR Z, CODE_00_169F
BitA JoypadInput_A
JR Z, CODE_00_1699

LD HL, $C201
DEC [HL]

CODE_00_1699:
XOR A
LD [Player_State], A
JR CODE_00_16BB

CODE_00_169F:
LD B, $E9
CALL CODE_00_1622
LD HL, $C305
CALL CODE_00_1612
LD A, [HL]
AND A
JR Z, CODE_00_16BB
LD A, [$DF4F]
AND $01
CALL NZ, CODE_00_1601
LD A, $00
LD [Player_AnimationFrame], A

CODE_00_16BB:
LD A, $01
LD [$DF65], A
JP CODE_00_12C3

CODE_00_16C3:
LD A, $01
LD [$C200], A
LD A, [FrameCounter]
AND $04
RET Z

LD A, $81
LD [$C200], A
RET

CODE_00_16D4:
LD A, [Player_State]
CP $08
JR Z, CODE_00_1702

LD A, $0F
LD [Player_AnimationFrame], A

CALL CODE_00_1240
XOR A
LD [$DF4F], A
LD HL, $DF6C
LD [HL], A
LD A, [$CA01]
AND A
JR NZ, CODE_00_16F4
LD A, $FB
LD [HL], A

CODE_00_16F4:
LD B, Music_Death                                           ;
LD A, [PlayerLives]                                         ;check if normal death or game over death (ran out of lives)
AND A                                                       ;
JR NZ, CODE_00_16FE                                         ;

LD B, Music_GameOver                                        ;

CODE_00_16FE:
LD A, B                                                     ;play either sound
CALL QueueSoundPrep_00_072B                                 ;

CODE_00_1702:
LD A, $08
LD [Player_State], A

LD A, [$DF4F]
AND $03
JR NZ, CODE_00_1712

LD HL, $DF6C
INC [HL]

CODE_00_1712:
LD HL, $C201
LD A, [$DF6C]
ADD A, [HL]
LD [HL], A
AND $F0
CP $B0
RET NZ

LD HL, $C627
SET 0, [HL]
RET


CODE_00_1725:
XOR A
LD B, A
CALL CODE_00_18F6

LD A, [TileDetectionArray+254]
AND A
JR Z, CODE_00_173C

LD A, $14
LD [Player_AnimationFrame], A

LDH A, [JoypadInputPress]
BitA JoypadInput_A
RET Z

LD B, $01

CODE_00_173C:
LD A, B
LD [Player_State], A

CALL CODE_00_1417
LD [Player_PogoFlag], A
RET


CODE_00_1747:
LD A, [$DF5D]
AND A
JR Z, CODE_00_1756
LD BC, $DF5D
LD HL, DATA_00_19A8
CALL CODE_00_1979

CODE_00_1756:
LDH A, [JoypadInputHolding]
BitA JoypadInput_Down
JR NZ, CODE_00_1760

XOR A
LD [Player_State], A

CODE_00_1760:
JP CODE_00_12DE

CODE_00_1763:
LD A, $14
LD [Player_AnimationFrame], A
LD A, [$DF66]
AND A
RET NZ

LD A, [$C208]
AND A
JR NZ, CODE_00_1778
CALL CODE_00_1265
JR CODE_00_177B

CODE_00_1778:
CALL CODE_00_1271

CODE_00_177B:
LD A, $04
LD [$DF57], A
JP CODE_00_1820

CODE_00_1783:
LD A, [$DF54]
AND A
JR NZ, CODE_00_178E
XOR A
LD [Player_State], A
RET


CODE_00_178E:
CP $68
JP C, CODE_00_12C3
LD A, $0F
LD [Player_AnimationFrame], A
LD A, [$C208]
AND A
JR Z, CODE_00_17A3
CALL CODE_00_1265
JR CODE_00_17A6

CODE_00_17A3:
CALL CODE_00_1271

CODE_00_17A6:
LD A, $01
LD [$DF57], A
JP CODE_00_1820

CODE_00_17AE:
LD A, $08
LD [$DF57], A
LD A, $0C
LD [Player_AnimationFrame], A
LD A, [Player_PogoFlag]
AND A
JR Z, CODE_00_17C3
LD A, $02
LD [Player_AnimationFrame], A

CODE_00_17C3:
LD A, [$DF5E]
AND A
JR Z, CODE_00_17CE
LD A, $03
LD [Player_AnimationFrame], A

CODE_00_17CE:
LD A, [$DF5E]
AND A
JR NZ, CODE_00_17E1

LDH A, [JoypadInputHolding]
BitA JoypadInput_B
JR Z, CODE_00_17E1

LD A, $01
LD [Player_PogoFlag], A
JR CODE_00_17E5

CODE_00_17E1:
XOR A
LD [Player_PogoFlag], A

CODE_00_17E5:
LDH A, [JoypadInputHolding]
BitA JoypadInput_A
JR NZ, CODE_00_1816

JR CODE_00_180E

CODE_00_17ED:
LD A, $10
LD [$DF57], A
LD A, $02
LD [Player_AnimationFrame], A
LD A, [$DF56]
CP $0F
JR NC, CODE_00_1803
LD A, $01
LD [Player_AnimationFrame], A

CODE_00_1803:
LDH A, [JoypadInputHolding]
BitA JoypadInput_B
JR NZ, CODE_00_1816

LD A, $00
LD [Player_PogoFlag], A

CODE_00_180E:
LD A, $02
LD [$DF59], A
JP CODE_00_1840

CODE_00_1816:
LD A, [$DF59]
AND A
JR NZ, CODE_00_1820
XOR A
LD [$DF55], A

CODE_00_1820:
LD A, [$DF59]
CP $02
JR Z, CODE_00_1840
LD A, $01
LD [$DF59], A
LD HL, $DF57
LD A, [$DF56]
CP [HL]
JR NC, CODE_00_1840
LD A, $03
LD [$DF58], A
LD HL, $DF56
INC [HL]
JR CODE_00_1851

CODE_00_1840:
LD A, [$DF58]
AND A
JR Z, CODE_00_1897
LD A, [$DF55]
AND $03
JR NZ, CODE_00_1851
LD HL, $DF58
DEC [HL]

CODE_00_1851:
LD A, [$DF58]
CALL CODE_00_18FB
LD A, [$C201]
CP $04
JR C, CODE_00_1897
LD A, [$CA03]
AND A
JR NZ, CODE_00_188B
LDH A, [JoypadInputHolding]
BitA JoypadInput_Right
JR Z, CODE_00_1871
CALL CODE_00_1265
XOR A
LD [$C208], A

CODE_00_1871:
LDH A, [JoypadInputHolding]
BitA JoypadInput_Left
JR Z, CODE_00_187F
CALL CODE_00_1271
LD A, $20
LD [$C208], A

CODE_00_187F:
LD HL, $DF55
INC [HL]
LD A, [$DF5E]
AND A
JP NZ, CODE_00_148D
RET


CODE_00_188B:
LD A, $03
LD [$DF56], A
LD HL, $C201
LD A, [HL]
ADD A, $02
LD [HL], A

CODE_00_1897:
XOR A
LD [Player_State], A
RET


CODE_00_189C:
LD A, [TileDetectionArray+253]
AND A
JR NZ, CODE_00_18A8
LD A, [$CA03]
AND A
JR Z, CODE_00_18E5

CODE_00_18A8:
LD A, [$C8F8]
BIT 1, A
JR Z, CODE_00_18B3
CALL CODE_00_1967
RET

CODE_00_18B3:
LDH A, [JoypadInputHolding]
BitA JoypadInput_Down
JR Z, CODE_00_18C7
CALL CODE_00_1967
LD C, $01
CALL CODE_00_111F
LD A, [TileDetectionArray+253]
AND A
JR Z, CODE_00_18E5

CODE_00_18C7:
LDH A, [JoypadInputHolding]
BitA JoypadInput_Up                                         ;check if holding up
JR Z, CODE_00_18DB

CALL CODE_00_1967

LD A, [TileDetectionArray+253]
AND A
JR Z, CODE_00_18DB
LD C, $FF
CALL CODE_00_10EE

CODE_00_18DB:
LDH A, [JoypadInputPress]
CP JoypadInput_A                                            ;check for A and NOTHING ELSE
RET NZ

LD A, $10
LD [$DF62], A

CODE_00_18E5:
XOR A
LD [Player_State], A

LD [Player_PogoFlag], A
LD [$DF52], A

LD A, [$DF61]
LD [$C203], A
RET



CODE_00_18F6:
LD C, A
CALL CODE_00_111F
RET



CODE_00_18FB:
LD B, A
LD A, $00
SUB B
CP $00
RET Z

LD C, A
CALL CODE_00_10EE
RET



CODE_00_1907:
LD A, [$C631]
AND $1F
RET Z

LD BC, $FFFF
BIT 4, A
JR Z, CODE_00_1917
LD BC, $0001

CODE_00_1917:
LD E, $0F
CALL CODE_00_1943
JR CODE_00_1907


CODE_00_191E:
LD A, [$C203]
CP $44
RET Z

LD D, $03
LD BC, $FFFF
JR C, CODE_00_192F
LD BC, $0001
INC D

CODE_00_192F:
CALL CODE_00_0D5C
RET NC

LD E, $11
CALL CODE_00_1943
LD HL, $C603
LD BC, $0010
CALL CODE_00_10CC
JR CODE_00_191E


CODE_00_1943:
CALL CODE_00_10A4
XOR A
LD D, A

CODE_00_1948:
DEC E
JP Z, CODE_00_0DC6
LD A, D
ADD A, $10
LD D, A
LD H, $C2
LD L, A
LD A, [HL]
AND A
JR Z, CODE_00_1948
LD HL, $C203
LD BC, $0100
LD A, D
OR L
LD L, A
PUSH DE
CALL CODE_00_10CC
POP DE
JR CODE_00_1948

CODE_00_1967:
LD A, [FrameCounter]                                        ;will produce a sound every 8th frame
AND $07                                                     ;
JR NZ, CODE_00_1973                                         ;

LD A, SFX_Climb                                             ;making climbing noise
CALL QueueSoundPrep_00_072B

CODE_00_1973:
LD BC, $DF60
LD HL, DATA_00_19A3

CODE_00_1979:
PUSH HL
LD H, B
LD L, C
LD A, [$DF4F]
AND $03
JR NZ, CODE_00_1984
INC [HL]

CODE_00_1984:
LD D, $00
LD E, [HL]
POP HL
ADD HL, DE
LD A, [HL]
CP $FF
JR Z, CODE_00_1992
LD [Player_AnimationFrame], A
RET

CODE_00_1992:
LD H, B
LD L, C
XOR A
LD [HL], A
LD [$DF5B], A
RET

DATA_00_199A:
db $09,$09,$0A,$0A,$0B,$0B,$0A,$0A
db $FF

DATA_00_19A3:
db $12,$12,$13,$13,$FF

DATA_00_19A8:
db $0D                                                      ;first byte - unused
db $0D,$0D

DATA_00_19AB:
db $0E,$0E,$0E,$FF

DATA_00_19AF:
db $0B                                                      ;first byte - unused
db $0B,$0B,$0A,$0A

DATA_00_19B4:
db $03,$03,$03,$04
db $04,$FF

DATA_00_19BA:
db $05                                                      ;first byte - unused
db $05,$05,$06,$06,$FF

DATA_00_19C0:
db $07                                                      ;first byte - unused
db $07,$07,$08,$08,$FF

DATA_00_19C6:
db $10                                                      ;first byte - unused


db $10,$10,$11,$11,$10,$10,$11,$11
db $FF

DATA_00_19D0:
db $00,$33,$87,$D3,$10,$33,$87
db $D3,$11,$33,$87,$D3,$07,$33,$87
db $D3,$08,$33,$87,$D3,$09,$33,$87
db $D3,$0A,$33,$87,$D3,$00,$34,$27
db $D3,$0B,$33,$87,$D3,$01,$33,$87
db $D3,$02,$33,$87,$D3,$03,$33,$87
db $D3,$04,$33,$87,$D3,$05,$33,$87
db $D3,$06,$33,$87,$D3,$02,$43,$3F
db $D3,$0C,$33,$87,$D3,$0D,$33,$87
db $D3,$0E,$33,$87,$D3,$0F,$33,$87
db $D3,$12,$33,$87,$D3,$00,$22,$1F
db $D3


CODE_00_1A28:
LD A, [$C8F8]
BIT 1, A
RET NZ

LD HL, $DF72
LD A, [$C1A2]
CP [HL]
JR NZ, CODE_00_1A4F
INC HL
DEC [HL]
JR NZ, CODE_00_1A40
XOR A
LD [$DF72], A
RET


CODE_00_1A40:
LD A, $02
LD [$C600], A
LD A, [HL]
AND $02
JR Z, CODE_00_1A4F
LD A, $82
LD [$C600], A

CODE_00_1A4F:
LD HL, $C617
LD A, [HL]
AND A
JR Z, CODE_00_1A5E
DEC [HL]
CALL CODE_00_32BB
CALL CODE_00_3414
RET


CODE_00_1A5E:
CALL CODE_00_32BB
CALL CODE_00_3414

CALL CODE_00_329E                                           ;get the first byte from a pointer (pointers at POINTERS_00_31C1)
LD C, A
AND $3F                                                     ;bits 0-5...
LD B, A
LD A, C
AND $C0                                                     ;bits 6 and 7...
JR Z, CODE_00_1A88
CP $40                                                      ;check if bit 6 specifically
JR NZ, CODE_00_1A79
LD A, B

CODE_00_1A75:
LD [$C617], A

RETURN_00_1A78:
RET

CODE_00_1A79:
CP $C0
JR NZ, CODE_00_1A84
CALL CODE_00_329E
LD C, A
JP CODE_00_21FD

CODE_00_1A84:
CP $80
JR Z, CODE_00_1AFE

CODE_00_1A88:
LD A, B
ExecutePointers

dw CODE_00_36D8
dw RETURN_00_1A78                                            ;unused pointer (do nothing)
dw CODE_00_203A
dw CODE_00_204A
dw CODE_00_1FE7
dw CODE_00_2007
dw CODE_00_1FCF
dw CODE_00_2115
dw CODE_00_2158
dw CODE_00_213C
dw CODE_00_20BF
dw CODE_00_20A6
dw CODE_00_208D
dw CODE_00_2053
dw CODE_00_2198
dw RETURN_00_1A78
dw CODE_00_21D8
dw CODE_00_21E9
dw CODE_00_21A9
dw CODE_00_21AD
dw CODE_00_21BC
dw CODE_00_21C0
dw CODE_00_251B
dw CODE_00_252B
dw CODE_00_252F
dw CODE_00_1F57
dw CODE_00_1F2F
dw CODE_00_1E34
dw CODE_00_1F4E
dw CODE_00_1EE7
dw CODE_00_1F09
dw CODE_00_1E1C
dw CODE_00_1EF9
dw CODE_00_1F28
dw CODE_00_1E9D
dw CODE_00_1E8F
dw CODE_00_1E3E
dw CODE_00_36F1
dw CODE_00_1FDE
dw CODE_00_1DFA
dw CODE_00_1DB2
dw CODE_00_1D4F
dw CODE_00_1D3D
dw CODE_00_1D46
dw CODE_00_1D0A
dw CODE_00_1C74
dw CODE_00_1C66
dw CODE_00_1C5F
dw CODE_00_2033
dw CODE_00_2043
dw CODE_00_2036
dw CODE_00_2046
dw CODE_00_2027
dw CODE_00_1C4D
dw CODE_00_1C1B
dw CODE_00_21D5
dw CODE_00_1B4B
dw CODE_00_1C14

CODE_00_1AFE:
LD A, B
AND $20
LD [$DF6F], A
LD A, B
AND $1F
ExecutePointersWithDestination CODE_00_2206

dw CODE_00_221F
dw CODE_00_2227
dw CODE_00_223E
dw CODE_00_2263
dw CODE_00_228E
dw CODE_00_249A
dw CODE_00_2450
dw CODE_00_2462
dw CODE_00_2296
dw CODE_00_2254
dw CODE_00_2274
dw CODE_00_22FA
dw CODE_00_230D
dw CODE_00_2362
dw CODE_00_23BC
dw CODE_00_2317
dw CODE_00_23E1
dw CODE_00_2405
dw CODE_00_2420
dw CODE_00_2434
dw CODE_00_243A
dw CODE_00_22E4
dw CODE_00_22EC
dw CODE_00_22C8
dw CODE_00_229D
dw CODE_00_238B
dw CODE_00_23D8
dw CODE_00_22BF
dw CODE_00_22B6
dw CODE_00_22A5
dw CODE_00_23C6
dw CODE_00_2285

CODE_00_1B4B:
CALL CODE_00_329E
CP $0F
JR C, CODE_00_1B5E
CALL CODE_00_2524
CALL CODE_00_1F57
LD BC, DATA_00_30A5
JP CODE_00_21FD

CODE_00_1B5E:
ExecutePointers

dw CODE_00_1B75
dw CODE_00_1B79
dw CODE_00_1B7F
dw CODE_00_1B8E
dw CODE_00_1BBD
dw CODE_00_1BC6
dw CODE_00_1BCD
dw CODE_00_1BD4
dw CODE_00_1BD8
dw CODE_00_1BDE
dw CODE_00_1C06

CODE_00_1B75:
LD A, $80
JR CODE_00_1B7B

CODE_00_1B79:
LD A, $02

CODE_00_1B7B:
LD [$C627], A
RET

CODE_00_1B7F:
LD A, [$C613]
CP $B0
RET C

CP $E8
RET NC

CALL CODE_00_32B0
JP CODE_00_32B0

CODE_00_1B8E:
LD BC, $C600
LD A, $02
LD [BC], A
LD HL, $C634
LD A, [$C633]
CALL CODE_00_3292
LD HL, $DF6D
CP [HL]
JR Z, CODE_00_1BA6
LD A, $82
LD [BC], A

CODE_00_1BA6:
LD BC, $C611
LD A, [BC]
CP $20
JR NC, CODE_00_1BB6
LD A, [HL]
SUB $08
LD [HL], A
LD A, $A0
JR CODE_00_1BBB

CODE_00_1BB6:
LD HL, $C616
LD A, [BC]
ADD A, [HL]

CODE_00_1BBB:
LD [BC], A
RET

CODE_00_1BBD:
CALL CODE_00_24CE
RET Z

LD A, E
LD [$DF78], A
RET

CODE_00_1BC6:
LD HL, $FF47
LD A, [HL]
CPL
LD [HL], A
RET

CODE_00_1BCD:
CALL CODE_00_329E
LD [Player_State], A
RET

CODE_00_1BD4:
CALL CODE_00_191E
RET

CODE_00_1BD8:
CALL CODE_00_201E
JP CODE_00_1A5E

CODE_00_1BDE:
LD A, [MoneyTotal]
CP $10
JP C, CODE_00_36D8

CODE_00_1BE6:
CALL CODE_00_1BFB
CP $07
JR Z, CODE_00_1BE6
SUB $03
LD [$C615], A
CALL CODE_00_1BFB
CPL
INC A
LD [$C616], A
RET

CODE_00_1BFB:
LD HL, $DF4F
DEC [HL]
CALL CODE_00_1C2B
LD A, D
AND $07
RET

CODE_00_1C06:
LD A, [$DF8A]
AND $0F
SUB $02
SLA A
SLA A
JP CODE_00_203D

CODE_00_1C14:
CALL CODE_00_329E
CALL QueueSoundPrep_00_072B
RET

CODE_00_1C1B:
CALL CODE_00_1C2B
LD A, D
SRL A
CP $60
JR NC, CODE_00_1C1B
ADD A, $10
LD [$C613], A
RET

CODE_00_1C2B:
LD HL, $DF79
LD A, [$DF4F]
ADD A, [HL]
LD [HL], A
LD HL, $DF79
INC [HL]
LD B, [HL]
SLA A
LD C, A
LD A, [$DF7A]
LD HL, $DF7B
ADD A, [HL]
ADD A, C
LD [$DF7A], A
LD D, A
ADD A, [HL]
ADD A, B
LD [$DF7B], A
RET


CODE_00_1C4D:
LD HL, $C611
LD A, [HL]
AND $FE
LD [HL], A
LD A, [$C615]
BIT 7, A
RET Z

LD HL, $C613
DEC [HL]
RET

CODE_00_1C5F:
CALL CODE_00_329E
CALL CODE_00_07B6
RET

CODE_00_1C66:
LD A, [$C613]
CP $A0
JP NC, CODE_00_32B0
SUB $04
LD [$C613], A
RET

CODE_00_1C74:
LD BC, $0000
LD A, $08
CALL CODE_00_1CE8
LD A, $04
CALL CODE_00_1CE8
LD A, $02
CALL CODE_00_1CE8
LD A, $01
CALL CODE_00_1CE8
XOR A
CP C
JR NZ, CODE_00_1CA6

LD HL, DATA_00_1CFF
LD A, [$C608]
AND A
JR NZ, CODE_00_1C9B
LD HL, $1CF4

CODE_00_1C9B:
LD A, [$DF74]
LD C, A
ADD HL, BC
LD A, [HL]
AND $0F
LD C, A
JR CODE_00_1CAA

CODE_00_1CA6:
LD A, C
LD [$DF74], A

CODE_00_1CAA:
LD HL, DATA_00_1CF4
LD A, [$C608]
AND A
JR Z, CODE_00_1CB6
LD HL, $1CFF

CODE_00_1CB6:
ADD HL, BC
CALL CODE_00_1CC6
LD [$C615], A
CALL CODE_00_1CCF
LD [$C616], A
JP CODE_00_2115

CODE_00_1CC6:
CALL CODE_00_1CE1
BIT 5, A
JR Z, CODE_00_1CE6
JR CODE_00_1CD6

CODE_00_1CCF:
CALL CODE_00_1CE1
BIT 6, A
JR Z, CODE_00_1CE6

CODE_00_1CD6:
LD A, [HL]
BIT 4, A
JR Z, CODE_00_1CDE
LD A, $02
RET

CODE_00_1CDE:
LD A, $FE
RET

CODE_00_1CE1:
LD A, [HL]
BIT 7, A
RET Z

POP DE

CODE_00_1CE6:
XOR A
RET

CODE_00_1CE8:
PUSH AF
CALL CODE_00_09FE
JR NC, CODE_00_1CF2
POP AF
OR C
LD C, A
RET

CODE_00_1CF2:
POP AF
RET

DATA_00_1CF4:
db $80                                                      ;first byte unused


db $28,$34

;unknown
db $80


db $51,$50,$30

;unknown
db $80


db $42,$20,$40

;unknown

DATA_00_1CFF:
db $80                                                      ;first byte is unused


db $34,$28

;unknown
db $80


db $42,$30,$40

;unknown
db $80


db $51,$50,$20

CODE_00_1D0A:
LD A, [$DF71]
AND A
JR NZ, CODE_00_1D19
LD A, $20
LD [$DF71], A

CODE_00_1D15:
CALL CODE_00_32B0
RET


CODE_00_1D19:
CP $01
JR NZ, CODE_00_1D22
XOR A
LD [$DF71], A
RET

CODE_00_1D22:
LD HL, $DF71
DEC [HL]
LD A, [$C201]
CP $58
JR C, CODE_00_1D15
LD A, [Player_State]
CP $08
JR Z, CODE_00_1D15
XOR A
LD [Player_PogoFlag], A
LD [Player_State], A
JR CODE_00_1D15

CODE_00_1D3D:
CALL CODE_00_329E
LD [$C613], A
JP CODE_00_1A5E

CODE_00_1D46:
CALL CODE_00_329E
LD [$C611], A
JP CODE_00_1A5E

CODE_00_1D4F:
CALL CODE_00_329E
CP $FF
JR Z, CODE_00_1D66
LD B, A
LD A, [$C603]
LDH [$FF8E], A

LD A, [$C601]
LDH [$FF8D], A

LD A, B

CODE_00_1D62:
CALL CODE_00_0C81
RET

CODE_00_1D66:
LD A, [$C613]
CP $B0
JP NC, CODE_00_36D8

LD E, $08                                                   ;block gets destroyed

LD A, [CurrentLand]                                         ;check for himalayas
CP CurrentLand_Himalayas                                    ;
JR NZ, CODE_00_1D79                                         ;

LD E, $10                                                   ;spawn a block of ice

CODE_00_1D79:
LD HL, $C613
LD A, [$C615]
BIT 7, A
JR Z, CODE_00_1D8C

LD A, $FE
LD [$C615], A

LD A, [HL]
SUB E
JR CODE_00_1D94

CODE_00_1D8C:
LD A, $02
LD [$C615], A
LD A, [HL]
ADD A, $20

CODE_00_1D94:
LD [HL], A
LDH [$FF8E], A
LD B, A
LD HL, $C611
LD A, [HL]
ADD A, E
LD [HL], A
LDH [$FF8D], A
LD C, A
CALL CODE_00_07E4
CP $06
JP NC, CODE_00_36D8
CP $03
JP C, CODE_00_36D8
LD A, $9F
JR CODE_00_1D62

CODE_00_1DB2:
CALL CODE_00_329E
BIT 7, A
JR Z, CODE_00_1DBE
LD HL, DATA_00_1DEE
JR CODE_00_1DC5

CODE_00_1DBE:
BIT 6, A
JR Z, CODE_00_1DCD
LD HL, DATA_00_1DF4

CODE_00_1DC5:
LD B, $00
LD A, [CurrentLand]
LD C, A
ADD HL, BC
LD A, [HL]

CODE_00_1DCD:
LD [MessageQueue], A
CP $0C                                                      ;check if the message is... Glomgold's race message
JR NZ, CODE_00_1DD9

LD A, $28
LD [$DF6D], A

CODE_00_1DD9:
CP $03                                                      ;helped huey in transylvania
JR NZ, CODE_00_1DE2

LD HL, $DF81
SET 0, [HL]

CODE_00_1DE2:
LD A, $0F
LD [Player_State], A

LD A, [$C1A2]
LD [$DF7C], A
RET

DATA_00_1DEE:
db $01,$03,$04,$06,$08

;unknown
db $03

DATA_00_1DF4:
db $00                                                      ;unused first byte... sigh
db $02

;unknown
db $05,$00


db $0A

;unknown
db $02

CODE_00_1DFA:
LD HL, $C20B
LD A, [$C60A]
OR L
LD L, A
LD A, [HL]
AND A
JP Z, CODE_00_36D8
LD HL, $C301
LD A, [$C60A]
OR L
LD L, A
LD A, [HL]
SUB $17
SLA A
AND $F0
OR $02
LD [$C609], A
RET

CODE_00_1E1C:
CALL CODE_00_329E
LD [$C61E], A
CALL CODE_00_329E
LD [$C61F], A
CALL CODE_00_329E
LD [$C61D], A
LD HL, $C612
SET 3, [HL]
RET

CODE_00_1E34:
XOR A
LD [$DF66], A
LD A, $80
LD [$DF54], A
RET

CODE_00_1E3E:
LD A, [Player_State]
CP $02
JR NZ, CODE_00_1E5A
CALL CODE_00_1E77
CP $1E
JP NC, CODE_00_1E5A
CALL CODE_00_1E7F
JP NC, CODE_00_1E5A
LD C, $FE
LD B, $2E
JP CODE_00_21FD

CODE_00_1E5A:
LD A, [$DF5E]
CP $02
JR NZ, CODE_00_1E74
CALL CODE_00_1E77
CP $09
JR NC, CODE_00_1E74
CALL CODE_00_1E7F
JR NC, CODE_00_1E74
LD C, $02
LD B, $2F
JP CODE_00_21FD

CODE_00_1E74:
JP CODE_00_32B0

CODE_00_1E77:
LD A, [$C601]
LD HL, $C201
SUB [HL]
RET

CODE_00_1E7F:
LD A, [$C603]
SUB $04
LD HL, $C203
SUB [HL]
JR NC, CODE_00_1E8C
CPL
INC A

CODE_00_1E8C:
CP $16
RET

CODE_00_1E8F:
LDH A, [$FF96]
AND A
JP NZ, CODE_00_1EDE
CALL CODE_00_32B0
LD A, $02
JP CODE_00_1A75

CODE_00_1E9D:
LD A, [$CA09]
AND A
JP Z, CODE_00_32B0
LD A, [$C603]
LD B, A
LD A, [$CA0B]
CP B
JP NZ, CODE_00_32B0
LD A, [$C601]
LD B, A
LD A, [$CA0A]
CP B
JP NZ, CODE_00_32B0
LD A, [$CA09]
BIT 2, A
JR NZ, CODE_00_1ED0
BIT 0, A
JR Z, CODE_00_1ECB
LD C, $7E
LD B, $31
JR CODE_00_1ED4

CODE_00_1ECB:
BIT 1, A
JP Z, CODE_00_32B0

CODE_00_1ED0:
LD C, $71
LD B, $31

CODE_00_1ED4:
XOR A
LD [$CA09], A
CALL CODE_00_1EDE
JP CODE_00_21DB


CODE_00_1EDE:
LD H, $C5
LD A, [$C60C]
LD L, A
LD [HL], $00
RET

CODE_00_1EE7:
LD A, $04
LD [$C610], A
CALL CODE_00_35E5
LD A, $C0
LD [$C612], A
LD E, $10
JP CODE_00_1EFD

CODE_00_1EF9:
CALL CODE_00_329E
LD E, A

CODE_00_1EFD:
LD A, [$C603]
LD B, A
LD A, [$C601]
LD C, A
CALL CODE_00_07D6
RET

CODE_00_1F09:
SetBankAndBackup 2
LD B, $0C
LD C, $02
CALL CODE_00_38E7
CALL CODE_00_329E
LD B, A
LD C, $03
CALL CODE_00_38E7
SetBankAndBackup 1
RET

CODE_00_1F28:
CALL CODE_00_329E
LD [$C602], A
RET

CODE_00_1F2F:
CALL CODE_00_329E
BIT 4, A
JR Z, CODE_00_1F4A
PUSH AF
CALL CODE_00_327B
LD HL, $C61D
LD [HL+], A
PUSH HL
LD HL, $C60E
LD A, [HL+]
LD E, A
LD D, [HL]
POP HL
LD A, E
LD [HL+], A
LD [HL], D
POP AF

CODE_00_1F4A:
LD [$C612], A
RET

CODE_00_1F4E:
CALL CODE_00_329E
LD [$C614], A
JP CODE_00_1A5E

CODE_00_1F57:
CALL CODE_00_329E
LD B, A
CALL CODE_00_329E
LD C, A

CODE_00_1F5F:
LD A, [$C613]
LD D, A
LD A, [$C611]
LD E, A
LD A, [$C615]
LDH [$FF94], A
LD A, [$C1A2]
PUSH AF
LD A, $F0
LD [$C1A2], A

CODE_00_1F75:
LD A, [$C1A2]
SUB $10
JR Z, CODE_00_1FCA
LD [$C1A2], A
LD HL, $C200
CALL CODE_00_3298
LD A, [HL]
AND A
JR NZ, CODE_00_1F75
LD HL, $C200
CALL CODE_00_3298
LD A, $02
LD [HL], A
LD HL, $C20E
CALL CODE_00_3298
LD A, B
LD [HL+], A
LD [HL], C
LD HL, $C303
CALL CODE_00_3298
LD [HL], D
LD HL, $C301
CALL CODE_00_3298
LD [HL], E
LD HL, $C305
CALL CODE_00_3298
LDH A, [$FF94]
LD [HL], A
LD HL, $C20A
CALL CODE_00_3298
POP AF
LD [HL], A
PUSH AF
LD HL, $C302
CALL CODE_00_3298
LD A, $80
LD [HL], A
LD A, [$C1A2]
LD [$C60B], A

CODE_00_1FCA:
POP AF
LD [$C1A2], A
RET

CODE_00_1FCF:
LD A, [$C208]
AND $20
RET Z

LD A, [$C615]
CPL
INC A
LD [$C615], A
RET

CODE_00_1FDE:
LD A, [$C615]
BIT 7, A
JR Z, CODE_00_2015
JR CODE_00_200E


CODE_00_1FE7:
LD A, [$C612]
BIT 4, A
JP NZ, CODE_00_2000
LD A, [$C603]
CP $D1
JR C, CODE_00_1FF8
LD A, $01

CODE_00_1FF8:
LD HL, $C203
CP [HL]
JR NC, CODE_00_2015
JR CODE_00_2007

CODE_00_2000:
LD A, [$C208]
AND $20
JR Z, CODE_00_2015

CODE_00_2007:
CALL CODE_00_201E
BIT 7, A
JR Z, CODE_00_2015

CODE_00_200E:
LD A, [$C608]
AND $DF
JR CODE_00_201A

CODE_00_2015:
LD A, [$C608]
OR $20

CODE_00_201A:
LD [$C608], A
RET

CODE_00_201E:
LD A, [$C615]
CPL
INC A
LD [$C615], A
RET

CODE_00_2027:
LD A, $01
LD [$C615], A
CALL CODE_00_1FE7
CALL CODE_00_2007
RET

CODE_00_2033:
XOR A
JR CODE_00_203D

CODE_00_2036:
LD A, $01
JR CODE_00_203D

CODE_00_203A:
CALL CODE_00_329E

CODE_00_203D:
LD [$C615], A
JP CODE_00_1A5E

CODE_00_2043:
XOR A
JR CODE_00_204D

CODE_00_2046:
LD A, $01
JR CODE_00_204D

CODE_00_204A:
CALL CODE_00_329E

CODE_00_204D:
LD [$C616], A
JP CODE_00_1A5E

CODE_00_2053:
LD HL, $C61C
LD A, [HL]
CP $1E
JR C, CODE_00_205D
XOR A
LD [HL], A

CODE_00_205D:
INC [HL]
LD B, $00
LD C, A
LD HL, DATA_00_206F
ADD HL, BC
LD A, [HL]
CPL
INC A
CALL CODE_00_212E
CALL CODE_00_2118
RET

DATA_00_206F:
db $FD,$FE,$FF,$01,$02,$03,$04,$04
db $03,$02,$02,$01,$FF,$FE,$FE,$FD
db $FC,$FC

DATA_00_2081:
db $FD,$FE,$FF,$01,$02,$03,$03,$02
db $01,$FF,$FE,$FD

CODE_00_208D:
LD HL, $C61C
LD A, [HL]
CP $0C
JR C, CODE_00_2097
XOR A
LD [HL], A

CODE_00_2097:
INC [HL]
LD B, $00
LD C, A
LD HL, DATA_00_2081
ADD HL, BC
LD A, [HL]
LD [$C616], A
JP CODE_00_2158

CODE_00_20A6:
LD HL, $C61C
LD A, [HL]
CP $0C
JR C, CODE_00_20B0
XOR A
LD [HL], A

CODE_00_20B0:
INC [HL]
LD B, $00
LD C, A
LD HL, DATA_00_2081
ADD HL, BC
LD A, [HL]
LD [$C616], A
JP CODE_00_2115

CODE_00_20BF:
LD HL, $C61C
LD A, [HL]
CP $30
JR C, CODE_00_20C9
XOR A
LD [HL], A

CODE_00_20C9:
INC [HL]
LD B, $00
LD C, A
LD HL, DATA_00_20E5
ADD HL, BC
LD A, [$C615]
BIT 7, A
JR Z, CODE_00_20DD
LD A, [HL]
CPL
INC A
JR CODE_00_20DE

CODE_00_20DD:
LD A, [HL]

CODE_00_20DE:
CALL CODE_00_212E
CALL CODE_00_2118
RET

DATA_00_20E5:
db $FD,$FD,$FF,$00,$00,$00,$00,$01
db $01,$01,$02,$02,$03,$03,$03,$03
db $03,$02,$02,$02,$01,$01,$01,$00
db $00,$FF,$FF,$FF,$FE,$FE,$FE,$FD
db $FD,$FD,$FD,$FD,$FE,$FE,$FF,$FF
db $FF,$00,$00,$00,$00,$01,$03,$03


CODE_00_2115:
CALL CODE_00_212B

CODE_00_2118:
LD A, [$C615]
LD B, A
LD A, [$C613]
ADD A, B
LD [$C613], A
AND $F8
CP $C8
JP Z, CODE_00_36D8
RET

CODE_00_212B:
LD A, [$C616]

CODE_00_212E:
LD B, A
LD A, [$C611]
ADD A, B
LD [$C611], A
CP $B1
JP NC, CODE_00_36D8
RET

CODE_00_213C:
CALL CODE_00_329E
LD [$DF70], A
BIT 0, A
CALL NZ, CODE_00_215B
LD A, [$DF70]
BIT 1, A
CALL NZ, CODE_00_2171
LD A, [$DF70]
BIT 3, A
CALL NZ, CODE_00_212B
RET

CODE_00_2158:
CALL CODE_00_2171

CODE_00_215B:
LD A, [$C615]
AND A
RET Z

BIT 7, A
JR NZ, CODE_00_2168
LD A, $08
JR CODE_00_216A

CODE_00_2168:
LD A, $04

CODE_00_216A:
CALL CODE_00_09FE
CALL NC, CODE_00_2118
RET

CODE_00_2171:
LD A, [$C616]
CP $00
RET Z

BIT 7, A
JR Z, CODE_00_2184
LD A, $01
CALL CODE_00_09FE
JR NC, CODE_00_212B
JR CODE_00_2193

CODE_00_2184:
LD A, $02
CALL CODE_00_09FE
JR NC, CODE_00_212B
LD A, [$C611]
AND $F8
LD [$C611], A

CODE_00_2193:
XOR A
LD [$C616], A
RET

CODE_00_2198:
LD A, [$C616]
BIT 7, A
JR NZ, CODE_00_21A2
CP $08
RET NC

CODE_00_21A2:
LD HL, $C616
INC [HL]
JP CODE_00_1A5E

CODE_00_21A9:
LD C, $00
JR CODE_00_21AF

CODE_00_21AD:
LD C, $01

CODE_00_21AF:
LD B, $00
CALL CODE_00_329E
LD HL, $C61A
ADD HL, BC
LD [HL], A
JP CODE_00_1A5E

CODE_00_21BC:
LD C, $00
JR CODE_00_21C2

CODE_00_21C0:
LD C, $01

CODE_00_21C2:
LD B, $00
LD HL, $C61A
ADD HL, BC
DEC [HL]
JP NZ, CODE_00_21FA
CALL CODE_00_329E
CALL CODE_00_329E
JP CODE_00_1A5E

CODE_00_21D5:
CALL CODE_00_2521

CODE_00_21D8:
CALL CODE_00_21F1

CODE_00_21DB:
LD HL, $C60E
LD A, [HL+]
LD E, A
LD D, [HL]
LD HL, $C618
LD A, E
LD [HL+], A
LD [HL], D
JR CODE_00_21FD

CODE_00_21E9:
LD HL, $C618
LD A, [HL+]
LD C, A
LD B, [HL]
JR CODE_00_21FD

;get a subpointer
CODE_00_21F1:
CALL CODE_00_329E
LD C, A
CALL CODE_00_329E
LD B, A
RET

CODE_00_21FA:
CALL CODE_00_21F1

CODE_00_21FD:
LD HL, $C60E
LD A, C
LD [HL+], A
LD [HL], B
JP CODE_00_1A5E

CODE_00_2206:
LD A, [$DF6F]
AND A
JR NZ, CODE_00_221C

CODE_00_220C:
CALL CODE_00_329E
CALL CODE_00_329E
JP CODE_00_1A5E

CODE_00_2215:
POP HL
LD A, [$DF6F]
AND A
JR NZ, CODE_00_220C

CODE_00_221C:
JP CODE_00_21FA

CODE_00_221F:
LD A, $02
CALL CODE_00_09FE
RET NC

JR CODE_00_2215

CODE_00_2227:
LD A, [$C615]
BIT 7, A
JR NZ, CODE_00_2236
LD A, $08
CALL CODE_00_09FE
JR C, CODE_00_2215
RET


CODE_00_2236:
LD A, $04
CALL CODE_00_09FE
JR C, CODE_00_2215
RET


CODE_00_223E:
LD A, [$C203]
LD [$DF7D], A
LD A, $03
LD [$DF7F], A
CALL CODE_00_357E
JR NC, CODE_00_2215
CALL CODE_00_3590
JR NC, CODE_00_2215
RET


CODE_00_2254:
LD A, [$C601]
ADD A, $18
LD B, A
LD A, [$C201]
SUB B
CP $04
JR C, CODE_00_2215
RET


CODE_00_2263:
LD A, [$C203]
LD B, A
LD A, [$C603]
SUB B
JR NC, CODE_00_226F
CPL
INC A

CODE_00_226F:
CP $30
JR C, CODE_00_2215
RET

CODE_00_2274:
LD A, [$C203]
LD B, A
LD A, [$C603]
SUB B
JR NC, CODE_00_2280
CPL
INC A

CODE_00_2280:
CP $60
JR C, CODE_00_2215
RET

CODE_00_2285:
LD A, [SelectedDifficulty]
CP $02                                                      ;check if difficulty is set to difficult
JP Z, CODE_00_2215
RET

CODE_00_228E:
LD A, [$DF66]
AND A
RET Z

JP CODE_00_2215

CODE_00_2296:
LDH A, [$FF96]
AND A
RET Z

JP CODE_00_2215

CODE_00_229D:
LD A, [LandBeatenFlag_Transylvania]                         ;check if beaten transylvania
AND A
JP NZ, CODE_00_2215
RET

CODE_00_22A5:
LD A, [$C210]
AND $80
RET NZ

LD HL, $C601
LD A, [$C211]
CP [HL]
JP C, CODE_00_2215
RET


CODE_00_22B6:
LD A, [$C608]
BIT 5, A
RET Z

JP CODE_00_2215

CODE_00_22BF:
LD A, [$C601]
CP $A0
JP NC, CODE_00_2215
RET


CODE_00_22C8:
LD HL, $C601
LD A, [$C201]
PUSH AF
LD A, [$C616]
BIT 7, A
JR NZ, CODE_00_22DE
POP AF
ADD A, $18
CP [HL]
JP C, CODE_00_2215
RET


CODE_00_22DE:
POP AF
CP [HL]
JP NC, CODE_00_2215
RET


CODE_00_22E4:
LD A, [$DF76]
AND A
JP NZ, CODE_00_2215
RET


CODE_00_22EC:
LD A, [$C631]
CP $60
RET NZ

LD A, $01
LD [$DF76], A
JP CODE_00_2215

CODE_00_22FA:
LD A, [$C613]
AND $F8
CP $40
RET NZ

LD A, [$C611]
AND $F8
CP $68
RET NZ

JP CODE_00_2215

CODE_00_230D:
LD A, [$C610]
CALL CODE_00_3409
JP NZ, CODE_00_2215
RET


CODE_00_2317:
LD A, [CurrentLand]
AND A
JR NZ, CODE_00_2324

LD A, [$C631]
CP $A0
JR Z, CODE_00_232E

CODE_00_2324:
LDH A, [$FF96]
AND A
RET Z

LD A, [$C62B]
AND A
JR NZ, CODE_00_2355

CODE_00_232E:
LD A, $0D
LD [Player_State], A
LD BC, $0000

CODE_00_2336:
LD A, $10
ADD A, C
AND A
JP Z, CODE_00_2215
LD C, A
LD A, [$C1A2]
CP C
JR Z, CODE_00_2336
LD HL, $C200
ADD HL, BC
LD D, H
LD E, L
LD HL, $C300
ADD HL, BC
PUSH BC
CALL CODE_00_36E7
POP BC
JR CODE_00_2336

CODE_00_2355:
LD A, [CurrentLand]
CP CurrentLand_Transylvania
JR NZ, CODE_00_232E

LD HL, $C627
SET 7, [HL]
RET

CODE_00_2362:
LD A, [$DF5E]
CP $03
RET NZ

LD HL, $C603
LD A, [$C203]
SUB [HL]
JR NC, CODE_00_2373
CPL
INC A

CODE_00_2373:
CP $21
RET NC

LD HL, $C601
LD A, [$C201]
SUB [HL]
CP $21
RET NC


CODE_00_2380:
CALL CODE_00_1EDE
LD A, $04
LD [$DF5E], A
JP CODE_00_2215

CODE_00_238B:
LD A, [$DF5E]
CP $03
RET NZ

LD HL, $C601
LD A, [$C201]
ADD A, $08
CP [HL]
RET NZ

LD HL, $C203
LD A, [$C603]
SUB [HL]
JR NC, CODE_00_23A6
CPL
INC A

CODE_00_23A6:
CP $21
RET NC

LD B, $18
LD A, [CurrentLand]
CP $01                                                      ;check if were in transylvania
JR NZ, CODE_00_23B4
LD B, $30

CODE_00_23B4:
LD HL, $C611
LD A, [HL]
SUB B
LD [HL], A
JR CODE_00_2380

CODE_00_23BC:
CALL CODE_00_1C2B
LD A, D
AND $01
RET Z

JP CODE_00_2215

CODE_00_23C6:
CALL CODE_00_23CF
BIT 0, [HL]
JP NZ, CODE_00_2215
RET

CODE_00_23CF:
LD A, [CurrentLand]

CODE_00_23D2:
LD HL, $DF84
ADD A, L
LD L, A
RET

CODE_00_23D8:
CALL CODE_00_23CF
BIT 7, [HL]
JP NZ, CODE_00_2215
RET

CODE_00_23E1:
LD B, $01
CALL CODE_00_2440

LD B, $08
LD C, $02
CALL CODE_00_2442

CALL CODE_00_240E
BIT 0, [HL]
JP NZ, CODE_00_2215

LD HL, CurrentLand
LD A, CurrentLand_Himalayas
CP [HL]
RET NZ

CALL CODE_00_23D2
BIT 0, [HL]
JP NZ, CODE_00_2215
RET

CODE_00_2405:
LD B, $10
CALL CODE_00_2440
CALL CODE_00_240E
RET

CODE_00_240E:
LD A, [CurrentLand]
AND $03
CP $01                                          ;check if in either transylvania or... transylvania. for the final boss battle.
RET NZ

LD HL, $DF81
BIT 0, [HL]
RET Z

POP AF
JP CODE_00_2215

CODE_00_2420:
LD B, $04
CALL CODE_00_2440

LD B, $02
LD C, CurrentLand_AfricanMines
CALL CODE_00_2442

LD B, $08
LD C, CurrentLand_Transylvania
CALL CODE_00_2442
RET

CODE_00_2434:
LD B, $01
CALL CODE_00_2440
RET

CODE_00_243A:
LD B, $10
CALL CODE_00_2440
RET

CODE_00_2440:
LD C, CurrentLand_Moon

CODE_00_2442:
LD A, [$CA1D]
AND B
RET Z

LD A, [CurrentLand]
CP C
RET NZ

POP AF
JP CODE_00_2215

CODE_00_2450:
LDH A, [$FF96]
AND A
RET Z

LD A, [$C1A2]
LD [$DF67], A
LD A, $0B
LD [Player_State], A
JP CODE_00_2215

CODE_00_2462:
LDH A, [JoypadInputHolding]
BitA JoypadInput_Up
RET Z

LD A, [$C203]
LD B, A
LD A, [$C603]
ADD A, $10
LD C, A
SUB B
CP $18
JR C, CODE_00_247B
LD A, B
SUB C
CP $08
RET NC


CODE_00_247B:
LD A, [$C201]
LD B, A
LD A, [$C601]
ADD A, $28
SUB B
CP $18
JR C, CODE_00_248E
LD A, B
SUB C
CP $18
RET NC

CODE_00_248E:
LD A, [$C1A2]
LD [$DF67], A
LD A, $0A
LD [Player_State], A
RET

CODE_00_249A:
CALL CODE_00_24CE
RET Z

LD HL, $C302
ADD HL, DE
LD A, [HL]
BIT 6, A
JR Z, CODE_00_24C7
LD A, $04
LD [$CA09], A
LD HL, $C303
ADD HL, DE
LD A, [HL]
LD [$CA0B], A
ADD A, $08
LD B, A
LD HL, $C301
ADD HL, DE
LD A, [HL]
LD C, A
LD [$CA0A], A
LD E, $00
CALL CODE_00_07D6
JR CODE_00_24CB

CODE_00_24C7:
LD A, E
LD [$DF78], A

CODE_00_24CB:
JP CODE_00_2215

CODE_00_24CE:
LD DE, $0010

CODE_00_24D1:
LD HL, $C1A2
LD A, E
CP [HL]
JR Z, CODE_00_2506
LD HL, $C200
ADD HL, DE
LD A, [HL]
AND A
JR Z, CODE_00_2506
LD HL, $C303
ADD HL, DE
LD A, [HL]
LD B, A
LD A, [$C613]
CALL CODE_00_2512
JR C, CODE_00_24F3
CALL CODE_00_2516
JR NC, CODE_00_2506

CODE_00_24F3:
LD HL, $C301
ADD HL, DE
LD A, [HL]
LD B, A
LD A, [$C611]
CALL CODE_00_2512
JR C, CODE_00_250F
CALL CODE_00_2516
JR C, CODE_00_250F

CODE_00_2506:
LD A, $10
ADD A, E
LD E, A
AND A
JR NZ, CODE_00_24D1
XOR A
RET

CODE_00_250F:
OR $01
RET

CODE_00_2512:
LD C, A
SUB B
JR CODE_00_2518


CODE_00_2516:
LD A, B
SUB C

CODE_00_2518:
CP $14
RET

CODE_00_251B:
CALL CODE_00_2521
JP CODE_00_1A5E

CODE_00_2521:
CALL CODE_00_329E

CODE_00_2524:
LD [$C610], A
CALL CODE_00_35E5
RET

CODE_00_252B:
LD A, $02
JR CODE_00_2531

CODE_00_252F:
LD A, $82

CODE_00_2531:
LD [$C600], A
RET

;i believe these are entity data.
;format currently unknown
DATA_00_2535:
db $34,$37,$3E,$40,$25,$37,$3F,$40
db $25,$E5,$36,$12,$04,$08,$0E,$0F
db $38,$02,$81,$4E,$25,$14,$42,$25
db $11,$05,$11

DATA_00_2550:
db $1A,$10,$21,$01,$37
db $3E,$63,$31,$34,$37,$3F,$63,$25
db $37,$3E,$63,$25,$E5,$59,$12,$04
db $08,$0F,$81,$71,$25,$0E,$08,$0F
db $14,$65,$25,$11,$A0,$6A,$25,$03
db $FA,$E5,$63

DATA_00_2578:
db $1A,$06,$10,$46,$31,$60

DATA_00_257E:
db $16,$40,$1A,$02,$30,$08,$08
db $0E,$0F,$A0,$82,$25,$31,$32,$05
db $37,$41,$9F,$25,$37,$42,$9F,$25
db $37,$43,$9F,$25,$37,$40,$9F,$25
db $E5,$8D,$39,$13,$12,$03,$08,$38
db $02,$A0,$82,$25,$08,$81,$B2,$25
db $08,$14,$A3,$25,$11,$05,$11

DATA_00_25B4:
db $1A
db $10,$21,$02,$1C,$34,$81,$3B,$31
db $31,$34,$17,$13,$02,$37,$44,$63
db $25,$37,$45,$63,$25,$37,$46,$63
db $25,$37,$45,$63,$25,$15,$C2,$25
db $81,$C0,$25,$16,$6A,$58,$19,$E3
db $25,$16,$6B,$60,$E5,$C0,$1A,$02
db $39,$0C,$16,$36,$26,$08,$08,$08
db $08,$A1,$EA,$25,$00

DATA_00_25F2:
db $1A,$22,$21
db $02,$1C,$40,$34,$37,$2B,$63,$31
db $16,$2B,$48,$A2,$FD,$25,$16,$31
db $4C,$16,$32,$48,$84,$0E,$26,$E5
db $FD,$39,$0A,$16,$32,$05,$7F,$39
db $0B,$38,$07,$1B,$16,$47,$4C,$1A
db $22,$E5,$FD

DATA_00_2620:
db $1C,$50,$21,$02,$38
db $02,$34,$02,$04,$9C,$2E,$26,$02
db $08,$07,$37,$5B,$63,$31,$BC,$39
db $26,$02,$F8,$07,$12,$06,$16,$5B
db $48,$16,$5C,$48,$14,$3B,$26,$BC
db $4A,$26,$02,$08,$07,$16,$34,$39
db $14,$12,$02,$16,$34,$4C,$16,$35
db $4C,$14,$50,$26,$E6,$33,$16,$8C
db $44,$27,$E6,$5D

DATA_00_2661:
db $1C,$30,$21,$03
db $19,$5B,$26,$16,$6C,$50,$83,$76
db $26,$16,$6D,$50,$83,$76,$26,$E6
db $68,$03,$02,$10,$8D,$26,$03,$FE
db $10,$8D,$26,$12,$04,$16,$6C,$50
db $16,$6D,$50,$14,$82,$26,$E6,$68
db $12,$02,$16,$6C,$07,$07,$0F,$07
db $07,$0F,$07,$07,$0F,$16,$6D,$07
db $07,$0F,$07,$07,$0F,$07,$07,$0F
db $14,$8F,$26,$11

DATA_00_26A9:
db $1A,$10,$21,$01
db $1C,$22,$34,$17,$16,$1E,$0B,$0F
db $07,$39,$15,$16,$1A,$0B,$0F,$07
db $39,$15,$E6,$B1

DATA_00_26C1:
db $21,$01,$16,$22
db $32,$26,$12,$02,$37,$22,$D8,$26
db $37,$23,$D8,$26,$14,$C9,$26,$43
db $05,$E6,$C7,$13,$04,$07,$0F,$15
db $DA,$26,$11

DATA_00_26E0:
db $21,$03,$37,$24,$46
db $31,$03,$02,$37,$37,$FC,$26,$37
db $38,$FC,$26,$32,$04,$37,$37,$07
db $27,$37,$38,$07,$27,$E6,$F2,$13
db $04,$08,$0F,$0F,$08,$0F,$15,$FE
db $26,$11,$13,$04,$0C,$0F,$08,$0F
db $82,$15,$27,$15,$09,$27,$31,$11
db $16,$24,$30,$0E,$0F,$08,$0F,$A0
db $15,$27,$13,$04,$16,$39,$48,$16
db $3A,$48,$15,$21,$27,$03,$FE,$37
db $37,$FC,$26,$37,$38,$FC,$26,$31
db $E6,$F0

DATA_00_2737:
db $1A,$00,$18,$2B,$89,$03
db $FA,$10,$41,$31,$48,$17,$1F,$7B
db $27,$01,$37,$5D,$67,$27,$19,$86
db $27,$10,$67,$27,$10,$67,$27,$48
db $37,$48,$67,$27,$10,$67,$27

;unknown
db $10,$67,$27,$19,$86,$27,$10,$67
db $27,$E7,$62

db $12,$02,$07,$0F,$07,$0F,$9B,$80
db $27,$07,$0F,$0E,$0F,$9B,$80,$27
db $14,$69,$27,$11,$19,$80,$27,$F1
db $4B,$7F,$7F,$7F,$7F

;unknown
db $E7,$37

db $1A,$80,$2B,$62,$16,$1F,$4C,$16
db $20,$46,$16,$21,$46,$00

DATA_00_2794:
db $1F,$F0
db $27,$01,$21,$02,$1C,$30,$03,$FA
db $07,$31,$37,$25,$AA,$27,$37,$26
db $AA,$27,$E7,$A0,$48,$83,$AF,$27
db $11,$32,$26,$12,$02,$37,$25,$E0
db $27,$37,$26,$E0,$27,$14,$B3,$27
db $19,$E9,$27,$16,$2C,$03,$FC,$12
db $04,$10,$D9,$27,$14,$C7,$27,$16
db $27,$10,$D9,$27,$A0,$CF,$27,$05
db $31,$E7,$B1,$09,$08,$09,$08,$0E
db $0F,$11,$13,$04,$07,$0F,$07,$15
db $E2,$27,$11,$03,$10,$07,$16,$1B
db $4C,$00,$16,$2C,$F1,$4B

DATA_00_27F4:
db $21,$04
db $1C,$44,$48,$37,$79,$63,$31,$44
db $AA,$FD,$27,$34,$37,$79,$0C,$28
db $37,$6E,$0C,$28,$E8,$02,$13,$08
db $0E,$AA,$2E,$28,$08,$0F,$81,$1B
db $28,$15,$0E,$28,$11,$16,$49,$48
db $16,$5E,$48,$19,$35,$28,$16,$4A
db $48,$16,$7A,$48,$16,$63,$48,$11
db $05,$0E,$08,$08,$0F,$E8,$2F,$1A
db $80,$29,$FF,$16,$16,$07,$07,$EF
db $25

DATA_00_283F:
db $1A,$10,$21,$03,$60,$37,$6F
db $63,$31,$34,$16,$6F,$03,$FC,$08
db $09,$01,$0F,$08,$0E,$08,$A0,$4D
db $28,$16,$4B,$44,$E8,$49

DATA_00_285C:
db $37,$19
db $46,$31,$48,$0E,$07,$07,$0F,$07
db $E8,$61

DATA_00_2868:
db $21,$03,$48,$34,$37,$4D
db $63,$31,$37,$4C,$63,$25,$37,$4D
db $63,$25,$37,$4E,$63,$25,$37,$4D
db $63,$25,$E8,$70

DATA_00_2882:
db $21,$02,$33,$12
db $02,$37,$2D,$A3,$28,$37,$2E,$A3
db $28,$14,$87,$28,$03,$FF,$12,$02
db $37,$2D,$A3,$28,$37,$2E,$A3,$28
db $14,$96,$28,$E8,$82,$07,$0F,$07
db $0F,$07,$0F,$07,$0F,$11

DATA_00_28AC:
db $21,$02
db $50,$37,$50,$63,$31,$34,$12,$04
db $37,$4F,$C4,$28,$37,$50,$C4,$28
db $14,$B6,$28,$05,$E8,$B4,$08,$0F
db $08,$08,$0F,$08,$08,$0F,$08,$11

DATA_00_28CE:
db $21,$03,$31,$02,$02,$04,$05,$17
db $37,$70,$1D,$29,$83,$E4,$28,$37
db $71,$1D,$29,$A3,$D6,$28,$33,$09
db $02,$A0,$E5,$28,$16,$51,$03,$FD
db $08,$09,$02,$0F,$0E,$A0,$EE,$28
db $81,$04,$29,$44,$39,$10,$16,$52
db $44,$16,$72,$48,$E8,$EA,$03,$FF
db $16,$71,$08,$81,$08,$29

;unknown
db $31,$37,$70,$1D,$29,$81,$04,$29
db $37,$71,$1D,$29,$81,$04,$29,$E9
db $0D

db $08,$08,$0F,$08,$0F,$08,$08,$0F
db $11

DATA_00_2926:
db $1A,$06,$16,$3B,$02,$FF,$38
db $08,$12,$20,$08,$38,$02,$14,$30
db $29,$E9,$2C

DATA_00_2938:
db $1A,$06,$32,$37,$3B
db $46,$31,$08,$0F,$A1,$3F,$29,$30
db $0F,$E9,$44

DATA_00_2948:
db $2B,$20,$10,$41,$31
db $1A,$02,$39,$1A,$34,$33,$16,$53
db $09,$08,$A9,$55,$29,$31,$0D,$0F
db $07,$0F,$E9,$5B

DATA_00_2961:
db $1C,$30,$21,$02
db $37,$3C,$63,$31,$34,$05,$1A,$80
db $16,$3C,$7F,$60,$1A,$00,$05,$37
db $56,$7E,$29,$37,$57,$7E,$29,$E9
db $74,$12,$04,$08,$08,$0E,$81,$8A
db $29,$14,$80,$29,$11,$16,$73,$19
db $9A,$29,$03,$FD,$09,$02,$0E,$A0
db $91,$29,$31,$E9,$6B,$29,$FF,$02
db $F8,$07,$10,$5A,$31,$00

DATA_00_29A3:
db $21,$03
db $1F,$F7,$29,$01,$19,$ED,$29,$2E
db $10,$E1,$29,$32,$8E,$B6,$29,$02
db $FF,$26,$37,$61,$D8,$29,$37,$62
db $D8,$29,$37,$61,$D8,$29,$10,$E1
db $29,$05,$37,$61,$D8,$29,$37,$62
db $D8,$29,$37,$61,$D8,$29,$10,$E1
db $29,$E9,$AD,$07,$07,$07,$07,$07
db $07,$07,$07,$11,$12,$03,$16,$5F
db $48,$16,$60,$48,$14,$E3,$29,$11
db $03,$10,$07,$20,$01,$1A,$06,$16
db $17,$24,$03,$08,$07,$41,$39,$16
db $12,$04,$16,$54,$44,$16,$55,$44
db $14,$FF,$29,$16,$33,$F1,$4B

DATA_00_2A0C:
db $1A
db $06,$37,$7E,$63,$31,$37,$7B,$24
db $2A,$37,$7C,$24,$2A,$37,$7D,$24
db $2A,$37,$7E,$24,$2A,$EA,$12,$44
db $86,$29,$2A,$11,$42,$38,$07,$37
db $7B,$4B,$2A,$37,$7C,$4B,$2A,$37
db $7D,$4B,$2A,$37,$7E,$4B,$2A,$EA
db $2C,$30,$31,$0E,$08,$0F,$08,$08
db $0F,$08,$08,$A0,$40,$2A,$02,$FF
db $12,$04,$A0,$3E,$2A,$07,$14,$4F
db $2A,$11,$19,$5C,$2A,$F1,$4B,$10
db $6D,$2D,$1D,$22,$16,$0F,$EE,$3B

DATA_00_2A65:
db $10,$47,$2D,$1E,$0C,$2A,$18,$2B
db $60,$1A,$00,$1F,$57,$2A,$04,$16
db $67,$12,$08,$18,$42,$17,$42,$14
db $78,$2A,$34,$03,$F9,$10,$93,$2A
db $05,$12,$02,$16,$67,$48,$16,$68
db $48,$14,$88,$2A,$EA,$7F,$0E,$08
db $0F,$08,$0F,$81,$B2,$2A,$08,$0F
db $09,$01,$A0,$93,$2A,$31,$2C,$12
db $14,$08,$08,$0F,$08,$0F,$81,$B5
db $2A,$14,$A6,$2A,$11,$05,$EA,$9B
db $05,$EA,$AE,$19,$BD,$2A,$F1,$4B
db $10,$6D,$2D,$1D,$22,$16,$10,$EE
db $3B

DATA_00_2AC6:
db $98,$CC,$2C,$10,$47,$2D,$1E
db $0D,$2A,$18,$2B,$68,$1A,$00,$1F
db $B8,$2A,$04,$34,$17,$1A,$02,$10
db $5A,$31,$34,$18,$48,$16,$5A,$12
db $08,$18,$42,$17,$42,$14,$E6,$2A
db $1A,$08,$03,$FF,$30,$12,$05,$37
db $74,$47,$2B,$37,$75,$47,$2B,$14
db $F4,$2A,$31,$34,$12,$08,$37,$74
db $3A,$2B,$37,$75,$3A,$2B,$14,$03
db $2B,$03,$01,$30,$08,$08,$A0,$11
db $2B,$31,$34,$10,$5A,$31,$16,$5A
db $7F,$60,$39,$0D,$19,$2C,$2B,$19
db $31,$2B,$19,$33,$2B,$EA,$DA,$03
db $FF,$30,$EB,$33,$03,$FF,$16,$2A
db $1A,$02,$07,$EB,$37,$13,$04,$0C
db $0F,$08,$0F,$81,$4E,$2B,$15,$3C
db $2B,$11,$08,$08,$0F,$08,$08,$0F
db $11,$05,$EB,$43,$19,$56,$2B,$F1
db $4B,$10,$6D,$2D,$1D,$22,$16,$11
db $EE,$3B

DATA_00_2B5F:
db $10,$47,$2D,$1E,$0D,$2A
db $40,$2B,$68,$16,$69,$1A,$00,$1F
db $51,$2B,$04,$32,$8E,$76,$2B,$02
db $FF,$26,$16,$69,$17,$13,$02,$03
db $FB,$12,$0B,$09,$02,$0F,$0E,$0F
db $14,$80,$2B,$15,$7C,$2B,$16,$59
db $03,$04,$08,$A0,$8F,$2B,$31,$1A
db $02,$37,$58,$A0,$2B,$37,$59,$A0
db $2B,$EB,$96,$2D,$2D,$2D,$2D,$2D
db $2D,$8B,$AA,$2B,$11,$1A,$08,$EB
db $70,$19,$B3,$2B,$F1,$4B,$10,$6D
db $2D,$1D,$22,$16,$12,$EE,$3B

DATA_00_2BBC:
db $10
db $47,$2D,$1E,$0D,$1C,$45,$2A,$6C
db $2B,$60,$1A,$00,$1F,$AE,$2B,$04
db $02,$FF,$12,$04,$16,$80,$17,$48
db $16,$81,$48,$14,$D1,$2B,$12,$02
db $03,$FB,$16,$80,$48,$16,$81,$48
db $16,$82,$10,$0F,$2C,$10,$0F,$2C
db $0E,$EB,$E7,$39,$0E,$16,$81,$60
db $14,$DD,$2B,$16,$80,$48,$16,$88
db $50,$19,$1F,$2C,$19,$19,$2C,$19
db $1C,$2C,$16,$80,$2C,$5F,$7F,$05
db $EB,$DB,$07,$80,$F0,$2B,$07,$0F
db $80,$F0,$2B,$11,$50,$EC,$1F,$70
db $EC,$1F,$36,$1A,$02,$2B,$20,$16
db $29,$33,$30,$07,$07,$07,$0F,$EC
db $28,$19,$33,$2C,$F1,$4B,$10,$6D
db $2D,$1D,$22,$16,$13,$EE,$3B

DATA_00_2C3C:
db $10
db $47,$2D,$1E,$0E,$2B,$68,$1A,$00
db $1F,$2E,$2C,$04,$2A,$3C,$17,$16
db $76,$30,$12,$04,$33,$07,$47,$03
db $FF,$07,$45,$14,$51,$2C,$31,$8E
db $8A,$2C,$02,$FE,$8E,$66,$2C,$02
db $02,$26,$31,$12,$03,$37,$77,$85
db $2C,$37,$78,$85,$2C,$14,$6A,$2C
db $05,$12,$03,$37,$77,$85,$2C,$37
db $78,$85,$2C,$14,$78,$2C,$EC,$49
db $07,$07,$07,$07,$11,$02,$FF,$8E
db $90,$2C,$32,$26,$16,$87,$03,$FB
db $10,$A9,$2C,$10,$A9,$2C,$09,$02
db $80,$AE,$2C,$10,$A9,$2C,$10,$A9
db $2C,$0E,$EC,$95,$08,$80,$AE,$2C
db $11,$05,$03,$FC,$07,$10,$C3,$2C
db $80,$49,$2C,$09,$01,$10,$C3,$2C
db $80,$49,$2C,$0E,$EC,$B2,$80,$49
db $2C,$08,$11,$38,$00,$F1,$4B

DATA_00_2CCC:
db $10
db $47,$2D,$1E,$0E,$1C,$45,$2B,$2C
db $1A,$00,$1F,$C8,$2C,$04,$36,$34
db $16,$7F,$10,$F9,$2C,$19,$03,$2D
db $1A,$08,$16,$89,$7F,$7F,$4F,$10
db $F9,$2C,$1A,$80,$12,$7F,$18,$14
db $F3,$2C,$EC,$DB,$12,$08,$18,$44
db $17,$44,$14,$FB,$2C,$11,$1A,$00
db $60,$34,$03,$01,$2B,$20,$37,$1C
db $2C,$2D,$37,$1D,$2C,$2D,$ED,$0B
db $03,$FF,$37,$1C,$37,$2D,$37,$1D
db $37,$2D,$ED,$17,$31,$37,$1C,$42
db $2D,$37,$1D,$42,$2D,$ED,$22,$12
db $04,$09,$08,$97,$15,$2D,$14,$2E
db $2D,$11,$12,$04,$07,$0F,$97,$21
db $2D,$14,$39,$2D,$11,$0B,$41,$0B
db $41,$11,$1A,$06,$18,$16,$08,$0F
db $AF,$4C,$2D,$7F,$5F,$2A,$00,$19
db $5F,$2D,$2A,$90,$19,$5F,$2D,$39
db $47,$11,$1A,$80,$03,$10,$2B,$20
db $12,$0A,$20,$01,$07,$14,$67,$2D
db $1A,$80,$2A,$40,$2B,$70,$7F,$F1
db $5A

DATA_00_2D76:
db $10,$90,$2D,$1A,$00,$10,$A0
db $2D,$EE,$C9

DATA_00_2D80:
db $1A,$06,$10,$90,$2D
db $10,$5A,$31,$16,$04,$10,$A0,$2D
db $35,$EE,$79

db $1A,$06,$38,$02,$02,$08,$03,$08
db $07,$16,$28,$48,$AD,$9B,$2D,$11
db $34,$03,$F8,$07,$31,$08,$0F,$80
db $A5,$2D,$0E,$09,$02,$0F,$09,$02
db $A0,$AA,$2D,$11

DATA_00_2DB4:
db $10,$DE,$2D,$E9,$4A

DATA_00_2DB9:
db $10,$DE,$2D,$30,$03,$E0,$07,$31
db $E5,$F2

DATA_00_2DC3:
db $10,$DE,$2D,$30,$19,$D7
db $2D,$4E,$8E,$3B,$31,$32,$19,$D7
db $2D,$4E,$8E,$3B,$31,$05,$10,$5A
db $31,$16,$01,$EE,$3C,$1A,$80,$48
db $B9,$E0,$2D,$02,$08,$07,$11

DATA_00_2DE8:
db $10,$ED,$2D,$EE,$36,$1A,$06,$23
db $F1,$5A

DATA_00_2DF2:
db $10
db $ED,$2D
db $EE,$69

DATA_00_2DF7:
db $10,$ED
db $2D,$EE,$6F

DATA_00_2DFC:
db $10,$ED,$2D,$EE,$75

DATA_00_2E01:
db $10,$ED,$2D,$EE,$7B

DATA_00_2E06:
db $9F,$F7,$2D
db $10,$ED,$2D,$EE,$84

DATA_00_2E0E:
db $10,$ED,$2D
db $EE,$8A

DATA_00_2E13:
db $10,$ED,$2D,$EE,$67,$18
db $16,$18,$EE,$2A,$18,$16,$01,$EE
db $2A,$18,$16,$05,$EE,$2A,$18,$16
db $03,$38,$0A,$03,$05,$07,$17,$30
db $31,$EE,$4D

DATA_00_2E34:
db $1D,$22,$16,$18,$02
db $04,$07,$30,$1A,$82,$03,$FD,$07
db $08,$08,$0E,$08,$08,$0E,$08,$08
db $0E,$08,$08,$0E,$1A,$03,$10,$62
db $2E,$80,$5C,$2E,$0E,$10,$62,$2E
db $A0,$4F,$2E,$0F,$8C,$5C,$2E,$EE
db $D4,$80,$5C,$2E,$08,$11

DATA_00_2E67:
db $1D,$22,$16,$01,$EE,$3B

DATA_00_2E6D:
db $1D,$22,$16,$00,$EE,$3B

DATA_00_2E73:
db $1D,$22,$16,$05,$EE,$3B

DATA_00_2E79:
db $1D,$22,$16,$03,$EE,$3B

DATA_00_2E7F:
db $9F,$6D,$2E,$1D,$22,$16,$06,$EE,$3B

DATA_00_2E88:
db $1D,$22,$16,$02,$EE,$3B

DATA_00_2E8E:
db $9E,$3B,$31,$1D,$22,$16,$07,$EE,$3B

DATA_00_2E97:
db $93,$3B,$31,$1A,$01,$16,$0A,$7F,$EE,$9E

DATA_00_2EA1:
db $92,$3B,$31,$1D,$22,$16,$0C,$EE
db $3B

DATA_00_2EAA:
db $92,$3B,$31,$1D,$22,$16,$0D,$EE
db $3B

DATA_00_2EB3:
db $92,$3B,$31,$1D,$22,$16,$0B,$EE
db $3B

DATA_00_2EBC:
db $94,$3B,$31,$1D,$22
db $16,$0E,$EE,$3B,$16,$07,$48,$00

DATA_00_2EC9:
db $10
dw DATA_00_315A
db $00

DATA_00_2ECD:
db $10
dw DATA_00_315A
db $1A,$01
db $16,$01
db $7F,$7F,$12,$10,$18,$43,$17,$43
db $14,$D8,$2E
db $00

DATA_00_2EE0:
db $10
dw DATA_00_315A
db $1A,$01
db $16,$03
db $EE,$D4

DATA_00_2EE9:
db $16,$14,$02,$02,$04,$03,$FE,$81
db $C9,$2E,$07,$85,$C5,$2E,$07,$80
db $C9,$2E,$07,$EE,$F0,$20,$00,$EE
db $C9,$20,$00,$48,$16,$17,$EF,$0B

DATA_00_2F09:
db $16,$15,$02,$02,$04,$03,$FD,$81
db $C9,$2E,$85,$C5,$2E,$07,$07,$80
db $C9,$2E,$85,$C5,$2E,$0E,$07,$EF
db $10

DATA_00_2F22:
db $02,$02,$04,$16,$16,$31,$81
db $C9,$2E,$0E,$A0,$C9,$2E,$08,$85
db $C5,$2E,$08,$EF,$28

DATA_00_2F36:
db $1A,$80,$02
db $01,$10,$44,$2F,$02,$FF,$10,$44
db $2F,$EF,$38,$12,$0C,$16,$8A,$0A
db $39,$12,$0F,$07,$16,$8B,$0A,$0F
db $07,$16,$8A,$0A,$87,$0F,$07,$16
db $8B,$0A,$0F,$07,$14,$46,$2F,$11

DATA_00_2F61:
db $9A,$3B,$31,$1A,$06,$37,$66,$3C
db $31,$28,$10,$F1,$38

DATA_00_2F6E:
db $1A,$80,$13
db $04,$12,$04,$10,$85,$2F,$14,$74
db $2F,$19,$8C,$2F,$15,$72,$2F,$10
db $85,$2F,$EF,$80,$16,$64,$50,$16
db $65,$50,$11,$1A,$01,$39,$11,$02
db $03,$8E,$97,$2F,$02,$FD,$43,$07
db $8E,$97,$2F,$30,$2B,$20,$16,$05
db $33,$07,$0F,$EF,$A2

DATA_00_2FA6:
db $1A,$80,$B3
db $F9,$2F,$95,$F6,$2F,$2F,$0A,$48
db $B6,$B0,$2F,$2A,$01,$32,$05,$05
db $12,$04,$16,$84,$48,$16,$83,$48
db $14,$BB,$2F,$19,$CA,$2F,$7F,$EF
db $C7,$16,$08,$02,$03,$08,$A1,$CE
db $2F,$03,$10,$02,$10,$07,$30,$2B
db $50,$12,$04,$10,$5A,$31,$29,$D2
db $07,$14,$DC,$2F,$02,$10,$07,$30
db $2B,$50,$12,$04,$10,$5A,$31,$29
db $D3,$07,$14,$ED,$2F,$2F,$0F,$00
db $2F,$0A,$00

DATA_00_2FFC:
db $9E,$3B,$31,$2F,$00
db $1A,$04,$1F,$0F,$30,$01,$03,$FE
db $07,$31,$16,$3D,$F1,$38,$12,$04
db $0E,$07,$07,$14,$11,$30,$0E,$08
db $A0,$17,$30,$03,$FC,$07,$31,$02
db $02,$26,$0E,$08,$A1,$23,$30,$28
db $07,$48,$02,$18,$07,$2B,$60,$31
db $10,$49,$30,$02,$10,$07,$10,$49
db $30,$2B,$70,$02,$F0,$10,$49,$30
db $07,$10,$49,$30,$2F,$05,$EE,$8E
db $29,$00,$F1,$5A

DATA_00_304D:
db $90,$3B,$31,$1A,$06,$37,$2F,$63
db $31,$10,$3C,$31,$28,$80,$F1,$38

DATA_00_305D:
db $91
dw DATA_00_313B
db $94
dw DATA_00_313B
db $2F,$14,$1A,$06,$37,$30
db $63,$31,$10,$3C,$31,$28,$40,$F1
db $38

DATA_00_3072:
db $1A,$06,$18,$37,$44,$3C,$31
db $28,$0B,$00

DATA_00_307C:
db $32,$38,$0F,$81,$30
db $7F,$05,$38,$10,$87,$30,$7F,$05
db $38,$11,$8D,$30,$7F,$05,$38,$12
db $93,$30,$7F,$05,$38,$13,$99,$30
db $7F,$12,$0A,$48,$38,$05,$14,$9C
db $30,$38,$00

;unknown
db $00

DATA_00_30A5:
db $03,$FC,$10,$D8,$29,$0E,$F0,$A7

DATA_00_30AD:
db $32,$26,$16,$8D,$7F,$19,$DF,$30
db $13,$04,$30,$03,$FC,$12,$09,$07
db $07,$07,$0E,$0F,$14,$BC,$30,$15
db $B7,$30,$7F,$7F,$02,$FF,$31,$12
db $60,$07,$14,$CE,$30,$30,$03,$FF
db $12,$18,$07,$14,$D7,$30,$38,$00

;unknown
db $F1,$38

db $2A,$44,$2B,$50,$19,$E9,$30,$44
db $F0,$E3,$38,$09,$16,$00,$10,$85
db $2C,$0E,$F0,$ED

DATA_00_30F3:
db $1A,$80,$17,$03
db $FF,$16,$85,$28,$0C,$7F,$12,$26
db $37,$86,$0D,$31,$37,$85,$0D,$31
db $14,$FF,$30,$31,$F0,$FF,$13,$04
db $38,$03,$0F,$15,$0F,$31,$11

DATA_00_3116:
db $1A
db $06,$16,$04,$0F,$9D,$28,$31,$A8
db $1A,$31,$38,$06,$10,$38,$00

;unknown
db $F1,$38

db $38,$06,$10,$32,$12,$10,$07,$0F
db $14,$2E,$31,$28,$0D,$7F,$38,$01
db $7F,$F1,$38

DATA_00_313B:
db $00,$44,$A8,$3C,$31
db $11,$44,$A3,$41,$31,$11,$44,$A2
db $46,$31,$11,$17,$03,$FB,$32,$06
db $0F,$39,$1F,$07,$0E,$0F,$F1,$53
db $50,$25

DATA_00_315A:
db $39,$07,$16,$08,$48,$16
db $09,$48,$11,$18,$80,$6F,$31,$03
db $08,$09,$08,$A0,$69,$31,$31,$17
db $11,$80,$80,$31,$31,$30,$0E,$08
db $38,$04,$A0,$76,$31,$08,$F1,$5A
db $02,$02,$04,$08,$08,$38,$04,$A0
db $74,$31,$A1,$83,$31,$F1,$5A


DATA_00_318F:
db $10,$B6,$31,$1A,$06,$50,$29,$9F
db $33
db $12,$10,$07,$0F,$14,$9A,$31,$29
db $DF,$18,$7F,$F1,$8F

DATA_00_31A5:
db $10,$B6,$31
db $1A,$02,$52,$29,$9F,$0E,$08,$08
db $0F,$80,$C9,$2E,$F1,$AD,$1A,$80
db $16,$15,$18,$42,$A2,$BB,$31,$17
db $11

;are these pointers?
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

CODE_00_327B:
LD HL, $C632
LD A, [$C631]
CALL CODE_00_3292
LD B, A
LD A, [$C208]
AND $20
JR NZ, CODE_00_3290
LD A, $0F
ADD A, B
LD B, A

CODE_00_3290:
LD A, B
RET

CODE_00_3292:
AND $F0
OR [HL]
SWAP A
RET

CODE_00_3298:
LD A, [$C1A2]
OR L
LD L, A
RET

;used to fetch the next byte from the current entity's data table
CODE_00_329E:
LD HL, $C60E                                                ;data table stored here
LD A, L
OR H

LOOP_00_32A3:
JR Z, LOOP_00_32A3                                          ;check if the pointer is somehow 0000? lock the game.

LD E, [HL]
INC [HL]
PUSH AF
INC HL
LD D, [HL]                                                  ;will get pointer
POP AF
JR NZ, CODE_00_32AE

INC [HL]

CODE_00_32AE:
LD A, [DE]
RET

CODE_00_32B0:
LD HL, $C60E
DEC [HL]
LD A, [HL]
CP $FF
RET NZ

INC HL
DEC [HL]
RET

CODE_00_32BB:
LD A, [$C614]
AND A
JR Z, CODE_00_32EC
LD E, A
LD A, [$C609]
LD D, A
CALL CODE_00_32F1
LD A, [$C608]
BIT 5, A
JR NZ, CODE_00_32DC
LD A, E
AND $0F
JR Z, CODE_00_32DC
LD C, A
LD A, D
AND $0F
CP C
JR NC, CODE_00_32E3

CODE_00_32DC:
LD A, [$C613]
LD [$C603], A
RET

CODE_00_32E3:
LD A, [$C613]
SUB $08
LD [$C603], A
RET

CODE_00_32EC:
CALL CODE_00_32DC
JR CODE_00_32FB

CODE_00_32F1:
LD A, E
AND $F0
LD C, A
LD A, D
AND $F0
CP C
JR NZ, CODE_00_3302

CODE_00_32FB:
LD A, [$C611]
LD [$C601], A
RET

CODE_00_3302:
LD B, A
LD A, C
SUB B
JR C, UNUSED_00_3312
SRL A
LD B, A
LD A, [$C611]
ADD A, B
LD [$C601], A
RET

UNUSED_00_3312:
SRL A
LD B, A
LD A, [$C611]
SUB B
LD [$C601], A
RET

CODE_00_331D:
LD A, SFX_ItemCollect                                       ;collected item. ding!
CALL QueueSoundPrep_00_072B                                 ;

LD A, [$C610]
AND A
JR NZ, CODE_00_332D

LD HL, DATA_00_0779+3
JR GiveMoney_00_333D

CODE_00_332D:
CP $01
JR NZ, CODE_00_3336
LD HL, DATA_00_0775+3
JR GiveMoney_00_333D

CODE_00_3336:
CP $18
JR NZ, CODE_00_3346
LD HL, DATA_00_0771+3

GiveMoney_00_333D:
LD DE, MoneyCurrent+3
CALL AddTo4ByteCounter_00_393F
JP CODE_00_3404

CODE_00_3346:
CP $05
JR NZ, CODE_00_335C

LD A, [PlayerHealthMax]
DEC A
LD E, A
LD HL, PlayerHealth

LD A, [HL]
CP E
JP NC, CODE_00_3404

CODE_00_3357:
INC [HL]

CODE_00_3358:
INC [HL]                                                    ;increase counter that was in HL.
JP CODE_00_3404

CODE_00_335C:
CP $03                                                      ;check cake item
JR NZ, CODE_00_3369

LD A, [PlayerHealthMax]                                     ;restore fully.
LD [PlayerHealth], A                                        ;
JP CODE_00_3404

CODE_00_3369:
CP $02
JR NZ, CODE_00_337D

LD A, $08
CALL QueueSoundPrep_00_072B

LD HL, PlayerLives
LD A, [HL]
CP $09                                                      ;check if lives are already capped
JP Z, CODE_00_3404
JR CODE_00_3358

CODE_00_337D:
CP $07
JR NZ, CODE_00_3391
CALL CODE_00_23CF
LD [HL], $01

LD HL, PlayerHealthMax
LD A, [HL]
ADD A, $02                                                  ;ice cone gives 1 plip of health
LD [PlayerHealth], A

JR CODE_00_3357

CODE_00_3391:
CP $06
JR NZ, CODE_00_33A8

XOR A
LD [$DF54], A
LD [Player_State], A

LD A, $FF                                                   ;set maximum timer
LD [Player_InvincibilityTimer], A                           ;

LD A, Music_Invincibility                                   ;invincibility theme
CALL QueueSoundPrep_00_072B

JR CODE_00_3404

CODE_00_33A8:
CALL CODE_00_3409
JR Z, CODE_00_33B4

LD A, $80
LD [$C627], A
JR CODE_00_33EA

CODE_00_33B4:
LD HL, $CA1D
LD A, [$C610]
CP $0A
JR NZ, CODE_00_33C4

SET 0, [HL]
LD A, $09
JR CODE_00_33F8

CODE_00_33C4:
CP $0B
JR NZ, CODE_00_33CE
SET 3, [HL]
LD A, $0F
JR CODE_00_33F8

CODE_00_33CE:
CP $0C
JR NZ, CODE_00_33D6
SET 1, [HL]
JR CODE_00_33DC

CODE_00_33D6:
CP $0D
JR NZ, CODE_00_33F0
SET 2, [HL]

CODE_00_33DC:
LD A, $0E
LD [MessageQueue], A

LD A, $0F
LD [Player_State], A

LD A, $21
LDH [SFXQueue], A

CODE_00_33EA:
LD HL, LegendaryTreasureValue_00_0781+3
JP GiveMoney_00_333D

CODE_00_33F0:
CP $0E
JR NZ, CODE_00_3404
SET 4, [HL]
LD A, $11

CODE_00_33F8:
LD [MessageQueue], A

LD A, $0F
LD [Player_State], A

LD A, $21
LDH [SFXQueue], A

CODE_00_3404:
CALL CODE_00_36D8
POP AF
RET

CODE_00_3409:
CP $0F
JR C, CODE_00_3412
CP $14
JR NC, CODE_00_3412
RET

CODE_00_3412:
XOR A
RET

CODE_00_3414:
XOR A
LDH [$FF96], A
LD A, [$C612]
BIT 7, A
RET NZ

LD A, [$C610]
CP $3B
JR Z, CODE_00_343C

LD A, [$DF4F]
AND $01
LD B, A
LD A, [$C1A2]
LD C, A
SWAP A
AND $01
CP B
RET NZ

LD HL, $DF78
LD A, C
CP [HL]
JP Z, CODE_00_34F0

CODE_00_343C:
CALL CODE_00_35C5
CALL CODE_00_357E
JR NC, CODE_00_3448
CALL CODE_00_3590
RET C

CODE_00_3448:
CALL CODE_00_359F
JR NC, CODE_00_3451
CALL CODE_00_35AA
RET C

CODE_00_3451:
LD A, $01
LDH [$FF96], A

LD A, [$C612]
BIT 0, A
JP NZ, CODE_00_331D

LD A, [$C201]
ADD A, $15
LD B, A
LD A, [$C601]
ADD A, $08
SUB B
JR NC, CODE_00_3488

CODE_00_346B:
LD A, [$C612]
BIT 2, A
RET NZ

LD A, [Player_InvincibilityTimer]                           ;check if ran out
AND A
JP NZ, CODE_00_3500

LD A, [$DF73]
AND A
JR Z, CODE_00_3482
CALL CODE_00_3576
RET Z

CODE_00_3482:
LD A, $01
LD [$CA00], A
RET

CODE_00_3488:
LD A, [$C610]
CP $3B
JR NZ, CODE_00_349B

LD A, [$C1A2]
LD [$DF67], A

LD A, $0C
LD [Player_State], A
RET

CODE_00_349B:
CP $15
JR NZ, CODE_00_34A5
LD A, $01
LD [$DF65], A
RET

CODE_00_34A5:
LD A, [$C612]
BIT 5, A
JR Z, CODE_00_34E9
LD A, [$DF54]
AND A
RET NZ

LD A, [Player_InvincibilityTimer]
AND A
RET NZ

LD A, [Player_State]
CP $08
RET Z

LD A, [$C203]
LD B, A
LD A, [$C603]
SUB B
JR NC, CODE_00_34C8
CPL
INC A

CODE_00_34C8:
CP $10
RET NC

LD A, $09
LD [Player_State], A

LD A, $01
LD [$DF66], A

LD A, [$C613]
SUB $04
LD [$C203], A
LD A, [$C611]
SUB $14
LD [$C201], A
CALL CODE_00_11D5
RET

CODE_00_34E9:
LD A, [Player_PogoFlag]
AND A
JP Z, CODE_00_346B

CODE_00_34F0:
XOR A
LD [$DF78], A
LD A, [$C612]
BIT 1, A
RET NZ

CALL CODE_00_3576
JP Z, CODE_00_346B

CODE_00_3500:
LD A, [$DF4F]
AND $03
JR NZ, CODE_00_3524
LD A, [$C609]
LD [$DF8A], A
LD A, [$C602]
AND $07
JR Z, CODE_00_3524
DEC A
SLA A
LD B, $00
LD C, A
LD HL, DATA_00_356E
ADD HL, BC
LD B, [HL]
INC HL
LD C, [HL]
CALL CODE_00_1F5F

CODE_00_3524:
LD A, $01
LD [$DF65], A
LD HL, $C60E
LD A, [$C612]
BIT 3, A
JR NZ, CODE_00_3542
LD [HL], $4B
INC HL
LD [HL], $31
LD HL, $C612
SET 7, [HL]
XOR A
LD [$C60B], A
RET


CODE_00_3542:
LD HL, $C61D
DEC [HL]
JR Z, CODE_00_3554
LD A, [$C1A2]
LD [$DF72], A
LD A, $80
LD [$DF73], A
RET


CODE_00_3554:
LD HL, $C60E
LD A, [$C61E]
LD [HL+], A
LD A, [$C61F]
LD [HL+], A
XOR A
LD [$DF72], A
LD [$DF73], A
LD [$DF71], A
LD A, $80
JP CODE_00_1F4A

DATA_00_356E:
db $18,$2E,$1D,$2E,$22,$2E,$27,$2E

CODE_00_3576:
LD HL, $DF72
LD A, [$C1A2]
CP [HL]
RET

CODE_00_357E:
LD A, [$DF7F]
CALL CODE_00_35BB
LD A, [$DF7D]
LD B, A
LD A, [$C603]

CODE_00_358B:
SUB B
LD B, A
LD A, C
CP B
RET

CODE_00_3590:
LD A, [$C609]
CALL CODE_00_35BB
LD A, [$C603]
LD B, A
LD A, [$DF7D]
JR CODE_00_358B


CODE_00_359F:
LD C, $15
LD A, [$DF7E]
LD B, A
LD A, [$C601]
JR CODE_00_358B


CODE_00_35AA:
LD A, [$C609]
CALL CODE_00_35B9
LD A, [$C601]
LD B, A
LD A, [$DF7E]
JR CODE_00_358B


CODE_00_35B9:
SWAP A


CODE_00_35BB:
AND $0F
SLA A
SLA A
SLA A
LD C, A
RET



CODE_00_35C5:
LD HL, $DF7D
LD A, [$C203]
ADD A, $08
LD [HL+], A
LD A, [$C201]
LD C, A
LDH A, [JoypadInputHolding]
BitA JoypadInput_Down
JR NZ, CODE_00_35DD

LD B, $31
LD A, C
JR CODE_00_35E2

CODE_00_35DD:
LD B, $21
LD A, C
ADD A, $08

CODE_00_35E2:
LD [HL+], A
LD [HL], B
RET

CODE_00_35E5:
LD HL, DATA_01_697C
LD B, $00
LD C, A
CALL CODE_00_3616

SetBankAndBackup 1

LD A, [BC]
LD [$C605], A
INC BC
LD A, [BC]
LD HL, DATA_01_692C
CALL CODE_00_360F
LD A, [BC]
LD [$C609], A
INC BC
LD HL, $C606
LD A, [BC]
LD [HL+], A
INC BC
LD A, [BC]
LD [HL], A
RET

CODE_00_360F:
LD B, $00
LD C, A
SLA C
RL B

CODE_00_3616:
SLA C
RL B
ADD HL, BC
LD B, H
LD C, L
RET

CODE_00_361E:
LD A, [$C1A2]
LDH [$FF94], A

LD A, E
LDH [$FF96], A

LD E, $EE
LD A, [$C8F8]
BIT 1, A
JR NZ, CODE_00_3656
LD A, D
AND $7F
CP $30
JR C, CODE_00_3656
PUSH BC
CALL CODE_00_327B
LD E, A
POP BC
XOR A
LD [$C1A2], A

CODE_00_3640:
LD HL, $C1A2
LD A, [HL]
ADD A, $10
JR Z, CODE_00_3656
LD [HL], A
LD HL, $C20D
CALL CODE_00_3298
LD A, [HL]
CP E
JP Z, CODE_00_36D2
JR CODE_00_3640

CODE_00_3656:
XOR A
LD [$C1A2], A

CODE_00_365A:
LD HL, $C1A2
LD A, [HL]
ADD A, $10
JP Z, CODE_00_36D2

LD [HL], A
LD HL, $C200
CALL CODE_00_3298
LD A, [HL]
AND A
JR NZ, CODE_00_365A
PUSH BC
PUSH DE
PUSH HL
LD D, H
LD E, L
LD HL, $C300
CALL CODE_00_3298
CALL CODE_00_36E7
POP HL
POP DE
POP BC
LD A, $02
LD [HL], A

LD HL, $C303
CALL CODE_00_3298
LD [HL], B

LD HL, $C301
CALL CODE_00_3298
LD [HL], C

LD HL, $C20D
CALL CODE_00_3298
LD [HL], E

LD HL, $C20C
CALL CODE_00_3298

LDH A, [$FF96]
LD [HL], A

LD A, D
AND $F0
JR NZ, CODE_00_36AE

LD HL, $C302
CALL CODE_00_3298

LD A, $80
LD [HL], A

CODE_00_36AE:
LD A, D
BIT 7, A
JR Z, CODE_00_36BC

LD HL, $C208
CALL CODE_00_3298

LD A, $10
LD [HL], A

CODE_00_36BC:
LD A, D
SLA A
LD C, A
LD B, $00
LD HL, POINTERS_00_31C1
ADD HL, BC
LD B, [HL]                                                  ;get pointer into B and C
INC HL

LD C, [HL]
LD HL, $C20E
CALL CODE_00_3298

LD [HL], B                                                  ;pointer into B and C
INC HL                                                      ;
LD [HL], C                                                  ;

CODE_00_36D2:
LDH A, [$FF94]
LD [$C1A2], A
RET

CODE_00_36D8:
LD HL, $C600
LD D, H
LD E, L
LD HL, $C610
LD A, [$C612]
BIT 4, A
JR NZ, CODE_00_36F1


CODE_00_36E7:
XOR A
LD [HL+], A
LD [DE], A
INC DE
LD A, L
AND $0F
JR NZ, CODE_00_36E7
RET

CODE_00_36F1:
LD A, [$C61D]
LD C, A
CALL CODE_00_327B
SUB C
CP $08
JR C, CODE_00_3703

LD E, $58                                                   ;pointer?
LD D, $31
JR CODE_00_3709

CODE_00_3703:
LD HL, $C61E
LD A, [HL+]
LD E, A
LD D, [HL]

CODE_00_3709:
LD HL, $C60E
LD A, E
LD [HL+], A
LD [HL], D
LD D, $B0
LD A, [$C208]
AND $20
JR Z, CODE_00_371A
LD D, $E0

CODE_00_371A:
LD A, D
LD [$C613], A

LD A, $30
LD [$C611], A

LD A, $10
LD [$C612], A

LD A, $82
LD [$C600], A
RET

;input A - how many VBlank hits to wait for
WaitForVBlank_372E:
LDH [VBlankWaitCounter], A

LOOP_00_3730:
HALT                                                        ;wait until interrupt...
LDH A, [VBlankWaitCounter]                                  ;check if the counter is 0
AND A                                                       ;
JR NZ, LOOP_00_3730
RET

CODE_00_3737:
LDH A, [Reg_InterruptsEnabler]
LDH [$FF92], A                                              ;save currently enabled interrupt bits here

ResetBitA Interrupt_VBlank                                  ;disable VBlank bit
LDH [Reg_InterruptsEnabler], A

LOOP_373F:
LDH A, [Register_LCDYPos]                                   ;check for horizontal line
CP $91                                                      ;
JR NZ, LOOP_373F

LDH A, [Reg_LCDControlAndRender]                            ;
AND $00                                                     ;??? (can use XOR A)
LDH [Reg_LCDControlAndRender], A                            ;disable everything

LDH A, [$FF92]                                              ;restore interrupts
LDH [Reg_InterruptsEnabler], A                         ;
RET                                                         ;

;does what it says on the tin, enable rendering
EnableLCDAndRender_00_3750:
LDH A, [Reg_LCDControlAndRender]
OR LCDControlEnable|LCDSpriteRender|LCDBackgroundRender
LDH [Reg_LCDControlAndRender], A
RET

;note: does not disable LCD, but disables sprite and background display
DisableRender_00_3757:
LDH A, [Reg_LCDControlAndRender]
AND $FF^(LCDSpriteRender|LCDBackgroundRender)
LDH [Reg_LCDControlAndRender], A
RET

;unknown
db $F0,$40,$F6,$03,$E0,$40,$C9

ReadJoypadInputs_00_3765:
LD A, $20
LDH [Reg_JoyPad], A

LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
CPL
AND $0F
SWAP A
LD B, A
LD A, $10
LDH [Reg_JoyPad], A

LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
CPL
AND $0F
OR B
LD C, A
LDH A, [JoypadInputHolding]
XOR C
AND C
LDH [JoypadInputPress], A
LD A, C
LDH [JoypadInputHolding], A

LD A, $30
LDH [Reg_JoyPad], A
RET

CODE_00_3796:
LD C, LOW(OAMUploadCode)
LD B, $0A
LD HL, CODE_00_37A4                                         ;put code into HRAM

LOOP_379D:
LD A, [HL+]
LD [$FF00+C], A
INC C
DEC B
JR NZ, LOOP_379D
RET

;some code that is stored into HRAM for faster access
CODE_00_37A4:
LD A, $C0
LDH [Reg_OAMDMA], A

LD A, $28

LOOP_00_37AA:
DEC A                                                       ;wait for a bit, I guess so we don't mess with OAM?
JR NZ, LOOP_00_37AA
RET

CODE_00_37AE:
LD A, [$C1A2]
LD E, A
LD D, $00
ADD HL, DE
RET

CODE_00_37B6:
PUSH DE
PUSH HL
LD H, $00
LDH A, [$FF8D]
AND $F8
LD L, A
SLA L
RL H
SLA L
RL H
LD DE, $9800
ADD HL, DE
LDH A, [$FF8E]
SRL A
SRL A
SRL A
LD E, A
LD D, $00
ADD HL, DE
LD A, H
LDH [$FF8F], A
LD A, L
LDH [$FF90], A
POP HL
POP DE
RET

;clear RAM routine
;input BC - amount of bytes to clear
;HL - RAM starting point
ClearRAM_00_37E0:
XOR A                                                       ;big fat 0
LD [HL+], A
DEC BC
LD A, C
OR B
JR NZ, ClearRAM_00_37E0                                     ;clear until we're done
RET

;clear tilemap
ClearTilemap_00_37E8:
LD HL, $9800
LD BC, $0800

LOOP_00_37EE:
LD A, $6E                                                   ;fill with this tile
LD [HL+], A
DEC BC

LD A, C
OR B
JR NZ, LOOP_00_37EE                                         ;loop until done
RET

;Transfer from table routine.
;input: HL - pointer
;DE - RAM or other location to store from pointer
;BC - amount of bytes to transfer
TransferData_00_37F7:
LD A, [HL+]
LD [DE], A
INC DE
DEC BC
LD A, B
OR C
JR NZ, TransferData_00_37F7
RET

;HL - pointer to a tilemap
ProcessStripeImage_00_3800:
LD A, [HL+]
AND A                                                       ;check if A is zero
RET Z

LDH [$FF8F], A                                              ;VRAM pointer
LD A, [HL+]

LDH [$FF90], A                                              ;store high byte
LD A, [HL+]

LD B, A                                                     ;how many bytes to transfer. if bit 7 is set, 
CALL DrawStripeImage_00_380F
JR ProcessStripeImage_00_3800                               ;keep going until hitting that elusive stop command

DrawStripeImage_00_380F:
LDH A, [Reg_LCDControlAndRender]                            ;
BitA LCDControlEnable                                       ;
JR NZ, StripeImageIntoBuffer_00_382D                        ;if LCD is enabled, can only draw from buffer

LD C, B                                                     ;transfer amount of bytes into C
LD B, $00                                                   ;clear B

LDH A, [$FF8F]
LD D, A                                                     ;pointer into DE

LDH A, [$FF90]
LD E, A

BitC StripeImageCommand_Repeat                              ;check if bit 7 is set
JR Z, TransferData_00_37F7                                  ;standard data transfer if not

ResetBitC StripeImageCommand_Repeat                         ;clear bit 7 again
LD B, C                                                     ;C goes back into B
LD A, [HL+]                                                 ;next byte

LOOP_00_3826:
CALL TranferByteToVRAM_00_3886                              ;
DEC B                                                       ;
JR NZ, LOOP_00_3826                                         ;
RET                                                         ;

;store to a buffer or from...
StripeImageIntoBuffer_00_382D:
LD DE, Buffer_DataCount                                     ;
LD A, [DE]                                                  ;
ADD A, B                                                    ;
CP $60                                                      ;check if we're writing more than 96 bytes of data.
JR C, CODE_00_383B                                          ;

LD A, $01                                                   ;clear the buffer if overloaded
CALL WaitForVBlank_372E                                     ;

CODE_00_383B:
LD A, $01                                                   ;UNDER CONSTRUCTION!!!
LD [Buffer_WritingFlag], A                                  ;

PUSH BC                                                     ;
LD A, [DE]                                                  ;get amount of data we're going to process and modify it as we put more buffered data
LD C, A                                                     ;

ADD A, E                                                    ;load new data into the area in the buffer where we left off last time.
LD E, A                                                     ;
JR NC, CODE_00_3848                                         ;
INC D                                                       ;handle high byte for that

CODE_00_3848:
INC DE                                                      ;get from Buffer_DataCount to Buffer_Storage

LDH A, [$FF8F]                                              ;VRAM high
CALL TranferByteToBuffer_00_3886                            ;

LDH A, [$FF90]                                              ;VRAM low
CALL TranferByteToBuffer_00_3886

BitB StripeImageCommand_Repeat                              ;check for repeat, again.
JR Z, CODE_00_3866

ResetBitB StripeImageCommand_Repeat
LD A, B
CALL TranferByteToBuffer_00_3886
LD A, [HL+]

LOOP_00_385E:
CALL TranferByteToBuffer_00_3886                            ;since buffer does not check for this bit, keep filling it with this byte.
DEC B                                                       ;
JR NZ, LOOP_00_385E                                         ;
JR CODE_00_3871                                             ;put a stop

CODE_00_3866:
LD A, B
CALL TranferByteToBuffer_00_3886

LOOP_00_386A:
LD A, [HL+]                                                 ;
CALL TranferByteToBuffer_00_3886                            ;put that into buffer
DEC B                                                       ;
JR NZ, LOOP_00_386A                                         ;

CODE_00_3871:
XOR A                                                       ;stop command
LD [DE], A                                                  ;

LD A, C                                                     ;update current count
LD [Buffer_DataCount], A                                    ;

XOR A                                                       ;zero this thing
LD [Buffer_WritingFlag], A                                  ;anti-under construction

POP BC                                                      ;
LDH A, [$FF8F]                                              ;
LD D, A                                                     ;

LDH A, [$FF90]                                              ;
ADD A, B                                                    ;add amount of bytes we just processed
LD E, A                                                     ;
RET NC                                                      ;return, potentially for more buffer writes

INC D                                                       ;
RET                                                         ;

TranferByteToVRAM_00_3886:
TranferByteToBuffer_00_3886:
LD [DE], A                                                  ;A into buffer
INC DE                                                      ;next buffer byte
INC C                                                       ;increase amount of data we're going to transfer...
RET                                                         ;

BufferedDraw_00_388A:
LD A, [Buffer_WritingFlag]                                  ;check if we're currently messing with buffer...
AND A                                                       ;
RET NZ                                                      ;go away if we are

LD HL, Buffer_Storage                                       ;

LOOP_00_3892:
LD A, [HL+]                                                 ;
AND A                                                       ;check if hit zero
JR NZ, CODE_00_389A                                         ;if not, keep reading from buffer
LD [Buffer_DataCount], A                                    ;set this to 0
RET                                                         ;

CODE_00_389A:
LD D, A                                                     ;D - VRAM pointer high

LD A, [HL+]                                                 ;
LD E, A                                                     ;E - VRAM pointer low

LD A, [HL+]
LD B, A                                                     ;B - amount of tiles to write

LOOP_00_389F:
LD A, [HL+]                                                 ;get tile
LD [DE], A                                                  ;write tile to VRAM.
INC DE                                                      ;next VRAM position
DEC B                                                       ;write until done...
JR NZ, LOOP_00_389F                                         ;

JR LOOP_00_3892                                             ;go back and check if need to do more writes

;used to load graphics...
CODE_00_38A7:
LD DE, $C1A3
LD C, $00

LOOP_00_38AC:
SetBankAndBackup 1

LD A, [HL]
LD B, A
LD A, [DE]
CP B
JR Z, CODE_00_38CB
LD A, B
SWAP A
AND $03
LD [MBC1Bank], A
LDH [CurrentProgramBank], A
LD A, B
LD [DE], A
AND $0F
LD B, A
CALL CODE_00_38E7

CODE_00_38CB:
INC DE
INC HL
INC C
LD A, $06
CP C                                                        ;check if done uploading all 6 chunks of graphics
JR NZ, LOOP_00_38AC

SetBankAndBackup 1
RET

;graphic chunk locations in VRAM
DATA_00_38DB:
dw $8000
dw $8080
dw $8800
dw $8880
dw $9000
dw $9080

;decompress graphics into RAM to be transported into VRAM later
CODE_00_38E7:
PUSH BC
PUSH DE
PUSH HL
PUSH BC

LD A, B
LD HL, POINTERS_02_4000                                     ;note: this can be either POINTERS_02_4000 or POINTERS_03_4000 depending on the current bank
RST $28

LD H, D
LD L, E
LD DE, GFXDecompressionBuffer
CALL CODE_00_3929

POP BC
LD A, C
LD HL, DATA_00_38DB
RST $28

LD HL, GFXDecompressionBuffer
LD B, $08

CODE_00_3903:
PUSH BC
LD B, $40
LD A, D
LDH [$FF8F], A
LD A, E
LDH [$FF90], A
CALL DrawStripeImage_00_380F
LD B, $40
LD A, D
LDH [$FF8F], A
LD A, E
LDH [$FF90], A
CALL DrawStripeImage_00_380F
LD A, E
ADD A, $80
LD E, A
JR NC, CODE_00_3921
INC D

CODE_00_3921:
POP BC
DEC B
JR NZ, CODE_00_3903
POP HL
POP DE
POP BC
RET

;used to transfer graphics I think...
CODE_00_3929:
LD A, [HL+]
LD C, A

CODE_00_392B:
LD A, [HL+]                                                 ;check if data matches the byte we stored in C...
CP C
JR Z, CODE_00_3933
LD [DE], A
INC DE
JR CODE_00_392B

CODE_00_3933:
LD A, [HL+]
AND A
RET Z                                                       ;check if it was 0

LD B, A
LD A, [HL+]

CODE_00_3938:
LD [DE], A
INC DE
DEC B
JR NZ, CODE_00_3938
JR CODE_00_392B

;counter addition. used for 4 byte counters.
;input:
;DE - counter RAM
;HL - data for amount to be substracted
AddTo4ByteCounter_00_393F:
PUSH DE
PUSH HL
AND A
LD B, $04

CODE_00_3944:
LD A, [DE]
ADC A, [HL]
DAA
LD [DE], A
DEC DE
DEC HL
DEC B
JR NZ, CODE_00_3944
JR NC, CODE_00_395A
INC DE
LD B, $04                                                   ;
LD A, $99                                                   ;all become 99

LOOP_00_3954:
LD [DE], A
INC DE
DEC B
JR NZ, LOOP_00_3954
SCF

CODE_00_395A:
POP HL
POP DE
RET

;counter substraction. used for 4 byte counters. timer is officially a 4 byte counter.
;input:
;DE - counter RAM
;HL - data for amount to be substracted
SubstractFrom4ByteCounter_00_395D:
PUSH DE
PUSH HL
AND A
LD B, $04                                                   ;amount of counter RAM

CODE_00_3962:
LD A, [DE]
SBC A, [HL]
DAA
LD [DE], A
DEC DE
DEC HL
DEC B
JR NZ, CODE_00_3962
JR NC, CODE_00_3977
INC DE
LD B, $04                                                   ;
XOR A                                                       ;all become 0

CODE_00_3971:
LD [DE], A
INC DE
DEC B
JR NZ, CODE_00_3971
SCF

CODE_00_3977:
POP HL
POP DE
RET

DATA_00_397A:
db $20,$03,$C0,$01,$08,$32,$60,$74
db $18,$01,$E0,$00,$10,$14,$20,$14
db $18,$01,$40,$01,$20,$28,$20,$74
db $18,$01,$40,$00,$08,$0A,$60,$14
db $28,$03,$20,$00,$20,$3C,$60,$74
db $08,$03,$20,$00

;unknown
db $00,$00,$00,$00

CODE_00_39AA:
LD A, [Player_State]
CP $0E
JP NZ, CODE_00_3A35

LD A, [FrameCounter]
AND $07
JR NZ, CODE_00_39BE

LD A, $17
CALL QueueSoundPrep_00_072B

CODE_00_39BE:
LD HL, $C1F6
INC [HL]
LD A, [HL]
AND $3F
RET NZ

BIT 7, [HL]
JR Z, CODE_00_39D0
CALL CODE_00_3A2A
JP CODE_00_3C35

CODE_00_39D0:
CALL DisableRender_00_3757
LD A, $10
CALL WaitForVBlank_372E
CALL CODE_00_3737

LD HL, $C210
LD BC, $00F0
CALL ClearRAM_00_37E0

LD HL, $C1F7

LD A, [HL+]
LD [$C633], A

LD A, [HL+]
LD [$C634], A

LD A, [HL+]
LD [$C631], A

LD A, [HL+]
LD [$C632], A

LD A, [HL+]
LD [$C201], A
LD A, [HL+]
LD [$C203], A

LD A, $02
LD [$C8F8], A
CALL CODE_00_04DE
XOR A
LD [$C8F8], A
CALL EnableLCDAndRender_00_3750

CODE_00_3A0E:
LD A, $01
CALL WaitForVBlank_372E

CALL CODE_00_0FE5
LD A, [FrameCounter]
AND $07
JR NZ, CODE_00_3A22
LD A, $17
CALL QueueSoundPrep_00_072B

CODE_00_3A22:
LD HL, $C1F6
INC [HL]
BIT 6, [HL]
JR NZ, CODE_00_3A0E


CODE_00_3A2A:
XOR A
LD [Player_State], A
LD [$CA08], A
LD [$C1F6], A
RET


CODE_00_3A35:
LD A, [$CA08]
AND A
RET Z

LD HL, DATA_00_397A
LD B, $06

CODE_00_3A3F:
LD C, $08
LD A, [HL]
SWAP A
AND $0F
LD D, A
LD A, [$C634]
CP D
JR NZ, CODE_00_3A59
LD A, [HL]
SWAP A
AND $F0
LD E, A
LD A, [$C633]
CP E
JR Z, CODE_00_3A60

CODE_00_3A59:
LD A, C
RST $18
DEC B
JR NZ, CODE_00_3A3F
AND A
RET


CODE_00_3A60:
DEC C
INC HL
LD A, [$C632]
CP [HL]
JR NZ, CODE_00_3A59
DEC C
INC HL
LD A, [$C631]
CP [HL]
JR NZ, CODE_00_3A59
DEC C
INC HL
LD A, [$C203]
BIT 0, [HL]
JR NZ, CODE_00_3A7F
CP $40
JR NC, CODE_00_3A59
JR CODE_00_3A83

CODE_00_3A7F:
CP $40
JR C, CODE_00_3A59

CODE_00_3A83:
LD A, $0E
LD [Player_State], A
LD DE, $C1F7
INC HL
LD A, B
CP $06
JR Z, CODE_00_3AA5
CP $01
JR Z, CODE_00_3AAF

CODE_00_3A95:
CALL CODE_00_3AC6
CALL CODE_00_3AC6
LD A, [HL+]
LD [DE], A
INC DE
LD A, [HL+]
LD [DE], A
XOR A
LD [$C1F6], A
RET

CODE_00_3AA5:
LD A, [$CA1D]
BIT 5, A
JR NZ, CODE_00_3A95
JP CODE_00_3A2A

CODE_00_3AAF:
LD A, [CurrentLand]
CP CurrentLand_DraculaDuckManor                             ;check if the mirror should bring you to the level select or not
JR Z, CODE_00_3ABD

LD A, $80
LD [$C1F6], A
AND A
RET

CODE_00_3ABD:
LD A, L
SUB $08
LD L, A
JR NC, CODE_00_3A95
DEC H
JR CODE_00_3A95

CODE_00_3AC6:
LD A, [HL]
SWAP A
AND $F0
LD [DE], A
INC DE
LD A, [HL+]
SWAP A
AND $0F
LD [DE], A
INC DE
RET

;used to display message
DisplayMessage_00_3AD5:
LD HL, Layout_MessageBox_00_3C3C
CALL ProcessStripeImage_00_3800

LD A, $02                                                   ;two frames
LD [MessageCharacterTimer], A

LD HL, CurrentMessageType
LD BC, $0028
CALL ClearRAM_00_37E0

LD A, [CurrentMessage]                                      ;message that will be displayed
AND $1F
DEC A                                                       ;0 doesn't count.
LD HL, LevelMessagePointers_00_3C78
RST $28

LD H, D                                                     ;
LD L, E                                                     ;
LD A, [HL+]                                                 ;
LD [CurrentMessageType], A                                  ;type of message

LD A, $9C                                                   ;message VRAM high byte
LD [MessageBuffer], A
LD [MessageLineBuffer], A

LD A, $A1                                                   ;message VRAM low byte
LD [MessageBuffer+1], A
LD [MessageLineBuffer+1], A

LD A, 1                                                     ;only upload one character at a time
LD [MessageBuffer+2], A

LD A, 18
LD [MessageLineBuffer+2], A                                 ;max message line width, to move the line and move on in the message

XOR A
LD [MessageBuffer+4], A                                     ;stop command
LD [MessageLineBuffer+21], A                                ;

LOOP_00_3B1A:
LD A, [MessageCharacterTimer]                               ;
LD D, A                                                     ;

LOOP_00_3B1E:
LD A, [FrameCounter]
AND $03
JR NZ, CODE_00_3B2A

LD A, $18
CALL QueueSoundPrep_00_072B

CODE_00_3B2A:
LD A, $01                                                   ;
CALL WaitForVBlank_372E                                     ;normal sync process
DEC D                                                       ;
JR NZ, LOOP_00_3B1E                                         ;a slight delay between each character

LD A, [HL+]                                                 ;next byte in our message
AND A                                                       ;check if got message end
JR Z, CODE_00_3BAC                                          ;
CP $FF                                                      ;check if got line break
JR Z, CODE_00_3B4F

CALL DrawMessageCharacter_00_3B3F
JR LOOP_00_3B1A

DrawMessageCharacter_00_3B3F:
LD [MessageBuffer+3], A                                     ;store message character to draw
PUSH HL

LD HL, MessageBuffer                                        ;buffer this character
CALL ProcessStripeImage_00_3800

POP HL                                                      ;
LD A, E                                                     ;next position in VRAM
LD [MessageBuffer+1], A
RET

CODE_00_3B4F:
LD A, [CurrentMessageType]                                  ;check if we're currently writing an ending message
BIT 7, A
JR Z, CODE_00_3B6A

LD A, [MessageBuffer+1]                                     ;next line
AND $E0                                                     ;
ADD A, $21                                                  ;
LD [MessageBuffer+1], A                                     ;

LD A, [MessageBuffer]                                       ;next line high byte
ADC A, $00                                                  ;
LD [MessageBuffer], A                                       ;

JR LOOP_00_3B1A

CODE_00_3B6A:
LD A, $C1
LD [$C1B1], A
LD A, [$C1AF]
INC A
LD [$C1AF], A
CP $02
JR C, CODE_00_3B8B
CALL CODE_00_075F
PUSH HL
LD HL, Layout_MessageBox_00_3C3C
CALL ProcessStripeImage_00_3800

LD HL, MessageLineBuffer
CALL ProcessStripeImage_00_3800
POP HL

CODE_00_3B8B:
PUSH HL
LD DE, MessageLineBuffer+3
LD B, $00

CODE_00_3B91:
LD A, [HL+]
AND A
JR Z, CODE_00_3B9E
CP $FF
JR Z, CODE_00_3B9E
LD [DE], A
INC DE
INC B
JR CODE_00_3B91

CODE_00_3B9E:
LD A, $6E
LD [DE], A
INC DE
INC B
LD A, B
CP $12
JR C, CODE_00_3B9E
POP HL
JP LOOP_00_3B1A

CODE_00_3BAC:
LD A, [CurrentMessageType]
BIT 7, A                                                    ;check if we're currently displaying an ending message
RET NZ

LD A, $4A
CALL DrawMessageCharacter_00_3B3F
CALL CODE_00_075F
BIT LOG(JoypadInput_B<<16,2.0)>>16, A                       ;check if pressed B
JR NZ, CODE_00_3BC9                                         ;if that is the case, close message box as normal

LD A, [CurrentMessageType]
CP $01                                                      ;check if it's a statue asking for money
JR Z, CODE_00_3BEB
CP $02                                                      ;check if it's Launchpad asking for a lift to Duckburg
JR Z, CODE_00_3C25

CODE_00_3BC9:
LD HL, Layout_MessageBox_00_3C3C
CALL ProcessStripeImage_00_3800

LD HL, CurrentMessage                                       ;check if we're displaying message...
LD A, [HL]
CP $04                                                      ;"find key in transylvania"
LD [HL], $00
JR Z, CODE_00_3BDB

AND A
RET

CODE_00_3BDB:
LD A, [$CA1D]
SET 5, A
LD [$CA1D], A

LD A, $01                                                   ;transport us into a magical land of Transylvania
LD [CurrentLand], A                                         ;
JP CODE_00_0257

CODE_00_3BEB:
LD A, [MoneyCurrent]                                        ;check if we have millions
AND A                                                       ;
JR NZ, CODE_00_3BF8                                         ;we definitely have at least 300000 dollary doos

LD A, [MoneyCurrent+1]                                      ;statue check for 300000 currency
CP $30                                                      ;
JR C, CODE_00_3BC9                                          ;nothing happens if less

CODE_00_3BF8:
LD DE, MoneyCurrent+3
LD HL, StatuePayValue_00_077D+3
CALL SubstractFrom4ByteCounter_00_395D                      ;decrease counter

LD A, $20                                                   ;I am guessing this is for generating rope tiles after paying
LDH [$FF8D], A

LD A, $40
LDH [$FF8E], A

LD A, $D2
CALL CODE_00_0C81

LD A, $20
LDH [$FF8D], A

LD A, $50
LDH [$FF8E], A

LD A, $D3
CALL CODE_00_0C81

LD A, [$CA1D]
SET 6, A
LD [$CA1D], A
JR CODE_00_3BC9

CODE_00_3C25:
LD HL, Layout_MessageBox_00_3C3C
CALL ProcessStripeImage_00_3800

CALL CODE_00_23CF
SET 7, [HL]

LD A, $FF
LD [$C627], A

CODE_00_3C35:
LD A, $01                                                   ;go to level select
LD [GameMode], A
SCF
RET

;clear status bar, it's now a dialogue box
Layout_MessageBox_00_3C3C:
db $9C,$80
db 20
db $4D,$4E,$4E,$4E,$4E
db " MESSAGE "
db $4E,$4E,$4E,$4E,$4E,$4F

db $9C,$A0
db 1
db $68

db $9C,$A1
db 18|StripeImageCommand_Repeat
db $6E

db $9C,$B3
db 1
db $78

db $9C,$C0
db 1
db $68

db $9C,$C1
db 18|StripeImageCommand_Repeat
db $6E

db $9C,$D3
db 1
db $78

db $9C,$E0
db 1
db $5D

db $9C,$E1
db 18|StripeImageCommand_Repeat 
db $5E

db $9C,$F3
db 1
db $5F

db StripeImageWriteCommand_Stop

include "Data/MessageLoader.asm"
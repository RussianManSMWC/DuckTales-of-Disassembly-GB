;A disassembly of Duck Tales for the Game Boy
;PRG ROM $0000-$3FFF

;used to execute code pointers right after the jump
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

;used to execute a code pointer after this call, and after that jump to address stored in DE
;input:
;A - pointer to execute
;DE - destination after executing code pointer
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

;used to get a pointer
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

include "Header.asm"

include "Defines/CharacterSet.asm"

SECTION "Main", ROM0 [$150]
RESET_00_0150:
DI                                                          ;disable interrupt
CALL DisableLCD_00_3737                                     ;

LD SP, Stack                                                ;

CALL StoreOAMUploadCodeToRAM_00_3796                        ;

LD HL, $C000                                                ;clear some WRAM
LD BC, $1FF0                                                ;
CALL ClearRAM_00_37E0                                       ;

LD HL, $FF8A                                                ;clear some HRAM
LD BC, $0075                                                ;
CALL ClearRAM_00_37E0                                       ;

CALL ClearTilemap_00_37E8

CALL Call_InitializeSoundRegisters_00_0183                  ;

LDH [Reg_BackgroundPalette], A                              ;init palettes
LDH [Reg_SpritePalette0], A                                 ;
LDH [Reg_SpritePalette1], A                                 ;

LD A, Interrupt_VBlank
LDH [Reg_InterruptsEnabler], A

CALL EnableLCDAndRender_00_3750
EI
JP CODE_00_0257

Call_InitializeSoundRegisters_00_0183:
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
BitTest LCDControlEnable, A                                 ;
JR Z, CODE_00_020F                                          ;skip buffer stuff

CALL OAMUploadCode                                          ;upload OAM
CALL BufferedDraw_00_388A                                   ;draw from the buffer

LD A, [$C1A9]                                               ;enable status bar?
AND A
JR Z, CODE_00_01C0

LDH A, [Reg_LCDControlAndRender]
OR LCDBackgroundTilemapSelect
LDH [Reg_LCDControlAndRender], A

LD A, LCDStatus_LCDYCheck
LDH [Reg_LCDStatus], A

LD A, $1F                                                   ;horizontal line where status bar ends
LDH [Reg_LCDYCompare], A

LDH A, [Reg_InterruptsEnabler]
OR Interrupt_HBlank                                         ;enable horizontal blank
LDH [Reg_InterruptsEnabler], A
EI                                                          ;enable interrupts

CODE_00_01C0:
XOR A
LDH [Reg_CameraXPosition], A

LD A, [CurrentMessage]                                      ;check if we're displaying a message
AND A                                                       ;
JR Z, CODE_00_01CB                                          ;

LD A, $20                                                   ;move camera to the message box (it's drawn below status bar to give an illusion of it replacing the status bar. clever!

CODE_00_01CB:
LDH [Reg_CameraYPosition], A                                ;

LD A, [$C631]
LD [CameraPositionX], A

LD A, [$C633]
LD [CameraPositionY], A

LD A, [ScreenShakeTimer]                                    ;check if screen shaking is enabled
AND A                                                       ;
JR Z, CODE_00_020F                                          ;

LD A, [FrameCounter]
BIT 3, A
JR Z, CODE_00_020F

LD HL, CurrentLand                                          ;check if we are in... Amazon, African Mines or Moon.
BIT 0, [HL]
JR NZ, CODE_00_01F4

LD A, $75                                                   ;this will adjust the camera position to make it seem like the screen is shaking
LD [CameraPositionY], A                                     ;
JR CODE_00_0204                                             ;

CODE_00_01F4:
BIT 2, A                                                    ;check if in Moon...?
JR NZ, CODE_00_01FF

LD A, $DC
LD [CameraPositionX], A
JR CODE_00_0204

CODE_00_01FF:
LD A, $E4
LD [CameraPositionX], A

CODE_00_0204:
LD A, [FrameCounter]                                        ;
AND $07                                                     ;
JR NZ, CODE_00_020F                                         ;

LD A, SFX_Quake                                             ;
LDH [SFXQueue], A                                           ;

CODE_00_020F:
CALL ReadJoypadInputs_00_3765

;japan exclusive code!
if Version == VERSION_JP
  LDH A, [JoypadInputHolding]                               ;check if holding...
  BitTest JoypadInput_Select, A                             ;select
  JR Z, CODE_JP_00_0228                                     ;move on if not
  
  LDH A, [JoypadInputPress]                                 ;check if pressed...
  BitTest JoypadInput_Start, A                              ;start
  JR Z, CODE_JP_00_0228                                     ;move on if not
  
  LDH A, [Reg_LCDControlAndRender]                          ;make sure render is enabled
  BitTest LCDControlEnable, A                               ;
  CALL Z, EnableLCDAndRender_00_3750                        ;

  JP RESET_00_0150                                          ;RESET

CODE_JP_00_0228:
endc

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
PUSH AF                                                     ;
LDH A, [Reg_LCDStatus]                                      ;
BitTest LCDStatus_LCDYEqualCheck, A                         ;checks if hit speicific horizontal line
JR Z, CODE_0255                                             ;nothing happens if haven't

LDH A, [Reg_InterruptsEnabler]                              ;
AND ~Interrupt_HBlank                                       ;disable h-blank
LDH [Reg_InterruptsEnabler], A                              ;

LD A, [CameraPositionY]                                     ;
SUB $10                                                     ;render level
LDH [Reg_CameraYPosition], A                                ;

LD A, [CameraPositionX]                                     ;
LDH [Reg_CameraXPosition], A                                ;

LDH A, [Reg_LCDControlAndRender]                            ;
AND ~LCDBackgroundTilemapSelect                             ;finished rendering status bar, render the background from now on
LDH [Reg_LCDControlAndRender], A                            ;

CODE_0255:
POP AF                                                      ;
RETI                                                        ;

;transition into game mode
CODE_00_0257:
LD SP, Stack                                                ;
CALL DisableLCD_00_3737                                     ;
CALL ClearTilemap_00_37E8                                   ;

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

if Version == VERSION_JP
  include "Data/SpecialScreenGraphicBankConfigurations.asm" ;graphic bank configurations are moved to bank 0 in japanese version
endc

;title screen
TitleScreenCode_00_0272:
LD DE, POINTERS_02_4000+(0*2)
CALL ProcessStripeImageFromBank2_00_032A                    ;draw title screen

LD HL, TitleScreenGraphicBanks_01_7A97                      ;load title screen graphics
CALL LoadAllGraphics_00_38A7

CALL TitleScreenInit_01_7C5F

if Version != VERSION_JP
  LD A, $00
  LD [FrameCounter], A
endc

LOOP_00_0286:
if Version == VERSION_JP
  ;japanese version essentially undoes the ExecuteTitleScreenCode_00_029F call, since it realistically is only needed once (no frame counter check helps)
  CALL WaitFrame_00_075A
  CALL CODE_00_0FE5

  SetProgramBank1
  CALL DisplayCursorSprite_01_7DFF                          ;the priority has the cursor display at the wrong position for a single frame

  LD HL, TitleScreen_CursorData_00_0299
  LD A, [SelectedDifficulty]
  CALL HandleCursorPrep_00_0789                             ;handle changing between difficulty options
  LD [SelectedDifficulty], A
  JR NC, LOOP_00_0286
else
  CALL ExecuteTitleScreenCode_00_029F

  LD A, [FrameCounter]
  CP 64                                                     ;wait for 64 frames before the game can be started
  JR C, LOOP_00_0286

LOOP_00_0290:
  CALL ExecuteTitleScreenCode_00_029F
  JR NC, LOOP_00_0290                                       ;check if pressed start
endc

SetProgramBank1                                             ;
JP StartGameFromTitleScreen_01_7C87                         ;will change game mode to land select and a few other prep things

;cursor data for the title screen.
;first byte - amount of options on a single column
;second byte - amount of columns. note that the game does not have programming for handling multiple columns of options, rendering this useless.
;then follows option X and Y position arrays. must be the same amount as respective options/columns
TitleScreen_CursorData_00_0299:
db $03,$00                                                  ;example: 3 options on a single column
db $28                                                      ;since there's only 1 column, the x-position is consistent

if Version == VERSION_EU
  db $50,$58,$60                                            ;european version lowers cursor's y-position to match lowered difficulty string positions
else
  db $40,$48,$50                                            ;three different y-positions based on cursor selection
endc

;title screen code
if Version != VERSION_JP
ExecuteTitleScreenCode_00_029F:
  CALL WaitFrame_00_075A
  CALL CODE_00_0FE5

  SetProgramBank1
  CALL DisplayCursorSprite_01_7DFF                          ;the priority has the cursor display at the wrong position for a single frame

  LD HL, TitleScreen_CursorData_00_0299
  LD A, [SelectedDifficulty]
  CALL HandleCursorPrep_00_0789                             ;handle changing between difficulty options
  LD [SelectedDifficulty], A
  RET
endc

CODE_00_02B6:
LD HL, LandSelectGraphicBanks_01_7A9D
CALL LoadAllGraphics_00_38A7

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

if Version != VERSION_JP
  LD A, $00                                                 ;??? A is already 0!
  LD [FrameCounter], A
endc

LOOP_00_02E7:
;same deal as with title screen, replace CALL with its code
if Version == VERSION_JP
  CALL WaitFrame_00_075A

  SetProgramBank1
  CALL CODE_01_7DD0
  CALL DisplayCursorSprite_01_7DFF

  LD HL, DATA_00_030A
  LD A, [CurrentLand]
  CALL HandleCursorPrep_00_0789

  LD HL, CurrentLand
  LD [HL+], A
  JR NC, LOOP_00_02E7
else
  CALL ExecuteLandSelectCode_00_0312

  LD A, [FrameCounter]
  CP 64
  JR C, LOOP_00_02E7

LOOP_00_02F1:
  CALL ExecuteLandSelectCode_00_0312
  JR NC, LOOP_00_02F1
endc


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

if Version != VERSION_JP
ExecuteLandSelectCode_00_0312:
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
endc

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

LD A, [CurrentLand]                                         ;current land
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
CALL WaitForVBlank_00_372E                                  ;

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

CALL WaitForAOrBPress_00_075F

LD A, CurrentLand_DraculaDuckManor                          ;get sent to transylvania for a third time
LD [CurrentLand], A
JP CODE_00_02F6

PlayMoneyCountingSFX_00_03C4:
LD A, [FrameCounter]                                        ;
AND $03                                                     ;
RET NZ                                                      ;play SFX every 4th frame

LD A, SFX_ItemCollect                                       ;
CALL QueueSoundPrep_00_072B                                 ;
RET                                                         ;

CODE_00_03D0:
SetProgramBank1
PUSH DE
CALL DisableRender_00_3757
CALL DisableLCD_00_3737
POP DE
LD BC, $0240
JP CODE_01_7C42

CODE_00_03DF:
LD B, $80
CALL CODE_00_0455
CALL DisableLCD_00_3737
CALL SetProgramBank2_00_0337

LD BC, $0D02
CALL LoadGraphics_00_38E7

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

LD A, [$C201]                                               ;if the player accidently fell off or climbed down offscreen during the final race...
CP $98                                                      ;
JR NC, CODE_00_0438                                         ;fail said race

JR CODE_00_040E

CODE_00_0428:
XOR A                                                       ;
LDH [CurrentMusic], A                                       ;

LD A, SFX_ItemJingle                                        ;win!
CALL QueueSoundPrep_00_072B                                 ;

LD A, 240                                                   ;wait a while before transition
CALL WaitForVBlank_00_372E                                  ;
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

CALL PlayerStateCode_DeadOrHurt_00_16D4

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
LD HL, DATA_03_4030                                         ;something else that's compressed in the same way as graphics
LD DE, $CE1F
CALL DecompressionAlgorithm_00_3929

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
CALL Z, LoadAllGraphics_00_38A7

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
CP CurrentLand_Moon
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
CALL DrawChestScreenFloor_JMP_03_402D

LD HL, EndingChestGraphicBanks_01_7AA3
CALL LoadAllGraphics_00_38A7

CALL EnableLCDAndRender_00_3750
CALL CODE_01_7D46

LD D, $6E
CALL CODE_00_03D0
CALL CODE_00_05F7

LD A, $E1
LDH [Reg_BackgroundPalette], A

LD HL, EndingDuckPressGraphcBanks_01_7AA9
CALL LoadAllGraphics_00_38A7

LD DE, POINTERS_02_4000+(17*2)
CALL ProcessStripeImageFromBank2_00_032A

CALL EnableLCDAndRender_00_3750
CALL CODE_01_7D84
CALL WaitForAOrBPress_00_075F

LD D, $6E
CALL CODE_00_03D0
CALL CODE_00_05F7

XOR A
LD [CurrentOAMSlot], A

LD A, $E4
LDH [Reg_BackgroundPalette], A

if Version == VERSION_JP
  LD HL, EndingCharacterPortraitGraphicBanksNephews_JP_00_02A0
else
  LD HL, EndingCharacterPortraitGraphicBanks_01_7AAF
endc
CALL LoadAllGraphics_00_38A7

CALL EnableLCDAndRender_00_3750

LD DE, POINTERS_03_4000+(17*2)
CALL ProcessStripeImageFromBank3_00_033F

LD A, $10
CALL WaitForVBlank_00_372E

CALL CODE_01_7DBA

XOR A
CALL CODE_00_05FF
CALL WaitForAOrBPress_00_075F

LD HL, Buffer_DataCount
LD BC, $0103
CALL ClearRAM_00_37E0

LD D, $6E
CALL CODE_00_03D0
CALL CODE_00_05F7

LD HL, EndingCharacterPortraitGraphicBanks_01_7AAF
CALL LoadAllGraphics_00_38A7
CALL EnableLCDAndRender_00_3750

LD A, $10
CALL WaitForVBlank_00_372E

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
CALL LoadEndingMessage_JMP_03_402A                          ;
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
LD [ScreenShakeTimer], A

LD A, [PlayerHealthMax]
LD [PlayerHealth], A

LD HL, DATA_00_061C
LD DE, $CA0E
LD BC, $0004
CALL TransferData_00_37F7

LOOP_00_0686:
LD A, $01                                                   ;
CALL WaitForVBlank_00_372E                                  ;

LD HL, PauseFlag                                            ;
LDH A, [JoypadInputPress]                                   ;
BitTest JoypadInput_Start, A                                ;check if player pressed start
JR Z, CODE_00_069D                                          ;

LD A, [HL]                                                  ;
XOR $01                                                     ;flip paused status
LD [HL], A                                                  ;

LD A, SFX_ItemCollect                                       ;pause SFX
CALL QueueSoundPrep_00_072B                                 ;

CODE_00_069D:
BIT 0, [HL]                                                 ;check if game is paused
JR NZ, LOOP_00_0686                                         ;wait until player unpauses it

LDH A, [JoypadInputPress]                                   ;check if pressed select
BitTest JoypadInput_Select, A                               ;
JR Z, CODE_00_06BD                                          ;

LD A, [MoneyTotal]                                          ;
CP $03                                                      ;check if have 3 millions
JR C, CODE_00_06BD                                          ;

LD DE, MoneyTotal+3                                         ;
LD HL, HealthRefillValue_00_0785+3                          ;
CALL SubstractFrom4ByteCounter_00_395D                      ;pay 3 million dollars

LD A, [PlayerHealthMax]                                     ;restore player's health.
LD [PlayerHealth], A                                        ;

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

LD A, 160
CALL WaitForVBlank_00_372E
JP CODE_00_0257

CODE_00_06DE:
CALL CODE_00_39AA
JP C, CODE_00_0257

LD A, [CurrentMessage]                                      ;check if we should display a message
AND A
CALL NZ, CODE_00_06EE

JP LOOP_00_0686

CODE_00_06EE:
SetProgramBank1
CALL CODE_01_7E6E
CALL CODE_00_0FE5
CALL SetProgramBank2_00_0337

LD BC, $0903
CALL LoadGraphics_00_38E7

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
CALL LoadGraphics_00_38E7

XOR A
LD [Player_State], A

SetProgramBank1
CALL CODE_01_7E94
RET

SetLevelMusicPrep_00_0725:
CALL SetProgramBank2_00_0337
JP SetLevelMusic_JMP_02_4026

;input A - sound effect or music to queue.
QueueSoundPrep_00_072B:
PUSH HL                                                     ;
PUSH BC                                                     ;
LD B, A                                                     ;input A move into B for the subroutine

LDH A, [CurrentProgramBank]                                 ;save bank
PUSH AF                                                     ;

SetBankAndBackup 2                                          ;
CALL QueueSound_JMP_02_4032                                 ;

POP AF                                                      ;
LD [MBC1Bank], A                                            ;restore bank
LDH [CurrentProgramBank], A                                 ;

POP BC                                                      ;
POP HL                                                      ;
RET                                                         ;

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
JP WaitForVBlank_00_372E

;Wait until A or B had been pressed. Used for message box, ending
WaitForAOrBPress_00_075F:
CALL WaitFrame_00_075A                                      ;vblank wait

LDH A, [JoypadInputPress]                                   ;
AND JoypadInput_A|JoypadInput_B                             ;
JR Z, WaitForAOrBPress_00_075F                              ;loop until either button is pressed
RET                                                         ;

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
CALL DecompressionAlgorithm_00_3929
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

LOOP_00_08C6:
LD A, [HL]
LD [DE], A
INC DE
LD A, $0A
RST $18
DEC B
JR NZ, LOOP_00_08C6

CALL CODE_00_0EB4

LD HL, $C8D0
LD DE, $C8D8
LD B, $08

LOOP_00_08DA:
CALL CODE_00_0877
INC HL
DEC B
JR NZ, LOOP_00_08DA

LDH A, [VRAMPointer]
LD D, A
LDH A, [VRAMPointer+1]
LD E, A

LD HL, $C8D0
LD B, $08

LOOP_00_08EC:
CALL CODE_00_0956
INC HL
LD A, E
ADD A, $40
LD E, A
JR NC, CODE_00_08F7
INC D

CODE_00_08F7:
DEC B
JR NZ, LOOP_00_08EC

LD HL, $C8D8
LD B, $10

CODE_00_08FF:
PUSH BC
LD B, $02
CALL DrawStripeImage_00_380F

LDH A, [VRAMPointer+1]
ADD A, $20
LDH [VRAMPointer+1], A
JR NC, CODE_00_0912

LDH A, [VRAMPointer]
INC A
LDH [VRAMPointer], A

CODE_00_0912:
POP BC
DEC B
JR NZ, CODE_00_08FF
POP HL
POP DE
POP BC
RET

DATA_00_091A:
db $00,$00,$00,$00,$01,$01,$01,$01
db $02

;unknown
db $02

db $03,$03,$04,$09,$05,$07

DATA_00_092A:
db $00,$00
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
LD HL, DATA_00_091A
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
LD HL, DATA_00_092A
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
LD A, [CurrentEntityRAMOffset]
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
LD A, [CurrentEntityRAMOffset]
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

DATA_00_0B35:
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
LD A, [CurrentEntityRAMOffset]
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
LD A, [CurrentEntityRAMOffset]
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
LD A, [CurrentEntityRAMOffset]
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
LD A, [CurrentEntityRAMOffset]
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
LD A, [CurrentEntityRAMOffset]
AND A
JP NZ, CODE_00_0B32
LD A, $01
LD [TileDetectionArray+255], A
RET

CODE_00_0BBD:
LD A, [CurrentEntityRAMOffset]
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
LD A, [CurrentEntityRAMOffset]
AND A
JR NZ, CODE_00_0BEC
INC A
LD [$CA01], A

CODE_00_0BEC:
XOR A
RET

CODE_00_0BEE:
LD A, [CurrentEntityRAMOffset]
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
LD HL, DATA_00_0B35
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
LDH A, [VRAMPointer]
LD D, A
LDH A, [VRAMPointer+1]
LD E, A

CALL CODE_00_0956

LD HL, $FF9C
LD DE, $FF9E
CALL CODE_00_0877

LD HL, $FF9E
LD C, $02

LOOP_00_0CAE:
PUSH BC
LD B, $02
CALL DrawStripeImage_00_380F

LDH A, [VRAMPointer+1]
ADD A, $20
LDH [VRAMPointer+1], A
JR NC, CODE_00_0CC1

LDH A, [VRAMPointer]
INC A
LDH [VRAMPointer], A

CODE_00_0CC1:
POP BC
DEC C
JR NZ, LOOP_00_0CAE
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
LD A, [CurrentEntityRAMOffset]
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
JR NZ, LOOP_00_0DBF
SRL A
SRL A
SRL A
SRL A

LOOP_00_0DBF:
SRL A
DEC B
JR NZ, LOOP_00_0DBF

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

LD BC, $FF80

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

DATA_00_0EA9:
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
LD HL, DATA_00_0EA9
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

;copy variables from $C2X0-$C2YF into $C600-C61F
GetCurrentEntityVariables_00_0F92:
LD HL, $C200
LD BC, $C600
LD A, [CurrentEntityRAMOffset]

LD D, A
LD L, A
CALL CODE_00_0FB4

LD L, D
INC H                                                       ;next 16 bytes
JR CODE_00_0FB4

StoreCurrentEntityVariables_00_0FA4:
LD HL, $C600                                                ;current entity RAM
LD BC, $C200                                                ;specific entity RAM
LD A, [CurrentEntityRAMOffset]
LD D, A
LD C, A
CALL CODE_00_0FB4

LD C, D                                                     ;restore low byte
INC B                                                       ;increment high byte (so, store to $C300 instead)

;unrolled storage
CODE_00_0FB4:
REPT 16
  LD A, [HL+]                                               ;store 16 variables from one area of RAM to another
  LD [BC], A                                                ;
  INC C                                                     ;
ENDR
RET

CODE_00_0FE5:
XOR A
LD [CurrentEntityRAMOffset], A
LD [CurrentOAMSlot], A

SetBankAndBackup 1

LOOP_00_0FF3:
LD HL, $C200
LD A, [CurrentEntityRAMOffset]
OR L
LD L, A

LD A, [HL]
AND $7F
JR Z, CODE_00_1023
LD E, A
CALL GetCurrentEntityVariables_00_0F92

LD A, E
ExecutePointersWithDestination CODE_00_1011

dw CODE_00_1033                                             ;unused pointer (clear all OAM)
dw CODE_00_118A                                             ;player code I think
dw CODE_00_1A28                                             ;other level entities
dw CODE_00_104D                                             ;runs scrooge's blinking eye code at the title screen

CODE_00_1011:
CALL CODE_00_10B6

LD A, [CurrentEntityRAMOffset]
AND A
CALL NZ, StoreCurrentEntityVariables_00_0FA4

LD A, [$C600]
BIT 7, A                                                    ;check if bit 7 is clear, can display graphics
CALL Z, CODE_01_7EA0

CODE_00_1023:
LD A, [$C8F8]
BIT 1, A
JR NZ, CODE_00_1033

LD HL, CurrentEntityRAMOffset
LD A, [HL]
ADD A, $10                                                  ;next entity's set of data
LD [HL], A
JR NC, LOOP_00_0FF3                                         ;

CODE_00_1033:
LD HL, OAM_Y

LD A, [CurrentOAMSlot]
ADD A, L                                                    ;L is zero (low byte), so....... not sure what this is for
LD L, A

LOOP_00_103B:
CP $A0                                                      ;loop until stored to all OAM tiles
RET NC

LD [HL], $00                                                ;off this OAM tile

ADD A, $04                                                  ;next OAM slot
LD L, A                                                     ;
JR LOOP_00_103B                                             ;

;tilemap for scrooge's eye at the title screen
;first byte is property, second is tile
DATA_00_1045:
db $00,$A6,$00,$B6
db $00,$A5,$00,$B5

CODE_00_104D:
XOR A                                                       ;default eye frame
LD [$C605], A

LD A, [FrameCounter]
CP $10
RET NC

LD A, $01                                                   ;wink
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

LD A, [CurrentEntityRAMOffset]
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

JP InitializeEntityVariables_00_36D8

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
CP Player_State_Climbing
JR NZ, CODE_00_114E

LD A, [$C201]
CP $20
LD D, $01
JR C, CODE_00_1155
JR CODE_00_114E

CODE_00_111F:
LD B, Player_State_FallingOrGrounded
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
CP Player_State_Dead
JP Z, PlayerStateCode_DeadOrHurt_00_16D4

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

LD A, SFX_Damage                                            ;
CALL QueueSoundPrep_00_072B                                 ;yikes!

LD A, Player_State_Damage                                   ;
LD [Player_State], A                                        ;scrooge got damaged. he will seek legal action against you

CODE_00_11D5:
LD A, $80
LD [$DF54], A

CALL CODE_00_1417
LD [Player_PogoFlag], A
LD [$CA00], A

LD HL, PlayerHealth                                         ;
DEC [HL]                                                    ;minus health

LD A, [SelectedDifficulty]                                  ;check if difficulty is EZ
AND A                                                       ;
JR Z, CODE_00_11EE                                          ;

DEC [HL]                                                    ;double damage (so every sphere is one hitpoint instead of two)

CODE_00_11EE:
LD A, [HL]                                                  ;check if zero health
AND A                                                       ;
RET NZ                                                      ;

POP HL                                                      ;oops.
JP PlayerStateCode_DeadOrHurt_00_16D4                       ;

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
CP Player_State_Ducking
JR Z, CODE_00_1217

XOR A
LD [$DF63], A
LD [$DF64], A

LD A, [Player_State]

CODE_00_1217:
ExecutePointersWithDestination CODE_00_123D

;player states!
dw PlayerStateCode_FallingOrGrounded_00_12C3
dw PlayerStateCode_Rising_00_17AE
dw PlayerStateCode_Pogo_00_17ED
dw PlayerStateCode_Climbing_00_189C
dw PlayerStateCode_ReadyCane_00_148D
dw PlayerStateCode_Ducking_00_1747
dw PlayerStateCode_Damage_00_1783
dw PlayerStateCode_Stuck_00_1725
dw PlayerStateCode_DeadOrHurt_00_16D4                       ;unused pointer (dead state skips some of the prior code to jump to this code)
dw PlayerStateCode_StuckEntity_00_1763
dw PlayerStateCode_ClimbingEntity_00_15E1
dw PlayerStateCode_MineCart_00_162E
dw PlayerStateCode_OnSpritePlatform_00_168B
dw PlayerStateCode_EnteringBossArena_00_159B
dw PlayerStateCode_Teleporting_00_16C3
dw PlayerStateCode_Message_00_15D5
dw PlayerStateCode_PickedRaceTreasure_00_123D

PlayerStateCode_PickedRaceTreasure_00_123D:
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

PlayerStateCode_FallingOrGrounded_00_12C3:
LDH A, [JoypadInputHolding]                                 ;
BitTest JoypadInput_Right, A                                ;check if holding right
JR Z, CODE_00_12D0

CALL CODE_00_125F

XOR A                                                       ;x-flip?
LD [$C208], A

CODE_00_12D0:
LDH A, [JoypadInputHolding]                                 ;
BitTest JoypadInput_Left, A                                 ;check if holding left
JR Z, CODE_00_12DE

CALL CODE_00_126B

LD A, OAMProp_XFlip                                         ;this has to be x-flip
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
BitTest JoypadInput_Up, A                                   ;
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

LD A, Player_State_Climbing
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
JP NZ, PlayerStateCode_DeadOrHurt_00_16D4

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

LD A, [Player_State]                                        ;check if player is currently ducking
CP Player_State_Ducking
RET Z

LD A, [$DF54]
CP $68
RET NC

LD A, [Player_PogoFlag]                                     ;
AND A                                                       ;
JR Z, CODE_00_138C                                          ;check if player is doing pogo

LD A, [$CA02]
AND A
JR Z, CODE_00_136B

LD A, SFX_PogoBounce                                        ;bounce on solid ground
CALL QueueSoundPrep_00_072B                                 ;

CODE_00_136B:
LD A, [TileDetectionArray+254]
AND A
JR Z, CODE_00_1377

LD A, Player_State_Stuck                                    ;sucked into snow
LD [Player_State], A                                        ;
RET                                                         ;

CODE_00_1377:
LDH A, [JoypadInputHolding]                                 ;holding B?
BitTest JoypadInput_B, A                                    ;
JR Z, CODE_00_1388

LD A, Player_State_Pogo                                     ;
LD [Player_State], A                                        ;

CALL CODE_00_1417
JP PlayerStateCode_Pogo_00_17ED

CODE_00_1388:
XOR A
LD [Player_PogoFlag], A

CODE_00_138C:
LD A, Player_AnimationFrame_Standstill                      ;can XOR A instead.
LD [Player_AnimationFrame], A                               ;

LDH A, [JoypadInputHolding]
AND JoypadInput_Right|JoypadInput_Left
JR Z, CODE_00_13A0

LD BC, $DF53
LD HL, PlayerAnimationTable_Walking_00_199A                ;
CALL AnimatePlayer_00_1979

CODE_00_13A0:
LD A, [$DF5B]
AND A
JR Z, CODE_00_13B4

XOR A
LD [$DF5B], A

LD A, SFX_GroundLand                                        ;
CALL QueueSoundPrep_00_072B                                 ;

LD A, $01
LD [$DF5C], A

CODE_00_13B4:
LD A, [$DF5C]
AND A
JR Z, CODE_00_13C5
LD BC, $DF5C
LD HL, PlayerAnimationTable_Duck_00_19AB
CALL AnimatePlayer_00_1979
JR CODE_00_13C9

CODE_00_13C5:
XOR A
LD [$DF5B], A

CODE_00_13C9:
LD A, [$DF5E]
AND A
JP NZ, PlayerStateCode_ReadyCane_00_148D

LD A, [$CA07]
AND A
JR Z, CODE_00_13E4

LD A, $01
LD [$DF5F], A

LD A, Player_State_ReadyCane
LD [Player_State], A

XOR A
LD [$CA07], A

CODE_00_13E4:
LD A, [Player_State]
CP Player_State_OnSpritePlatform
JR Z, CODE_00_13FE

LDH A, [JoypadInputHolding]
BitTest JoypadInput_Down, A
JR Z, CODE_00_13FE

LD A, Player_State_Ducking
LD [Player_State], A

LD A, $01
LD [$DF5D], A
JP PlayerStateCode_Ducking_00_1747

CODE_00_13FE:
LDH A, [JoypadInputHolding]
BitTest JoypadInput_A, A
CALL Z, CODE_00_1417

LD A, [$DF59]
AND A
JR NZ, RETURN_00_1416

LDH A, [JoypadInputHolding]                                 ;
BitTest JoypadInput_A, A                                    ;check if player pressed A
JR Z, RETURN_00_1416                                        ;

LD A, Player_State_Rising
LD [Player_State], A                                        ;Juuuuuuuuuump!

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

LD A, Player_AnimationFrame_Airborn                         ;show airborn frame
LD [Player_AnimationFrame], A                               ;

LD A, $01
LD [$DF5B], A

LD A, [Player_PogoFlag]                                     ;check if using cane for pogo jump
AND A
JR Z, CODE_00_143B

LD A, Player_AnimationFrame_Pogo
LD [Player_AnimationFrame], A                               ;if using pogo, obviously show the pogo frame

CODE_00_143B:
LD A, [$DF5E]
AND A
JR NZ, CODE_00_144E                                         ;if player is currently holding against a solid object, will show ready cane frame instead

LDH A, [JoypadInputHolding]
BitTest JoypadInput_B, A                                    ;check if holding B in air
JR Z, CODE_00_1453

LD A, $01                                                   ;we're using pogo cane
LD [Player_PogoFlag], A                                     ;
JR CODE_00_1457

CODE_00_144E:
LD A, Player_AnimationFrame_ReadyCane1                      ;
LD [Player_AnimationFrame], A                               ;

CODE_00_1453:
XOR A                                                       ;
LD [Player_PogoFlag], A                                     ;NOT using pogo cane

CODE_00_1457:
LD A, [$DF54]
AND A
JR Z, CODE_00_1466
CP $68
JR C, CODE_00_1466

LD A, Player_AnimationFrame_Hurt
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

PlayerStateCode_ReadyCane_00_148D:
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
LD HL, PlayerAnimationTable_CaneReadyStart_00_19AF
CALL AnimatePlayer_00_1979
JR CODE_00_14FB

CODE_00_14C1:
LD A, $01
LD [$DF5E], A
XOR A
LD [$DF5F], A

CODE_00_14CA:
LD BC, $DF5F
LD HL, PlayerAnimationTable_CaneReadyLoop_00_19B4
CALL AnimatePlayer_00_1979
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
BitTest JoypadInput_B, A
JR Z, CODE_00_14FB

LD A, SFX_CaneHit
CALL QueueSoundPrep_00_072B

LD A, $02
LD [$DF5E], A

LD A, $01
LD [$DF5F], A
JR CODE_00_1515

CODE_00_14FB:
LDH A, [JoypadInputHolding]
BitTest JoypadInput_A, A

CALL Z, CODE_00_1417

LD A, [$DF59]
AND A
JR NZ, CODE_00_1513

LDH A, [JoypadInputHolding]
BitTest JoypadInput_A, A
JR Z, CODE_00_1513

LD A, Player_State_Rising
LD [Player_State], A

CODE_00_1513:
JR CODE_00_1576

CODE_00_1515:
LD A, [$DF5F]
AND A
JR Z, CODE_00_1526
LD BC, $DF5F
LD HL, PlayerAnimationTable_UsingCaneStart_00_19BA
CALL AnimatePlayer_00_1979
JR CODE_00_1576

CODE_00_1526:
LD A, [$CA05]
AND A
JR NZ, CODE_00_1538

LD A, $03
LD [$DF5E], A

LD A, SFX_CaneHitWrong
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
LD HL, PlayerAnimationTable_UsingCaneFail_00_19C6
CALL AnimatePlayer_00_1979
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
LD HL, PlayerAnimationTable_UsingCaneSuccess_00_19C0
CALL AnimatePlayer_00_1979
JR CODE_00_1576

CODE_00_156E:
LD A, $20
LD [$DF5E], A
JP CODE_00_158C


CODE_00_1576:
LDH A, [JoypadInputHolding]
BitTest JoypadInput_Right, A
JR Z, CODE_00_1580

LD A, $08
JR CODE_00_1588

CODE_00_1580:
LDH A, [JoypadInputHolding]
BitTest JoypadInput_Left, A
JR Z, CODE_00_158C

LD A, $04

CODE_00_1588:
CALL CODE_00_09FE
RET C

CODE_00_158C:
XOR A
LD [$DF5E], A

LD A, [Player_State]
CP Player_State_Rising
RET Z

CODE_00_1596:
XOR A                                                       ;Player_State_FallingOrGrounded
LD [Player_State], A                                        ;
RET

PlayerStateCode_EnteringBossArena_00_159B:
LD BC, $DF53
LD HL, PlayerAnimationTable_Walking_00_199A
CALL AnimatePlayer_00_1979

LD HL, $C203
LD E, [HL]
LD D, $03
LD A, [$C208]
AND $20
JR NZ, CODE_00_15B8                                         ;check which direction the player is walking

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
CALL CODE_00_0D5C                                           ;camera scroll I imagine
POP DE
POP HL
JR NC, CODE_00_15D0
JP CODE_00_10A4

CODE_00_15D0:
XOR A                                                       ;Player_State_FallingOrGrounded
LD [Player_State], A
RET

;player during message state
PlayerStateCode_Message_00_15D5:
LD A, Player_AnimationFrame_Standstill                      ;player will stand still even if airborn during message
LD [Player_AnimationFrame], A

LD A, [MessageQueue]                                        ;
LD [CurrentMessage], A                                      ;will display this message
RET                                                         ;

PlayerStateCode_ClimbingEntity_00_15E1:
LDH A, [JoypadInputPress]                                   ;
BitTest JoypadInput_A, A                                    ;check if pressed A while climbing
JR Z, CODE_00_15EC

XOR A                                                       ;Player_State_FallingOrGrounded
LD [Player_State], A                                        ;stop climbing, drop
RET                                                         ;

CODE_00_15EC:
LD B, $28
LD C, $0B
LD A, [$C208]
BIT 5, A
JR NZ, CODE_00_15F9
LD C, $02

CODE_00_15F9:
CALL CODE_00_1618

LD A, Player_AnimationFrame_Climbing1
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

PlayerStateCode_MineCart_00_162E:
LD A, [$C201]
CP $80
JR C, CODE_00_1638
JP PlayerStateCode_DeadOrHurt_00_16D4

CODE_00_1638:
LD B, $FE
LD C, $09
CALL CODE_00_1618

LD A, Player_AnimationFrame_InMinecart                      ;appear as in minecart
LD [Player_AnimationFrame], A                               ;

LD HL, $C305
CALL CODE_00_1612

LD A, [HL]
AND A
JR NZ, CODE_00_1660

LDH A, [JoypadInputPress]
BitTest JoypadInput_A, A
RET Z

CALL CODE_00_1612

XOR A                                                       ;Player_State_FallingOrGrounded
LD [Player_State], A                                        ;

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
BitTest JoypadInput_Down, A
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

PlayerStateCode_OnSpritePlatform_00_168B:
LDH A, [JoypadInputHolding]
AND ~JoypadInput_Down                                       ;check if holding anything but d-pad down
JR Z, CODE_00_169F
BitTest JoypadInput_A, A
JR Z, CODE_00_1699

LD HL, $C201
DEC [HL]

CODE_00_1699:
XOR A                                                       ;Player_State_FallingOrGrounded
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

LD A, Player_AnimationFrame_Standstill
LD [Player_AnimationFrame], A

CODE_00_16BB:
LD A, $01
LD [$DF65], A
JP PlayerStateCode_FallingOrGrounded_00_12C3

PlayerStateCode_Teleporting_00_16C3:
LD A, $01
LD [$C200], A

LD A, [FrameCounter]                                        ;flicker graphics every 4 frames
AND $04                                                     ;
RET Z                                                       ;

LD A, $81
LD [$C200], A
RET

PlayerStateCode_DeadOrHurt_00_16D4:
LD A, [Player_State]                                        ;
CP Player_State_Dead                                        ;
JR Z, CODE_00_1702                                          ;

LD A, Player_AnimationFrame_Hurt                            ;damage frame
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
LD A, Player_State_Dead                                     ;become dead
LD [Player_State], A                                        ;

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
CP $B0                                                      ;check if player fell to the bottom of the screen?
RET NZ

LD HL, $C627
SET 0, [HL]
RET

PlayerStateCode_Stuck_00_1725:
XOR A
LD B, A
CALL CODE_00_18F6

LD A, [TileDetectionArray+254]
AND A
JR Z, CODE_00_173C

LD A, Player_AnimationFrame_Stuck                           ;player gets stuck in snow
LD [Player_AnimationFrame], A                               ;

LDH A, [JoypadInputPress]                                   ;
BitTest JoypadInput_A, A                                    ;
RET Z                                                       ;

LD B, Player_State_Rising                                   ;jump out of snow

CODE_00_173C:
LD A, B
LD [Player_State], A

CALL CODE_00_1417
LD [Player_PogoFlag], A
RET

PlayerStateCode_Ducking_00_1747:
LD A, [$DF5D]
AND A
JR Z, CODE_00_1756

LD BC, $DF5D
LD HL, PlayerAnimationTable_DuckStart_00_19A8
CALL AnimatePlayer_00_1979

CODE_00_1756:
LDH A, [JoypadInputHolding]
BitTest JoypadInput_Down, A
JR NZ, CODE_00_1760

XOR A                                                       ;snap out of ducking state
LD [Player_State], A                                        ;

CODE_00_1760:
JP CODE_00_12DE

PlayerStateCode_StuckEntity_00_1763:
LD A, Player_AnimationFrame_Stuck                           ;
LD [Player_AnimationFrame], A                               ;

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

PlayerStateCode_Damage_00_1783:
LD A, [$DF54]
AND A
JR NZ, CODE_00_178E

XOR A                                                       ;Player_State_FallingOrGrounded
LD [Player_State], A                                        ;
RET                                                         ;

CODE_00_178E:
CP $68
JP C, PlayerStateCode_FallingOrGrounded_00_12C3

LD A, Player_AnimationFrame_Hurt
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

PlayerStateCode_Rising_00_17AE:
LD A, $08
LD [$DF57], A

LD A, Player_AnimationFrame_Airborn
LD [Player_AnimationFrame], A

LD A, [Player_PogoFlag]
AND A
JR Z, CODE_00_17C3

LD A, Player_AnimationFrame_Pogo
LD [Player_AnimationFrame], A

CODE_00_17C3:
LD A, [$DF5E]
AND A
JR Z, CODE_00_17CE

LD A, Player_AnimationFrame_ReadyCane1
LD [Player_AnimationFrame], A

CODE_00_17CE:
LD A, [$DF5E]
AND A
JR NZ, CODE_00_17E1

LDH A, [JoypadInputHolding]
BitTest JoypadInput_B, A
JR Z, CODE_00_17E1

LD A, $01
LD [Player_PogoFlag], A
JR CODE_00_17E5

CODE_00_17E1:
XOR A
LD [Player_PogoFlag], A

CODE_00_17E5:
LDH A, [JoypadInputHolding]
BitTest JoypadInput_A, A
JR NZ, CODE_00_1816

JR CODE_00_180E

PlayerStateCode_Pogo_00_17ED:
LD A, $10
LD [$DF57], A

LD A, Player_AnimationFrame_Pogo
LD [Player_AnimationFrame], A

LD A, [$DF56]
CP $0F
JR NC, CODE_00_1803

LD A, Player_AnimationFrame_PogoBounce
LD [Player_AnimationFrame], A

CODE_00_1803:
LDH A, [JoypadInputHolding]
BitTest JoypadInput_B, A
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
BitTest JoypadInput_Right, A
JR Z, CODE_00_1871

CALL CODE_00_1265
XOR A
LD [$C208], A

CODE_00_1871:
LDH A, [JoypadInputHolding]
BitTest JoypadInput_Left, A
JR Z, CODE_00_187F

CALL CODE_00_1271

LD A, $20
LD [$C208], A

CODE_00_187F:
LD HL, $DF55
INC [HL]
LD A, [$DF5E]
AND A
JP NZ, PlayerStateCode_ReadyCane_00_148D
RET

CODE_00_188B:
LD A, $03
LD [$DF56], A
LD HL, $C201
LD A, [HL]
ADD A, $02
LD [HL], A

CODE_00_1897:
XOR A                                                       ;Player_State_FallingOrGrounded
LD [Player_State], A
RET

PlayerStateCode_Climbing_00_189C:
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
BitTest JoypadInput_Down, A
JR Z, CODE_00_18C7
CALL CODE_00_1967
LD C, $01
CALL CODE_00_111F
LD A, [TileDetectionArray+253]
AND A
JR Z, CODE_00_18E5

CODE_00_18C7:
LDH A, [JoypadInputHolding]
BitTest JoypadInput_Up, A                                   ;check if holding up
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

LOOP_00_191E:
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
JR LOOP_00_191E

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
CALL QueueSoundPrep_00_072B                                 ;

CODE_00_1973:
LD BC, $DF60
LD HL, PlayerAnimationTable_Climbing_00_19A3

;HL - animation table, BC - timer or something idk
AnimatePlayer_00_1979:
PUSH HL
LD H, B
LD L, C

LD A, [$DF4F]
AND $03                                                     ;every 4th frame?
JR NZ, CODE_00_1984

INC [HL]

CODE_00_1984:
LD D, $00                                                   ;apply table offset (8-bit)
LD E, [HL]                                                  ;
POP HL                                                      ;
ADD HL, DE                                                  ;

LD A, [HL]                                                  ;
CP $FF                                                      ;check if animation over
JR Z, CODE_00_1992
LD [Player_AnimationFrame], A                               ;store player frame
RET                                                         ;

CODE_00_1992:
LD H, B
LD L, C

XOR A
LD [HL], A
LD [$DF5B], A
RET

;Animation tables, end with FF
PlayerAnimationTable_Walking_00_199A:
db Player_AnimationFrame_Walk1
db Player_AnimationFrame_Walk1
db Player_AnimationFrame_Walk2
db Player_AnimationFrame_Walk2
db Player_AnimationFrame_Walk3
db Player_AnimationFrame_Walk3
db Player_AnimationFrame_Walk2
db Player_AnimationFrame_Walk2
db $FF

PlayerAnimationTable_Climbing_00_19A3:
db Player_AnimationFrame_Climbing1
db Player_AnimationFrame_Climbing1
db Player_AnimationFrame_Climbing2
db Player_AnimationFrame_Climbing2
db $FF

PlayerAnimationTable_DuckStart_00_19A8:
db Player_AnimationFrame_Duck1                              ;first byte - unused
db Player_AnimationFrame_Duck1
db Player_AnimationFrame_Duck1

PlayerAnimationTable_Duck_00_19AB:
db Player_AnimationFrame_Duck2                              ;not actually animating, but sure
db Player_AnimationFrame_Duck2
db Player_AnimationFrame_Duck2
db $FF

PlayerAnimationTable_CaneReadyStart_00_19AF:
db Player_AnimationFrame_Walk3                              ;unused
db Player_AnimationFrame_Walk3
db Player_AnimationFrame_Walk3
db Player_AnimationFrame_Walk2
db Player_AnimationFrame_Walk2

PlayerAnimationTable_CaneReadyLoop_00_19B4:
db Player_AnimationFrame_ReadyCane1
db Player_AnimationFrame_ReadyCane1
db Player_AnimationFrame_ReadyCane1
db Player_AnimationFrame_ReadyCane2
db Player_AnimationFrame_ReadyCane2
db $FF

PlayerAnimationTable_UsingCaneStart_00_19BA:
db Player_AnimationFrame_UsingCane1                         ;unused
db Player_AnimationFrame_UsingCane1
db Player_AnimationFrame_UsingCane1
db Player_AnimationFrame_UsingCane2
db Player_AnimationFrame_UsingCane2
db $FF

PlayerAnimationTable_UsingCaneSuccess_00_19C0:
db Player_AnimationFrame_UsingCane3
db Player_AnimationFrame_UsingCane3
db Player_AnimationFrame_UsingCane3
db Player_AnimationFrame_UsingCane4
db Player_AnimationFrame_UsingCane4
db $FF

PlayerAnimationTable_UsingCaneFail_00_19C6:
db Player_AnimationFrame_UsingCaneWrong1                    ;unused
db Player_AnimationFrame_UsingCaneWrong1
db Player_AnimationFrame_UsingCaneWrong1
db Player_AnimationFrame_UsingCaneWrong2
db Player_AnimationFrame_UsingCaneWrong2
db Player_AnimationFrame_UsingCaneWrong1
db Player_AnimationFrame_UsingCaneWrong1
db Player_AnimationFrame_UsingCaneWrong2
db Player_AnimationFrame_UsingCaneWrong2
db $FF

DATA_00_19D0:
db $00,$33,$87,$D3
db $10,$33,$87,$D3
db $11,$33,$87,$D3
db $07,$33,$87,$D3
db $08,$33,$87,$D3
db $09,$33,$87,$D3
db $0A,$33,$87,$D3
db $00,$34,$27,$D3
db $0B,$33,$87,$D3
db $01,$33,$87,$D3
db $02,$33,$87,$D3
db $03,$33,$87,$D3
db $04,$33,$87,$D3
db $05,$33,$87,$D3
db $06,$33,$87,$D3
db $02,$43,$3F,$D3
db $0C,$33,$87,$D3
db $0D,$33,$87,$D3
db $0E,$33,$87,$D3
db $0F,$33,$87,$D3
db $12,$33,$87,$D3
db $00,$22,$1F,$D3

CODE_00_1A28:
LD A, [$C8F8]
BIT 1, A
RET NZ

LD HL, $DF72
LD A, [CurrentEntityRAMOffset]
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
LD HL, CurrentEntity_WaitTimer                              ;
LD A, [HL]                                                  ;
AND A                                                       ;
JR Z, CODE_00_1A5E                                          ;

DEC [HL]                                                    ;decrement timer
CALL CODE_00_32BB
CALL CODE_00_3414
RET

CODE_00_1A5E:
CALL CODE_00_32BB
CALL CODE_00_3414

CALL GetEntityDataArgument_00_329E                          ;get the first byte from a pointer (pointers at POINTERS_00_31C1)
LD C, A
AND $3F                                                     ;the rest of bits (0 through 5) contains some sort of value/props
LD B, A                                                     ;

LD A, C
AND $C0                                                     ;bits 6 and 7...
JR Z, CODE_00_1A88                                          ;if either is clear, get to executing a pointer
CP $40                                                      ;check if bit 6 only is set
JR NZ, CODE_00_1A79

LD A, B                                                     ;

CODE_00_1A75:
LD [CurrentEntity_WaitTimer], A                             ;set timer

RETURN_00_1A78:
RET                                                         ;

CODE_00_1A79:
CP $C0                                                      ;check if both are set
JR NZ, CODE_00_1A84

CALL GetEntityDataArgument_00_329E                          ;get next byte, it'll be the destination (low byte)

LD C, A
JP CODE_00_21FD

CODE_00_1A84:
CP $80                                                      ;check if bit 7 only set
JR Z, CODE_00_1AFE                                          ;other code pointers...

;execute command
CODE_00_1A88:
LD A, B
ExecutePointers

dw InitializeEntityVariables_00_36D8                        ;command $00
dw RETURN_00_1A78                                           ;command $01 unused pointer (do nothing)
dw CODE_00_203A                                             ;command $02
dw CODE_00_204A                                             ;command $03
dw CODE_00_1FE7                                             ;command $04
dw CODE_00_2007                                             ;command $05
dw CODE_00_1FCF                                             ;command $06
dw CODE_00_2115                                             ;command $07
dw CODE_00_2158                                             ;command $08
dw CODE_00_213C                                             ;command $09
dw CODE_00_20BF                                             ;command $0A
dw CODE_00_20A6                                             ;command $0B
dw CODE_00_208D                                             ;command $0C
dw CODE_00_2053                                             ;command $0D
dw CODE_00_2198                                             ;command $0E
dw RETURN_00_1A78                                           ;command $0F (end processing commands for now)
dw CODE_00_21D8                                             ;command $10 start fetching data from a subpointer
dw CODE_00_21E9                                             ;command $11 a command to return from subpointer data to main pointer
dw CODE_00_21A9                                             ;command $12
dw CODE_00_21AD                                             ;command $13
dw CODE_00_21BC                                             ;command $14
dw CODE_00_21C0                                             ;command $15
dw CODE_00_251B                                             ;command $16
dw CODE_00_252B                                             ;command $17
dw CODE_00_252F                                             ;command $18
dw CODE_00_1F57                                             ;command $19
dw CODE_00_1F2F                                             ;command $1A
dw CODE_00_1E34                                             ;command $1B
dw CODE_00_1F4E                                             ;command $1C
dw CODE_00_1EE7                                             ;command $1D
dw CODE_00_1F09                                             ;command $1E
dw CODE_00_1E1C                                             ;command $1F
dw CODE_00_1EF9                                             ;command $20
dw CODE_00_1F28                                             ;command $21
dw CODE_00_1E9D                                             ;command $22
dw CODE_00_1E8F                                             ;command $23
dw CODE_00_1E3E                                             ;command $24
dw CODE_00_36F1                                             ;command $25
dw CODE_00_1FDE                                             ;command $26
dw CODE_00_1DFA                                             ;command $27
dw CODE_00_1DB2                                             ;command $28
dw CODE_00_1D4F                                             ;command $29
dw CODE_00_1D3D                                             ;command $2A
dw CODE_00_1D46                                             ;command $2B
dw CODE_00_1D0A                                             ;command $2C
dw CODE_00_1C74                                             ;command $2D
dw CODE_00_1C66                                             ;command $2E
dw CODE_00_1C5F                                             ;command $2F
dw CODE_00_2033                                             ;command $30
dw CODE_00_2043                                             ;command $31
dw CODE_00_2036                                             ;command $32
dw CODE_00_2046                                             ;command $33
dw CODE_00_2027                                             ;command $34
dw CODE_00_1C4D                                             ;command $35
dw LOOP_00_1C1B                                             ;command $36
dw CODE_00_21D5                                             ;command $37
dw CODE_00_1B4B                                             ;command $38
dw EntityCommand_PlaySFX_00_1C14                            ;command $39

;commands $80-BF (just bit 7 enabled)
CODE_00_1AFE:
LD A, B
AND $20                                                     ;bit 5 does....... something. i am great at charades
LD [$DF6F], A

LD A, B
AND $1F
ExecutePointersWithDestination CODE_00_2206

dw CODE_00_221F                                             ;$80
dw CODE_00_2227                                             ;$81
dw CODE_00_223E
dw CODE_00_2263
dw CODE_00_228E
dw CODE_00_249A
dw CODE_00_2450
dw CODE_00_2462                                             ;launchpad helicopter rope response
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
dw CODE_00_229D                                             ;$98 - transylvania related
dw CODE_00_238B
dw CODE_00_23D8
dw CODE_00_22BF
dw CODE_00_22B6
dw CODE_00_22A5
dw CODE_00_23C6
dw CODE_00_2285

CODE_00_1B4B:
CALL GetEntityDataArgument_00_329E
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
LD HL, Reg_BackgroundPalette
LD A, [HL]
CPL
LD [HL], A
RET

CODE_00_1BCD:
CALL GetEntityDataArgument_00_329E
LD [Player_State], A
RET

CODE_00_1BD4:
CALL LOOP_00_191E
RET

CODE_00_1BD8:
CALL CODE_00_201E
JP CODE_00_1A5E

CODE_00_1BDE:
LD A, [MoneyTotal]
CP $10
JP C, InitializeEntityVariables_00_36D8

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

EntityCommand_PlaySFX_00_1C14:
CALL GetEntityDataArgument_00_329E
CALL QueueSoundPrep_00_072B
RET

LOOP_00_1C1B:
CALL CODE_00_1C2B
LD A, D
SRL A
CP $60
JR NC, LOOP_00_1C1B
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
CALL GetEntityDataArgument_00_329E
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
LD HL, DATA_00_1CF4

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

LD HL, DATA_00_1CFF

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

;a command to generate screen shaking and its effects
CODE_00_1D0A:
LD A, [ScreenShakeTimer]                                    ;check if timer is set
AND A                                                       ;
JR NZ, CODE_00_1D19                                         ;

LD A, $20                                                   ;set timer
LD [ScreenShakeTimer], A                                    ;

CODE_00_1D15:
CALL CODE_00_32B0
RET

CODE_00_1D19:
CP $01                                                      ;check if ran out
JR NZ, CODE_00_1D22                                         ;

XOR A                                                       ;
LD [ScreenShakeTimer], A                                    ;
RET                                                         ;

CODE_00_1D22:
LD HL, ScreenShakeTimer                                     ;
DEC [HL]                                                    ;decrement timer

LD A, [$C201]
CP $58
JR C, CODE_00_1D15                                          ;check if player is grounded (hardcoded y-pos check)

LD A, [Player_State]                                        ;if player is dead, keep them dead
CP Player_State_Dead                                        ;
JR Z, CODE_00_1D15                                          ;

XOR A                                                       ;
LD [Player_PogoFlag], A                                     ;
LD [Player_State], A                                        ;player cannot jump or pogo while shake effect is applied
JR CODE_00_1D15                                             ;

CODE_00_1D3D:
CALL GetEntityDataArgument_00_329E
LD [$C613], A
JP CODE_00_1A5E

CODE_00_1D46:
CALL GetEntityDataArgument_00_329E
LD [$C611], A
JP CODE_00_1A5E

CODE_00_1D4F:
CALL GetEntityDataArgument_00_329E
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
JP NC, InitializeEntityVariables_00_36D8

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
JP NC, InitializeEntityVariables_00_36D8
CP $03
JP C, InitializeEntityVariables_00_36D8
LD A, $9F
JR CODE_00_1D62

CODE_00_1DB2:
CALL GetEntityDataArgument_00_329E
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
LD A, Player_State_Message
LD [Player_State], A

LD A, [CurrentEntityRAMOffset]
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
JP Z, InitializeEntityVariables_00_36D8

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
CALL GetEntityDataArgument_00_329E
LD [$C61E], A

CALL GetEntityDataArgument_00_329E
LD [$C61F], A

CALL GetEntityDataArgument_00_329E
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
CP Player_State_Pogo
JR NZ, CODE_00_1E5A

CALL CODE_00_1E77
CP $1E
JP NC, CODE_00_1E5A
CALL CODE_00_1E7F
JP NC, CODE_00_1E5A

LD C, LOW(DATA_00_2EFE)
LD B, HIGH(DATA_00_2EFE)
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

LD C, LOW(DATA_00_2F02)
LD B, HIGH(DATA_00_2F02)
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

LD C, LOW(DATA_00_317E)
LD B, HIGH(DATA_00_317E)
JR CODE_00_1ED4

CODE_00_1ECB:
BIT 1, A
JP Z, CODE_00_32B0

CODE_00_1ED0:
LD C, LOW(DATA_00_3171)
LD B, HIGH(DATA_00_3171)

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
CALL GetEntityDataArgument_00_329E
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
CALL LoadGraphics_00_38E7
CALL GetEntityDataArgument_00_329E

LD B, A
LD C, $03
CALL LoadGraphics_00_38E7
SetBankAndBackup 1
RET

CODE_00_1F28:
CALL GetEntityDataArgument_00_329E
LD [$C602], A
RET

CODE_00_1F2F:
CALL GetEntityDataArgument_00_329E
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
CALL GetEntityDataArgument_00_329E
LD [$C614], A
JP CODE_00_1A5E

CODE_00_1F57:
CALL GetEntityDataArgument_00_329E
LD B, A

CALL GetEntityDataArgument_00_329E
LD C, A

CODE_00_1F5F:
LD A, [$C613]
LD D, A

LD A, [$C611]
LD E, A

LD A, [$C615]
LDH [$FF94], A
LD A, [CurrentEntityRAMOffset]
PUSH AF
LD A, $F0
LD [CurrentEntityRAMOffset], A

LOOP_00_1F75:
LD A, [CurrentEntityRAMOffset]
SUB $10
JR Z, CODE_00_1FCA
LD [CurrentEntityRAMOffset], A

LD HL, $C200
CALL GetCurrentEntityRAMOffset_00_3298

LD A, [HL]
AND A
JR NZ, LOOP_00_1F75

LD HL, $C200
CALL GetCurrentEntityRAMOffset_00_3298
LD A, $02
LD [HL], A

LD HL, $C20E
CALL GetCurrentEntityRAMOffset_00_3298

LD A, B
LD [HL+], A
LD [HL], C

LD HL, $C303
CALL GetCurrentEntityRAMOffset_00_3298

LD [HL], D
LD HL, $C301
CALL GetCurrentEntityRAMOffset_00_3298
LD [HL], E

LD HL, $C305
CALL GetCurrentEntityRAMOffset_00_3298

LDH A, [$FF94]
LD [HL], A

LD HL, $C20A
CALL GetCurrentEntityRAMOffset_00_3298
POP AF
LD [HL], A
PUSH AF
LD HL, $C302
CALL GetCurrentEntityRAMOffset_00_3298

LD A, $80
LD [HL], A

LD A, [CurrentEntityRAMOffset]
LD [$C60B], A

CODE_00_1FCA:
POP AF
LD [CurrentEntityRAMOffset], A
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
CALL GetEntityDataArgument_00_329E

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
CALL GetEntityDataArgument_00_329E

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
JP Z, InitializeEntityVariables_00_36D8
RET

CODE_00_212B:
LD A, [$C616]

CODE_00_212E:
LD B, A
LD A, [$C611]
ADD A, B
LD [$C611], A
CP $B1
JP NC, InitializeEntityVariables_00_36D8
RET

CODE_00_213C:
CALL GetEntityDataArgument_00_329E

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
CALL GetEntityDataArgument_00_329E

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

CALL GetEntityDataArgument_00_329E
CALL GetEntityDataArgument_00_329E
JP CODE_00_1A5E

CODE_00_21D5:
CALL CODE_00_2521

CODE_00_21D8:
CALL GetEntityDataPointerViaArgument_00_21F1

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
;output BC - data pointer
GetEntityDataPointerViaArgument_00_21F1:
CALL GetEntityDataArgument_00_329E
LD C, A

CALL GetEntityDataArgument_00_329E
LD B, A
RET

CODE_00_21FA:
CALL GetEntityDataPointerViaArgument_00_21F1

;entity data pointer jump. C - low byte, B - high byte
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
CALL GetEntityDataArgument_00_329E
CALL GetEntityDataArgument_00_329E
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
LD A, Player_State_EnteringBossArena
LD [Player_State], A

LD BC, $0000

CODE_00_2336:
LD A, $10
ADD A, C
AND A
JP Z, CODE_00_2215
LD C, A
LD A, [CurrentEntityRAMOffset]
CP C
JR Z, CODE_00_2336
LD HL, $C200
ADD HL, BC
LD D, H
LD E, L
LD HL, $C300
ADD HL, BC
PUSH BC
CALL LOOP_00_36E7
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
CP CurrentLand_Transylvania                                 ;check if were in transylvania
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
CP CurrentLand_Transylvania                                 ;check if in either transylvania or... transylvania. for the final boss battle.
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

LD A, [CurrentEntityRAMOffset]
LD [$DF67], A

LD A, Player_State_MineCart
LD [Player_State], A
JP CODE_00_2215

CODE_00_2462:
LDH A, [JoypadInputHolding]                                 ;check if player held up
BitTest JoypadInput_Up, A                                   ;
RET Z                                                       ;

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
LD A, [CurrentEntityRAMOffset]                              ;player will now be attached to launchpad's rope
LD [$DF67], A

LD A, Player_State_ClimbingEntity                           ;
LD [Player_State], A                                        ;
RET                                                         ;

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
LD HL, CurrentEntityRAMOffset
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
CALL GetEntityDataArgument_00_329E

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

include "Data/EntityData.asm"

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

;input HL - base RAM address (in reality only needs L)
GetCurrentEntityRAMOffset_00_3298:
LD A, [CurrentEntityRAMOffset]                              ;base offset
OR L                                                        ;logical L
LD L, A                                                     ;resulting HL
RET                                                         ;

;used to fetch the next byte from the current entity's data table
GetEntityDataArgument_00_329E:
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
LD A, [DE]                                                  ;get data byte
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

LD A, SFX_ExtraLife
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

LD A, $09                                                   ;found remote control message
JR CODE_00_33F8

CODE_00_33C4:
CP $0B
JR NZ, CODE_00_33CE

SET 3, [HL]

LD A, $0F                                                   ;found key to the mines message
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
LD [MessageQueue], A                                        ;found legendary treasure message

LD A, Player_State_Message                                  ;player frozen, do display message
LD [Player_State], A                                        ;

LD A, SFX_ItemJingle                                        ;
LDH [SFXQueue], A                                           ;

CODE_00_33EA:
LD HL, LegendaryTreasureValue_00_0781+3
JP GiveMoney_00_333D

CODE_00_33F0:
CP $0E
JR NZ, CODE_00_3404

SET 4, [HL]

LD A, $11                                                   ;found UFO key

CODE_00_33F8:
LD [MessageQueue], A                                        ;

LD A, Player_State_Message                                  ;
LD [Player_State], A                                        ;

LD A, SFX_ItemJingle                                        ;
LDH [SFXQueue], A                                           ;

CODE_00_3404:
CALL InitializeEntityVariables_00_36D8                      ;
POP AF                                                      ;
RET                                                         ;

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
LD A, [CurrentEntityRAMOffset]
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

LD A, [CurrentEntityRAMOffset]
LD [$DF67], A

LD A, Player_State_OnSpritePlatform                         ;should stay on top of the platform
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
CP Player_State_Dead
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

LD A, Player_State_StuckEntity
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
LD HL, POINTERS_00_356E
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

LD [HL], LOW(DATA_00_314B)
INC HL
LD [HL], HIGH(DATA_00_314B)

LD HL, $C612
SET 7, [HL]

XOR A
LD [$C60B], A
RET

CODE_00_3542:
LD HL, $C61D
DEC [HL]
JR Z, CODE_00_3554

LD A, [CurrentEntityRAMOffset]
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
LD [ScreenShakeTimer], A

LD A, $80
JP CODE_00_1F4A

POINTERS_00_356E:
dw DATA_00_2E18
dw DATA_00_2E1D
dw DATA_00_2E22
dw DATA_00_2E27

CODE_00_3576:
LD HL, $DF72
LD A, [CurrentEntityRAMOffset]
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
BitTest JoypadInput_Down, A
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

;FetchDataWithBCTimes4_00_360F
CODE_00_360F:
LD B, $00
LD C, A
SLA C
RL B

;FetchDataWithBCTimes2
;Input HL - base data pointer
;BC - pointer offset
CODE_00_3616:
SLA C
RL B
ADD HL, BC
LD B, H
LD C, L
RET

CODE_00_361E:
LD A, [CurrentEntityRAMOffset]
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
LD [CurrentEntityRAMOffset], A

LOOP_00_3640:
LD HL, CurrentEntityRAMOffset
LD A, [HL]
ADD A, $10
JR Z, CODE_00_3656

LD [HL], A
LD HL, $C20D
CALL GetCurrentEntityRAMOffset_00_3298

LD A, [HL]
CP E
JP Z, CODE_00_36D2
JR LOOP_00_3640

CODE_00_3656:
XOR A
LD [CurrentEntityRAMOffset], A

CODE_00_365A:
LD HL, CurrentEntityRAMOffset
LD A, [HL]
ADD A, $10
JP Z, CODE_00_36D2

LD [HL], A
LD HL, $C200
CALL GetCurrentEntityRAMOffset_00_3298

LD A, [HL]
AND A
JR NZ, CODE_00_365A

PUSH BC
PUSH DE
PUSH HL
LD D, H
LD E, L
LD HL, $C300
CALL GetCurrentEntityRAMOffset_00_3298
CALL LOOP_00_36E7
POP HL
POP DE
POP BC
LD A, $02
LD [HL], A

LD HL, $C303
CALL GetCurrentEntityRAMOffset_00_3298
LD [HL], B

LD HL, $C301
CALL GetCurrentEntityRAMOffset_00_3298
LD [HL], C

LD HL, $C20D
CALL GetCurrentEntityRAMOffset_00_3298
LD [HL], E

LD HL, $C20C
CALL GetCurrentEntityRAMOffset_00_3298

LDH A, [$FF96]
LD [HL], A

LD A, D
AND $F0
JR NZ, CODE_00_36AE

LD HL, $C302
CALL GetCurrentEntityRAMOffset_00_3298

LD A, $80
LD [HL], A

CODE_00_36AE:
LD A, D
BIT 7, A
JR Z, CODE_00_36BC

LD HL, $C208
CALL GetCurrentEntityRAMOffset_00_3298

LD A, $10
LD [HL], A

CODE_00_36BC:
LD A, D
SLA A
LD C, A
LD B, $00
LD HL, POINTERS_00_31C1
ADD HL, BC                                                  ;offset

LD B, [HL]                                                  ;get 16-bit pointer into BC
INC HL
LD C, [HL]

LD HL, $C20E
CALL GetCurrentEntityRAMOffset_00_3298

LD [HL], B                                                  ;store BC into entity's RAM
INC HL                                                      ;
LD [HL], C                                                  ;

CODE_00_36D2:
LDH A, [$FF94]
LD [CurrentEntityRAMOffset], A
RET

;some kind of code to initialize entity variables? seems to also be used for deleting an entity
InitializeEntityVariables_00_36D8:
LD HL, $C600
LD D, H
LD E, L

LD HL, $C610
LD A, [$C612]
BIT 4, A
JR NZ, CODE_00_36F1

LOOP_00_36E7:
XOR A
LD [HL+], A                                                 ;clear $C610-C61F
LD [DE], A                                                  ;clear $C600-C60F
INC DE

LD A, L
AND $0F
JR NZ, LOOP_00_36E7
RET

CODE_00_36F1:
LD A, [$C61D]
LD C, A
CALL CODE_00_327B
SUB C
CP $08
JR C, CODE_00_3703

LD E, LOW(DATA_00_3158)
LD D, HIGH(DATA_00_3158)
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
WaitForVBlank_00_372E:
LDH [VBlankWaitCounter], A                                  ;

LOOP_00_3730:
HALT                                                        ;wait until interrupt...
LDH A, [VBlankWaitCounter]                                  ;check if the counter is 0
AND A                                                       ;
JR NZ, LOOP_00_3730                                         ;
RET                                                         ;

;thanks to pokemon red and blue disassembly, I now know what this routine does!
DisableLCD_00_3737:
LDH A, [Reg_InterruptsEnabler]                              ;
LDH [InterruptEnablerMirror], A                             ;save currently enabled interrupt bits here

ResetBit Interrupt_VBlank, A                                ;disable VBlank bit
LDH [Reg_InterruptsEnabler], A                              ;

LOOP_00_373F:
LDH A, [Reg_LCDYPos]                                        ;
CP $91                                                      ;check if in VBlank
JR NZ, LOOP_00_373F                                         ;

LDH A, [Reg_LCDControlAndRender]                            ;
AND $00                                                     ;preserve NO bits, not even LCD control
LDH [Reg_LCDControlAndRender], A                            ;

LDH A, [InterruptEnablerMirror]                             ;restore interrupts
LDH [Reg_InterruptsEnabler], A                              ;
RET                                                         ;

;does what it says on the tin, enable rendering
EnableLCDAndRender_00_3750:
LDH A, [Reg_LCDControlAndRender]                            ;
OR LCDControlEnable|LCDSpriteRender|LCDBackgroundRender     ;
LDH [Reg_LCDControlAndRender], A                            ;
RET

;note: does not disable LCD, but disables sprite and background display
DisableRender_00_3757:
LDH A, [Reg_LCDControlAndRender]                            ;
AND ~(LCDSpriteRender|LCDBackgroundRender)                  ;
LDH [Reg_LCDControlAndRender], A                            ;
RET                                                         ;

;unused code, enables sprite and background rendering without control enable bit
EnableRender_00_375E:
LDH A, [Reg_LCDControlAndRender]
OR LCDSpriteRender|LCDBackgroundRender
LDH [Reg_LCDControlAndRender], A
RET

ReadJoypadInputs_00_3765:
LD A, $20                                                   ;
LDH [Reg_JoyPad], A                                         ;read buttons

LDH A, [Reg_JoyPad]                                         ;
LDH A, [Reg_JoyPad]                                         ;twice
CPL
AND $0F
SWAP A
LD B, A

LD A, $10                                                   ;read directions
LDH [Reg_JoyPad], A                                         ;

LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]
LDH A, [Reg_JoyPad]                                         ;read 6 times for... stabilizing inputs
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

StoreOAMUploadCodeToRAM_00_3796:
LD C, LOW(OAMUploadCode)
LD B, $0A
LD HL, OAMUploadCode_00_37A4                                ;put code into HRAM

LOOP_00_379D:
LD A, [HL+]
LD [$FF00+C], A
INC C
DEC B
JR NZ, LOOP_00_379D
RET

;some code that is stored into HRAM for faster access
OAMUploadCode_00_37A4:
LD A, $C0
LDH [Reg_OAMDMA], A

LD A, $28

LOOP_00_37AA:
DEC A                                                       ;wait for a bit, I guess so we don't mess with OAM?
JR NZ, LOOP_00_37AA
RET

;related to gravity?
CODE_00_37AE:
LD A, [CurrentEntityRAMOffset]
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
LDH [VRAMPointer], A
LD A, L
LDH [VRAMPointer+1], A
POP HL
POP DE
RET

;clear RAM routine
;input BC - amount of bytes to clear
;HL - RAM starting point
ClearRAM_00_37E0:
XOR A                                                       ;big fat 0
LD [HL+], A                                                 ;

DEC BC                                                      ;
LD A, C                                                     ;
OR B                                                        ;
JR NZ, ClearRAM_00_37E0                                     ;clear until we're done
RET                                                         ;

;clear tilemap
ClearTilemap_00_37E8:
LD HL, $9800                                                ;
LD BC, $0800                                                ;

LOOP_00_37EE:
LD A, $6E                                                   ;fill with this tile
LD [HL+], A                                                 ;

DEC BC                                                      ;
LD A, C                                                     ;
OR B                                                        ;
JR NZ, LOOP_00_37EE                                         ;loop until done
RET                                                         ;

;Transfer from table routine.
;input: HL - pointer
;DE - RAM or other location to store from pointer
;BC - amount of bytes to transfer
TransferData_00_37F7:
LD A, [HL+]                                                 ;
LD [DE], A                                                  ;
INC DE                                                      ;

DEC BC                                                      ;
LD A, B                                                     ;
OR C                                                        ;
JR NZ, TransferData_00_37F7                                 ;
RET                                                         ;

;HL - pointer to a tilemap
ProcessStripeImage_00_3800:
LD A, [HL+]                                                 ;
AND A                                                       ;check if A is zero
RET Z                                                       ;
LDH [VRAMPointer], A                                        ;VRAM pointer

LD A, [HL+]
LDH [VRAMPointer+1], A                                      ;store high byte

LD A, [HL+]
LD B, A                                                     ;how many bytes to transfer + repeat write command if applicable
CALL DrawStripeImage_00_380F                                ;
JR ProcessStripeImage_00_3800                               ;keep going until hitting that elusive stop command

DrawStripeImage_00_380F:
LDH A, [Reg_LCDControlAndRender]                            ;
BitTest LCDControlEnable, A                                 ;
JR NZ, StripeImageIntoBuffer_00_382D                        ;if LCD is enabled, can only draw from buffer

LD C, B                                                     ;transfer amount of bytes into C
LD B, $00                                                   ;clear B

LDH A, [VRAMPointer]                                        ;
LD D, A                                                     ;pointer into DE

LDH A, [VRAMPointer+1]                                      ;
LD E, A                                                     ;

BitTest StripeImageCommand_Repeat, C                        ;check if bit 7 is set
JR Z, TransferData_00_37F7                                  ;standard data transfer if not

ResetBit StripeImageCommand_Repeat, C                       ;clear bit 7
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
CALL WaitForVBlank_00_372E                                  ;

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

LDH A, [VRAMPointer]                                        ;VRAM high
CALL TranferByteToBuffer_00_3886                            ;

LDH A, [VRAMPointer+1]                                      ;VRAM low
CALL TranferByteToBuffer_00_3886

BitTest StripeImageCommand_Repeat, B                        ;check for repeat, again.
JR Z, CODE_00_3866                                          ;

ResetBit StripeImageCommand_Repeat, B                       ;
LD A, B                                                     ;
CALL TranferByteToBuffer_00_3886                            ;
LD A, [HL+]                                                 ;

LOOP_00_385E:
CALL TranferByteToBuffer_00_3886                            ;since buffer does not check for this bit, keep filling it with this byte.
DEC B                                                       ;
JR NZ, LOOP_00_385E                                         ;
JR CODE_00_3871                                             ;put a stop

CODE_00_3866:
LD A, B                                                     ;
CALL TranferByteToBuffer_00_3886                            ;

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
LDH A, [VRAMPointer]                                        ;
LD D, A                                                     ;

LDH A, [VRAMPointer+1]                                      ;
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

LD A, [HL+]                                                 ;
LD B, A                                                     ;B - amount of tiles to write

LOOP_00_389F:
LD A, [HL+]                                                 ;get tile
LD [DE], A                                                  ;write tile to VRAM.
INC DE                                                      ;next VRAM position
DEC B                                                       ;write until done...
JR NZ, LOOP_00_389F                                         ;

JR LOOP_00_3892                                             ;go back and check if need to do more writes

;used to load graphics...
;HL - graphic bank configuration
LoadAllGraphics_00_38A7:
LD DE, LatestGraphicsConfiguration                          ;
LD C, $00                                                   ;

LOOP_00_38AC:
SetBankAndBackup 1                                          ;is this necessary? the bank will likely be overwritten anyway

LD A, [HL]                                                  ;load graphic data for this chunk
LD B, A                                                     ;

LD A, [DE]                                                  ;if matches with what was already loaded, don't reload
CP B                                                        ;
JR Z, CODE_00_38CB                                          ;

LD A, B                                                     ;
SWAP A                                                      ;
AND $03                                                     ;get PRG bank where the graphics are stored
LD [MBC1Bank], A                                            ;
LDH [CurrentProgramBank], A                                 ;

LD A, B                                                     ;
LD [DE], A                                                  ;
AND $0F                                                     ;graphics pointer
LD B, A                                                     ;
CALL LoadGraphics_00_38E7                                   ;decompress and store

CODE_00_38CB:
INC DE                                                      ;
INC HL                                                      ;

INC C                                                       ;
LD A, $06                                                   ;
CP C                                                        ;check if done uploading all 6 chunks of graphics
JR NZ, LOOP_00_38AC                                         ;

SetBankAndBackup 1                                          ;make sure we have $4000-$7FFF mapped to bank 1
RET                                                         ;

;graphic chunk locations in VRAM
VRAMGraphicChunks_00_38DB:
dw $8000
dw $8080
dw $8800
dw $8880
dw $9000
dw $9080

;decompress graphics into RAM to be transported into VRAM later
;B - pointer value
;C - which graphic chunk to store the graphics in VRAM
LoadGraphics_00_38E7:
PUSH BC                                                     ;
PUSH DE                                                     ;
PUSH HL                                                     ;

PUSH BC                                                     ;backup inputs
LD A, B                                                     ;
LD HL, POINTERS_02_4000                                     ;note: this can be either POINTERS_02_4000 or POINTERS_03_4000 depending on the current bank
RST $28                                                     ;

LD H, D                                                     ;
LD L, E                                                     ;
LD DE, GFXDecompressionBuffer                               ;
CALL DecompressionAlgorithm_00_3929                         ;

POP BC                                                      ;
LD A, C                                                     ;
LD HL, VRAMGraphicChunks_00_38DB                            ;obtain graphic chunk pointer
RST $28                                                     ;

LD HL, GFXDecompressionBuffer                               ;
LD B, $08                                                   ;upload 64 8x8 tiles (1KB of of graphics)

LOOP_00_3903:
PUSH BC                                                     ;
LD B, 64                                                    ;transfer 64 bytes of graphics, which is equivalent to 4 8x8 tiles

LD A, D                                                     ;
LDH [VRAMPointer], A                                        ;

LD A, E                                                     ;
LDH [VRAMPointer+1], A                                      ;

CALL DrawStripeImage_00_380F                                ;

LD B, 64                                                    ;4 more tiles

LD A, D                                                     ;
LDH [VRAMPointer], A                                        ;

LD A, E                                                     ;
LDH [VRAMPointer+1], A                                      ;

CALL DrawStripeImage_00_380F                                ;

LD A, E                                                     ;
ADD A, 128                                                  ;offset
LD E, A                                                     ;
JR NC, CODE_00_3921                                         ;

INC D                                                       ;

CODE_00_3921:
POP BC                                                      ;
DEC B                                                       ;
JR NZ, LOOP_00_3903                                         ;keep storing those tiles

POP HL                                                      ;
POP DE                                                      ;
POP BC                                                      ;
RET                                                         ;

;A basic decompression code.
;DE - decompression buffer
;HL - graphics data
DecompressionAlgorithm_00_3929:
LD A, [HL+]                                                 ;get key byte
LD C, A                                                     ;that will be in C

LOOP_00_392B:
LD A, [HL+]                                                 ;
CP C                                                        ;check if byte matches with key byte
JR Z, CODE_00_3933                                          ;

LD [DE], A                                                  ;not compressed byte
INC DE                                                      ;
JR LOOP_00_392B                                             ;

CODE_00_3933:
LD A, [HL+]                                                 ;
AND A                                                       ;
RET Z                                                       ;if the next byte after key byte is 0, that means graphics are finished
LD B, A                                                     ;amount of identical bytes
LD A, [HL+]                                                 ;data byte that will be copied multiple times

LOOP_00_3938:
LD [DE], A                                                  ;copy this byte...
INC DE                                                      ;

DEC B                                                       ;B times
JR NZ, LOOP_00_3938                                         ;
JR LOOP_00_392B                                             ;done decompressing that

;counter addition. used for 4 byte counters.
;input:
;DE - counter RAM
;HL - data for amount to be added
AddTo4ByteCounter_00_393F:
PUSH DE
PUSH HL
AND A
LD B, $04                                                   ;4 byte counter

LOOP_00_3944:
LD A, [DE]
ADC A, [HL]
DAA
LD [DE], A
DEC DE
DEC HL
DEC B
JR NZ, LOOP_00_3944
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

LOOP_00_3971:
LD [DE], A
INC DE
DEC B
JR NZ, LOOP_00_3971
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
LD A, [Player_State]                                        ;
CP Player_State_Teleporting                                 ;
JP NZ, CODE_00_3A35                                         ;

LD A, [FrameCounter]                                        ;every 8th frame...
AND $07                                                     ;
JR NZ, CODE_00_39BE                                         ;

LD A, SFX_Teleport                                          ;make teleport noise
CALL QueueSoundPrep_00_072B                                 ;

CODE_00_39BE:
LD HL, TeleportationTimer
INC [HL]                                                    ;increment
LD A, [HL]
AND $3F
RET NZ
BIT 7, [HL]                                                 ;if bit 7 is set, it'll return you to the land select
JR Z, CODE_00_39D0

CALL CODE_00_3A2A
JP CODE_00_3C35

CODE_00_39D0:
CALL DisableRender_00_3757

LD A, $10
CALL WaitForVBlank_00_372E
CALL DisableLCD_00_3737

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

LOOP_00_3A0E:
LD A, $01
CALL WaitForVBlank_00_372E

CALL CODE_00_0FE5

LD A, [FrameCounter]
AND $07                                                     ;wait every 8 frames
JR NZ, CODE_00_3A22

LD A, SFX_Teleport
CALL QueueSoundPrep_00_072B

CODE_00_3A22:
LD HL, TeleportationTimer                                   ;
INC [HL]                                                    ;
BIT 6, [HL]                                                 ;if bit 6 is set (on the other side of teleport mirror)
JR NZ, LOOP_00_3A0E                                         ;keep teleport loop

CODE_00_3A2A:
XOR A
LD [Player_State], A
LD [$CA08], A
LD [TeleportationTimer], A
RET

CODE_00_3A35:
LD A, [$CA08]
AND A
RET Z

LD HL, DATA_00_397A
LD B, $06

LOOP_00_3A3F:
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
JR NZ, LOOP_00_3A3F

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
LD A, Player_State_Teleporting
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
LD [TeleportationTimer], A
RET

CODE_00_3AA5:
LD A, [$CA1D]
BIT 5, A
JR NZ, CODE_00_3A95
JP CODE_00_3A2A

;special mirror
CODE_00_3AAF:
LD A, [CurrentLand]
CP CurrentLand_DraculaDuckManor                             ;check if the mirror should bring you to the level select or not
JR Z, CODE_00_3ABD

LD A, $80
LD [TeleportationTimer], A
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
AND $1F                                                     ;this limits to 30 messages
DEC A                                                       ;0 doesn't count, so 30, not 31 messages.
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

LD A, SFX_MessageText                                       ;
CALL QueueSoundPrep_00_072B                                 ;

CODE_00_3B2A:
LD A, $01                                                   ;
CALL WaitForVBlank_00_372E                                  ;normal sync process
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
CALL WaitForAOrBPress_00_075F
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

LD A, CHARVAL(".")                                          ;
CALL DrawMessageCharacter_00_3B3F                           ;message ends with a dot

CALL WaitForAOrBPress_00_075F                               ;wait for A or B
BitTest JoypadInput_B, A                                    ;check if pressed B
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

include "Data/Tilemaps/MessageBox.asm"

include "Data/MessageLoader.asm"
MACRO ExecutePointers
  RST $00                                                   ;the game uses this area for code pointer execution
ENDM

MACRO ExecutePointersWithDestination
  LD DE, \1
  RST $10                                                   ;the game uses this are for code pointer execution, then going to set destination
ENDM

MACRO SetProgramBank1
  RST $38                                                   ;the game uses this area for a bank switch. the macro is here for readability.
ENDM

MACRO SetBankAndBackup
  LD A, \1
  LD [MBC1Bank], A
  LDH [CurrentProgramBank], A
ENDM

;so i don't have to remember LOG function every time, just use this to get a BIT value
MACRO BitA
  BIT LOG(\1<<16,2.0)>>16, A
ENDM

MACRO BitB
  BIT LOG(\1<<16,2.0)>>16, B
ENDM

MACRO BitC
  BIT LOG(\1<<16,2.0)>>16, C
ENDM

MACRO ResetBitA
  RES LOG(\1<<16,2.0)>>16, A
ENDM

MACRO ResetBitB
  RES LOG(\1<<16,2.0)>>16, B
ENDM

MACRO ResetBitC
  RES LOG(\1<<16,2.0)>>16, C
ENDM
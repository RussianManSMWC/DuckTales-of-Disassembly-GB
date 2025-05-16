SETCHARMAP General

LevelMessagePointers_00_3C78:
dw Message_BossTip_00_3C9A
dw Message_HelpHuey_00_3CC8
dw Message_HelpedHuey_00_3CF8
dw Message_FindKeyInTransylvania_00_3D3B
dw Message_BubbaTrapped_00_3D6E                             ;unused pointer (duplicate)
dw Message_BubbaTrapped_00_3D6E
dw Message_BubbaRescued_00_3D9B
dw Message_FindRemoteControl_00_3DCA
dw Message_FoundRemoteControl_00_3E08
dw Message_FindUFOKey_00_3E3F
dw Message_PayStatue_00_3E78
dw Message_FinalRace_00_3EAC
dw Message_FinalRaceFail_00_3F12
dw Message_HiddenTreasure_00_3F5F
dw Message_FoundKeyInTransylvania_00_3F77
dw Message_Launchpad_00_3FA2
dw Message_FoundUFOKey_00_3FE0

include "Data/Messages/BossTip.asm"
include "Data/Messages/HelpHuey.asm"
include "Data/Messages/HelpedHuey.asm"
include "Data/Messages/FindKeyInTransylvania.asm"
include "Data/Messages/BubbaTrapped.asm"
include "Data/Messages/BubbaRescued.asm"
include "Data/Messages/FindRemoteControl.asm"
include "Data/Messages/FoundRemoteControl.asm"
include "Data/Messages/FindUFOKey.asm"
include "Data/Messages/PayStatue.asm"
include "Data/Messages/FinalRace.asm"
include "Data/Messages/FinalRaceFail.asm"
include "Data/Messages/HiddenTreasure.asm"
include "Data/Messages/FoundKeyInTransylvania.asm"
include "Data/Messages/Launchpad.asm"
include "Data/Messages/FoundUFOKey.asm"

;a litte bit of message free space.
db $00,$00,$00,$00,$00,$00,$00

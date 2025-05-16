;flimsy enums

;sound effects
RSRESET
def CurrentLand_Amazon rb 1
def CurrentLand_Transylvania rb 1
def CurrentLand_AfricanMines rb 1
def CurrentLand_Himalayas rb 1
def CurrentLand_Moon rb 1
def CurrentLand_DraculaDuckManor rb 1

RSRESET
def SFX_None rb 1
def SFX_GroundLand rb 1                                     ;scrooge landed on the ground
def SFX_PogoBounce rb 1
def SFX_Climb rb 1
def SFX_CaneHit rb 1
def SFX_Damage rb 1                                         ;Ow, ow, ow!
def SFX_ItemCollect rb 1                                    ;also used as a pause ding.
def SFX_Destruction rb 1
def SFX_ExtraLife rb 1
def SFX_PlantCatch rb 1                                     ;scrooge landede into a hungry plant
def SFX_PlantSpit rb 1                                      ;scrooge gets spat out afterwards
def SFX_SpearThrow rb 1                                     ;natives spear throw attack
;the rest TBA eventually. did i mention that this disassembly is sloppy? no? well, there, now you know.

RSSET $41
def Music_Amazon rb 1
def Music_Transylvania rb 1
def Music_AfricanMines rb 1
def Music_Hymalayas rb 1
def Music_Moon rb 1
def Music_StageSelect rb 1
def Music_Boss rb 1
def Music_TitleTheme rb 1
def Music_Invincibility rb 1
def Music_GameOver rb 1
def Music_Death rb 1
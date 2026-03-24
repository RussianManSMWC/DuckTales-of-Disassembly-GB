;flimsy enums

RSRESET
def CurrentLand_Amazon rb 1
def CurrentLand_Transylvania rb 1
def CurrentLand_AfricanMines rb 1
def CurrentLand_Himalayas rb 1
def CurrentLand_Moon rb 1
def CurrentLand_DraculaDuckManor rb 1

;player states
RSRESET
def Player_State_FallingOrGrounded rb 1                     ;going down/grounded
def Player_State_Rising rb 1                                ;rising up e.g. jump
def Player_State_Pogo rb 1                                  ;pogo bounce up
def Player_State_Climbing rb 1
def Player_State_ReadyCane rb 1
def Player_State_Ducking rb 1
def Player_State_Damage rb 1
def Player_State_Stuck rb 1                                 ;stuck in snow
def Player_State_Dead rb 1 ;dead
def Player_State_StuckEntity rb 1                           ;plant bit player's backside
def Player_State_ClimbingEntity rb 1                        ;launchpad's helicopter rope
def Player_State_MineCart rb 1
def Player_State_OnSpritePlatform rb 1
def Player_State_EnteringBossArena rb 1
def Player_State_Teleporting rb 1
def Player_State_Message rb 1
def Player_State_TreasureRaceFreeze rb 1                    ;freeze player, either win or lose treasure race

;player animation frames
RSRESET
def Player_AnimationFrame_Standstill rb 1
def Player_AnimationFrame_PogoBounce rb 1
def Player_AnimationFrame_Pogo rb 1
def Player_AnimationFrame_ReadyCane1 rb 1                   ;when walking against a solid object, scrooge will ready his cane to hit that something
def Player_AnimationFrame_ReadyCane2 rb 1
def Player_AnimationFrame_UsingCane1 rb 1
def Player_AnimationFrame_UsingCane2 rb 1
def Player_AnimationFrame_UsingCane3 rb 1
def Player_AnimationFrame_UsingCane4 rb 1
def Player_AnimationFrame_Walk1 rb 1
def Player_AnimationFrame_Walk2 rb 1
def Player_AnimationFrame_Walk3 rb 1
def Player_AnimationFrame_Airborn rb 1
def Player_AnimationFrame_Duck1 rb 1
def Player_AnimationFrame_Duck2 rb 1                        ;also used when landing on solid ground
def Player_AnimationFrame_Hurt rb 1
def Player_AnimationFrame_UsingCaneWrong1 rb 1              ;hit the solid object from the side but nothing happens $10
def Player_AnimationFrame_UsingCaneWrong2 rb 1
def Player_AnimationFrame_Climbing1 rb 1
def Player_AnimationFrame_Climbing2 rb 1
def Player_AnimationFrame_Stuck rb 1                        ;when bitten by plant or stuck in snow $14
def Player_AnimationFrame_InMinecart rb 1

;sound effects (most are placeholders for now)
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
def SFX_CaneHitWrong rb 1
def SFX_PlantCatch rb 1                                     ;scrooge landede into a hungry plant
def SFX_PlantSpit rb 1                                      ;scrooge gets spat out afterwards
def SFX_SpearThrow rb 1                                     ;natives spear throw attack 
def SFX_0D rb 1 ;???
def SFX_Quake rb 1                                          ;statue boss shaking the screen upon landing
def SFX_MetalPunchDupe rb 1                                 ;unused duplicate
def SFX_MetalPunch rb 1                                     ;robot duck enemies from Moon
def SFX_11 rb 1 ;???
def SFX_LaunchpadHelicopter rb 1
def SFX_Boulder rb 1
def SFX_Snake rb 1
def SFX_Bee rb 1
def SFX_16 rb 1 ;???
def SFX_Teleport rb 1
def SFX_MessageText rb 1                                    ;text appearing in the message box
def SFX_CursorMove rb 1
def SFX_Ghost rb 1
def SFX_EnemyDefeatDupe1 rb 1
def SFX_EnemyDefeatDupe2 rb 1
def SFX_EnemyDefeatDupe3 rb 1
def SFX_EnemyDefeatDupe4 rb 1                               ;4 duplicates
def SFX_EnemyDefeat rb 1
def SFX_TimerRunningOut rb 1
def SFX_ItemJingle rb 1                                     ;legendary treasures and other important items

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
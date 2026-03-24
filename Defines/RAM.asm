;ram addresses

def OAM_Y = $C000
def OAM_X = $C001
def OAM_Tile = $C002
def OAM_Prop = $C003

def Buffer_DataCount = $C0A0                                ;counts up how much data we're transferring, so it doesn't overflow. do an emergency VBlank wait if capped.
def Buffer_Storage = $C0A1                                  ;buffered data storage

def Buffer_WritingFlag = $C1A0                              ;set to 1 when writing to buffer, so any potential interrupts do not read from incomplete buffer
def CurrentOAMSlot = $C1A1                                  ;counts up by 4 for each used slot
def CurrentEntityRAMOffset = $C1A2


def CurrentMessage = $C1AA
;$C1AB - unused
def MessageCharacterTimer = $C1AD                           ;how many frames does it take between each character?
def CurrentMessageType = $C1AE                              ;0 - normal, 1 - greedy statue asking money, 2 - launchpad
def MessageBuffer = $C1B0                                   ;used to write a message, character by character, using stripe format.
def MessageLineBuffer = $C1B6                               ;used to move the second line to scroll the message

def CounterUpdateBuffer = $C1D6                             ;store stripe data to then transfer into main buffer

def TeleportationTimer = $C1F6                              ;counts up when teleporting. if bit 7 was enabled at the start, the player will be sent to land select. bit 6 indicates player being on the other side of the teleportation
def PauseFlag = $C1FD

;fairly certain the first entity is always player
;entity RAM is between $C200 and $C2FF. each entity reserves 16 bytes, e.g. $C200-$C20F - entity 0, $C210-$C22F - entity 1, etc

;$C20E - entity's behavior pointer

;$C300-$C3FF - also entity memory, also 16 bytes per entity

;current entity is actually $C600?

;$C600-$C61F - copied from entity RAM for current entity variables
def CurrentEntity_YPosScreenRelative = $C601
def CurrentEntity_XPosScreenRelative = $C603
def CurrentEntity_AnimationFrame = $C605
def CurrentEntity_DataPointer = $C60E                       ;points to a set of data used by the entity, various properties and stuff
;C610 - entity ID?
def CurrentEntity_WaitTimer = $C617                         ;counts down until zero, stops data parsing

def FrameCounter = $C620                                    ;16-bit frame counter

def CursorYPos = $C623
def CursorXPos = $C624
def GameMode = $C625                                        ;0 - title screen, 1 - land select, 2 - game, 3 - unknown
def SelectedDifficulty = $C626                              ;0 - easy, 1 - normal, 2 - difficult

def CurrentLand = $C628                                     ;what level we're in.
def Unknown_C629 = $C629                                    ;set to $FF when starting the game, but never referenced.
def LandBeatenFlags = $C62A                                 ;each level reserves a flag, indicating that it's been beaten. 5 bytes
def LandBeatenFlag_Amazon = $C62A
def LandBeatenFlag_Transylvania = $C62B
def LandBeatenFlag_AfricanMines = $C62C
def LandBeatenFlag_Himalayas = $C62D
def LandBeatenFlag_Moon = $C62E

def CameraPositionY = $C635
def CameraPositionX = $C636

;$C640 - $C650 - level-related data

def TileDetectionArray = $C900                              ;Used by the player to detect their surroundings, basically copies visible blocks and uses them to tell how the player should react

;$CA0E and $CA0F are also timer-related due to how it uses the same counter code as for money. they aren't actually used but decrease like normal.
def Timer = $CA10
def MoneyTotal = $CA12                                      ;4 bytes
def MoneyCurrent = $CA16                                    ;4 bytes
def PlayerLives = $CA1A
def PlayerHealthMax = $CA1B
def PlayerHealth = $CA1C

def GFXDecompressionBuffer = $CA1F

def Player_State = $DF50
def Player_AnimationFrame = $DF51
def Player_PogoFlag = $DF5A                                 ;using cane in air
;$DF5E - a flag indicating that the player is holding against a solid object for an extended amount of time, can use cane to hit that something
def Player_InvincibilityTimer = $DF68
def MessageQueue = $DF6A                                    ;will display the message stored there

def ScreenShakeTimer = $DF71                                ;handles screen shaking and SFX. note that it does not decrement on its own

def OAMUploadCode = $FF80                                   ;code in RAM

def JoypadInputHolding = $FF8B
def JoypadInputPress = $FF8C

;FF8F-FF90 - temporary pointer RAM
def VBlankWaitCounter = $FF91                               ;used to tell the game to wait for VBlank code. counts down for every VBlank hit.
def InterruptDisablerMirror = $FF92
def CurrentProgramBank = $FF93
;$FF94 - temporary?

def SFXQueue = $FFA9                                        ;used to play SFX and music
def CurrentMusic = $FFAA
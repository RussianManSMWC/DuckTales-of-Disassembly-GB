;CONSTANTS here
def JoypadInput_A = %00000001
def JoypadInput_B = %00000010
def JoypadInput_Select = %00000100
def JoypadInput_Start = %00001000
def JoypadInput_Right = %00010000
def JoypadInput_Left = %00100000
def JoypadInput_Up = %01000000
def JoypadInput_Down = %10000000

def StripeImageCommand_Repeat = %10000000                   ;bit 7 will make repeat writes of one value
def StripeImageWriteCommand_Stop = $00                      ;command to stop VRAM write and return from routine.

def BGTile_Blank = $6E

;easy OAM props, don't change these
def OAMProp_BGPriority = %10000000
def OAMProp_YFlip = %01000000
def OAMProp_XFlip = %00100000
def OAMProp_Palette0 = %00000000
def OAMProp_Palette1 = %00010000
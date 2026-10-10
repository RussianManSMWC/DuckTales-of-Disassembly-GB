;level name pointers! these are used for after clearing the level. stage select strings are separate.
LandClearLandNames_02_648A:
dw LandName_TheAmazon_02_6494
dw LandName_Transylvania_02_64A2
dw LandName_AfricanMines_02_64B2
dw LandName_TheHimalayas_02_64C3
dw LandName_TheMoon_02_64D4

LandName_TheAmazon_02_6494:
dwb $9904
db 10
db "THE AMAZON"

db StripeImageWriteCommand_Stop

LandName_Transylvania_02_64A2:
dwb $9904
db 12
db "TRANSYLVANIA"

db StripeImageWriteCommand_Stop

LandName_AfricanMines_02_64B2:
dwb $9904
db 13
db "AFRICAN MINES"

db StripeImageWriteCommand_Stop

LandName_TheHimalayas_02_64C3:
dwb $9904
db 13
db "THE HIMALAYAS"

db StripeImageWriteCommand_Stop

LandName_TheMoon_02_64D4:
dwb $9904
db 8
db "THE MOON"

db StripeImageWriteCommand_Stop
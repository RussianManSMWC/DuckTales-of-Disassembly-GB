;clear status bar, it's now a dialogue box
Layout_MessageBox_00_3C3C:
dwb $9C80
db 20
db $4D,$4E,$4E,$4E,$4E
db " MESSAGE "
db $4E,$4E,$4E,$4E,$4E,$4F

dwb $9CA0
db 1
db $68

dwb $9CA1
db 18|StripeImageCommand_Repeat
db $6E

dwb $9CB3
db 1
db $78

dwb $9CC0
db 1
db $68

dwb $9CC1
db 18|StripeImageCommand_Repeat
db $6E

dwb $9CD3
db 1
db $78

dwb $9CE0
db 1
db $5D

dwb $9CE1
db 18|StripeImageCommand_Repeat 
db $5E

dwb $9CF3
db 1
db $5F

db StripeImageWriteCommand_Stop
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
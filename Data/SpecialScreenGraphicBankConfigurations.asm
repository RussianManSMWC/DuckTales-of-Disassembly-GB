;high nibble - bank to switch to
;low nibble - pointer offset (pointers at the beginning of the respective bank)
TitleScreenGraphicBanks_01_7A97:
TitleScreenGraphicBanks_JP_00_0288:
db $30,$3D,$3E,$3F,$29,$3D

LandSelectGraphicBanks_01_7A9D:
LandSelectGraphicBanks_JP_00_028E:
db $2F,$3D,$2C,$29,$2F,$3D

EndingChestGraphicBanks_01_7AA3:
EndingChestGraphicBanks_JP_00_0294:
db $30,$31,$2C,$2F,$38,$3D

EndingDuckPressGraphcBanks_01_7AA9:
EndingDuckPressGraphcBanks_JP_00_029A:
if Version != VERSION_JP
;identical to previous set of graphic banks. curious
  db $30,$31,$2C,$2F,$38,$3D
else
;turns out that's because it's different in japanese version! different font of course
  db $30,$31,$2C,$2F,$29,$3D

;additional bank configuration for nephews, who speak japanese. it's either scrooge or katakana
EndingCharacterPortraitGraphicBanksNephews_JP_00_02A0:
  db $30,$34,$3E,$29,$2F,$3D
endc

EndingCharacterPortraitGraphicBanks_01_7AAF:
EndingCharacterPortraitGraphicBanks_JP_00_02A6:
db $30,$34,$3E,$3F,$2F,$3D
;change below to alter what version to compile.
;valid values: VERSION_USA, VERSION_EU, VERSION_JP
def Version = VERSION_USA

db "DUCK TALES",$00,$00,$00,$00,$00                         ;title
db $00                                                      ;Game Boy game (not game boy color only or game boy color enhanced)
db $00,$00                                                  ;new license (this game was made before that was a thing)
db $00                                                      ;Super Game Boy flag (made before Super Game Boy, so no extra features)
db $01                                                      ;Cart type = ROM. nothing fancy.
db $01                                                      ;ROM size = 64KB
db $00                                                      ;extra RAM = none
if Version == VERSION_JP
  db $00                                                    ;region = japan
else
  db $01                                                    ;region = non-japan
endc
db $08                                                      ;old licensee = Capcom
db $00                                                      ;version 1.0 so to speak

if Version == VERSION_JP
  db $1D                                                    ;header checksum (different for japanese ver)
else
  db $1C                                                    ;header checksum
endc

if Version == VERSION_USA
  db $A3,$DD                                                ;global checksum
elif Version == VERSION_EU
  db $85,$13                                                ;global checksum but different
else
  db $9F,$69                                                ;global checksum but from japan
endc
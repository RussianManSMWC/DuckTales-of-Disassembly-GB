#extract all graphics from ducktales for the game boy.
#simply run it with DuckTales.gb in the same folder. all generated graphics data will be in the output folder. move them to Data/Graphics to make the disassembly work.
#NOTE: currently only supports US version.

import os

ROM = "DuckTales.gb" #game's ROM
OutputFolder = "CompressedOutput"

def extract_byteToInt(byte):
    byte_to_int = int.from_bytes(byte, byteorder='little')
    return byte_to_int

#where all graphics are located in the ROM.
GraphicsPointers = (
0xA61F,
0xA631,
0xA99B,
0xAD62,
0xB13A,
0xB4F0,
0xB8A3,
0xBC68,
0xC320,
0xC6CF,
0xCAA3,
0xCE7B,
0xD25D,
0xD5F6,
0xD9CD,
0xDD97,
0xE151,
0xE525,
0xE8BE,
0xEC9A,
0xF04C,
0xF424,
0xF768,
0xFAA3
)

GraphicsNames = (
"Blank.bin",
"JapaneseFont.bin",
"TransylvaniaSprites.bin",
"MoonSprites.bin",
"BossGFX1.bin",
"BossGFX2.bin",
"BossGFX3.bin",
"MonitorAndEndingChest.bin",
"PlayerSprites1.bin",
"PlayerSprites2.bin",
"AmazonSprites1.bin",
"AmazonSprites2.bin",
"SupportingCharacters.bin",
"AfricanMinesSprites.bin",
"HimalayasAndTransylvaniaSprites2.bin",
"HimalayasSprites.bin",
"AmazonTileset.bin",
"HimalayasTileset.bin",
"TransylvaniaTileset.bin",
"AfricanMinesTileset.bin",
"MoonTileset.bin",
"EnglishFontAndStatusBar.bin",
"TitleScreen.bin",
"Ending.bin"
)

try:
    os.mkdir(OutputFolder)                #generate CompressedOutput folder from script's position, I think
except:
    pass

with open(ROM, "rb") as inFile:
    for i in range(0, len(GraphicsPointers)):
        inFile.seek(GraphicsPointers[i])
        b = 0
        print("currently generating "+GraphicsNames[i])
        with open(OutputFolder+"/"+GraphicsNames[i], "wb") as outFile:
            key = inFile.read(1)
            outFile.write(key)
            while 1:
                if b > 1024: #if size is way too big...
                    raise ValueError("Somehow the while loop got stuck! Are you sure you're extracting graphics from the correct ROM?")
                else:
                    currentByte = inFile.read(1)
                    if currentByte == key:
                        outFile.write(key)
                        immediateByte = inFile.read(1)
                        if extract_byteToInt(immediateByte) == 0:
                            outFile.write(immediateByte)
                            break #get outta here! neext!
                        else:
                            outFile.write(immediateByte)
                            outFile.write(inFile.read(1))
                    else:
                        outFile.write(currentByte)
                
                b+=1
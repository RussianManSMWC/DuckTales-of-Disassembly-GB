#once you're done editing DuckTales GB graphics data, feed it into this script to compress it for use in the game.

import sys
import os

CompressFile = sys.argv[1]
CompressFolder = "CompressedOutput"
CompressedFile = CompressFolder+"/"+os.path.basename(CompressFile).split('/')[-1]

def extract_byteToInt(byte):
    byte_to_int = int.from_bytes(byte, byteorder='little')
    return byte_to_int

try:
    os.mkdir(DecompressFolder)                #generate DecompressFolder folder from script's position, I think
except:
    pass

keyByte = 1                 #key byte cannot be 0... i think
b = 0
with open(CompressFile, "rb") as inFile:
    #step 1 - decide on the key byte
    while b < 1024:
        if keyByte == extract_byteToInt(inFile.read(1)):
            keyByte += 1
            #check if the pixel art is somehow too populated... varied... whatever
            if keyByte > 0xFF:
                raise ValueError("Cannot generate key byte and compress the file! Make sure to have some free pixel data formation that would serve as a key byte!")
            b = 0
            inFile.seek(b) #start over
        b+=1

    #step 2 - generate compressed data
    inFile.seek(0) #reset where we are in the file that we're compressing
    with open(CompressedFile, "wb") as outFile:
        #write key byte as the first byte
        outFile.write(keyByte.to_bytes())
        b = 0
        var1 = inFile.read(1)               #4 consecutive bytes, used to check for a repeat to compress
        var2 = inFile.read(1)
        var3 = inFile.read(1)
        var4 = inFile.read(1)
        while 1:
            if b == 1024:
                outFile.write(keyByte.to_bytes())
                outFile.write(int.to_bytes(0x00))
                break
            elif b > 1024:
                raise ValueError("Uh oh! Couldn't compress for some reason. Went over the file size of 1KB.")

            #check if we should have compression here
            #at least 4 consecutive bytes must match to compress them
            if (var1 == var2) and (var1 == var3) and (var1 == var4):
                b+=3
                outFile.write(keyByte.to_bytes()) #key byte, then amount of repeats
                repeatCount = 4 #at least 4 bytes of repeat
                while 1:
                    nextByte = inFile.read(1)
                    b+=1
                    if b == 1024:
                        #repeatCount+=1
                        outFile.write(repeatCount.to_bytes())
                        outFile.write(var1)
                        break
                    if nextByte == var1:
                        if repeatCount == 0xFF:
                            outFile.write(repeatCount.to_bytes())
                            outFile.write(var1)
                            var1 = nextByte
                            var2 = inFile.read(1)
                            var3 = inFile.read(1)
                            var4 = inFile.read(1)
                            break
                        else:
                            repeatCount+=1
                    else:
                        outFile.write(repeatCount.to_bytes())
                        outFile.write(var1)
                        var1 = nextByte
                        var2 = inFile.read(1)
                        var3 = inFile.read(1)
                        var4 = inFile.read(1)
                        break
            else:
                # a normal byte write
                outFile.write(var1)
                var1 = var2
                var2 = var3
                var3 = var4
                var4 = inFile.read(1)
                b+=1

            
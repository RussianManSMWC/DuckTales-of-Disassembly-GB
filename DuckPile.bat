rgbasm -o DuckTalesGBDis.o DuckTalesGBDis.asm
rgblink -o DuckTalesGBDis.gb DuckTalesGBDis.o -p 255
pause
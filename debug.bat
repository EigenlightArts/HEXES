start "" /B "C:/Users/Kaleidosium/Code/HEXES/mGBA-dev/mGBA.exe" -g HEXES.elf
sleep 4
C:\devkitPro\devkitARM\bin\arm-none-eabi-gdb.exe HEXES.elf -ex "target remote localhost:2345"
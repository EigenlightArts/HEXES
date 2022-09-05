start "" /B "C:\Program Files\mGBA\mGBA.exe" -g HEXES.elf
sleep 4
C:\devkitPro\devkitARM\bin\arm-none-eabi-gdb.exe HEXES.elf -ex "target remote localhost:2345"
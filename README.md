## BIOS Build 

### Compile 

  `ca65 file.s` 

### Link

  `ld65 -C bios.cfg file.o` 

### Check image 

  `hexdump -C a.out`
  
### Write to EPROM

  `minipro -p AT28C256 -w a.out` 
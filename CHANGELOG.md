Changelog

0.7.6		06/09/25

	Updated CSpect 3.0.2.0 - This now uses new BREAK DB $FD, $00 macro 
	
	Added 	mini2.bas with joystick example (thanks danboid)		#34

	Fixed 	truncating line : outstring += '!BMP8'+bmpfile[:-1]+',0,0,0,0,255' + CRLF 
			when creating a NEX with a BMP 

	Fixed 	LoadSDBank should now work realtime when no #DEFINE NEX is used
			for clarity : when #DEFINE NEX is used, LoadSDBank becomes an empty
			macro that instructs NextBuild to include the file into the NEX at the 
			correct memory location when generating the NEX. Without #DEFINE NEX the 
			file is loaded at run time into the reqeusted bank 

    updated Move to yaml release file
	
0.7.52a		25/11/24 7.52a
			minor package update removing unnecessary .git files, reducing the downloading size.

0.7.52		12/04/24
			update 4bit-Sprite.bas to include BinToString()
			fixed out of date links and readmes, more complete PDF

0.7.51		10/03/24
			Updated nextbuild.py now generates [filename].map
			added InitSprites2(byVal Total as ubyte, spraddress as uinteger,bank as ubyte, sprite as ubyte=0)

0.7.3.1	Fixed 1MB / 2MB NEX generation

0.7	Now using VSCode

0.6	28/09/18

	Updated to use CSpect v1.8 by Mike Dailly please see the readmes in \Emu\cspect
	
	Added Shiru's AYFX engine, can be manually called or initiate an IM routine
	Added Layer2 Plot : PlotL2(x,y,colour[0-255])
	Added ULA faster plot using PIXELADD : fPlot(x,y)
	Added userdefinable commands into scripts using a post compiler parser, this required a rewrite of some of the build scripts:
	
	eg. these can be added to the top of your source file :
	
	'!sna "h:\stars2.sna" -a       					; this will copy the compiled.sna to h:\stars.sna, the - a will create a new autoexec.bas
	'!exec "del h:\nextzxos\autoexec.bas"			; this will execute the command line "del h:\nextzxos\autoexec.bas" (in effect deleting my autoexec.bas from my flashair)
	'!bin "final.bin"								; creates a copy of the temp.bin to "final.bin"
	'!noemu											; dont launch emulator when compiling
	'!data -f "h:\data"								; will copy new files in the data folder to "h:\data", -f to copy all 
	'!v 											; this is verbose post compiler, useful for debugging postcompiler issues and off by default

	Added ability to change "Start Address" instead of always being fixed at 24576
	
	Optimized ScrollLayer2(x,y)
	

0.4b 
	Massive update!
	Now includes the NextLib which can be used with including : 
	
	#INCLDUE <nextlib.bas> 
	
	in your program and facilatates the following NEW commands to use
	
	**SD Card :
	LoadSD(filename$,address,length,offset)	; Loads from SD card
	SaveSD(filename$,address,length)	; Saves to SD card 
	LoadBMP(filenam$)					; loads bmp to layer2 
		
	NOTE : in your project folder SD access files should be in the data folder. Compile includes
			should be in the root of your project folder.
		
	**Layer2:
	ShowLayer2(1=on 0 off)
	ScrollLayer(X,Y)
	InitSprites(Number of sprites to upload, address of data)
	UpdateSprite(X,Y,sprite slow,sprite image,mirror & flip)
	LoadBMP(filename$)
	DoTile(x,y,tile number) 	;  16x16px tiles start at $c000
	DoTile8(x,y,tile number) 	;  8x8px tiles start at $c000
	PalUpload(address of palette,colours to upload,start from offet)
	CLS256(colour)
	TileMap(address of tilemap, start offset,number of tiles)   ; this is for 8x8 tiles 
	ClipLayer2(x1,x2,y1,y2)		; clips layer 2 defaults 0,255,0,191
	MMU(slot,bank number) 		; swaps in 8kb memory page into slots 0-7 $0000-$1fff, $2000-$3fff, $4000-$5fff, 
									; $6000-$7fff,$8000-$9fff,$a000-$bfff,$c000-$dfff,$e000-$ffff	
									; normal bank paging is carried out on slots 6 & 7 $c000-$ffff
	bank=GetMMU(slot)			; returns 8kb memory bank in slot
	NextReg(reg,val)				; this is a macro for $91ED
	NextRegA(reg,val)				; this sets a with val and does $92ED 
	
	zx7Unpack(source,destination)	; decompressor from the amazing Eianr Saukas 
		
	Fixes :
	
	Now detects when the compialtion fails and shows the logs rather than running the emulation (Thanks Johnny)
	Array check has been renamed "Launch Fuse" in BorIDE and fixed to work properly
	Now store the data files inside the data directory in your project folder, the MMC for CSpect
	will be automatically mapped. 
	Fixed crashes on certain commands (Print32/64/str etc) that relied on zxbasic sysvars being set
	Cleaner output in the compile console 
	BorIDE moved to own folder and start address adjusted to always be 24576 and heap 1000
	Lots of stuff cleaned up and tidied up. 
	In CSpect debugger the address labels are shown in the debugger with F1, F7 step
	
0.3b
	Now autosets the compiler / last dir in the BorIDE config 
	Refactered Scripts
	Removed lots of redundant data files that were left over from testing


	
0.2b
	Intial release

	Bugs:
	DetectBlock isnt working on scrolling yet
	
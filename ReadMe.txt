NextBuild v0.6 28/9/2018 David Saphier
---------------------------------------
http://zxbasic.uk/NextBuild/

Note! If you compile and get and error make sure you havent got the CSpect or Fuse still open
or that you dont have the error log showing!

What does it contain?

Boriel's ZX Basic (ZXB) - A PC based language which resembles ZX Basic but allows 
SUBs/FUNcs inline ASM and a bunch of other features and is SUPER fast. By Jose Rodriguez
LCD's BorIDE - An integrated editor designed for Boriel's ZXB Daniel Chmielewski
CSpect - One of the premiere ZX Spectrun Next emulators By Mike Dailly full download is 
located in \Emu\cspect\

Thanks to the many wonderful people that have helped, such Michael Flash Ware for the Tile print code,
Jose for his support, Mike Dailly for code examples, Gary Lancaster for his inpsiration in NextZXOS, 

Fuse - Probably the fastest and most reliable ZX Spectrum emulator by Philip Kendall et al

This is a collection of tools to allow you to write software for the ZX Spectrum Next (and normal
spectrum if you use Fuse). It aims to simplify the process by having a one-click launcher into an 
editor, then press F5 to build and should launch in CSpect.

Scripts, NextLib and launchers by Me.

As mentioned ZXB lets you use inline ASM so creating macros and includes to control the Next 
hardware is easily done as well as being very much like ZX Basic but much much faster! 
There is a whole wiki dedicated to ZXB http://boriel.com/wiki/en/index.php/ZXBasic

Instructions
------------

Extract to a folder and then double click NextBuild.exe - thats it!

When BorIDE starts it will try and launch CSpect, this is a good test to see if it works on
your system. 

Now you're ready to code. You can click Project / Open and choose from one of the examples in
Sources folder. 

Press F9 to build and run the emulator. 

Tips
----

If you tick "Launch Fuse" on the left hand side, it will launch in Fuse rather than CSpect.


Changlog

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
	
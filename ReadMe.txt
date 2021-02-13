
NextBuild v0.7.2  13/02/21	em00k / David Saphier

Thanks to Jose & Jari 

v.7 on has been engineered to work best with VSCode, please do 
take the time to try it out, nextbuild can work on Windows, Linux
and Mac. You can still use BorIDE but this now offers the least 
amount of features. 

When you install VScode, choose Open Folder and point to the "Sources"
folder inside \Nextbuild. VSCode will ask to install all the required
extensions for code completion and snippets. 

See https://www.youtube.com/watch?v=kF_jfE7mAvg how to setup for Win.

Now produces NEX & BIN files. Please see examples
Reworked for Visual Studio Code, extension for syntax and code snippets 
Lots of bugs fixed 
New interrupt AYFX & Music Player routines

InitSFX(bank)		bank with ayfx afb in 
InitMusic(playerbank,musicbank,offset in music bank)
SetUpIM2()
EnableSFX
EnableMusic

Build scripts replaced with python script

NextBuild v0.7 9/12/2020b em00k / David Saphier

LoadSDBank(fname,add,len,off,bank)
DoTileBank16(x,y,tile,bank b)
L2Text(x,y,message,font bank)

WaitRetrace(nr frames)

Note the order of arguments 

320x256 L2 commands 

FPlotL2(x,y,colour)
FL2Text(x,y,,string,font bank)	
FDoTile8(tile,x,y,bank)  
FDoTile16(tile,x,y,bank)

New commands

LoadSDBank(fname,add,len,off,bank)

Loads data from SD card into a bank. This is one of the most versatile new commands. This routine 
takes care of all the banking requirments. If you load a file larger than 8kb, the next consecutive
bank is paged in meaning you can load files of any size.

This is also usefule for creating NEX files. All the LoadSDBank commands can be disabled using 

#DEFINE NEX 

before the nextlib.bas include. This is useful if you have a source code parser that can then
generate a nexcreator config file with the information on what banks need to be populated in your NEX.

fname = filename$
address = 0  - 16383
	This is the address offset into the start bank. 
lenght = 0 - MASSIVE
	This instructs the Next to load X amount of bytes, if you set this to ZERO the size will be 
	automatically detected. 
off	= 0 - MASSIVE
	This is the offset into the file you are loading. Please note if you are using a post
	compiler processor that current nexcreators dont support including files with an offset. 
bank = 0 - 227 
	This is the base bank to start loading. When the loaded amount of data exceeds 8192 bytes
	the next bank is paged in. You can load files of any size using this routine. 
eg. Load a file called "test.bin" to bank 36 - I dont know the filesize

	LoadSDBank("test.bin",0,0,0,36) 
	
Load a file called "test.bin" to bank 36 with offset in ram by $0200 bytes  - I dont know the filesize 

	LoadSDBank("test.bin",$200,0,0,36) 
	
Load a file called "test.bin" to bank 36, only load first 1024 bytes  - I dont know the filesize 

	LoadSDBank("test.bin",0,1024,0,36) 
	
Load a file called "test.bin" to bank 36 skipping first 1078 bytes  - I dont know the filesize 	

	LoadSDBank("test.bin",0,0,1078,36)
	
I would recommend offset in files to only be used whule in development, when creating the final 
product it would be better to trim unwanted bytes off files. 
############################## ###==- Tile Commands -==### ##############################

DoTileBank16(x,y,tile,bank b)

Displays a 16x16 tile on to Layer2, from bank b

x = 0 - 15, y = 0 - 11, tile 0 - 256, bank = base bank in which tile data exists
Normally only 64 16x16 tiles can be printed with DoTile but DoTileBank16 allows you to load 
tile data into consecutive banks and will automatically increase the bank number should the 
tile > 64. 
L2Text(x,y,message,font bank)

This displays text on Layer 2 256x192

x = 0 - 31, y = 0 - 23, message = string to print, font is the bank where the font is stored (8x8)
Font must be in ascii order 
############################## ###==- 320x256 commands -==### ##############################

FPlotL2(x,y,colour) (F=Fullscreen)

Plots a pixel on L2 320x256
x = 0 - 319, y = 0 - 255, colour = 0 - 255
FDoTile8(tile,x,y,bank)

Draws an 8x8px tile on to L2 320x256
tile = 0 - 255, x = 0 to 39, y = 0 to 31

**** Need to add banking 
FDoTile16(tile,x,y,bank) (F=Fullscreen)

Draws a 16x16px tile on L2 320x256 
tile = 0 - 255, x = 0 - 19, y = 0 - 15

This works the same as DoTileBank16, in which you can load consecutive banks with tile data then 
you can specify a tile up to 255 and banking is automatically handled 
############################## ###==- Misc -==### ##############################

WaitRetrace(nr frames)

Waits a number of frames before exiting 

nr frames = 0 - 65535
ConvertRGB(bank)

Converts data in a bank from RGB333 PAL to Next Colours. This colours are applied to L2. 

bank = bank where the PAL data is stored. 


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
	
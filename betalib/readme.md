v7.0 8/12/20

Commands 

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
		
eg. 
	Load a file called "test.bin" to bank 36 - I dont know the filesize 
	
		LoadSDBank("test.bin",0,0,0,36) 
		
	Load a file called "test.bin" to bank 36 with offset in ram by $0200 bytes  - I dont know the filesize 

		LoadSDBank("test.bin",$200,0,0,36) 
		
	Load a file called "test.bin" to bank 36, only load first 1024 bytes  - I dont know the filesize 

		LoadSDBank("test.bin",0,1024,0,36) 
		
	Load a file called "test.bin" to bank 36 skipping first 1078 bytes  - I dont know the filesize 	

		LoadSDBank("test.bin",0,0,1078,36)
		
	I would recommend offset in files to only be used whule in development, when creating the final 
	product it would be better to trim unwanted bytes off files. 

##############################
###==- Tile Commands    -==###
##############################

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

##############################
###==- 320x256 commands -==###
##############################

FPlotL2(x,y,colour)					(F=Fullscreen)

	Plots a pixel on L2 320x256
	x = 0 - 319, y = 0 - 255, colour = 0 - 255

FDoTile8(tile,x,y,bank)   

	Draws an 8x8px tile on to L2 320x256
	tile = 0 - 255, x = 0 to 39, y = 0 to 31
	
	**** Need to add banking 

FDoTile16(tile,x,y,bank)			(F=Fullscreen)

	Draws a 16x16px tile on L2 320x256 
	tile = 0 - 255, x = 0 - 19, y = 0 - 15
	
	This works the same as DoTileBank16, in which you can load consecutive banks with tile data then 
	you can specify a tile up to 255 and banking is automatically handled 

##############################
###==- Misc			    -==###
##############################

WaitRetrace(nr frames)

	Waits a number of frames before exiting 

	nr frames = 0 - 65535

ConvertRGB(bank)

	Converts data in a bank from RGB333 PAL to Next Colours. This colours are applied to L2. 
	
	bank = bank where the PAL data is stored. 
	
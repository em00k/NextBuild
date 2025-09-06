ZXSpectrum emulator by Mike Dailly (c) Copyright 1998-2024 All rights reserved

Be aware...emulator is far from well tested, and might crash for any reason - sometimes just out of pure spite!

NOTE: DISTRIBUTION WITH COMMERCIAL TITLES IS NOT PERMITTED WITHOUT WRITTEN CONSENT.

Installing
----------
Windows - You will need the latest .NET, and openAL ( https://www.openal.org/downloads/ )
Linux   - You will need the full MONO  (on ubuntu do "apt-get install mono-devel" )
OSX     - You will need the latest mono from https://www.mono-project.com/


NXtel release
-------------
NXtel is written by SevenFFF / Robin Verhagen-Guest and is 
(c) Copyright 2018,2019, all rights reserved, and released under the GPL3 License.
( see license here: https://github.com/Threetwosevensixseven/NXtel/blob/master/LICENSE)
Latest versions can be found here: https://github.com/Threetwosevensixseven/NXtel/releases


Command Line Options
======================================================================================
-zxnext            =  enable Next hardware registers
-nextrom           =  enable the Next ROM (SD card image required)
-zx128             =  enable ZX Spectrum 128 mode
-s7                =  enable 7Mhz mode
-s14               =  enable 14Mhz mode
-s28               =  enable 28Mhz mode
-exit              =  to enable "EXIT" opcode of "DD 00"
-brk               =  to enable "BREAK" opcode of "FD 00"
-esc               =  to disable ESCAPE exit key (use exit opcode, close button or ALT+F4 to exit)
-cur               =  to map cursor keys to 6789 (l/r/d/u)
-8_3               =  set filenames back to 8.3 detection
-mmc=<dir\ or file>=  enable RST $08 usage, must provide path to "root" dir of emulated SD card (eg  "-mmc=.\" or "-mmc=c:\test\")
-sd2=<path\file>   =  Second SD card image file
-map=<path\file>   =  SNASM format map file for use in the debugger. format is: "<16bit_address> <24bit_physical_address> <type> <primary_label>[@<local>]"
-sound             =  disable sound
-joy               =  disable joysticks
-w<size>           =  set window size (1 to 4)
-r                 =  Remember window settings (in "cspect.dat" file, just delete the file to reset)
-16bit             =  Use the logical (16bit) addresses in the debugger only
-60                =  60Hz mode
-fullscreen        =  Startup in fullscreen mode
-vsync             =  Sync to display (for smoother scrolling when using "-60 -sound", but a little faster)
-com="COM?:BAUD"   =  Setup com port for UART. i.e. -com="COM5:115200". if not set, coms will be disabled.
-basickeys         =  Enable Next BASIC key interface (F10 toggles)
+tv                =  Enable the TV shader (or CTRL+F1)
-emu               =  Enable the emulator "bit" in the hardware registers
-major=<value>     =  Sets the value returned by NextReg $01
-minor=<value>     =  Sets the value returned by NextReg $0E
-debug             =  start up in the debugger
-remote            =  Enable the remote debugger mode, by disabling the debugger screen.
-fill=$XXXXX...XX  =  Fill memory with this hex sequence on power up
-rewind            =  Enable CPU history for debugger rewinding
-analytics         =  Disable analytics. Please if you can, leave these on as it'll help direct developement effort.
-fps               =  Display FPS in titlebar
-freerun           =  Disable all timer locks and run as fast as we can (must use -sound as well)
+def[0-9]"text"    =  Debugger macro command, executed using ALT+[0-9] allowing handy pre-defined bookmarks
-divmap            =  Disable the DivMMC automapping (might speed things up for some people)
-nodelay           =  Do not wait for NEX file delay (used to display title screens etc)
-mouse             =  Disable mouse capture
-threaded          =  Enable the experimental threaded renderer


Manual SDCARD setup 
-------------------
NOTE: You can get a pre-made image here: http://www.zxspectrumnext.online/cspect/
unzip this file - and the contained ROM files into a folder (SD_CARD_PATH)

Making an image yourself
------------------------
Download the latest SD card from https://www.specnext.com/category/downloads/
Copy onto an SD card (preferably 2GB and less than 16GB as it's your Next HD for all your work)
Copy the files "enNextZX.rom" and "enNxtmmc.rom" from this SD Card into the root of the CSpect folder
Download Win32DiskImager ( https://sourceforge.net/projects/win32diskimager/ )
make an image of the SD card
start CSpect with the command line... 

Running
-------
"CSpect.exe -w3 -zxnext -nextrom -mmc=<SD_CARD_PATH>\sdcard.img"

I'd also recommend downloading HDFMonkey, which lets you copy files to/from the SD image. 
This tool can be used while CSpect is running, meaning you can just reset and remount the image
if you put new files on it - just like the real machine.
This tool also lets you rescue files saved onto the image by #CSpect - like a BASIC program
you may have written, or a hiscore file from a game etc.
I found a copy of this tool here: http://uto.speccy.org/downloads/hdfmonkey_windows.zip




General Emulator Keys
======================================================================================
Escape  - quit
F1      - Enter/Exit debugger
F2      - load SNA
F3      - reset
F5      - Take screenshot
F6      - Cycle through different speeds (3.5,7,14 and 28)
F8      - Toggle VSync
F10     - Toggle Key mode


Standard Plugin Keys
======================================================================================
CTRL+ALT+C          Copper Disassembler
CTRL+ALT+X          Show copper wait lines, and IRQs
CTRL+ALT+R          Show Next Register window
CTRL+ALT+SHIFT+A    Assosiate .SNX and .NEX fies to this EXE
CTRL+ALT+P          Bring up the profiler
CTRL+ALT+S          Show sprite viewer

Debugger Keys
======================================================================================
F1                  - Exit debugger
F2                  - load SNA
F3                  - reset
F7                  - single step
F7+SHIFT            - Rewind CPU (when active)
F8                  - Step over (for loops calls etc)
F9                  - toggle breakpoint on current line
Up                  - move user bar up
Down                - move user bar down
PageUp              - Page disassembly window up
PageDown            - Page disassembly window down
SHIFT+Up            - move memory window up 16 bytes
SHIFT+Down          - move memory window down 16 bytes
SHIFT+PageUp        - Page memory window up
SHIFT+PageDown      - Page memory window down
CTRL+SHIFT+Up       - move trace window up 16 bytes
CTRL+SHIFT+Down     - move trace window down 16 bytes
CTRL+SHIFT+PageUp   - Page trace window up
CTRL+SHIFT+PageDown - Page trace window down
CTRL+SHIFT+[1-0]    - Set memory window bookmark
CTRL+[0-9]          - Goto memory window bookmark
ALT+[0-9]           - Playback command line definition

Mouse is used to toggle "switches"
HEX/DEC mode can be toggled via "switches"

You can also use the mouse to select "bytes" to edit in the memory window, simply place 
mouse over the top and left click. Enter will cancel, as will clicking outside the
memory window.


Debugger Commands
======================================================================================
M <address>         Set memory window base address (in normal 64k window)
M <bank>:<offset>   Set memory window into physical memory using bank/offset
G <address>         Goto address in disassembly window
BR <address>        Toggle Breakpoint
BR <bank>:<offset>  Toggle Physical address breakpoint
WRITE <address>     Toggle a WRITE access break point
READ  <address>     Toggle a READ access break point (also when EXECUTED)
INPORT <16bitport>  Toggle a breakpoint on port READ
OUTPORT <16bitport> Toggle a breakpoint on port WRITE
PUSH <value>        push a 16 bit value onto the stack
POP				    pop the top of the stack
POKE <add>,<val>    Poke a value into memory
TONE                Toggles a single tone to be played back. Testing the audio streaming is consistent and working
NEXTBRK             Toggles stopping in the debugger after a NEXT specific instruction is executed
Registers:
   A  <value>       Set the A register
   A' <value>       Set alternate A register
   F  <value>       Set the Flags register
   F' <value>       Set alternate Flags register
   AF <value>       Set 16bit register pair value
   AF'<value>       Set 16bit register pair value
   |
   | same for all others
   |
   SP <value>       Set the stack register
   PC <value>       Set alternate program counter register
LOG OUT [port]      LOG all port writes to [port]. If port is not specified, ALL port writes are logged.
                    (Logging only occurs when values to the port change)
LOG IN  [port]      LOG all port reads from [port]. If port is not specified, ALL port reads are logged.
                    (Logging only occurs when values port changes)
NEXTREG <reg>,<val> Poke a next register	
OUT Port,Value      Out a value to a 16bit port
Set <Type>,<StartAddress>,<EndAddress>  Set a range of breakpoints, where TYPE is the breakpoint type (see below)
Clr <Type>,<StartAddress>,<EndAddress>  Clear a range of breakpoints, where TYPE is the breakpoint type (see below)
SAVE "NAME",add,len                     Save in the 64K memory space
SAVE "NAME",BANK:OFFSET,length          Save in physical memory using a bank and offset as the start address
SAVE "NAME",BANK:OFFSET,BANK:OFFSET     Save in physical memory using a bank and offset as the start address, and as an end address
LOAD "NAME",add[,len]                   Load in the 64K memory space with optional length
LOAD "NAME",BANK:OFFSET[,length]        Load in physical memory using a bank and offset as the start address, with optional length


Breakpoint Type 
---------------
Execute     -   0
Read        -   1
Write       -   2
OutPort     -   3
InPort      -   4


Symbol file format
======================================================================================
The symbol file is a simple list of values in this format

<16bit_address> <24bit_physical_address> <type> <primary_label>[@<local>]"

A symbols 24 bit address is (Bank*8192)+Offset
The TYPE can be one of these. If in doubt use FFFFFFFF.
00000000 = Label
00000001 = EQU or SET
FFFFFFFF = Unknown Label

You can force the use of the 16bit only value by specifying "-16bit" on the command line.


New Z80n opcodes on the NEXT
======================================================================================
   swapnib           ED 23           8Ts      A bits 7-4 swap with A bits 3-0
   mul               ED 30           8Ts      Multiply D*E = DE (no flags set)
   add  hl,a         ED 31           8Ts      Add A to HL (no flags set)
   add  de,a         ED 32           8Ts      Add A to DE (no flags set)
   add  bc,a         ED 33           8Ts      Add A to BC (no flags set)
   add  hl,$0000     ED 34 LO HI     16Ts     Add $0000 to HL (no flags set)
   add  de,$0000     ED 35 LO HI     16Ts     Add $0000 to DE (no flags set)
   add  bc,$0000     ED 36 LO HI     16Ts     Add $0000 to BC (no flags set)
   ldix              ED A4           16Ts     As LDI,  but if byte==A does not copy
   ldirx             ED B4           21Ts     As LDIR, but if byte==A does not copy
   lddx              ED AC           16Ts     As LDD,  but if byte==A does not copy, and DE is incremented
   lddrx             ED BC           21Ts     As LDDR,  but if byte==A does not copy
   ldpirx            ED B7           16/21Ts  (de) = ( (hl&$fff8)+(E&7) ) when != A
   ldws              ED A5           14Ts     LD (DE),(HL): INC D: INC L
   mirror a          ED 24           8Ts      Mirror the bits in A     
   push $0000        ED 8A LO HI     19Ts     Push 16bit immidiate value
   nextreg reg,val   ED 91 reg,val   20Ts     Set a NEXT register (like doing out($243b),reg then out($253b),val )
   nextreg reg,a     ED 92 reg       17Ts     Set a NEXT register using A (like doing out($243b),reg then out($253b),A )
   pixeldn           ED 93           8Ts      Move down a line on the ULA screen
   pixelad           ED 94           8Ts      Using D,E (as Y,X) calculate the ULA screen address and store in HL
   setae             ED 95           8Ts      Using the lower 3 bits of E (X coordinate), set the correct bit value in A
   test $00          ED 27           11Ts     And A with $XX and set all flags. A is not affected.
   outinb            ED 90           16Ts     OUT (C),(HL), HL++
   bsla de,b         ED 28           8Ts      shift DE left by B places - uses bits 4..0 of B only
   bsra de,b         ED 29           8Ts      arithmetic shift right DE by B places - uses bits 4..0 of B only - bit 15 is replicated to keep sign
   bsrl de,b         ED 2A           8Ts      logical shift right DE by B places - uses bits 4..0 of B only
   bsrf de,b         ED 2B           8Ts      shift right DE by B places, filling from left with 1s - uses bits 4..0 of B only
   brlc de,b         ED 2C           8Ts      rotate DE left by B places - uses bits 3..0 of B only (to rotate right, use B=16-places)
   jp (c)            ED 98           13Ts     JP  ((IN(c)*64)+PC&0xC000)"






#CSpect Plugins
======================================================================================
An example (empty) plugin is provided, along with the source to the Plugin interface

Write a DLL based on the iPlugin interface, and implement all members of that interface.

    // Type of access
    public enum eAccess
    {
        /// <summary>All READ data comes FROM this port</summary>
        Port_Read = 1,
        /// <summary>All WRITE data goes TO this port</summary>
        Port_Write = 2,
        /// <summary>All reads to this address come from this plugin</summary>
        Memory_Read = 3,
        /// <summary>All writes from this address come from this plugin</summary>
        Memory_Write = 4,
        /// <summary>Next register write</summary>
        NextReg_Write = 5,
        /// <summary>Next register read</summary>
        NextReg_Read = 6
    };


bool Write(eAccess _type, int _port, byte _value )
---------------------------------------------------
On write access this function is called with the access type, port and byte being written.
If you use the value passed, you can return TRUE to indicate you've used the value, and no 
more extensions or internal functions will be called.


byte Read(eAccess _type, int _address, out bool _isvalid)
---------------------------------------------------------
On read access to the requested address/port/reg, this function is called.
_isvalid should be set to true if you "use up" the value, or it'll be pased onto 
other plugins, or the internal functions will be called.


List<sIO> Init( iCSpect _CSpect )
---------------------------------
Initialise the plugin. iCSpect it an interface back into the emulator that allows you to
Peek,Poke, IN,OUT, and Set/Get Nextreg values.
returns a list of IO request structures.


void Quit()
-----------
Is called on exit, letting you free up unmanaged system resources.


void Tick()
-----------
Called one per game/frame refresh



DebugOut extension
======================================================================================
This adds a new "RST $18" command that will output text to the console. There are 2 ways to call this.

        ; HL should point to a null terminated string
		ld	hl,TestString
		RST	$18

The second method is.
		RST	$18
        db  $FF                        ; this is "RST $38" instruction
        dw  Message

If the second is used, the PC is set to after the last USED argument. NOTE: This will not run on actual hardware.
The second method will allow all registers to be dumped




Examples
-------------
; Simple text out
Example1:   db	"Hello World",0

; Out a 8 digit hex value (lower case)
Example2    db	"Hello World %x",0
            db  $21,$43,$65,$87         ; must ALWAYS be a 32bit number

; Out a 8 digit hex value (upper case)
Example3    db	"Hello World %X",0
            db  $21,$43,$65,$87         ; must ALWAYS be a 32bit number

; Out a 4 digit hex value (upper case). The top bits are MASKED off. 
Example4    db	"Hello World %4X",0
            db  $21,$43,$65,$87         ; must ALWAYS be a 32bit number

; Out a signed decimal value 
Example5    db	"Hello World %d",0
            dw  12345,0                 ; must ALWAYS be a 32bit number

; Out a signed decimal value 
Example6    db	"Hello World %d",0
            dw  $43,$21,$ff,$ff         ; must ALWAYS be a 32bit number

; Output a sub string
Example7    db	"Hello World %s",0
            dw  StringToOuput           ; point to someplace in memory
; substring to print "somewhere" in paged in memory
StringToOuput:
            db  "substring",0



; Out a 32bit binary value 
Example8    db	"Hello World %b",0
            db  %10101010,%11110000,%01111110,%11001100        ; must ALWAYS be a 32bit number

; Out an 8bit signed binary value 
Example9    db	"Hello World %8b",0
            db  %10101010,0,0,0                             ; must ALWAYS be a 32bit number

; Out a 16bit signed binary value 
Example10   db	"Hello World %16b",0
            db  %10101010,%11001100,0,0                     ; must ALWAYS be a 32bit number


Printing a register
-----------------------
%raf  =   AF register
%rbc  =   BC register
%rde  =   DE register
%rhl  =   HL register     (Must use method 2 in order to use this)
%rAF  =   'AF register
%rBC  =   'BC register
%rDE  =   'DE register
%rHL  =   'HL register
%rsp  =   SP register
%rpc  =   PC register
%rIM  =   IM register
%rII  =   I register

; Out a register value 
Example8    db	"Hello World %af %rbc %rBC %rix",0          ; af,bc regs, ALT BC and IX



            ; Full example
TestString	db	"Hello %s value is - 0x%X, %d, %8b %rpc %raf %rbc %rde",0
		    dw	SubString
		    db	$21,$43,$ba,$fd
		    dw	12345,0
		    db	%11110000,%10101010,%11001100,%10000001
SubString	db	"world",0







Next OS streaming API
---------------------
; *************************************************************************** 
; * DISK_FILEMAP ($85)                                                      * 
; *************************************************************************** 
; Obtain a map of card addresses describing the space occupied by the file. 
; Can be called multiple times if buffer is filled, continuing from previous. 
; Entry: 
;       A=file handle (just opened, or following previous DISK_FILEMAP calls) 
;       IX=buffer 
;       DE=max entries (each 6 bytes: 4 byte address, 2 byte sector count) 
; Exit (success): 
;       Fc=0 
;       DE=max entries-number of entries returned 
;       HL=address in buffer after last entry 
;       A=card flags: bit 0=card id (0 or 1) 
;                     bit 1=0 for byte addressing, 1 for block addressing 
; Exit (failure): 
;       Fc=1 
;       A=error 
; 
; NOTES: 
; Each entry may describe an area of the file between 2K and just under 32MB 
; in size, depending upon the fragmentation and disk format. 
; Please see example application code, stream.asm, for full usage information 
; (available separately or at the end of this document).

; *************************************************************************** 
; * DISK_STRMSTART ($86)                                                    * 
; *************************************************************************** 
; Start reading from the card in streaming mode. 
; Entry: IXDE=card address 
;        BC=number of 512-byte blocks to stream 
;        A=card flags. $80 = don't wait for card being ready.
; Exit (success): Fc=0 
;                 B=0 for SD/MMC protocol, 1 for IDE protocol 
;                 C=8-bit data port 
; Exit (failure): Fc=1, A=esx_edevicebusy 
; ; NOTES: 
; On the Next, this call always returns with B=0 (SD/MMC protocol) and C=$EB 
; When streaming using the SD/MMC protocol, after every 512 bytes you must read 
; a 2-byte CRC value (which can be discarded) and then wait for a $FE value 
; indicating that the next block is ready to be read. 
; Please see example application code, stream.asm, for full usage information 
; (available separately or at the end of this document).

; *************************************************************************** 
; * DISK_STRMEND ($87)                                                      * 
; *************************************************************************** 
; Stop current streaming operation. 
; Entry: A=card flags 
; Exit (success): Fc=0 
; Exit (failure): Fc=1, A=esx_edevicebusy 
; 
; NOTES: 
; This call must be made to terminate a streaming operation. 
; Please see example application code, stream.asm, for full usage information 
; (available separately or at the end of this document).






ZX Spectrum ROM
----------------
Amstrad have kindly given their permission for the redistribution of their copyrighted material but retain that copyright





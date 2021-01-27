#CSpect V2.13.00 ZXSpectrum emulator by Mike Dailly
(c)Copyright 1998-2020 All rights reserved

Be aware...emulator is far from well tested, and might crash for any reason - sometimes just out of pure spite!

NOTE: DISTRIBUTION WITH COMMERCIAL TITLES IS NOT PERMITTED WITHOUT WRITTEN CONSENT.


Whats new
======================================================================================
v2.13.00
--------
Fixed a bug in the rewind of MMUs
Swapped to 2.13 coz I was bored of 12.??


v2.12.39
--------
Fixed physical breakpoints in the plugins
(Highly) Experiminetal "rewind" debugger feature. Simply press SHIFT+F7 to step back.
         Currently tracks all RAM access and Sprite port access.
		 There's bound to be HEAPs of issues and bugs with this, but for simple debugging, 
		 it should be fine.
Added UnStep in plugin system
Added "REWIND" debugger command, to allow you to switch the CPU history on/off dynamically
Added Debugger message display. Now reports errors when you use a non-existant label etc.


v2.12.38
--------
Added NextRegs $2C and $2E (DAC mirrors)
DMA read flags (Bit 5 and Bit 1) added and fixed.
Added "_" to BASIC key detection
I "think" I've fixed the stuck BASIC mode keys (where : just gets stuck and repeats....)
Added OpenAL32.dll to the zip.... turns out that's allowed.
on loading of a NEX file, NextRegs are set to what the OS NexLoad sets

v2.12.37
--------
RAM is now filled with random bytes on power up to help simulate the real machine
-fill=$XXXXX allows you top specify a specific byte sequence to fill RAM with
Debugger: general layout adjustment.
Debugger: text colour changes when user bar over the top for easier reading
Debugger: $ added to all hex numbers
Debugger: Hex numbers are now coloured for easier spotting
Debugger: Added "peek()" of all memory access to the left of the disassembly line
Debugger: Added 16bit "peek()" of all 16bit register load/store locations
Debugger: Added a small permanent memory dump using 16bit registers as the base address
Debugger: ` now displays the current screen in the debugger (Keypad-Enter also works)
Debugger: Memory window bookmarks added.  CTRL+SHIFT+[0-9] to set, CTRL+[0-9] to jump to.
CSpect should now run on 32bit and 64bit machines
Now detects if the shader fails to compile, and switches off the shader mode
Fixed port $123b 16k bank offset mode
Fixed unified attached sprites


v2.12.36
--------
Fixed F_RENAME to use IX instead of HL (now working)
Fixed sprite clipping (I think)
First pass at Tiles and Tilemaps in bank 7

v2.12.35
--------
Faked esxDOS loading now returns an "access denied" error, if it tried to open a file that is write protected
Transparent border now working (ULA off)
Added F_RENAME (untested)

v2.12.34
--------
Fixed HEX editing in the memory window so that it's case insensitive. (don't have to press SHIFT)
ReadMe.txt now holds the "manual" part of this text file, and this is now "just" the version info.

v2.12.33
--------
You can now click on the memory window to edit bytes directly by typing HEX values into it ENTER or click off to stop
You can now press KEYPAD_ENTER to display the game screen while in the debugger

v2.12.32
--------
Fixed reg $8E bit 3 usage - don't change RAM mapping
Fixed Layer 2 palette colour offsets (NextReg $70)
Regs $6E and $6F now return top 2 bits as 0

v2.12.31
--------
Added DAC's B,C and D
Added SAVE to the debugger:  SAVE "NAME",add,len,   SAVE "NAME",BANK:OFFSET,length,    SAVE "NAME",BANK:OFFSET,BANK:OFFSET
You can now read DMA Registers
CTRL+F7 now executes to cursor in the debugger
Added the demo "mod_player.nex" added to #CSpect package

v2.12.30
--------
Layer 2 palette offset added to 256,320 and 640 modes.
Fixed a crash when a write to E3 happens, and the roms haven't been loaded.
Fixed a crash in the debugger when you entered a bank:offset and the offset was an invalid symbol
Tilereg $6E set to $2C on power up - same as hardware. (don't assume though, set it)
Tilereg $6F set to $0C on power up - same as hardware. (don't assume though, set it)

v2.12.29
--------
640x256 Layer 2 mode added

v2.12.28
--------
Fixed DMA prescaler (usually used for digial audio)

v2.12.27
--------
Fixed a crash in AY Audio when loading in large files via fake esxDOS.

v2.12.26
--------
Fixed a crash inside the debugger.
Added a new eDebugCommand.ClearAllBreakpoints to the iCSpect plugin interface

v2.12.25
--------
Fixed Tilemaps being over the border when the border is transparent

v2.12.24
--------
Lower border colour fixed
Added some wait states to slow down 28Mhz mode to more closely match the real machine

v2.12.23
--------
CTRL+F3 (or CTRL+PrintScreen) will now save a screenshot in the current working directory

v2.12.22
--------
Fixed a stupid typo on iCSpect interface to get sprites.

v2.12.21
--------
NextReg 0x1c can now be read
NextRegs 0x61 and 0x62 can now be read correctly
iCSpect memory interface changed to take/return byte arrays
Reading/Setting NextReg 255 (which isn't a real one) was crashing the emulator due to plugins
Fixed the fallback colour, was only 8 bit instead of 9
Fixed reading of the raster line for lower in the screen (lower 64 pixels usually)
Fixed some threading issues in the serial coms (on USB hardware)
Fixed and changed baud rates, and added in all normal ones (HDMI timing = 27000000/baud )  
   2000000 = 13
   1152000 = 23
   921600  = 29
   576000  = 46
   460800  = 58
   256000  = 105
   230400  = 117
   128000  = 210
   115200  = 234
   57600   = 468
   38400   = 703
   31250   = 864
   19200   = 1406
   9600    = 2812
   2400    = 11250
   1200    = 22500

v2.12.20
--------
Removed debug code that could cause a crash on others machines

v2.12.19
--------
Fixed a bug in 48k Layer 2 offset mapping (untested)
Changed set/clear breakpoints to be a proper set/clear

v2.12.18
--------
Fixed Layer 2,320x256 clip window
Fixed a crash in Layer 2, 320x256 rendering
Fixed NextReg0 (machine type) initialisation bug

v2.12.17
--------
1Bit tilemaps now use Global Transparency for it's transparency, not the tile index
Have added GetSprite() and SetSprite() to iCSpect interface for plugin writers


v2.12.16
--------
Reverted .NEX border colour palette change, was just wrong.
Added PeekSprite(address) and PokeSprite(address,value) to iCSpect interface for plugins

v2.12.15
--------
Added plugin "tick" into debugger mode

v2.12.14
--------
Plugin API can now control the debugger using the new extended eDebugCommand enum
-remote command line switch added, to disable the "visible" part of the debugger

v2.12.13
--------
Fixed GetRegister() callback
Fixed NextReg 0x05 reading
Setup some of the Nextreg on reset (also helps reset a bit better)
Fixed bit 3 of new NextReg 0x8E, which fixes dot commands (and sprite editor exiting)

v2.12.12
--------
Changed number of scanlines to 262 (HDMI) for 60Hz

v2.12.11
--------
Fixed a crash in plugin creation

v2.12.10
--------
Added pluging "eAccess.NextReg_Read" type (untested)

v2.12.9
-------
50hz/60hz bit now set in NextReg 5
-debug added to the command line. You can now "start" in the debugger.

v2.12.8
-------
Fixed AY partial port decoding
Fixed a minor reset stall when it was waiting on a HALT before the reset
NextReg 0x8c added
NextReg 0x8e added

v2.12.7 (internal)
-------
Added AltRom1 support

v2.12.6 (internal)
-------
Fixed a serial port "send" bug. Now sends the whole byte
Fixed tile attribute byte bit 7 - top bit of palette offset was being ignored
Fixed esxDOS date/time function (M_GETDATE $8E)
NEX file 1.3 now parsed... should load more things
NEX files get IRQs switched off when loaded (as per machine)
Fixed esxDOS date is wrong
Fixed Border colour now sets the palette entry as well
Fixed GetRegister() in plugins not working
Fixed Copper run then loop not working
Fixed Top line (in 256 pixel high view) is missing
Fixed DI followed by HALT should stop the CPU
Fixed Hires tilemap has clipping on far right
F8 not steps over conditional jumps and branches that go backwards. Branches forwards are taken.
Fixed ADD HL/DE/BC,A no longer affects flags
Fixed OUTI so that B is decemented first. (OTIR was already like that)
Minor change to 60hz audio
NextReg 0x69 can now be read.
DMA Continue mode added
Fixed a timing issue with DMA, so timing much better


v2.12.5
-------
Border now comes from fallback colour if paper/ink mode is 255 (as per hardware)
Fixed Plugin loading. Was broken due to new system loading+resetting.
Added new "Tick" to iPlugin interface, called once per emulated frame
Added Debugger() call to CSpect interface, allowing you to enter the debugger from the emulator

v2.12.4
-------
Fixed memory reading of Layer2 mapping in $2000-$3fff
Fixed MMC path, it was being reset when loading SNA/NEX from the command line.

v2.12.3
-------
Lowres scrolling fixed. 
Added ULA Scrolling registers $26 and $27. 
Fixed HL being set to $10000 after reading a file at the end of memory...
Fixed a command line startup issue when not started in the EXE path

v2.12.2
-------
Changed 320x256 mode to use Y/X orientation (0,0)=$0000, (1,0)=$0100, (2,0)=$0200.  (0,1)=$0001,(0,2)=$0002 etc...

v2.12.1 
-------
Plugin system can now get/set Z80 registers
A better reset on load of an SNA/Nex file. Should be a complete system reset now...
320x256 Layer 2 screen mode added (not tested very well...)
NextReg $70 added ($10=320x256 mode)
NextReg $71 added. MSB of Layer 2 XScroll added
Added Port 0x123B extended memory mapping mode added - using bit 4 to select

v2.12.0
-------
A new plugin system added, so that folk can add their own toys or support custom hardware. See below

v2.11.11
-------
Fixed a crash in 60Hz mode

v2.11.10
-------
added -major and -minor to let you set the CORE version number
added -emu to force the setting of the emulation bit in nextreg 0
added debugger command "nextreg <reg>,<value>" so you can set a next register from the debugger

v2.11.9
-------
Updated audio to be 16bit so DAC isn't squished to oblivion. (should just sound better in general)

v2.11.8 
-------
1bit tilemap fix, when tilemap is already in bank 10 or 11 (untested)

v2.11.7 (internal)
-------
Tilemap clip window right edge fix  - I think.

v2.11.6 (internal)
-------
Coms with the Pi (and it not being there), no longer crashes CSpect.
null comport now returns 0, as per hardware.

v2.11.5 (internal)
-------
Proper 60Hz Layer2 and Sprites now working

v2.11.4 (internal)
-------
Mono "textmode" added
CP/M mode now works

v2.11.3 (internal)
-------
fixed com2 command line parsing and com port initialisation.
Reg $7f now defaults to $FF on power up
When no UART2, now returns $FF
.ROM files (for OS loading) now come from the same path as the IMG file, rather than program folder
fixed com2 command line parsing and com port initialisation.

v2.11.2 (internal)
-------
Fixed "all RAM mode". 2 configurations weren't working right.
Core version number updated to 3.0
-60 now does proper 60hz, including reduced lines and proper 60hz audio *not working fully yet*
-com2=??? added. You can now have a second UART that can be used to send to a real Pi
port 0x153b (bit 6) added to switch UARTs from Wifi to Pi

v2.11.1
-------
Fixed extra pixel in wrapping scroll of ULA
Fixed label on/off
Fixed lowres vertex clip "smear"

v2.11.0
-------
Fixed -tv command line, and made it actually switch off all shader usage
if bit 6 in attrib 3 is not set, #CSpect now properly ignores attribute 4
Copper now runs at 28Mhz
The CPU no longers slows down over the screen
ULA can now scroll in 1/2 pixels
ULA Shadow screen now works with Layer 2
Reg 0x69 added (Layer 2 enable, ULA shadow mirror, and port bits 0-5 goto port 0xFF)
Copper Reg 0x63 added
DMA is now always 14Mhz...
4 bit lowres mode added (reg 0x6A)
Added $123b Read mode 
Added $123b 48K mapping mode 
Reg 7 is now R/W, and bits 4/5 now set correctly
Window regsiters are now R/W


v2.10.1
-------
Fixed a shader crash on OSX (Probably Linux as well)


v2.10.0 (private)
-------
Fixed a crash in relative sprites where the X coordinate could go negative
Added +3 "all ram" mode. (ZX81 games now work on the Next SD card)
ay8912.dll no longer obfuscated. Didn't realise this was still getting obfuscated. This means you can now compile the DLL yourself using the supplied source.
Fixed the fake UART and Wifi - was ignoring a basic AT command. 
Added a couple of new AT commands to the UART. AT+CIPSTA? will now return your IP address.
AT+CIPDNS_CUR? will return googles DNS server - coz why not.
AT+GMR will return n00160901 - which is an older version of the wifi chip I believe - any other preference?
Fixed the default MMC path (when you don't specify one) on the Mac/Linux. Now uses .Net Path.PathSeparator...
Any unknown UART command is now sent to the LOG file
CTRL+F1 now enables/disables the TV shader
PageUp+PageDown now makes the TV lines less/more visible
Home+End now adjusts the TV shader "blur"


v2.9.2
------
Added sprite clipping in over border mode (1 = enabled) (bit 5 of reg $15)
Composite/Unified mode visibility flag fixed
Parallax scrolling demo (and .BAT file to run it) added to CSpect distro.


v2.9.1
------
Fixed a sprite window clipping bug
Fixed the esxDOS streaming API emulation


v2.9.0
------
Improved the timing of the CPU so it should be much closer to the NEXT
48k timing - along with memory contention should also be much closer to the real thing
Fixed the sprite over border clip window - no longer resets the user clip window
Sprite "composite" mode added
Sprite "Unified" mode added
Fixed a screen render issue, where the screen was being stretched 1 pixel too much

v2.8.3
------
Fixed Left control in BASIC key mode.
Fixed a bug where setting port $7ffd or port $1ffd would change the +3 ROM offset - even if next roms weren't enabled.
.NEX files are now started in 14Mhz mode - same as the real machine
Added IFF 1/2 to the debug display
Fixed -fullscreen, just wasn't doing anything....
Fixed -r when you exit in "fullscreen" mode (ALT+ENTER). Now exits fullscreen before quiting
Added a "wish list" to the bottom of this doc.

v2.8.2
------
Right shift now works the same as left shift in BASIC key mode.
Left ALT now releases the mouse, Left and Right Control is now SymbShift.
In BASIC key mode if you also disable escape (-esc), escape will bring up the menu allowing you to quit BASIC/re-number etc.
Fixed a SD card write, now flushes each sector as it writes so that card is always in a complete state


v2.8.1
------
Fixed a crash in SD Card writing.
Added -sd2 for attaching a second SD card
Added a special ZXBASIC keyboard mode, meaning it'll auto map keys to the spectrum version. (" will map to SYM+P for example)
Added PageUp, PageDown, Home &  End to ZXBASIC keyboard mode.
F10 will toggle between game and ZXBASIC keyboard mode
Fixed a bug when setting the sprite index via NextReg and top bit was set, the shap wasn't being offset by $80
Added OpenAL install check for windows, if not found sound is disabled. use -sound to bypass check/error dialog

The lovely guys at SpecNext.com have added "images" of the distro, making SD card usage much simpler.
http://www.zxspectrumnext.online/cspect/

Simply download the one you need.
http://www.zxspectrumnext.online/cspect/cspect-next-16gb.zip
http://www.zxspectrumnext.online/cspect/cspect-next-8gb.zip
http://www.zxspectrumnext.online/cspect/cspect-next-4gb.zip
http://www.zxspectrumnext.online/cspect/cspect-next-2gb.zip
There are also some empty SD card images on the main site that you can put into the second SD card slot,
allowing your work to be separate from the OS (allowing easy upgrading)
In BASIC you can do 'SAVE "d:name.bas"' to save to the second slot....



v2.8.0
------
Fixed -esc command line, hadn't been ported from 1.x version
Swapped Right Shift for SYMSHIFT to Right Control. Both shifts map to CAPS SHIFT.  "," still works as SYMSHIFT
Fixed PUSH XXXX opcode in debugger. Was displaying low/high. Now fixed to display high/low.
Added "-log_cpu" for tracing the CPU instruction stream
Added back in Label "switch" to debugger
Missing "LDWS" opcode added to disassembler
Fixed bug in ULA off mode where the border was still being drawn
Fixed bug in 512 tile mode, where it was always above the ULA screen
Added +3 ROM emulation (without RAM only mode)
Added divMMC ROM/RAM hardware support via port $E3
Added divMMC SD card support via ports $E7 and $EB
SD Card SPI commands supported:CMD0,CMD1,CMD8,CMD9,CMD12,CMD13,CMD16,CMD17,CMD24,CMD55,CMD58,ACMD41
(see SDCARD setup below to get up and running)


V2.7.0
------
Removed debug text output
Initial WiFi/UART support added.
NXtel.nex added to archive - see weblink above for the latest versions.

V2.6.4
------
Fixed Timex Hires mode when using ULANext
Fixed Timex Hires border colour

V2.6.3
------
Fixed sprites crashing when using default transparency
Fixed fallback colour in screen area (I think)

V2.6.2
------
Fixed darkening mode - removed debug code
Fixed sprites being offset by a 1/2 pixel to the left

V2.6.1
------
Fixed new sprite rendering
Fixed Lighten and Darkening modes

V2.6.0
------
Rendering rewrite to properly fix transparancy.

V2.5.1
------
Trying to fix ULA transparancy.

V2.5.0
------
Fixed PUSH $1234 to have the right order.
Fixed LDWS so that flags are set based on the INC D
Fixed BSLA so that it takes bits 4..0 not just bits 3..0
Fixed a global colour transparancy issue

V2.4.6
------
Palette reading added - untested
Fixed a transparency issue with ULA colours

V2.4.5
------
HL now gets set properly after an F_READ (address of next byte)
9 bit Layer 2 colour now compares to Global transparency 8 bits correctly.

V2.4.4
------
Attempt 3 at 9bit colour (3 bit blue)

V2.4.3
------
Fixed a type-o in 9 bit blues

V2.4.2
------
Fixed "HALT" instruction so that it waits for the next IRQ or Reset, and doesn't carry on at VBlank.
9 bit colours (and so 3 bit blues), now use the same colour mapping as Red and Green. 8 Bit colour is as before.

V2.4.1
------
Inital UART spport added via standard windows serial COM ports. Must use "-com" to setup
Fixed the Real Time Clock (RTC) APi... was returing in the wrong order.
Added "fine" seconds control to RTC API. "H" now holds full seconds.

V2.4.0
------
Copper will now trap uninitialised memory when trying to execute a program, and enter the debugger.
Gamepads will now only use the "first" mapped analogue controller. Sorry. Dpad should work fine.
Fixed a bug where creating a new file, then trying to open it would fail.

V2.3.3
------
Fixed 512 tile mode. ULA Disabled bit has moved to Reg 0x68, bit 7.
Border can now be transparent and will use the fallback colour.
NEX format file expanded. Default 16k RAM bank at  $C000 now set.
NEX format file can now set the file handle on request.
Added more window scaling options (-w1 to -w10 now available).
Updated 512 tile mode to use NextReg $6B (bits 0 and 1) properly.
core version now set to 28 (2.0.28)

V2.3.2
------
Screen size changed to 320x256 to allow for full tilemap+sprites display (640x512 actual)
Fixed Tiles under ULA screen when in border area (now also under border). Same as H/W
Added 2 player Joysticks (first pass)
Added MegaDrive joysticks (first pass)


V2.3.1
------
Sprite over border clipping fixed
Sprite over border *2 on coords fixed
Fixed a rasterline reading issue when read at the bottom of the screen.


V2.3.0
------
F_FSTAT($A1) and F_STAT($AC) now implemented again
-fullscreen added to start in fullscreen mode
Fixed loading of NEX files that have pre-set tiles


V2.2.3
------
Minor update for tilemap indexing


V2.2.3
------
Added ULA scrolling using LowRes scroll registers. Note: X currently byte scrolling only.
Added Tilemap screen mode
Added X and Y scrolling to tilemaps
Fixed a couple of bugs in the streaming API.
Fixed USL rendering order - was just buggered. (Layer2 demo was broken)
Added a "-vsync" mode for when using "-60 -sound"

V2.2.2
------
Fixed regs $75-$79 auto inc then top bit of $35 NOT set
Upped sprites to 128 as per new hardware (yum!)

V2.2.1
------
Fixed reg 0x43 bit 7- disable palette auto increment.
Fixed NextReg access for sprites. Was using the wrong index.
Added Auto-increment/port binding for NextReg $35 (sprite number)
Added Auto-increment sprite Next registers $75-$79 (mirrors)
Fixed MMC path setting from the command line


V2.1.4
------
Added logging debug command (see below)
Added Layer 2 pixel priority mode - top bit of second colour palette byte (the single bit of blue) specifies over the top of everything.
Added Next OS streaming API ( see below  )
Added DMA reverse mode (R0 BASE, bit 2)
Added BSLA DE,B  (ED 28)  shift DE left by B places - uses bits 4..0 of B only
Added BSRA DE,B  (ED 28)  arithmetic shift right DE by B places - uses bits 4..0 of B only - bit 15 is replicated to keep sign
Added BSRL DE,B  (ED 2A)  logical shift right DE by B places - uses bits 4..0 of B only
Added BSRF DE,B  (ED 2B)  shift right DE by B places, filling from left with 1s - uses bits 4..0 of B only
Added BRLC DE,B  (ED 2C)  rotate DE left by B places - uses bits 3..0 of B only (to rotate right, use B=16-places)
Added JP (C)     (ED 98)  JP  ( IN(C)*64 + PC&$c000 )
Added new sprite control byte
Added sprite expand on X (16,32,64 or 128)
Added sprite expand on Y (16,32,64 or 128)
Added 16 colour shape mode
Removed 12 sprite limit, limitations still apply when expanding on X (100 16x16s per line max)
Sprite pixel wrapping on X and Y (out one side, back in the other)
Added "lighten" mode.  L2+ULA colours clamped. (selected using SLU layer order of 110)
Added "darken" mode.  L2+ULA-555 colours clamped. (selected using SLU layer order of 111)


V2.1.1
------
Fixed a crash in sprite palettes.

V2.1.0
------
Fixed Create/Truncate on esxDOS emulation
Mouse support added
Gamepads added - not sure about OSX and Linux, but appear fine on Windows.

V2.0.2
------
Ported to C#, OpenTL, OpenGL and OpenAL, now fully cross platform!
Things NOT yet finished/ported.
   Gamepads
   Some esxDOS functions  (F_FSTAT, F_STAT, M_GETDATE)
   128K SNA files are not currently loading
   File dialog (F2) will not work on OSX due to windows Forms not working in x64 mode in mono
   Mouse is not currently implemented
   Due to the way openAL appears to work, things aren't as smooth as i'd like. Disabling audio (-sound) will smooth out movement for now...
   Probably a few more things....



V1.18
-----
added "-16bit" to use only the logical address of the MAP file
Execution Breakpoints are now set in physical address space. A HEX number or SHIFT+F9 will set a logical address breakpoint. This means you can now set breakpoints on code that is not banked in yet.
Next mode enabled when loading a .NEX file


V1.17
-----
ULA colours updated to match new core colours. Bright Magenta no longer transparent by default. Now matches with $E7 (not $E3)
Fixed debugger bug where "0" is just left blank
New MAP format allowing overlays mapped in. Labels in the debugger are now based on physical addresses depending on the MMU
You can now specify a bank+offset in the debuggers memory view (M $00:$0000) to display physical addresses. 
Numeric Keypad added for debugger use.
EQUates are no longer displayed in the debugger, only addresses. This makes the view much cleaner


V1.16
-----
Fixed sprite transparency to use the index before the palette and colour conversion is done
-r on the command line will now allow CSpect to remember the window location, is if you move it somewhere, it'll start up there again next time.
Moved command line options to the top of the file, as no one seems to find them. Keys etc are still below.



V1.15
-----
Fixed sprite transparency index. now reads transparancy colour from sprite palette.
Timex Hi-Colour mode fixed

M_GETDATE added to esxDOS emulation (MSDOS format)
BC = DATE
DE = TIME

Bits	Description
0-4     Day of the month (1–31)
5-8     Month (1 = January, 2 = February, and so on)
9-15    Year offset from 1980 (add 1980 to get actual year)

Bits    Description
0-4     Second divided by 2
5-10    Minute (0–59)
11-15   Hour (0–23 on a 24-hour clock)




V1.14
-----
-joy to disable DirectInput gamepads
Re-added OUTINB instruction (16Ts)
Fixed a but with MMU1 mapping when reading, it was reading using MMU0 instead.
In ZXNext mode, if you have RAM paged in MMU0, then RST8 will be called, and esxDOS not simulated
Palette control registers are now readable (Hires Pawn demo now works)
Reg 0 now returns 10 as Machine ID
Reg 1 now returns 0x1A as core version (1.10)
Layer2 transparancy now checks the final colour, not the index
Fixed sprites in the right border area (the 320x192 picture demo)
Timex Hires colours now correct (Pawn demo)


V1.13.2
-------
Fixed CPU on WRITE and on READ breakpoints
-port1f command line removed
.NEX format now leaves IRQs enabled
Removed some of the old opcodes from the debugger
Kempston joystick emulation added using direct input. All controllers map to a single port, port $001F = %000FUDLR
Fixed memory contention disable (so now tested!)


V1.12.1
-------
Added .NEX format loading. (see format below)
Added nextreg 8, bit 6 - set to disable memory contention. (untested)
Added Specdrum Nextreg mirror ($2D)
Removed OUTINB
Removed MIRROR DE
Added sprite global transparancy register ($4B) - $e3 by default, same as global transparancy ($14).
NextReg reg,val timing changed to 20T
NextReg reg,a timing changed to 17T
Added LDWS instruction (might change)


V1.11
-----
Fixed Lowres window (right edge)
You can now use long filenames in  RST $08 commands (as per NextOS), can be set back to 8.3 via command line
Layer 2 now defaults to banks 9 and 12 as per NextOS
Added command line option to retrun $FF from port $1f
Fixed a possible issue in loading 128K SNA files. Last entry in stack (SP) was being wiped - this may have been pointing to ROM....
Fixed mouse buttons return value (bit 0 for button 1, bit 1 for button 2)


V1.10
-----
-cur to map cursor keys to 6789 (l/r/d/u)
Fixed copper instruction order
Copper fixed - and confirmed working. (changes are only visible on next line)
Copper increased to 2K - 1024 instructions
Fixed a bug in the AY emulation (updated source included)
Fixed Lowres colour palette selection
Added new "Beast" demo+source to the package to show off the copper


V1.09
-----
Layer 2 is now disabled if "shadow" screen is active  (bit 3 of port $7FFD)
Timex mode second ULA screen added (via port $FF bit 0 = 0 or 1). Second screen at $6000.
Fixed bit ?,(ix+*) type instructions in the disassembler. All $DD,$CB and $FD,$CB prefix instructions.


V1.08
-----
$123b is now readable
Fixed cursor disappearing


V1.07
-----
"Trace" text was still being drawn when window is too small.
"POKE"  debugger command added
New timings added to enhanced instructions - see below.


V1.06
-----
Border colour should now work again.... (palette paper offsets shifted)


V1.05
-----
Minor update to fix port $303b. If value is >63, it now writes 0 instead (as per the hardware)


V1.04
-----
Palettes now tested and working


V1.03
-----
Missing ay.dll from archive


V1.02
-----
Quick fix for ULA clip window


V1.01
----
Fixed a bug in delete key in debugger not working
Fixed Raster line IRQ so they now match the hardware
Fixed a bug in 128K SNA file loading
Fixed a bug in moving the memory window around using SHIFT key(s)
Removed SID support  :(
Added auto speed throttling.  While rendering the screen, if the speed is over 7Mhz, it will drop to 7Mhz. (*approximated)
Removed extra CPU instructions which are now defuct. (final list below)
MUL is now D*E=DE (8x8 bit = 16bit)
Current Next reg (via port $243b is now shown) in debugger
Current 8K MMU banks are now shown in debugger
CPU TRACE added to debugger view (see keys below) ( only when in 4x screen size mode)
Copper support added. Note: unlike hardware, changes will happen NEXT scanline.
Sprite Clip Window support added (Reg 25)
Layer 2 Clip Window support added (Reg 24)
ULA Clip Window support added (Reg 24)
LOWRES Clip Window support added (Reg 24)
Layer 2 2x palettes added
Sprite 2x palettes added
ULA 2x palettes added
Regiuster $243b is now readable

NOTE: SNASM now requires "opt ZXNEXTREG" to enable the "NextReg" opcode




V1.00
----
Startup and shut down crash should be fixed
You can now use register names in the debugger evaluation  ("M HL" instead of "M $1234", "BC HL" etc.)
G <val/reg/sym> to disassemble from address
-sound to disable audio
Timing fixed when no sound active.
-resid to enable loading and using of the reSID DLL. Note: not working yet - feel free to try and fix it! :)
-exit  to enable "EXIT" opcode of "DD 00"
-brk   to enable "BREAK" opcode of "DD 01"
-esc   to disable ESCAPE exit key (use exit opcode, close button or ALT+F4 to exit)
Fixed the Kempston Mouse interface, now works like the hardware.
Next registers are now readable (as per hardware)
local labels beginning with ! or . will now be stripped properly
Pressing CONTROL will release the mouse
Right shift is now also "Symbol shift"
3xAY audio added - many thanks to Matt Westcott (gasman)  https://github.com/gasman/libayemu
Timex Hicolour added
Timex Hires added
Lowest bit og BLUE can now be set
SHIFT+ENTER will set the PC to the current "user bar" address
Raster interrupts via Next registers $22 and $23
MMU memory mapping via NextReg $50 to $57
Added 3xAY demo by Purple Motion.
Source for ay.dll and resid.dll included (feel free to fix reSID.DLL!)
You can now specify the window size with -w1, -w2, -w3 and -w4(default). If winow is less than 3x then the debugger is not available
Cursor keys are now mapped to 5678 (ZX spectrum cursor)
Backspace now maps to LeftShift+0 (delete)
DMA now available! Simple block transfer (memory to memory, memory to port, port to memory)
SpecDrum sample interface included. Port $ffdf takes an 8 bit signed value and is output to audio. (not really tested)
Added the lowres demo (press 1+2 to switch demo)
Updated Mouse demo and added Raster Interrupts
Added DMA demo
Added 3xAY music demo


V0.9
----
register 20 ($14) Global transparancy colour added (defaults to $e3)
regisrer 7 Turbo mode selection implemented. 
Fixed 28Mhz to 14,7,3.5 transition. 
ULANext mode updated to new spec  (see https://www.specnext.com/tbblue-io-port-system/)
LDIRSCALE added
LDPIRX added


V0.8
----
New Lowres layer support added (details below)
ULANext palette support added (details below)
TEST $XX opcode fixed



V0.7
----
port $0057 and  $005b are now $xx57 and $xx5b, as per the hardware
Fixed some sprite rotation and flipping
Can now save via RST $08  (see layer 2 demo)
Some additions to SNasm (savebin, savesna, can now use : to seperate asm lines etc)


V0.6
----
Swapped HLDE to DEHL to aid C compilers
ACC32 changed to A32
TEST $00 added


V0.5
----
Added in lots more new Z80 opcodes (see below)
128 SNA snapshots can now be loaded properly
Shadow screen (held in bank 7) can now be used


V0.4
----
New debugger!!!  F1 will enter/exit the debugger
Sprite shape port has changed (as per spec) from  $55 to $5B
Loading files from RST $08 require the drive to be set (or gotten) properly - as per actual machines. 
  RST $08/$89 will return the drive needed. 
  Please see the example filesystem.asm for this.
  You can also pass in '*' or '$' to set the current drive to be system or default
Basic Audio now added (beeper)
New sprite priorities using register 21. Bits 4,3,2
New Layer 2 double buffering via Reg 18,Reg 19 and bit 3 of port $123b


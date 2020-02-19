UDGeedNext 0.4.4
----------------

0.4.6 - 1.03.18

changes / additions 

- Shows index value for select background / foreground 
- Can now hold right mouse on palette to drag to pick colour

0.4.5 - 1.03.18

changes / additions 

- Save range of sprites 
- Now clamps mouse when editing to try and avoid graphic tablet crashes (I have no idea if this will work)

0.4.4 - 1.03.18

fixed 

- crashed if a certain person drags the mouse across and out of the palette area

0.4.3 - 1.03.18

fixes

- fixed mroe undo bugs! :D
- save bmp broke zoom on editor
- fixed not storing changes when going backwards with transparent background
- fixed undo bugs (again)
- export bmp no longer need to be flipped/rotated!
- massive bug where if you clicked over 63 times on same sprite it crashed! arrgh!


changes / additions 

- new palettes to chose from
	pal, amiga , hsv 
- optional resize in image slicer
- preview is always updated and shows values
- quick save button
- shows actual sprite number on system ie slot 0 - 63
- other bits and pieces 
- shows filename in title bar
- preview mode in preview tab, now you can browse your sprites files with ease 

0.4.1 - 10.11.17

fixes

- fixed cut copy paste bug, forgot to add offset multiplier ;)
- save bmp extension should have been checked
- reworked colour pickers
- rearranged colour palette
- fixed undo bugs (again)
- adjusted button layout to be more efficient 

0.4   - 09.11.17

fixes

- Fixed export to 256 BMP for layer2 (colours where mashed)
- Fixed keyboard shortcuts interfering with some bits
- Keyboard shortcuts now require CTRL+key
- Fixed undo / redo 
- Many more I have forgotten about

added 

- new icons from flaticons.com
- undo / redo 
- Mirror and Flip for export of image to 256BMP, this is perfect for the simple esxdos load by Russ McNulty 
- When picking a colour will now show selected colour picked on palette 		

0.3.2 - 17.06.17

fixes

- fixed copying from output panel to clipboard
- hopefully output updating now always shows

added 

- right click menu on output panel, copy / generate / select all  


0.3.1 - 17.06.17

fixes

- import 1 / 2 sprites cause issues and didnt correct max sprites correctly. 

0.3.0 - 17.06.17

added 

- animations (set frame start, and number of frames)
- added preview output, increase count and width- useful for objects more than one sprite
- added custom output asm text
- added fill 
- added colour picker, also use keyboard P - left click set FG, right click set BG
- added rotate left, right, up and down - keyboard WASD
- added flip and mirror keyboard f/h
- added keybaord ADD to add a new frame
- added keyboard ctrl x/c/v for block cut / copy / paste 
- added options for smooth or raw resizing
- added sliders for rescaling
- added status bar
- added requester for export single sprite
- reposition import with right click on the left hand preview 

fixes

- generate output padded values to left instead of right cause blue colours in space of reds
- generate output didnt always show output
- a million other fixes 

0.2.5 - 10.06.17

added

- import sprites from images, resize reposition
- menu options
- keyboard shortcuts : left arror, right arror , keyboard + to add sprite 

fixes

- fix x of x when clearing 
- when imported adds blank sprite at end 
	(this is due to nextsprite )
- when import new image reset x/y offset and sizing
- asm output listing

0.2.3 - 04.06.17

fixes 

- doesnt double up the file extension 
- remove sprite / clear sprite shows warning

added

- ability to export sprites as asm data

inital Released 03.06.17

Written by David Saphier, david.saphier@gmail.com
More info zxbasic.uk/tools (does not yet exist ;)
and at http://www.specnext.com/forum/

This is a simple tool that allows you to edit the SPR files that are used on the 
ZX Spectrum Next in the current spec. 

A SPR file contains sprites (max 64). Each sprite is 256 bytes in length and are store consecutively in the SPR file. 

Each pixel is a pointer to the RRRGGGBB palette with 255,0,255 being transparent. Max SPR size is 16384. 

Usage :
-------

There is a editor area and a palette area

Editor :

Click left to place a pixel, right to remove. 
Clear to Trans will clear all sprites to the transparent colour
Clear Sprite will clear all sprites to white
Show/Hide T will toggle the transparent colour on the editor for visibility

Export Sprite - saves the current sprite to current directory as "sprite.spr"
Load Sprite Sheet - Loads either a single or multi sprites store in the SPR file
Save All Sprites - will save all sprites to a SPR file

Image Import 

Load any image type, use the width and height to resize
then select number of sprites to import using the X and Y offset and width and height or 16x16 sprites
You can also use the right mouse button the the image to quickly locate the offset required

<< - Navigate back a sprite
>> - Navigate forward a sprite
Remove Sprite - Decreases the number of sprites
Add Sprite - Increases the number of sprites

The pink colour with a T is the transparent colour. 

bugs/improvements/suggestions welcome.

Thanks

 




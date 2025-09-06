This is a simple test/demo I used to figure out the blending and ULA/Tile to sprite interactions. 
It's nothing fancy, but as you play with it, you'll see some weird tile to sprite interactions
that I really wanted to emulate, because I could see you doing some pretty cool effects using it.

Enjoy



Instructions

R - force tiles in front (Bit 1, NextReg $6B)
T - Toggle bit 0 (ULA over Tilemap) in tilemap attribute (all tiles)

  bits 6:5 = Blending in SLU modes 6 & 7 (soft reset = 0)
           = 00 for ula as blend colour
           = 10 for ula/tilemap mix result as blend colour
           = 11 for tilemap as blend colour
           = 01 for no blending

Z - set %00 in reg $68 for ULA as blend colour
X - set %00 in reg $68 for ula/tilemap mix result as blend colour
C - set %11 in reg %68 for tilemap as blend colour
V - set %01 in reg %68 for no blending

Q - Scroll tilemap Up
A - Scroll tilemap Down
O - Scroll tilemap Left
P - Scroll tilemap Right

Shift+Q - Scroll sprites up/down
Shift+A - Scroll sprites up/down

W - Scroll ULA Up (half pixels)
S - Scroll ULA Down (half pixels)
U - Scroll ULA Left (half pixels)
I - Scroll ULA Right (half pixels)

SHIFT+W - Scroll L2 Up (half pixels)
SHIFT+S - Scroll L2 Down (half pixels)
SHIFT+U - Scroll L2 Left (half pixels)
SHIFT+I - Scroll L2 Right (half pixels)


0 - Pick Mode 0
1 - Pick Mode 1
2 - Pick Mode 2
3 - Pick Mode 3
4 - Pick Mode 4
5 - Pick Mode 5
6 - Pick Mode 6
7 - Pick Mode 7

N - Enable/Disable Stencil mode
M - Enable/Disable ULA output
Y - Toggle Sprite over/under border

L - Enable LowRes screen
K - Enable ULA screen
D - Set L2 left/right window to be invalid

F - L2 256x192
G - L2 320x256
H - L2 640x256

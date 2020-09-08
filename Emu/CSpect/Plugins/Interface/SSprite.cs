using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Plugin
{
    [StructLayout(LayoutKind.Sequential, Pack = 1)]
    public struct SSprite
    {
        /// <summary>Sprite X coordinate</summary>
        public byte x;
        /// <summary>Sprite Y coordinate</summary>
        public byte y;
        /// <summary>Palette offset, mirror, flip, rotate and MSB</summary>
        public byte paloff_mirror_flip_rotate_xmsb;
        /// <summary>Sprite visibility and name</summary>
        public byte visible_name;

        /// <summary>
        ///     H=1 means this sprite uses 4-bit patterns
        ///     N6 = 0 chooses the top 128 bytes of the 256-byte pattern otherwise the bottom 128 bytes
        ///     T  = 0 if relative sprites are composite type else 1 for unified type
        ///     XX = expand on X (0-3=16,32,64,128)
        ///     YY = expand on Y (0-3=16,32,64,128)
        ///     Y8 = Extra Y coordinate bit
        ///
        ///     Relative sprite mode
        ///     7  = 0 means this sprite uses 4-bit patterns
        ///     6  = 1 means this sprite uses 4-bit patterns
        ///     N6 = 1 chooses the top 128 bytes of the 256-byte pattern otherwise the bottom 128 bytes
        ///     XX = expand on X (0-3=16,32,64,128)
        ///     YY = expand on Y (0-3=16,32,64,128)
        ///     P0 = Shape is relative
        /// </summary>
        public byte H_N6_0_XX_YY_Y8;

        public void Clear()
        {
            x = 0;
            y = 0;
            paloff_mirror_flip_rotate_xmsb = 0;
            visible_name = 0;
        }
    };

}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Plugin
{
    public class Z80Regs
    {
        public UInt16 AF;
        public UInt16 BC;
        public UInt16 DE;
        public UInt16 HL;

        public UInt16 _AF;
        public UInt16 _BC;
        public UInt16 _DE;
        public UInt16 _HL;

        public UInt16 IX;
        public UInt16 IY;
        public UInt16 PC;
        public UInt16 SP;

        public byte R;
        public byte I;
        public bool IFF1;
        public bool IFF2;
        public byte IM;
    }

}

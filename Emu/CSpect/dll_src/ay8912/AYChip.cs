using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ay8912
{
    public class AYChip : IAYChip
    {
        ayemu_ay_t m_AY;
        public ayemu_ay_t AY
        {
            get
            {
                return m_AY;
            }

            set
            {
                m_AY = value;
            }
        }

        byte[] m_pAYBuffer;
        public byte[] pAYBuffer
        {
            get
            {
                return m_pAYBuffer;
            }

            set
            {
                m_pAYBuffer = value;
            }
        }


        /// <summary>
        ///     Reset to the next frame - do nothing really
        /// </summary>
        /// <param name="_ay"></param>
        public void AYFrameReset()
        {
        }


        public void InitAY(byte[] _pAYBuffer)
        {
            ay8912.init_ay8912();

            // remember buffer
            pAYBuffer = _pAYBuffer;

            // init AY structure and reset virtual chip
            AY = new ayemu_ay_t();
            ay8912.ayemu_init(AY);
            ay8912.ayemu_reset(AY);

            // will create a 1248 buffer per frame (624 samples at 16bit)
            int ret = ay8912.ayemu_set_sound_format(AY, 312 * 2 * 50, 2, 8);
        }

        public void ProcessAY(int _index)
        {
            ay8912.ayemu_gen_sound(AY,m_pAYBuffer, null,1, _index);
        }

        /// <summary>
        ///     Write an AY register
        /// </summary>
        /// <param name="_ay">AY chip</param>
        /// <param name="_reg">register to set</param>
        /// <param name="_value8">value to set</param>
        public void WriteAY(int _reg, byte _value8)
        {
            ay8912.ayemu_set_reg(AY, _reg, _value8);
        }
    }
}

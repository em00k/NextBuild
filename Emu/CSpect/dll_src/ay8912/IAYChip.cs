using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ay8912
{
    /// <summary>
    ///     AY chip interface
    /// </summary>
    interface IAYChip
    {
        byte[]    pAYBuffer { get; set; }
        ayemu_ay_t  AY { get; set; }

        /// <summary>
        ///     Init the AY chip
        /// </summary>
        /// <param name="_pAYBuffer">Dest Sample buffer</param>
        void InitAY(byte[] _pAYBuffer);

        /// <summary>
        ///     Write an AY register
        /// </summary>
        /// <param name="_ay">AY chip</param>
        /// <param name="_reg">register to set</param>
        /// <param name="_value8">value to set</param>
        void WriteAY(int _reg, byte _value8);

        /// <summary>
        ///     Process the AY chip
        /// </summary>
        /// <param name="_ay">AY chip to process</param>
        /// <param name="_index">index into buffer to sample with</param>
        void ProcessAY(int _index);

        /// <summary>
        ///     Reset the frame
        /// </summary>
        void AYFrameReset();        
    }
}

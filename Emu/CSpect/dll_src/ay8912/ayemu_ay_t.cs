using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ay8912
{
    public class ayemu_ay_t
    {
        // for check ayemu_t structure inited
        public const int MAGIC1 = 0xcdef;


        // emulator settings 
        public int[] table;      // table of volumes for chip 
        public ayemu_chip_t type;      // general chip type (\b AYEMU_AY or \b AYEMU_YM) 
        public int ChipFreq;           // chip emulator frequency 
        public int[] eq;          // volumes for channels.
						    //Array contains 6 elements:
						    //A left, A right, B left, B right, C left and C right;
						    //range -100...100 
        public ayemu_regdata_t regs;       // parsed registers data 
        public ayemu_sndfmt_t sndfmt;  // output sound format 

        // flags 
        public int magic;          // structure initialized flag 
        public int default_chip_flag;  // =1 after init, resets in #ayemu_set_chip_type() 
        public int default_stereo_flag;    // =1 after init, resets in #ayemu_set_stereo() 
        public int default_sound_format_flag; // =1 after init, resets in #ayemu_set_sound_format() 
        public bool dirty;          // dirty flag. Sets if any emulator properties changed 

        public bool bit_a;          // state of channel A generator 
        public bool bit_b;          // state of channel B generator 
        public bool bit_c;          // state of channel C generator 
        public bool bit_n;          // current generator state 
        public int cnt_a;          // back counter of A 
        public int cnt_b;          // back counter of B 
        public int cnt_c;          // back counter of C 
        public int cnt_n;          // back counter of noise generator 
        public int cnt_e;          // back counter of envelop generator 
        public int ChipTacts_per_outcount;   // chip's counts per one sound signal count 
        public int Amp_Global;     // scale factor for amplitude 
        public int[][] vols;              // stereo type (channel volumes) and chip table. This cache calculated by #table and #eq  

        public int EnvNum;             // number of current envilopment (0...15) 
        public int env_pos;            // current position in envelop (0...127) 
        public int Cur_Seed;		        // random numbers counter 


        /// <summary>
        ///     Create ayemu_ay_t
        /// </summary>
        public ayemu_ay_t()
        {
            magic = MAGIC1;
            table = new int[32];
            type = new ayemu_chip_t();
            eq = new int[6];

            regs = new ayemu_regdata_t();
            sndfmt = new ayemu_sndfmt_t();

            vols = new int[6][];
            for (int i = 0; i < 6; i++){
                vols[i] = new int[32];
            }
        }
    }
}

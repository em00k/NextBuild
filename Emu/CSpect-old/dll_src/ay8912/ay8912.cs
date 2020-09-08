using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ay8912
{
    public enum ayemu_stereo_t
    {
        AYEMU_MONO = 0,
        AYEMU_ABC,
        AYEMU_ACB,
        AYEMU_BAC,
        AYEMU_BCA,
        AYEMU_CAB,
        AYEMU_CBA,
        AYEMU_STEREO_CUSTOM = 255
    };



    // Sound chip type.Constant for identify used chip for emulation 
    public enum ayemu_chip_t
    {
        AYEMU_AY,               // default AY chip (lion17 for now) 
        AYEMU_YM,               // default YM chip (lion17 for now) 
        AYEMU_AY_LION17,        // emulate AY with Lion17 table 
        AYEMU_YM_LION17,        // emulate YM with Lion17 table 
        AYEMU_AY_KAY,           // emulate AY with HACKER KAY table 
        AYEMU_YM_KAY,           // emulate YM with HACKER KAY table 
        AYEMU_AY_LOG,           // emulate AY with logariphmic table 
        AYEMU_YM_LOG,           // emulate YM with logariphmic table
        AYEMU_AY_CUSTOM,        //  use AY with custom table
        AYEMU_YM_CUSTOM         // use YM with custom table. 
    };





    /// <summary>
    ///     AY/YM emulator implementation
    ///     https://github.com/gasman/libayemu  by Matt Westcott (gasman)
    /// </summary>
    public class ay8912
    {
        public static string ayemu_err;
        public static string VERSION = "libayemu 0.9";

        // Max amplitude value for stereo signal for avoiding for possible folowwing SSRC for clipping
        public const int AYEMU_MAX_AMP = 24575;
        public const int AYEMU_DEFAULT_CHIP_FREQ = 1773400;

        // sound chip volume envelops (will calculated by gen_env())
        public static bool bEnvGenInit = false;
        public static int[][] Envelope;     //[16][128];


        // AY volume table (c) by V_Soft and Lion 17 
        public static int[] Lion17_AY_table =
        { 0, 513, 828, 1239, 1923, 3238, 4926, 9110,
        10344, 17876, 24682, 30442, 38844, 47270, 56402, 65535 };

        /* YM volume table (c) by V_Soft and Lion 17 */
        public static int[] Lion17_YM_table =
        { 0, 0, 190, 286, 375, 470, 560, 664,
        866, 1130, 1515, 1803, 2253, 2848, 3351, 3862,
        4844, 6058, 7290, 8559, 10474, 12878, 15297, 17787,
        21500, 26172, 30866, 35676, 42664, 50986, 58842, 65535 };

        /* AY volume table (c) by Hacker KAY */
        public static int[] KAY_AY_table =
        { 0, 836, 1212, 1773, 2619, 3875, 5397, 8823,
        10392, 16706, 23339, 29292, 36969, 46421, 55195, 65535 };

        /* YM volume table (c) by Hacker KAY */
        public static int[] KAY_YM_table =
        { 0, 0, 248, 450, 670, 826, 1010, 1239,
        1552, 1919, 2314, 2626, 3131, 3778, 4407, 5031,
        5968, 7161, 8415, 9622, 11421, 13689, 15957, 18280,
        21759, 26148, 30523, 34879, 41434, 49404, 57492, 65535 };

        /* default equlaizer (layout) settings for AY and YM, 7 stereo types */
        public static int[][][] default_layout;


        public static void init_ay8912()
        {
            Envelope = new int[16][];
            for (int i = 0; i < 16; i++)
            {
                Envelope[i] = new int[128];
            }

            default_layout = new int[2][][];
            default_layout[0] = new int[7][];
            default_layout[1] = new int[7][];

            // A_l, A_r,  B_l, B_r,  C_l, C_r 

            // for AY 
            default_layout[0][0] = new int[] { 100, 100, 100, 100, 100, 100 };  // _MONO
            default_layout[0][1] = new int[] { 100, 33, 70, 70, 33, 100 };      // _ABC
            default_layout[0][2] = new int[] { 100, 33, 33, 100, 70, 70 };      // _ACB
            default_layout[0][3] = new int[] { 70, 70, 100, 33, 33, 100 };      // _BAC
            default_layout[0][4] = new int[] { 33, 100, 100, 33, 70, 70 };      // _BCA
            default_layout[0][5] = new int[] { 70, 70, 33, 100, 100, 33 };      // _CAB
            default_layout[0][6] = new int[] { 33, 100, 70, 70, 100, 33 };      // _CBA


            // for YM 
            default_layout[0][0] = new int[] { 100, 100, 100, 100, 100, 100 };  // _MONO
            default_layout[0][1] = new int[] { 100, 5, 70, 70, 5, 100 };      // _ABC
            default_layout[0][2] = new int[] { 100, 5, 5, 100, 70, 70 };      // _ACB
            default_layout[0][3] = new int[] { 70, 70, 100, 5, 5, 100 };      // _BAC
            default_layout[0][4] = new int[] { 5, 100, 100, 5, 70, 70 };      // _BCA
            default_layout[0][5] = new int[] { 70, 70, 5, 100, 100, 5 };      // _CAB
            default_layout[0][6] = new int[] { 5, 100, 70, 70, 100, 5 };      // _CBA

  
        }



        public static bool check_magic(ayemu_ay_t ay)
        {
            if (ay.magic == ayemu_ay_t.MAGIC1)
                return true;
            return false;
        }


        /// <summary>
        ///     make chip hardware envelop tables. Will execute once before first use.  
        /// </summary>
        public static void gen_env()
        {
            int env;
            int pos;
            int hold;
            int dir;
            int vol;

            for (env = 0; env < 16; env++)
            {
                hold = 0;
                dir = ((env & 4)!=0) ? 1 : -1;
                vol = ((env & 4)!=0) ? -1 : 32;
                for (pos = 0; pos < 128; pos++)
                {
                    if (!(hold!=0))
                    {
                        vol += dir;
                        if (vol < 0 || vol >= 32)
                        {
                            if ((env & 8)!=0)
                            {
                                if ((env & 2)!=0) dir = -dir;
                                vol = (dir > 0) ? 0 : 31;
                                if ((env & 1)!=0)
                                {
                                    hold = 1;
                                    vol = (dir > 0) ? 31 : 0;
                                }
                            }
                            else
                            {
                                vol = 0;
                                hold = 1;
                            }
                        }
                    }
                    Envelope[env][pos] = vol;
                }
            }
            bEnvGenInit = true;
        }


        /// <summary>
        ///     retval ayemu_init none.
        /// </summary>
        /// <param name="ay"></param>
        public static void ayemu_init(ayemu_ay_t ay)
        {
            ay.default_chip_flag = 1;
            ay.ChipFreq = AYEMU_DEFAULT_CHIP_FREQ;
            ay.default_stereo_flag = 1;
            ay.default_sound_format_flag = 1;
            ay.dirty = true;
            ay.magic = ayemu_ay_t.MAGIC1;

            ayemu_reset(ay);
        }

        /** Reset AY/YM chip.
        *
        * \arg \c ay - pointer to ayemu_ay_t structure.
        * \return none.
*/
        public static void ayemu_reset(ayemu_ay_t ay)
        {
            if (!check_magic(ay)) return;

            ay.cnt_a = ay.cnt_b = ay.cnt_c = ay.cnt_n = ay.cnt_e = 0;
            ay.bit_a = ay.bit_b = ay.bit_c = ay.bit_n = false;
            ay.env_pos = ay.EnvNum = 0;
            ay.Cur_Seed = 0xffff;

            ay.regs.tone_a = ay.regs.tone_b = ay.regs.tone_c = 0;
            ay.regs.noise = 0;
            ay.regs.R7_tone_a = ay.regs.R7_tone_b = ay.regs.R7_tone_c = false;
            ay.regs.R7_noise_a = ay.regs.R7_noise_b = ay.regs.R7_noise_c = false;
            ay.regs.vol_a = ay.regs.vol_b = ay.regs.vol_c = 0;
            ay.regs.env_a = ay.regs.env_b = ay.regs.env_c = false;
            ay.regs.env_freq = ay.regs.env_style = 0;
        }


        public static void set_table_ay(ayemu_ay_t ay, int[] tbl)       //[16]
        {
            int n;
            for (n = 0; n < 32; n++)
                ay.table[n] = tbl[n / 2];
            ay.type = ayemu_chip_t.AYEMU_AY;
        }

        public static void set_table_ym(ayemu_ay_t ay, int[] tbl)       //[32]
        {
            int n;
            for (n = 0; n < 32; n++)
                ay.table[n] = tbl[n];
            ay.type = ayemu_chip_t.AYEMU_YM;
        }


        /** Set chip type. */
        public static int ayemu_set_chip_type(ayemu_ay_t ay, ayemu_chip_t type, int[] custom_table)
        {
            if (!check_magic(ay)) return 0;

            if (!(type == ayemu_chip_t.AYEMU_AY_CUSTOM || type == ayemu_chip_t.AYEMU_YM_CUSTOM) && custom_table != null)
            {
                ayemu_err = "For non-custom chip type 'custom_table' param must be NULL";
                return 0;
            }

            switch (type)
            {
                case ayemu_chip_t.AYEMU_AY:
                case ayemu_chip_t.AYEMU_AY_LION17:  set_table_ay(ay, Lion17_AY_table); break;
                case ayemu_chip_t.AYEMU_YM:
                case ayemu_chip_t.AYEMU_YM_LION17:  set_table_ym(ay, Lion17_YM_table); break;
                case ayemu_chip_t.AYEMU_AY_KAY: set_table_ay(ay, KAY_AY_table); break;
                case ayemu_chip_t.AYEMU_YM_KAY: set_table_ym(ay, KAY_YM_table); break;
                case ayemu_chip_t.AYEMU_AY_CUSTOM: set_table_ay(ay, custom_table); break;
                case ayemu_chip_t.AYEMU_YM_CUSTOM: set_table_ym(ay, custom_table); break;
                default:
                    ayemu_err = "Incorrect chip type";
                    return 0;
            }

            ay.default_chip_flag = 0;
            ay.dirty = true;
            return 1;
        }


        // Set chip frequency. 
        public static void ayemu_set_chip_freq(ayemu_ay_t ay, int chipfreq)
        {
            if (!check_magic(ay)) return;

            ay.ChipFreq = chipfreq;
            ay.dirty = true;
        }



        /// <summary>
        ///     Set output sound format
        /// </summary>
        /// <param name="ay">pointer to ayemu_t structure</param>
        /// <param name="freq">sound freq (44100 for example)</param>
        /// <param name="chans">number of channels (1-mono, 2-stereo)</param>
        /// <param name="bits"> now supported only 16 and 8.</param>
        /// <returns>
        ///         1 on success, \b 0 if error occure
        /// </returns>
        public static int ayemu_set_sound_format(ayemu_ay_t ay, int freq, int chans, int bits)
        {
            if (!check_magic(ay)) return 0;

            if (!(bits == 16 || bits == 8))
            {
                ayemu_err = "Incorrect bits value";
                return 0;
            }
            else if (!(chans == 1 || chans == 2))
            {
                ayemu_err = "Incorrect number of channels";
                return 0;
            }
            else if (freq < 50)
            {
                ayemu_err = "Incorrect output sound freq";
                return 0;
            }
            else
            {
                ay.sndfmt.freq = freq;
                ay.sndfmt.channels = chans;
                ay.sndfmt.bpc = bits;
            }

            ay.default_sound_format_flag = 0;
            ay.dirty = true;
            return 1;
        }


        /// <summary>
        ///     Set amplitude factor for each of channels (A,B anc C, tone and noise).
        ///     Factor's value must be from (-100) to 100.
        /// </summary>
        /// <param name="ay">pointer to ayemu_t structure</param>
        /// <param name="stereo_type">type of stereo</param>
        /// <param name="custom_eq">null or array with custom table of mixer layout.</param>
        /// <returns>
        ///     1 if OK, 0 if error occures.
        /// </returns>
        public static int ayemu_set_stereo(ayemu_ay_t ay, ayemu_stereo_t stereo_type, int[] custom_eq)
        {
            int i;
            int chip;

            if (!check_magic(ay)) return 0;

            if (stereo_type != ayemu_stereo_t.AYEMU_STEREO_CUSTOM && custom_eq != null)
            {
                ayemu_err = "Stereo type not custom, 'custom_eq' parametr must be NULL";
                return 0;
            }

            chip = (ay.type == ayemu_chip_t.AYEMU_AY) ? 0 : 1;

            switch (stereo_type)
            {
                case ayemu_stereo_t.AYEMU_MONO:
                case ayemu_stereo_t.AYEMU_ABC:
                case ayemu_stereo_t.AYEMU_ACB:
                case ayemu_stereo_t.AYEMU_BAC:
                case ayemu_stereo_t.AYEMU_BCA:
                case ayemu_stereo_t.AYEMU_CAB:
                case ayemu_stereo_t.AYEMU_CBA:
                    for (i = 0; i < 6; i++)
                        ay.eq[i] = default_layout[chip][(int)stereo_type][i];
                    break;
                case ayemu_stereo_t.AYEMU_STEREO_CUSTOM:
                    for (i = 0; i < 6; i++)
                        ay.eq[i] = custom_eq[i];
                    break;
                default:
                    ayemu_err = "Incorrect stereo type";
                    return 0;
            }

            ay.default_stereo_flag = 0;
            ay.dirty = true;
            return 1;
        }


        public static bool WARN_IF_REGISTER_GREAT_THAN(int reg, int m)
        {
            /*
            if (*(regs + r) > m) {
                Debug.Writeln(stderr, "ayemu_set_regs: warning: possible bad register data- R%d > %d\n", reg, m)
                return false;
            }*/
            return true;
        }


/** Assign values for AY registers.
*
* You must pass array of char [14] to this function
*/
/*
void ayemu_set_regs(ayemu_ay_t ay, unsigned char* regs)
        {
            if (!check_magic(ay)) return;

            //	WARN_IF_REGISTER_GREAT_THAN(1, 15);
            //	WARN_IF_REGISTER_GREAT_THAN(3, 15);
            //	WARN_IF_REGISTER_GREAT_THAN(5, 15);
            //	WARN_IF_REGISTER_GREAT_THAN(8, 31);
            //	WARN_IF_REGISTER_GREAT_THAN(9, 31);
            //	WARN_IF_REGISTER_GREAT_THAN(10, 31);

            ay.regs.tone_a = regs[0] + ((regs[1] & 0x0f) << 8);
            ay.regs.tone_b = regs[2] + ((regs[3] & 0x0f) << 8);
            ay.regs.tone_c = regs[4] + ((regs[5] & 0x0f) << 8);

            ay.regs.noise = regs[6] & 0x1f;

            ay.regs.R7_tone_a = !(regs[7] & 0x01);
            ay.regs.R7_tone_b = !(regs[7] & 0x02);
            ay.regs.R7_tone_c = !(regs[7] & 0x04);

            ay.regs.R7_noise_a = !(regs[7] & 0x08);
            ay.regs.R7_noise_b = !(regs[7] & 0x10);
            ay.regs.R7_noise_c = !(regs[7] & 0x20);

            ay.regs.vol_a = regs[8] & 0x0f;
            ay.regs.vol_b = regs[9] & 0x0f;
            ay.regs.vol_c = regs[10] & 0x0f;
            ay.regs.env_a = regs[8] & 0x10;
            ay.regs.env_b = regs[9] & 0x10;
            ay.regs.env_c = regs[10] & 0x10;
            ay.regs.env_freq = regs[11] + (regs[12] << 8);

            if (regs[13] != 0xff)
            {                   // R13 = 255 means continue curent envelop 
                ay.regs.env_style = regs[13] & 0x0f;
                ay.env_pos = ay.cnt_e = 0;
            }
        }
*/
        /** Assign value for a single AY register.
*/
        public static void ayemu_set_reg(ayemu_ay_t ay, int reg, byte value)
        {
            if (!check_magic(ay)) return;

            switch (reg)
            {
                case 0:
                    ay.regs.tone_a = (ay.regs.tone_a & 0x0f00) | value;
                    break;
                case 1:
                    ay.regs.tone_a = (ay.regs.tone_a & 0x00ff) | ((value & 0x0f) << 8);
                    break;
                case 2:
                    ay.regs.tone_b = (ay.regs.tone_b & 0x0f00) | value;
                    break;
                case 3:
                    ay.regs.tone_b = (ay.regs.tone_b & 0x00ff) | ((value & 0x0f) << 8);
                    break;
                case 4:
                    ay.regs.tone_c = (ay.regs.tone_c & 0x0f00) | value;
                    break;
                case 5:
                    ay.regs.tone_c = (ay.regs.tone_c & 0x00ff) | ((value & 0x0f) << 8);
                    break;
                case 6:
                    ay.regs.noise = value & 0x1f;
                    break;
                case 7:
                    ay.regs.R7_tone_a = !((value & 0x01) != 0);
                    ay.regs.R7_tone_b = !((value & 0x02) != 0);
                    ay.regs.R7_tone_c = !((value & 0x04) != 0);

                    ay.regs.R7_noise_a = !((value & 0x08) != 0);
                    ay.regs.R7_noise_b = !((value & 0x10) != 0);
                    ay.regs.R7_noise_c = !((value & 0x20) != 0);

                    break;
                case 8:
                    ay.regs.vol_a = value & 0x0f;
                    ay.regs.env_a = false;
                    if ((value & 0x10) != 0) ay.regs.env_a = true;
                    break;
                case 9:
                    ay.regs.vol_b = value & 0x0f;
                    ay.regs.env_b = false;
                    if ((value & 0x10) != 0) ay.regs.env_b = true;
                    break;
                case 10:
                    ay.regs.vol_c = value & 0x0f;
                    ay.regs.env_c = false;
                    if ((value & 0x10) != 0) ay.regs.env_c = true;
                    break;
                case 11:
                    ay.regs.env_freq = (ay.regs.env_freq & 0xff00) | value;
                    break;
                case 12:
                    ay.regs.env_freq = (ay.regs.env_freq & 0x00ff) | (value << 8);
                    break;
                case 13:
                    ay.regs.env_style = value & 0x0f;
                    ay.env_pos = ay.cnt_e = 0;
                    break;
            }
        }


        public static void prepare_generation(ayemu_ay_t ay)
        {
            int vol, max_l, max_r;

            if (!ay.dirty) return;

            if (!bEnvGenInit) gen_env();

            if ((ay.default_chip_flag)!=0) ayemu_set_chip_type(ay, ayemu_chip_t.AYEMU_AY, null);

            if ((ay.default_stereo_flag)!=0) ayemu_set_stereo(ay, ayemu_stereo_t.AYEMU_ABC, null);

            if ((ay.default_sound_format_flag)!=0) ayemu_set_sound_format(ay, 44100, 2, 16);

            ay.ChipTacts_per_outcount = ay.ChipFreq / ay.sndfmt.freq / 8;

            {  // GenVols 
                int n, m;
                int vol2;
                for (n = 0; n < 32; n++)
                {
                    vol2 = ay.table[n];
                    for (m = 0; m < 6; m++)
                        ay.vols[m][n] = (int)(((double)vol2 * ay.eq[m]) / 100);
                }
            }

            /* ???????????? ????????? ??????????? ???????????? ????????
            ???????????????, ??? ? vols [x][31] ????? ????? ??????? ?????????
            TODO: ??????? ???????? ?? ??? ;-)
            */
            max_l = ay.vols[0][31] + ay.vols[2][31] + ay.vols[4][31];
            max_r = ay.vols[1][31] + ay.vols[3][31] + ay.vols[5][31];
            vol = (max_l > max_r) ? max_l : max_r;  // =157283 on all defaults
            ay.Amp_Global = ay.ChipTacts_per_outcount * vol / AYEMU_MAX_AMP;

            ay.dirty = false;
        }


        /// <summary>
        /// Generate sound. Fill sound buffer with current register data
        /// </summary>
        /// <param name="ay">ay chip</param>
        /// <param name="buff">8 bit buffer to fill - or null</param>
        /// <param name="buff16">16 bit buffer to fill - or null</param>
        /// <param name="frame_count">size of buffer</param>
        public static int ayemu_gen_sound(ayemu_ay_t ay, byte[] buff, UInt16[]  buff16, int frame_count, int _index)
        {
            int mix_l, mix_r;
            int tmpvol;
            int m;
            byte[] char_buf = buff;
            UInt16[] short_buf = buff16;
            int buff_index = _index;

            if (!check_magic(ay)) return 0;

            prepare_generation(ay);

            while (frame_count-- > 0)
            {
                mix_l = mix_r = 0;

                for (m = 0; m < ay.ChipTacts_per_outcount; m++)
                {
                    if (++ay.cnt_a >= ay.regs.tone_a)
                    {
                        ay.cnt_a = 0;
                        ay.bit_a = !ay.bit_a;
                    }
                    if (++ay.cnt_b >= ay.regs.tone_b)
                    {
                        ay.cnt_b = 0;
                        ay.bit_b = !ay.bit_b;
                    }
                    if (++ay.cnt_c >= ay.regs.tone_c)
                    {
                        ay.cnt_c = 0;
                        ay.bit_c = !ay.bit_c;
                    }

                    /* GenNoise (c) Hacker KAY & Sergey Bulba */
                    if (++ay.cnt_n >= (ay.regs.noise * 2))
                    {
                        ay.cnt_n = 0;
                        ay.Cur_Seed = (ay.Cur_Seed * 2 + 1) ^ (((ay.Cur_Seed >> 16) ^ (ay.Cur_Seed >> 13)) & 1);
                        ay.bit_n = false;
                        if (((ay.Cur_Seed >> 16) & 1)!=0) ay.bit_n = true;
                    }

                    if (++ay.cnt_e >= ay.regs.env_freq)
                    {
                        ay.cnt_e = 0;
                        if (++ay.env_pos > 127)
                            ay.env_pos = 64;
                    }

                    //#define ENVVOL Envelope[ay.regs.env_style][ay.env_pos]

                    if ((ay.bit_a | !ay.regs.R7_tone_a) & (ay.bit_n | !ay.regs.R7_noise_a))
                    {
                        tmpvol = (ay.regs.env_a) ? Envelope[ay.regs.env_style][ay.env_pos] : ay.regs.vol_a * 2 + 1;
                        mix_l += ay.vols[0][tmpvol];
                        mix_r += ay.vols[1][tmpvol];
                    }

                    if ((ay.bit_b | !ay.regs.R7_tone_b) & (ay.bit_n | !ay.regs.R7_noise_b))
                    {
                        tmpvol = (ay.regs.env_b) ? Envelope[ay.regs.env_style][ay.env_pos] : ay.regs.vol_b * 2 + 1;
                        mix_l += ay.vols[2][tmpvol];
                        mix_r += ay.vols[3][tmpvol];
                    }

                    if ((ay.bit_c | !ay.regs.R7_tone_c) & (ay.bit_n | !ay.regs.R7_noise_c))
                    {
                        tmpvol = (ay.regs.env_c) ? Envelope[ay.regs.env_style][ay.env_pos] : ay.regs.vol_c * 2 + 1;
                        mix_l += ay.vols[4][tmpvol];
                        mix_r += ay.vols[5][tmpvol];
                    }
                } /* end for (m=0; ...) */

                mix_l /= ay.Amp_Global;
                mix_r /= ay.Amp_Global;

                if (ay.sndfmt.bpc == 8)
                {
                    mix_l = (mix_l >> 8);// | 128; /* 8 bit sound */
                    mix_r = (mix_r >> 8);// | 128;
                    char_buf[_index++] = (byte)mix_l;
                    if (ay.sndfmt.channels != 1)
                        char_buf[_index++] = (byte)mix_r;
                }
                else
                {
                    short_buf[_index++] = (UInt16) mix_l; /* 16 bit sound */
                    if (ay.sndfmt.channels != 1)
                    {
                        short_buf[_index++] = (UInt16)mix_r;
                    }
                }
            }
            return buff_index; 
        }

  


        void ayemu_free(ayemu_ay_t ay)
        {
            //
            return;
        }
    }
}

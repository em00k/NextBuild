using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ay8912
{
    public class ayemu_regdata_t
    {
        public int tone_a;           /**< R0, R1 */
        public int tone_b;     /**< R2, R3 */
        public int tone_c;     /**< R4, R5 */
        public int noise;      /**< R6 */
        public bool R7_tone_a;  /**< R7 bit 0 */
        public bool R7_tone_b;  /**< R7 bit 1 */
        public bool R7_tone_c;  /**< R7 bit 2 */
        public bool R7_noise_a; /**< R7 bit 3 */
        public bool R7_noise_b; /**< R7 bit 4 */
        public bool R7_noise_c; /**< R7 bit 5 */
        public int vol_a;      /**< R8 bits 3-0 */
        public int vol_b;      /**< R9 bits 3-0 */
        public int vol_c;      /**< R10 bits 3-0 */
        public bool env_a;      /**< R8 bit 4 */
        public bool env_b;      /**< R9 bit 4 */
        public bool env_c;      /**< R10 bit 4 */
        public int env_freq;       /**< R11, R12 */
        public int env_style;	/**< R13 */
    }
}

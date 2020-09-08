using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Plugin
{

    // ********************************************************
    /// <summary>
    ///     Debugger command
    /// </summary>
    // ********************************************************
    public enum eDebugCommand
    {
        none = 0,
        Enter
    };


    // ############################################################
    /// <summary>
    ///     Interface back intgo #CSpect
    /// </summary>
    // ############################################################
    public interface iCSpect
    {
        // ------------------------------------------------------------
        /// <summary>
        ///     Poke a byte into z80's 64k address space.
        ///     Follows all currently banked RAM and ROM rules
        /// </summary>
        /// <param name="_address">16bit address</param>
        /// <param name="_value">byte to poke</param>
        // ------------------------------------------------------------
        void Poke(ushort _address, byte _value);

        // ------------------------------------------------------------
        /// <summary>
        ///     Poke a byte into the nexts 2Mb address range
        /// </summary>
        /// <param name="_address">Physical address to poke into</param>
        /// <param name="_value">byte to poke</param>
        // ------------------------------------------------------------
        void PokePhysical(int _address, byte _value);


        // ------------------------------------------------------------
        /// <summary>
        ///     Peek a byte from z80's 64k address space.
        ///     Follows all currently banked RAM and ROM rules
        /// </summary>
        /// <param name="_address">Address to peek</param>
        /// <returns>
        ///     Byte at the requested location
        /// </returns>
        // ------------------------------------------------------------
        byte Peek(ushort _address);


        // ------------------------------------------------------------
        /// <summary>
        ///     Peek a byte from Nexts 2Mb address space
        /// </summary>
        /// <param name="_address">Address to peek</param>
        /// <returns>
        ///     Byte at the requested location
        /// </returns>
        // ------------------------------------------------------------
        byte PeekPhysical(int _address);


        // ------------------------------------------------------------
        /// <summary>
        ///     Set a Next Register
        /// </summary>
        /// <param name="_reg">Register to set</param>
        /// <param name="_value">value to set</param>
        // ------------------------------------------------------------
        void SetNextRegister(byte _reg, byte _value);

        // ------------------------------------------------------------
        /// <summary>
        ///     Read a next register
        /// </summary>
        /// <param name="_reg">register to read</param>
        /// <returns>
        ///     register value
        /// </returns>
        // ------------------------------------------------------------
        byte GetNextRegister(byte _reg);

        // ------------------------------------------------------------
        /// <summary>
        ///     Send a value to Z80 port
        /// </summary>
        /// <param name="_port">port to write to</param>
        /// <param name="_value">value to write</param>
        // ------------------------------------------------------------
        void OutPort(ushort _port, byte _value);

        // ------------------------------------------------------------
        /// <summary>
        ///     Read from a Z80 port
        /// </summary>
        /// <param name="_port">port to read from</param>
        /// <returns>
        ///     Read value
        /// </returns>
        // ------------------------------------------------------------
        byte InPort(ushort _port);


        // ------------------------------------------------------------
        /// <summary>
        ///     Get all Z80 registers
        /// </summary>
        /// <returns>
        ///     a class holding all the register info
        /// </returns>
        // ------------------------------------------------------------
        Z80Regs GetRegs();

        // ------------------------------------------------------------
        /// <summary>
        ///     Set all Z80 registers
        /// </summary>
        /// <param name="_regs">Register class holding all registers</param>
        // ------------------------------------------------------------
        void SetRegs(Z80Regs _regs);



        // ------------------------------------------------------------
        /// <summary>
        ///     Execute a debugger command
        /// </summary>
        /// <param name="_cmd">The command to execture</param>
        // ------------------------------------------------------------
        void Debugger(eDebugCommand _cmd);
    }
}

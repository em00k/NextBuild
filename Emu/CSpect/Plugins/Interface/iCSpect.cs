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
        /// <summary>Set remote mode - enables/disables debugger screen (0 for enable, 1 for disable)</summary>
        SetRemote,
        /// <summary>Get the debug state (in debugger or not - returns 0 or 1)</summary>
        GetState,
        /// <summary>Enter debugger</summary>
        Enter,
        /// <summary>Exit debugger and run (only in debug mode)</summary>
        Run,
        /// <summary>Single step (only in debug mode)</summary>
        Step,
        /// <summary>Step over (only in debug mode)</summary>
        StepOver,
        /// <summary>Set a breakpoint [0 to 65535]</summary>
        SetBreakpoint,
        /// <summary>Clear a breakpoint [0 to 65535]</summary>
        ClearBreakpoint,
        /// <summary>Get a breakpoint [0 to 65535], returns 0 or 1 for being set</summary>
        GetBreakpoint,
        /// <summary>Set a breakpoint in physical memory[0 to 0x1FFFFF]</summary>
        SetPhysicalBreakpoint,
        /// <summary>Clear a breakpoint in physical memory[0 to 0x1FFFFF]</summary>
        ClearPhysicalBreakpoint,
        /// <summary>Get a breakpoint in physical memory[0 to 0x1FFFFF], returns 0 or 1 for being set</summary>
        GetPhysicalBreakpoint,
        /// <summary>Set a breakpoint on CPU READING of a memory location[0 to 65535]</summary>
        SetReadBreakpoint,
        /// <summary>Clear a READ breakpoint [0 to 65535]</summary>
        ClearReadBreakpoint,
        /// <summary>Get a READ breakpoint [0 to 65535], returns 0 or 1 for being set</summary>
        GetReadBreakpoint,
        /// <summary>Set a breakpoint on CPU WRITING of a memory location[0 to 65535]</summary>
        SetWriteBreakpoint,
        /// <summary>Clear a WRITE breakpoint [0 to 65535]</summary>
        ClearWriteBreakpoint,
        /// <summary>Get a WRITE breakpoint [0 to 65535], returns 0 or 1 for being set</summary>
        GetWriteBreakpoint,
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
        /// <param name="_values">Array of values to poke</param>
        // ------------------------------------------------------------
        void Poke(ushort _address, byte[] _value);

        // ------------------------------------------------------------
        /// <summary>
        ///     Poke a byte into the nexts 2Mb address range
        /// </summary>
        /// <param name="_address">Physical address to poke into</param>
        /// <param name="_values">Array of values to poke</param>
        // ------------------------------------------------------------
        void PokePhysical(int _address, byte[] _value);


        // ------------------------------------------------------------
        /// <summary>
        ///     Poke a byte into the 16K of sprite image memory
        /// </summary>
        /// <param name="_address">Sprite data address</param>
        /// <param name="_values">Array of values to poke</param>
        /// <returns>
        ///     Byte at the requested location
        /// </returns>        
        // ------------------------------------------------------------
        void PokeSprite(int _address, byte[] _values);



        // ------------------------------------------------------------
        /// <summary>
        ///     Peek a byte from z80's 64k address space.
        ///     Follows all currently banked RAM and ROM rules
        /// </summary>
        /// <param name="_address">Address to peek</param>
        /// <param name="_count">number of bytes to "peek"</param>
        /// <returns>
        ///     Array holding the requested location
        /// </returns>
        // ------------------------------------------------------------
        byte[] Peek(ushort _address, int _count);


        // ------------------------------------------------------------
        /// <summary>
        ///     Peek a byte from Nexts 2Mb address space
        /// </summary>
        /// <param name="_address">Address to peek</param>
        /// <param name="_count">number of bytes to "peek"</param>
        /// <returns>
        ///     Array holding the requested location
        /// </returns>
        // ------------------------------------------------------------
        byte[] PeekPhysical(int _address, int _count);

        // ------------------------------------------------------------
        /// <summary>
        ///     Peek a byte from the 16K of sprite image memory
        /// </summary>
        /// <param name="_address">Sprite data address (0-$3fff)</param>
        /// <param name="_count">number of bytes to "peek"</param>
        /// <returns>
        ///     Array holding the requested location
        /// </returns>
        // ------------------------------------------------------------
        byte[] PeekSprite(int _address, int _count);


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
        /// <param name="_cmd">The command to execute</param>
        /// <returns>
        ///     return value on GET operations, otherwise 0
        /// </returns>        
        // ------------------------------------------------------------
        int Debugger(eDebugCommand _cmd, int _value = 0);


        // ------------------------------------------------------------
        /// <summary>
        ///     Get a sprite
        /// </summary>
        /// <param name="_index">The sprite index</param>
        /// <returns>
        ///     A sprite structure holding the sprite attributes
        /// </returns>        
        // ------------------------------------------------------------
        SSprite GetSprite(int _index);


        // ------------------------------------------------------------
        /// <summary>
        ///     Get a sprite
        /// </summary>
        /// <param name="_index">The sprite index</param>
        /// <param name="_sprite">A sprite structure holding the sprite attributes</param>
        // ------------------------------------------------------------
        void SetSprite(int _index, SSprite _sprite);

    }
}

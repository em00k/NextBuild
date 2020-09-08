using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Plugin
{
    // ********************************************************
    /// <summary>
    ///     Type of access
    /// </summary>
    // ********************************************************
    public enum eAccess
    {
        /// <summary>All READ data comes FROM this port</summary>
        Port_Read = 1,
        /// <summary>All WRITE data goes TO this port</summary>
        Port_Write = 2,
        /// <summary>All reads to this address come from this plugin</summary>
        Memory_Read = 3,
        /// <summary>All writes from this address come from this plugin</summary>
        Memory_Write = 4,
        /// <summary>Next register write</summary>
        NextReg_Write = 5,
        /// <summary>Next register read</summary>
        NextReg_Read = 6
    };


    // ********************************************************
    /// <summary>
    ///     IO access structure
    /// </summary>
    // ********************************************************
    public struct sIO
    {
        /// <summary>The port to register</summary>
        public int Port;

        /// <summary>The type of port access</summary>
        public eAccess Type;

        /// <summary>
        ///     Create a new 
        /// </summary>
        /// <param name="_port"></param>
        /// <param name="_type"></param>
        public sIO(int _port, eAccess _type)
        {
            Port = _port;
            Type = _type;
        }
    }

    // ********************************************************
    /// <summary>
    ///     The Plugin interface
    /// </summary>
    // ********************************************************
    public interface iPlugin
    {
        // -------------------------------------------------------
        /// <summary>
        ///     Called once an emulation frame
        /// </summary>
        // -------------------------------------------------------
        void Tick();

        // -------------------------------------------------------
        /// <summary>
        /// Write to one of the registered ports
        /// </summary>
        /// <param name="_address">The port/address top write to</param>
        /// <param name="_value">The value to write</param>
        /// <returns>
        ///     True to indicate if the write has been dealt with
        /// </returns>
        // -------------------------------------------------------
        bool Write(eAccess _type, int _port, byte _value );

        // -------------------------------------------------------
        /// <summary>
        ///     Read from a registered port
        /// </summary>
        /// <param name="_address">The port/address to read from</param>
        /// <param name="_isvalid">Is the data valid? (if false, checks next device)</param>
        /// <returns>
        ///     Byte to return, or ignored if _isvalid == false
        /// </returns>
        // -------------------------------------------------------
        byte Read(eAccess _type, int _address, out bool _isvalid);

        // -------------------------------------------------------
        /// <summary>
        ///     Init the plugin
        /// </summary>
        /// <param name="_CSpect">CSpect</param>
        /// <returns>
        ///     A list of IO read/write requests
        /// </returns>
        // -------------------------------------------------------
        List<sIO> Init( iCSpect _CSpect );

        // -------------------------------------------------------
        /// <summary>
        ///     Quit the plugin - allowing freeing of resources
        /// </summary>
        // -------------------------------------------------------
        void Quit();
    }
}

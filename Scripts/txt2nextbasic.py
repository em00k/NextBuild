# Created by Author
# Student number: 000000000
# Date : 23/2/2021
# FileName: txt2nextbasic.py.py
# Version: 1.0
# Description:

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# -*- mode: Python; tab-width: 4; indent-tabs-mode: nil; -*-
# Do not change the previous lines. See PEP 8, PEP 263.
"""
Text to NextBASIC File Converter for ZX Spectrum Next (+3e/ESXDOS compatible)
    Copyright (c) 2020 @Kounch

    File Structure and Headers obtained from
    http://www.worldofspectrum.org/ZXSpectrum128+3Manual/chapter8pt27.html

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

import sys
import os
import argparse
import logging
import shlex
import re
import gettext

try:
    from pathlib import Path
except (ImportError, AttributeError):
    from pathlib2 import Path

__MY_NAME__ = 'txt2nextbasic.py'
__MY_VERSION__ = '1.1.2'

LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.INFO)
LOG_FORMAT = logging.Formatter(
    '%(asctime)s [%(levelname)-5.5s] - %(name)s: %(message)s')
LOG_STREAM = logging.StreamHandler(sys.stdout)
LOG_STREAM.setFormatter(LOG_FORMAT)
LOGGER.addHandler(LOG_STREAM)

path_locale = os.path.dirname(__file__)
path_locale = os.path.join(path_locale, 'locale')
gettext.bindtextdomain(__MY_NAME__, localedir=path_locale)
gettext.textdomain(__MY_NAME__)
_ = gettext.gettext


def main():


    ##inputfile = ['-i','input.bas','-o','loader.bas']
    ##print("input "+inputfile[])


    """Main Routine"""
    # Check Python version
    arr_v = sys.version_info
    if arr_v[0] < 3 or (arr_v[0] == 3 and arr_v[1] < 6):
        str_msg = _('You need version 3.6 or later of Python')
        LOGGER.error(str_msg)
        raise RuntimeError(str_msg)

    arg_data = parse_args()

    load_addr = 0x8000
    if arg_data['is_binary']:
        with open(arg_data['input'], 'rb') as f:
            file_content = f.read()
    else:
        if arg_data['input']:
            with open(arg_data['input'], 'r') as f:
                code = f.readlines()
        else:
            if arg_data['makebin']==0:
                #
                s_addr = arg_data['start_addr']
                code = ['#autostart']
                if arg_data['autostart']==1:
                    code += ['10 CD "C:\\"']
                    code += ['15 CD "DEV"']
                code += ['20 .NEXLOAD {0}'.format(arg_data['name'])]
                #code += ['30 RANDOMIZE USR {0}'.format(s_addr)]
            else:
                s_addr = arg_data['start_addr']
                code = ['#autostart']
                if arg_data['autostart']==1:
                    code += ['10 CD "C:\\"']
                    code += ['15 CD "DEV"']
                code += ['20 CLEAR {0}'.format(s_addr - 1)]
                code += ['30 LOAD "{0}" CODE {1}'.format(arg_data['name'], s_addr)]
                code += ['40 RANDOMIZE USR {0}'.format(s_addr)]

        prev_line = -1
        basic_data = []
        for line in code:
            line = line.strip()
            arr_line = line.split(' ', -1)
            if line:
                # Comments and directives aren't parsed
                if line[0] != '#':
                    if load_addr == 0:  # Grab next line number for #autostart
                        load_addr, _ = extract_linenumber(line)

                    i_line, arr_line = proc_basic(line, arg_data['no_trim'])
                    if i_line <= prev_line:
                        str_msg = _('Wrong Line Number: {0}')
                        LOGGER.error(str_msg.format(i_line))
                        raise RuntimeError(str_msg.format(i_line))
                    else:
                        prev_line = i_line

                    if arr_line:
                        basic_data.append(arr_line)  # Parse BASIC
                elif line.startswith('#program'):
                    if not arg_data['output']:
                        if len(arr_line) > 1:
                            arg_data['output'] = arg_data['input'].with_name(
                                arr_line[1] + '.bas')
                elif line.startswith('#autostart'):
                    if len(arr_line) > 1:
                        load_addr = int(arr_line[1])
                    else:
                        load_addr = 0
                else:
                    str_msg = _('Cannot parse line: {0}')
                    LOGGER.error(str_msg.format(line))
                    raise RuntimeError(str_msg.format(line))

        file_content = b''.join(basic_data)

    # Save bytes to file
    file_obj = Plus3DosFile(0, file_content, load_addr)
    with open(arg_data['output'], 'wb') as f:
        f.write(file_obj.make_bin())


# Functions
# ---------


def parse_args():
    """Command Line Parser"""

    parser = argparse.ArgumentParser(description='Text to NextBASIC Converter')
    parser.add_argument('-v',
                        '--version',
                        action='version',
                        version='%(prog)s {}'.format(__MY_VERSION__))
    parser.add_argument('-n',
                        '--name',
                        action='store',
                        dest='name',
                        help='Destination Binary File Name')
    parser.add_argument('-o',
                        '--output',
                        action='store',
                        dest='output_path',
                        help='Output path')
    parser.add_argument('-s',
                        '--start',
                        action='store',
                        dest='start_addr',
                        help='Machine Code Start Address')
    parser.add_argument('-i',
                        '--input',
                        required=False,
                        action='store',
                        dest='input_path',
                        help='Input text file with BASIC code')
    parser.add_argument('-b',
                        '--binary',
                        action='store_true',
                        dest='is_binary',
                        help='Input file is binary BASIC data')
    parser.add_argument('-d',
                        '--dont_trim',
                        action='store_true',
                        dest='dont_trim',
                        help='Do not trim spaces')

    #arguments = parser.parse_args()

    values = {}

    # b_name = None
    # if arguments.name:
    #     b_name = arguments.name

    # i_path = None
    # if arguments.input_path:
    #     i_path = Path(arguments.input_path)

    # o_path = None
    # if arguments.output_path:
    #     o_path = Path(arguments.output_path)

    # s_addr = 32768
    # if arguments.start_addr:
    #     s_addr = int(arguments.start_addr)

    # is_binary = False
    # if arguments.is_binary:
    #     is_binary = True

    # dont_trim = False
    # if arguments.dont_trim:
    #     dont_trim = True

    # if i_path:
    #     if not i_path.exists():
    #         str_msg = _('Path not found: {0}')
    #         LOGGER.error(str_msg.format(i_path))
    #         str_msg = _('Input path does not exist!')
    #         raise IOError(str_msg)
    # else:
    #     if not b_name:
    #         str_msg = _('A binary name is required!')
    #         LOGGER.error(str_msg)
    #         str_msg = _('No name!')
    #         raise ValueError(str_msg)

    values['name'] = b_name
    values['input'] = None
    values['output'] = b_loadername
    values['start_addr'] = b_start
    values['is_binary'] = False
    values['no_trim'] = False 
    values['autostart'] = b_auto 
    values['makebin'] = b_makebin

    return values


def proc_basic(line, no_trim=False):
    """
       Does processing on a BASIC line, replacing text tokens, params, numbers,
       etc. with Sinclair ASCII characters. It also extracts line number apart.
       Data is returned as bytes.
    """

    i_line, line = extract_linenumber(line)  # Line number as int
    line = convert_char(line)  # Replace all known UTF-8 characters
    line, comment = extract_comment(line)  # REM comments won't be parsed
    arr_statements = extract_statements(line)  # Split quoted strings and ':'

    line_bin = ''
    dot_mode = False
    for str_sttmnt in arr_statements:
        if str_sttmnt:
            chk_sttmnt = str_sttmnt.strip()
            if chk_sttmnt and chk_sttmnt[0] == ':':
                chk_sttmnt = chk_sttmnt[1:].strip()
                dot_mode = False
            if chk_sttmnt:
                # Don't process quoted text or dot commands
                if chk_sttmnt[0] == '.':
                    dot_mode = True
                if chk_sttmnt[0] != '"' and not dot_mode:
                    str_sttmnt = process_tokens(str_sttmnt, no_trim)
                    str_sttmnt = process_params(str_sttmnt)
                    str_sttmnt = process_numbers(str_sttmnt)
        line_bin += str_sttmnt
    line_bin += comment + '\x0d'
    line_bin = [ord(c) for c in line_bin]
    line_bin = bytes(line_bin)

    line_number = i_line.to_bytes(2, byteorder='big')
    line_len = len(line_bin)
    line_len = line_len.to_bytes(2, byteorder='little')
    line_bin = b''.join([line_number, line_len, line_bin])

    return i_line, line_bin


def extract_linenumber(line):
    """Splits line into line number and line"""

    det_line = re.compile('\\s*([0-9]+)\\s*(.*)')
    match_det = det_line.match(line)
    if match_det:
        line_number = match_det.group(1)
        line = match_det.group(2)
    LOGGER.debug('LINE: {0}'.format(line_number))

    return int(line_number), line


def convert_char(line):
    """Converts non-ASCII characters from UTF-8 to Sinclair ASCII"""

    # UTF Char conversion (Block Graphics, etc)
    for s_char in CHARS:
        line = line.replace(s_char, CHARS[s_char])

    # Escape characters conversion
    n_line = ''
    arr_line = line.split('`')  # Split using escape ` char
    if arr_line:
        n_line = arr_line[0]
        for p_line in arr_line[1:]:
            # Integer between 0 and 255
            str_i = '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
            str_x = '(x[0-9a-fA-F]{1,2})'  # Hex between 0 and FF
            det_esc = re.compile('({0}|{1})(.*)'.format(str_i, str_x))
            match_esc = det_esc.findall(p_line)
            if match_esc:
                match_esc = match_esc[0]
                n_char = match_esc[1]
                if match_esc[2]:
                    n_char = match_esc[2].replace(u'x', u'0x')
                n_line += chr(int(n_char, 0))
                n_line += match_esc[3]
            else:
                n_line += p_line
    line = n_line
    return line


def extract_comment(line):
    """Splits line into line and ;/REM comment strings"""

    # Detect ; and REM comments
    comment = ''
    det_comm = re.compile('(\\s*\\d*\\s*(?:;|REM\\s?))(.*)', re.MULTILINE
                          | re.DOTALL)  # Comments at start of line
    match_comm = det_comm.match(line)
    if match_comm:
        line = match_comm.group(1)
        comment = match_comm.group(2)
    else:
        det_comm = re.compile('(.*:\\s*(?:;|REM\\s?))(.*)',
                              re.MULTILINE | re.DOTALL)  # Comments after :
        match_comm = det_comm.match(line)
        if match_comm:
            n_line = match_comm.group(1)
            if n_line.count(u'"') % 2 == 0:  # Not between quotes
                line = n_line
                comment = match_comm.group(2)

    return line, comment


def extract_statements(line):
    """Converts line to array with quoted elements and statements as members"""

    arr_line = []
    # Split quoted elements
    b_quote = False
    elem_line = u''
    for letter in line:
        if letter == u'"':
            if b_quote:
                b_quote = False
                elem_line += letter
                arr_line.append(elem_line)  # End quote: Append to list
                elem_line = u''
                continue
            else:
                arr_line.append(elem_line)  # Start quote. Split and append
                elem_line = u''
                b_quote = True

        elem_line += letter
    if elem_line:
        arr_line.append(elem_line)  # Add ending string if not empty

    # Split statements using ':'
    arr_statements = []
    for elem_line in arr_line:
        if elem_line:
            if elem_line[0] == u'"':
                arr_statements.append(elem_line)  # Quoted strings kept as is
            else:
                i = prev_i = 0
                for str_char in elem_line:
                    if str_char == u':':
                        arr_statements.append(
                            elem_line[prev_i:i])  # Split on :
                        prev_i = i
                    i += 1
                if prev_i < i:
                    arr_statements.append(
                        elem_line[prev_i:i])  # Last statement

    return arr_statements


def process_tokens(str_statement, no_trim=False):
    """ Converts token strings in statement to Sinclair ASCII"""

    # Tokens with spaces are processed first
    for token in TOKENS:
        chr_token = chr(
            TOKENS[token][0])  # Dictionaries are ordereded since 3.6
        if ' ' in token:
            det_t = re.compile('(\\s*{0}\\s*)'.format(token))
            find_t = det_t.findall(str_statement)
            if find_t:
                for str_token in find_t:
                    str_statement = str_statement.replace(str_token, chr_token)

    # Two kind of token "words", standard (e.g. INKEY$) and symbols (<=, etc.)
    str_letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ$'
    str_symbols = '<>='

    str_result = ''
    is_word = is_symbol = False
    str_word = ''  # Temporary storage of word (possibly a token)
    i = 0
    # Compose a list of all possible words in statement, split accordingly
    for str_char in str_statement:
        if str_char in str_letters:  # Word
            if is_symbol:
                is_symbol = False
                str_result += find_token(str_word)
            if not is_word:
                is_word = True
                str_word = str_char
            else:
                str_word += str_char

        elif str_char in str_symbols:  # Symbol
            if is_word:
                is_word = False
                str_result += find_token(str_word)
            if not is_symbol:
                is_symbol = True
                str_word = str_char
            else:
                str_word += str_char

        else:  # Not a Word
            if is_word or is_symbol:
                is_word = is_symbol = False
                str_result += find_token(str_word)

            if str_char != ' ' and not no_trim:
                str_result += str_char

    # Last remaining word
    if is_word or is_symbol:
        str_result += find_token(str_word)

    return str_result


def find_token(str_word):
    """Checks if a word is token or symbol, and replaces with Sinclair ASCII
    character, if not, the original word is returned"""

    str_result = str_word
    for token in TOKENS:
        str_token = token.replace('\\', '')
        # Dictionaries are ordered since Python 3.6
        chr_token = chr(TOKENS[token][0])
        if str_word == str_token:
            str_result = chr_token
            b_token = True
            break

    return str_result


def process_params(str_statement):
    """
        Parses statement and expands parameters to 5-byte format.
        Statement MUST have tokens converted to Sinclair ASCII
        (e.g. 0xCE instead of DEF FN)
    """

    # Detect DEF FN parameters
    det_params = re.compile('(.*\xCE[^\\(]*\\()([^\\)]*)(\\).*)')
    match_det = det_params.match(str_statement)
    if match_det:
        str_statement = match_det.group(1)
        str_params = match_det.group(2)
        if str_params:
            arr_params = str_params.split(',')
            arr_line = []
            for param in arr_params:
                param = param.strip()
                # Analyzing basic programs, looks like DEF FN parameters are
                # identified like numbers (using 0x0E as marker) and then
                # filled with arbitrary data on definition, and dynamically
                # replaced with other data on runtime, so we take an easy
                # approach, and use dashes to fill the space
                arr_line.append('{0}\x0e-----'.format(param))
            str_params = ','.join(arr_line)
        str_statement += str_params
        str_statement += match_det.group(3)

    return str_statement


def process_numbers(str_statement):
    """Parses statement and expands numbers to 5-byte format"""

    # Standard tokens which are also functions with integer-only forms
    # (as stated in page 76 of ZX Spectrum Next manual)
    # RND, PEEK, IN, USR, BIN
    arr_intfunc = '\xa5\xbe\xbf\xc0\xc4'
    # Tokens that never have integer expressions directly behind
    # LET, FOR
    arr_nonint = '\xf1\xEB'

    is_number = False
    is_intexpr = False  # Integer in int expression (NextBASIC)
    not_intexpr = False  # Non integer assignment
    arr_numbers = []  # Number as string, position, previous char and previous
    # part of statement
    chr_prev = ''
    n_prev = 0
    i = 0
    # Compose a list of all possible numbers in statement, split accordingly
    for str_char in str_statement:
        if i:
            chr_prev = str_statement[i - 1]

        if str_char in arr_nonint:
            not_intexpr = True

        if str_char in '%\x8b':  # Int expression or MOD
            is_intexpr = True
        elif str_char in ',' or ord(str_char) > 164:  # Standard token
            if str_char not in arr_intfunc:  # Not an integer-only function
                is_intexpr = False
        elif str_char in '=' and not_intexpr:  # Looks like a LET assignment
            is_intexpr = False
            not_intexpr = False

        if not is_intexpr:
            if not is_number:
                if str_char in '0123456789.':
                    if not chr_prev or chr_prev in PRENUM:
                        is_number = True
                        n_pos = i
            else:
                testfloat = str_statement[n_pos:i + 1]
                if (str_char not in 'eE.') and not (str_char in '+-'
                                                    and chr_prev in 'eE'):
                    try:
                        testfloat = float(testfloat)
                    except ValueError:
                        is_number = False
                        # Previous iteration had a number?
                        testfloat = str_statement[n_pos:i]
                        try:
                            testfloat = float(testfloat)
                            inc_arr_numbers(str_statement, n_pos, i, n_prev,
                                            arr_numbers)
                            n_prev = i
                        except ValueError:
                            pass  # Not a number
        i += 1

    if is_number:
        # We may still have one remaining number to process
        try:
            testfloat = float(str_statement[n_pos:i])
            inc_arr_numbers(str_statement, n_pos, i, n_prev, arr_numbers)
            n_prev = i
        except ValueError:
            if len(str_statement) > 1:
                inc_arr_numbers(str_statement, n_pos, i - 1, n_prev,
                                arr_numbers)
                n_prev = i

    # Save remaining text of statement (without numbers inside)
    str_post = str_statement[n_prev:]

    # Read list of numbers and compose the expanded statement
    str_result = ''
    for str_num, n_pos, chr_prev, str_prev in arr_numbers:
        bin_num = str_num  # By default, the number is not expanded
        str_result += str_prev  # Append text prepending number

        if chr_prev == '\xc4':  # BIN number
            LOGGER.debug('bin: {0}'.format(str_num))
            det_bin = re.compile('^[01]{8}$')
            match_det = det_bin.match(str_num)
            if match_det:
                int_num = int(str_num, base=2)  # Binary text to int
                bin_num = u'{0}\x0e'.format(
                    str_num)  # Sinclair BASIC number marker
                # BIN numbers are saved using one byte surrounded by 0s?
                bin_num += u'\x00\x00{0}\x00\x00'.format(chr(int_num))
        else:  # Other kind of number
            # LOGGER.debug('Number: {0}'.format(str_num))
            if str_num != '.':  # Only valid floats allowed
                bin_num = convert_number(str_num)  # Expand int or float
                bin_num = '{0}\x0e{1}'.format(str_num, bin_num)

        str_result += bin_num

    str_result += str_post  # Recover remaining text of statement

    return str_result


def inc_arr_numbers(str_sttmnt, n_pos, i, n_prev, arr_numbers):
    """Increments Number array slicing the required data from str_sttmnt"""

    str_number = str_sttmnt[n_pos:i]
    str_prevc = str_sttmnt[n_pos - 1]
    str_prevp = str_sttmnt[n_prev:n_pos]
    arr_numbers.append([str_number, n_pos, str_prevc, str_prevp])


def convert_number(strnum):
    """ Detect if string it's a number and then the type (int, float),
    then try to convert using Sinclair BASIC 5-byte number format
    (http://fileformats.archiveteam.org/wiki/Sinclair_BASIC_tokenized_file#5-byte_numeric_format)
    """

    c = None
    # Integer
    det_int = re.compile('[+-]?[0-9]+$')
    match_int = det_int.match(strnum)
    if match_int:
        # LOGGER.debug('int: {0}'.format(strnum))
        newint = int(strnum)
        c = convert_int(newint)
    else:
        # Float
        try:
            newfloat = float(strnum)
            # LOGGER.debug('float: {0}'.format(strnum))
            c = convert_float(newfloat)
        except ValueError:
            pass

    # Convert binary to string
    s = ''
    if c:
        for b_char in c:
            s += chr(b_char)

    return s


def convert_int(newint):
    """Convert int to bytes using 5-byte Sinclair format"""

    if newint < 65536 and newint > -65536:
        LOGGER.debug('int->{0}'.format(newint))
        if newint < 0:  # Negative, so two's complement is needed
            b = b'\x00\xff'
            newint += 65536
        else:
            b = b'\x00\x00'

        c = newint.to_bytes(2, byteorder='little', signed=False)

        # To bytes
        b = b''.join([b, c, b'\x00'])

        return b
    else:
        # Out of range, must be treated as float
        return convert_float(float(newint))


def convert_float(newfloat):
    """Convert float to bytes using 5-byte Sinclair format"""

    if newfloat != 0.0:
        LOGGER.debug('float->{0}'.format(newfloat))

        # Extract sign and absolute value
        b_sign = '0'
        normalized = False
        if newfloat < 0.0:
            b_sign = '1'
            newfloat = abs(newfloat)

        # Process integer part
        intpart = int(newfloat)
        mantissa = '{0:b}'.format(intpart)
        if intpart == 0:
            mantissa = ''
        else:
            normalized = True

        # Base exponent, possibly not normalized yet
        newexp = len(mantissa)

        # Process fractional part
        fractpart = newfloat - intpart
        i = 0  # Bit counter
        fractbin = ''
        # Bit by bit, one extra bit for rounding reasons
        while i < 33:
            fractpart *= 2
            if int(fractpart) > 0:
                if not normalized:
                    normalized = True
                    fractbin = fractbin[i:]
                    i = 0  # Normalizing, so more bits are needed
                fractpart -= int(fractpart)
                fractbin += '1'
            else:
                if not normalized:
                    newexp -= 1  # Normalizing
                fractbin += '0'
            i += 1
        fractint = int(fractbin, 2)  # Convert binary string to int

        if newexp < 0:  # Negative exponent, adjust fractional part
            fractint -= 1

        fractint = '{0:033b}'.format(fractint)  # To string again

        # Compose mantisa
        mantissa += fractint
        mantissa = b_sign + mantissa[1:]

        # Format exponent
        b = '{0:08b}'.format(128 + newexp)  # To string

        b += mantissa  # Final bits

        # Rounding using bit #41
        if b[40] == '1':
            b = b[:39] + '1'
        b = int(b[:40], 2)

        # To bytes
        b = b.to_bytes(5, byteorder='big', signed=False)

        return b
    else:
        # 0 is always treated as int
        return convert_int(0)


# Classes
# -------
class Plus3DosFile(object):
    """+3DOS File Object"""
    def __init__(self, filetype=0, content=None, load_addr=0x8000):
        self.issue = 1
        self.version = 0
        self.filetype = filetype
        self.load_addr = load_addr
        self.set_content(content)

    def set_content(self, content=None):
        self.content = content
        content_length = 0
        if content:
            content_length = len(content)

        self.header = Plus3DosFileHeader(self.filetype, content_length,
                                         self.load_addr)

        self.length = 128 + content_length

    def make_bin(self):
        arr_bytes = b'PLUS3DOS'  # +3DOS signature - 'PLUS3DOS'
        arr_bytes += b'\x1A'  # 1Ah (26) Soft-EOF (end of file)
        arr_bytes += (self.issue).to_bytes(1, 'little')
        arr_bytes += (self.version).to_bytes(1, 'little')
        arr_bytes += (self.length).to_bytes(4, 'little')
        arr_bytes += self.header.make_bin()
        arr_bytes += b'\0' * 104  # Reserved (set to 0)
        checksum = 0
        for i in range(0, 126):
            checksum += arr_bytes[i]
        checksum %= 256
        arr_bytes += (checksum).to_bytes(1, 'little')
        arr_bytes += self.content

        return arr_bytes


class Plus3DosFileHeader(object):
    """+3DOS File Header Object

      504C5553 33444F53  Bytes 0...7  - +3DOS signature - 'PLUS3DOS'
      1A                 Byte 8       - 1Ah (26) Soft-EOF (end of file)
      01                 Byte 9       - Issue number
      00                 Byte 10      - Version number
      C7000000           Bytes 11...14    - Length of the file in bytes,
                                            32 bit number, least significant
                                            byte in lowest address
      0047000A 00470000  Bytes 15...22    - +3 BASIC header data
      Program  -  0  - file length - 8000h or LINE    offset to prog
                                                      (not used)
                 00    4700          0A00             4700              00
      000000 (...) 0000  Bytes 23...126   - Reserved (set to 0)
      D7                 Byte 127 - Checksum (sum of bytes 0...126 modulo 256)
      (BASIC Program)
        Notes for a file named: "nnnnnnnnn.bin":
        504C5553 33444F53 1A0100           -> Bytes 0...10
        187 + n bytes (file)               -> Bytes 11...14 least significant
                                                         byte in lowest address
        00                                 -> Byte  15
        59  + n bytes (prog)               -> Bytes 16,17 least significant
                                                         byte in lowest address
        0A00                               -> Bytes 18,19
        59  + n bytes (prog)               -> Bytes 20,21
        00..00                             -> Bytes 22..126
        Checksum  179 + (3 x n) % mod(256) -> Byte  127
        000A0D00 FD333237 36370E00         -> Bytes 128..139
        00FF7F00 0D001415 00EF22           -> Bytes 140..150
        "Filename.bin"                     -> Bytes 151..(151+n+3)
        22AF3332 3736380E 00000080         -> Bytes (151+n+4)..EOF
        000D001E 0E00F9C0 33323736
        380E0000 0080000D
    """
    def __init__(self, filetype=0, length=0, load_addr=0x8000):
        self.filetype = filetype
        self.load_addr = load_addr
        self.set_length(length)

    def set_length(self, length=0):
        self.length = length
        self.offset = length

    def make_bin(self):
        arr_bytes = (self.filetype).to_bytes(1, 'little')
        arr_bytes += (self.length).to_bytes(2, 'little')
        arr_bytes += (self.load_addr).to_bytes(2, 'little')
        arr_bytes += (self.offset).to_bytes(2, 'little')
        arr_bytes += b'\x00'
        return arr_bytes


# Constants
# ---------

TOKENS = {
    'PEEK\\$': [135, True],
    'REG': [136, True],
    'DPOKE': [137, True],
    'DPEEK': [138, True],
    'MOD': [139, True],
    '<<': [140, True],
    '>>': [141, True],
    'UNTIL': [142, False],
    'ERROR': [143, False],
    'DEFPROC': [145, False],
    'ENDPROC': [146, False],
    'PROC': [147, False],
    'LOCAL': [148, False],
    'DRIVER': [149, False],
    'WHILE': [150, False],
    'REPEAT': [151, False],
    'ELSE': [152, False],
    'REMOUNT': [153, False],
    'BANK': [154, True],
    'TILE': [155, True],
    'LAYER': [156, True],
    'PALETTE': [157, False],
    'SPRITE': [158, True],
    'PWD': [159, False],
    'CD': [160, False],
    'MKDIR': [161, False],
    'RMDIR': [162, False],
    'SPECTRUM': [163, True],
    'PLAY': [164, False],
    'RND': [165, True],
    'INKEY\\$': [166, False],
    'PI': [167, False],
    'POINT': [169, True],
    'SCREEN\\$': [170, True],
    'ATTR': [171, True],
    'TAB': [173, True],
    'VAL\\$': [174, False],
    'CODE': [175, True],
    'VAL': [176, False],
    'LEN': [177, False],
    'SIN': [178, True],
    'COS': [179, True],
    'TAN': [180, True],
    'ASN': [181, True],
    'ACS': [182, True],
    'ATN': [183, True],
    'LN': [184, True],
    'EXP': [185, True],
    'SQR': [187, True],
    'SGN': [188, True],
    'ABS': [189, True],
    'PEEK': [190, True],
    'USR': [192, True],
    'STR\\$': [193, False],
    'CHR\\$': [194, True],
    'NOT': [195, False],
    'BIN': [196, True],
    '<=': [199, True],
    '>=': [200, True],
    '<>': [201, True],
    'LINE': [202, True],
    'THEN': [203, False],
    'STEP': [205, True],
    'DEF FN': [206, False],
    'CAT': [207, False],
    'FORMAT': [208, True],
    'MOVE': [209, False],
    'ERASE': [210, True],
    'OPEN #': [211, True],
    'CLOSE #': [212, True],
    'MERGE': [213, True],
    'VERIFY': [214, False],
    'BEEP': [215, True],
    'CIRCLE': [216, True],
    'INK': [217, True],
    'PAPER': [218, True],
    'FLASH': [219, True],
    'BRIGHT': [220, True],
    'INVERSE': [221, True],
    'OVER': [222, True],
    'OUT': [223, True],
    'LPRINT': [224, True],
    'LLIST': [225, True],
    'STOP': [226, False],
    'READ': [227, False],
    'DATA': [228, True],
    'RESTORE': [229, True],
    'NEW': [230, False],
    'BORDER': [231, True],
    'CONTINUE': [232, False],
    'DIM': [233, True],
    'REM': [234, False],
    'FOR': [235, False],
    'GO TO': [236, True],
    'GO SUB': [237, True],
    'INPUT': [238, False],
    'LOAD': [239, False],
    'LIST': [240, True],
    'LET': [241, False],
    'PAUSE': [242, True],
    'NEXT': [243, False],
    'POKE': [244, True],
    'PRINT': [245, True],
    'PLOT': [246, True],
    'RUN': [247, True],
    'SAVE': [248, False],
    'RANDOMIZE': [249, True],
    'IF': [250, False],
    'CLS': [251, False],
    'DRAW': [252, True],
    'CLEAR': [253, True],
    'RETURN': [254, False],
    'COPY': [255, True],
    'ON': [144, False],
    'FN': [168, False],
    'AT': [172, True],
    'INT': [186, True],
    'IN': [191, True],
    'OR': [197, False],
    'AND': [198, False],
    'TO': [204, True]
}

CHARS = {
    '£': '`',
    '©': '\x7f',
    '\u259D': '\x81',  # Quadrant upper right
    '\u2598': '\x82',  # Quadrant upper left
    '\u2580': '\x83',  # Upper half block
    '\u2597': '\x84',  # Quadrant lower right
    '\u2590': '\x85',  # Right half block
    '\u259A': '\x86',  # Quadrant upper left and lower right
    '\u259C': '\x87',  # Quadrant upper left and upper right and lower right
    '\u2596': '\x88',  # Quadrant lower left
    '\u259E': '\x89',  # Quadrant upper right and lower left
    '\u258C': '\x8a',  # Left half block
    '\u259B': '\x8b',  # Quadrant upper left and upper right and lower left
    '\u2584': '\x8c',  # Lower half block
    '\u259F': '\x8d',  # Quadrant upper right and lower left and lower right
    '\u2599': '\x8e',  # Quadrant upper left and lower left and lower right
    '\u2588': '\x8f'  # Full block
}

PRENUM = ' =(,+-*/<>#;~'
for str_tok in TOKENS:
    if TOKENS[str_tok][1]:
        PRENUM += chr(TOKENS[str_tok][0])

if __name__ == '__main__':
    main()
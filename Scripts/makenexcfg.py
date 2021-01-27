#!/usr/bin/env python3
import sys
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
print(BASE_DIR)

CURR_DIR = os.path.dirname(os.path.realpath(__file__))
print(CURR_DIR)
print(sys.argv[1])

CRLF = "\r\n"

outstring = "; Minimum core version" + CRLF
outstring += "!COR3,0,0" + CRLF
outstring += "compiled.sna,5,0000,1,1,1,1,0,0,0,0" + CRLF

#inputfile = "playertes.bas" 
inputfile = sys.argv[1]

try:
    with open(inputfile) as f:
        lines = f.read().splitlines()
        curline = 0
        for x in lines:
            x = x.replace(")", ",")
            x = x.replace("(", ",")
            # convert to lower case so xl.find() will be case insensitive
            xl = x.lower()
            curline += 1
            # look for SD command 
            ldsd_pos = xl.find("loadsdbank,")
            if ldsd_pos != -1:
                if xl.find("sub") == -1:
                    filename = "./data/" + x.split('"')[2-1]
                    bank = x.split(',')[6-1]
                    offset = x.split(',')[3-1]
                    offset = offset.replace("$", "0x")
                    offval = int(offset,16) & 0x1fff
                    if offset.find("0x") == -1: 
                        offval = int(offset,10) & 0x1fff

                    outstring += "; " + x + CRLF
                    outstring += "!MMU" + filename + "," + bank + ",$"+("000" + hex(offval)[2:])[-4:] + CRLF
            
            org_pos = xl.find("'!org=")
            if org_pos != -1:
                org = x.split("=")[2-1]
                sp = int(org) - 2
                outstring += "!PCSP$" + ("000" + hex(sp+2)[2:])[-4:] + ",$" + ("000"+hex(sp)[2:])[-4:] + CRLF


    print(outstring)

    with open("nexcfg.txt", "w") as f:
        f.write(outstring)
except:
    print("ERROR "+xl)
  
#!/usr/bin/env python3
# v7.2 NextBuild / NextLib by David Saphier (c) 2021 / em00k 13-Feb-2021
# ZX Basic Compiler by (c) Jose Rodriguez
# Thanks to Jari Komppa for help with the cfg parser 
# Extra thanks to Jose for help integrating into the zxb python modules and nextcreator.py 
# 
# 
# This file takes a zx basic source file and compiles then generates a NEX file. 
#
import sys
import subprocess, os, platform

# add a bunch or dirs to the path 
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir))
SCRIPTS_DIR = os.path.abspath(os.path.join(BASE_DIR, 'Scripts'))  # ZX BASIC root path
ZXBASIC_DIR = os.path.abspath(os.path.join(BASE_DIR, 'zxbasic'))  # ZX BASIC root path
LIB_DIR = os.path.join(ZXBASIC_DIR, 'src/arch/zxnext/library')
SRC_DIR = os.path.join(ZXBASIC_DIR, 'src')
TOOLS_DIR = os.path.join(ZXBASIC_DIR, 'tools')


sys.path.append(SRC_DIR)  # append it to the list of imports folders
sys.path.append(SCRIPTS_DIR)  # append it to the list of imports folders
sys.path.append(LIB_DIR)  # append it to the list of imports folders
sys.path.append(ZXBASIC_DIR)  # append it to the list of imports folders
sys.path.append(TOOLS_DIR)  # append it to the list of imports folders

from shutil import copyfile
from src.zxbc import zxbc
from src.zxbc import version
from tools import nextcreator
from datetime import datetime


start=datetime.now()

# show info 
print("===============================================================================================")
print("NextBuild v7      : David Saphier / em00k - 14-Jan-2021     https://github.com/em00k/NextBuild")
print("ZX Basic Compiler : Jose Rodriguez aka Boriel               https://zxbasic.readthedocs.io/")
print("Cspect Emulator   : Mike Dailly                             https://cspect.org")
print("===============================================================================================")

print("Input File : " + sys.argv[1])
print("")

inputfile = sys.argv[1]                         # get filename from commandline arg

try:
    maketap = sys.argv[2]                           # are we making a tap?
    gentape = 1 
except:
    gentape = 0 
    
head_tail = os.path.split(inputfile)            # get the path of the file 
sys.path.append(head_tail[0])                   # add to paths 
os.chdir(head_tail[0])                          # make sure we're in the working source folder 
copy = 0                                        # for setting up copying to another location 
heap = "2048"                                   # default heap 
orgfound = 0
destinationfile = "" 
createasm=0
headerless = 0 
optimize = '4'
bmpfile = None
noemu = 0


 
# need to get the fname and splice off extension 
filenamenoext = head_tail[1].split('.')[1-1]
      
# now scan the top 64 lines for any info on ORG/HEAP 

try:
    print("Looking for ORG...")
    org="32768"
    with open(inputfile ,'rt') as f:
        lines = f.read().splitlines()
        curline = 0
        for x in lines:
            xl = x.lower()
            org_pos = xl.find("'!org=")         # we fonud '!ORG= so now set var org 
            if org_pos != -1:
                org = x.split("=")[2-1]
                print("Found ORG    :  "+org)  
                orgfound = 1
            hea_pos = xl.find("'!heap=")        # same for heap 
            if hea_pos != -1:
                heap = x.split("=")[2-1]
                print("Found HEAP   :  "+heap)          
            optimize_pos = xl.find("'!opt=")        # same optimisations 
            if optimize_pos != -1:
                optimize = x.split("=")[2-1]
                print("Found OPT    :  "+optimize)          
            noemeu_pos = xl.find("'!noemu")        # same optimisations 
            if noemeu_pos != -1:
               noemu = 1 
               print("Do Not Run Emu ")
            copy_pos = xl.find("'!copy=")        # same optimisations               
            if copy_pos != -1:
                copy = 1
                destinationfile = x.split("=")[2-1]
                print("Found copy   :  "+destinationfile)
            asm_pos = xl.find("'!asm")        # and copy 
            if asm_pos != -1:
                noemu = 1
                createasm=1
                print("Found ASM   :   Will generate ASM file")
            head_pos = xl.find("'!headerless")        # and headerless mode 
            if head_pos != -1:
                headerless = 1
                print("Headerless  :   Will generate headerless binary")
            bmp_pos = xl.find("'!bmp=")        # and headerless mode 
            if bmp_pos != -1:
                bmpfile = './data/'+x.split("=")[2-1]
                print("Loading BMP :   "+bmpfile)
            curline += 1
            # if the line > 64 then quit 
            if curline == 64:
                break
except:
    print("Uknown error opening source file")
    
if orgfound == 0: 
    print("Never found ORG")             # if no org found, we had set it 32768
    print("Default ORG  :  "+org)
        


# compile with zxbasic 


print("Working Dir  : ",head_tail[0])
#print("Source       :  "+inputfile)
#print("Filename     :  "+filenamenoext)

# this is the full call to zxb 

#print("====================================================")
print("Compiling    :  "+inputfile)
print("ZXbasic ver  :  "+version.VERSION)
print("")

if createasm == 0:
    # disable warnings for fastcall with param
    # disable warnings for unused function 
    # disable warnings for functions never called 
    if headerless == 1: 
        test=zxbc.main([inputfile,'--headerless','-W','160','-W','140','-W','150','-W','170','-S', org,'-O',optimize,'-H',heap,'-M','Memory.txt','-e','Compile.txt','-o',head_tail[0]+'/'+filenamenoext+'.bin','-I', LIB_DIR,'-I', SCRIPTS_DIR])
    else: 
        # '-e','Compile.txt'
        if gentape  == 1: 
            test=zxbc.main([inputfile,'-W','160','-W','140','-W','150','-W','170','-W','190','-S', org,'-O',optimize,'-H',heap,'-M','Memory.txt','-t','-B','-a','-o',head_tail[0]+'/'+filenamenoext+'.tap','-I', LIB_DIR,'-I', SCRIPTS_DIR])
        else: 
            test=zxbc.main([inputfile,'-W','160','-W','140','-W','150','-W','170','-W','190','-S', org,'-O',optimize,'-H',heap,'-M','Memory.txt','-o',head_tail[0]+'/'+filenamenoext+'.bin','-I', LIB_DIR,'-I', SCRIPTS_DIR])

else:
    test=zxbc.main([inputfile,'-S', org,'-O',optimize,'-H',heap,'-e','Compile.txt','-A','-o',head_tail[0]+'/'+filenamenoext+'.asm','-I', LIB_DIR,'-I', SCRIPTS_DIR])
    noemu = 1 
    copy = 0   
if test == 0:
    print("YAY! Compiled OK! ")
    if gentape  == 1: 
        print("")
        print("Compile Log  :  "+head_tail[0]+"\\Compile.txt")
        print("Memory Log   :  "+head_tail[0]+"\\Memory.txt")
        print("")
        print("TAP created OK! All done.")
        timetaken = str(datetime.now()-start)
        print('Overall build time : '+timetaken[:-5]+'s')
        sys.exit(0)
else:
# # # if compilation fails open the compile output as a system textfile
# #     print("Compile FAILED :( "+str(test))
# #     #os.system('start notepad compile.txt')
# #     if platform.system() == 'Darwin':       # macOS
# #         subprocess.call(('open', 'compile.txt'))
# #     elif platform.system() == 'Windows':    # Windows
# #         os.startfile('compile.txt')
# #     else:                                   # linux variants
# #         subprocess.call(('xdg-open', 'compile.txt'))
# #     print("Compile Log  :  "+head_tail[0]+"\\Compile.txt")
    sys.exit(-1)

if createasm == 1:
    # display this massive message so you dont get confused when code isn't changing in your nex..... ;)
    print(" █████╗ ███████╗███╗   ███╗")
    print("██╔══██╗██╔════╝████╗ ████║")
    print("███████║███████╗██╔████╔██║")
    print("██╔══██║╚════██║██║╚██╔╝██║")
    print("██║  ██║███████║██║ ╚═╝ ██║")
    print("╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝")
    print("Generated    : "+head_tail[0]+'\\'+filenamenoext+'.asm')
    print("Compile Log  :  "+head_tail[0]+"\\Compile.txt")
    print("Exiting.")
    sys.exit(1) 
    
# compiled ok, new lets generate a config to make a NEX file 

CRLF = "\r\n"
print("====================================================")
print("Generating Nexcreator Config ...")
print("")

# default top lines 
outstring = "; Minimum core version" + CRLF
outstring += "!COR3,0,0" + CRLF
# we include sysvars 
outstring += "!MMU../../Tools/sysvars.bin,10,$1C00" + CRLF
defaultpc = org

# now read through full source for MAIN_ADDRESS 
# this is for headerless but seems broken
# try:
    # print("Looking for .__MAIN_PROGRAM__...")
    # with open(head_tail[0]+"\\Memory.txt" ,'rt') as f:
        # lines = f.read().splitlines()
        # curline = 0
        # for x in lines:
            # xl = x.lower()
            # main_pos = xl.find(".__main_program__")         # we fonud '!ORG= so now set var org 
            # if main_pos != -1:
                # pc = x.split(":")[1-1]
                # defaultpc = int(pc,16)             
                # print("Found main_pos    :  "+str(defaultpc))  
               # # orgfound = 1
           
            # curline += 1
            # # if the line > 64 then quit 
            # if curline == 64:
                # break
# except:
    # print("Uknown error opening source file")
    # raise 
if bmpfile != None:
        
       outstring += '!BMP8'+bmpfile[:-1]+',0,0,0,0,255' + CRLF
    
try:
    with open(inputfile, 'rt') as f:
        lines = f.read().splitlines()
        curline = 0 
        trimmed = 0 
        outstringa =""
        for x in lines:
            # replace any brackets with commas so we can do string split 
            x = x.replace(")", ",")
            x = x.replace("(", ",")
            # convert to lower case so xl.find() will be case insensitive
            xl = x.lower()
            curline += 1
            # look for SD command 
            ldsd_pos = xl.find("loadsdbank,")   
            if ldsd_pos != -1:
                # is it isnt the main SUB 
                if xl.find("sub") == -1:
                    # get the filename + add the data path 
                    partname = x.split('"')[2-1]
                    filename = "./data/" + partname

                    try:
                        f = open(filename)
                        f.close()
                        # and load address in bank 
                        offset = x.split(',')[3-1]
                        offset = offset.replace("$", "0x")
                        offval = int(offset,16) & 0x1fff
                        if offset.find("0x") == -1: 
                            offval = int(offset,10) & 0x1fff

                        #offset from start of file 
                        fileoffset = x.split(',')[5-1]
                        #creates a trimmed copy of the bank
                        if int(fileoffset) > 0:
                            floffset = int(fileoffset)
                            print("File "+partname+" has an offset of : "+str(floffset))
                            orig_file_content = open(filename, 'rb').read()
                            new_file_content = orig_file_content[floffset:]
                            with open('./data/tr_'+partname[:-4]+str(trimmed)+'.bnk', 'wb') as f:
                                f.write(new_file_content)                          
                                filename = './data/tr_'+partname[:-4]+str(trimmed)+'.bnk'
                                print("Trimmed as :"+filename)
                                trimmed+1
                        
                        # get the bank 
                        bank = x.split(',')[6-1]   

                        # add to our outstring 
                        outstring += "; " + x + CRLF
                        outstring += "!MMU" + filename + "," + bank + ",$"+("000" + hex(offval)[2:])[-4:] + CRLF

                    except IOError:
                        print("##ERROR - Failed to find file :"+filename)
                        print("Please make sure this file exist!")
                        print("")
                        sys.exit(1) 

    # generate PC and SP for cfg 

    sp = int(org) -2
    pc = int(defaultpc)
    outstring += "!PCSP$" + ("000" + hex(sp+2)[2:])[-4:] + ",$" + ("000"+hex(sp)[2:])[-4:] + CRLF

    # this works out which rambank we need to put our code in depending on the ORG 
    
    if int(org)>=0x4000 and int(org)<=0x7fff:
        rambank="5"
    elif int(org)>=0x8000 and int(org)<=0xbfff:
        rambank="2" 
    elif int(org)>=0xc000 and int(org)<=0xffff:
        rambank="0"   
    codestart = int(org) % 0x4000
    
    outstring += filenamenoext+".bin,"+rambank+",$"+("000" + hex(codestart)[2:])[-4:] + CRLF

    # save config 

    with open(filenamenoext+".cfg", 'wt') as f:
        f.write(outstring)
    print("Saved config file : "+filenamenoext+".cfg")
except:
    raise
    print("ERROR "+xl)
    sys.exit(0) 

# now use nexcreator.py to creat a NEX using the config file 
print("====================================================")
print("Generating NEX : "+head_tail[0]+'\\'+filenamenoext+'.nex')
print("")
try:
    nextcreator.parse_file(head_tail[0]+'/'+filenamenoext+'.cfg')
    nextcreator.generate_file(filenamenoext+'.nex')
    
    print("")
    print("Compile Log  :  "+head_tail[0]+"\\Compile.txt")
    print("Memory Log   :  "+head_tail[0]+"\\Memory.txt")
    print("")
    print("NEX created OK! All done.")
    timetaken = str(datetime.now()-start)
    print('Overall build time : '+timetaken[:-5]+'s')
except:
    print("ERROR creating NEX file!")
    raise 
    sys.exit(1) 
    
if copy == 0:
    if noemu == 0:
        sys.exit(0)
    else:
        sys.exit(1)

print("Copy "+filenamenoext+".nex to : "+destinationfile)
try:
    copyfile(head_tail[0]+'\\'+filenamenoext+'.nex', destinationfile)
    print("Copy SUCCESS!")
except:
    print("Failed to copy....")
    raise 
    quit()

if noemu == 0:
    sys.exit(0)
else:
    sys.exit(1)    
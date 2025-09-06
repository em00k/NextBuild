#!/usr/bin/env python3
# v7.6 NextBuild / NextLib by David Saphier (c) 2025 / em00k 06-09-2025
# ZX Basic Compiler by (c) Jose Rodriguez
# Thanks to Jari Komppa for help with the cfg parser 
# Extra thanks to Jose for help integrating into the zxb python modules and nextcreator.py 
# 
# 
# This file takes a zx basic source file and compiles then generates a NEX file. 
#
import sys
import subprocess, os, platform

# Get the absolute path of the current file's directory
current_dir = os.path.dirname(os.path.abspath(__file__))

# Get the root directory containing the drive
root_dir = current_dir

# Get the relative path from the current file to the parent directory
relative_path_to_parent = os.path.join(*([os.pardir] * 1))

# Construct the base directory by joining the root directory and the relative path
BASE_DIR = os.path.abspath(os.path.join(root_dir, relative_path_to_parent))

SCRIPTS_DIR = os.path.abspath(os.path.join(BASE_DIR, 'Scripts'))
EMU_DIR = os.path.abspath(os.path.join(BASE_DIR, 'Emu/CSpect'))
ZXBASIC_DIR = os.path.abspath(os.path.join(BASE_DIR, 'zxbasic'))
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
import txt2nextbasic
global heap, orgfound, destinationfile, createasm, headerless, optimize, bmpfile, noemu, org, head_file, inputfile ,autostart, nextzxos
global filename_path,filename_extension,filename_noextension,copy,gentape,makebin,binfile

start=datetime.now()

# show info 
print("===============================================================================================")
print("NextBuild v7.3    : David Saphier / em00k - 19-Mar-2021     https://github.com/em00k/NextBuild")
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
nextzxos = 0 
makebin = 0 
autostart = 0 
filename_path = ""
filename_extension = ""
filename_noextension = ""

# need to get the fname and splice off extension 
filenamenoext = head_tail[1].split('.')[1-1]
filename_extension = head_tail[1]
filename_path = head_tail[0]

# procs 

def GenerateLoader():

        #filename =  os.path.split(inputfile) 
        # get path and filename
        #dest = inputfile.split(':')[1-2] 

        if makebin == 1: 
            # we are making a bin not nex 
            print('Making a bin')
            ext = '.bin'
            txt2nextbasic.b_makebin = 1 
            outfile = os.path.split(binfile)
            outfilenoext = outfile[1].split('.')[1-1]
            print(outfilenoext)
        else:
            ext = '.nex'
            txt2nextbasic.b_makebin = 0
            outfilenoext = filenamenoext
            ParseNEXCfg()
            CreateNEXFile()

        txt2nextbasic.b_name = outfilenoext+ext              # filename of basic file 
        txt2nextbasic.b_start = int(org)

        if autostart == 1: 
            txt2nextbasic.b_auto = 1                 # filename of basic file 
            txt2nextbasic.b_loadername = 'autoexec.bas'              # filename of basic file 
            txt2nextbasic.main()
            # copies the autoexec.bas 
            if nextzxos == 1: 
                subprocess.run([EMU_DIR+'\\hdfmonkey.exe','put','/CSpect/cspect-next-2gb.img','autoexec.bas','/nextzxos/autoexec.bas'])
        else:
            txt2nextbasic.b_auto = 0 

        print("BAS created OK! All done.")

        if makebin == 1: 
            loaderfile = filenamenoext+'loader.bas'

            txt2nextbasic.b_loadername = loaderfile              # filename of basic file 
            txt2nextbasic.b_auto = 0 
            txt2nextbasic.main()

            subprocess.run([EMU_DIR+'\\hdfmonkey.exe','put','/CSpect/cspect-next-2gb.img',loaderfile,'/dev/'+loaderfile])
        
        subprocess.run([EMU_DIR+'\\hdfmonkey.exe','put','/CSpect/cspect-next-2gb.img',filenamenoext+ext,'/dev/'+outfilenoext+ext])
        #subprocess.run([EMU_DIR+'\\launchnextzxos.bat',head_tail[0]+'\\Memory.txt',EMU_DIR])
        if noemu == 0:
            subprocess.Popen([EMU_DIR+'\\launchnextzxos.bat',head_tail[0]+'\\Memory.txt',EMU_DIR])


def CreateNEXFile():
    try:        
        # now use nexcreator.py to creat a NEX using the config file 
        print("====================================================")
        print("Generating NEX : "+head_tail[0]+'\\'+filenamenoext+'.nex')
        print("")
        nextcreator.parse_file(head_tail[0]+'/'+filenamenoext+'.cfg')
        nextcreator.generate_file(filenamenoext+'.nex')            
        print("")
        print("Compile Log  :  "+head_tail[0]+"\\Compile.txt")
        print("Memory Log   :  "+head_tail[0]+"\\Memory.txt")
        print("")
        file_size = os.path.getsize(filenamenoext+'.nex')
        print("NEX filesize : "+str(file_size))
        print("NEX created OK! All done.")
    except:
        print("ERROR creating NEX file!")
        raise 
        sys.exit(1) 

def ParseNEXCfg():
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
                
            outstring += '!BMP8'+bmpfile+',0,0,0,0,255' + CRLF
            
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
                    xl = x.lower().strip()
                    curline += 1
                    # look for SD command 
                    ldsd_pos = xl.find("loadsdbank,")   
                    if ldsd_pos != -1:
                        # if it isnt the main SUB or a commented out line
                         if xl.find("sub") == -1 and xl[0] != "'":
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

def ParseDirectives():
    global heap, orgfound, destinationfile, createasm, headerless, optimize, bmpfile, noemu, org, head_file, inputfile ,autostart, nextzxos
    global filename_path,filename_extension,filename_noextension,copy,gentape,makebin,binfile

    try:
        print("Looking for ORG...")
        org="32768"
        with open(inputfile ,'rt') as f:
            lines = f.read().splitlines()
            curline = 0
            for x in lines:
                xl = x.lower().strip().split(" ")[0]   # strips off comments
               # print(xa)
               # xl = xa.split()
               # print(xl)
                org_pos = xl.find("'!org=")         # we fonud '!ORG= so now set var org 
                if org_pos != -1:
                    # x = x.split()
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
                copy_pos = xl.find("'!copy=")        # and copy         
                if copy_pos != -1:
                    copy = 1
                    destinationfile = x.split("=")[2-1]
                    print("Found copy   :  "+destinationfile)
                asm_pos = xl.find("'!asm")        # and asm
                if asm_pos != -1:
                    noemu = 1
                    createasm=1
                    print("Found ASM   :   Will generate ASM file")
                head_pos = xl.find("'!headerless")        # and headerless mode 
                if head_pos != -1:
                    headerless = 1
                    print("Headerless  :   Will generate headerless binary")
                bmp_pos = xl.find("'!bmp=")                 # adds loading screen
                if bmp_pos != -1:
                    bmpfile = './data/'+x.split("=")[2-1]
                    print("Loading BMP :   "+bmpfile)
                nextzxos_pos = xl.find("'!nextzxos")        # launches in nextzxos
                if nextzxos_pos != -1:
                    nextzxos = 1 
                    noemu == 1

                auto_pos = xl.find("'!autostart")        # creates auto start for nextzxos
                if auto_pos != -1:
                    autostart = 1 
                    print("Found autostart")
                    noemu == 1

                make_bin = xl.find("'!bin")        # launches in nextzxos
                if make_bin != -1:
                    makebin = 1 
                    binfile = x.split("=")[2-1]
                    print("Found bin    :  "+binfile)
                    noemu == 1

                curline += 1
                # if the line > 64 then quit 
                if curline == 64:
                    break


    except:
        print("Uknown error opening source file")
        raise 
    if makebin == 1: 
        if nextzxos == 0:
            print('Can only use !bin with !nextzxos')
            makebin = 0 
        copy = 0 

    if nextzxos == 1: 
        print("Will launch from NextZXOS.")   

    if orgfound == 0: 
        print("Never found ORG")             # if no org found, we had set it 32768
        print("Default ORG  :  "+org)

def ZXBCompile():
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
        if nextzxos == 1: 
            print("Generating NextZXOS loader.bas")

            GenerateLoader()

            timetaken = str(datetime.now()-start)
            print('Overall build time : '+timetaken[:-5]+'s')    
            sys.exit(1)   
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

def CopyToDestination():
    
    if copy == 1:

        print("Copy "+filenamenoext+".nex to : "+destinationfile)


        try:
            filename_path = os.path.split(destinationfile) 
            filename_extension = filename_path[1].split('.')[1-2]
            filename_noextension = filename_path[1].split('.')[1-1]

            txt2nextbasic.b_makebin = 1 
            txt2nextbasic.b_name = filename_path[1]              # filename of basic file 
            txt2nextbasic.b_start = int(org)

            txt2nextbasic.b_auto = 0                 # filename of basic file 
            txt2nextbasic.b_loadername = 'loader.bas'              # filename of basic file 
            txt2nextbasic.main()

            if filename_extension=='bin':
                print('its a bin ')
                try:
                    copyfile(head_tail[0]+'\\loader.bas', filename_path[0]+filename_noextension+'loader.bas')
                    copyfile(head_tail[0]+'\\'+filenamenoext+'.'+filename_extension, filename_path[0]+filename_noextension+'.'+filename_extension)
                    print('Copied '+filename_path[0]+filename_noextension+'loader.bas')
                    print('Copied '+filename_path[0]+filename_noextension+'.'+filename_extension)
                except:
                    print('failed to copy'+head_tail[0]+'\\loader.bas to '+filename_path+filenamenoext+'loader.bas')
            else:
                copyfile(head_tail[0]+'\\'+filenamenoext+'.'+filename_extension, destinationfile)

            if autostart == 1 : 
                    copyfile(head_tail[0]+'\\loader.bas', filename_path[0]+'nextzxos/autoexec.bas')
                    print('Copied '+filename_path[0]+'nextzxos/autoexec.bas')    

            print("Copy SUCCESS!")
        except:
            print("Failed to copy....")
            raise 
            quit()

# now scan the top 64 lines for any info on ORG/HEAP 

ParseDirectives()

# compile with zxbasic 

ZXBCompile()

# compiled ok, new lets generate a config to make a NEX file 

ParseNEXCfg()

# now use nexcreator.py to creat a NEX using the config file

CreateNEXFile()

# copy to destination if set

CopyToDestination()

timetaken = str(datetime.now()-start)
print('Overall build time : '+timetaken[:-5]+'s')

if noemu == 0:
    sys.exit(0)
else:
    sys.exit(1)    

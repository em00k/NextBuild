# NextBuild v7 Full Release 

NextBuild : A suite of tools based on Boriel's ZX Basic Compiler targetting the ZX Spectrum Next

## Since January release of VSCode the syntax hover help does not work correctly - use a release from before JAN22 ##

Please report any bugs and I will try to fix them.

http://zxbasic.uk/nextbuild/

Latest ZXBasic Compiler included v15.1.0
Now generates NEX & bin files 
Scripts rewritten in python so will work on Win, Mac & Linux

**VSCode will install the NextBuild VSCode extension**

****When you start Vscode, choose "Open Folder" and point to "Sources" in the Nextbuild folder.****

Download the archive and extract to a folder, launch VScode
and choose "Open Folder", select the "Sources" folder inside
of \NextBuildv7 

Load a source .bas file (try examples) and then compile by
using the terminal menu and Run Build Task - you can configure
a keyboard shortcut in your prefs. 

This should compile and launch in CSpect if there is an error 
the Compile.txt is opened in the default text editor. 

See the video below on how to setup for Windows & VSCode 

[![THIS VIDEO HERE](https://img.youtube.com/vi/kF_jfE7mAvg/0.jpg)](https://www.youtube.com/watch?v=kF_jfE7mAvg)

**TROUBLESHOOTING**

- I dont see snippets or hover help!

Make sure you have NextBuild set as the language 

<img src="https://raw.githubusercontent.com/em00k/src-gifs/main/help1.png">

Snippets & Code hints 
<img src="https://github.com/em00k/src-gifs/blob/main/demo.gif">

Inline help for keywords and links to https://zxbasic.readthedocs.io/en/doc/

<img src="https://github.com/em00k/src-gifs/blob/main/demo2.gif">

Compiling one of the examples and running with CSpect

<img src="https://github.com/em00k/src-gifs/blob/main/demo3.gif">

Useful information in VSCodes terminal: 

<img src="https://raw.githubusercontent.com/em00k/src-gifs/main/2021-01-30%2002_02_52-Snip%20%26%20Sketch.png">

You can easily output to ASM to view the actucal source code that gets assembled

<img src="https://raw.githubusercontent.com/em00k/src-gifs/main/2021-01-30%2002_11_47-Greenshot.png">

Copy finalised NEX file to another location: 

<img src="https://raw.githubusercontent.com/em00k/src-gifs/main/2021-01-30%2002_47_45-Greenshot.png">

Thanks to :

- Jose Rodgriguez aka Boriel for ZXBasic
- Kounch for Text to NextBASIC File Converter for ZX Spectrum Next
- JSJ for his ZXBasic vscode extenstion
- Remy Sharp for his hover helper code
- Mike Dailly for CSpect
- And all others who have helped!

# NextBuild v6
NextBuild : A suite of tools based on Boriel's ZX Basic Compiler targetting the ZX Spectrum Next

This is the latest version I have been trying to get out, a few suggested hosting on git so it can be a WIP.

Please report any bugs and I will try to fix them.

http://zxbasic.uk/nextbuild/


You will need this for VSC if not using BorIDE or something similar:

NOTE : the demo .bas file have an associated .cfg file that stores the ORG address from BorIDE, so if demos fail to work, check the .cfg in a text editor as some depend on a starting address being set.
```
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "echo",
            "type": "shell",
            "command": "C:\\NextBuildv6\\Scripts\\compile.bat ${file} -S ",
            "args": [

                "${input:startaddress}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ],
    "inputs": [
        {
            "type": "promptString",
            "id": "startaddress",
            "description": "Start Address : ",
            "default": "24576"
        }
    ]
}
```

# SDCardEditor
.NET DLL and UI for accessing SD card images directly  
Copyright 2021 Mike Dailly, All rights reserved.

The source and executables for this project can be used freely, for both commercial and non-commercial reasons, without charge, but copyright is maintained and credit must be given to anyone who has contributed (see below) in any project where it is used.  
No warranty is given to this project, and you use it at your own risk. A link in the application to this project would be appreciated, but is not required. Source does not have to be bundled.  

If you extend it, improve it, add new or missing features, please consider pushing back all changes for others to benefit from. This is again appreciated, but not required. Any accepted changes will be added to the contributors list.


Find it at: https://github.com/mikedailly/SDCardEditor


Contributors
------------
Mike Dailly


Usage
-----

Example :- loading a ZX Spectrum Next image  

	SDCard card = SDCard.Open( "C:\source\ZXSpectrum\_Demos\2gbimage\cspect-next-2gb.img" );  
	List<DirectoryEntry> dir = card.ReadDirectory("Demos\\WidescreenImageDemo");  
	byte[] f = card.LoadFile("demos\\WidescreenImageDemo\\readme.txt");  


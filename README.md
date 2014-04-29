GADRSTabSeparateFile
====================

GADRSTabSeparateFile is a class that reads a tab separated file line by line.


Installation
-----------

The GADRSTabSeparateFile has a library target. Hence all that needs to be done
is to copy the contents of the GADRSTabSeparateFile library into your project
directory, and add the GADRSTabSeparateFile to your project. Then the test
target in your project need to link to the GADRSTabSeparateFile lib and to be
made dependent on the lib target from the GADRSTabSeparateFile project. Also
make sure that the header and library search paths of your project include
'$(BUILT_PRODUCTS_DIR)', and that 'Other Linker Flags' contains '-ObjC'.

Step by step instructions:

1.	Copy the contents of the GADRSTabSeparateFile repository into your project 
	directory, it does not matter where exactly. 
1.	Open your project in XCode. 
1.	In XCode (with your project open) select the group which you wish to contain
	the GADRSTabSeparateFile project, and bring up it's context menu. 
1.	In the context menu select 'Add files to "<< your project name >>"...' 
1.	Select the GADRSTabSeparateFile project file (ie.
	GADRSTabSeparateFile.xcodeproj), and click the 'Add' button. 
1.	Go to the 'Build Phases' of your project, and select the tests target.
1.	Add the GADRSTabSeparateFile library to the 'Target Dependencies'.
1.	Add the 'libGADRSTabSeparateFile.a' to 'Link Binary With Libraries'
1.	Go to the 'Build Settings' of your project, and select the tests target.
1.	Add '$(BUILT_PRODUCTS_DIR)' to the 'Header Search Path' and to the
	'Library Search Path'.
1. 	Add '-ObjC' to 'Other Linker Flags'.




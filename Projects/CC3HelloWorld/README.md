<img src="http://www.brenwill.com/docs/cocos3d/Logos/cocos3d-Banner-150h.png">

README
----------------------

Cocos3D 2.0.1

Copyright (c) 2010-2014 [The Brenwill Workshop Ltd.](http://www.brenwill.com) All rights reserved.

*This document is written in [Markdown](http://en.wikipedia.org/wiki/Markdown) format. 
For best results, use a Markdown reader.*


Getting Started
---------------

You can use this Xcode project as a starting point for developing your own app, by simply 
copying the `Projects/CC3HelloWorld` folder from the  Cocos3D distribution folder to the 
location where you want to develop your application. Once copied, you can rename the Xcode
project to the name of your own app.

This starter application presents a 3D take on the ubiquitous ***hello, world*** application. 
In addition to demonstrating how to load and display a 3D model, this application animates 
the model, and includes simple user interaction by having the 3D object visibly respond to
finger touches.

The `CC3HelloWorldScene.m` file is where all the interesting action happens. To add your 
own 3D content, or to change the activty and interactivity of the 3D content, edit the 
methods in that file.

You can also edit the `application:didFinishLaunchingWithOptions:` method in the `AppDelegate.m` 
file to tweak the basic setup of your Cocos3D application. This method is where the Cocos3D 
framework is hooked into the Cocos2D framework, and Apple's OpenGL ES framework.

NOTE: The `hello-world.pod` 3D model data file used for the ***hello, world*** message 
model is fairly large, because converting a font to a mesh results in a lot of triangles.
When adapting this project for your own application, don't forget to remove the
`hello-world.pod` file from the `Resources` folder of your project!


Learning Cocos3D
----------------

Wondering how to get started? View Harry Dart-O’Flynn’s wonderful [Starting Cocos3D](http://www.youtube.com/playlist?list=PLU4bmVOOYXK-fV0Wt-ES5n3k8qTTyqgYu) 
collection of video tutorials!

To learn more about Cocos3D, please refer to the [Cocos3D Programming Guide](http://brenwill.com/2011/cocos3d-programming-guide/)
and the latest [API documentation](http://brenwill.com/docs/cocos3d/2.0.1/api/).

You can create a local copy of the API documentation using `Doxygen` to extract the documentation
from the source files. There is a `Doxygen` configuration file to output the API documents in the
same format as appears online in the folder Docs/API within the Cocos3D distribution.

For a complete demonstration of almost all Cocos3D capabilities, see the fully-documented
`CC3DemoMashUp` demo app, which is your best tool for learning the capabilities of Cocos3D,
and how to work within the framework.



Cocos2D Version Compatibility
-----------------------------

Cocos3D under iOS and Android is compatible with `Cocos2D` `3.x` and `Cocos2D` `2.1`, for 
using programmable-pipeline OpenGL ES 2.0, and is compatible with `Cocos2D` `1.1`, for 
using fixed-pipeline OpenGL ES 1.1.

Cocos3D under OSX is compatible with `Cocos2D` `3.x` and `Cocos2D` `2.1`, for using
programmable-pipeline OpenGL. Cocos3D is not compatible with `Cocos2D` `1.1` under OSX.

At the time of this release, the current version of Cocos2D is `3.2.1`, and by default, this 
starter app is pre-configured to use that version. To build and run this app with a different
version of Cocos2D, follow the steps described here:

1. Run the `install-cocos3d.sh` script again and identify the new version of `Cocos2D` to be linked.
   Keep in mind that you must link `Cocos2D` `3.x` or `Cocos2D 2.1` if you want to use OpenGL ES 2.0 
   (iOS & Android) or OpenGL (OSX) with a programmable rendering pipeline, and you must link 
   `Cocos2D 1.1` if you want to use OpenGL ES 1.1 (iOS & Android) with a fixed rendering pipeline.

2. Add the updated Cocos2D files to this project:

	1. Replace the `cocos2d` folder in this project with the updated `Projects/CC3HelloWorld/cocos2d` 
	   folder from the Cocos3D distribution.

	2. In the Xcode *Project Navigator* panel, delete the reference to the *cocos2d* group. 

	3. Drag the updated `cocos2d` folder in this project into the Xcode *Project Navigator* panel. 
	   When prompted for the target to add the source code to, select the `cocos2d` target.

	4. In the Xcode *Project Navigator* panel, delete the reference to the *cocos2d-chipmunk* group.

	5. Replace the `cocos2d-chipmunk` folder in this project with the updated 
	   `Projects/CC3HelloWorld/cocos2d-chipmunk` folder from the Cocos3D distribution.

	6. Drag the updated `cocos2d-chipmunk` folder in this project into the Xcode *Project Navigator* panel. 
	   When prompted for the target to add the source code to, select the `cocos2d-chipmunk` target.

6. If you are using Cocos2D 3.2 or later, configure the `CCNoARC.m` file to use Manual Refernce Counting:

	1. Select the *Build Phases* tab of the `cocos2d` target.

	2. Open the *Compile Sources* list and locate the entry for the `CCNoARC.m` file.

	3. On the `CCNoARC.m` entry, double-click the *Compiler Flags* column and enter the `-fno-objc-arc` 
	   compiler flag. As the name implies, the  `CCNoARC.m` file uses Manual Refernce Counting (MRC)
	   instead of Automatic Reference Counting (ARC), to improve performance.

7. `Cocos2D` `3.x` uses Automatic Reference Counting (ARC). `Cocos2D` `2.1` and `Cocos2D` `1.1`
   do not. You must set the appropriate compiler build setting to ensure the compiler will use
   the correct technique.
	1. Select the `cocos2d` target.
	2. Select the *Build Settings* tab.
	3. Locate the **Objective-C Automatic Reference Counting** (aka `CLANG_ENABLE_OBJC_ARC`)
	   setting for the `cocos2d` target. If you are now linking to `Cocos2D` `3.x`, set this
	   property to `YES`. If you are now linking to `Cocos2D` `2.1` or `Cocos2D` `1.1`, set 
	   this property to NO. Make sure you change only the setting for the `cocos2d` target 
	   within your project. Do not change the setting for the `cocos2d-library-iOS` or 
	   `cocos2d-library-OSX` project itself.
	4. The `cocos2d-chipmunk` part of the `Cocos2D` `3.x` library does *not* use ARC. Ensure
	   the **Objective-C Automatic Reference Counting** (aka `CLANG_ENABLE_OBJC_ARC`) setting
	   of the `cocos2d-chipmunk` target is always set to NO.
8. `Cocos2D` `3.x` supports compiling to the ARM64 architecture. `Cocos2D` `2.1` and
   `Cocos2D` `1.1` do *not* support compiling to the ARM64 architecture. Because of this,
   by default, the **Valid Architectures** (aka `VALID_ARCHS`) build setting for all demo 
   Xcode Projects in the Cocos3D distribution is set to `$(ARCHS_STANDARD_32_BIT)` (which 
   resolves to **armv7 armv7s**), so that the demo projects will compile with all versions
   of `Cocos2D`. If you are now linking to `Cocos2D` `3.x`, you can set this property to
   `$(ARCHS_STANDARD)` (or simply remove this setting from the Project), in all demo Projects,
   to allow compilation to include the ARM64 architecture.
9. As a development optimization, if you are now linking to `Cocos2D` `3.x`, you can set the 
   value of the **Build Active Architecture Only** (aka `ONLY_ACTIVE_ARCH`) build setting in 
   the *Debug* configuration in all demo projects to `YES`. You should not do this if you are
   linking to `Cocos2D` `2.1` or `Cocos2D` `1.1`, as this will prohibit you from building
   the demo apps on devices that use the ARM64 processor.
10. If you have already built the demo app using the old version of `Cocos2D`, delete the 
   contents of your `~/Library/Developer/Xcode/DerivedData` folder before attempting to compile again.


Compiling for Android
---------------------

Cocos3D (along with Cocos2D) is written in Objective-C. Cocos3D has partnered with 
[Apportable](http://www.apportable.com) to bring your 3D apps and games to the Android
platform. The Apportable SDK is a free SDK for porting Objective-C applications to Android.

To build and install your app or game project for the Android platform:

1. Download and install the Apportable SDK.
2. Open a `Terminal` window and navigate to the Xcode project folder of your Cocos3D app.
3. Run the command: `apportable install` to build and install your Cocos3D app on an
   Android device connected to your computer.
	
Please refer to the Apportable SDK documentation for more information about building,
installing, and debugging your app on Android. If you are building an OpenGL ES 1.1 app, 
you will need to modify the `configuration.json` file in your Xcode project, as indicated
in that file.


Creating POD 3D Model Files
---------------------------

Cocos3D reads 3D model content from POD files.

If you are using Blender, Maya, or 3DS Max as your 3D editor, you can install the PVRGeoPOD
plugin from Imagination Technologies to export directly from your editor to the POD file format.

For other editors, you can export your 3D model to a file in COLLADA 1.4 format, and then use
the standalone PVRGeoPOD app to convert the COLLADA file to the POD format.

Both the standalone and plugin versions of PVRGeoPOD are available free of charge from
Imagination Technologies, the supplier of the GPU's used in iOS devices.

Read the [full instructions](http://brenwill.com/2011/cocos3d-importing-converting-collada-to-pod/)
for more info on where to get the PVRGeoPOD converter, and how to use it to generate POD files.

If you are using *Blender* as your 3D editor, and have many `.blend` files to export to POD format,
you can use the command-line batch tool available in the `Tools/Blender-POD Batch Converter`
folder in the Cocos3D distribution. See the `README.txt` file in that folder for instructions.
The `Blender-POD Batch Converter` tool was created by Cocos3D user Nikita Medvedev.


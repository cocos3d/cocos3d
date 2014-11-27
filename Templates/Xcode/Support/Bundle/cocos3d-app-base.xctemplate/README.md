<a href="http://cocos3d.org"><img src="http://cocos3d.org/images/cocos3d-Banner-150h.png" /></a>

README
----------------------

Cocos3D 2.0.1

Copyright (c) 2010-2014 [The Brenwill Workshop Ltd.](http://www.brenwill.com) All rights reserved.

*This document is written in [Markdown](http://en.wikipedia.org/wiki/Markdown) format. For best results, use a Markdown reader.*


Getting Started
---------------

This starter application presents a 3D take on the ubiquitous ***hello, world*** application,
and can be compiled to run on any iOS devices.

This project is complete, but Xcode does not automatically create the dependencies 
between the targets within this project. You can do this as follows:

1. Once this template project opens, select your `___PROJECTNAMEASIDENTIFIER___` project in the 
   Xcode *Project Navigator* panel.

2. Select the `___PROJECTNAMEASIDENTIFIER___` target.

3. Select the *Build Phases* tab of the `___PROJECTNAMEASIDENTIFIER___` target.

4. Open the *Target Dependencies* list and add the `cocos3d`, `cocos2d`, and `cocos2d-chipmunk` 
   (if it exists) targets to the list. The `cocos2d-chipmunk` target will only exist if you
   are using `Cocos2D 3.x`.

The content of the scene is constructed in the `initializeScene` method in the
`___PROJECTNAMEASIDENTIFIER___Scene.m` file. To add your own 3D content, edit that method.

The `___PROJECTNAMEASIDENTIFIER___Scene.m` file is also where you add interactive behaviour,
typically in the `updateBeforeTransform:` method.

You can also edit the `application:didFinishLaunchingWithOptions:` method in the
`AppDelegate.m` file to tweak the basic setup of your
Cocos3D application. This method is where the Cocos3D framework is hooked into the
Cocos2D framework, and Apple's OpenGL ES framework.

NOTE: The `hello-world.pod` 3D model data file used for the ***hello, world*** message model
is fairly large, because converting a font to a mesh results in a LOT of triangles.
When adapting this template project for your own application, don't forget to remove the
'hello-world.pod' from the Resources folder of your project!


Learning Cocos3D
----------------

Wondering how to get started? View Harry Dart-O’Flynn’s wonderful [Starting Cocos3D](http://www.youtube.com/playlist?list=PLU4bmVOOYXK-fV0Wt-ES5n3k8qTTyqgYu) collection of video tutorials!

To learn more about Cocos3D, please refer to the [Cocos3D Programming Guide](http://brenwill.com/2011/cocos3d-programming-guide/)
and the latest [API documentation](http://brenwill.com/docs/cocos3d/2.0.1/api/).

You can create a local copy of the API documentation using `Doxygen` to extract the documentation
from the source files. There is a `Doxygen` configuration file to output the API documents in the
same format as appears online in the folder Docs/API within the Cocos3D distribution.

For a complete demonstration of almost all Cocos3D capabilities, see the fully-documented
`CC3DemoMashUp` demo app, which is your best tool for learning the capabilities of Cocos3D,
and how to work within the framework.


Cocos2D & OpenGL ES Version Compatibility
-----------------------------------------

Cocos3D under iOS and Android is compatible with `Cocos2D` `3.0` and `Cocos2D` `2.1`, for 
using programmable-pipeline OpenGL ES 2.0, and is compatible with `Cocos2D` `1.1`, for using
fixed-pipeline OpenGL ES 1.1.

Cocos3D under OSX is compatible with `Cocos2D` `3.0` and `Cocos2D` `2.1`, for using 
programmable-pipeline OpenGL (OSX). Cocos3D is not compatible with `Cocos2D` `1.1` under OSX.

Choosing the appropriate Cocos3D template will automatically link to the corresponding version
of the `Cocos2D` library, if it exists in your template environment. You must ensure that you 
have downloaded the appropriate version of `Cocos2D`, and have installed its templates.


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


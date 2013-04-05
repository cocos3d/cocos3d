README!
----------------------

cocos3d 2.0.0

Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
http://www.brenwill.com

+++++++++++++++++++++++++++++++++++


Getting Started
---------------

This starter application presents a 3D take on the ubiquitous "hello, world" application,
and can be compiled to run on any iOS devices.

The content of the scene is constructed in the initializeScene method in the
___PROJECTNAMEASIDENTIFIER___Scene.m file. To add your own 3D content, edit that method.

The ___PROJECTNAMEASIDENTIFIER___Scene.m file is also where you add interactive behaviour,
typically in the updateBeforeTransform: method.

You can also edit the applicationDidFinishLaunching: method in the
___PROJECTNAMEASIDENTIFIER___AppDelegate.m file to tweak the basic setup of your
cocos3d application. This method is where the cocos3d framework is hooked into the
cocos2d framework, and Apple's OpenGL ES framework.

For a complete demonstration of almost all cocos3d capabilities, see the fully-documented
CC3DemoMashUp demo app, which is your best tool for learning the capabilities of cocos3d,
and how to work within the framework.

NOTE: The 'hello-world.pod' 3D model data file used for the 'hello, world' message model
is fairly large, because converting a font to a mesh results in a LOT of triangles.
When adapting this template project for your own application, don't forget to remove the
'hello-world.pod' from the Resources folder of your project!


cocos2d & OpenGL ES Version Compatibility
-----------------------------------------

cocos3d is compatible with cocos2d 1.0.1 and 1.1, for using fixed-pipeline OpenGL ES 1.1,
and is compatible with cocos2d 2.0 and 2.1, for using programmable-pipeline OpenGL ES 2.0.

This template application will use whichever version of cocos2d you indicated when you ran
the install_cocos3d.sh script. You can easily change the version of cocos2d that is linked
to this project by following these steps within Xcode:

1. Delete the reference to the cocos2d group in the Xcode Project Navigator panel.
2. Run the install_cocos3d script and identify the new version of cocos2d to be linked.
3. Add the newly linked cocos2d files to the project by dragging the cocos2d folder from
   the cocos3d distribution folder to the Xcode Project Navigator panel.

By linking to cocos2d 2.x, you will automatically use OpenGL ES 2.0, and by linking to
cocos2d 1.x, you will automatically use OpenGL ES 1.1. Because of this, you cannot mix
the use of OpenGL ES 2.0 and 1.1 within a single application.


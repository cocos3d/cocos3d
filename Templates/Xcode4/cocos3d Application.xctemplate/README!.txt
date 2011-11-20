README!
----------------------

cocos3d 0.6.4

Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
http://www.brenwill.com

+++++++++++++++++++++++++++++++++++


Getting Started
---------------

This starter application presents a 3D take on the ubiquitous "hello, world" application.

The content of the world is constructed in the initializeWorld method in the
___PROJECTNAMEASIDENTIFIER___World.m file. To add your own 3D content, edit that method.

The ___PROJECTNAMEASIDENTIFIER___World.m file is also where you add interactive behaviour,
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


cocos2d Version Compatibility
-----------------------------

cocos3d 0.6.4 is compatible with cocos2d versions 0.99.5 through 1.1.

At the time of this release, the current version of cocos2d is 1.0.1, and by default, cocos3d is
configured to use that version. This section includes notes on compatibility with other versions.

   cocos2d 1.1
   -----------

   Version 1.1 of cocos2d introduced a change to the structure used for 2D particles.
   When running cocos2d 1.1 set the following build setting in your Xcode build configuration:

      CC_USES_2D_PARTICLES=0

   You can set this in your Xcode project build settings in the Preprocessor Macros entry.
   This applies to any cocos3d project, including the demo projects that are included in the
   cocos3d distribution and the cocos3d project templates.

   cocos2d 0.9.5
   -------------

   Version 0.99.5 of cocos2d contains several files that were removed in cocos2d 1.0,
   These files are not included in the cocos3d Xcode demo apps and project templates.
   When using cocos2d 0.9.5, drag the following files to the cocos2d group within the Xcode project:

      cocos2d/CCCompatibility.h
      cocos2d/CCCompatibility.m
      cocos2d/CCSpriteSheet.h
      cocos2d/CCSpriteSheet.m
      TouchJSON/Extensions/NSCharacterSet_Extensions.h
      TouchJSON/Extensions/NSCharacterSet_Extensions.m
      TouchJSON/Extensions/NSScanner_Extensions.h
      TouchJSON/Extensions/NSScanner_Extensions.m

   Because of the modular nature of Xcode 4 project templates, the cocos3d Xcode 4 template
   project uses whichever cocos2d Xcode 4 project templates were installed. Typically this
   will be the cocos2d 1.0.0 project templates, unless you have created cocos2d 0.99.5
   Xcode 4 project templates.

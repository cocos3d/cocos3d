README!
----------------------

cocos3d 0.6.0-sp

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

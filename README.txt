README - cocos3d 0.5.4
----------------------

cocos3d 0.5.4

Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
http://www.brenwill.com

+++++++++++++++++++++++++++++++++++

Installation
------------

The cocos3d framework is built on cocos2d. You must download and install the cocos2d SDK from

http://www.cocos2d-iphone.org/download 

before installing cocos3d.

Unzip the cocos3d distribution file (which you've probably already done,
otherwise you wouldn't be reading this document).

Open a Terminal session, navigate to the unzipped cocos3d distribution
directory and run the install-cocos3d script as follows:

./install-cocos3d.sh -u -f -2 "relative-path-to-cocos2d-sources"

For example:

./install-cocos3d.sh -u -f -2 "../../cocos2d/cocos2d-iphone-0.99.5"

The cocos2d source code must be available and identified using the -2 switch
so that the installer can copy the cocos2d libraries to the cocos3d templates
and demo projects.

That's it!


cocos2d Version Compatibility
-----------------------------

cocos3d 0.5.4 is compatible with both cocos2d 0.99.5 and cocos2d 1.0.0.

Please note that at the time of this 0.5.4 release, cocos2d 1.0.0 was still in release-candidate
stage. Therefore, the cocos3d Xcode 3 template and the cocos3d demo application projects have been built
with cocos2d 0.99.5.

If you use cocos2d 1.0.0, be aware that several cocos2d files that are referenced in the cocos3d
Xcode projects have been removed from cocos2d 1.0.0. You will need to delete these files from the
cocos3d Xcode projects before building. Xcode will spit out file-not-found errors otherwise.

The following files were removed in cocos2d 1.0.0 and references to them must be deleted from your
cocos3d project if you are using cocos2d 1.0.0:

   cocos2d/CCCompatibility.h
   cocos2d/CCCompatibility.m
   cocos2d/CCSpriteSheet.h
   cocos2d/CCSpriteSheet.m
   TouchJSON/Extensions/NSCharacterSet_Extensions.h
   TouchJSON/Extensions/NSCharacterSet_Extensions.m
   TouchJSON/Extensions/NSScanner_Extensions.h
   TouchJSON/Extensions/NSScanner_Extensions.m

Once you remove the references from the cocos3d project, the project will successfully build and run.

Because of the modular nature of Xcode 4 project templates, the cocos3d Xcode 4 template project
uses whichever cocos2d Xcode 4 project templates were installed. Typically this will be the
cocos2d 1.0.0 project templates, unless you have created cocos2d 0.99.5 Xcode 4 project templates.


Creating Your First cocos3d Project
-----------------------------------

To get started with your first cocos3d project, follow one of the following instructions, depending
on whether you are using Xcode 3 or Xcode 4:

   Xcode 3:
   --------

   Open Xcode, click on the File->NewProject... menu selection, and select the 'cocos3d Application'
   project template from the 'cocos3d 0.5' template group.

   If you are using cocos2d 1.0.0, read the notes above regarding running the demo apps with that version.

   This project starts with a working 3D variation on the familiar 'hello, world' application, and you
   can use it as a starting point for your own application.

   Xcode 4:
   --------

   Open Xcode, click on the File->New->NewProject.. menu selection, and select the 'cocos3d Application'
   project template from the cocos3d template group.

   Drag the 'cocos3d 0.5.4/cocos3d' source code folder to your new Xcode 4 project. For instructions on
   how to do this, and an explanation of why it is necessary, please see the README! file in your Xcode 4
   cocos3d project after you have created it from the Xcode 4 project template. This step is NOT required
   if you are using Xcode 3.

   If you are using cocos2d 1.0.0, read the notes above regarding running the demo apps with that version.

   This project starts with a working 3D variation on the familiar 'hello, world' application, and you
   can use it as a starting point for your own application.


Demo Applications
-----------------

To help get you learn how to work with cocos3d, the following demo apps are included
in the cocos3d distribution. They will help you understand how to use cocos3d, and
demonstrate many of the key features and capabilities of cocos3d.


   CC3DemoMashUp
   _____________

   Your camera hovers over a virtual world that includes animated robots, bouncing beach-balls,
   spinning globes, and a selection of animated teapots. This is a sophisticated demo that
   showcases many interesting features of cocos3d, including:

     - loading mesh models, cameras and lights from 3D model files stored in the PowerVR POD format
     - creating mesh models from static header file data
     - sharing mesh data across several nodes with different materials
     - loading 3D models from a POD file converted from a Collada file created in a 3D editor
     - assemblies of nodes in a hierarchical parent-child structual assembly.
     - texturing a 3D mesh from a CCTexture2D image
     - texturing a mesh using UV coordinates exported from a 3D editor
     - transparency and alpha-blending
     - coloring a mesh with a per-vertex color blend
     - animating 3D models using a variety of standard cocos2d CCActionIntervals
     - overlaying the 3D world with 2D cocos2d controls such as joysticks and buttons
     - displaying 2D labels (eg- health-bars) at locations projected from the position of 3D objects
     - directing the 3D camera to track a particular target object
     - selecting a 3D object by touching the object on the screen with a finger
     - placing a 3D object on another at a point that was touched with a finger
     - toggling between opacity and translucency using the isOpaque property
     - creating and deploying many copies of a node, while sharing the underlying mesh data
     - constructing and drawing a wire-frame bounding box around a node using CC3LineNode
     - constructing and drawing a rectangular plane mesh using CC3PlaneNode


   CC3Performance
   --------------

   This is a simple demo of the performance characteristics of cocos3d. It demonstrates how to
   collect statistics about your application's performance. In doing so, it presents a number
   of model scenarios, and through the user interface, you can control the type of model loaded
   and how many copies to render.

   You can dynamically experiment with how different model types, sizes and quantities affects
   the performance of cocos3d. You can also use this performance demo app to compare performance
   across different device types.


Creating POD 3D Model Files
---------------------------

The PowerVR SDK contains tools for converting from a limited number of 3D editor export
files. The PVR SDK is available free from Imagination Technologies, the supplier of the
GPU's used in iOS devices. You can download the PowerVR SDK from:

http://www.imgtec.com/powervr/insider/sdk/KhronosOpenGLES1xMBX.asp

If you are using Blender (or any 3D editor), you can export your 3D model to a file in
Collada 1.4 format, and used the Collada2POD converter tool (GUI or command line) in the
PVR SDK to convert the Collada file to POD format.

For convenience, when using the Collada2POD tool, you can use the settings in the
Tools/Collada2PODSettings.txt file in the cocos3d distribution. When using the
Collada2POD GUI converter, please be aware that the tool does not store the setting
for the Invert Transparency flag. This flag must be turned on each time you use the
GUI tool to avoid having all your models disappear.

Please also note that the Collada2POD tool rotates data so that the Z-axis is 'up'.
Since the OpenGL ES default is to have the Y-axis as up, and the camera looking down
the -Z-axis, it is usually more convenient to use the OpenGL orientation in cocos3d
(although there's nothing to stop you from rotating everything by 90 degrees in cocos3d).

With this in mind, when using Blender, and exporting to POD via Collada, orient your
model world so that 'up' is along the Z-axis (which is the Blender default anyway).
The Collada2POD tool will then rotate the axes so that 'up' is along the Y-axis when
the model is imported into cocos3d.


PowerVR Library
---------------

In order to reduce the size of the cocos3d distribution, several large and
unused files have been removed from the PVR library. More info can be found
in the document: 'cocos3d/cc3PVR/PVRT 2.07/PVRT_Removed_Files.txt'.



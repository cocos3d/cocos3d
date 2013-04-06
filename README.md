<img src="http://www.cocos2d-iphone.org/downloads/cocos2d_logo.png">

Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.

cocos3d
=======

Table of Contents
-----------------

- About cocos3d
- Installation
- cocos2d & OpenGL Version Compatibility
- Creating Your First cocos3d Project
- Documentation
- Demo Applications
    - CC3DemoMashUp - demos all important cocos3d features
    - CC3Demo3DTiles - demos displaying many tiled 3D scenes in a single window
    - CC3Performance - demos collecting cocos3d performance statistics
- Demo Models
- Creating POD 3D Model Files


About cocos3d
-------------

cocos3d is a sophisticated, yet intuitive and easy-to-use, 3D application development 
framework for the iOS platform. With cocos3d, you can build sophisticated, dynamic 3D
games and applications using Objective-C.

- Build 3D apps for iOS devices or Mac computers running OSX. The same 3D content and game logic will run unchanged under iOS or Mac OSX.
- Use OpenGL programmable pipelines for sophisticated GLSL shader rendering, or use OpenGL fixed pipelines for simpler configurable rendering.
- Supports OpenGL ES 2.0 or OpenGL ES 1.1 on iOS devices, and OpenGL programmable or fixed pipelines on Mac OSX.
- Seamless integration with cocos2d. Rendering of all 3D model objects occurs within a special cocos2d layer, which fits seamlessly into the cocos2d node hierarchy, allowing 2D nodes such as controls, labels, and health bars to be drawn under, over, or beside 3D model objects. With this design, 2D objects, 3D objects, and sound can interact with each other to create a rich, synchronized audio-visual experience.
- Seamless integration with the iOS UIViewController framework.
- Pluggable loading framework for 3D models exported from familiar 3D editors such as Blender, 3ds Max or Cheetah3D, or through industry standard 3D object files such as Collada or PowerVR POD, or even from your own customized object file formats.
- 3D models can be selected and positioned by touch events and gestures, allowing intuitive user interaction with the objects in the 3D world.
- 3D models can include animation sequences, with full or fractional animation.
- 3D model objects can be arranged in sophisticated structural assemblies, allowing child objects to be moved and oriented relative to their parent structure.
- 3D models and assemblies can be easily duplicated. Each duplicated model can be independently controlled, animated, colored, or textured. But fear not, underlying mesh data is shared between models. You can quickly and easily create swarming hoards to populate your 3D world, without worrying about device memory limitations.
- 3D models, cameras, and lighting can be manipulated and animated using familiar cocos2d Actions, allowing you to quickly and easily control the dynamics of your 3D world, in a familiar, and easy-to-use programming paradigm.
- 3D objects can be covered with dynamic materials and textures to create rich, realistic imagery.
- Multi-texturing and bump-mapped textures are available, allowing you to create sophisticated surface effects.
- Vertex skinning, also often referred to as bone rigging, allowing soft-body meshes to be realistically deformed based on the movement of an underlying skeleton constructed of bones and joints.
- Automatic shadowing of models using shadow volumes.
- Collision detection between nodes.
- Ray-casting for nodes intersected by a ray, and the local location of intersection on a node or mesh, right down to the exact mesh intersection location and face.
- The 3D camera supports both perspective and orthographic projection options.
- Objects can dynamically track other objects as they move around the world. The 3D camera can dynamically point towards an object as it moves, and other objects can dynamically point towards the camera as it moves.
- Lighting effects include multiple lights, attenuation with distance, spotlights, and fog effects.
- Mesh data can be shared between 3D objects, thereby saving precious device memory.
- Mesh data can freely, and automatically, use OpenGL vertex buffer objects to improve performance and memory management.
- Culling of 3D objects outside of the camera frustum is automatic, based on pluggable, customizable object bounding volumes.
- Automatic ordering and grouping of 3D objects minimizes OpenGL state changes and improves rendering performance. Pluggable sorters allow easy customization of object sorting, ordering, and grouping for optimal application performance.
- Integrated particle systems:
- 3D point particles provide efficient but sophisticated particle effects.
- 3D mesh particles allow particles to be created from any 3D mesh template (eg- spheres, cones, boxes, POD models, etc).
- Automatic OpenGL state machine shadowing means that the OpenGL functions are invoked only when a state really has changed, thereby reducing OpenGL engine calls, and increasing OpenGL throughput.
- Sophisticated performance metrics API and tools collect real-time application drawing and updating performance statistics, for logging or real-time display.
- Sophisticated math library eliminates the need to use OpenGL ES function calls for matrix mathematics.
- Fully documented API written entirely in familiar Objective-C. No need to switch to C or C++ to work with 3D artifacts.
- Extensive logging framework to trace program execution, including all OpenGL ES function calls.
- Includes demo applications and Xcode templates to get you up and running quickly.


Installation
------------

1. The cocos3d framework works with [cocos2d](http://www.cocos2d-iphone.org). Before installing
cocos3d, you must [download](http://www.cocos2d-iphone.org/download) and install cocos2d.<br/><br/>

	The same cocos3d distribution can be used with either `cocos2d 2.x` or `cocos2d 1.x`.
	Link to `cocos2d 2.x` to make use of the more advanced shader-based programmable-pipeline
	available with OpenGL ES 2.0 (iOS) or OpenGL (OSX). Or link to `cocos2d 1.x` to use the
	simpler configurable fixed-pipeline of OpenGL ES 1.1 (iOS) or OpenGL (OSX), and avoid
	the need to write GLSL shaders.

2. Download the latest [stable cocos3d release](http://cocos3d.org), or clone the
[cocos3d github repository](http://github.com/cocos3d/cocos3d).

3. Unzip the cocos3d distribution file.

4. Open a Terminal session, navigate to the unzipped cocos3d distribution
directory and run the install-cocos3d script as follows:

		./install-cocos3d.sh -f -2 "path-to-cocos2d"

	For example:

		./install-cocos3d.sh -f -2 "../cocos2d-iphone-2.0"

	The cocos2d distribution must be available and identified using the -2 switch so the
	installer can link the cocos2d libraries to the cocos3d templates and demo projects.<br/><br/>
	
	You may use either a relative path (as above), or an absolute path. If for some reason
	the relative path cannot be correctly resolved on your system, or the resulting links 
	to the cocos2d library are not accurate, try again using the full absolute path.

	If you encounter `rsync` errors during installation, it's typically because you are
	trying to run the installer without first navigating to the cocos3d distribution directory.
	Be sure to run the installer from the cocos3d distribution directory.

5. That's it!

Keep in mind that cocos3d does not "patch" your cocos2d installation. Instead, you install
cocos3d alongside cocos2d, and link to it using the installation script. As a concrete 
example, let's say you have a development directory named `MyCocosDev`, into which you 
download and unzip both cocos2d and cocos3d. You'll end up with a directory structure like:

	MyCocosDev
		cocos2d-iphone-2.0
		cocos3d-2.0.0

First, in a Terminal session, install cocos2d by navigating to the `cocos2d-iphone-2.0`
directory and running:

	./install-templates.sh -f -u

Then, navigate to the `cocos3d-2.0.0` directory and install cocos3d by running:

	./install-cocos3d.sh -f -2 "../cocos2d-iphone-2.0"


cocos2d & OpenGL Version Compatibility
-----------------------------------------

cocos3d is compatible with `cocos2d` `1.1` and `1.0.1`, for using fixed-pipeline OpenGL ES 1.1 (iOS)
or OpenGL (OSX), and is compatible with `cocos2d` `2.1` and `2.0`, for using programmable-pipeline
OpenGL ES 2.0 (iOS) or OpenGL (OSX).

When linking to a cocos2d library version, keep in mind that if you want to use shaders and a
programmable pipeline using OpenGL ES 2.0 (iOS) or OpenGL (OSX), you must use a `cocos2d 2.x`
version, and if you want to use a fixed pipeline using OpenGL ES 1.1 (iOS) or OpenGL (OSX),
you must use a `cocos2d 1.x` version.

Because of this, you cannot mix the use of fixed and programmable pipelines within a single app.
However, you can easily change whether an app uses a programmable or fixed rendering pipeline
by changing the version of `cocos2d` that is linked, by following these steps within any Xcode
project (including any of the included demo apps):

1. Delete the reference to the cocos2d group in the Xcode Project Navigator panel.
2. Run the `install-cocos3d.sh` script again and identify the new version of cocos2d to be linked.
   Keep in mind that you must link `cocos2d 2.x` if you want to use OpenGL ES 2.0 (iOS) or
   OpenGL (OSX) with a programmable rendering pipeline, and you must link `cocos2d 1.x` if
   you want to use OpenGL ES 1.x (iOS) or OpenGL (OSX) with a fixed rendering pipeline.
3. Add the newly linked cocos2d files to the project by dragging the `cocos2d` folder from
   the cocos3d distribution folder to the Xcode Project Navigator panel.

At the time of this release, the current stable version of cocos2d is `2.0`, and by default,
the demo apps within the cocos3d distribution are pre-configured to use that version. To build
and run the demo apps with a different version of cocos2d, follow the steps described above.


Creating Your First cocos3d Project
-----------------------------------

The `install-cocos3d.sh` script also installs several convenient Xcode project templates.

To get started with your first cocos3d iOS project, open Xcode 4, click on the File->New->NewProject...
menu selection, and select either the *cocos3d2 iOS Application* or the *cocos3d1 iOS Application*
project template from the cocos3d template group in the iOS section, depending on whether you want to
use OpenGL ES 2.0, or OpenGL ES 1.1, respectively.

Remember that if you want to use the *cocos3d2 iOS Application* template and OpenGL ES 2.0, your
cocos3d installation must be linked to a `cocos2d 2.x` version, as described above, and if you
want to use the *cocos3d1 iOS Application* template and OpenGL ES 1.1, your cocos3d installation
must be linked to a `cocos2d 1.x` version, as described above.

To get started with your first cocos3d Mac OSX project, open Xcode 4, click on the File->New->NewProject...
menu selection, and select either the *cocos3d2 Mac Application* or the *cocos3d1 Mac Application* project
template from the cocos3d template group in the OS X section, depending on whether you want to use
OpenGL with a programmable rendering pipeline, or a configurable fixed rendering pipeline, respectively.

Remember that if you want to use the *cocos3d2 Mac Application* template and OpenGL with a programmable
pipeline, your cocos3d installation must be linked to a `cocos2d 2.x` version, as described above, and
if you want to use the *cocos3d1 Mac Application* template and OpenGL with a fixed pipeline, your cocos3d
installation must be linked to a `cocos2d 1.x` version, as described above.

The template project starts with a working 3D variation on the familiar *hello, world*
application, and you can use it as a starting point for your own application.


Documentation
-------------

To learn more about cocos3d, please refer to the [cocos3d Programming Guide](http://brenwill.com/2011/cocos3d-programming-guide/)
and the latest [API documentation] (http://brenwill.com/docs/cocos3d/2.0.0/api/).

You can create a local copy of the API documentation using Doxygen to extract the documentation
from the source files. There is a Doxygen configuration file to output the API documents in the
same format as appears online in the folder Docs/API within the cocos3d distribution.


Demo Applications
-----------------

The best way to understand what cocos3d can do is to look at the examples and code in the demo
applications that are included in the cocos3d distribution. These demos, particularly the
`CC3DemoMashUp` app, will help you understand how to use cocos3d, and demonstrate many of the
key features and capabilities of cocos3d.

For convenience, to access all of the demos together, open either the *cocos3d-iOS.xcworkspace*
or *cocos3d-Mac.xcworkspace* Xcode workspace. You can also open each demo project individually
in the Demos folder.

At the time of this release, the current stable version of cocos2d is `2.0`, and by default,
the demo apps within the cocos3d distribution are pre-configured to use that version. To build
and run the demo apps with a different version of cocos2d, follow the steps described above in
the section about cocos2d version compatibility.

The following demo apps are included in the cocos3d distribution:


CC3DemoMashUp
-------------

Please read the class notes of the `CC3DemoMashUpScene` class for a full description of how to
run and interact with this demo, and what features it covers.

Your camera hovers over a scene that includes animated robots, bouncing beach-balls,
spinning globes, and a selection of animated teapots. This is a sophisticated demo that
showcases many interesting features of cocos3d, including:

- loading mesh models, cameras and lights from 3D model files stored in the PowerVR POD format
- creating mesh models from static header file data
- sharing mesh data across several nodes with different materials
- loading 3D models from a POD file converted from a Collada file created in a 3D editor (Blender)
- assembling nodes into a hierarchical parent-child structual assembly.
- programatic creation of spherical, box and plane meshes using parametric definitions.
- texturing a 3D mesh from a CCTexture2D image
- transparency and alpha-blending
- translucent and transparent textures
- coloring a mesh with a per-vertex color blend
- multi-texturing an object using texture units by combining several individual textures into overlays
- DOT3 bump-map texturing of an object to provide high-resolution surface detail on a model with few actual vertices
- Vertex skinning with a soft-body mesh bending and flexing based on the movement of skeleton bone nodes.
- Copying soft-body nodes to create a completely separate character, with its own skeleton, that can be manipulated independently of the skeleton of the original.
- animating 3D models using a variety of standard cocos2d CCActionIntervals
- overlaying the 3D scene with 2D cocos2d controls such as joysticks and buttons
- embedding 2D cocos2d text labels into the 3D scene
- incorporating 2D cocos2d CCParticleEmitters into the 3D scene (as a sun and explosion fire)
- emitting 3D point particles from a moving nozzle, with realistic distance attenuation
- emitting two different types of 3D mesh particles, with distinct textures, from a moving nozzle, with each particle moving, rotating, and fading independently
- creating a tightly focused spotlight whose intensity attenuates with distance
- directing the 3D camera to track a particular target object
- directing an object to track the camera, always facing (looking at) the camera (aka halo objects)
- directing an object to track another object, always facing (looking at) that object
- selecting a 3D object by touching the object on the screen with a finger
- placing a 3D object on another at a point that was touched with a finger
- adding a small CC3Layer/CC3Scene pair as a child window to a larger CC3Layer/CC3Scene pair.
- moving, scaling and fading a CC3Layer and its CC3Scene
- creating parametric boxes and texturing all six sides of the box with a single texture.
- adding an object as a child of another, but keeping the original orientation of the child 
- handling touch-move events to create swipe gestures to spin a 3D object using rotation around an arbitrary axis
- toggling between opacity and translucency using the isOpaque property
- choosing to cull or display backfaces (shouldCullBackFaces)
- creating and deploying many independent copies of a node, while sharing the underlying mesh data
- drawing a descriptive text label on a node using CC3Node shouldDrawDescriptor property.
- drawing a wireframe bounding box around a node using CC3Node shouldDrawWireframeBox property.
- automatically zooming the camera out to view all objects in the scene
- constructing and drawing a highly tessellated rectangular plane mesh using CC3PlaneNode
- caching mesh data into GL vertex buffer objects and releasing vertex data from application memory
- retaining vertex location data in application memory (retainVertexLocations) for subsequent calculations
- moving the pivot location (origin) of a mesh to the center of geometry of the mesh.
- attaching application-specific userData to any node
- applying a texture to all six sides of a parametric box
- displaying direction marker lines on a node to clarify its orientation during development.
- displaying a repeating texture pattern across a mesh
- creating and displaying shadow volumes to render shadows for selected nodes
- detecting the local location of where a node was touched using ray tracing
- collision detection between nodes
- texturing a node with only a small section of single texture
- using the CC3Scene onOpen method to initiate activity when a scene opens
- using pinch and pan gestures to control the movement of the 3D camera
- using tap gestures to select 3D objects, and pan gestures to spin 3D objects
- bitmapped font text labels
- moving individual vertex location programmatically
  
In addition, there are a number of interesting options for you to play with by uncommenting
certain lines of code in the methods of this class that build objects in the 3D scene,
including experimenting with:

- simple particle generator with multi-colored, light-interactive, particles
- simple particle generator with meshes updated less frequently to conserve performance 
- different options for ordering nodes when drawing, including ordering by mesh or texture
- configuring the camera for parallel/isometric/orthographic projection instead of the default
  perpective projection
- mounting the camera on a moving object, in this case a bouncing ball
- mounting the camera on a moving object, in this case a bouncing ball, and having the
  camera stay focused on the rainbow teapot as both beach ball and teapot move and rotate
- directing an object to track another object, always facing that object, but only
  rotating in one direction (eg- side-to-side, but not up and down).
- displaying 2D labels (eg- health-bars) overlayed on top of the 3D scene at locations projected from the position of 3D objects
- disabling animation for a particular node, in this case the camera and light
- invading with an army of teapots instead of robots
- ignore lighting conditions when drawing a node to draw in pure colors and textures
- initializing and disposing of users data by adding initUserData and releaseUserData method extension categories.
- displaying descriptive text and wireframe bounding boxes on every node
- displaying a dynamic bounding box on a 3D particle emitter.
- making use of a fixed bounding volume for the 3D particle emitter to improve performance.
- permitting a node to cast a shadow even when the node itself is invisible by using the shouldCastShadowsWhenInvisible property


CC3Demo3DTiles
--------------

A simple demo that lays out multiple small cocos3d scenes as layers in a larger cocos2d layer.
The effect is a grid of tiles, with each tile displaying a separate 3D scene, each containing
its own camera and lighting. The main node in each 3D tile can be rotated under touch control.

This demonstrates the ability to simply include 3D objects in an otherwise 2D game, and techniques
for optimizing under those conditions. It also demonstrates touch control when many 3D scene are
visible concurrently, and the ability to add app data to nodes using the userData property.

The CC3Demo3DTiles demo app also demonstrates the use of the cocos2d `RootController` with cocos3d.


CC3Performance
--------------

This is a simple demo of the performance characteristics of cocos3d. It demonstrates how to
collect statistics about your application's performance. In doing so, it presents a number
of model scenarios, and through the user interface, you can control the type of model loaded
and how many copies to render.

You can dynamically experiment with how different model types, sizes and quantities affects
the performance of cocos3d. You can also use this performance demo app to compare performance
across different device types.


Demo Models
-----------

Some of the POD models that appear in the demo and template apps were designed in Blender,
exported to DAE, and converted to POD files using the PowerVR *PVRGeoPOD* converter.

As a reference for the creation of your own 3D models for use in cocos3d, you can find the original
Blender files and DAE files for these POD models in the Models folder in the cocos3d distribution.


Creating POD 3D Model Files
---------------------------

cocos3d reads 3D model content from POD files. If you are using a 3D editor, you can export
your 3D model to a file in COLLADA 1.4 format, and then convert the COLLADA file to the POD
format read by cocos3d.

To convert COLLADA files to POD files, you can use the *PVRGeoPOD* converter tool, which is available
free of charge from Imagination Technologies, the supplier of the GPU's used in iOS devices.

Read the [full instructions](http://brenwill.com/2011/cocos3d-importing-converting-collada-to-pod/)
for more info on where to get the *PVRGeoPOD* converter, and how to use it to convert COLLADA files
to POD files.




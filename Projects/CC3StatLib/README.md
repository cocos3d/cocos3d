<img src="http://www.brenwill.com/docs/cocos3d/Logos/cocos3d-Banner-150h.png">

README
----------------------

Cocos3D 2.0.1

Copyright (c) 2010-2014 [The Brenwill Workshop Ltd.](http://www.brenwill.com) All rights reserved.

*This document is written in [Markdown](http://en.wikipedia.org/wiki/Markdown) format. 
For best results, use a Markdown reader.*


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



Adding this Cocos3D Static Library to an existing Cocos2D Project
-----------------------------------------------------------------

You can add this Cocos3D static library project to an existing Cocos2D application (for example
`MyCocos2DApp`), to allow you to add 3D content to your existing 2D application or game.

1. The first step is to add this Cocos3D static library project as a subproject to your Cocos2D
   Xcode project, as follows:

	1. Copy the top level `CC3StatLib` folder to the `MyCocos2DApp/MyCocos2DApp/Libraries` 
	   folder within your Cocos2D app.
	   
	2. Open your `MyCocos2DApp.xcodeproj` Xcode project.

	3. Drag the Cocos3D static library Xcode subproject at `MyCocos2DApp/MyCocos2DApp/Libraries/CC3StatLib/cocos3d-iOS.xcodeproj` 
	   to the `Libraries` group in the *Project Navigator* panel of your `MyCocos2DApp` Xcode project 
	   (if you are building an OSX app, drag the `cocos3d-OSX.xcodeproj` subproject instead).

	4. Drag the Cocos3D GLSL shader folder at `MyCocos2DApp/MyCocos2DApp/Libraries/CC3StatLib/cocos3d-GLSL`
	   to the `MyCocos2DApp` group in the *Project Navigator* panel of your `MyCocos2DApp` Xcode project.
	   When prompted for the target to add the source code to, select the `MyCocos2DApp` target. 
	   Once added, these files will appear in the *Copy Bundle Resources* list on the *Build Phases* tab 
	   of the `MyCocos2DApp` target.

2. Next, within Xcode, you need to tell your Cocos2D app project how to link to the code 
   and components of this Cocos3D static library subproject:

	1. Select your `MyCocos2DApp` project in the Xcode *Project Navigator* panel.

	2. Select the *Build Phases* tab of the `MyCocos2DApp` target
		1. Open the *Target Dependencies* list and add the `cocos3d` target to the list.
		2. Open the *Link Binary with Libraries* list, and add the `libcocos3d.a` library to the list.

	3. Select the *Build Settings* tab
		1. In the **Header Search Paths** (aka `HEADER_SEARCH_PATHS`) entry, add an entry to
		   `"$(SRCROOT)/$(PROJECT_NAME)/Libraries/CC3StatLib/cocos3d"` 
		   (including the double-quote marks), and mark it as `recursive`.
		2. In the **Other Linker Flags** (aka `OTHER_LD_FLAGS`) entry, add an entry for `-lstdc++`.

3. Cocos3D requires a depth buffer to provide 3D depth realism. You can add a depth buffer in your
   application code in the `AppDelegate.m` file. In the `application:didFinishLaunchingWithOptions:`
   method, add the following line in the constructor for the config dictionary passed to the 
   `setupCocos2dWithOptions:` method:

		CCSetupDepthFormat: @GL_DEPTH_COMPONENT16,         // Cocos3D requires a depth buffer
		
	This will create a basic 16-bit depth buffer, which covers most needs. If you want higher depth
	accuracy, you can use @GL\_DEPTH\_COMPONENT24\_OES. And if you will be using shadow volume effects,
	use @GL\_DEPTH24\_STENCIL8\_OES to create a combined depth and stencil buffer.

4. Add your custom `CC3Layer` and `CC3Scene` source files (`MyCC3Layer.h`, `MyCC3Layer.m`, 
   `MyCC3Scene.h`, and `MyCC3Scene.m`), and any 3D resources your app requires, to the 
   `MyCocos2DApp` target of your `MyCocos2DApp.xcodeproj` Xcode project.

5. You can add a 3D component by adding code similar to the following within one of your
   customized 2D scene layouts (eg - `MyCocos2DScene.m`):

		#import "MyCC3Layer.h"
		
		...
		
		CC3Layer* cc3Layer = [[MyCC3Layer alloc] init];
		cc3Layer.contentSize = CGSizeMake(300.0, 200.0);
		cc3Layer.position = CGPointMake(100.0, 100.0);
		[self addChild: cc3Layer];


Adding this Cocos3D Static Library to a SpriteBuilder Project
-------------------------------------------------------------

You can use Cocos3D to add 3D content to games created with [SpriteBuilder](http://www.spritebuilder.com).
Adding Cocos3D to SpriteBuilder is similar to adding Cocos3D to an existing Cocos2D app, as
described in the previous section. You can add this Cocos3D static library to your SpriteBuilder
app (for example `MySpriteBuilderApp.spritebuilder`) as follows:

1. The first step is to add this Cocos3D static library project as a subproject to your 
   SpriteBuilder Xcode project, as follows:

	1. Copy the top level `CC3StatLib` folder to the `MySpriteBuilderApp.spritebuilder/Source/libs` 
	   folder within your SpriteBuilder app.
	   
	2. Open your `MySpriteBuilderApp.xcodeproj` Xcode project.

	3. Drag the Cocos3D static library Xcode subproject at 
	  `MySpriteBuilderApp.spritebuilder/Source/libs/CC3StatLib/cocos3d-iOS.xcodeproj`. to the
	  `libs` group in the *Project Navigator* panel of your `MySpriteBuilderApp` Xcode project.

	4. Drag the Cocos3D GLSL shader folder at `MySpriteBuilderApp.spritebuilder/Source/libs/CC3StatLib/cocos3d-GLSL`
	   to the *Project Navigator* panel of your `MySpriteBuilderApp` Xcode project.
	   When prompted for the target to add the source code to, select the `MySpriteBuilderApp`
	   target. Once added, these files will appear in the *Copy Bundle Resources* list on the 
	   *Build Phases* tab of the `MySpriteBuilderApp` target.

2. Next, within Xcode, you need to tell your SpriteBuilder app project how to link to the code 
   and components of the Cocos3D subproject:

	1. Select your `MySpriteBuilderApp` project in the Xcode *Project Navigator* panel.

	2. Select the *Build Phases* tab of the `MySpriteBuilderApp` target
		1. Open the *Target Dependencies* list and add the `cocos3d` target to the list.
		2. Open the *Link Binary with Libraries* list, and add the `libcocos3d.a` library to the list.

	3. Select the *Build Settings* tab
		1. In the **Header Search Paths** (aka `HEADER_SEARCH_PATHS`) entry, add an entry to
		   `"Source/libs/CC3StatLib/cocos3d"` (including the double-quote marks),
		   and mark it as `recursive`.
		2. In the **Other Linker Flags** (aka `OTHER_LD_FLAGS`) entry, add an entry for `-lstdc++`.

3. Cocos3D requires a depth buffer to provide 3D depth realism. You can add a depth buffer in your
   application code in the `AppDelegate.m` file. In the `AppContoller application:didFinishLaunchingWithOptions:`
   method, add the following line somewhere ***before*** the call to `setupCocos2dWithOptions:`

		cocos2dSetup[CCSetupDepthFormat] = @GL_DEPTH_COMPONENT16;        // Cocos3D requires a depth buffer
		
   This will create a basic 16-bit depth buffer, which covers most needs. If you want higher depth
   accuracy, you can use @GL\_DEPTH\_COMPONENT24\_OES. And if you will be using shadow volume effects, 
   use @GL\_DEPTH24\_STENCIL8\_OES to create a combined depth and stencil buffer.

4. Add your custom `CC3Layer` and `CC3Scene` source files (`MyCC3Layer.h`, `MyCC3Layer.m`, 
   `MyCC3Scene.h`, and `MyCC3Scene.m`), and any 3D resources your app requires, to the 
   `MySpriteBuilderApp` target of your `MySpriteBuilderApp.xcodeproj` Xcode project.

5. You're now ready to add 3D content to your SpriteBuilder interface. As with any Cocos3D
   application, you provide 3D content by creating a custom subclass of `CC3Layer`. 
   Open your `MySpriteBuilderApp.spritebuilder` project, and add your custom `CC3Layer` 
   to your SpriteBuilder layout as follows:
	1. Drag a *Node* from the SpriteBuilder component palette to your layout.
	2. Set the *Custom class* property of the new component to the name of your custom `MyCC3Layer` class.
	3. Set the *Content size* property to the size at which you want your want your 3D scene to be displayed.
	4. When first placed, the `MyCC3Layer` component will be added as a child of the root node of the 
	   SpriteBuilder scene. If you want the `MyCC3Layer` node to move as part of another node, you can use 
	   the SpriteBuilder timeline hierarchy to reposition the node to be a child of a different parent.
	5. *Save* and *Publish* your new SpriteBuilder layout.
	6. Build and run your app from Xcode to see your new 3D content.
	7. Repeat for all 3D sprites that you want to add to your SpriteBuilder scene.


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

If you are using *Blender*, *Maya*, or *3DS Max* as your 3D editor, you can install the *PVRGeoPOD*
plugin from Imagination Technologies to export directly from your editor to the POD file format.

For other editors, you can export your 3D model to a file in `COLLADA 1.4` format, and then use
the standalone *PVRGeoPOD* app to convert the COLLADA file to the POD format.

Both the standalone and plugin versions of *PVRGeoPOD* are available free of charge from
Imagination Technologies, the supplier of the GPU's used in iOS devices.

Read the [full instructions](http://brenwill.com/2011/cocos3d-importing-converting-collada-to-pod/)
for more info on where to get the *PVRGeoPOD* converter, and how to use it to generate POD files.

If you are using *Blender* as your 3D editor, and have many `.blend` files to export to POD format,
you can use the command-line batch tool available in the `Tools/Blender-POD Batch Converter`
folder in the Cocos3D distribution. See the `README.txt` file in that folder for instructions.
The `Blender-POD Batch Converter` tool was created by Cocos3D user Nikita Medvedev.

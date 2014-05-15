<img src="http://www.brenwill.com/docs/cocos3d/Logos/cocos3d-Banner-150h.png">

README!
----------------------

Cocos3D 2.0.0

Copyright (c) 2010-2014 [The Brenwill Workshop Ltd.](http://www.brenwill.com) All rights reserved.

*This document is written in [Markdown](http://en.wikipedia.org/wiki/Markdown) format. For best results, use a Markdown reader.*


Learning Cocos3D
----------------

Wondering how to get started? View Harry Dart-O’Flynn’s wonderful [Starting Cocos3D](http://www.youtube.com/playlist?list=PLU4bmVOOYXK-fV0Wt-ES5n3k8qTTyqgYu) collection of video tutorials!

To learn more about Cocos3D, please refer to the [Cocos3D Programming Guide](http://brenwill.com/2011/cocos3d-programming-guide/)
and the latest [API documentation](http://brenwill.com/docs/cocos3d/2.0.0/api/).

You can create a local copy of the API documentation using `Doxygen` to extract the documentation
from the source files. There is a `Doxygen` configuration file to output the API documents in the
same format as appears online in the folder Docs/API within the Cocos3D distribution.

For a complete demonstration of almost all Cocos3D capabilities, see the fully-documented
`CC3DemoMashUp` demo app, which is your best tool for learning the capabilities of Cocos3D,
and how to work within the framework.



Adding this Cocos3D Static Library to an existing Cocos2D Project
-----------------------------------------------------------------

You can add this Cocos3D static library (for example `ThisCocos3DStatLib.xcodeproj`) to an existing Cocos2D 
application (for example `MyCocos2DApp`), to allow you to add 3D content to your existing 2D application or game.

1. The first step is to add this Cocos3D static library project as a subproject to your Cocos2D Xcode project,
   as follows:

	1. Copy this Cocos3D static library Xcode project (`ThisCocos3DStatLib`) to the 
	   `MyCocos2DApp/MyCocos2DApp/Libraries` folder within your Cocos2D app.
	   
	2. Open your `MyCocos2DApp.xcodeproj` Xcode project.

	3. Drag this Cocos3D static library Xcode subproject at `MyCocos2DApp/MyCocos2DApp/Libraries/ThisCocos3DStatLib/ThisCocos3DStatLib.xcodeproj`
	   to the `Libraries` group in the *Project Navigator* panel of your `MyCocos2DApp` Xcode project.

2. Next, within Xcode, you need to tell your Cocos2D app project how to link to the code 
   and components of this Cocos3D static library subproject:

	1. Select your `MyCocos2DApp` project in the Xcode *Project Navigator* panel.

	2. Select the *Build Phases* tab of the `MyCocos2DApp` target
		1. Open the *Target Dependencies* list and add both the `cocos3d` and `Cocos3DResources` targets to the list.
		2. Open the *Link Binary with Libraries* list, and add the `libcocos3d.a` library to the list.
		3. Open the *Copy Bundle Resources* list, and drag the `Cocos3DResources.bundle` item from the
		   *Project Navigator* panel to the *Copy Bundle Resources* list (you can find `Cocos3DResources.bundle` 
		   in the `Libraries/ThisCocos3DStatLib.xcodeproj/Products` group folder).

	3. Select the *Build Settings* tab
		1. In the **Header Search Paths** (aka `HEADER_SEARCH_PATHS`) entry, add an entry to
		   `"$(SRCROOT)/$(PROJECT_NAME)/Libraries/ThisCocos3DStatLib/cocos3d"`, and mark it as `recursive`.
		2. In the **Other Linker Flags** (aka `OTHER_LD_FLAGS`) entry, add an entry for `-lstdc++`.

3. Cocos3D requires a depth buffer to provide 3D depth realism. You can add a depth buffer in your
   application code in the `AppDelegate.m` file. In the `application:didFinishLaunchingWithOptions:`
   method, add the following line in the constructor for the config dictionary passed to the 
   `setupCocos2dWithOptions:` method:

		CCSetupDepthFormat: @GL_DEPTH_COMPONENT16,         // Cocos3D requires a depth buffer
		
	This will create a basic 16-bit depth buffer, which covers most needs. If you want higher depth
	accuracy, you can use @GL\_DEPTH\_COMPONENT24. And if you will be using shadow volume effects, use
	@GL\_DEPTH24\_STENCIL8 to create a combined depth and stencil buffer.

4. Add your custom `CC3Layer` and `CC3Scene` source files (`MyCC3Layer.h`, `MyCC3Layer.m`, `MyCC3Scene.h`,
   and `MyCC3Scene.m`), and any 3D resources your app requires, to the `MyCocos2DApp` target of your 
   `MyCocos2DApp.xcodeproj` Xcode project.

5. You can add a 3D component by adding code similar to the following within one of your customized 
   2D scene layouts (eg - `MyCocos2DScene.m`):

		#import "MyCC3Layer.h"
		
		...
		
		CC3Layer* cc3Layer = [[MyCC3Layer alloc] init];
		cc3Layer.contentSize = CGSizeMake(300.0, 200.0);
		cc3Layer.position = CGPointMake(100.0, 100.0);
		[self addChild: cc3Layer];


Adding this Cocos3D Static Library to a SpriteBuilder Project
-------------------------------------------------------------

You can use Cocos3D to add 3D content to games created with [SpriteBuilder](http://www.spritebuilder.com).
Adding Cocos3D to SpriteBuilder is similar to adding Cocos3D to an existing Cocos2D app, as described in 
the previous section. You can add this Cocos3D static library (for example `ThisCocos3DStatLib.xcodeproj`) 
to your SpriteBuilder app (for example `MySpriteBuilderApp.spritebuilder`) as follows:

1. The first step is to add this Cocos3D static library project as a subproject to your SpriteBuilder Xcode 
   project, as follows:

	1. Copy this Cocos3D static library Xcode project (`ThisCocos3DStatLib`) to the 
	   `MySpriteBuilderApp.spritebuilder/Source/libs` folder within your SpriteBuilder app.
	   
	2. Open your `MySpriteBuilderApp.xcodeproj` Xcode project.

	3. Drag this Cocos3D static library Xcode subproject at `MySpriteBuilderApp.spritebuilder/Source/libs/ThisCocos3DStatLib/ThisCocos3DStatLib.xcodeproj`
	   to the `libs` group in the *Project Navigator* panel of your `MySpriteBuilderApp` Xcode project.

2. Next, within Xcode, you need to tell your SpriteBuilder app project how to link to the code 
   and components of the Cocos3D subproject:

	1. Select your `MySpriteBuilderApp` project in the Xcode *Project Navigator* panel.

	2. Select the *Build Phases* tab of the `MySpriteBuilderApp` target
		1. Open the *Target Dependencies* list and add both the `cocos3d` and `Cocos3DResources` targets to the list.
		2. Open the *Link Binary with Libraries* list, and add the `libcocos3d.a` library to the list.
		3. Open the *Copy Bundle Resources* list, and drag the `Cocos3DResources.bundle` item from the
		   *Project Navigator* panel to the *Copy Bundle Resources* list (you can find `Cocos3DResources.bundle` 
		   in the `libs/ThisCocos3DStatLib.xcodeproj/Products` group folder).

	3. Select the *Build Settings* tab
		1. In the **Header Search Paths** (aka `HEADER_SEARCH_PATHS`) entry, add an entry to
		   `Source/libs/ThisCocos3DStatLib/cocos3d`, and mark it as `recursive`.
		2. In the **Other Linker Flags** (aka `OTHER_LD_FLAGS`) entry, add an entry for `-lstdc++`.

3. Cocos3D requires a depth buffer to provide 3D depth realism. You can add a depth buffer in your
   application code in the `AppDelegate.m` file. In the `AppContoller application:didFinishLaunchingWithOptions:`
   method, add the following line somewhere ***before*** the call to `setupCocos2dWithOptions:`

		cocos2dSetup[CCSetupDepthFormat] = @GL_DEPTH_COMPONENT16;        // Cocos3D requires a depth buffer
		
	This will create a basic 16-bit depth buffer, which covers most needs. If you want higher depth
	accuracy, you can use GL\_DEPTH\_COMPONENT24. And if you will be using shadow volume effects, use
	GL\_DEPTH24\_STENCIL8 to create a combined depth and stencil buffer.

4. Add your custom `CC3Layer` and `CC3Scene` source files (`MyCC3Layer.h`, `MyCC3Layer.m`, `MyCC3Scene.h`,
   and `MyCC3Scene.m`), and any 3D resources your app requires, to the `MySpriteBuilderApp` target of your 
   `MySpriteBuilderApp.xcodeproj` Xcode project.

5. You're now ready to add 3D content to your SpriteBuilder interface. As with any Cocos3D
   application, you provide 3D content by creating a custom subclass of `CC3Layer`. Open your
   `MySpriteBuilderApp.spritebuilder` project, and add your custom `CC3Layer` to your SpriteBuilder 
   layout as follows:
	1. Drag a *Node* from the SpriteBuilder component palette to your layout.
	2. Set the *Custom class* property of the new component to the name of your custom `MyCC3Layer` class.
	3. Set the *Content size* property to the size at which you want your want your 3D scene to be displayed.
	4. When first placed, the `MyCC3Layer` component will be added as a child of the root node of the 
	   SpriteBuilder scene. If you want the `MyCC3Layer` node to move as part of another node, you can use 
	   the SpriteBuilder timeline hierarchy to reposition the node to be a child of a different parent.
	5. *Save* and *Publish* your new SpriteBuilder layout.
	6. Build and run your app from Xcode to see your new 3D content.
	7. Repeat for all 3D sprites that you want to add to your SpriteBuilder scene.


Cocos2D Version Compatibility
-----------------------------

Cocos3D under iOS and Android is compatible with `Cocos2D` `3.0` and `Cocos2D` `2.1`, for 
using programmable-pipeline OpenGL ES 2.0, and is compatible with `Cocos2D` `1.1`, for 
using fixed-pipeline OpenGL ES 1.1.

Cocos3D under OSX is compatible with `Cocos2D` `3.0` and `Cocos2D` `2.1`, for using
programmable-pipeline OpenGL. Cocos3D is not compatible with `Cocos2D` `1.1` under OSX.

At the time of this release, the current version of Cocos2D is `3.0`, and by default, the 
demo apps and static libraries within the Cocos3D distribution are pre-configured to use 
that version. To build and run the demo apps or static libraries with a different version 
of Cocos2D, follow the steps described here:

1. Delete the reference to the *cocos2d* and *cocos2d-chipmunk* groups in the Xcode *Project Navigator*
   panel. These groups can be found in the `cocos2d-library-iOS` or `cocos2d-library-OSX` project.
2. Run the `install-cocos3d.sh` script again and identify the new version of `Cocos2D` to be linked.
   Keep in mind that you must link `Cocos2D` `3.0` or `Cocos2D 2.1` if you want to use 
   OpenGL ES 2.0 (iOS) or OpenGL (OSX) with a programmable rendering pipeline, and you must link
   `Cocos2D 1.1` if you want to use OpenGL ES 1.1 (iOS & Android) with a fixed rendering pipeline.
3. Add the newly linked Cocos2D files to the project by dragging the `cocos2d` folder from the 
   Cocos3D distribution folder into the `cocos2d-library-iOS` or `cocos2d-library-OSX` 
   project in the Xcode *Project Navigator* panel. When prompted for the target to add the source
   code to, select the `cocos2d` target.
4. Add the newly linked Cocos2D Chipmunk files to the project by dragging the `cocos2d-chipmunk`
   folder from the Cocos3D distribution folder into the `cocos2d-library-iOS` or `cocos2d-library-OSX` 
   project in the Xcode *Project Navigator* panel. When prompted for the target to add the source
   code to, select the `cocos2d-chipmunk` target.
6. `Cocos2D` `3.0` uses Automatic Reference Counting (ARC). `Cocos2D` `2.1` and `Cocos2D` `1.1`
   do not. You must set the appropriate compiler build setting to ensure the compiler will use
   the correct technique.
	1. In the `cocos2d-library-iOS` or `cocos2d-library-OSX` project, select the `cocos2d` 
	   target in your project settings.
	2. Select the *Build Settings* tab.
	3. Locate the **Objective-C Automatic Reference Counting** (aka `CLANG_ENABLE_OBJC_ARC`)
	   setting for the `cocos2d` target. If you are now linking to `Cocos2D` `3.0`, set this
	   property to `YES`. If you are now linking to `Cocos2D` `2.1` or `Cocos2D` `1.1`, set 
	   this property to NO. Make sure you change only the setting for the `cocos2d` target 
	   within your project. Do not change the setting for the `cocos2d-library-iOS` or 
	   `cocos2d-library-OSX` project itself.
	4. The `cocos2d-chipmunk` part of the `Cocos2D` `3.0` library does *not* use ARC. Ensure
	   the **Objective-C Automatic Reference Counting** (aka `CLANG_ENABLE_OBJC_ARC`) setting
	   of the `cocos2d-chipmunk` target is always set to NO.
7. `Cocos2D` `3.0` supports compiling to the ARM64 architecture. `Cocos2D` `2.1` and
   `Cocos2D` `1.1` do *not* support compiling to the ARM64 architecture. Because of this,
   by default, the **Valid Architectures** (aka `VALID_ARCHS`) build setting for all demo 
   Xcode Projects in the Cocos3D distribution is set to `$(ARCHS_STANDARD_32_BIT)` (which 
   resolves to **armv7 armv7s**), so that the demo projects will compile with all versions
   of `Cocos2D`. If you are now linking to `Cocos2D` `3.0`, you can set this property to
   `$(ARCHS_STANDARD)` (or simply remove this setting from the Project), in all demo Projects,
   to allow compilation to include the ARM64 architecture.
8. As a development optimization, if you are now linking to `Cocos2D` `3.0`, you can set the 
   value of the **Build Active Architecture Only** (aka `ONLY_ACTIVE_ARCH`) build setting in 
   the *Debug* configuration in all demo projects to `YES`. You should not do this if you are
   linking to `Cocos2D` `2.1` or `Cocos2D` `1.1`, as this will prohibit you from building
   the demo apps on devices that use the ARM64 processor.
9. If you have already built the demo app using the old version of `Cocos2D`, delete the 
   contents of your `~/Library/Developer/Xcode/DerivedData` folder, and restart Xcode.


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

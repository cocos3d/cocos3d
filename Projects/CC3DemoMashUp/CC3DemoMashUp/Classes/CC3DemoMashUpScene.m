/*
 * CC3DemoMashUpScene.m
 *
 * Cocos3D 2.0.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * http://en.wikipedia.org/wiki/MIT_License
 *
 * The Cocos3D mascot model was created by Alexandru Barbulescu, and used here
 * by permission. Further rights may be claimed for that model.
 * 
 * See header file CC3DemoMashUpScene.h for full API documentation.
 */

#import "CC3DemoMashUpScene.h"
#import "CC3OSExtensions.h"
#import "CC3Billboard.h"
#import "CC3Actions.h"
#import "CC3ModelSampleFactory.h"
#import "CCLabelTTF.h"
#import "CGPointExtension.h"
#import "CC3PODNode.h"
#import "CC3PODResourceNode.h"
#import "CC3BoundingVolumes.h"
#import "CC3PointParticleSamples.h"
#import "CC3MeshParticleSamples.h"
#import "CC3MeshParticles.h"
#import "CC3DemoMashUpLayer.h"
#import "CC3VertexSkinning.h"
#import "CC3ShadowVolumes.h"
#import <objc/runtime.h>
#import "CC3LinearMatrix.h"
#import "CC3AffineMatrix.h"
#import "CC3ProjectionMatrix.h"
#import "CC3PFXResource.h"
#import "CC3BitmapLabelNode.h"
#import "CC3EnvironmentNodes.h"
#import "CCTextureCache.h"


// File names
#define kRobotPODFile					@"IntroducingPOD_float.pod"
#define kBeachBallPODFile				@"BeachBall.pod"
#define kGlobeTextureFile				@"earthmap1k.jpg"
#define kMascotPODFile					@"cocos3dMascot.pod"
#define kDieCubePODFile					@"DieCube.pod"
#define kGroundTextureFile				@"Grass.jpg"
#define kSignTextureFile				@"Crate.png"
#define kSignStampTextureFile			@"Stamp.png"
#define kSignStampNormalsTextureFile	@"Stamp-nm.png"
#define kHeadPODFile					@"Head.pod"
#define kHeadTextureFile				@"Head_diffuse.png"
#define kHeadBumpFile					@"Head_clonespace.png"
#define kCubeTextureFile				@"BoxTexture.png"
#define kBrickTextureFile				@"Bricks-Red.jpg"
#define kRunningManPODFile				@"man.pod"
#define kMalletPODFile					@"mallet.pod"
#define kPointParticleTextureFile		@"fire.ppng"
#define kMeshParticleTextureFile		@"BallBoxTexture.png"
#define kReflectiveMaskPODFile			@"ReflectiveMask.pod"
#define kEtchedMaskPODFile				@"EtchedMask.pod"
#define kReflectivePFXFile				@"ReflectiveEffects.pfx"
#define kEtchedPFXFile					@"EtchedEffects.pfx"
#define kEtchedMaskPFXEffect			@"EtchedEffect"
#define kTVPODFile						@"samsung_tv-med.pod"
#define kTVTestCardFile					@"TVTestCard.jpg"
#define kPostProcPFXFile				@"PostProc.pfx"

// Model names
#define kLandingCraftName				@"LandingCraft"
#define kPODRobotRezNodeName			@"RobotPODRez"
#define kPODLightName					@"FDirect01"
#define kPODCameraName					@"Camera01"
#define kRobotTopArm					@"TopArm"
#define kRobotBottomArm					@"BottomArm"
#define kRobotCylinder					@"Cylinder01"
#define kRobotBase						@"GeoSphere01"
#define kRobotCameraName				@"Camera01"
#define kBeachBallRezNodeName			@"BeachBallPODRez"
#define kBeachBallName					@"BeachBall"
#define kBeachBallWhiteSegment			@"BeachBall-submesh0"
#define kGlobeName						@"Globe"
#define kDieCubeName					@"DieCube"
#define kDieCubePODName					@"Cube"
#define kTexturedTeapotName				@"Teapot"
#define kRainbowTeapotName				@"RainbowTeapot"
#define kTeapotHolderName				@"TeapotHolder"
#define kTeapotRedName					@"TeapotRed"
#define kTeapotGreenName				@"TeapotGreen"
#define kTeapotBlueName					@"TeapotBlue"
#define kTeapotWhiteName				@"TeapotWhite"
#define kTeapotOrangeName				@"TeapotOrange"
#define	kBillboardName					@"DizzyLabel"
#define kBitmapLabelName				@"BitmapLabel"
#define	kSunName						@"Sun"
#define kSpotlightName					@"Spotlight"
#define kBeachName						@"Beach"
#define kGroundName						@"Ground"
#define kFloaterName					@"Floater"
#define kMascotName						@"cocos2d_3dmodel_unsubdivided"
#define kDistractedMascotName			@"DistractedMascot"
#define kSignName						@"MultiTextureSign"
#define kSignLabelName					@"SignLabel"
#define kPODHeadRezNodeName				@"HeadPODRez"
#define kFloatingHeadName				@"head03low01"
#define kBumpMapLightTrackerName		@"BumpMapLightTracker"
#define kExplosionName					@"Explosion"
#define kPointHoseEmitterName			@"PointHose"
#define kMeshHoseEmitterName			@"MeshHose"
#define kTexturedCubeName				@"TexturedCube"
#define kBrickWallName					@"BrickWall"
#define kMalletName						@"Ellipse01"
#define kRunningTrackName				@"RunningTrack"
#define kRunnerName						@"Runner"
#define kRunnerCameraName				@"Camera01"
#define kRunnerLampName					@"Spot01"
#define kLittleBrotherName				@"LittleBrother"
#define kTVName							@"Television"
#define kTVScreenName					@"TVScreen"

#define	kMultiTextureCombinerLabel		@"Multi-texture combiner function: %@"

#define kCameraMoveDuration				3.0
#define kTeapotRotationActionTag		1
#define kSkyColor						ccc4f(0.4, 0.5, 0.9, 1.0)
#define kFadeInDuration					1.0f
#define kNoFadeIn						0.0f

#define kFlappingActionTag				77
#define kGlidingActionTag				78


// Size of the television
#define kTVScale 40
static CC3IntSize kTVTexSize = { (16 * kTVScale), (9 * kTVScale) };

// Locations for the brick wall in open and closed position
static CC3Vector kBrickWallOpenLocation = { -190, 150, -840 };
static CC3Vector kBrickWallClosedLocation = { -115, 150, -765 };


@interface CCAction (PrivateMethods)
// This method doesn't actually exist on CCAction, but it does on all subclasses we use in this project.
-(CCAction*) reverse;
@end

@interface CC3Node (TemplateMethods)
@property(nonatomic, readonly) CCColorRef initialDescriptorColor;
@end

@implementation CC3DemoMashUpScene

@synthesize primaryCC3DemoMashUpLayer=_primaryCC3DemoMashUpLayer;
@synthesize playerDirectionControl=_playerDirectionControl;
@synthesize playerLocationControl=_playerLocationControl;
@synthesize isManagingShadows=_isManagingShadows;

/**
 * Add the initial content to the scene.
 *
 * Once the scene is displayed and running, additional content is added asynchronously in
 * the addSceneContentAsynchronously method, which is invoked on a background thread by the
 * CC3Backgrounder singleton.
 */
-(void) initializeScene {
	
	[self initCustomState];			// Set up any initial state tracked by this subclass
	
	[self preloadAssets];			// Loads, compiles, links, and pre-warms all shader programs
									// used by this scene, and certain textures.
	
	[self addBackdrop];				// Add a static solid sky-blue backdrop, or optional textured backdrop.

	[self addGround];				// Add a ground plane to provide some perspective to the user
	
//	[self addSkyBox];				// Add a skybox around the scene. This is the skybox that is reflected
									// in the reflective runner added in the addSkinnedRunners method

	[self addRobot];				// Add an animated robot arm, a light, and a camera. This POD file
									// contains the primary camera of this scene.
	
	[self addProjectedLabel];		// Attach a text label to the hand of the animated robot.
	
//	[self addPointParticles];		// Uncomment to add a platform of multi-colored, light-interactive,
									// point particles hanging in the scene.
	
//	[self addMeshParticles];		// Uncomment to add a platform of multi-colored, mesh particles
									// hanging in the scene.
	
	[self addPointHose];			// Attach a point particle hose to the hand of the animated robot.
									// The hose is turned on and off when the robot arm is touched.
	
	[self addMeshHose];				// Attach a point particle hose to the hand of the animated robot.
									// The hose is turned on and off when the robot arm is touched.
	
	[self addSun];					// Add a Cocos2D particle emitter as the sun in the sky.
	
	[self addSpotlight];			// Add a spotlight to the camera.
									// This spotlight will be turned on when the sun is turned off.
	
	[self addLightProbes];			// Adds light probes to the scene, as an alternate to using lights.
									// Using the light probes can be turned on and off.
	
	[self configureLighting];		// Set up the lighting
	[self configureCamera];			// Check out some interesting camera options.
	
	// Configure all content added so far in a standard manner. This illustrates how CC3Node
	// properties and methods can be applied to large assemblies of nodes, and even the entire
	// scene itself, allowing us to perform this only once, for all current scene content.
	// For content that is added dynamically after this initial content, this method will also
	// be invoked on each new content component.
	[self configureForScene: self andMaterializeWithDuration: kNoFadeIn];
	
	// The existing node structure of the scene is logged using the following line.
	LogInfo(@"The structure of this scene is: %@", [self structureDescription]);
}

/**
 * Adds additional scene content dynamically and asynchronously.
 *
 * This method is invoked from a code block that is run on a background thread by the 
 * CC3Backgrounder singleton. It adds content dynamically and asynchronously after
 * rendering has begun on the rendering thread.
 *
 * To emphasize that the loading is happening on a background thread while the existing scene
 * is running, this method takes a small pause before loading each model. This pause is purely
 * for dramatic effect for the purposes of this demo app. Pauses are NOT required before normal
 * background model loading.
 *
 * Certain assets, notably shader programs, will cause short, but unavoidable, delays in the
 * rendering of the scene, because certain finalization steps from shader compilation occur on
 * the main thread. Shaders and certain other critical assets are pre-loaded in the preloadAssets
 * method, which is invoked prior to the opening of this scene.
 */
-(void) addSceneContentAsynchronously {

	[self pauseDramatically];
	[self addAxisMarkers];			// Add colored teapots to mark each coordinate axis

	[self pauseDramatically];
	[self addLightMarker];			// Add a small white teapot to show the direction toward the light

	[self pauseDramatically];
	[self addBitmapLabel];			// Add a bitmapped string label

	[self pauseDramatically];
	[self addSkinnedMallet];		// Adds a flexible mallet to the scene, showing bone skinning.

	[self pauseDramatically];
	[self addSkinnedRunners];		// Adds two running figures to the scene, showing bone skinning.

	[self pauseDramatically];
	[self addDieCube];				// Add a game die whose rotation is controlled by touch-swipe user action

	[self pauseDramatically];
	[self addTexturedCube];			// Add another cube, this one textured, below the die cube.

	[self pauseDramatically];
	[self addGlobe];				// Add a rotating globe from a parametric sphere covered by a texture

	[self pauseDramatically];
	[self addFloatingRing];			// Add a large yellow band floating above the ground, using a texture
									// containing transparency. The band as a whole fades in and out
									// periodically. This demonstrates managing opacity and translucency
									// at both the texture and material level.

	[self pauseDramatically];
	[self addBeachBall];			// Add a transparent bouncing beach ball...exported from Blender

	[self pauseDramatically];
	[self addTelevision];			// Add a television showing the view from the runner camera
									// This demonstrates dynamic rendering-to-texture capabilities.
									// Must be added after the skinned runners.

	[self pauseDramatically];
	[self addTeapotAndSatellite];	// Add a large textured teapot with a smaller satellite teapot

	[self pauseDramatically];
	[self addBrickWall];			// Add a brick wall that can block the path of the satellite teapot
									// This must happen after camera is loaded (in addRobot).

	[self pauseDramatically];
	[self addWoodenSign];			// Add the multi-texture wooden sign.
									// This must happen after camera is loaded (in addRobot).

	[self pauseDramatically];
	[self addFloatingHead];			// Add the bump-mapped floating head.
									// This must happen after camera is loaded (in addRobot).

	[self pauseDramatically];
	[self addReflectiveMask];		// Adds a floating mask that uses GLSL shaders loaded via a PowerVR
									// PFX file. Under OpenGL ES 1.1, mask appears with a default texture.

	[self pauseDramatically];
	[self addEtchedMask];			// Adds a floating mask that uses GLSL shaders loaded via a PowerVR
									// PFX file. Under OpenGL ES 1.1, mask appears with a default texture.

	[self pauseDramatically];
	[self addMascots];				// Add the Cocos3D mascot.

	[self pauseDramatically];
	[self addDragon];				// Add a flying dragon that demos blending between animation tracks

	// Log a list of the shader programs that are being used by the scene. During development,
	// we can use this list as a starting point for populating the preloadAssets method.
	LogRez(@"The following list contains the shader programs currently in use in this scene."
		   @" You can copy and paste much of this list into the preloadAssets method"
		   @" in order to pre-load the shader programs during scene initialization. %@",
		   [CC3ShaderProgram loadedProgramsDescription]);

	// Log a list of the PFX resources that are being used by the scene. During development, we can
	// use this list as a starting point for adding PFX files to the preloadAssets method.
	// When initially building this list, set the CC3Resource.isPreloading to YES and leave it there.
	LogRez(@"The following list contains the resource files currently in use in this scene."
		   @" You can copy the PFX resources from this list and paste them into the"
		   @" preloadAssets method, in order to pre-load additional shader programs"
		   @" that originate in PFX files, during scene initialization. %@",
		   [CC3PFXResource cachedResourcesDescription]);

	// Remove the pre-loaded PFX resources, now that we no longer need them.
	// Other weakly-cached PFX resources will have been automatically removed already.
	[CC3PFXResource removeAllResources];

	LogRez(@"Finished loading on background thread!");
}


/** 
 * When loading in the background, periodically pause the loading to phase the scene in over time.
 * We put an explicit test here, because if the CC3Backgrounder shouldRunTasksOnRequestingThread
 * property is set to YES, the addSceneContentAsynchronously method will be run in the foreground, 
 * and we don't want to add any unncessary delays in that case.
 */
-(void) pauseDramatically {
	if (!CC3OpenGL.sharedGL.isRenderingContext) {
		NSTimeInterval pauseDuration = 0.25f;
		LogRez(@"Pausing for %i milliseconds before loading next resource", (int)(pauseDuration * 1000));
		[NSThread sleepForTimeInterval: pauseDuration];
	}
}

/**
 * Invoked by the customized initializeScene to set up any initial state for
 * this customized scene. This is broken into a separate method so that the
 * initializeScene method can focus on loading the artifacts of the 3D scene.
 */
-(void) initCustomState {
	_isManagingShadows = NO;
	_playerDirectionControl = CGPointZero;
	_playerLocationControl = CGPointZero;
	
	// The order in which meshes are drawn to the GL engine can be tailored to your needs.
	// The default is to draw opaque objects first, then alpha-blended objects in reverse Z-order.
	// ([CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirst]).
	//
	// To experiment with an alternate drawing order, set a different node sequence sorter
	// by uncommenting one of the lines here and commenting out the others. The last option
	// does not use a drawing sequencer, and draws the objects hierarchically instead.
	// With this, notice that the transparent beach ball now appears opaque, because it
	// was added first, and is traversed ahead of other objects in the hierarchical assembly,
	// resulting it in being drawn first, and so it cannot blend with the background objects.
	//
	// You can of course write your own node sequencers to customize to your specific
	// app needs. Best to change the node sequencer before any model objects are added.
//	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirstGroupMeshes];
//	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirstGroupTextures];
//	self.drawingSequencer = nil;
}

/**
 * Pre-loads certain assets, such as shader programs, and certain textures, prior to the
 * scene being displayed.
 *
 * Much of the scene is loaded on a background thread, while the scene is visible. However,
 * the handling of some assets on the background thread can interrupt the main rendering thread.
 *
 * The GL drivers often leave the final stages of shader compilation and configuration until
 * the first time the shader program is used to render an object. This can often introduce a
 * short, unwanted pause if the shader program is loaded while the scene is running.
 *
 * Unfortunately, although resources such as models, textures, and shader programs can be loaded
 * on a background thread, the final stages of shader programs compilation must be performed on
 * the primary rendering thread. Because of this, the only way to avoid an unwanted pause while
 * a shader program compilation is finalized is to therefore perform all shader program loading
 * prior to the scene being displayed, including shader programs that may not be required until
 * additional content is loaded later in the scene on a background thread.
 *
 * In order to ensure that the shader programs will be available when the models are loaded
 * at a later point in the scene (usually via background loading), the cache must be configured
 * to retain the loaded shader programs even though they will not immediately be used to display
 * any models. This is done by turning on the value of the class-side isPreloading property.
 *
 * In addition, the automatic creation of mipmaps on larger textures, particularly cube-map 
 * textures (which require a set of six mipmaps), can cause excessive work for the GPU in
 * the background, which can spill over into a delay on the primary rendering thread.
 *
 * As a result, a large cube-map texture is loaded here and cached, for later access once
 * the model that uses it is loaded in the background.
 */
-(void) preloadAssets {
#if CC3_GLSL

	// Strongly cache the shader programs loaded here, so they'll be availble
	// when models are loaded on the background loading thread.
	CC3ShaderProgram.isPreloading = YES;

	[CC3ShaderProgram programFromVertexShaderFile: @"CC3ClipSpaceTexturable.vsh"
							andFragmentShaderFile: @"CC3ClipSpaceNoTexture.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3ClipSpaceTexturable.vsh"
							andFragmentShaderFile: @"CC3Fog.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3PointSprites.vsh"
							andFragmentShaderFile: @"CC3PointSprites.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh"
							andFragmentShaderFile: @"CC3BumpMapObjectSpace.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh"
							andFragmentShaderFile: @"CC3BumpMapTangentSpace.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh"
							andFragmentShaderFile: @"CC3NoTexture.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh"
							andFragmentShaderFile: @"CC3SingleTexture.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh"
							andFragmentShaderFile: @"CC3SingleTextureAlphaTest.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3Texturable.vsh"
							andFragmentShaderFile: @"CC3SingleTextureReflect.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3TexturableBones.vsh"
							andFragmentShaderFile: @"CC3SingleTexture.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3TexturableBones.vsh"
							andFragmentShaderFile: @"CC3SingleTextureReflect.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3TexturableRigidBones.vsh"
							andFragmentShaderFile: @"CC3BumpMapTangentSpace.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3TexturableRigidBones.vsh"
							andFragmentShaderFile: @"CC3NoTexture.fsh"];
	[CC3ShaderProgram programFromVertexShaderFile: @"CC3TexturableRigidBones.vsh"
							andFragmentShaderFile: @"CC3SingleTexture.fsh"];

	// Now pre-load shader programs that originate in PFX resources.
	// Leave the shader program preloading on too...since effects will also load shaders.
	CC3Resource.isPreloading = YES;

	[CC3PFXResource resourceFromFile: kPostProcPFXFile];
	[CC3PFXResource resourceFromFile: kReflectivePFXFile];
	
	// All done with shader pre-loading...let me know in the logs if any further shader programs
	// are loaded during the scene operation.
	CC3Resource.isPreloading = NO;
	CC3ShaderProgram.isPreloading = NO;

#endif	// CC3_GLSL
	
	// The automatic generation of mipmap in the environment map texture on the background
	// thread causes a short delay in rendering on the main thread. The text glyph texture
	// also requires substantial time for mipmap generation. For such textures, by loading
	// the texture, creating the mipmap, and caching the texture here, we can avoid the delay.
	// All other textures are loaded on the background thread.
	CC3Texture.isPreloading = YES;
	[CC3Texture textureFromFile: @"Arial32BMGlyph.png"];
#if !CC3_OGLES_1
	[CC3Texture textureCubeFromFilePattern: @"EnvMap%@.jpg"];
#endif	// !CC3_OGLES_1
	CC3Texture.isPreloading = NO;
}

/** Various options for configuring interesting camera behaviours. */
-(void) configureCamera {
	CC3Camera* cam = self.activeCamera;

	// Camera starts out embedded in the scene.
	_cameraZoomType = kCameraZoomNone;
	
	// The camera comes from the POD file and is actually animated.
	// Stop the camera from being animated so the user can control it via the user interface.
	[cam disableAnimation];
	
	// Keep track of which object the camera is pointing at
	_origCamTarget = cam.target;
	_camTarget = _origCamTarget;
	
	// Set the field of view orientation to diagonal, to give a good overall average view of
	// the scene, regardless of the shape of the viewing screen. As loaded from the POD file,
	// the FOV is measured horizontally.
	cam.fieldOfViewOrientation = CC3FieldOfViewOrientationDiagonal;

	// For cameras, the scale property determines camera zooming, and the effective field of view.
	// You can adjust this value to play with camera zooming. Conversely, if you find that objects
	// in the periphery of your view appear elongated, you can adjust the fieldOfView and/or
	// uniformScale properties to reduce this "fish-eye" effect. See the notes of the CC3Camera
	// fieldOfView property for more on this.
	cam.uniformScale = 0.5;
	
	// You can configure the camera to use orthographic projection instead of the default
	// perspective projection by setting the isUsingParallelProjection property to YES.
	// You will also need to adjust the scale to match the different projection.
//	cam.isUsingParallelProjection = YES;
//	cam.uniformScale = 0.015;
	
	// To see the effect of mounting a camera on a moving object, uncomment the following
	// lines to mount the camera on a virtual boom attached to the beach ball.
	// Since the beach ball rotates as it bounces, you might also want to comment out the
	// CC3ActionRotateForever action that is run on the beach ball in the addBeachBall method!
//	[_beachBall addChild: cam];				// Mount the camera on the beach ball
//	cam.location = cc3v(2.0, 1.0, 0.0);		// Relative to the parent beach ball
//	cam.rotation = cc3v(0.0, 90.0, 0.0);	// Point camera out over the beach ball

	// To see the effect of mounting a camera on a moving object AND having the camera track a
	// location or object, even as the moving object bounces and rotates, uncomment the following
	// lines to mount the camera on a virtual boom attached to the beach ball, but stay pointed at
	// the moving rainbow teapot, even as the beach ball that the camera is mounted on bounces and
	// rotates. In this case, you do not need to comment out the CC3ActionRotateForever action that
	// is run on the beach ball in the addBeachBall method
//	[_beachBall addChild: cam];				// Mount the camera on the beach ball
//	cam.location = cc3v(2.0, 1.0, 0.0);		// Relative to the parent beach ball
//	cam.target = teapotSatellite;			// Look toward the rainbow teapot...
//	cam.shouldTrackTarget = YES;			// ...and track it as it moves
}

/** Configure the lighting. */
-(void) configureLighting {
	
	// Start out with a sunny day
	_lightingType = kLightingSun;

	// Set the ambient scene lighting.
	self.ambientLight = ccc4f(0.3, 0.3, 0.3, 1.0);

	// Adjust the relative ambient and diffuse lighting of the main light to
	// improve realisim, particularly on shadow effects.
	_robotLamp.diffuseColor = ccc4f(0.8, 0.8, 0.8, 1.0);
	
	// Another mechansim for adjusting shadow intensities is shadowIntensityFactor.
	// For better effect, set here to a value less than one to lighten the shadows
	// cast by the main light.
	_robotLamp.shadowIntensityFactor = 0.75f;
	
	// The light from the robot POD file is animated to move back and forth, changing
	// the lighting of the scene as it moves. To turn this animation off, comment out
	// the following line. This can be useful when reviewing shadowing.
//	[_robotLamp disableAnimation];

}

/**
 * Configures the specified node and all its descendants for use in the scene, and then fades
 * them in over the specified duration, in seconds. Specifying zero for the duration will 
 * instantly materialize the node without employing any fading.
 *
 * This scene is highly complex, and it helps to configure the nodes within it in a standardized
 * manner, including whether we use VBO's to manage the vertices, whether the vertices need to
 * also be retained in main memory, whether bounding volumes are required, and to force early
 * selection of shaders for use with the nodes.
 *
 * The specified node can be the root of an arbitrarily complex node tree, and the behaviour
 * applied in this method is propagated to all descendant nodes of the specified node, and the
 * materialization fading will be applied to the entire node tree. The specified node can even
 * be the entire scene itself.
 */
-(void) configureForScene: (CC3Node*) aNode andMaterializeWithDuration: (CCTime) duration {
	
	// This scene is quite complex, containing many objects. As the user moves the camera
	// around the scene, objects move in and out of the camera's field of view. At any time,
	// there may be a number of objects that are out of view of the camera. With such a scene
	// layout, we can save significant GPU processing by not drawing those objects. To make
	// that happen, we assign a bounding volume to each mesh node. Once that is done, only
	// those objects whose bounding volumes intersect the camera frustum will be drawn.
	// Bounding volumes can also be used for collision detection between nodes. You can see
	// the effect of not using bounding volumes on drawing perfomance by commenting out the
	// following line and taking note of the drop in performance for this scene. However,
	// testing bounding volumes against the camera's frustum does take some CPU processing,
	// and in scenes where all or most of the objects are in front of the camera at all times,
	// using bounding volumes may actually result in slightly lower performance. By including
	// or not including the line below, you can test both scenarios and decide which approach
	// is best for your particular scene. Bounding volumes are not automatically created for
	// skinned meshes, such as the runners and mallet. See the addSkinnedRunners and
	// addSkinnedMallet methods to see how those bounding volumes are added manually.
	[aNode createBoundingVolumes];
	
	// Create OpenGL buffers for the vertex arrays to keep things fast and efficient, and
	// to save memory, release the vertex data in main memory because it is now redundant.
	// However, because we can add shadow volumes dynamically to any node, we need to keep the
	// vertex location, index and skinning data of all meshes around to build shadow volumes.
	// If we had added the shadow volumes before here, we wouldn't have to retain this data.
	[aNode retainVertexLocations];
	[aNode retainVertexIndices];
	[aNode retainVertexBoneWeights];
	[aNode retainVertexBoneIndices];
	[aNode createGLBuffers];
	[aNode releaseRedundantContent];
	
	// The following line displays the bounding volumes of each node. The bounding volume of
	// all mesh nodes, except the globe, contains both a spherical and bounding-box bounding
	// volume, to optimize testing. For something extra cool, touch the robot arm to see the
	// bounding volume of the particle emitter grow and shrink dynamically. Use the joystick
	// controls or gestures to back the camera away to get the full effect. You can also turn
	// on this property on individual nodes or node structures. See the notes for this property
	// and the shouldDrawBoundingVolume property in the CC3Node class notes.
//	aNode.shouldDrawAllBoundingVolumes = YES;
	
	// Select the appropriate shaders for each mesh node descendent now. If this step is omitted,
	// shaders will be selected for each mesh node the first time that mesh node is drawn.
	// Doing it now adds some additional time up front, but avoids potential pauses as the
	// shaders are loaded, compiled, and linked, the first time it is needed during drawing.
	// Shader selection is driven by the characteristics of each mesh node and its material,
	// including the number of textures, whether alpha testing is used, etc. To have the
	// correct shaders selected, it is important that you finish configuring the mesh nodes
	// prior to invoking this method. If you change any of these characteristics that affect
	// the shader selection, you can invoke the removeShaders method to cause different shaders
	// to be selected, based on the new mesh node and material characteristics.
	[aNode selectShaders];
	
	// For an interesting effect, to draw text descriptors and/or bounding boxes on every node
	// during debugging, uncomment one or more of the following lines. The first line displays
	// short descriptive text for each node (including class, node name & tag). The second line
	// displays bounding boxes of only those nodes with local content (eg- meshes). The third
	// line shows the bounding boxes of all nodes, including those with local content AND
	// structural nodes. You can also turn on any of these properties at a more granular level
	// by using these and similar methods on individual nodes or node structures. See the CC3Node
	// class notes. This family of properties can be particularly useful during development to
	// track down display issues.
//	aNode.shouldDrawAllDescriptors = YES;
//	aNode.shouldDrawAllLocalContentWireframeBoxes = YES;
//	aNode.shouldDrawAllWireframeBoxes = YES;
	
	// Use a standard CCActionFadeIn to fade the node in over the specified duration
	if (duration > 0.0f) {
		aNode.opacity = 0;	// Needed for Cocos2D 1.x, which doesn't start fade-in from zero opacity
		[aNode runAction: [CCActionFadeIn actionWithDuration: duration]];
	}
}

/** 
 * Creates a clear-blue-sky backdrop. Or install a textured backdrop by uncommenting the 
 * 2nd & 3rd lines of this method. See the notes for the backdrop property for more info.
 */
-(void) addBackdrop {
	self.backdrop = [CC3Backdrop nodeWithName: @"Backdrop" withColor: kSkyColor];
//	self.backdrop = [CC3Backdrop nodeWithName: @"Backdrop"
//								  withTexture: [CC3Texture textureFromFile: kBrickTextureFile]];
}

/**
 * Add a large circular grass-covered ground to give everything perspective.
 * The ground is tessellated into many smaller faces to improve realism of spotlight.
 */
-(void) addGround {
	_ground = [CC3PlaneNode nodeWithName: kGroundName];
	[_ground populateAsDiskWithRadius: 1500 andTessellation: CC3TessellationMake(8, 32)];

	// To demonstrate that a Cocos3D CC3Texture can be created from an existing Cocos2D CCTexture,
	// we first load a CCTexture, and create the CC3Texture from it. We then assign the CC3Texture
	// a unique name and add it to the texture cache it so it will be available for later use.
	CCTexture* tex2D = [CCTextureCache.sharedTextureCache  addImage: kGroundTextureFile];
	CC3Texture* tex3D = [CC3Texture textureWithCCTexture: tex2D];
	tex3D.name = kGroundTextureFile;
	[CC3Texture addTexture: tex3D];
	_ground.texture = tex3D;

	// To simply load a Cocos3D texture directly, without first loading a Cocos2D texture,
	// comment out the lines above, and uncomment the following line.
//	_ground.texture = [CC3Texture textureFromFile: kGroundTextureFile];

	// The ground uses a repeating texture
	[_ground repeatTexture: (ccTex2F){10, 10}];		// Grass
//	[_ground repeatTexture: (ccTex2F){3, 3}];		// MountainGrass
	
	_ground.location = cc3v(0.0, -100.0, 0.0);
	_ground.rotation = cc3v(-90.0, 180.0, 0.0);
	_ground.shouldCullBackFaces = NO;	// Show the ground from below as well.
	_ground.touchEnabled = YES;			// Allow the ground to be selected by touch events.
	[_ground retainVertexLocations];	// Retain location data in main memory, even when it
										// is buffered to a GL VBO via releaseRedundantContent,
										// so that it may be accessed for further calculations
										// when dropping objects on the ground.
	[self addChild: _ground];
}

/**
 * Adds a large rectangular orange ring floating above the ground. This ring is created from a plane
 * using a texture that combines transparency and opacity. It demonstrates the use of transparency in
 * textures. You can see through the transparent areas to the scene behind the texture. The texture
 * as a whole fades in and out periodically, and rotates around the vertical (Y) axis.
 *
 * The type of blending function used to blend the transparent/translucent areas of the texture
 * with the object behind is set automatically, and is influenced by the opacity of the object,
 * whether the texture contains an alpha channel, and whether the color channels of the texture
 * have been pre-multiplied by the alpha channel in the texture. Here we provide the option to
 * demonstrate textures with either pre-multiplied content or non-pre-multiplied content, and
 * the resulting blending function is logged to help you understand the difference.
 *
 * The non-premultiplied alpha texture is a PNG file with the special file-extension PPNG. 
 * This is a normal PNG file, but the renamed extension will stop Xcode from modifying the file
 * to pre-multiply the alpha during app building. The PPNG file is loaded with a custom image
 * loader, again, to avoid iOS pre-multiplying the texture content during image loading. 
 * This allows the texture to appear exactly as it was created. This is an important feature
 * when loading textures that contain custom content, such as normal-maps, light-maps, shininess,
 * weightings, etc. See the notes for the CC3STBImage useForFileExtensions property to learn 
 * more about these special file extensions.
 *
 * As the ring rotates, both sides are visible. This is because the shouldCullBackFaces property is
 * set to NO, so that both sides of each face are rendered. 
 *
 * A border is drawn around the bounding box of the mesh to highlight the extent of the
 * transparency in the texture.
 */
-(void) addFloatingRing {
	CC3MeshNode* floater = [CC3PlaneNode nodeWithName: kFloaterName];
	[floater populateAsCenteredRectangleWithSize: CGSizeMake(120.0, 120.0)];

	// The OrangeRing.ppng texture will be loaded without pre-multiplied alpha.
	// The OrangeRing.png texture will be loaded without pre-multiplied alpha.
	// Comment out one or other of the following lines to see the difference. The effect
	// on the material blending that is automatically assigned is output in the logs.
	floater.texture = [CC3Texture textureFromFile: @"OrangeRing.ppng"];
//	floater.texture = [CC3Texture textureFromFile: @"OrangeRing.png"];
	floater.isOpaque = NO;		// Not strictly needed, because will be set automatically
								// during fading action, but set here to allow the blending
								// function to be logged on the next line.
	LogInfo(@"%@ with %@ blending (%@/%@) and %@ %@ pre-multiplied alpha.",
			floater, floater.material,
			NSStringFromGLEnum(floater.material.sourceBlend),
			NSStringFromGLEnum(floater.material.destinationBlend),
			floater.texture, (floater.texture.hasPremultipliedAlpha ? @"with" : @"without"));

	// This is a simple plane node. To make this object visible from behind, we need
	// to show the back sides of the faces as well.
	floater.shouldCullBackFaces = NO;			// Show from behind as well.
	
	// This object has some unexpected behaviour when using fog using GLSL. Since fog is dependent
	// on the depth buffer, the fog intensity will be that of this object, even though the farther
	// objects can be see through the transparent parts of this ring. To help with this, we
	// can cause the transparent fragments to be discarded, which helps because the transparent
	// fragments will not be written to the depth buffer. This works well except for the fact
	// that we also fade the entire object in and out, which causes issues as the opqaue areas
	// of the ring approach full transparency under fading. In general, opaque areas that have
	// been faded almost away will not play well with GLSL fog.
	floater.shouldDrawLowAlpha = NO;
	floater.material.alphaTestReference = 0.05;
	
	floater.location = cc3v(400.0, 150.0, -250.0);
	floater.touchEnabled = YES;
	floater.shouldDrawLocalContentWireframeBox = YES;	// Draw an box around texture

	// Ring is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: floater andMaterializeWithDuration: kFadeInDuration];
	[self addChild: floater];

	// Fade the floating ring in and out
	CCActionInterval* fadeOut = [CCActionFadeOut actionWithDuration: 5.0];
	CCActionInterval* fadeIn = [CCActionFadeIn actionWithDuration: 5.0];
	[floater runAction: [[CCActionSequence actionOne: fadeOut two: fadeIn] repeatForever]];
	
	// Rotate the floating ring to see the effect on the orientation of the plane normals
	[floater runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0.0, 30.0, 0.0)]];
}

/** Utility method to copy a file from the resources directory to the Documents directory */
-(BOOL) copyResourceToDocuments: (NSString*) fileName {
	NSString* srcDir = [[NSBundle mainBundle] resourcePath];
	NSString* srcPath = [srcDir stringByAppendingPathComponent: fileName];
	NSString* dstDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* dstPath = [dstDir stringByAppendingPathComponent: fileName]; 
	
	NSError* err = nil;
	NSFileManager* fileMgr = [NSFileManager defaultManager];
	[fileMgr removeItemAtPath: dstPath error: &err];
	if ( [fileMgr copyItemAtPath: srcPath toPath: dstPath error: &err] ) {
		LogRez(@"Copied %@ to %@", srcPath, dstPath);
		return YES;
	} else {
		LogError(@"Could not copy %@ to %@ because (%li) in %@: %@",
					  srcPath, dstPath, (long)err.code, err.domain, err.userInfo);
		return NO;
	}
}

/**
 * Loads a POD file containing a semi-transparent beach ball
 * sporting multiple materials, exported from Blender.
 */
-(void) addBeachBall {
	
	// To show it is possible to load model files from other directories,
	// we copy the POD file to the application Document directory.
	[self copyResourceToDocuments: kBeachBallPODFile];
	NSString* docDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* podPath = [docDir stringByAppendingPathComponent: kBeachBallPODFile];
	
	// Load the POD file from the application Documents directory. It will also
	// load any needed textures from that directory as well.
	CC3ResourceNode* bbRez = [CC3PODResourceNode nodeWithName: kBeachBallRezNodeName fromFile: podPath];
	
	// Configure the bouncing beach ball
	_beachBall = [bbRez getNodeNamed: kBeachBallName];
	_beachBall.location = cc3v(200.0, 200.0, -400.0);
	_beachBall.uniformScale = 50.0;
	
	// Allow this beach ball node to be selected by touch events.
	// The beach ball is actually a structural assembly containing four child nodes,
	// one for each separately colored mesh. By marking the node assembly as touch-enabled,
	// and NOT marking each component mesh node as touch-enabled, when any of the component
	// nodes is touched, the entire beach ball structural node will be selected.
	_beachBall.touchEnabled = YES;
	
	// Bounce the beach ball...simply...we're not trying for realistic physics here,
	// but we can still do some fun and interesting stuff with Ease-actions.
	GLfloat hangTime = 3.0f;
	CC3Vector dropLocation = _beachBall.location;
	CC3Vector landingLocation = dropLocation;
	landingLocation.y = _ground.location.y + 30.0f;
	
	CCActionInterval* dropAction = [CC3ActionMoveTo actionWithDuration: hangTime moveTo: landingLocation];
	dropAction = [CCActionEaseOut actionWithAction: [CCActionEaseIn actionWithAction: dropAction rate: 4.0f] rate: 1.6f];
	
	CCActionInterval* riseAction = [CC3ActionMoveTo actionWithDuration: hangTime moveTo: dropLocation];
	riseAction = [CCActionEaseIn actionWithAction: [CCActionEaseOut actionWithAction: riseAction rate: 4.0f] rate: 1.6f];
	
	[_beachBall runAction: [[CCActionSequence actionOne: dropAction two: riseAction] repeatForever]];
	
	// For extra realism, also rotate the beach ball as it bounces.
	[_beachBall runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(30.0, 0.0, 45.0)]];
	
	// Beach ball is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: _beachBall andMaterializeWithDuration: kFadeInDuration];
	[self addChild: _beachBall];
}

/**
 * Adds a rotating globe that is created programatically from a prametric sphere,
 * and is covered with a rectangular texture containing a cylindrical projection
 * (typical of earth maps taken from space).
 */
-(void) addGlobe {
	
	// To show it is possible to load texture files from other directories,
	// we copy the texture file to the application Document directory.
	[self copyResourceToDocuments: kGlobeTextureFile];
	NSString* docDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* texPath = [docDir stringByAppendingPathComponent: kGlobeTextureFile];
	
	// Configure the rotating globe
	_globe = [CC3SphereNode nodeWithName: kGlobeName];		// weak reference
	[_globe populateAsSphereWithRadius: 1.0f andTessellation: CC3TessellationMake(32, 32)];
	_globe.texture = [CC3Texture textureFromFile: texPath];
	_globe.location = cc3v(150.0, 200.0, -150.0);
	_globe.uniformScale = 50.0;
	_globe.ambientColor = kCCC4FLightGray;		// Increase the ambient reflection
	_globe.touchEnabled = YES;				// allow this node to be selected by touch events
	
	// Rotate the globe
	[_globe runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0.0, 30.0, 0.0)]];
	
	// Cube is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: _globe andMaterializeWithDuration: kFadeInDuration];
	[self addChild: _globe];
	
	// For something interesting, uncomment the following lines to make the
	// globe invisible, but still touchable, and still able to cast a shadow.
//	_globe.visible = NO;
//	_globe.shouldAllowTouchableWhenInvisible = YES;
//	_globe.shouldCastShadowsWhenInvisible = YES;
}

/**
 * Adds a die cube that can be rotated by the user touching it and then swiping in any
 * direction. The die cube rotates in the direction of the swipe, at a speed proportional
 * to the speed and length of the swipe, and then steadily slows down over time.
 *
 * While the user is touching the cube and moving the finger, the die cube is rotated
 * under direct finger motion. Once the finger is lifted, the die cube spins in a
 * freewheel fashion, and slows down over time due to friction.
 *
 * This die cube does not use a CCAction to rotate. Instead, a custom SpinningNode class
 * replaces the node loaded from the POD file. This custom class spins by adjusting its
 * rotational state on each update pass. It contains a spinSpeed property to indicate how
 * fast it is currently spinning, and a friction property to adjust the spinSpeed on each
 * update.
 *
 * To handle the behaviour of the node while it is freewheeling, we create it as a
 * specialized subclass. Since this node is loaded from a POD file, one way to do this
 * is to load the POD class and then copy it to the subclass we want. That is done here.
 *
 * To rotate a node using changes in rotation using the rotateBy... family of methods,
 * as is done to this node, does NOT requre a specialized class. This specialized class
 * is required to handle the freewheeling and friction nature of the behaviour after the
 * rotation has begun.
 *
 * The die cube POD file was created from a Blender model available from the Blender
 * "Two dice" modeling tutorial available online at:
 * http://wiki.blender.org/index.php/Doc:Tutorials/Modeling/Two_dice
 */
-(void) addDieCube {

	// Fetch the die cube model from the POD file.
	CC3ResourceNode* podRezNode = [CC3PODResourceNode nodeFromFile: kDieCubePODFile];
	CC3Node* podDieCube = [podRezNode getNodeNamed: kDieCubePODName];
	
	// We want this node to be a SpinningNode class instead of the CC3PODNode class that
	// is loaded from the POD file. We can swap it out by creating a copy of the loaded
	// POD node, using a different node class as the base.
	_dieCube = [podDieCube copyWithName: kDieCubeName asClass: [SpinningNode class]];

	// Now set some properties, including the friction, and add the die cube to the scene
	_dieCube.uniformScale = 30.0;
	_dieCube.location = cc3v(-200.0, 200.0, 0.0);
	_dieCube.touchEnabled = YES;
	_dieCube.friction = 1.0;
	
	// Cube is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: _dieCube andMaterializeWithDuration: kFadeInDuration];
	[self addChild: _dieCube];
}

/**
 * Adds a parametric textured cube that rotates by swiping, similar to the die cube.
 *
 * This is a single box mesh (not constructed from six separate plane meshes), and is
 * wrapped by a single texture, that wraps around all six sides of the cube. The texture
 * must be constructed to do this. Have a look at the BoxTexture.png texture file to
 * understand how the texture is wrapped to the different sides.
 */
-(void) addTexturedCube {
	NSString* itemName;
	
	// Create a parametric textured cube, centered on the local origin.
	CC3BoxNode* texCube = [CC3BoxNode nodeWithName: kTexturedCubeName];
	[texCube populateAsSolidBox: CC3BoxMake(-1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f)];
	texCube.uniformScale = 30.0;

	// Add a texture to the textured cube. This creates a material automatically.
	// For kicks, we use a texture that contains two distinct images, one for a box and
	// one for a ball, and set a texture rectangle on the node so it will use only one
	// part of the texture to cover the box.
	texCube.texture = [CC3Texture textureFromFile: kMeshParticleTextureFile];
	texCube.textureRectangle = CGRectMake(0, 0, 1, 0.75);
//	texCube.texture = [CC3Texture textureFromFile: kCubeTextureFile];	// Alternately, use a full texture

	texCube.ambientColor = ccc4f(0.6, 0.6, 0.6, 1.0);		// Increase the ambient reflection
	
	// Add direction markers to demonstrate how the sides are oriented. In the local coordinate
	// system of the cube node, the red marker point in the direction of the positive-X axis,
	// the green marker in the direction of the positive-Y axis, and the blue marker in the
	// direction of the positive-Z axis. As these demonstrate, the front faces the positive-Z
	// direction, and the top faces the positive-Y direction.
	[texCube addAxesDirectionMarkers];
	
	// Wrap the cube in a spinner node to allow it to be rotated by touch swipes.
	// Give the spinner some friction so that it slows down over time one released.
	itemName = [NSString stringWithFormat: @"%@-Spinner", texCube.name];
	_texCubeSpinner = [SpinningNode nodeWithName: itemName];
	_texCubeSpinner.friction = 1.0;
	_texCubeSpinner.location = cc3v(-200.0, 75.0, 0.0);
	_texCubeSpinner.touchEnabled = YES;

	// Add the cube to the spinner and the spinner to the scene.
	[_texCubeSpinner addChild: texCube];
	
	// Cube is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: _texCubeSpinner andMaterializeWithDuration: kFadeInDuration];
	[self addChild: _texCubeSpinner];
}

/** 
 * Adds a large textured teapot and a small multicolored teapot orbiting it.
 * 
 * When running with GLSL shaders under OpenGL ES 2.0 on iOS, or OpenGL on OSX, the textured
 * teapot reflects the surrounding environment dynamically. This is performed by adding a
 * environmental cube-map texture to the teapot. A cube-map texture actually consists of six
 * textures, each representing a view of the scene from one of the six scene axes. The reflection
 * texture is updated each frame (see the generateTeapotEnvironmentMapWithVisitor method), so
 * the teapot reflects the dynamic scene. As objects move around the scene, they are reflected
 * in the teapot.
 *
 * The default program matcher assigns the GLSL shaders CC3Texturable.vsh and
 * CC3SingleTextureReflect.fsh shaders to the reflective teapot.
 *
 * The textured teapot actually has two textures. The first is the reflective cube-map, and the
 * second can provide an optional surface material effect (in this case brushed metal), that
 * blends with the reflection, to more realistically mimic a non-silvered reflective material.
 * The reflectivity property of the material covering the teapot adjusts the blend between the
 * reflective and material textures, and can be used to control how reflective the surface is.
 * For demonstative effect, the reflectivity property is set to the maximum value of 1.0, making
 * the material fully reflective (like a mirror or chrome), and none of the brushed metal texture
 * shows through. You can reduce the reflectivity value to dull the reflection and show more of
 * the brushed metal surface.
 */
-(void) addTeapotAndSatellite {
	_teapotTextured = [CC3ModelSampleFactory.factory makeTexturableTeapotNamed: kTexturedTeapotName];
	_teapotTextured.touchEnabled = YES;		// allow this node to be selected by touch events
	
#if !CC3_OGLES_1
	// If cube-maps are available, add two textures to the teapot. The first is a cube-map texture
	// showing the six sides of a real-time reflective environmental cube surrounding the teapot,
	// viewed from the teapot's perspective. The reflection is dynamically generated as objects
	// move around the scene. A second texture is added to provide an optional surface material
	// (eg- brushed metal). The material reflectivity property adjusts how reflective the surface
	// is, by adjusting the blend between the two textures. Lower the reflectivity towards zero to
	// show some of the underlying material. Since the environment map texture renders the scene,
	// it requires a depth buffer. This is created automatically during the initialization of the
	// environment texture. However, if we had multiple reflective objects, we could use the same
	// depth buffer for all of them if the textures are the same size, by using a different
	// creation method for the environment texture. Since generating an environment map texture
	// requires rendering the scene from each of the six axis directions, it can be quite costly.
	// You can use the numberOfFacesPerSnapshot property to adjust how often the reflective faces
	// are updated, to trade off real-time accuracy and performance.
	_envMapTex = [CC3EnvironmentMapTexture textureCubeWithSideLength: 256];
	_envMapTex.name = @"TeapotMirror";				// Give it a name to help with troubleshooting
	_envMapTex.numberOfFacesPerSnapshot = 1.0f;		// Update only one side of the cube in each frame
	
	[_teapotTextured addTexture: _envMapTex];
	_teapotTextured.reflectivity = 0.7;		// Modify this (0-1) to change how reflective the teapot is
	_teapotTextured.shouldUseLighting = NO;		// Ignore lighting to highlight reflections demo
#endif	// !CC3_OGLES_1

	// Add a brushed metal texture (with or without the reflective texture added above).
	[_teapotTextured addTexture: [CC3Texture textureFromFile: @"tex_base.png"]];
	
	// Add a second rainbow-colored teapot as a satellite of the reflective teapot.
	_teapotSatellite = [PhysicsMeshNode nodeWithName: kRainbowTeapotName];
	_teapotSatellite.mesh = CC3ModelSampleFactory.factory.multicoloredTeapotMesh;
	_teapotSatellite.material = [CC3Material shiny];
	_teapotSatellite.location = cc3v(0.3, 0.1, 0.0);
	_teapotSatellite.uniformScale = 0.4;
	_teapotSatellite.touchEnabled = YES;		// allow this node to be selected by touch events
	[_teapotTextured addChild: _teapotSatellite];
	
	_teapotTextured.location = cc3v(0.0, 150.0, -650.0);
	_teapotTextured.uniformScale = 500.0;
	
	// Teapots are added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: _teapotTextured andMaterializeWithDuration: kFadeInDuration];
	[self addChild: _teapotTextured];
	
	// Rotate the teapots. The satellite orbits the reflective teapot because it is a child node of the
	// reflective teapot, and orbits as the parent node rotates. We give the rotation action a tag so we can
	// find it again when the satellite teapot collides with the brick wall and we need to change the motion.
	CCAction* teapotSpinAction =  [CC3ActionRotateForever actionWithRotationRate: cc3v(0.0, 60.0, 0.0)];
	teapotSpinAction.tag = kTeapotRotationActionTag;
	[_teapotTextured runAction: teapotSpinAction];

	 // For effect, also rotate the satellite around its own axes.
	[_teapotSatellite runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(30.0, 0.0, 45.0)]];
}

/**
 * When running with GLSL shaders under OpenGL ES 2.0 on iOS, or OpenGL on OSX, adds a large skybox
 * surrounding the scene, using a cube-map texture. A cube-map texture actually consists of six
 * textures, each representing a view of the scene from one of the six scene axes. As a convenience,
 * the six textures are loaded using a file-name pattern.
 *
 * In this example, the six cube-map textures include markers to illustrate which texture is which.
 *
 * Cube maps can also be used to render environmental reflections on objects. This skybox is reflected
 * into the reflective runner added in the addSkinnedRunners method. The runner will reflect this skybox
 * texture even if the skybox itself is not added.
 */
-(void) addSkyBox {
#if !CC3_OGLES_1
	CC3MeshNode* skyBox = [CC3SphereNode nodeWithName: @"SkyBox"];
	[skyBox populateAsSphereWithRadius: 1600.0f andTessellation: CC3TessellationMake(24, 24)];
	skyBox.shouldCullBackFaces = NO;
	skyBox.texture = [CC3Texture textureCubeFromFilePattern: @"EnvMap%@.jpg"];
	[skyBox applyEffectNamed: @"SkyBox" inPFXResourceFile: @"EnvMap.pfx"];
	[self addChild: skyBox];

	// PVR files can contain an entire cube-map (and all the mipmaps too) in a single file.
	// To try it out when running on iOS, uncomment the following line.
//	skyBox.texture = [CC3Texture textureFromFile: @"Skybox.pvr"];

	[_ground remove];	// Remove the ground, because the skybox already includes a ground
#endif	// !CC3_OGLES_1
}

/**
 * Adds a parametric textured wall that can be touched to slide it into the path of the
 * rainbow teapot as it orbits the textured teapot. Once in the path of the teapot, it
 * causes the teapot to bounce off it and reverse path, demonstating collision detection.
 */
-(void) addBrickWall {
	// Create a parametric textured box as an open door.
	_brickWall = [DoorMeshNode nodeWithName: kBrickWallName];
	_brickWall.touchEnabled = YES;
	[_brickWall populateAsSolidBox: CC3BoxMake(-1.5, 0, -0.3, 1.5, 2.5, 0.3)];
	_brickWall.uniformScale = 40.0;
	
	// Add a texture to the wall and repeat it. This creates a material automatically.
	_brickWall.texture = [CC3Texture textureFromFile: kBrickTextureFile];
	[_brickWall repeatTexture: (ccTex2F){4, 2}];
	_brickWall.ambientColor = kCCC4FWhite;			// Increase the ambient reflection so the backside is visible
	
	// Start with the wall in the open position
	_brickWall.isOpen = YES;
	_brickWall.location = kBrickWallOpenLocation;
	_brickWall.rotation = cc3v(0, -45, 0);
	
	// Wall is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: _brickWall andMaterializeWithDuration: kFadeInDuration];
	[self addChild: _brickWall];
}

/** Loads a POD file containing an animated robot arm, a camera, and an animated light. */
-(void) addRobot {
	// We introduce a specialized resource subclass, not because it is needed in general,
	// but because the original PVR demo app ignores some data in the POD file. To replicate
	// the PVR demo faithfully, we must do the same, by tweaking the loader to act accordingly
	// by creating a specialized subclass.
	CC3ResourceNode* podRezNode = [CC3PODResourceNode nodeWithName: kPODRobotRezNodeName];
	[podRezNode populateFromResource: [IntroducingPODResource resourceFromFile: kRobotPODFile]];
	
	// If you want to stop the robot arm from being animated, uncomment the following line.
//	[podRezNode disableAllAnimation];
	
	podRezNode.touchEnabled = YES;
	[self addChild: podRezNode];
	
	// Retrieve the camera in the POD and cache it for later access.
	_robotCam = (CC3Camera*)[podRezNode getNodeNamed: kRobotCameraName];
	
	// Retrieve the light from the POD resource so we can track its location as it moves via animation
	_robotLamp = (CC3Light*)[podRezNode getNodeNamed: kPODLightName];
	
	// Start the animation of the robot arm and bouncing lamp from the PVR POD file contents.
	// But we'll have a bit of fun with the animation, as follows.
	// The basic animation in the POD pirouettes the robot arm in a complex movement...
	CCActionInterval* pirouette = [CC3ActionAnimate actionWithDuration: 5.0];
	
	// Extract only the initial bending-down motion from the animation, reverse it to create
	// a stand-up motion, and paste the two actions together to create a bowing motion.
	CCActionInterval* bendDown = [CC3ActionAnimate actionWithDuration: 1.8 limitFrom: 0.0 to: 0.15];
	CCActionInterval* standUp = [bendDown reverse];
	CCActionInterval* takeABow = [CCActionSequence actionOne: bendDown two: standUp];
	
	// Now...put it all together. The robot arm performs its pirouette, and then takes a bow,
	// over and over again.
	[podRezNode runAction: [[CCActionSequence actionOne: pirouette two: takeABow] repeatForever]];
}

/**
 * Add small red, green and blue teapots to mark the X, Y & Z axes respectively.
 * The teapots appear at location 100.0 on each of the axes.
 */
-(void) addAxisMarkers {
	
	// To exhibit node creation options, we create the red teapot using a factory method.
	// But then we create the blue and green teapots by copying the red teapot.

	// Red teapot is at postion 100 on the X-axis
	CC3Node* teapotRed = [[CC3ModelSampleFactory factory] makeUniColoredTeapotNamed: kTeapotRedName
																		  withColor: ccc4f(0.7, 0.0, 0.0, 1.0)];
	teapotRed.location = cc3v(100.0, 0.0, 0.0);
	teapotRed.uniformScale = 100.0;
	teapotRed.touchEnabled = YES;		// allow this node to be selected by touch events
	
	// Teapot is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: teapotRed andMaterializeWithDuration: kFadeInDuration];
	[self addChild: teapotRed];
	
	// Green teapot is at postion 100 on the Y-axis
	// Create it by copying the red teapot.
	CC3Node* teapotGreen = [teapotRed copyWithName:  kTeapotGreenName];
	teapotGreen.diffuseColor = ccc4f(0.0, 0.7, 0.0, 1.0);
	teapotGreen.location = cc3v(0.0, 100.0, 0.0);

	// Teapot is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: teapotGreen andMaterializeWithDuration: kFadeInDuration];
	[self addChild: teapotGreen];
	
	// Blue teapot is at postion 100 on the Z-axis
	// Create it by copying the red teapot.
	CC3Node* teapotBlue = [teapotRed copyWithName:  kTeapotBlueName];
	teapotBlue.diffuseColor = ccc4f(0.0, 0.0, 0.7, 1.0);
	teapotBlue.location = cc3v(0.0, 0.0, 100.0);

	// Teapot is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: teapotBlue andMaterializeWithDuration: kFadeInDuration];
	[self addChild: teapotBlue];
}

/**
 * Adds a small white teapot that will be used to indicate the current position of the light
 * that illuminates the scene. The light is animated and moves up and down according to
 * animation data from the POD file, and the white teapot tracks its location (actually its
 * direction, since it is a directional light).
 */
-(void) addLightMarker {
	_teapotWhite = [[CC3ModelSampleFactory factory] makeUniColoredTeapotNamed: kTeapotWhiteName
																	withColor: kCCC4FWhite];
	_teapotWhite.uniformScale = 200.0;
	_teapotWhite.touchEnabled = YES;		// allow this node to be selected by touch events
	
	// Teapot is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: _teapotWhite andMaterializeWithDuration: kFadeInDuration];
	[self addChild: _teapotWhite];
}

/**
 * Adds a label created from bitmapped font loaded from a font confguration file.
 *
 * The CylinderLabel class is a custom class that further bends the text around the arc of
 * a circle whose center is behind the text. The effect is like a marquee on a round tower.
 * This example demonstrates both the use of bitmapped text labels, and the ability to
 * manipulate the locations of vertices programmatically.
 */
-(void) addBitmapLabel {
	CylinderLabel* bmLabel = [CylinderLabel nodeWithName: kBitmapLabelName];
	bmLabel.radius = 50;
	bmLabel.textAlignment = NSTextAlignmentCenter;
	bmLabel.relativeOrigin = ccp(0.5, 0.5);
	bmLabel.tessellation = CC3TessellationMake(4, 1);
	bmLabel.fontFileName = @"Arial32BMGlyph.fnt";
	bmLabel.labelString = @"Hello, world!";
	_bmLabelMessageIndex = 0;	// Keep track of which message is being displayed
	
	bmLabel.location = cc3v(-150.0, 75.0, 500.0);
	bmLabel.rotation = cc3v(0.0, 180.0, 0.0);
	bmLabel.uniformScale = 2.0;
	bmLabel.color = CCColorRefFromCCC4F(ccc4f(0.0, 0.85, 0.45, 1.0));
	bmLabel.shouldCullBackFaces = NO;			// Show from behind as well.
	bmLabel.touchEnabled = YES;

	// Label is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: bmLabel andMaterializeWithDuration: kFadeInDuration];
	[self addChild: bmLabel];
	[bmLabel runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0, 30, 0)]];
}

/**
 * Add a label attached to the robot arm. This is created using a Cocos2D label object wrapped
 * in a CC3Billboard to turn it into a 3D object.
 *
 * Unfortunately, this label will not play nicely with the fog, because it contains transparent parts
 * that should be discarded by the fragment shader so that the deptth component is not written to the
 * depth buffer. This would allow the fog to show through (see the cylindrical text example in this 
 * demo for an example of how that works. But since this is a Cocos2D component, it would require
 * changing the Cocos2D shaders to get it to work. There's no point in doing that, because it would
 * be better to simply use 3D text instead of a Cocos2D text component.
 */
-(void) addProjectedLabel {
	CCLabelTTF* bbLabel = [CCLabelTTF labelWithString: @"Whoa...I'm dizzy!"
											 fontName: @"Marker Felt"
											 fontSize: 18.0];
	CC3Billboard* bb = [CC3Billboard nodeWithName: kBillboardName withBillboard: bbLabel];
	bb.color = CCColorRefFromCCC4F(kCCC4FYellow);
	
	// The billboard is a one-sided rectangular mesh, and would not normally be visible from the
	// back side. This is not an issue, since it is configured to always face the camera. However,
	// this also affects its ability to cast a shadow when the light is behind it. Set the back
	// faces to draw so that a shadow will be cast when the light is behind the billboard.
//	bb.shouldCullBackFaces = NO;
	
	// As the hose emitter moves around, it is sometimes in front of this billboard, but emits
	// some particles behind this billboard. The result is that those particles are blocked by
	// the transparent parts of the billboard and appear to inappropriately disappear. To compensate,
	// set the explicit Z-order of the billboard to be either always in-front of (< 0) or always
	// behind (> 0) the particle emitter. You can experiment with both options here. Or set the
	// Z-order to zero (the default and same as the emitter), and see what the problem is in the
	// first place! The problem is more evident when the emitter is set to a wide dispersion angle.
	bb.zOrder = -1;
	
	// Uncomment to see the extent of the label as it moves in the 3D scene
//	bb.shouldDrawLocalContentWireframeBox = YES;

	
	// A billboard can be drawn either as part of the 3D scene, or as an overlay
	// above the 3D scene. By commenting out one of the following sections of code,
	// you can choose which method to use.
	
	// 1) In the 3D scene:
	//    Find the camera and track it, so that it always faces the camera.
	bb.shouldAutotargetCamera = YES;
	
	// 2) Overlaid above the 3D scene:
	//    The following lines add the emitter billboard as a 2D overlay that draws above
	//    the 3D scene. The label text will not be occluded by any other 3D nodes.
	//    Comment out the lines just above, and uncomment the following lines:
//	bb.shouldDrawAs2DOverlay = YES;
//	bb.unityScaleDistance = 425.0;
//	bb.offsetPosition = ccp( 0.0, 15.0 );
	
	// Billboards with transparency don't shadow well, so don't let this billboard cast a shadow.
	bb.shouldCastShadows = NO;
	
	// Locate the billboard at the end of the robot's arm
	bb.location = cc3v( 0.0, 90.0, 0.0 );
	[[self getNodeNamed: kRobotTopArm] addChild: bb];
}

/**
 * OpenGL ES 1.1 performs multi-texturing using a series of texture units that can be
 * configured and chained together. This provides a flexible multi-texturing environment.
 *
 * Adds a multi-texture sign, consisting of a combination of a wooden sign texture
 * and a stamp texture that are combined during rendering. Several styles of combining 
 * (including bump-mapping) can be cycled through by repeatedly touching the sign.
 *
 * OpenGL ES 2.0 and OpenGL OSX do not provide the same system of configurable texture units.
 * In those programmable rendering pipelines, fragment shader perform the same texture-combining
 * functionality (and much more). This example is only active under OpenGL ES 1.1.
 */
#if CC3_OGLES_1
-(void) addWoodenSign {
	// Texture for the basic wooden sign
	_signTex = [CC3Texture textureFromFile: kSignTextureFile];

	// Texture for the stamp overlay.
	// Give it a configurable texture unit so we can play with the configuration.
	_stampTex = [CC3TextureUnitTexture textureFromFile: kSignStampTextureFile];
	_stampTex.textureUnit = [CC3ConfigurableTextureUnit textureUnit];
	
	// Texture that has a bump-map stamp, whose pixels contain normals instead of colors.
	// Give it a texture unit configured for bump-mapping. The rgbNormalMap indicates how
	// the X,Y & Z components of the normal are stored in the texture RGB components.
	_embossedStampTex = [CC3TextureUnitTexture textureFromFile: kSignStampNormalsTextureFile];
	
	// Although there is also a dedicated CC3BumpMapTextureUnit that we'd usually
	// use for bump-mapping, we use CC3ConfigurableTextureUnit instead, to demonstrate
	// that it is possible, and also to make it easier to swap one texture for the other.
	CC3ConfigurableTextureUnit* ctu = [CC3ConfigurableTextureUnit textureUnit];
	ctu.combineRGBFunction = GL_DOT3_RGB;
	ctu.rgbSource1 = GL_CONSTANT;
	ctu.rgbNormalMap = kCC3DOT3RGB_YZX;
	_embossedStampTex.textureUnit = ctu;
	
	// Create wooden sign, starting with wood sign texture
	_woodenSign = [CC3PlaneNode nodeWithName: kSignName];
	[_woodenSign populateAsCenteredRectangleWithSize: CGSizeMake(150.0, 150.0)
									 andTessellation: CC3TessellationMake(4, 4)];
	_woodenSign.texture = _signTex;

	// Add the stamp overlay texture
	[_woodenSign addTexture: _stampTex];

	// Adjust the mesh to use only a section of the texture. This feature can be used to
	// extract a texture from a texture atlas, so that a single loaded texture can be used
	// to cover multiple meshes, with each mesh covered by a different section fo the texture.
	_woodenSign.textureRectangle = CGRectMake(0.4, 0.23, 0.35, 0.35);
	
	// The bump-map texture uses an object-space bump-map that uses a light direction that is held in
	// the texture unit. The node tracks the light and sets the light direction in the texture unit.
	_woodenSign.target = _robotLamp;
	_woodenSign.shouldTrackTarget = YES;
	_woodenSign.isTrackingForBumpMapping = YES;

	_woodenSign.diffuseColor = kCCC4FCyan;
	_woodenSign.specularColor = kCCC4FLightGray;
	_woodenSign.touchEnabled = YES;		// Allow the sign to be selected by touch events.
	
	// The sign starts out in the X-Y plane and facing up the positive Z-axis.
	// Rotate the sign 90 degrees so that it faces the center of the scene.
	_woodenSign.rotation = cc3v(0.0, 90.0, 0.0);
	
	// Add a label below the sign that identifies which combiner method is being used.
	// This label will be automatically updated whenever the user touches the wooden sign
	// to switch the combiner function.
	NSString* texEnvName = NSStringFromGLEnum(((CC3ConfigurableTextureUnit*)_stampTex.textureUnit).combineRGBFunction);
	NSString* lblStr = [NSString stringWithFormat: kMultiTextureCombinerLabel, texEnvName];
	CCLabelTTF* bbLabel = [CCLabelTTF labelWithString: lblStr
											 fontName: @"Arial"
											 fontSize: 9.0];
	CC3Billboard* bb = [CC3Billboard nodeWithName: kSignLabelName withBillboard: bbLabel];
	bb.location = cc3v( 0.0, -90.0, 0.0 );
	bb.color = ccMAGENTA;
	[_woodenSign addChild: bb];
	
	// Allow the wooden sign to be viewed when the camera goes behind.
	_woodenSign.shouldCullBackFaces = NO;
	
	// The wooden sign is a planar mesh with no "other side", so it requires special
	// configuration when applying shadow volumes. We indicate that we want to shadow back
	// faces as well as front faces, and we use vertex offsetting instead of decal offsetting.
	_woodenSign.shouldShadowBackFaces = YES;
	_woodenSign.shadowOffsetUnits = 0;
	_woodenSign.shadowVolumeVertexOffsetFactor = kCC3DefaultShadowVolumeVertexOffsetFactor;
	
	// Add the wooden sign to the bump-map light tracker so that when the bump-map
	// texture overlay is displayed, it will interact with the light source.
	_woodenSign.location = cc3v(-600.0, 250.0, -200.0);

	// Sign is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: _woodenSign andMaterializeWithDuration: kFadeInDuration];
	[self addChild: _woodenSign];

}
#else
-(void) addWoodenSign {}
#endif	// CC3_OGLES_1

// Text to hold in userData of floating head and then log when the head is poked.
static NSString* kDontPokeMe = @"Owww! Don't poke me!";

/**
 * Adds a bump-mapped floating purple head to the scene, suitable for running under either
 * OpenGL ES 1.1 or OpenGL ES 2.0.
 *
 * Bump-mapping under OpenGL ES 1.1 is much more limited than the techniques available under
 * OpenGL ES 2.0. This example demonstrates the technique for OpenGL ES 1.1. Under OpenGL ES 1.1,
 * the normals contained in the bump-mapping texture must be specified in model-space coordinates.
 *
 * This example also runs correctly under OpenGL ES 2.0, but is not the recommended technique.
 * Under OpenGL ES 2.0, your model should include vertex tangent content, and the normals in
 * your texture should be specified in tangent-space (which is much easier). When using vertex
 * tangents, none of the texture unit configuration below is required, nor is the light tracker
 * required, as the GLSL shader code handles the texture lookups and normal mapping directly.
 * See the addEtchedMask method for an example of using vertex tangent content.
 *
 * Bump-mapping works by applying a texture that contains normal data instead of colors. This allows
 * us to apply a different normal to every pixel of the texture, instead of only at the vertices.
 * This allows us to simulate 3D surface at a resolution much higher than the vertices permit.
 * 
 * The floating head has much higher 3D definitional resolution that provided by the
 * relatively low vertex count mesh. The mesh only contains 153 vertices.
 *
 * You'll notice that the light shadowing changes correctly as the light moves up and
 * down, and as you move the camera around, which causes the head to rotate to follow you.
 */
-(void) addFloatingHead {
	CC3ResourceNode* podRezNode = [CC3PODResourceNode nodeWithName: kPODHeadRezNodeName
														  fromFile: kHeadPODFile];

	// Extract the floating head mesh node and set it to be touch enabled
	_floatingHead = [podRezNode getMeshNodeNamed: kFloatingHeadName];
	_floatingHead.touchEnabled = YES;
	_floatingHead.diffuseColor = kCCC4FWhite;
	_floatingHead.ambientColor = kCCC4FGray;
	
	// Demonstrate the use of application-specific data attached to a node in the userData property.
	_floatingHead.userData = kDontPokeMe;
	
	// The floating head normal texture was created in a left-handed coordinate
	// system (eg- DirectX). OpenGL uses a right-handed coordinate system.
	// The difference means that the bump-map normals interact as if the light
	// was coming from the opposite direction. We can correct for this by flipping
	// the normal texture horizontally by flipping the textue mapping coordinates
	// of the mesh horizontally.
	[_floatingHead flipTexturesHorizontally];

	// The origin of the floating head mesh is at the bottom. It suits our purposes better to
	// have the origin of the mesh at the center of geometry. The method we invoke here changes
	// the value of every vertex in the mesh. So we should only ever want to do this once per mesh.
	[_floatingHead moveMeshOriginToCenterOfGeometry];
	
	// Texture that has a bump-map stamp, whose pixels contain normals instead of colors.
	// Give it a texture unit configured for bump-mapping. The rgbNormalMap indicates how
	// the X,Y & Z components of the normal are stored in the texture RGB components.
	_headBumpTex = [CC3TextureUnitTexture textureFromFile: kHeadBumpFile];
	_headBumpTex.textureUnit = [CC3BumpMapTextureUnit textureUnit];
	_headBumpTex.textureUnit.rgbNormalMap = kCC3DOT3RGB_YZX;
	
	// Load the visible texture of the floating head, and add it as an overlay on the bump map texture.
	_headTex = [CC3Texture textureFromFile: kHeadTextureFile];

	// The two textures are PVR textures pre-loaded with mipmaps.
	// However, using the mipmap for this mesh creates a visual artifact around the
	// fringe of the model. So we'll just use linear filtering on the main texture.
	// Comment out these two lines if you want to see the difference.
	_headBumpTex.texture.minifyingFunction = GL_LINEAR;
	_headTex.minifyingFunction = GL_LINEAR;

	// Add the bump-map texture and the color texture to the material.
	_floatingHead.material.texture = _headBumpTex;		// replace the dummy texture
	[_floatingHead.material addTexture: _headTex];
	
	// The bump-map texture uses an OpenGL ES 1.1-compatible object-space bump-map that uses
	// a light direction that is held in the texture unit. The mesh node tracks the direction
	// to the light, and sets it in the texture unit. Because of this, the mesh node cannot
	// also track the camera, to face the camera. But that's okay, because we have already
	// wrapped the floating head mesh node in an orienting wrapper.
	_floatingHead.target = _robotLamp;
	_floatingHead.shouldTrackTarget = YES;
	_floatingHead.isTrackingForBumpMapping = YES;
	
	// Put the head node in an orienting wrapper so that we can orient it to face the camera.
	// First turn the floating head to face right so that it points towards the side of the
	// wrapper that will be kept facing the camera, and move the head to the origin of the wrapper.
	_floatingHead.rotation = cc3v(0, -90, 0);
	_floatingHead.location = kCC3VectorZero;
	CC3Node* headHolder = [_floatingHead asCameraTrackingWrapper];
	headHolder.location = cc3v(-500.0, 200.0, 0.0);

	// Head is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: headHolder andMaterializeWithDuration: kFadeInDuration];
	[self addChild: headHolder];
}

/**
 * Loads a POD file containing the Cocos3D mascot, and creates a copy of it so that we have
 * two mascots. One mascot always stares back at the camera, regardless of where the camera
 * moves to. The other is distracted by the rainbow teapot and its gaze follows the teapot
 * as the rainbow teapot moves.
 *
 * The Cocos2D/Cocos3D mascot model was created by Alexandru Barbulescu, and used by permission.
 */
-(void) addMascots {

	// Create the mascots. Load the first from file, then copy to create the second.
	// The texture coordinates of the mascot POD file expect the texture to be loaded
	// upside down. By telling the resource this, it will compensate during loading.
	CC3ResourceNode* podRezNode = [CC3PODResourceNode nodeFromFile: kMascotPODFile
								  expectsVerticallyFlippedTextures: YES];
	_mascot = [podRezNode getMeshNodeNamed: kMascotName];
	CC3MeshNode* distractedMascot = [_mascot copyWithName: kDistractedMascotName];
	
	// Allow the mascots to be selected by touch events.
	_mascot.touchEnabled = YES;
	distractedMascot.touchEnabled = YES;

	// Scale the mascots
	_mascot.uniformScale = 22.0;
	distractedMascot.uniformScale = 22.0;
	
	// Create the wrapper for the mascot that stares back at the camera.
	// Rotate the mascot in the wrapper so that the correct side faces the camera
	// as the wrapper tracks the camera.
	CC3Node* mascotHolder = [_mascot asCameraTrackingWrapper];
	_mascot.rotation = cc3v(0, -90, 0);
	mascotHolder.location = cc3v(-450.0, 100.0, -575.0);

	// Mascot is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: mascotHolder andMaterializeWithDuration: kFadeInDuration];
	[self addChild: mascotHolder];

	// Arrange for the mascot to be distracted by the rainbow teapot's movements.
	// We could have the mascot track the teapot itself. But, the wrong side would
	// face the teapot. To have the correct side of the mascot face the teapot, we
	// add it to a wrapper, turn it to look to the right within the wrapper, and
	// then arrange for the wrapper to track the rainbow teapot.
	CC3Node* distractedMascotHolder = [distractedMascot asTrackingWrapper];
	distractedMascot.rotation = cc3v(0, -90, 0);
	distractedMascotHolder.location = cc3v(-375.0, 100.0, -700.0);
	distractedMascotHolder.target = _teapotSatellite;

	// Mascot is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: distractedMascotHolder andMaterializeWithDuration: kFadeInDuration];
	[self addChild: distractedMascotHolder];

	// If you want to restrict the mascot to only rotating side-to-side around the
	// Y-axis, but not up and down, uncomment the following line.
//	distractedMascotHolder.targettingConstraint = kCC3TargettingConstraintLocalYAxis;
	
	// To see the orientation of the mascot within the orienting wrapper, uncomment
	// the first line below. This will show that the front of the mascot faces down
	// the positive X-axis. The 90-degree rotation above serves to rotate this X-axis
	// of the mascot to align with the positive-Z axis of the wrapper, which is the
	// axis that points towards the rainbox teapot.
	// Uncomment the second line to see that the Z-axis of the wrapper points towards
	// the target. If you uncomment both lines to see both sets of axes at the same
	// time, then also uncomment the third line below to give the two sets of axes
	// an offset, so you can see both.
//	[distractedMascot addAxesDirectionMarkers];
//	[distractedMascotHolder addAxesDirectionMarkers];
//	distractedMascot.location = cc3v(0, 20, 0);
}

/**
 * Adds a sun in the sky, in the form of a standard Cocos2D particle emitter,
 * held in the 3D scene by a CC3Billboard. The sun is a very large particle
 * emitter, and you should notice a drop in frame rate when it is visible.
 */
-(void) addSun {
	// Create the Cocos2D 2D particle emitter.
	CCParticleSystem* emitter = [CCParticleSun node];
	emitter.position = ccp(0.0, 0.0);
	
	// Create the 3D billboard node to hold the 2D particle emitter.
	CC3Billboard* bb = [CC3ParticleSystemBillboard nodeWithName: kSunName
												  withBillboard: emitter];

	// A billboard can be drawn either as part of the 3D scene, or as an overlay
	// above the 3D scene. By commenting out one of the following sections of code,
	// you can choose which method to use.
	
	// 1) In the 3D scene.
	// The following lines wrap the emitter billboard in a wrapper that will find
	// and track the camera in 3D. The sun can be occluded by other nodes between
	// it and the camera.

	bb.uniformScale = 3.0;			// Find a suitable size

	// 2D particle systems do not have a real contentSize and boundingBox, so we need to
	// calculate it dynamically on each update pass, or assign one that will cover the
	// area that will be used by this particular particle system. This bounding rectangle
	// is specified in terms of the local coordinate system of the particle system and
	// will be scaled and transformed as the node is transformed. By setting this once,
	// we don't need to calculate it while running the particle system.
	// To calculate it dynamically on each update instead, comment out the following line,
	// and uncomment the line after.
	bb.billboardBoundingRect = CGRectMake(-30.0, -30.0, 60.0, 60.0);
//	bb.shouldAlwaysMeasureBillboardBoundingRect = YES;
	
	// How did we determine the billboardBoundingRect? This can be done by trial and
	// error, by uncommenting culling logging in the CC3Billboard doesIntersectBoundingVolume:
	// method. Or it is better done by changing LogTrace to LogDebug in the CC3Billboard
	// billboardBoundingRect property accessor method, commenting out the line above this
	// comment, and uncommenting the following line. Doing so will cause an ever expanding
	// bounding box to be logged, the maximum size of which can be used as the value to
	// set in the billboardBoundingRect property.
//	bb.shouldMaximizeBillboardBoundingRect = YES;

	// Locate the sun way up in the sky, and set it to find and track the camera
	// so that it appears to be spherical from wherever the camera is.
	bb.location = cc3v(1000.0, 1000.0, -100.0);
	bb.shouldAutotargetCamera = YES;
	[self addChild: bb];

	// 2) Overlaid above the 3D scene.
	// The following lines add the emitter billboard as a 2D overlay that draws above
	// the 3D scene. The flames will not be occluded by any other 3D nodes.
	// Comment out the lines in section (1) just above, and uncomment the following lines:
//	emitter.positionType = kCCPositionTypeGrouped;
//	bb.shouldDrawAs2DOverlay = YES;
//	bb.location = cc3v(3000.0, 3000.0, -100.0);
//	bb.unityScaleDistance = 9000.0;
//	[self addChild: bb];
}

/**
 * Adds a spotlight to the camera. The spotlight is initially turned off, but will be turned
 * on when the sun is turned off. The spotlight has a focused beam and the intensity of the
 * light attenuates with distance from the light.
 */
-(void) addSpotlight {
	CC3Light* spotLight = [CC3Light nodeWithName: kSpotlightName];
	spotLight.visible = NO;
	spotLight.spotExponent = 30.0;
	spotLight.spotCutoffAngle = 60.0;
	spotLight.attenuation = CC3AttenuationCoefficientsMake(0.0, 0.002, 0.000001);
	spotLight.isDirectionalOnly = NO;
	[self.activeCamera addChild: spotLight];
}

/** 
 * Adds light probes to the scene.
 *
 * Illuminating models with light probes is an alternate to using individual lights. Light probes 
 * contain a texture (usually a cube-map texture) that defines the lighting characteristics of an
 * area of the scene. Within a GLSL shader, the vertex or fragment normal is used to pick a light 
 * intensity from the texture. Light probes often capture lighting nuances and detail that can be 
 * difficult to replicate with individual lights, and can improve performance, as they require 
 * substantially less calculation within a shader.
 * 
 * Light probes are not available when using OpenGL ES 1.1.
 */
-(void) addLightProbes {
#if !CC3_OGLES_1
	// Load the cube texture that contains the lighting incident from all directions.
	// Alternately, for an interesting effect, you can comment out the first line and
	// uncomment the second line, to load a cube-texture that contains a different
	// solid color per side. This color-coded clearly demonstrates how the cube texture
	// is being mapped to the normals of the model.
	CC3Texture* lpTex = [CC3Texture textureCubeFromFilePattern: @"cubelight_%@.png"];
//	CC3Texture* lpTex = [CC3Texture textureCubeColoredForAxes];

	[self addChild: [CC3LightProbe nodeWithTexture: lpTex]];
#endif	// !CC3_OGLES_1
}

/**
 * Adds fog to the scene. The fog is initially turned off, but will be turned on when
 * the sun button is toggled. The fog cycles in color between bluish and reddish tones.
 * Under OpenGL ES 1.1, fog is configured in GL engine. Under OpenGL ES 2.0 or OpenGL OSX,
 * fog provided using shader post-processing.
 */
-(void) addFog {
	self.fog = [CC3Fog fog];

#if CC3_GLSL
	[_fog addTexture: _postProcSurface.colorTexture];
	[_fog addTexture: _postProcSurface.depthTexture];
	_fog.shaderProgram = [CC3ShaderProgram programFromVertexShaderFile: @"CC3ClipSpaceTexturable.vsh"
												 andFragmentShaderFile: @"CC3Fog.fsh"];
#endif	// !CC3_GLSL

	_fog.visible = NO;
	_fog.color = CCColorRefFromCCC4F(ccc4f(0.5, 0.5, 0.75, 1.0));	// A slightly bluish fog.

	// Choose one of GL_LINEAR, GL_EXP or GL_EXP2
	_fog.attenuationMode = GL_EXP2;

	// If using GL_EXP or GL_EXP2, the density property will have effect.
	_fog.density = 0.0017;
	
	// If using GL_LINEAR, the start and end distance properties will have effect.
	_fog.startDistance = 200.0;
	_fog.endDistance = 1500.0;

	// To make things a bit more interesting, set up a repeating up/down cycle to
	// change the color of the fog from the original bluish to reddish, and back again.
	GLfloat tintTime = 4.0f;
	CCColorRef startColor = _fog.color;
	CCColorRef endColor = CCColorRefFromCCC4F(ccc4f(0.75, 0.5, 0.5, 1.0));		// A slightly redish fog.
	CCActionInterval* tintDown = [CCActionTintTo actionWithDuration: tintTime color: endColor];
	CCActionInterval* tintUp   = [CCActionTintTo actionWithDuration: tintTime color: startColor];
	[_fog runAction: [[CCActionSequence actionOne: tintDown two: tintUp] repeatForever]];
}

/**
 * Adds a mallet that moves back and forth, alternately hammering two anvils.
 * The mallet's mesh employs vertex skinning and an animated bone skeleton to
 * simulate smooth motion and realistic flexibility.
 */
-(void) addSkinnedMallet {
	// Load the POD file and remove its camera since we won't need it.
	// This is not actually necessary, but demonstrates that the resources loaded from
	// a POD file, including the resource node, are just nodes that can be manipulated
	// like any other node assembly.
	CC3ResourceNode* malletAndAnvils = [CC3PODResourceNode nodeFromFile: kMalletPODFile];
	[[malletAndAnvils getNodeNamed: @"Camera01"] remove];
	[[malletAndAnvils getNodeNamed: @"Camera01Target"] remove];

	CC3MeshNode* mallet = [malletAndAnvils getMeshNodeNamed: kMalletName];
	
	// Mallet normal transforms are scaled too far during transforms, so force
	// the normals to be individually re-normalized after being transformed.
	mallet.normalScalingMethod = kCC3NormalScalingNormalize;

	// Ensure the bones in the mallet are rigid (no scale applied). Doing this allows the
	// shader program that is optimized for that to be automatically selected for the mallet
	// skinned mesh node. Many more active bones are possible with a rigid skeleton.
	// The model must be designed as a rigid model, otherwise it won't animate correctly.
	[mallet ensureRigidSkeleton];
	
	// Because the mallet is a skinned model, it is not automatically assigned a bounding volume,
	// and will be be drawn even if it is not in front of the camera. We can leave it like this,
	// however, because the mallet is a complex model and is often out of view of the camera, we
	// can reduce processing costs by giving it a fixed bounding volume whose size we determine at
	// development time. We do this here by letting the mallet determine its own bounding volume,
	// which will be a spherical bounding volume that encompasses the mesh in its rest pose.
	// By using the shouldDrawAllBoundingVolumes property, we can check if this bounding volume
	// is appropriate. It turns out to be a bit too small, so we scale the bounding volume, to
	// increase its radius, so that it encompasses the mallet regardless of how the mallet is flexed.
	[mallet createSkinnedBoundingVolumes];
	[mallet.boundingVolume scaleBy: 1.6f];
//	malletAndAnvils.shouldDrawAllBoundingVolumes = YES;	// Verify visually and adjust scale accordingly

	malletAndAnvils.touchEnabled = YES;		// make the mallet touchable
	malletAndAnvils.location = cc3v(300.0, 95.0, 300.0);
	malletAndAnvils.rotation = cc3v(0.0, -45.0, 0.0);
	malletAndAnvils.uniformScale = 0.15;
	
	[malletAndAnvils runAction: [[CC3ActionAnimate actionWithDuration: 3.0] repeatForever]];

	// Spin the mallet and anvils around for effect
	[malletAndAnvils runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0.0, 10.0, 0.0)]];

	// Mallet is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: malletAndAnvils andMaterializeWithDuration: kFadeInDuration];
	[self addChild: malletAndAnvils];
}

/**
 * Adds two running men to the scene. The men run endless laps around the scene. The men's meshes
 * employ vertex skinning and an animated bone skeleton to simulate smooth motion and realistic
 * joint flexibility. Under a programmable rendering pipeline, the smaller man also sports a
 * reflective skin that reflects the environment, using a static cube-map texture. 
 *
 * In contrast to the reflective teapot in the addTeapotAndSatellite method, the reflective runner
 * here has a static cube-map texture. Such a texture is typically generated once, usually at
 * development time, and does not dynamically update as the scene contents change. The benefit
 * to using a static environment map is that it does not required repeatitive regeneration, and
 * is therefore much more efficient than a fully dynamic enviornment map, such as used on the
 * reflective teapot.
 *
 * Cube maps can also be used to draw skyboxes. To see the environment that is being reflected
 * into the reflective runner, uncomment the addSkyBox invocation in the initializeScene method.
 */
-(void) addSkinnedRunners {

	// Load the first running man from the POD file.
	CC3ResourceNode* runner = [CC3PODResourceNode nodeWithName: kRunnerName
													  fromFile: kRunningManPODFile];
	
	// Retrieve the camera in the POD and cache it for later access. Adjust the camera
	// frustum to values that are more useful for this demo. Set the field of view to
	// be measured in the vertical orientation, because the runner is vertically oriented
	// and we want him to fit any shape surface in the vertical direction. This corresponds
	// to the common Hor+ FOV approach.
	_runnerCam = (CC3Camera*)[runner getNodeNamed: kRunnerCameraName];
	_runnerCam.fieldOfViewOrientation = CC3FieldOfViewOrientationVertical;
	_runnerCam.farClippingDistance = self.activeCamera.farClippingDistance;
	_runnerCam.hasInfiniteDepthOfField = YES;

	// Retrieve the lamp in the POD, cache it for later access, and turn it off for now.
	_runnerLamp = (CC3Light*)[runner getNodeNamed: kRunnerLampName];
	_runnerLamp.visible = NO;

	// Make the runner a little more visible underl lighting
	runner.diffuseColor = kCCC4FWhite;
	runner.ambientColor = kCCC4FWhite;

	runner.touchEnabled = YES;		// make the runner touchable
	
	// Create a running track at the scene's center.
	// This "running track" is really just a structural node on which we can place the man and
	// then rotate the "track" to move the man. It's really just an invisible boom holding the man.
	CC3Node* runningTrack = [CC3Node nodeWithName: kRunningTrackName];
	runningTrack.location = _ground.location;

	// Place the man on the track, near the edge of the ground frame
	runner.location = cc3v(0, 0, 1100);
	runner.rotation = cc3v(0, 90, 0);	// Rotate the entire POD resource so camera rotates as well
	[runningTrack addChild: runner];
	
	// The bones of the runner are fairly self-contained, and do not move beyond the sphere
	// that encompasses the rest pose of the mesh they are controlling. Because of this, we
	// can let each skin mesh node in the runner (there are 3 skin meshes) create its own
	// spherical bounding volume. If the initial bounding volume of any skin mesh node needs
	// to be adjusted in size, you can retrieve the skin mesh node from the runner model,
	// retrieve its bounding volume using the boundingVolume property, and scale it using
	// the scaleBy: method on the bounding volume. If you want to see the bounding volumes,
	// uncomment the second line below.
	[runner createSkinnedBoundingVolumes];
//	runner.shouldDrawAllBoundingVolumes = YES;	// Verify visually
	
	// Alternately, we can manually create a more accurate bounding volume manually as follows:
	//   - Start by extracting the bounding box of the rest pose of the model. Because this is
	//     happening before the scene has been updated, it is not always safe to invoke the
	//     boundingBox property at runtime because it can mess with node target alignment.
	//     If this issue arises (as it does here with the POD camera target), we can log the
	//     result at dev time and hardcode it.
	//   - Use the bounding box to create a fixed bounding volume around the model
	//   - Set the bounding volume into the root node of the skeleton within the model.
	//     This is the node that you want the bounding volume to track as it moves.
	//   - Use the shouldUseFixedBoundingVolume property to mark the bounding volume as
	//     having a fixed size.
	//   - Set the shouldDrawBoundingVolume property to YES to visualize the bounding volume.
	//   - Use the setSkeletalBoundingVolume: method on the entire model to force all skinned
	//     mesh nodes within the model to use the bounding volume being controlled by the skeleton.
	//   - Visually check the bounding volume. If okay, go with it.
	//   - Use CC3BoxTranslate and CC3BoxScale to modify the bounding box
	//     extracted from the model (or just hardcode a modified bounding box) to position
	//     and size the bounding volume around the model and verify visually.
//	LogTrace(@"Runner box: %@", NSStringFromCC3Box(runner.boundingBox));	// Extract bounding box
//	CC3Box bb = CC3BoxFromMinMax(cc3v(-76.982, 18.777, -125.259), cc3v(61.138, 268.000, 96.993));
//	bb = CC3BoxTranslateFractionally(bb, cc3v(0.0f, -0.1f, 0.1f));	// Move it if necessary
//	bb = CC3BoxScale(bb, cc3v(1.0f, 1.1f, 1.0f));					// Size it if necessary
//	CC3NodeBoundingVolume* bv = [CC3NodeSphereThenBoxBoundingVolume boundingVolumeCircumscribingBox: bb];
//	CC3Node* skeleton = [runner getNodeNamed: @"D_CharacterControl"];
//	skeleton.boundingVolume = bv;						// BV is controlled by skeleton root
//	skeleton.shouldUseFixedBoundingVolume = YES;		// Don't want the BV to change
////	skeleton.shouldDrawBoundingVolume = YES;			// Visualize the BV
////	[skeleton addAxesDirectionMarkers];					// Indicate the orientation
//	runner.skeletalBoundingVolume = bv;					// All skinned mesh nodes in model should use BV

	// Run, man, run!
	// The POD node contains animation to move the skinned character through a running stride.
	[runner runAction: [[CC3ActionAnimate actionWithDuration: 2.4] repeatForever]];

	// Make him run around a circular track by rotating the "track" around the scene's center,
	// and it will carry the man around in a circle with it. By trial and error, set the rotation
	// to take 15 seconds for a full circle, to match the man's stride.
	[runningTrack runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0.0, 12.0, 0.0)]];

	// To demonstrate copying of skinned nodes, add another runner that is a copy, but smaller and
	// with a faster stride. We don't want the runner's POD camera or light, so we'll retrieve the
	// running figure from the POD resource and just copy that. This demonstrates how we can animate
	// either the whole POD resource node, or the specific soft-body node.
	NSString* runnerFigureName = [NSString stringWithFormat: @"%@-SoftBody", kRunningManPODFile];
	CC3Node* runnerFigure = [runner getNodeNamed: runnerFigureName];
	CC3Node* littleBrother = [runnerFigure copyWithName: kLittleBrotherName];
	littleBrother.uniformScale = 0.75f;
	littleBrother.location = cc3v(0, 0, 1000);
	littleBrother.rotation = cc3v(0, 90, 0);	// Copied runner was not rotated (its parent was)
	littleBrother.touchEnabled = YES;			// make the runner touchable
	
	[runningTrack addChild: littleBrother];
	[littleBrother runAction: [[CC3ActionAnimate actionWithDuration: 1.6] repeatForever]];

#if !CC3_OGLES_1
	// If cube-maps are available, give the little runner a reflective coating. This is done
	// by adding a static cube-map environment-map texture to, and setting the reflectivity of,
	// each mesh node contained within the smaller runner. You can adjust the value of the
	// reflectivity property to shor more or less of the runner's suit. Moving the reflectivity
	// towards 1 will make him appear like a little liquid-metal Terminator 2!
	[littleBrother addTexture: [CC3Texture textureCubeFromFilePattern: @"EnvMap%@.jpg"]];
	littleBrother.reflectivity = 0.4;
#endif	// !CC3_OGLES_1

	// Runners are added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: runningTrack andMaterializeWithDuration: kFadeInDuration];
	[self addChild: runningTrack];
}

/**
 * Adds a television showing the view from the runner camera
 * This demonstrates dynamic rendering-to-texture capabilities.
 *
 * The television model POD file was created by exporting from a low-poly (decimated) version
 * of a Blender model created by Blend Swap artist "nhumrod", and downloaded from Blend Swap
 * at http://www.blendswap.com/blends/view/63306 under a CreativeCommons Zero license.
 */
-(void) addTelevision {
	// Create an off-screen framebuffer surface, of a size and aspect (16x9) useful in an
	// HDTV model, backed by a blank color texture to which we can render. Alpha is not
	// required for the underlying texture, so we indicate the texture is opaque, which
	// uses a more memory-efficient 16-bit RGB format. Similarly, since stencils will not
	// be used, we allow a default 16-bit depth buffer to be used for this surface.
	CC3GLFramebuffer*  tvSurface = [CC3GLFramebuffer colorTextureSurfaceIsOpaque: YES];
	tvSurface.name = @"Television";
	tvSurface.size = kTVTexSize;

	// Now create a drawing visitor that will coordinate the drawing of the the TV screen
	// Since the aspect of the TV screen surface is different than the main display, we don't
	// want to reuse either the main camera, or the runner's camera. Instead, we create a
	// dedicated drawing visitor, with it's own camera, which we copy from the runner's camera.
	// and add it beside the runner's camera. We clear the new camera's existing viewport
	// so that it will be set to match the aspect of the TV screen.
	_tvDrawingVisitor = [[[self viewDrawVisitorClass] alloc] init];
	_tvDrawingVisitor.renderSurface = tvSurface;
	CC3Camera* tvCam = [_runnerCam copy];
	[_runnerCam.parent addChild: tvCam];
	tvCam.viewport = kCC3ViewportZero;		// Clear the camera viewport, so it will be set to match the TV surface
	_tvDrawingVisitor.camera = tvCam;
	
	// Load a television model, extract the mesh node corresponding to the screen, and attach
	// the TV test card image as its texture. Since this is a TV, it should not interact with
	// lighting. Since we want to frequently access the TV screen mesh node, it is given a
	// useful name, and cached in an instance variable of this scene.
	CC3ResourceNode* tv = [CC3PODResourceNode nodeWithName: kTVName fromFile: kTVPODFile];
	tv.location = cc3v(1000.0, -100.0, -1000.0);
	tv.rotation = cc3v(0, -45, 0);
	tv.uniformScale = 750.0;
	tv.touchEnabled = YES;
	tv.shouldCullBackFaces = NO;				// Faces winding on decimated model is inconsistent
	_tvScreen = [tv getMeshNodeNamed: @"tv_set-submesh3"];	// Auto-named by PVRGeoPOD
	_tvScreen.name = kTVScreenName;							// Give it a more friendly name
	_tvScreen.shouldUseLighting = NO;
	_tvScreen.emissionColor = kCCC4FWhite;
	_tvScreen.shouldCullFrontFaces = YES;		// Don't paint both front and back of screen
	
	// Start with a test card displayed on the TV
	// Keep the mesh texture coordinates in memory so we can swap textures of different sizes
	_tvTestCardTex = [CC3Texture textureFromFile: kTVTestCardFile];
	_tvScreen.texture = _tvTestCardTex;
	[_tvScreen retainVertexTextureCoordinates];
	
	// TV is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: tv andMaterializeWithDuration: kFadeInDuration];
	[self addChild: tv];
	
	_isTVOn = NO;		// Indicate TV is displaying test card
	
	// Demonstrate the ability to extract a CCTexture from a CC3Texture.
	// For some interesting fun, extract a Cocos2D CCTexture instance from the texture
	// underpinning the TV surface, and replace the Cocos2D label node in the billboard held
	// by the robot arm with a CCSprite holding the CCTexture. The robot arm ends up holding
	// a smaller version of the TV screen. You have to touch the TV screen to activate it.
	// Because the TV screen is only updated with new rendered content when the big-screen
	// TV is viewable by the active camera, the portable TV held by the robot arm will only
	// display dynamic video if the larger TV is in the camera view as well. To view both
	// the big TV and the portable TV updating together, move behind the robot arm and look
	// back towards the big TV so that you can see both TV's displaying live video. You can
	// also change the optimization line in the drawSceneContentWithVisitor: method, and invoke
	// the drawToTVScreen method on each loop, to have both TV's show live video at all times.
//	CCSprite* portableTV = [CCSprite spriteWithTexture: [tvSurface.colorTexture ccTexture]];
//	portableTV.flipY = CCTexture.texturesAreLoadedUpsideDown;		// Cocos2D 3.1 & above takes care of flipping
//	CC3Billboard* bb = (CC3Billboard*)[self getNodeNamed: kBillboardName];
//	bb.uniformScale = 0.1;
//	bb.billboard = portableTV;
}

/** Convenience property that returns the rendering surface of the TV, cast to the correct class. */
-(CC3GLFramebuffer*) tvSurface { return (CC3GLFramebuffer*)_tvDrawingVisitor.renderSurface; }

/**
 * Adds post-rendering image processing capabilities.
 *
 * Adds an off-screen framebuffer surface backed by a texture to hold the color and a texture
 * to hold the depth content. The scene can be rendered to this surface, and, using GLSL shaders,
 * the textures attached to the surface can be processed by the shaders associated with a
 * special post-processing node when drawing one or the other of the surface's textures to the
 * view's rendering surface.
 *
 * If we choose to render the color texture, we can process the values to perform visual
 * operations such as grayscale or blurring. If we choose to render the depth texture, we
 * can get a visualization of the values held in the depth buffer.
 *
 * We want the surface that we create to match the dimensions and characteristics of the view,
 * and we want it to automatically adjust if the view dimensions change. To do that, we construct
 * the surface with the same size as the view's surface, and format the textures to be compatible
 * with the format of the view's surface. And then we register this new surface with the surface
 * manager of the CC3Layer to have it automatically update the dimensions of the textures whenever
 * the dimensions of the CC3Layer change.
 *
 * Since this method accesses the view's surface manager, it must be invoked after the
 * view has been created. This method is invoked from the onOpen method of this class,
 * instead of from the initializeScene method.
 */
-(void) addPostProcessing {
#if !CC3_OGLES_1	// Depth-texture not supported in OpenGL ES 1

	// Create the off-screen framebuffer surface to render the scene to for post-processing effects.
	// We create the off-screen surface with the same size and format characteristics as the view's
	// rendering surface. We specifically use a renderable texture as the depth buffer, so that we
	// can use it to display the contents of the depth buffer as one post-processing option.
	// Otherwise, we could have just used the simpler renderbuffer option for the depth buffer.
	// Finally, we register the off-screen surface with the view's surface manager, so that the
	// off-screen surface will be resized automatically whenever the view is resized.
	CC3ViewSurfaceManager* surfMgr = CC3ViewSurfaceManager.sharedViewSurfaceManager;
	CC3Texture* depthTexture = [CC3Texture textureWithPixelFormat: surfMgr.depthTexelFormat
													withPixelType: surfMgr.depthTexelType];
	_postProcSurface = [CC3GLFramebuffer colorTextureSurfaceWithPixelFormat: surfMgr.colorTexelFormat
															  withPixelType: surfMgr.colorTexelType
														withDepthAttachment: [CC3TextureFramebufferAttachment attachmentWithTexture: depthTexture]];
	_postProcSurface.name = @"Post-proc surface";
	[surfMgr addSurface: _postProcSurface];
	
	// Create a clip-space node that will render the off-screen color texture to the screen.
	// Load the node with shaders that convert the image into greyscale, making the scene
	// appear as if it was filmed with black & white film.
	_grayscaleNode = [CC3ClipSpaceNode nodeWithName: @"Grayscale post-processor" withTexture: _postProcSurface.colorTexture];
	[_grayscaleNode applyEffectNamed: @"Grayscale" inPFXResourceFile: kPostProcPFXFile];
	
	// Create a clip-space node that will render the off-screen depth texture to the screen.
	// Load the node with shaders that convert the depth values into greyscale, visualizing
	// the depth of field as a grayscale gradient.
	_depthImageNode = [CC3ClipSpaceNode nodeWithName: @"Depth-map post-processor" withTexture: _postProcSurface.depthTexture];
	[_depthImageNode applyEffectNamed: @"Depth" inPFXResourceFile: kPostProcPFXFile];

#endif	// !CC3_OGLES_1
}

/**
 * Adds a platform of 3D point particles to the scene, laid out in a grid, and hanging over
 * the back part of the ground. Each particle is displayed in a different color, and the
 * entire platform rotates.
 *
 * Each particle has a normal vector so that it interacts with the light sources.
 * Move the camera around to see the difference between when the camera is looking at the
 * side of a particle that is facing towards a light source and when the camera is looking
 * at the side of a particle that is facing away from a light source.
 *
 * You can play with the settings below to understand how particles behave.
 */
-(void) addPointParticles {
	// Set up the emitter for 1000 particle, each an instance of the HangingParticle class.
	// Each particle has an individual location, color, and size.
	CC3PointParticleEmitter* emitter = [CC3PointParticleEmitter nodeWithName: @"Particles"];
	emitter.particleClass = [HangingPointParticle class];
	emitter.maximumParticleCapacity = 1000;
	emitter.vertexContentTypes = kCC3VertexContentLocation |
								 kCC3VertexContentColor |
								 kCC3VertexContentPointSize;
	
	// Set the emission characteristics
	emitter.texture = [CC3Texture textureFromFile: kPointParticleTextureFile];
	emitter.emissionInterval = 0.01;

	// Combination of particleSize and unity scale distance determine visible size
	// of each particle relative to the distance from the particle to the camera.
	emitter.particleSize = 70.0;
	emitter.unityScaleDistance = 200.0;

	// You can play with the following depth and blending parameters to see the effects
//	emitter.shouldDisableDepthTest = YES;
//	emitter.shouldDisableDepthMask = NO;
	emitter.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
//	emitter.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};	// Additive particles

	// Point particles assume lighting will not be used by default. Turn it on.
	emitter.shouldUseLighting = YES;

	// Shows the bounding volume. The boundingVolumePadding gives the boundary some depth
	// so that the emitter doesn't disappear if particles are still on-screen.
	emitter.boundingVolumePadding = 20.0;
	emitter.shouldDrawLocalContentWireframeBox = YES;
	emitter.shouldUseFixedBoundingVolume = NO;

	emitter.touchEnabled = YES;		// Shows the emitter name when touched
	
	// Set the location of the emitter, and optionally set it rotating for effect.
	emitter.location = cc3v(0.0, 150.0, kParticlesPerSide * kParticlesSpacing / 2.0f);
//	[emitter runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0.0, 15.0, 0.0)]];
	[self addChild: emitter];

//	[emitter emitParticles: emitter.maximumParticleCapacity];	// Uncomment to get them all out at once
	[emitter play];
}

/**
 * Adds a platform of 3D mesh particles to the scene, laid out in a grid, and hanging over
 * the back part of the ground. Each particle is displayed in a different color, and the
 * entire platform can be rotated.
 *
 * Each particle is a small mesh cube. You can play with the settings below to understand
 * how mesh particles behave.
 */
-(void) addMeshParticles {

	#define kMeshParticleCubeExtent 10.0f
	CC3BoxNode* templateModel = [CC3BoxNode nodeWithName: kTexturedCubeName];
	[templateModel populateAsSolidBox: CC3BoxMake(-kMeshParticleCubeExtent,
														  -kMeshParticleCubeExtent, 
														  -kMeshParticleCubeExtent,
														   kMeshParticleCubeExtent,
														   kMeshParticleCubeExtent,
														   kMeshParticleCubeExtent)];
	// We get fancy here for the sake of it!
	// The texture file is actually a composite of two textures. We're only interested in the
	// bottom part of the texture, so we assign a texture rectangle to the template mesh.
	// Each HangingMeshParticle also assigns itself a smaller texture rectangle within the
	// texture rectangle of this template mesh. This demonstrates that particles can nest
	// an individual texture rectangle within the texture rectangle of the tempalte mesh.
	templateModel.texture = [CC3Texture textureFromFile: kMeshParticleTextureFile];
	templateModel.textureRectangle = CGRectMake(0, 0, 1, 0.75);
	
	// Set up the emitter for 1000 particle, each an instance of the HangingParticle class.
	// Each particle has an individual location, color, size, and normal vector so that it
	// interacts with light sources. You can change this parameter to see different options.
	CC3MeshParticleEmitter* emitter = [CC3MeshParticleEmitter nodeWithName: @"Particles"];
	emitter.particleClass = [HangingMeshParticle class];
	emitter.particleTemplate = templateModel;
	emitter.maximumParticleCapacity = 1000;
	emitter.vertexContentTypes = kCC3VertexContentLocation |
								 kCC3VertexContentNormal |
								 kCC3VertexContentTextureCoordinates;
	
	// Set the emission characteristics
//	emitter.texture = [CC3Texture textureFromFile: kCubeTextureFile];
	emitter.emissionInterval = 0.01;
	
	// You can play with the following depth and blending parameters to see the effects
//	emitter.shouldDisableDepthTest = YES;
//	emitter.shouldDisableDepthMask = NO;
//	emitter.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
//	emitter.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};	// Additive particles
	
	// Uncomment to see effect of not using lighting.
	// Can also get same effect by not including kCC3VertexContentNormal in particle content above.
//	emitter.shouldUseLighting = NO;
//	emitter.emissionColor = kCCC4FWhite;
	
	// Shows the bounding volume. The boundingVolumePadding gives the boundary some depth
	// so that the emitter doesn't disappear if particles are still on-screen.
	emitter.boundingVolumePadding = 20.0;
	emitter.shouldDrawLocalContentWireframeBox = YES;
	emitter.shouldUseFixedBoundingVolume = NO;
	
	emitter.touchEnabled = YES;		// Shows the emitter name when touched
	
	// Set the location of the emitter, and optionally set it rotating for effect.
	emitter.location = cc3v(0.0, 150.0, kParticlesPerSide * kParticlesSpacing / 2.0f);
//	[emitter runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0.0, 15.0, 0.0)]];
	[self addChild: emitter];
	
//	[emitter emitParticles: emitter.maximumParticleCapacity];	// Uncomment to get them all out at once
	[emitter play];
}

/**
 * Adds a point particle emitter, that emits particles as if from a hose, to the end of the robot arm.
 * The emitter is started and paused by touching the robot arm.
 */
-(void) addPointHose {
	// Set up the emitter for CC3UniformlyEvolvingPointParticle particles. This specialized emitter
	// already comes with an appropriate particleNavigator and particleClass, which we do not need
	// to change for this usage. We don't need to set up a maxiumum capacity, because this emitter
	// reaches steady-state around 350 particles Each particle has an individual location, color
	// and size, but have no normal, so they do not interact with lighting. You can change this
	// property to see different options.
	CC3VariegatedPointParticleHoseEmitter* emitter = [CC3VariegatedPointParticleHoseEmitter nodeWithName: kPointHoseEmitterName];
	emitter.vertexContentTypes = kCC3VertexContentLocation |
								 kCC3VertexContentColor |
								 kCC3VertexContentPointSize;
	
	// Set the emission characteristics
	emitter.texture = [CC3Texture textureFromFile: kPointParticleTextureFile];
	emitter.emissionRate = 100.0f;			// Per second
	
	// Combination of particleSize and unity scale distance determine visible size
	// of each particle relative to the distance from the particle to the camera.
	emitter.unityScaleDistance = 200.0;

	// Optionally, set up for additive blending to create bright fire effect,
	// by uncommenting second line.
	emitter.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
//	emitter.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
	
	// Point particles assume lighting will not be used by default.
	// To see the effect of lighting on the particles, uncomment the following line.
//	emitter.shouldUseLighting = YES;
	
	// The boundingVolumePadding gives the boundary some depth so that the emitter doesn't
	// disappear if particles are still on-screen.
	emitter.boundingVolumePadding = 20.0;

	// Change this to YES to make boundary visible, and watch it change as the particles move around.
	emitter.shouldDrawLocalContentWireframeBox = NO;

	// By default, the bounding volume of the emitter is calculated dynamically as the particles
	// move around. You can avoid having to calculate the bounding volume on each frame, and
	// improve performance (a little bit), by setting a fixed boundary. To see the effect,
	// uncomment the following lines. The boundary below was determined by running with a
	// dynamic boundary and setting the shouldMaximize property of the bounding volume to YES
	// in order to determine the maximum range of the particles.
//	emitter.shouldUseFixedBoundingVolume = YES;
//	CC3NodeSphereThenBoxBoundingVolume* bv = (CC3NodeSphereThenBoxBoundingVolume*)emitter.boundingVolume;
//	bv.sphericalBoundingVolume.radius = 900.0;
//	bv.boxBoundingVolume.boundingBox = CC3BoxMake(-659.821, -408.596, -657.981, 651.606, 806.223, 637.516);

	// Shows the emitter name and location when the particles are touched
	emitter.touchEnabled = YES;
	
	// We don't want the emitter's bounding volume (which will be quite large)
	// participating in any ray casting.
	emitter.shouldIgnoreRayIntersection = YES;

	// Configure the ranges for the beginning and ending particle size and color.
	emitter.minParticleStartingSize = 20.0f;
	emitter.maxParticleStartingSize = 40.0f;					// Starting at 20-40 pixels wide
	emitter.minParticleEndingSize = kCC3ParticleConstantSize;
	emitter.maxParticleEndingSize = kCC3ParticleConstantSize;	// Stay same size while alive
	emitter.minParticleStartingColor = kCCC4FDarkGray;
	emitter.maxParticleStartingColor = kCCC4FWhite;				// Mix of light colors
	emitter.minParticleEndingColor = kCC3ParticleFadeOut;
	emitter.maxParticleEndingColor = kCC3ParticleFadeOut;		// Fade out, but don't change color
	
	// Emitters can be assigned a particle navigator, which is responsible for configuring the life-cycle
	// and trajectory of the particle. A particle navigator is only involved in the initial configuration of the
	// particle. It does not interact with the particle once it has been emitted, unless the particle
	// accesses it directly. In this case, we establish a particle navigator to configure the starting
	// and ending state for the life-span, speed, size and color, to establish the evolution of the
	// particle throughout its life.
	CC3HoseParticleNavigator* particleNavigator = (CC3HoseParticleNavigator*)emitter.particleNavigator;
	particleNavigator.minParticleLifeSpan = 3.0f;
	particleNavigator.maxParticleLifeSpan = 4.0f;			// Each lives for 2-3 seconds
	particleNavigator.minParticleSpeed = 100.0f;
	particleNavigator.maxParticleSpeed = 200.0f;			// Travelling 100-200 units/second
	
	// Set the emitter to emit a thin stream. Since it's a small dispersion angle, the 
	// shouldPrecalculateNozzleTangents property will automatically be set to YES to avoid
	// performing two tanf function calls every time a particle is emitted.
	particleNavigator.dispersionAngle = CGSizeMake(10.0, 10.0);
	
	// Try a wider dispersion. This will automatically set the shouldPrecalculateNozzleTangents to NO.
//	particleNavigator.dispersionAngle = CGSizeMake(180.0, 180.0);
	
	// The hose navigator has a nozzle to direct the flow of the particles. The nozzle is actually
	// a CC3Node that can be located anywhere in the scene, can be attached to another node, and can
	// be oriented so as to to direct the stream of particles in a particular direction. In this case,
	// we'll place the hose navigator nozzle at the end of the robot arm so that it moves with the arm,
	// and point the nozzle out the end of the arm.
	CC3Node* nozzle = particleNavigator.nozzle;
	nozzle.location = cc3v( 0.0, 90.0, 0.0 );
	nozzle.rotation = cc3v( -90.0, 30.0, 0.0 );
	[[self getNodeNamed: kRobotTopArm] addChild: nozzle];
	
	// Add the emitter to the scene
	[self addChild: emitter];

	// To see the bounding volume of the emitter, set this shouldDrawBoundingVolume property to YES.
	// The bounding volume of most nodes contains both a spherical and bounding-box bounding volume
	// to optimize intersection testing. Touch the robot arm to see the bounding volume of the
	// particle emitter grow and shrink dynamically. Back the camera away to get the full effect.
	emitter.shouldDrawBoundingVolume = NO;
}

/**
 * Adds a mesh particle emitter, that emits particles as if from a hose, to the end of the robot arm.
 * The emitter is started and paused by touching the robot arm.
 */
-(void) addMeshHose {

	#define kPartMeshDim 3.0f
	
	// The template mesh node defines the mesh (and optionally the material) that is used
	// for each particle. Each particle is constucted as a transformed copy of the template mesh.
	// This particle emitter can have multiple template meshes, to allow more than one particle
	// shape. In this case, we create an emitter that emits both spheres and boxes.
	
	// Because an emitter draws all particles with a single GL draw call, both template meshes
	// must use the same texture. We create a single texture file that is a combination of
	// two textures, and assign a different textureRectangle to each template mesh. The particles
	// that use each mesh will inherit their texture rectangle. We can even assign an individual
	// texture rectangle to each particle (although that is not done in this example), to allow
	// each particle to use a different part of the textureRectangle assigned to the template mesh,
	// allowing each partile to appear to be textured individually.

	// Box template mesh
	CC3BoxNode* boxModel = [CC3BoxNode node];
	[boxModel populateAsSolidBox: CC3BoxMake(-kPartMeshDim, -kPartMeshDim, -kPartMeshDim,
													  kPartMeshDim, kPartMeshDim, kPartMeshDim)];
	boxModel.texture = [CC3Texture textureFromFile: kMeshParticleTextureFile];
	boxModel.textureRectangle = CGRectMake(0, 0, 1, 0.75);	// Bottom part of texture is box texture
	CC3Mesh* boxMesh = boxModel.mesh;

	// Sphere template mesh
	CC3MeshNode* ballModel = [CC3SphereNode node];
	[ballModel populateAsSphereWithRadius: (kPartMeshDim * 1.5) andTessellation: CC3TessellationMake(8, 7)];
	ballModel.texture = [CC3Texture textureFromFile: kMeshParticleTextureFile];
	ballModel.textureRectangle = CGRectMake(0, 0.75, 1, 0.25);	// Top part of texture is ball texture
	CC3Mesh* ballMesh = ballModel.mesh;
	
	// Set up the emitter to emit mesh particles of type CC3UniformlyEvolvingMeshParticle constructed as
	// copies of the particle template mesh. We don't need to set up a maxiumum capacity, because this
	// emitter reaches steady-state after a couple of hundred particles. We include color content type,
	// and set an alpha-blending function on the emitter material so that the particles can be faded.
	// We assign two separate template meshes. Each particle will be assigned one of these meshes at
	// random as it is emitted.
	CC3MultiTemplateMeshParticleEmitter* emitter = [CC3MultiTemplateMeshParticleEmitter nodeWithName: kMeshHoseEmitterName];
	emitter.vertexContentTypes = kCC3VertexContentLocation |
								 kCC3VertexContentNormal |
								 kCC3VertexContentColor |
								 kCC3VertexContentTextureCoordinates;
	emitter.particleClass = [RotatingFadingMeshParticle class];
	[emitter addParticleTemplateMesh: boxMesh];
	[emitter addParticleTemplateMesh: ballMesh];
	emitter.texture = [CC3Texture textureFromFile: kMeshParticleTextureFile];
	emitter.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
	
	// Set the emission characteristics
	emitter.emissionRate = 50.0f;				// Per second

	// The boundingVolumePadding gives the boundary some depth so that the emitter doesn't
	// disappear if particles are still on-screen.
	emitter.boundingVolumePadding = 20.0;
	
	// Change this to YES to make boundary visible, and watch it change as the particles move around.
	emitter.shouldDrawLocalContentWireframeBox = NO;
	
	// By default, the bounding volume of the emitter is calculated dynamically as the particles
	// move around. By using a fixed bounding volume, you can improve performance in two ways:
	// A fixed bounding volume avoids the need to have to calculate the bounding volume on each frame,
	// as the particles move around, and if the bounding volume is outside the camera's frustum,
	// the vertices of the paricles do not need to be transformed.
	// To see the effect, uncomment the following lines. The boundary below was determined by running
	// with a dynamic boundary and setting the shouldMaximize property of the bounding volume to YES
	// in order to determine the maximum range of the particles (and logging the result).
//	emitter.shouldUseFixedBoundingVolume = YES;
//	CC3NodeSphereThenBoxBoundingVolume* bv = (CC3NodeSphereThenBoxBoundingVolume*)emitter.boundingVolume;
//	bv.sphericalBoundingVolume.radius = 750.0;
//	bv.boxBoundingVolume.boundingBox = CC3BoxMake(-400.0, -100.0, -500.0, 500.0, 750.0, 500.0);
	
	// Even without a fixed bounding volume, you can still improve performance when the particles
	// are not in view of the camera by setting the following property to NO.
	// However, this can sometimes create a visually jarring effect when the particles come back
	// into view. See the notes of the shouldTransformUnseenParticles property for more info.
	emitter.shouldTransformUnseenParticles = YES;
	
	// Shows the emitter name and location when the particles are touched
	emitter.touchEnabled = YES;
	
	// We don't want the emitter's bounding volume (which will be quite large)
	// participating in any ray casting.
	emitter.shouldIgnoreRayIntersection = YES;
	
	// Emitters can be assigned a particle navigator, which is responsible for configuring the
	// life-cycle and trajectory of the particle. A particle navigator is only involved in the
	// initial configuration of the particle. It does not interact with the particle once it has
	// been emitted, unless the particle accesses it directly. In this case, we establish a particle
	// navigator to configure the starting and ending state for the life-span and speed, to establish
	// the evolution of the particle throughout its life.
	CC3HoseParticleNavigator* particleNavigator = [CC3HoseParticleNavigator navigator];
	particleNavigator.minParticleLifeSpan = 4.0f;
	particleNavigator.maxParticleLifeSpan = 6.0f;			// Each lives for a few seconds
	particleNavigator.minParticleSpeed = 50.0f;
	particleNavigator.maxParticleSpeed = 100.0f;			// Travelling units/second
	
	// Set the emitter to emit a thin stream. Since it's a small dispersion angle, the 
	// shouldPrecalculateNozzleTangents property will automatically be set to YES to avoid
	// performing two tanf function calls every time a particle is emitted.
	particleNavigator.dispersionAngle = CGSizeMake(10.0, 10.0);
	
	// Try a wider dispersion. This will automatically set the shouldPrecalculateNozzleTangents to NO.
//	particleNavigator.dispersionAngle = CGSizeMake(180.0, 180.0);
	
	// Assign the navigator to the emitter.
	emitter.particleNavigator = particleNavigator;
	
	// The hose navigator has a nozzle to direct the flow of the particles. The nozzle is actually
	// a CC3Node that can be located anywhere in the scene, can be attached to another node, and can
	// be oriented so as to to direct the stream of particles in a particular direction. In this case,
	// we'll place the hose navigator nozzle at the end of the robot arm so that it moves with the arm,
	// and point the nozzle out the end of the arm.
	CC3Node* nozzle = particleNavigator.nozzle;
	nozzle.location = cc3v( 0.0, 90.0, 0.0 );
	nozzle.rotation = cc3v( -90.0, 30.0, 0.0 );
	[[self getNodeNamed: kRobotTopArm] addChild: nozzle];
	
	// Add the emitter to the scene
	[self addChild: emitter];
	
	// To see the bounding volumes of the emitter, set the shouldDrawBoundingVolume to YES.
	// The bounding volume of most nodes contains both a spherical and bounding-box
	// bounding volume to optimize intersection testing. Touch the robot arm to see
	// the bounding volume of the particle emitter grow and shrink dynamically.
	// Use the joystick controls to back the camera away to get the full effect.
	emitter.shouldDrawBoundingVolume = NO;
}

/**
 * Adds a floating mask that uses a PowerVR PFX file to define a GLSL shader program for the
 * material. The material in the POD file references a PFX effect found in a PFX resource file.
 * The PFX effect applies two textures to the mask.
 * 
 * When running under OpenGL ES 2.0, specialized shaders defined in the PFX effect render the
 * second texture as an environment reflection.
 *
 * When running under OpenGL ES 1.1, only the second texture is visible, due to the default
 * multi-texturing configuration. Under OpenGL ES 1.1, further texture unit configuration
 * could be applied to allow the two textures to be combined in a more realistic manner.
 *
 * This example also demonstrates the ability to define within a shader a customized uniform
 * variable, that does not have a semantic mapping to content  within the environment, and have
 * the application set the value of such a uniform variable directly.
 */
-(void) addReflectiveMask {

	// To show it is possible to load PFX files from other directories, we copy the POD and
	// PFX and texture files to the application Document directory. Actually, by this time,
	// the PFX file has already been loaded in the preloadAssets method, so to have this work,
	// you need to comment out the line in the preloadAssets method that preloads the
	// kReflectivePFXFile PFX file.
	[self copyResourceToDocuments: kReflectiveMaskPODFile];
	[self copyResourceToDocuments: kReflectivePFXFile];
	[self copyResourceToDocuments: @"BrushedSteel.png"];
	[self copyResourceToDocuments: @"tex_base.bmp"];	// Not really needed, but referenced in the POD file
	NSString* docDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* podPath = [docDir stringByAppendingPathComponent: kReflectiveMaskPODFile];
	CC3ResourceNode* podRezNode = [CC3PODResourceNode nodeFromFile: podPath];
	CC3MeshNode* mask = [podRezNode getMeshNodeNamed: @"maskmain"];
	
	// The mask animation locates the mask at a distant location and scale. Wrap it in a holder
	// to move it to a more convenient location and scale. Remember that the location of the mask
	// within the holder (and therefore the required offset) scales as the holder scales!!
	CC3Node* maskHolder = [mask asOrientingWrapper];
	maskHolder.uniformScale = 4.0;
	CC3Vector maskOffset = CC3VectorScaleUniform(mask.location, maskHolder.uniformScale);
	maskHolder.location = CC3VectorDifference(cc3v(-750.0, 100.0, -500.0), maskOffset);

	// Mask is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: maskHolder andMaterializeWithDuration: kFadeInDuration];
	[self addChild: maskHolder];
	
	// The vertex shader defines a uniform named "CustomMatrix" which uses an app-supplied
	// 4x4 matrix to adjust the position of the vertices. This "CustomMatrix" does not map
	// to a standard semantic, so it must be populated directly by the application, or use
	// a default value. Setting the uniform directly is done by creating an override uniform
	// on the shader context of a specific mesh node. Each node can set a different value for
	// the customized variable. This technique can also be used to override the value of a
	// uniform variable whose content can actually be retrieved from the environment.
	// Alternately, the shader program can use a default value for the uniform. By default,
	// this is disabled, but can be enabled by setting the shouldAllowDefaultVariableValues
	// property to YES. Since this app uses picking nodes from touch events, the property must
	// also be enabled in both the shader program and the pure color shader program used for
	// picking nodes. To use a default value instead, comment out the first four lines here,
	// and uncomment the last two.
	CC3GLSLUniform* progUniform = [mask.shaderContext uniformOverrideNamed: @"CustomMatrix"];
	CC3Matrix4x4 customMtx;
	CC3Matrix4x4PopulateIdentity(&customMtx);	// Could be any matrix...but just make it an identity
	progUniform.matrix4x4 = &customMtx;
//	mask.shaderProgram.shouldAllowDefaultVariableValues = YES;
//	mask.shaderContext.pureColorProgram.shouldAllowDefaultVariableValues = YES;

	// Make the mask touchable and animate it.
	mask.touchEnabled = YES;
	[mask runAction: [[CC3ActionAnimate actionWithDuration: 10.0] repeatForever]];
}

/**
 * Adds a floating mask that uses two textures to create a tangent-space bump-mapped surface
 * when running under OpenGL ES 2.0.
 *
 * When running under OpenGL ES 1.1, only the second (base) texture is visible, due to default
 * multi-texturing configuration.
 *
 * Two techniques for applying bump-mapping GLSL shaders are provided here, and each can be
 * selected by selectively commenting out code in this method. By default, this method applies
 * the bump-map and visible textures to the mask and allows the default tanget-space bump-map
 * shaders to be applied to the mask.
 *
 * Alternately, you can apply the textures and specific shaders to the mask by applying a
 * PowerVR PFX file to determine apply the textures and shaders. The shaders assigned in the
 * PFX file are different than the default bump-map shaders, and the mask will look different.
 */
-(void) addEtchedMask {
	CC3ResourceNode* podRezNode = [CC3PODResourceNode nodeFromFile: kEtchedMaskPODFile];
	CC3MeshNode* mask = [podRezNode getMeshNodeNamed: @"objmaskmain"];
	
	// Load the textures into the material (bump-mapped texture first), and allow the default shaders
	// to perform the bump-mapping. The default shaders include lighting and material coloring,
	// and so are more realistic than the shaders defined in the PFX file.
	[mask addTexture: [CC3Texture textureFromFile: @"NormalMap.png"]];
	[mask addTexture: [CC3Texture textureFromFile: @"BaseTex.png"]];
	
	// Alternately, you can apply a PFX effect to the mask node. This will attach the GL program and
	// texture defined in the PFX effect file, which will run shaders dedicated to tangent-space
	// bump-mapping. The shaders in the PFX file are simpler than the default shaders and do not
	// interact with material and lighting as effectively, and are therefore not as accurate.
	// To load the PFX file, uncomment the following line.
//	[mask applyEffectNamed: kEtchedMaskPFXEffect inPFXResourceFile: kEtchedPFXFile];
	
	mask.uniformScale = 4.0;
	mask.location = cc3v(-750.0, 50.0, -500.0);
	
	// Mask is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: mask andMaterializeWithDuration: kFadeInDuration];
	[self addChild: mask];
	
	// Make the mask touchable and animate it.
	mask.touchEnabled = YES;
	[mask runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0.0, 30.0, 0.0)]];
}

/**
 * Adds a dragon flying in a circular path above the scene.
 *
 * When first seen, the dragon is flying by flapping its wings. Touching the dragon causes it
 * to start gliding. Touching it again causes it to go back to flapping. The transition between
 * flapping and gliding occurs smoothly, regardless of when the dragon is touched.
 *
 * Flapping and gliding are handled by two separate tracks of animation, and the transition
 * is done by animating the relative blending weights beween the two tracks by using an
 * animation cross-fade action. Animated cross-fading ensures a smooth transition between
 * the distinct animations, regardless of where in each animation cycle it is started.
 * Try touching the dragon when its wings are at the top of the flap, or the bottom of the
 * flap. Either way, the transition to the gliding animation is smoothly blended.
 *
 * The dragon model was created in Blender by Aleksandra Sebastian, and is available on
 * Blend Swap at http://www.blendswap.com/blends/view/67196. It is used here under a
 * Creative Commons Attribution 3.0 CC-BY license, requiring attribution to the author.
 * All animation was added to the model after acquisition. The animated and modified
 * Blender model is available in the Models folder of the Cocos3D distribution.
 * The dragon POD file was created by exporting directly to POD from within Blender.
 */
-(void) addDragon {
	CC3ResourceNode* dgnRez = [CC3PODResourceNode nodeFromFile: @"Dragon.pod"];
	_dragon = [dgnRez getNodeNamed: @"Dragon.pod-SoftBody"];
	_dragon.touchEnabled = YES;
	
	// The bones of the dragon are fairly self-contained, and do not move beyond the sphere
	// that encompasses the mesh rest pose. Because of this, we can let the dragon skin mesh
	// node create its own spherical bounding volume. We then use that same bounding volume
	// for the other skinned mesh nodes within the dragon model (ie- the mouth), by using the
	// setSkeletalBoundingVolume: method on the entire model.
	// If you want to see this bounding volume, uncomment the third line below.
	CC3MeshNode* dgnBody = [_dragon getMeshNodeNamed: @"Dragon"];
	[dgnBody createBoundingVolume];
//	dgnBody.shouldDrawBoundingVolume = YES;
	[_dragon setSkeletalBoundingVolume: dgnBody.boundingVolume];

	// Ensure the bones in the dragon are rigid (no scale applied). Doing this allows the
	// shader program that is optimized for that to be automatically selected for the skinned
	// mesh nodes in the dragon. Many more active bones are possible with a rigid skeleton.
	// The model must be designed as a rigid model, otherwise it won't animate correctly.
	[_dragon ensureRigidSkeleton];

#if !CC3_GLSL
	// The fixed pipeline of OpenGL ES 1.1 cannot make use of the tangent-space normal
	// mapping texture that is applied to the dragon, and the result is that the dragon
	// looks black. Extract the diffuse texture (from texture unit 1), remove all texture,
	// and set the diffuse texture as the only texture (in texture unit 0).
	CC3Material* dgnMat = dgnBody.material;
	CC3Texture* dgnTex = [dgnMat textureForTextureUnit: 1];
	[dgnMat removeAllTextures];
	dgnMat.texture = dgnTex;
#endif
	
	// The model animation that was loaded from the POD into track zero is a concatenation of
	// several separate movements, such as gliding and flapping. Extract the distinct movements
	// from the base animation and add those distinct movement animations as separate tracks.
	_dragonGlideTrack = [_dragon addAnimationFromFrame: 0 toFrame: 60];
	_dragonFlapTrack = [_dragon addAnimationFromFrame: 61 toFrame: 108];
	
	// The dragon model now contains three animation tracks: a gliding track, a flapping track,
	// and the original concatenation of animation loaded from the POD file into track zero.
	// Any of these tracks can be played or blended by adjusting the relative weightings of each
	// track. We want to start with the dragon flying and flapping its wings. So, we give the
	// flapping track a weight of one, and the gliding and original tracks a weighting of zero.
	// In general, once the movement tracks have been created, you will set track zero, containing
	// the original animation concatenation, to a weighting of zero, and leave it there.
	[_dragon setAnimationBlendingWeight: 0.0f onTrack: 0];
	[_dragon setAnimationBlendingWeight: 0.0f onTrack: _dragonGlideTrack];
	[_dragon setAnimationBlendingWeight: 1.0f onTrack: _dragonFlapTrack];
	
	// Now create an animate action to actually run the flapping animation, and make it repeat
	// in a loop. We give it a known tag so that we can identify it to stop it later, after
	// we transition to a different movement.
	CCAction* flapping = [[CC3ActionAnimate actionWithDuration: 1.5 onTrack: _dragonFlapTrack] repeatForever];
	flapping.tag = kFlappingActionTag;
	[_dragon runAction: flapping];
	_dragonMotion = kDragonFlapping;	// Keep track of which animation is currently active
	
	// Add the dragon to a wrapper node that can be rotated to make the dragon fly in a circular
	// path. Locate the dragon up and away from the point of rotation of the wrapper, and rotate
	// the dragon itself within the wrapper, to make it face the direction of rotation, which is
	// the direction it is flying. Then add the flight path wrapper to the scene.
	CC3Node* flightPath = [_dragon asOrientingWrapper];
	_dragon.location = cc3v(0, 500, 1300);
	_dragon.rotation = cc3v(0, -90, 15);
	_dragon.uniformScale = 5.0;
	[flightPath runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(0, -15, 0)]];

	// Dragon is added on on background thread. Configure it for the scene, and fade it in slowly.
	[self configureForScene: _dragon andMaterializeWithDuration: kFadeInDuration];
	[self addChild: flightPath];
}

/**
 * Adds a temporary fiery explosion on top of the specified node, using a Cocos2D
 * CCParticleSystem. The explosion is set to a short duration, and when the particle
 * system has exhausted, the CC3ParticleSystem node along with the CCParticleSystem
 * billboard it contains are automatically removed from the 3D scene.
 */
-(void) addExplosionTo: (CC3Node*) aNode {
	// Create the particle emitter with a finite duration, and set it to auto-remove
	// once it is exhausted.
	CCParticleSystem* emitter = [CCParticleFire node];
	emitter.position = ccp(0.0, 0.0);
	emitter.duration = 0.75;
	emitter.autoRemoveOnFinish = YES;
	
	// Create the 3D billboard node to hold the 2D particle emitter.
	// The bounding volume is removed so that the flames will not be culled as the
	// camera pans away from the flames. This is suitable since the particle system
	// only exists for a short duration.
	CC3ParticleSystemBillboard* bb = [CC3ParticleSystemBillboard nodeWithName: kExplosionName
																withBillboard: emitter];
	
	// A billboard can be drawn either as part of the 3D scene, or as an overlay
	// above the 3D scene. By commenting out one of the following sections of code,
	// you can choose which method to use.
	
	// 1) In the 3D scene.
	// The following lines wrap the emitter billboard in a wrapper that will find
	// and track the camera in 3D. The flames can be occluded by other nodes between
	// the explosion and the camera.

	bb.uniformScale = 0.25 * (1.0 / aNode.uniformScale);	// Find a suitable scale
	bb.shouldInheritTouchability = NO;						// Don't allow flames to be touched

	// If the 2D particle system uses point particles instead of quads, attenuate the
	// particle sizes with distance realistically. This is not needed if the particle
	// system will always use quads, but it doesn't hurt to set it.
	bb.particleSizeAttenuation = CC3AttenuationCoefficientsMake(0.05, 0.02, 0.0001);
	
	// 2D particle systems do not have a real contentSize and boundingBox, so we need to
	// calculate it dynamically on each update pass, or assign one that will cover the
	// area that will be used by this particular particle system. This bounding rectangle
	// is specified in terms of the local coordinate system of the particle system and
	// will be scaled and transformed as the node is transformed. By setting this once,
	// we don't need to calculate it while running the particle system.
	// To calculate it dynamically on each update instead, comment out the following line,
	// and uncomment the line after. And also uncomment the third line to see the bounding
	// box drawn and updated on each frame.
	bb.billboardBoundingRect = CGRectMake(-90.0, -50.0, 190.0, 340.0);
//	bb.shouldAlwaysMeasureBillboardBoundingRect = YES;
//	bb.shouldDrawLocalContentWireframeBox = YES;

	// How did we determine the billboardBoundingRect? This can be done by trial and
	// error, by uncommenting culling logging in the CC3Billboard doesIntersectBoundingVolume:
	// method. Or it is better done by changing LogTrace to LogDebug in the CC3Billboard
	// billboardBoundingRect property accessor method, commenting out the line above this
	// comment, and uncommenting the following line. Doing so will cause an ever expanding
	// bounding box to be logged, the maximum size of which can be used as the value to
	// set in the billboardBoundingRect property.
//	bb.shouldMaximizeBillboardBoundingRect = YES;

	// We want to locate the explosion between the node and the camera, so that it
	// appears to engulf the node. To do this, wrap the billboard in an orientating
	// wrapper, give the explosion a location offset, and make the wrapper track
	// the camera. This will keep the explosion between the node and the camera,
	// regardless of where they are.
	// If we didn't need the locational offset to place the explosion in front
	// of the camera, we could have the billboard itself track the camera
	// using the shouldAutotargetCamera property of the billboard itself.
	bb.location = cc3v(0.0, 0.0, 0.5);
	[aNode addChild: [bb asCameraTrackingWrapper]];

	// 2) Overlaid above the 3D scene.
	// The following lines add the emitter billboard as a 2D overlay that draws above
	// the 3D scene. The flames will not be occluded by any other 3D nodes.
	// Comment out the lines in section (1) just above, and uncomment the following lines:
//	emitter.positionType = kCCPositionTypeGrouped;
//	bb.shouldDrawAs2DOverlay = YES;
//	bb.unityScaleDistance = 180.0;
//	[aNode addChild: bb];
}


#pragma mark Drawing

/**
 * This scene has custom drawing requirements, perfoming multiple passes, based on user interaction.
 *
 * The depth buffer is optionally cleared before rendering, based on whether a secondary
 * CC3Layer and CC3Scene is being displayed on top of this scene.
 *
 * If the user has turned on the TV in the scene, we render one pass of the scene from the
 * point of view of the camera that travels with the runners into a texture that is then
 * displayed on the TV screen during the main scene rendering pass.
 *
 * If the user has selected one of the post-processing options via the lighting button, the 
 * primary rendering pass is rendered to a texture, which is then presented to the view surface
 * as a quad via a single-node rendering pass.
 */
-(void) drawSceneContentWithVisitor: (CC3NodeDrawingVisitor*) visitor {

	// If the main CC3DemoMashUpLayer is currently displaying the secondary HUD view,
	// we need to clear the depth buffer before rendering the scene. If the HUD is not
	// currently displayed, we won't bother, because clearing the depth buffer is expensive.
	CC3DemoMashUpLayer* layer = self.primaryCC3DemoMashUpLayer;		// Create strong reference to weak property
	if (layer.isShowingHUD) { [visitor.renderSurface clearDepthContent]; }

	[self illuminateWithVisitor: visitor];			// Light up your world!
	
	// If the TV is on and the TV is in the field of view of the primary camera viewing
	// the scene, draw the scene to the TV screen.
	if (_isTVOn && [_tvScreen doesIntersectFrustum: visitor.camera.frustum]) [self drawToTVScreen];
	
	// As a pre-processing pass, if the reflective metal teapot is visible, generate an
	// environment-map cube-map texture for it by taking snapshots of the scene in all
	// six axis directions from its position.
	[self generateTeapotEnvironmentMapWithVisitor: visitor];

	// When post-processing, we render to a temporary off-screen surface.
	// We remember the original surface in this variable.
	id<CC3RenderSurface> origSurface;
	
	// If we are post-processing the rendered scene image, draw to an off-screen surface,
	// clearing it first. Otherwise, draw to view surface directly, without clearing because
	// it was done at the beginning of the rendering cycle.
	if (self.isPostProcessing) {
		origSurface = visitor.renderSurface;
		visitor.renderSurface = _postProcSurface;
		[_postProcSurface clearColorAndDepthContent];
	}
	
	[self drawBackdropWithVisitor: visitor];	// Draw the backdrop if it exists
	[visitor visit: self];						// Draw the scene components
	
	// Shadows are drawn with a specialized visitor
	[self.shadowVisitor alignShotWith: visitor];
	[self drawShadowsWithVisitor: self.shadowVisitor];

	// If we are post-processing the rendered scene image, draw the appropriate off-screen
	// surface to the view surface.
	if (self.isPostProcessing) {
		// If the layer is not full-screen, rendering the layer again will further reduce
		// its shape. To compensate, temporarily clear the camera viewport so that it will
		// be set to the size of the surface when the surface is attached to the visitor
		// so that it draws the post-processed image to the entire view surface.
		CC3Viewport vvp = visitor.camera.viewport;
		visitor.camera.viewport = kCC3ViewportZero;
		
		visitor.renderSurface = origSurface;		// Ensure drawing to the original surface
		[visitor visit: self.postProcessingNode];

		visitor.camera.viewport = vvp;		// Now set the viewport back to the layer's size.
	}
}

/**
 * When drawing an environment map, don't bother with shadows, avoid all the post-rendering
 * processing, don't redraw the TV. And avoid an infinitely recursive issue where rendering
 * the scene for the texture triggers a recursive nested scene render!
 */
-(void) drawSceneContentForEnvironmentMapWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor.renderSurface clearColorAndDepthContent];
	[self drawBackdropWithVisitor: visitor];	// Draw the backdrop if it exists
	[visitor visit: self];						// Draw the scene components
}

/**
 * Draws the scene from the runners' camera perspective to the TV screen.
 *
 * The drawing is performed by a dedicated drawing visitor that contains its own camera
 * in the same location as the camera loaded with the runners. A dedicated camera is used
 * because the aspect of the TV screen (HDTV) is different than the main scene view.
 */
-(void) drawToTVScreen {
	LogTrace(@"Drawing to TV");

	[_tvDrawingVisitor.renderSurface clearColorAndDepthContent];	// Clear color & depth of TV surface.
	[self drawBackdropWithVisitor: _tvDrawingVisitor];				// Draw the backdrop if it exists
	[_tvDrawingVisitor visit: self];								// Draw the scene components
	
	[self pictureInPicture];		// Add a small PiP image in the bottom right of the TV screen
}

/**
 * Adds a small picture-in-picture window in the TV screen by directly changing the TV screen texture.
 *
 * This is done by copying a rectangle of pixels from the rendering surface used to render
 * the TV image, and then pasting them into a different location in the surface. Along the
 * way, a border is added to the PiP image by directly setting pixel values.
 */
-(void) pictureInPicture {
	// Define the source and destination rectangles within the surface
	CC3IntSize pipSize = CC3IntSizeMake(kTVScale * 2, kTVScale * 2);
	CC3IntPoint pipSrcOrg = CC3IntPointMake((10 * kTVScale), (5 * kTVScale));
	CC3IntPoint pipDstOrg = CC3IntPointMake((13.5 * kTVScale), (0.5 * kTVScale));
	CC3Viewport pipSrc = CC3ViewportFromOriginAndSize(pipSrcOrg, pipSize);
	CC3Viewport pipDst = CC3ViewportFromOriginAndSize(pipDstOrg, pipSize);
	
	// Allocate a temporary array to hold the extracted image content
	ccColor4B colorArray[pipSize.width * pipSize.height];
	
	// Copy a rectangle of image content from the surface, add the border,
	// and paste it to a different location on the surface.
	[self.tvSurface readColorContentFrom: pipSrc into: colorArray];
	[self addBorderToImage: colorArray ofSize: pipSize];
	[self.tvSurface replaceColorPixels: pipDst withContent: colorArray];
}

/** 
 * Adds a border around the specified image array, which is of the specified rectangular size.
 *
 * Content in the specified image array is ordered from left to right across each row of
 * pixels, starting the row at the bottom, and ending at the row at the top.
 */
-(void) addBorderToImage: (ccColor4B*) colorArray ofSize: (CC3IntSize) imgSize {
	ccColor4B borderColor = ccc4(128, 0, 0, 255);

	// Add the top and bottom borders
	GLuint topRowStart = imgSize.width * (imgSize.height - 1);
	for (GLuint colIdx = 0; colIdx < imgSize.width; colIdx++) {
		colorArray[colIdx] = borderColor;					// Bottom row
		colorArray[topRowStart + colIdx] = borderColor;		// First row
	}
	
	// Add the left and right borders
	for (GLuint rowIdx = 0; rowIdx < imgSize.height; rowIdx++) {
		colorArray[imgSize.width * rowIdx] = borderColor;				// First column in row
		colorArray[imgSize.width * (rowIdx + 1) - 1] = borderColor;		// Last column in row
	}
}

/** Returns whether post-processing of the scene view is active. */
-(BOOL) isPostProcessing {
	switch (_lightingType) {
		case kLightingFog:
			return CC3_GLSL;		// Fog is performed as a post-processing if shaders are available
		case kLightingGrayscale:
			return YES;
		case kLightingDepth:
			return YES;
		default:
			return NO;
	}
}

/** Returns the appropriate full-screen rendering node for the current lighting conditions. */
-(CC3MeshNode*) postProcessingNode {
	switch (_lightingType) {
		case kLightingFog:
			return _fog;
		case kLightingGrayscale:
			return _grayscaleNode;
		case kLightingDepth:
			return _depthImageNode;
		default:
			return nil;
	}
}

/** 
 * If we're not already in the middle of generating an environment map, and the reflective metal
 * teapot is visible, generate an environment-map cube-map texture for it by taking snapshots of
 * the scene in all six axis directions from its position. We don't want the teapot to
 * self-reflect, so we make it invisible while we are rendering the scene from the teapot's center.
 */
-(void) generateTeapotEnvironmentMapWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (visitor.isDrawingEnvironmentMap ||
		![_teapotTextured doesIntersectFrustum: visitor.camera.frustum] ) return;

	BOOL isVis = _teapotTextured.visible;
	_teapotTextured.visible = NO;			// Hide the teapot from itself
	[_envMapTex generateSnapshotOfScene: self
					 fromGlobalLocation: _teapotTextured.globalCenterOfGeometry];
	_teapotTextured.visible = isVis;
}


#pragma mark Updating and user interactions

/**
 * This method is invoked when the scene is opened within the layer (or when the
 * scene is added to an existing running layer). We can use this method to perform
 * set-up that depends on the layer being attached and sized, such as camera actions
 * that require the dimensions of the viewport to be established.
 *
 * During development, we can use this opportunity to move the camera to view the
 * entire scene, or some section of the scene, in order to troubleshoot the scene.
 */
-(void) onOpen {

	// Add post-processing capabilities, demonstrating render-to-texture and post-rendering
	// image processing. This is performed here, rather than in initializeScene, so that
	// we can make the off-screen surfaces the same size as the view surface, which is not
	// available during initializeScene.
	[self addPostProcessing];
	
	// Adds fog to the scene. This is initially invisible.
	// This is performed here, rather than in initializeScene, because under OpenGL ES 2.0
	// and OpenGL OSX, fog is created as a post-processing effect, and so we need access to
	// the off-screen surfaces created in addPostProcessing.
	[self addFog];
	
	// Here, we add additional scene content dynamically and asynchronously on a background thread
	// using the CC3Backgrounder singleton. Asynchronous loading must be initiated after the scene
	// has been attached to the view, and should not be started in the initializeScene method.
	// When running on Android, background loading can cause threading conflicts within the GL engine,
	// depending on the device, and must be handled with extreme care. Because of this, if running
	// under Android, we turn background loading off here and the addSceneContentAsynchronously
	// method will run immediately on this thread, before further processing is performed.
#if APPORTABLE
	CC3Backgrounder.sharedBackgrounder.shouldRunTasksOnRequestingThread = YES;
#endif
	[CC3Backgrounder.sharedBackgrounder runBlock: ^{ [self addSceneContentAsynchronously]; }];

	// Uncomment the first line to have the camera move to show the entire scene.
	// Uncomment the second line to draw the bounding box of the scene.
//	[self.activeCamera moveWithDuration: kCameraMoveDuration toShowAllOf: self];
//	self.shouldDrawWireframeBox = YES;

	// Or uncomment this line to have the camera pan and zoom to focus on the Cocos3D mascot.
//	[self.activeCamera moveWithDuration: kCameraMoveDuration toShowAllOf: mascot];
}

/** 
 * Called periodically as part of the CCLayer scheduled update mechanism.
 * This is where model objects are updated.
 *
 * For this scene, the camera direction and location are updated
 * under control of the user interface, and the location of the white teapot that
 * indicates the direction of the light is updated as the light moves. All other motion
 * in the scene is handled by CCActions.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {

	[self updateCameraFromControls: visitor.deltaTime];
	
	// To show where the POD light is, track the small white teapot to the light location.
	_teapotWhite.location = _robotLamp.location;
 }

/** After all the nodes have been updated, check for collisions. */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self checkForCollisions];
}

/**
 * Check for collisions.
 *
 * Invoke the doesIntersectNode: method to determine whether the rainbow teapot has
 * collided with the brick wall.
 *
 * If the teapot is colliding with the wall, it may do so for several update frames.
 * On each frame, we need to determine whether it is heading towards the wall, or
 * away from it. If it's heading towards the wall we turn it around. If it's already
 * been turned around and is heading away from the wall, we let it continue.
 *
 * All movement is handled by CCActions.
 * 
 * The effect is to see the teapot collide with the wall, bounce off it,
 * and head the other way.
 */
-(void) checkForCollisions {
	
	// Test whether the rainbow teapot intersects the brick wall.
	if ( [_teapotSatellite doesIntersectNode: _brickWall] ) {

		// Get the direction from the teapot to the wall.
		CC3Vector tpDir = CC3VectorDifference(_brickWall.globalLocation, _teapotSatellite.globalLocation);		

		// If the teapot velocity is in the same direction as the vector from the
		// teapot to the wall, it is heading towards the wall. If so, turn it around
		// by getting the current spin action on the teapot holder and replacing it
		// with the reverse spin.
		if (CC3VectorDot(_teapotSatellite.velocity, tpDir) > 0.0f) {
			LogInfo(@"BANG! %@ hit %@", _teapotSatellite, _brickWall);
			
			// Get the current spinning action.
			CCAction* spinAction = [_teapotTextured getActionByTag: kTeapotRotationActionTag];
			
			// Reverse it and give it a tag so we can find it again.
			CCAction* revSpinAction = [spinAction reverse];
			revSpinAction.tag = kTeapotRotationActionTag;

			// Stop the old action and start the new one. 
			[_teapotTextured stopAction: spinAction];
			[_teapotTextured runAction: revSpinAction];
		}
	}
}

/** Update the location and direction of looking of the 3D camera */
-(void) updateCameraFromControls: (CCTime) dt {
	CC3Camera* cam = self.activeCamera;
	
	// Update the location of the player (the camera)
	if ( _playerLocationControl.x || _playerLocationControl.y ) {
		
		// Get the X-Y delta value of the control and scale it to something suitable
		CGPoint delta = ccpMult(_playerLocationControl, dt * 100.0);

		// We want to move the camera forward and backward, and side-to-side,
		// from the camera's (the user's) point of view.
		// Forward and backward will be along the globalForwardDirection of the camera,
		// and side-to-side will be along the globalRightDirection of the camera.
		// These two directions are scaled by Y and X delta components respectively, which
		// in turn are set by the joystick, and combined into a single directional vector.
		// This represents the movement of the camera. The new location is simply the old
		// camera location plus the movement.
		CC3Vector moveVector = CC3VectorAdd(CC3VectorScaleUniform(cam.globalRightDirection, delta.x),
											CC3VectorScaleUniform(cam.globalForwardDirection, delta.y));
		cam.location = CC3VectorAdd(cam.location, moveVector);
	}

	// Update the direction the camera is pointing by panning and inclining using rotation.
	if ( _playerDirectionControl.x || _playerDirectionControl.y ) {
		CGPoint delta = ccpMult(_playerDirectionControl, dt * 30.0);		// Factor to set speed of rotation.
		CC3Vector camRot = cam.rotation;
		camRot.y -= delta.x;
		camRot.x += delta.y;
		cam.rotation = camRot;	
	}
}

/**
 * When the user hits the switch-camera-target button, cycle through a series of four
 * different camera targets. The actual movement of the camera to home in on a new target
 * is handled by a CCActionInterval, so that the movement appears smooth and animated.
 */
-(void) switchCameraTarget {
	if (_camTarget == _origCamTarget)
		_camTarget = _globe;
	else if (_camTarget == _globe)
		_camTarget = _beachBall;
	else if (_camTarget == _beachBall)
		_camTarget = _teapotTextured;
	else if (_camTarget == _teapotTextured)
		_camTarget = _mascot;
	else if (_camTarget == _mascot)
		_camTarget = _floatingHead;
	else if (_camTarget == _floatingHead)
		_camTarget = _dieCube;
	else
		_camTarget = _origCamTarget;
	
	CC3Camera* cam = self.activeCamera;
	cam.target = nil;			// Ensure the camera is not locked to the original target
	[cam stopAllActions];
	[cam runAction: [CC3ActionRotateToLookAt actionWithDuration: 2.0 targetLocation: _camTarget.globalLocation]];
	LogInfo(@"Camera target toggled to %@", _camTarget);
}

/**
 * Launches an invasion of an army of robots...or removes them if they are here.
 * You can change the robots to teapots by swapping out the last commented line with the one above it.
 */
-(void) invade {
	LandingCraft* landingCraft = (LandingCraft*)[self getNodeNamed: kLandingCraftName];
	if (landingCraft) {
		[landingCraft evaporate];
	} else {
		[self invadeWithRobotArmy];
//		[self invadeWithTeapotArmy];	// Or if robot armies frighten you, invade with teapots instead.
	}
}

/** Create a landing craft and populate it with an army of robots. */
-(void) invadeWithRobotArmy {
	// First create a template node by copying the POD resource node.
	// We copy it so we can mofify it.
	// Remove the camera and light that it includes, and since the billboard
	// 2D CCNode can't easily be copied, we'll remove the billboard as well.
	CC3Node* robotTemplate = [[self getNodeNamed: kPODRobotRezNodeName] copy];
	[[robotTemplate getNodeNamed: kPODLightName] remove];
	[[robotTemplate getNodeNamed: kPODCameraName] remove];
	[[robotTemplate getNodeNamed: kBillboardName] remove];

	// In the original robot arm, each component is individually selectable.
	// For the army, we wont bother with this level of detail, and we'll just
	// select the whole assembly (actually the resource node) whenever any part
	// of the robot is touched. This is done by first removing the individual
	// enablement that we set on the original, and then just enabling the top level.
	[robotTemplate touchDisableAll];
	robotTemplate.touchEnabled = YES;

	// Make these robots smaller to distinguish them from the original
	robotTemplate.uniformScale = 0.5;
	
	[self invadeWithArmyOf: robotTemplate];
}

/** Create a landing craft and populate it with an army of teapots. */
-(void) invadeWithTeapotArmy {
	// First create a template node by copying the POD resource node.
	CC3Node* teapotTemplate = [[self getNodeNamed: kTeapotWhiteName] copy];
	teapotTemplate.uniformScale *= 3.0;

	[self invadeWithArmyOf: teapotTemplate];
}

/**
 * Invade with multiple copies of the specified template node. Instantiates a landing
 * craft and populates it with an army copied from the specified template node.
 */
-(void) invadeWithArmyOf: (CC3Node*) invaderTemplate {
	LandingCraft* landingCraft = [LandingCraft nodeWithName: kLandingCraftName];
	[landingCraft populateArmyWith: invaderTemplate];

	// We want to add the landing craft as a child of the ground when it lands.
	// But the ground has been rotated in two dimensions, and if we simply add the landing
	// craft as a child, it will be rotated along with the ground. The result will be that
	// the army will appear to land horizontally and be deployed vertically. However, adding
	// the landing craft to the ground, and locaizing it to the ground, will compensate for
	// the existing transformations that have been applied to the ground. The result will be
	// that the army will appear to land vertically and deploy horizontally, as expected.
	landingCraft.location = _ground.location;
	[_ground addAndLocalizeChild: landingCraft];
}

-(void) cycleLights {
	CC3Node* sun = [self getNodeNamed: kSunName];
	CC3Node* flashLight = [self getNodeNamed: kSpotlightName];

	// Cycle to the next lighting type, based on current lighting type
	switch (_lightingType) {
		case kLightingSun:
			_lightingType = kLightingFlashlight;
			break;
		case kLightingFlashlight:
#if CC3_OGLES_1
			_lightingType = kLightingFog;	// Light probes not supported in OpenGL ES 1
#else
			_lightingType = kLightingLightProbe;
#endif	// CC3_OGLES_1
			break;
		case kLightingLightProbe:
			_lightingType = kLightingFog;
			break;
		case kLightingFog:
#if CC3_OGLES_1
			_lightingType = kLightingSun;	// Depth-texture not supported in OpenGL ES 1
#else
			_lightingType = kLightingGrayscale;
#endif	// CC3_OGLES_1
			break;
		case kLightingGrayscale:
			_lightingType = kLightingDepth;
			break;
		case kLightingDepth:
			_lightingType = kLightingSun;
			break;
	}

	// Configure the scene for the new lighting conditions
	switch (_lightingType) {
		case kLightingSun:
			sun.visible = YES;
			_fog.visible = NO;
			_robotLamp.visible = YES;
			flashLight.visible = NO;
			_bumpMapLightTracker.target = _robotLamp;
			_backdrop.emissionColor = kSkyColor;
			self.shouldUseLightProbes = NO;
			break;
		case kLightingFlashlight:
			sun.visible = NO;
			_fog.visible = NO;
			_robotLamp.visible = NO;
			flashLight.visible = YES;
			_bumpMapLightTracker.target = flashLight;
			_backdrop.emissionColor = kCCC4FBlack;
			self.shouldUseLightProbes = NO;
			break;
		case kLightingLightProbe:
			sun.visible = NO;
			_fog.visible = NO;
			_robotLamp.visible = YES;
			flashLight.visible = NO;
			_bumpMapLightTracker.target = _robotLamp;
			_backdrop.emissionColor = kSkyColor;
			self.shouldUseLightProbes = YES;
			break;
		case kLightingFog:
			sun.visible = YES;
			_fog.visible = YES;
			_robotLamp.visible = YES;
			flashLight.visible = NO;
			_bumpMapLightTracker.target = _robotLamp;
			_backdrop.emissionColor = kSkyColor;
			self.shouldUseLightProbes = NO;
			break;
		case kLightingGrayscale:
			sun.visible = YES;
			_fog.visible = NO;
			_robotLamp.visible = YES;
			flashLight.visible = NO;
			_bumpMapLightTracker.target = _robotLamp;
			_backdrop.emissionColor = kSkyColor;
			self.shouldUseLightProbes = NO;
			break;
		case kLightingDepth:
			sun.visible = YES;
			_fog.visible = NO;
			_robotLamp.visible = YES;
			flashLight.visible = NO;
			_bumpMapLightTracker.target = _robotLamp;
			_backdrop.emissionColor = kSkyColor;
			self.shouldUseLightProbes = NO;
			break;
	}
}

/**
 * Cycle between current camera view and two views showing the complete scene.
 * When the full scene is showing, a wireframe is drawn so we can easily see its extent.
 */
-(void) cycleZoom {
	CC3Camera* cam = self.activeCamera;
	[cam stopAllActions];						// Stop any current camera motion
	switch (_cameraZoomType) {

		// Currently in normal view. Remember orientation of camera, turn on wireframe
		// and move away from the scene along the line between the center of the scene
		// and the camera until everything in the scene is visible.
		case kCameraZoomNone:
			_lastCameraOrientation = CC3RayFromLocDir(cam.globalLocation, cam.globalForwardDirection);
			self.shouldDrawWireframeBox = YES;
			[cam moveWithDuration: kCameraMoveDuration toShowAllOf: self];
			_cameraZoomType = kCameraZoomStraightBack;	// Mark new state
			break;
		
		// Currently looking at the full scene.
		// Move to view the scene from a different direction.
		case kCameraZoomStraightBack:
			self.shouldDrawWireframeBox = YES;
			[cam moveWithDuration: kCameraMoveDuration
					  toShowAllOf: self
					fromDirection: cc3v(-1.0, 1.0, 1.0)];
			_cameraZoomType = kCameraZoomBackTopRight;	// Mark new state
			break;

		// Currently in second full-scene view.
		// Turn off wireframe and move back to the original location and orientation.
		case kCameraZoomBackTopRight:
		default:
			self.shouldDrawDescriptor = NO;
			self.shouldDrawWireframeBox = NO;
			[cam runAction: [CC3ActionMoveTo actionWithDuration: kCameraMoveDuration
												   moveTo: _lastCameraOrientation.startLocation]];
			[cam runAction: [CC3ActionRotateToLookTowards actionWithDuration: kCameraMoveDuration
													  forwardDirection: _lastCameraOrientation.direction]];
			_cameraZoomType = kCameraZoomNone;	// Mark new state
			break;
	}
}


#pragma mark Gesture handling

-(void) startMovingCamera { _cameraMoveStartLocation = self.activeCamera.location; }

-(void) stopMovingCamera {}

/** Set this parameter to adjust the rate of camera movement during a pinch gesture. */
#define kCamPinchMovementUnit		250

-(void) moveCameraBy:  (CGFloat) aMovement {
	CC3Camera* cam = self.activeCamera;

	// Convert to a logarithmic scale, zero is backwards, one is unity, and above one is forward.
	GLfloat camMoveDist = logf(aMovement) * kCamPinchMovementUnit;

	CC3Vector moveVector = CC3VectorScaleUniform(cam.globalForwardDirection, camMoveDist);
	cam.location = CC3VectorAdd(_cameraMoveStartLocation, moveVector);
}

-(void) startPanningCamera { _cameraPanStartRotation = self.activeCamera.rotation; }

-(void) stopPanningCamera {}

-(void) panCameraBy:  (CGPoint) aMovement {
	CC3Vector camRot = _cameraPanStartRotation;
	CGPoint panRot = ccpMult(aMovement, 90);		// Full pan swipe is 90 degrees
	camRot.y += panRot.x;
	camRot.x -= panRot.y;
	self.activeCamera.rotation = camRot;
}

-(void) startDraggingAt: (CGPoint) touchPoint { [self pickNodeFromTapAt: touchPoint]; }

-(void) dragBy: (CGPoint) aMovement atVelocity: (CGPoint) aVelocity {
	if (_selectedNode == _dieCube || _selectedNode == _texCubeSpinner)
		[self rotate: ((SpinningNode*)_selectedNode) fromSwipeVelocity: aVelocity];
}

-(void) stopDragging { _selectedNode = nil; }

/** Set this parameter to adjust the rate of rotation from the length of swipe gesture. */
#define kSwipeVelocityScale		400

/**
 * Rotates the specified spinning node by setting its rotation axis
 * and spin speed from the specified 2D drag velocity.
 */
-(void) rotate: (SpinningNode*) aNode fromSwipeVelocity: (CGPoint) swipeVelocity {
	
	// The 2D rotation axis is perpendicular to the drag velocity.
	CGPoint axis2d = ccpPerp(swipeVelocity);
	
	// Project the 2D rotation axis into a 3D axis by mapping the 2D X & Y screen
	// coords to the camera's rightDirection and upDirection, respectively.
	CC3Camera* cam = self.activeCamera;
	aNode.spinAxis = CC3VectorAdd(CC3VectorScaleUniform(cam.rightDirection, axis2d.x),
								  CC3VectorScaleUniform(cam.upDirection, axis2d.y));

	// Set the spin speed from the scaled drag velocity.
	aNode.spinSpeed = ccpLength(swipeVelocity) * kSwipeVelocityScale;

	// Mark the spinning node as free-wheeling, so that it will start spinning.
	aNode.isFreeWheeling = YES;
}


#pragma mark Touch events

/**
 * Handle touch events in the scene:
 *   - Touch-down events are used to select nodes. Forward these to the touched node picker.
 *   - Touch-move events are used to generate a swipe gesture to rotate the die cube
 *   - Touch-up events are used to mark the die cube as freewheeling if the touch-up event
 *     occurred while the finger is moving.
 * This is a poor UI. We really should be using the touch-stationary event to mark definitively
 * whether the finger stopped before being lifted. But we're just working with what we have handy.
 *
 * If gestures are being used (see the setting of the touchEnabled property in the initializeControls
 * method of CC3DemoMashUpLayer), this method will not be invoked. Instead, the gestures invoke handler
 * methods on the CC3DemoMashUpLayer, which then issues higher-level control messages to this scene.
 *
 * It is generally recommended that you use gestures to provide user interaction with the 3D scene.
 */
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
	struct timeval now;
	gettimeofday(&now, NULL);

	// Time since last event
	CCTime dt = (now.tv_sec - _lastTouchEventTime.tv_sec) + (now.tv_usec - _lastTouchEventTime.tv_usec) / 1000000.0f;

	switch (touchType) {
		case kCCTouchBegan:
			[self pickNodeFromTouchEvent: touchType at: touchPoint];
			break;
		case kCCTouchMoved:
			if (_selectedNode == _dieCube || _selectedNode == _texCubeSpinner) {
				[self rotate: ((SpinningNode*)_selectedNode) fromSwipeAt: touchPoint interval: dt];
			}
			break;
		case kCCTouchEnded:
			if (_selectedNode == _dieCube || _selectedNode == _texCubeSpinner) {
				// If the user lifted the finger while in motion, let the cubes know
				// that they can freewheel now. But if the user paused before lifting
				// the finger, consider it stopped.
				((SpinningNode*)_selectedNode).isFreeWheeling = (dt < 0.5);
			}
			_selectedNode = nil;
			break;
		default:
			break;
	}
	
	// For all event types, remember when and where the touchpoint was, for subsequent events.
	_lastTouchEventPoint = touchPoint;
	_lastTouchEventTime = now;
}

/** Set this parameter to adjust the rate of rotation from the length of touch-move swipe. */
#define kSwipeScale 0.6

/**
 * Rotates the specified node, by determining the direction of each touch move event.
 *
 * The touch-move swipe is measured in 2D screen coordinates, which are mapped to
 * 3D coordinates by recognizing that the screen's X-coordinate maps to the camera's
 * rightDirection vector, and the screen's Y-coordinates maps to the camera's upDirection.
 *
 * The node rotates around an axis perpendicular to the swipe. The rotation angle is
 * determined by the length of the touch-move swipe.
 *
 * To allow freewheeling after the finger is lifted, we set the spin speed and spin axis
 * in the node. We indicate for now that the node is not freewheeling.
 */
-(void) rotate: (SpinningNode*) aNode fromSwipeAt: (CGPoint) touchPoint interval: (CCTime) dt {
	
	CC3Camera* cam = self.activeCamera;

	// Get the direction and length of the movement since the last touch move event, in
	// 2D screen coordinates. The 2D rotation axis is perpendicular to this movement.
	CGPoint swipe2d = ccpSub(touchPoint, _lastTouchEventPoint);
	CGPoint axis2d = ccpPerp(swipe2d);
	
	// Project the 2D axis into a 3D axis by mapping the 2D X & Y screen coords
	// to the camera's rightDirection and upDirection, respectively.
	CC3Vector axis = CC3VectorAdd(CC3VectorScaleUniform(cam.rightDirection, axis2d.x),
								  CC3VectorScaleUniform(cam.upDirection, axis2d.y));
	GLfloat angle = ccpLength(swipe2d) * kSwipeScale;

	// Rotate the cube under direct finger control, by directly rotating by the angle
	// and axis determined by the swipe. If the die cube is just to be directly controlled
	// by finger movement, and is not to freewheel, this is all we have to do.
	[aNode rotateByAngle: angle aroundAxis: axis];

	// To allow the cube to freewheel after lifting the finger, have the cube remember
	// the spin axis and spin speed. The spin speed is based on the angle rotated on
	// this event and the interval of time since the last event. Also mark that the
	// die cube is not freewheeling until the finger is lifted.
	aNode.isFreeWheeling = NO;
	aNode.spinAxis = axis;
	aNode.spinSpeed = angle / dt;
}

/** 
 * This callback method is automatically invoked when a touchable 3D node is picked
 * by the user. If the touch event indicates that the user has raised the finger,
 * thus completing the touch action.
 *
 * If the UI is in "managing shadows" mode, each touch of an object cycles through
 * various shadowing options for the touched node. If not in "managing shadows" mode,
 * the actions described here occur.
 *
 * Most nodes are simply temporarily highlighted by running a Cocos2D tinting action on
 * the emission color property of the node (which affects the emission color property of
 * the materials underlying the node).
 *
 * Some nodes have other, or additional, behaviour. Nodes with special behaviour include
 * the ground, the die cube, the beach ball, the textured and rainbow teapots, and the wooden sign.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {

	// If in "managing shadows" mode, cycle through a variety of shadowing techniques.
	if (_isManagingShadows) {
		[self cycleShadowFor: aNode];
		return;
	}
	
	// Remember the node that was selected
	_selectedNode = aNode;
	
	// Uncomment to toggle the display of a descriptor label on the node
//	aNode.shouldDrawDescriptor = !aNode.shouldDrawDescriptor;

	// Briefly highlight the location where the node was touched.
	[self markTouchPoint: touchPoint on: aNode];
	
	if (!aNode) return;

	if (aNode == _ground) {
		[self touchGroundAt: touchPoint];
	} else if (aNode == _beachBall) {
		[self touchBeachBallAt: touchPoint];
	} else if (aNode == _brickWall) {
		[self touchBrickWallAt: touchPoint];
	} else if (aNode == _woodenSign) {
		[self switchWoodenSign];
	} else if (aNode == _floatingHead) {
		[self toggleFloatingHeadConfiguration];
	} else if (aNode == _dieCube || aNode == _texCubeSpinner) {
		// These are spun by touch movement. Do nothing...and don't highlight
	} else if (aNode == [self getNodeNamed: kRunnerName]) {
		[self toggleActiveCamera];
	} else if (aNode == [self getNodeNamed: kLittleBrotherName]) {
		[self toggleActiveCamera];
	} else if (aNode == [self getNodeNamed: kBitmapLabelName]) {
		[self cycleLabelOf: (CC3BitmapLabelNode*)aNode];
	} else if (aNode == [self getNodeNamed: @"Particles"]) {
		[((CC3ParticleEmitter*)aNode) emitParticle];
	} else if (aNode == [self getNodeNamed: kTVName]) {
		[self toggleTelevision];
	} else if (aNode == _teapotTextured || aNode == _teapotSatellite) {
		
		// Toggle wireframe box around the touched teapot's mesh
		CC3LocalContentNode* lcNode = (CC3LocalContentNode*)aNode;
		lcNode.shouldDrawLocalContentWireframeBox = !lcNode.shouldDrawLocalContentWireframeBox;
		
		// Toggle the large wireframe box around both teapots
		_teapotTextured.shouldDrawWireframeBox = !_teapotTextured.shouldDrawWireframeBox;

	// If the robot was touched, cycle through three particle hose options.
	// If no particles are being emitting, turn on the point particle hose.
	// If the point particle hose is emitting, turn it off and turn on the mesh particle hose.
	// If the mesh particle hose is emitting, turn it off so neither hose is emitting.
	} else if (aNode == [self getNodeNamed: kPODRobotRezNodeName] ) {
		CC3ParticleEmitter* pointHose = (CC3ParticleEmitter*)[self getNodeNamed: kPointHoseEmitterName];
		CC3ParticleEmitter* meshHose = (CC3ParticleEmitter*)[self getNodeNamed: kMeshHoseEmitterName];
		if (pointHose.isEmitting) {
			[pointHose pause];
			[meshHose play];
		} else if (meshHose.isEmitting) {
			[meshHose pause];
		} else {
			[pointHose play];
		}
		
	// If the dragon was touched, cycle through several different animations for the dragon
	} else if (aNode == _dragon ) {
		[self cycleDragonMotion];

	// If the globe was touched, toggle the opening of a HUD window displaying it up close.
	} else if (aNode == _globe ) {
		CC3DemoMashUpLayer* layer = self.primaryCC3DemoMashUpLayer;		// Create strong reference to weak property
		[layer toggleGlobeHUDFromTouchAt: touchPoint];
	}
}

/**
 * Unproject the 2D touch point into a 3D global-coordinate ray running from the camera through
 * the touched node. Find the node that is punctured by the ray, the location at which the ray
 * punctures the node's bounding volume in the local coordinates of the node, and add a temporary
 * visible marker at that local location that fades in and out, and then removes itself.
 */
-(void) markTouchPoint: (CGPoint) touchPoint on: (CC3Node*) aNode {

	if (!aNode) {
		LogInfo(@"You selected no node.");
		return;
	}

	// Get the location where the node was touched, in its local coordinates.
	// Normally, in this case, you would invoke nodesIntersectedByGlobalRay:
	// on the touched node, not on this CC3Scene. We do so here, to show that
	// all of the nodes under the ray will be detected, not just the touched node.
	CC3Ray touchRay = [self.activeCamera unprojectPoint: touchPoint];
	CC3NodePuncturingVisitor* puncturedNodes = [self nodesIntersectedByGlobalRay: touchRay];
	
	// The reported touched node may be a parent. We want to find the descendant node that
	// was actually pierced by the touch ray, so that we can attached a descriptor to it.
	CC3Node* localNode = puncturedNodes.closestPuncturedNode;
	CC3Vector nodeTouchLoc = puncturedNodes.closestPunctureLocation;

	// Create a descriptor node to display the location on the node
	NSString* touchLocStr = [NSString stringWithFormat: @"(%.1f, %.1f, %.1f)", nodeTouchLoc.x, nodeTouchLoc.y, nodeTouchLoc.z];
	CCLabelTTF* dnLabel = [CCLabelTTF labelWithString: touchLocStr
											 fontName: @"Arial"
											 fontSize: 8];
	CC3Node* dn = [CC3NodeDescriptor nodeWithName: [NSString stringWithFormat: @"%@-TP", localNode.name]
									withBillboard: dnLabel];
	dn.color = localNode.initialDescriptorColor;

	// Use actions to fade the descriptor node in and then out, and remove it when done.
	CCActionInterval* fadeIn = [CCActionFadeIn actionWithDuration: 0.2];
	CCActionInterval* fadeOut = [CCActionFadeOut actionWithDuration: 5.0];
	CCActionInstant* remove = [CC3ActionRemove action];
	dn.opacity = 0;		// Start invisible
	[dn runAction: [CCActionSequence actions: fadeIn, fadeOut, remove, nil]];
	
	// Set the location of the descriptor node to the touch location,
	// which are in the touched node's local coordinates, and add the
	// descriptor node to the touched node.
	dn.location = nodeTouchLoc;
	[localNode addChild: dn];

	// Log everything that happened.
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"You selected %@", aNode];
	[desc appendFormat: @" located at %@", NSStringFromCC3Vector(aNode.globalLocation)];
	[desc appendFormat: @", or at %@ in 2D.", NSStringFromCC3Vector([self.activeCamera projectNode: aNode])];
	[desc appendFormat: @"\nThe actual node touched was %@", localNode];
	[desc appendFormat: @" at %@ on its boundary", NSStringFromCC3Vector(nodeTouchLoc)];
	[desc appendFormat: @" (%@ globally).", NSStringFromCC3Vector(puncturedNodes.closestGlobalPunctureLocation)];
	[desc appendFormat: @"\nThe nodes punctured by the ray %@ were:", NSStringFromCC3Ray(touchRay)];
	NSUInteger puncturedNodeCount = puncturedNodes.nodeCount;
	for (NSUInteger i = 0; i < puncturedNodeCount; i++) {
		[desc appendFormat: @"\n\t%@", [puncturedNodes puncturedNodeAt: i]];
		[desc appendFormat: @" at %@ on its boundary.", NSStringFromCC3Vector([puncturedNodes punctureLocationAt: i])];
		[desc appendFormat: @" (%@ globally).", NSStringFromCC3Vector([puncturedNodes globalPunctureLocationAt: i])];
	}
	LogInfo(@"%@", desc);
}

/**
 * If the touched node is the ground, place a little orange teapot at the location
 * on the ground corresponding to the touch-point. As the teapot is placed, we set off
 * a fiery explosion using a 2D particle system for dramatic effect. This demonstrates
 * the ability to drop objects into the 3D scene using touch events, along with the
 * ability to add Cocos2D CCParticleSystems into the 3D scene.
 */
-(void) touchGroundAt: (CGPoint) touchPoint {
	CC3Plane groundPlane = _ground.plane;
	CC3Vector4 touchLoc = [self.activeCamera unprojectPoint: touchPoint ontoPlane: groundPlane];

	// Make sure the projected touch is in front of the camera, not behind it
	// (ie- cam is facing towards, not away from, the ground)
	if (touchLoc.w > 0.0) {
		CC3MeshNode* tp = [[CC3ModelSampleFactory factory] makeUniColoredTeapotNamed: kTeapotOrangeName
																		   withColor: kCCC4FOrange];
		tp.uniformScale = 200.0;
		tp.location = touchLoc.v;
		
		[self addExplosionTo: tp];	// For effect, add an explosion as the teapot is placed
		
		// We've set the teapot location to the global 3D point that was derived from the
		// touch point, and the teapot has a global rotation of zero, and a global scale.
		// When we add it to the ground plane, we don't want those properties to be further
		// transformed by the ground plane's existing transform. Therefore, the teapot
		// transform properties must be localized to properties that are relative to those
		// of the ground plane. We can do that using the addAndLocalizeChild: method.
		[_ground addAndLocalizeChild: tp];
	}
}

/** If the node is the beach ball, toggle it between opaque and translucent. */
-(void) touchBeachBallAt: (CGPoint) touchPoint {

	// Because the beach ball is a composite node, and we add a fading touch location
	// descriptor node as a child to it when the beach ball is touched we can't trust
	// the value of the opacity property of the beach ball parent node. Instead, we
	// need to dig into one of its mesh node segments to determine its opacity.
	CCOpacity bbOpacity = [_beachBall getNodeNamed: kBeachBallWhiteSegment].opacity;
	_beachBall.opacity = (bbOpacity == kCCOpacityFull) ? (kCCOpacityFull * 0.75) : kCCOpacityFull;

	// For fun, uncomment the following line to draw wireframe boxes around the beachball component meshes
//	_beachBall.shouldDrawAllLocalContentWireframeBoxes = !_beachBall.shouldDrawAllLocalContentWireframeBoxes;
}

/** When the brick wall is touched, slide it back and forth to open or close it. */
-(void) touchBrickWallAt: (CGPoint) touchPoint {
	CC3Vector destination = _brickWall.isOpen ? kBrickWallClosedLocation : kBrickWallOpenLocation;
	CCActionInterval* moveAction = [CC3ActionMoveTo actionWithDuration: 3.0 moveTo: destination];
	// Add a little bounce for realism.
	moveAction = [CCActionEaseElasticOut actionWithAction: moveAction period: 0.5];
	[_brickWall stopAllActions];
	[_brickWall runAction: moveAction];
	_brickWall.isOpen = !_brickWall.isOpen;
}

/**
 * Switch the multi-texture displayed on the wooden sign node to the next texture combination
 * function in the cycle. There are two basic examples of texture combining demonstrated here.
 * The first is a series of methods of combining regular RGB textures. The second is DOT3
 * bump-mapping which uses the main texture as a normal map to interact with the lighting,
 * and then overlaying the wooden sign texture onto it. The effect of this last type of
 * combining is to add perceived embossing to the wooden texture.
 *
 * Once the multi-texture combining function is determined, the name of it is set in
 * the label that hovers above the wooden sign.
 *
 * This functionality is available only under OpenGL ES 1.1.
 */
#if CC3_OGLES_1
-(void) switchWoodenSign {
	CC3Texture* mainTex = _woodenSign.texture;
	CC3TextureUnitTexture* stampOverlay = _stampTex;
	CC3ConfigurableTextureUnit* stampTU = (CC3ConfigurableTextureUnit*)stampOverlay.textureUnit;

	// If showing embossed DOT3 multi-texture, switch it to stamped texture with modulation.
	if (mainTex == _embossedStampTex) {
		[_woodenSign removeAllTextures];
		[_woodenSign addTexture: _signTex];
		[_woodenSign addTexture: _stampTex];
		stampTU.combineRGBFunction = GL_MODULATE;
	} else {
		// Otherwise, showing stamped texture. Use the current combining function to
		// select the next combining function. Once we get to GL_SUBTRACT, the next
		// step in the cycle is to flip to the embossed DOT3 multi-texture.
		switch (stampTU.combineRGBFunction) {
			case GL_MODULATE:
				stampTU.combineRGBFunction = GL_ADD;
				break;
			case GL_ADD:
				stampTU.combineRGBFunction = GL_ADD_SIGNED;
				break;
			case GL_ADD_SIGNED:
				stampTU.combineRGBFunction = GL_REPLACE;
				break;
			case GL_REPLACE:
				stampTU.combineRGBFunction = GL_SUBTRACT;
				break;
			case GL_SUBTRACT:
				// Switch to the embossed texture showing DOT3. Must reverse the order of the textures.
				[_woodenSign removeAllTextures];
				[_woodenSign addTexture: _embossedStampTex];
				[_woodenSign addTexture: _signTex];
				stampOverlay = _embossedStampTex;		// For bump-map, the combiner function is in the main texture
				stampTU = (CC3ConfigurableTextureUnit*)stampOverlay.textureUnit;
				break;
			default:
				break;
		}
	}
	
	// Get the label below the wooden sign, and update its contents to be
	// the name of the new multi-texture combining function, and re-measure the
	// bounding box of the CC3Billboard from the new size of the label.
	// Alternately, we could have set the shouldAlwaysMeasureBillboardBoundingRect
	// property on the CC3Billboard to have the bounding box measured automatically
	// on every update pass, at the cost of many unneccessary measurements when the
	// label text does not change.
	CC3Billboard* bbSign = (CC3Billboard*)[_woodenSign getNodeNamed: kSignLabelName];
	id<CCLabelProtocol> signLabel = (id<CCLabelProtocol>)bbSign.billboard;
	[signLabel setString: [NSString stringWithFormat: kMultiTextureCombinerLabel,
						   NSStringFromGLEnum(stampTU.combineRGBFunction)]];
	[bbSign resetBillboardBoundingRect];
}
#else
-(void) switchWoodenSign {}
#endif	// CC3_OGLES_1

/** 
 * Toggle the floating head between a detailed bump-mapped texture and a mesh-only texture,
 * illustrating the use of bump-mapping to increase the visbible surface detail on a very
 * low-poly mesh.
 */
-(void) toggleFloatingHeadConfiguration; {

	// Clear all textures then, if moving to bump-mapping, add the bump-map texture first,
	// then add the visible texture. Otherwise, skip the bump-map texture and just add the
	// visible texture.
	BOOL shouldBumpMap = (_floatingHead.texture != _headBumpTex);
	[_floatingHead removeAllTextures];
	if (shouldBumpMap) [_floatingHead addTexture: _headBumpTex];
	[_floatingHead addTexture: _headTex];

	// If running shaders under OpenGL ES 2.0, clear the shader program so that a different
	// shader program will automatically be selected for the new texture configuration.
	[_floatingHead removeLocalShaders];
	
	// Demonstrate the use of application-specific data attached to a node, by logging the data.
	if (_floatingHead.userData) {
		LogInfo(@"%@ says '%@'", _floatingHead, _floatingHead.userData);
	}
}

/**
 * Turn the TV on or off by toggle the image on the TV between a static test pattern card and a
 * texture generated dynamically by rendering the scene from the runner's camera into a texture.
 *
 * To demonstrate extracting an iOS or OSX image from a render surface, every time we turn the
 * TV off, we create a CGImageRef from the TV screen image, and save it to a JPEG file.
 */
-(void) toggleTelevision {
	_isTVOn = !_isTVOn;
	_tvScreen.texture = _isTVOn ? self.tvSurface.colorTexture : _tvTestCardTex;
	
	if (!_isTVOn) [self saveTVImage];
}

/** 
 * Extracts the image from the TV screen, converts it into an OS image,
 * and saves it to a JPEG file in the Documents directory.
 */
-(void) saveTVImage {
	NSString* docDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* imgPath = [docDir stringByAppendingPathComponent: @"TV.jpg"];

	// Extract a CGImageRef from either the entire TV surface, or just a section (by uncommenting below)
	CGImageRef tvImgRef = self.tvSurface.createCGImage;
//	CGImageRef tvImgRef = [_tvSurface createCGImageFrom: CC3ViewportMake(230, 100, 256, 256)];
	
#if CC3_IOS
	// Convert the CGImageRef to a UIImage and save it as a JPEG file.
	UIImage* tvImg	= [UIImage imageWithCGImage: tvImgRef];
	NSData* imgData = UIImageJPEGRepresentation(tvImg, 0.9f);
	[imgData writeToFile: imgPath atomically: YES];
#endif	// CC3_IOS

#if CC3_OSX
	// Create an image destination and save the CGImageRef to it.
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:imgPath];
	CGImageDestinationRef dest = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
	CGImageDestinationAddImage(dest, tvImgRef, nil);
	CGImageDestinationFinalize(dest);
	CFRelease(dest);
#endif	// CC3_OSX
	
	// Don't forget to release the CGImageRef!
	CGImageRelease(tvImgRef);
	LogInfo(@"TV image saved to file: %@", imgPath);
}

/** Toggle between the main scene camera and the camera running along with the runner. */
-(void) toggleActiveCamera {
	self.activeCamera = (self.activeCamera == _robotCam) ? _runnerCam : _robotCam;
}

/** Cycles the specified bitmapped label node through a selection of label strings. */
-(void) cycleLabelOf: (CC3BitmapLabelNode*) bmLabel {
	switch (_bmLabelMessageIndex) {
		case 0:
			bmLabel.labelString = @"Goodbye,\ncruel world.";
			bmLabel.color = CCColorRefFromCCC4F(kCCC4FRed);
			_bmLabelMessageIndex++;
			break;
		default:
			bmLabel.labelString = @"Hello, world!";
			bmLabel.color = CCColorRefFromCCC4F(ccc4f(0, 0.85, 0.5, 1.0));
			_bmLabelMessageIndex = 0;
			break;
	}
}

/** Cycles through a variety of shadowing options for the specified node. */
-(void) cycleShadowFor: (CC3Node*) aNode {
	
	// Don't add a shadow to the ground
	if (aNode == _ground) return;

	// If the node already has a shadow volume, remove it, otherwise add one.
	if ( [aNode hasShadowVolumesForLight: _robotLamp] ) {
		[aNode removeShadowVolumesForLight: _robotLamp];
		LogInfo(@"Removed shadow from: %@", aNode);
	} else {
		// Normally, shadow volumes interact with the stencil buffer, and are not visible
		// themselves. You can change the following property to YES, to make the shadow
		// volumes themselves during development.
		CC3ShadowVolumeMeshNode.defaultVisible = NO;
		
		// Since we're already running, spawn a background threaded task to create and
		// populate the shadow volume, in order to reduce any unwanted animation pauses.
		[CC3Backgrounder.sharedBackgrounder runBlock: ^{
			[aNode addShadowVolumesForLight: _robotLamp];
			LogInfo(@"Added shadow to: %@", aNode);
		}];
	}
}

/**
 * When the dragon node is touched, cycle through several different animations, smoothly
 * transitioning between the current and new animations by using animation cross-fading
 * which blends the two animations together using animated blending weights.
 */
-(void) cycleDragonMotion {
	switch (_dragonMotion) {
		case kDragonFlapping:
			[self dragonTransitionToGliding];
			break;
		
		case kDragonStill:
		case kDragonGliding:
		default:
			[self dragonTransitionToFlapping];
			break;
	}
}

/**
 * Smoothly transitions the dragon from flapping animation to gliding animation.
 *
 * Flapping and gliding are handled by two separate tracks of animation, and the transition
 * is done by animating the relative blending weights beween the two tracks by using an
 * animation cross-fade action. Animated cross-fading ensures a smooth transition between
 * the distinct animations, regardless of where in each animation cycle it is started.
 *
 * In addition, once the cross-fading transition has finished, the old animation will no longer
 * be visibly affecting the dragon, and can be shut down to save unnecessary processing. We do
 * this after the transition has complted to avoid an abrupt transtion that would occur if the
 * old animation track was stopped while it was still visible.
 */
-(void)	dragonTransitionToGliding {
	
	// Create the gliding animation action and start it running on the dragon
	CCAction* gliding = [[CC3ActionAnimate actionWithDuration: 2.0 onTrack: _dragonGlideTrack] repeatForever];
	gliding.tag = kGlidingActionTag;
	[_dragon runAction: gliding];
	
	// The dragon is currently running the flapping animation at full weight and the gliding animation
	// at zero weight. Cross-fade from flapping to gliding over a short time period, then shut
	// down the flapping animation, so we're not wasting time animating it when it's not visible.
	CCActionInterval* crossFade = [CC3ActionAnimationCrossFade actionWithDuration: 0.5
																  fromTrack: _dragonFlapTrack
																	toTrack: _dragonGlideTrack];
	CCActionCallFunc* stopFlapping = [CCActionCallFunc actionWithTarget: self selector: @selector(dragonStopFlapping)];
	[_dragon runAction: [CCActionSequence actionOne: crossFade two: stopFlapping]];
	
	_dragonMotion = kDragonGliding;		// Dragon is gliding now
}

/** 
 * Smoothly transitions the dragon from gliding animation to flapping animation.
 *
 * Flapping and gliding are handled by two separate tracks of animation, and the transition
 * is done by animating the relative blending weights beween the two tracks by using an
 * animation cross-fade action. Animated cross-fading ensures a smooth transition between
 * the distinct animations, regardless of where in each animation cycle it is started.
 *
 * In addition, once the cross-fading transition has finished, the old animation will no longer
 * be visibly affecting the dragon, and can be shut down to save unnecessary processing. We do 
 * this after the transition has complted to avoid an abrupt transtion that would occur if the
 * old animation track was stopped while it was still visible.
 */
-(void)	dragonTransitionToFlapping {
	
	// Create the flapping animation action and start it running on the dragon
	CCAction* flapping = [[CC3ActionAnimate actionWithDuration: 2.0 onTrack: _dragonFlapTrack] repeatForever];
	flapping.tag = kFlappingActionTag;
	[_dragon runAction: flapping];
	
	// The dragon is currently running the gliding animation at full weight and the flapping animation
	// at zero weight. Cross-fade from gliding to flapping over a short time period, then shut
	// down the gliding animation, so we're not wasting time animating it when it's not visible.
	CCActionInterval* crossFade = [CC3ActionAnimationCrossFade actionWithDuration: 0.5
																  fromTrack: _dragonGlideTrack
																	toTrack: _dragonFlapTrack];
	CCActionCallFunc* stopGliding = [CCActionCallFunc actionWithTarget: self selector: @selector(dragonStopGliding)];
	[_dragon runAction: [CCActionSequence actionOne: crossFade two: stopGliding]];
	
	_dragonMotion = kDragonFlapping;		// Dragon is flapping now
}

/** Stop the CC3ActionAnimate action that is running the dragon's flapping animation. */
-(void) dragonStopFlapping { [_dragon stopActionByTag: kFlappingActionTag]; }

/** Stop the CC3ActionAnimate action that is running the dragon's gliding animation. */
-(void) dragonStopGliding { [_dragon stopActionByTag: kGlidingActionTag]; }

@end

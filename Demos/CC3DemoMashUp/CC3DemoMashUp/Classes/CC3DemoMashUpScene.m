/*
 * CC3DemoMashUpScene.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * The cocos3d mascot model was created by Alexandru Barbulescu, and used here
 * by permission. Further rights may be claimed for that model.
 * 
 * See header file CC3DemoMashUpScene.h for full API documentation.
 */

#import "CC3DemoMashUpScene.h"
#import "CC3IOSExtensions.h"
#import "CC3Billboard.h"
#import "CC3ActionInterval.h"
#import "CC3ModelSampleFactory.h"
#import "CCLabelTTF.h"
#import "CGPointExtension.h"
#import "CCTouchDispatcher.h"
#import "CCParticleExamples.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3PODNode.h"
#import "CC3PODResourceNode.h"
#import "CC3BoundingVolumes.h"
#import "CC3ParametricMeshNodes.h"
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
#import "CC3GLMatrix.h"

// File names
#define kRobotPODFile					@"IntroducingPOD_float.pod"
#define kBeachBallPODFile				@"BeachBall.pod"
#define kGlobeTextureFile				@"earthmap1k.jpg"
#define kMascotPODFile					@"cocos3dMascot.pod"
#define kDieCubePODFile					@"DieCube.pod"
#define kGroundTextureFile				@"Grass.jpg"
#define kFloaterTextureFile				@"ButtonRing48x48.png"
#define kSignTextureFile				@"Crate.pvr"
#define kSignStampTextureFile			@"Stamp.pvr"
#define kSignStampNormalsTextureFile	@"Stamp-nm.pvr"
#define kHeadPODFile					@"Head.pod"
#define kHeadTextureFile				@"Head_diffuse.pvr"
#define kHeadBumpFile					@"Head_clonespacePVRTC.pvr"
#define kCubeTextureFile				@"BoxTexture.png"
#define kBrickTextureFile				@"Bricks-Red.jpg"
#define kRunningManPODFile				@"man.pod"
#define kMalletPODFile					@"mallet.pod"
#define kPointParticleTextureFile		@"fire.png"
#define kMeshPartileTextureFile			@"BallBoxTexture.png"

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
#define kRainbowTeapotName				@"Satellite"
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
#define kRunnerCameraName				@"RunnerCamera"
#define kRunnerLampName					@"Spot01"
#define kLittleBrotherName				@"LittleBrother"

#define	kMultiTextureCombinerLabel		@"Multi-texture combiner function: %@"

#define kCameraMoveDuration				3.0
#define kTeapotRotationActionTag		1

// Locations for the brick wall in open and closed position
static CC3Vector kBrickWallOpenLocation = { -190, 150, -840 };
static CC3Vector kBrickWallClosedLocation = { -115, 150, -765 };

@interface CCAction (PrivateMethods)
// This method doesn't actually exist on CCAction, but it does on all subclasses we use in this project.
-(CCAction*) reverse;
@end

@interface CC3Node (TempalteMethods)
@property(nonatomic, readonly) ccColor3B initialDescriptorColor;
@end

@interface CC3DemoMashUpScene (Private)
-(void) addRobot;
-(void) addGround;
-(void) addFloatingRing;
-(void) addAxisMarkers;
-(void) addLightMarker;
-(void) addBitmapLabel;
-(void) addProjectedLabel;
-(void) addTeapotAndSatellite;
-(void) addBrickWall;
-(void) addBeachBall;
-(void) addGlobe;
-(void) addDieCube;
-(void) addMascots;
-(void) addBumpMapLightTracker;
-(void) addWoodenSign;
-(void) addFloatingHead;
-(void) addSun;
-(void) addSpotlight;
-(void) addFog;
-(void) addPointParticles;
-(void) addMeshParticles;
-(void) addPointHose;
-(void) addMeshHose;
-(void) addTexturedCube;
-(void) addSkinnedMallet;
-(void) addSkinnedRunners;
-(void) addExplosionTo: (CC3Node*) aNode;
-(void) configureCamera;
-(void) configureLighting;
-(void) updateCameraFromControls: (ccTime) dt;
-(void) invadeWithRobotArmy;
-(void) invadeWithTeapotArmy;
-(void) invadeWithArmyOf: (CC3Node*) invaderTemplate;
-(void) rotateCubeFromSwipeAt: (CGPoint) touchPoint interval: (ccTime) dt;
-(void) rotate: (SpinningNode*) aNode fromSwipeAt: (CGPoint) touchPoint interval: (ccTime) dt;
-(void) rotate: (SpinningNode*) aNode fromSwipeVelocity: (CGPoint) swipeVelocity;
-(void) touchGroundAt: (CGPoint) touchPoint;
-(void) touchBeachBallAt: (CGPoint) touchPoint;
-(void) touchBrickWallAt: (CGPoint) touchPoint;
-(void) switchWoodenSign;
-(void) toggleFloatingHeadDefinition;
-(void) toggleActiveCamera;
-(void) cycleLabelOf: (CC3BitmapLabelNode*) aNode;
-(void) cycleShadowFor: (CC3Node*) aNode;
-(void) markTouchPoint: (CGPoint) touchPoint on: (CC3Node*) touchedNode;
-(void) checkForCollisions;
@end


@implementation CC3DemoMashUpScene

@synthesize playerDirectionControl, playerLocationControl, isManagingShadows;

-(void) dealloc {
	ground = nil;
	teapotWhite = nil;			// not retained
	teapotTextured = nil;		// not retained
	teapotSatellite = nil;		// not retained
	brickWall = nil;			// not retained
	podLight = nil;				// not retained
	beachBall = nil;			// not retained
	globe = nil;				// not retained
	dieCube = nil;				// not retained
	texCubeSpinner = nil;		// not retained
	mascot = nil;				// not retained
	bumpMapLightTracker = nil;	// not retained
	woodenSign = nil;			// not retained
	floatingHead = nil;			// not retained
	camTarget = nil;			// not retained
	origCamTarget = nil;		// not retained
	[signTex release];
	[stampTex release];
	[embossedStampTex release];
	[headTex release];
	[headBumpTex release];
	
	[super dealloc];
}

/**
 * Invoked by the customized initializeScene to set up any initial state for
 * this customized scene. This is broken into a separate method so that the
 * initializeScene method can focus on loading the artifacts of the 3D scene.
 */
-(void) initCustomState {
	isManagingShadows = NO;
	playerDirectionControl = CGPointZero;
	playerLocationControl = CGPointZero;
	
	// Improve performance by avoiding clearing the depth buffer when transitioning
	// between 2D content and 3D content. Since we are drawing 2D content on top of
	// the 3D content, we must also turn off depth testing when drawing 2D content.
	self.shouldClearDepthBufferBefore2D = NO;
	self.shouldClearDepthBufferBefore3D = NO;
	[[CCDirector sharedDirector] setDepthTest: NO];
	
	// The order in which meshes are drawn to the GL engine can be tailored to your needs.
	// The default is to draw opaque objects first, then alpha-blended objects in reverse
	// Z-order. Since this example has lots of similar teapots and robots to draw in this
	// example, we choose to also group objects by meshes here, while also drawing opaque
	// objects first, and translucent objects in reverse Z-order.
	//
	// To experiment with an alternate drawing order, set a different node sequence sorter
	// by uncommenting one of the lines here and commenting out the others. The third option
	// performs no grouping and draws the objects in the order they are added to the scene
	// below. The fourth option does not use a drawing sequencer, and draws the objects
	// hierarchically instead. With this, notice that the transparent beach ball now appears
	// opaque, because it was added first, and is traversed ahead of other objects in the
	// hierarchical assembly, resulting it in being drawn first, and so it cannot blend with
	// the background.
	//
	// You can of course write your own node sequencers to customize to your specific
	// app needs. Best to change the node sequencer before any model objects are added.
	//	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirstGroupMeshes];
	//	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirstGroupTextures];
	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirst];
	//	self.drawingSequencer = nil;
	
}

/**
 * Adds the 3D objects to the scene, loading some models from POD files, and building others
 * algorithmically. The loading of different features within the scene is broken into a sequence
 * of template methods. If you want to play with not loading certain elements, simply comment
 * out one the invocations of these template methods within this method.
 */
-(void) initializeScene {
	
	// Set up any initial state tracked by this subclass
	[self initCustomState];
	
	[self addGround];				// Add a ground plane to provide some perspective to the user
	
	[self addBeachBall];			// Add a transparent bouncing beach ball...exported from Blender
	
	[self addGlobe];				// Add a rotating globe from a parametric sphere covered by a texture

	[self addDieCube];				// Add a game die whose rotation is controlled by touch-swipe user action

	[self addTexturedCube];			// Add another cube, this one textured, below the die cube.
	
	[self addTeapotAndSatellite];	// Add a large textured teapot with a smaller satellite teapot
	
	[self addBrickWall];			// Add a brick wall that can block the path of the satellite teapot

	[self addRobot];				// Add an animated robot arm, a light, and a camera
	
	[self addBitmapLabel];			// Add a bitmapped string label
	
	[self addProjectedLabel];		// Attach a text label to the hand of the animated robot.
	
//	[self addPointParticles];		// Uncomment to add a platform of multi-colored, light-interactive,
									// point particles hanging in the scene.
	
//	[self addMeshParticles];		// Uncomment to add a platform of multi-colored, mesh particles
									// hanging in the scene.
	
	[self addPointHose];			// Attach a point particle hose to the hand of the animated robot.
									// The hose is turned on and off when the robot arm is touched.
	
	[self addMeshHose];				// Attach a point particle hose to the hand of the animated robot.
									// The hose is turned on and off when the robot arm is touched.
	
	[self addFloatingRing];			// Add a large yellow band floating above the ground, using a texture
									// containing transparency. The band as a whole fades in and out
									// periodically. This demonstrates managing opacity and translucency
									// at both the texture and material level.

	[self addAxisMarkers];			// Add colored teapots to mark each coordinate axis
	
	[self addLightMarker];			// Add a small white teapot to show where the light is coming from
	
	[self addMascots];				// Add the cocos3d mascot.
									// This must happen after camera is loaded (in addRobot).
	
	[self addBumpMapLightTracker];	// Add a light tracker for the bump-maps in the wooden sign
									// and floating head. This must happen after main light is
									// loaded from the POD file (in addRobot).

	[self addWoodenSign];			// Add the multi-texture wooden sign. 
									// This must happen after camera is loaded (in addRobot).
	
	[self addFloatingHead];			// Add the bump-mapped floating head. 
									// This must happen after camera is loaded (in addRobot).
	
	[self addSun];					// Add a cocos2d particle emitter as the sun in the sky.

	[self addSpotlight];			// Add a spotlight to the camera.
									// This spotlight will be turned on when the sun is turned off.

	[self addFog];					// Adds fog to the scene. This is initially invisible.
	
	[self addSkinnedMallet];		// Adds a flexible mallet to the scene, showing bone skinning.
	
	[self addSkinnedRunners];		// Adds two running figures to the scene, showing bone skinning.

	[self configureLighting];		// Set up the lighting
	[self configureCamera];			// Check out some interesting camera options.
	
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now
	// redundant. However, because we can add shadow volumes dynamically to any node,
	// we need to keep the vertex location, index and skinning data of all meshes
	// around to build shadow volumes. If we had added the shadow volumes before here,
	// we wouldn't have to retain this data.
	[self retainVertexLocations];
	[self retainVertexIndices];
	[self retainVertexWeights];
	[self retainVertexMatrixIndices];
	[self createGLBuffers];
	[self releaseRedundantData];
	
	// For an interesting effect, to draw text descriptors and/or bounding boxes on every node
	// during debugging, or to display the bounding volumes, used for collision detection and
	// visual culling, uncomment one or more of the following lines. The first line displays
	// short descriptive text for each node (including class, node name & tag). The second line
	// displays bounding boxes of only those nodes with local content (eg- meshes). The third
	// line shows the bounding boxes of all nodes, including those with local content AND
	// structural nodes. The fourth line displays the bounding volumes of each node. Bounding
	// volumes are used to determine when a node is within the camera frustum, and thus appears
	// on-screen. Nodes that are not visible on screen are not rendered. Bounding volumes are
	// also used for collision detection. The bounding volume of most nodes (except the globe)
	// contains both a spherical and bounding-box bounding volume to optimize testing.
	// For something extra cool, touch the robot arm to see the bounding volume of the particle
	// emitter grow and shrink dynamically. Use the joystick controls to back the camera away to
	// get the full effect. You can also turn on any of these properties at a more granular level
	// by using these and similar methods on individual nodes or node structures. See the CC3Node
	// class notes. This family of properties can be particularly useful during development to
	// track down display issues.
//	self.shouldDrawAllDescriptors = YES;
//	self.shouldDrawAllLocalContentWireframeBoxes = YES;
//	self.shouldDrawAllWireframeBoxes = YES;
//	self.shouldDrawAllBoundingVolumes = YES;
	
	// The full node structure of the scene is logged using the following line.
	LogInfo(@"The structure of this scene is: %@", [self structureDescription]);
}

/** Various options for configuring interesting camera behaviours. */
-(void) configureCamera {
	CC3Camera* cam = self.activeCamera;

	// Camera starts out embedded in the scene.
	cameraZoomType = kCameraZoomNone;
	
	// The camera comes from the POD file and is actually animated.
	// Stop the camera from being animated so the user can control it via the user interface.
	[cam disableAnimation];
	
	// Keep track of which object the camera is pointing at
	origCamTarget = cam.target;
	camTarget = origCamTarget;

	// For cameras, the scale property determines camera zooming, and the effective field-of-view.
	// You can adjust this value to play with camera zooming. Conversely, if you find that objects
	// in the periphery of your view appear elongated, you can adjust the fieldOfView and/or
	// uniformScale properties to reduce this "fish-eye" effect. See the notes of the CC3Camera
	// fieldOfView property for more on this.
	cam.uniformScale = 0.9;
	
	// You can configure the camera to use orthographic projection instead of the default
	// perspective projection by setting the isUsingParallelProjection property to YES.
	// You will also need to adjust the scale to match the different projection.
//	cam.isUsingParallelProjection = YES;
//	cam.uniformScale = 0.015;
	
	// To see the effect of mounting a camera on a moving object, uncomment the following
	// lines to mount the camera on a virtual boom attached to the beach ball.
	// Since the beach ball rotates as it bounces, you might also want to comment out the
	// CC3RotateBy action that is run on the beachBall in the addBeachBall method!
//	[beachBall addChild: cam];				// Mount the camera on the beach ball
//	cam.location = cc3v(2.0, 1.0, 0.0);		// Relative to the parent beach ball
//	cam.rotation = cc3v(0.0, 90.0, 0.0);	// Point camera out over the beach ball

	// To see the effect of mounting a camera on a moving object AND having the camera track a
	// location or object, even as the moving object bounces and rotates, uncomment the following
	// lines to mount the camera on a virtual boom attached to the beach ball, but stay pointed at
	// the moving rainbow teapot, even as the beach ball that the camera is mounted on bounces and
	// rotates. In this case, you do not need to comment out the CC3RotateBy action that is run on
	// the beachBall in the addBeachBall method
//	[beachBall addChild: cam];				// Mount the camera on the beach ball
//	cam.location = cc3v(2.0, 1.0, 0.0);		// Relative to the parent beach ball
//	cam.target = teapotSatellite;			// Look toward the rainbow teapot...
//	cam.shouldTrackTarget = YES;			// ...and track it as it moves

}

/** Configure the lighting. */
-(void) configureLighting {

	// Set the ambient scene lighting.
	self.ambientLight = CCC4FMake(0.3, 0.3, 0.3, 1.0);

	// Adjust the relative ambient and diffuse lighting of the main light to
	// improve realisim, particularly on shadow effects.
	podLight.diffuseColor = CCC4FMake(0.8, 0.8, 0.8, 1.0);
	
	// Another mechansim for adjusting shadow intensities is shadowIntensityFactor.
	// For better effect, set here to a value less than one to lighten the shadows
	// cast by the main light.
	podLight.shadowIntensityFactor = 0.75f;
	
	// The light from the robot POD file is animated to move back and forth, changing
	// the lighting of the scene as it moves. To turn this animation off, comment out
	// the following line. This can be useful when reviewing shadowing.
//	[podLight disableAnimation];
	
}

/**
 * Add a large circular grass-covered ground to give everything perspective.
 * The ground is tessellated into many smaller faces to improve realism of spotlight.
 */
-(void) addGround {
	ground = [CC3PlaneNode nodeWithName: kGroundName];
	[ground populateAsDiskWithRadius: 1500 andTessellation: ccg(8, 32)];
	ground.texture = [CC3Texture textureFromFile: kGroundTextureFile];

	// To experiment with repeating textures, uncomment the following line
	[ground repeatTexture: (ccTex2F){10, 10}];	// Grass
//	[ground repeatTexture: (ccTex2F){3, 3}];	// MountainGrass
	
	ground.location = cc3v(0.0, -100.0, 0.0);
	ground.rotation = cc3v(-90.0, 180.0, 0.0);
	ground.shouldCullBackFaces = NO;	// Show the ground from below as well.
	ground.isTouchEnabled = YES;		// Allow the ground to be selected by touch events.
	[ground retainVertexLocations];		// Retain location data in main memory, even when it
										// is buffered to a GL VBO via releaseRedundantData,
										// so that it may be accessed for further calculations
										// when dropping objects on the ground.
	[self addChild: ground];
}

/**
 * Adds a large rectangular yellow ring floating above the ground. This ring is created from a plane
 * using a texture that combines transparency and opacity. It demonstrates the use of transparency in
 * textures. You can see through the transparent areas to the scene behind the texture. The texture
 * as a whole fades in and out periodically, and rotates around the vertical (Y) axis.
 *
 * As the ring rotates, both sides are visible. This is because the shouldCullBackFaces property is
 * set to NO, so that both sides of each face are rendered. However, one side appears bright and
 * colorful and the other appears dark. Surprisingly, it is the front sides of the faces that appear
 * dark and it is the back side of the faces that appear bright and colorful. This is because the
 * light is located on the opposite side of the ring from the camera, and therefore the side that
 * faces towards the light is illuminated. However, since the normals of the faces in the rectangular
 * plane extend out from the front face of the plane, it is when the front face faces towards the
 * light (and away from the camera) that the plane appears most illuminated. At that time, it is the
 * back faces of the plane that we see. When the front faces are facing the camera, the normals are
 * facing away from the light and the entire plane appears dark. Understanding this behaviour helps
 * to understand the interaction between lighting, faces, and normals in any object.
 */
-(void) addFloatingRing {
	CC3MeshNode* floater = [CC3PlaneNode nodeWithName: kFloaterName];
	[floater populateAsCenteredRectangleWithSize: CGSizeMake(250.0, 250.0)];
	floater.texture = [CC3Texture textureFromFile: kFloaterTextureFile];
	floater.location = cc3v(400.0, 150.0, -250.0);
	floater.shouldCullBackFaces = NO;			// Show from behind as well.
	floater.isTouchEnabled = YES;
	[self addChild: floater];

	// Fade the floating ring in and out
	CCActionInterval* fadeOut = [CCFadeOut actionWithDuration: 5.0];
	CCActionInterval* fadeIn = [CCFadeIn actionWithDuration: 5.0];
	CCActionInterval* fadeCycle = [CCSequence actionOne: fadeOut two: fadeIn];
	[floater runAction: [CCRepeatForever actionWithAction: fadeCycle]];
	
	// Rotate the floating ring to see the effect on the orientation of the plane normals
	[floater runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																				rotateBy: cc3v(0.0, 30.0, 0.0)]]];
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
		LogError(@"Could not copy %@ to %@ because (%i) in %@: %@",
					  srcPath, dstPath, err.code, err.domain, err.userInfo);
		return NO;
	}
}

/**
 * Loads a POD file containing a semi-transparent beach ball
 * sporting multiple materials, exported from Blender.
 */
-(void) addBeachBall {
	
	// To show it is possible to load model files from other directories, we copy
	// the POD and texture files to the application Document directory.
	[self copyResourceToDocuments: kBeachBallPODFile];
	NSString* docDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* podPath = [docDir stringByAppendingPathComponent: kBeachBallPODFile];
	
	// Load the POD file from the application Documents directory. It will also
	// load any needed textures from that directory as well.
	[self addContentFromPODFile: podPath withName: kBeachBallRezNodeName];
	
	// Configure the bouncing beach ball
	beachBall = [self getNodeNamed: kBeachBallName];
	beachBall.location = cc3v(200.0, 200.0, -400.0);
	beachBall.uniformScale = 50.0;
	
	// Allow this beach ball node to be selected by touch events.
	// The beach ball is actually a structural assembly containing four child nodes,
	// one for each separately colored mesh. By marking the node assembly as touch-enabled,
	// and NOT marking each component mesh node as touch-enabled, when any of the component
	// nodes is touched, the entire beach ball structural node will be selected.
	beachBall.isTouchEnabled = YES;
	
	// Bounce the beach ball...simply...we're not trying for realistic physics here,
	// but we can still do some fun and interesting stuff with Ease-actions.
	GLfloat hangTime = 3.0f;
	CC3Vector dropLocation = beachBall.location;
	CC3Vector landingLocation = dropLocation;
	landingLocation.y = ground.location.y + 30.0f;
	
	CCActionInterval* dropAction = [CC3MoveTo actionWithDuration: hangTime moveTo: landingLocation];
	dropAction = [CCEaseOut actionWithAction: [CCEaseIn actionWithAction: dropAction rate: 4.0f] rate: 1.6f];
	
	CCActionInterval* riseAction = [CC3MoveTo actionWithDuration: hangTime moveTo: dropLocation];
	riseAction = [CCEaseIn actionWithAction: [CCEaseOut actionWithAction: riseAction rate: 4.0f] rate: 1.6f];
	
	CCActionInterval* bounce = [CCSequence actionOne: dropAction two: riseAction];
	[beachBall runAction: [CCRepeatForever actionWithAction: bounce]];
	
	// For extra realism, also rotate the beach ball as it bounces.
	[beachBall runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																					rotateBy: cc3v(30.0, 0.0, 45.0)]]];
}

/**
 * Adds a rotating globe that is created programatically from a prametric sphere,
 * and is covered with a rectangular texture containing a cylindrical projection
 * (typical of earth maps taken from space).
 */
-(void) addGlobe {
	
	// To show it is possible to load texture files from other directories,
	// we copy texture file to the application Document directory.
	[self copyResourceToDocuments: kGlobeTextureFile];
	NSString* docDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString* texPath = [docDir stringByAppendingPathComponent: kGlobeTextureFile];
	
	// Configure the rotating globe
	globe = [CC3MeshNode nodeWithName: kGlobeName];		// not retained
	[globe populateAsSphereWithRadius: 1.0f andTessellation: ccg(32, 32)];
	globe.texture = [CC3Texture textureFromFile: texPath];
	globe.location = cc3v(150.0, 200.0, -150.0);
	globe.uniformScale = 50.0;
	globe.ambientColor = kCCC4FLightGray;		// Increase the ambient reflection
	globe.isTouchEnabled = YES;				// allow this node to be selected by touch events
	
	// Rotate the globe
	[globe runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																				rotateBy: cc3v(0.0, 30.0, 0.0)]]];
	[self addChild: globe];

	// For something interesting, uncomment the following lines to make the
	// globe invisible, but still touchable, and still able to cast a shadow.
//	globe.visible = NO;
//	globe.shouldAllowTouchableWhenInvisible = YES;
//	globe.shouldCastShadowsWhenInvisible = YES;
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
	CC3PODResourceNode* podRezNode = [CC3PODResourceNode nodeFromFile: kDieCubePODFile];
	CC3Node* podDieCube = [podRezNode getNodeNamed: kDieCubePODName];
	
	// We want this node to be a SpinningNode class instead of the CC3PODNode class that
	// is loaded from the POD file. We can swap it out by creating a copy of the loaded
	// POD node, using a different node class as the base.
	dieCube = [[podDieCube copyWithName: kDieCubeName
								asClass: [SpinningNode class]] autorelease];

	// Now set some properties, including the friction, and add the die cube to the scene
	dieCube.uniformScale = 30.0;
	dieCube.location = cc3v(-200.0, 200.0, 0.0);
	dieCube.isTouchEnabled = YES;
	dieCube.friction = 1.0;
	[self addChild: dieCube];

}

/**
 * Adds a parametric textured cube that rotates by swiping, similar to the die cube
 * (see the note for the addDieCube method to learn how this is done.
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
	[texCube populateAsSolidBox: CC3BoundingBoxMake(-1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f)];
	texCube.uniformScale = 30.0;

	// Add a texture to the textured cube. This creates a material automatically.
	texCube.texture = [CC3Texture textureFromFile: kMeshPartileTextureFile];
	texCube.textureRectangle = CGRectMake(0, 0, 1, 0.75);
//	texCube.texture = [CC3Texture textureFromFile: kCubeTextureFile];

	texCube.ambientColor = CCC4FMake(0.6, 0.6, 0.6, 1.0);		// Increase the ambient reflection
	
	// Add direction markers to demonstrate how the sides are oriented. In the local coordinate
	// system of the cube node, the red marker point in the direction of the positive-X axis,
	// the green marker in the direction of the positive-Y axis, and the blue marker in the
	// direction of the positive-Z axis. As these demonstrate, the front faces the positive-Z
	// direction, and the top faces the positive-Y direction.
	[texCube addAxesDirectionMarkers];
	
	// Wrap the cube in a spinner node to allow it to be rotated by touch swipes.
	// Give the spinner some friction so that it slows down over time one released.
	itemName = [NSString stringWithFormat: @"%@-Spinner", texCube.name];
	texCubeSpinner = [SpinningNode nodeWithName: itemName];
	texCubeSpinner.friction = 1.0;
	texCubeSpinner.location = cc3v(-200.0, 75.0, 0.0);
	texCubeSpinner.isTouchEnabled = YES;

	// Add the cube to the spinner and the spinner to the scene.
	[texCubeSpinner addChild: texCube];
	[self addChild: texCubeSpinner];
}

/** Adds a large textured teapot and a small multicolored teapot orbiting it. */
-(void) addTeapotAndSatellite {
	teapotTextured = [[CC3ModelSampleFactory factory] makeLogoTexturedTeapotNamed: kTexturedTeapotName];
	teapotTextured.isTouchEnabled = YES;		// allow this node to be selected by touch events
	
	// To experiment with repeating textures, uncomment the following line
	// Note that the texture does not actually appear repeated 5 times.
	// This is because it is an NPOT texture. POT textures will repeat accurately.
//	[teapotTextured repeatTexture: (ccTex2F){5, 1}];
	
	// Uncomment the following two lines to experiment with a material that does not
	// interact with the current lighting conditions. In fact, you can turn lighting
	// completely off and this node will still be visible.
//	teapotTextured.shouldUseLighting = NO;
//	teapotTextured.emissionColor = kCCC4FLightGray;
	
	teapotSatellite = [PhysicsMeshNode nodeWithName: kRainbowTeapotName];
	teapotSatellite.mesh = [CC3ModelSampleFactory factory].multicoloredTeapotMesh;
	teapotSatellite.material = [CC3Material shiny];
	teapotSatellite.location = cc3v(0.3, 0.1, 0.0);
	teapotSatellite.uniformScale = 0.4;
	teapotSatellite.isTouchEnabled = YES;		// allow this node to be selected by touch events
	
	teapotTextured.location = cc3v(0.0, 150.0, -650.0);
	teapotTextured.uniformScale = 500.0;
	[teapotTextured addChild: teapotSatellite];
	[self addChild: teapotTextured];
	
	// Rotate the teapots. The satellite orbits the textured teapot because it is
	// a child node of the textured teapot, and orbits as the parent node rotates.
	// We give the rotation action a tag so we can find it again when the satellite
	// teapot collides with the brick wall and we need to change the motion.
	CCAction* teapotSpinAction = [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																						   rotateBy: cc3v(0.0, 60.0, 0.0)]];
	teapotSpinAction.tag = kTeapotRotationActionTag;
	[teapotTextured runAction: teapotSpinAction];

	 // For effect, also rotate the satellite around its own axes.
	[teapotSatellite runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																						  rotateBy: cc3v(30.0, 0.0, 45.0)]]];
}

/**
 * Adds a parametric textured wall that can be touched to slide it into the path of the
 * rainbow teapot as it orbits the textured teapot. Once in the path of the teapot, it
 * causes the teapot to bounce off it and reverse path, demonstating collision detection.
 */
-(void) addBrickWall {
	// Create a parametric textured box as an open door.
	brickWall = [DoorMeshNode nodeWithName: kBrickWallName];
	brickWall.isTouchEnabled = YES;
	[brickWall populateAsSolidBox: CC3BoundingBoxMake(-1.5, 0, -0.3, 1.5, 2.5, 0.3)];
	brickWall.uniformScale = 40.0;
	
	// Add a texture to the wall and repeat it. This creates a material automatically.
	brickWall.texture = [CC3Texture textureFromFile: kBrickTextureFile];
	[brickWall repeatTexture: (ccTex2F){4, 2}];
	brickWall.ambientColor = kCCC4FWhite;			// Increase the ambient reflection so the backside is visible
	
	// Start with the wall in the open position
	brickWall.isOpen = YES;
	brickWall.location = kBrickWallOpenLocation;
	brickWall.rotation = cc3v(0, -45, 0);
	[self addChild: brickWall];
}

/** Loads a POD file containing an animated robot arm, a camera, and an animated light. */
-(void) addRobot {
	// We introduce a specialized resource subclass, not because it is needed in general,
	// but because the original PVR demo app ignores some data in the POD file. To replicate
	// the PVR demo faithfully, we must do the same, by tweaking the loader to act accordingly
	// by creating a specialized subclass.
	CC3PODResourceNode* podRezNode = [CC3PODResourceNode nodeWithName: kPODRobotRezNodeName];
	podRezNode.resource = [IntroducingPODResource resourceFromFile: kRobotPODFile];
	
	// If you want to stop the robot arm from being animated, uncomment the following line.
//	[podRezNode disableAllAnimation];
	
	podRezNode.isTouchEnabled = YES;
	[self addChild: podRezNode];
	
	// Retrieve the light from the POD resource so we can track its location as it moves via animation
	podLight = (CC3Light*)[podRezNode getNodeNamed: kPODLightName];
	
	// Start the animation of the robot arm and bouncing lamp from the PVR POD file contents.
	// But we'll have a bit of fun with the animation, as follows.
	// The basic animation in the POD pirouettes the robot arm in a complex movement...
	CCActionInterval* pirouette = [CC3Animate actionWithDuration: 5.0];
	
	// Extract only the initial bending-down motion from the animation, reverse it to create
	// a stand-up motion, and paste the two actions together to create a bowing motion.
	CCActionInterval* bendDown = [CC3Animate actionWithDuration: 1.8 limitFrom: 0.0 to: 0.15];
	CCActionInterval* standUp = [bendDown reverse];
	CCActionInterval* takeABow = [CCSequence actionOne: bendDown two: standUp];
	
	// Now...put it all together. The robot arm performs its pirouette, and then takes a bow,
	// over and over again.
	[podRezNode runAction: [CCRepeatForever actionWithAction: [CCSequence actionOne: pirouette
																				two: takeABow]]];
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
																		  withColor: CCC4FMake(0.7, 0.0, 0.0, 1.0)];
	teapotRed.location = cc3v(100.0, 0.0, 0.0);
	teapotRed.uniformScale = 100.0;
	teapotRed.isTouchEnabled = YES;		// allow this node to be selected by touch events
	[self addChild: teapotRed];
	
	// Green teapot is at postion 100 on the Y-axis
	// Create it by copying the red teapot.
	CC3Node* teapotGreen = [[teapotRed copyWithName:  kTeapotGreenName] autorelease];
	teapotGreen.diffuseColor = CCC4FMake(0.0, 0.7, 0.0, 1.0);
	teapotGreen.location = cc3v(0.0, 100.0, 0.0);
	[self addChild: teapotGreen];
	
	// Blue teapot is at postion 100 on the Z-axis
	// Create it by copying the red teapot.
	CC3Node* teapotBlue = [[teapotRed copyWithName:  kTeapotBlueName] autorelease];
	teapotBlue.diffuseColor = CCC4FMake(0.0, 0.0, 0.7, 1.0);
	teapotBlue.location = cc3v(0.0, 0.0, 100.0);
	[self addChild: teapotBlue];
}

/**
 * Adds a small white teapot that will be used to indicate the current position of the light
 * that illuminates the scene. The light is animated and moves up and down according to
 * animation data from the POD file, and the white teapot tracks its location (actually its
 * direction, since it is a directional light).
 */
-(void) addLightMarker {
	teapotWhite = [[CC3ModelSampleFactory factory] makeUniColoredTeapotNamed: kTeapotWhiteName withColor: kCCC4FWhite];
	teapotWhite.uniformScale = 200.0;
	teapotWhite.isTouchEnabled = YES;		// allow this node to be selected by touch events
	[self addChild: teapotWhite];
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
	bmLabel.radius = 30;
	bmLabel.textAlignment = UITextAlignmentCenter;
	bmLabel.relativeOrigin = ccp(0.5, 0.5);
	bmLabel.tessellation = ccg(1, 1);
	bmLabel.fontFileName = @"arial16.fnt";
	bmLabel.labelString = @"Hello, world.";
	bmLabelMessageIndex = 0;	// Keep track of which message is being displayed
	
	bmLabel.location = cc3v(-150.0, 75.0, 500.0);
	bmLabel.rotation = cc3v(0.0, 180.0, 0.0);
	bmLabel.uniformScale = 3.0;
	bmLabel.color = ccORANGE;
	bmLabel.shouldUseLighting = NO;
	bmLabel.shouldCullBackFaces = NO;			// Show from behind as well.
	bmLabel.isTouchEnabled = YES;
	[self addChild: bmLabel];
	[bmLabel runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																				  rotateBy: cc3v(0, 30, 0)]]];
}

-(void) addProjectedLabel {
	CCLabelTTF* bbLabel = [CCLabelTTF labelWithString: @"Whoa...I'm dizzy!"
											 fontName: @"Marker Felt"
											 fontSize: 18.0];
	CC3Billboard* bb = [CC3Billboard nodeWithName: kBillboardName withBillboard: bbLabel];
	bb.color = ccYELLOW;
	bb.shouldUseLighting = NO;
	
	// The billboard is a one-sided rectangular mesh, and would not normally be visible
	// from the back side. This is not an issue, since it is configured to always face
	// the camera. However, this also affects its ability to cast a shadow when the light
	// is behind it. Set the back faces to draw so that a shadow will be cast when the
	// light is behind the billboard.
//	bb.shouldCullBackFaces = NO;
	
	// As the hose emitter moves around, it is sometimes in front of this billboard,
	// but emits some particles behind this billboard. The result is that those
	// particles are blocked by the transparent parts of the billboard and appear to
	// inappropriately disappear. To compensate, set the explicit Z-order of the
	// billboard to be either always in-front of (< 0) or always behind (> 0) the
	// particle emitter. You can experiment with both options here. Or set the Z-order
	// to zero (the default and same as the emitter), and see what the problem is in
	// the first place! The problem is more evident when the emitter is set to a wide
	// dispersion angle.
	bb.zOrder = -1;
	
	// Uncomment to see the extent of the label as it moves in the 3D scene
//	bb.shouldDrawLocalContentWireframeBox = YES;
	
	// A billboard can be drawn either as part of the 3D scene, or as an overlay
	// above the 3D scene. By commenting out one of the following sections of code,
	// you can choose which method to use.
	
	// 1) In the 3D scene.
	// Locate the billboard at the end of the robot's arm, and tell it to
	// find the camera and track it, so that it always faces the camera.
	bb.location = cc3v( 0.0, 90.0, 0.0 );
	bb.shouldAutotargetCamera = YES;

	[[self getNodeNamed: kRobotTopArm] addChild: bb];
	
	// 2) Overlaid above the 3D scene.
	// The following lines add the emitter billboard as a 2D overlay that draws above
	// the 3D scene. The label text will not be occluded by any other 3D nodes.
	// Comment out the lines just above, and uncomment the following lines:
//	bb.shouldDrawAs2DOverlay = YES;
//	bb.location = cc3v( 0.0, 80.0, 0.0 );
//	bb.unityScaleDistance = 425.0;
//	bb.offsetPosition = ccp( 0.0, 15.0 );
//	[[self getNodeNamed: kRobotTopArm] addChild: bb];
}

/**
 * Adds a wrapper node that will track the light loaded from the POD file as it moves
 * and will update the light direction of any mesh nodes that are covered with a bump-map
 * texture. This allows the normals embedded in the bump-map texture to interact with
 * the direction of the light source to create per-pixel luminosity that appears realistic.
 */
-(void) addBumpMapLightTracker {
	bumpMapLightTracker = [CC3Node nodeWithName: kBumpMapLightTrackerName];
	bumpMapLightTracker.shouldTrackTarget = YES;
	bumpMapLightTracker.isTrackingForBumpMapping = YES;
	bumpMapLightTracker.target = podLight;
	[self addChild: bumpMapLightTracker];
}

/**
 * Adds a multi-texture sign, consisting of a combination of a wooden sign texture
 * and a stamp texture that are combined during rendering. Several styles of combining
 * (including bump-mapping) can be cycled through by repeatedly touching the sign.
 * The sign acts as a halo object, always facing the camera.
 */
-(void) addWoodenSign {
	// Texture for the basic wooden sign
	signTex = [[CC3Texture textureFromFile: kSignTextureFile] retain];

	// Texture for the stamp overlay.
	// Give it a configurable texture unit so we can play with the configuration.
	stampTex = [[CC3Texture textureFromFile: kSignStampTextureFile] retain];
	stampTex.textureUnit = [CC3ConfigurableTextureUnit textureUnit];
	
	// Texture that has a bump-map stamp, whose pixels contain normals instead of colors.
	// Give it a texture unit configured for bump-mapping. The rgbNormalMap indicates how
	// the X,Y & Z components of the normal are stored in the texture RGB components.
	embossedStampTex = [[CC3Texture textureFromFile: kSignStampNormalsTextureFile] retain];
	
	// Although there is also a dedicated CC3BumpMapTextureUnit that we'd usually
	// use for bump-mapping, we use CC3ConfigurableTextureUnit instead, to demonstrate
	// that it is possible, and also to make it easier to swap one texture for the other.
	CC3ConfigurableTextureUnit* ctu = [CC3ConfigurableTextureUnit textureUnit];
	ctu.combineRGBFunction = GL_DOT3_RGB;
	ctu.rgbSource1 = GL_CONSTANT;
	ctu.rgbNormalMap = kCC3DOT3RGB_YZX;
	embossedStampTex.textureUnit = ctu;
	
	// Create wooden sign, starting with wood sign texture
	woodenSign = [CC3PlaneNode nodeWithName: kSignName];
	[woodenSign populateAsCenteredRectangleWithSize: CGSizeMake(150.0, 150.0)
									andTessellation: ccg(4, 4)];
	woodenSign.texture = signTex;

	// Add the stamp overlay texture
	[woodenSign addTexture: stampTex];

	// Adjust the mesh to use only a section of the texture.
	// This feature can be used to extract a texture from a texture atlas,
	// so that a single loaded texture can be used to cover multiple meshes,
	// with each mesh covered by a different section fo the texture.
	woodenSign.textureRectangle = CGRectMake(0.4, 0.23, 0.35, 0.35);

	woodenSign.diffuseColor = kCCC4FCyan;
	woodenSign.specularColor = kCCC4FLightGray;
	woodenSign.isTouchEnabled = YES;		// Allow the sign to be selected by touch events.
	
	// The sign starts out in the X-Y plane and facing up the positive Z-axis.
	// Rotate the sign 90 degrees so that it faces the center of the scene.
	woodenSign.rotation = cc3v(0.0, 90.0, 0.0);
	
	// Add a label below the sign that identifies which combiner method is being used.
	// This label will be automatically updated whenever the user touches the wooden sign
	// to switch the combiner function.
	NSString* texEnvName = NSStringFromGLEnum(((CC3ConfigurableTextureUnit*)stampTex.textureUnit).combineRGBFunction);
	NSString* lblStr = [NSString stringWithFormat: kMultiTextureCombinerLabel, texEnvName];
	CCLabelTTF* bbLabel = [CCLabelTTF labelWithString: lblStr
											 fontName: @"Arial"
											 fontSize: 9.0];
	CC3Billboard* bb = [CC3Billboard nodeWithName: kSignLabelName withBillboard: bbLabel];
	bb.location = cc3v( 0.0, -90.0, 0.0 );
	bb.color = ccMAGENTA;
	bb.shouldUseLighting = NO;
	[woodenSign addChild: bb];
	
	// Allow the wooden sign to be viewed when the camera goes behind.
	woodenSign.shouldCullBackFaces = NO;
	
	// Add the wooden sign to the bump-map light tracker so that when the bump-map
	// texture overlay is displayed, it will interact with the light source.
	woodenSign.location = cc3v(-600.0, 250.0, -300.0);
	[bumpMapLightTracker addChild: woodenSign];
}

// Text to hold in userData of floating head and then log when the head is poked.
static NSString* kDontPokeMe = @"Owww! Don't poke me!";

/**
 * Adds a bump-mapped floating purple head to the scene.
 * 
 * Bump mapping works by applying a texture that contains normal data instead of colors.
 * This allows us to apply a different normal to every pixel of the texture, instead of
 * only at the vertices. This allows us to simulate 3D surface at a resolution much
 * higher than the vertices permit.
 * 
 * The floating head has much higher 3D definitional resolution that provided by the
 * relatively low vertex count mesh. The mesh only contains 153 vertices.
 *
 * You'll notice that the light shadowing changes correctly as the light moves up and
 * down, and as you move the camera around, which causes the head to rotate to follow you.
 */
-(void) addFloatingHead {

	// We introduce a specialized resource subclass, not because it is needed in general,
	// but because the POD file containing the head model contains an erroneous reference
	// to a texture file that does not actually exist. This specialized resource subclass
	// avoids this erroneous reference.
	CC3PODResourceNode* podRezNode = [CC3PODResourceNode nodeWithName: kPODHeadRezNodeName];
	podRezNode.resource = [HeadPODResource resourceFromFile: kHeadPODFile];

	// Extract the floating head mesh node and set it to be touch enabled
	floatingHead = [podRezNode getMeshNodeNamed: kFloatingHeadName];
	floatingHead.isTouchEnabled = YES;
	
	// Demonstrate the use of applicaiton-specific data attached to a node.
	floatingHead.userData = kDontPokeMe;
	
	// The floating head normal texture was created in a left-handed coordinate
	// system (eg- DirectX). OpenGL uses a right-handed coordinate system.
	// The difference means that the bump-map normals interact as if the light
	// was coming from the opposite direction. We can correct for this by flipping
	// the normal texture horizontally by flipping the textue mapping coordinates
	// of the mesh horizontally.
	[floatingHead flipTexturesHorizontally];

	// The origin of the floating head mesh is at the bottom. It suits our purposes better to
	// have the origin of the mesh at the center of geometry. The method we invoke here changes
	// the value of every vertex in the mesh. So we should only ever want to do this once per mesh.
	[floatingHead moveMeshOriginToCenterOfGeometry];
	
	// Texture that has a bump-map stamp, whose pixels contain normals instead of colors.
	// Give it a texture unit configured for bump-mapping. The rgbNormalMap indicates how
	// the X,Y & Z components of the normal are stored in the texture RGB components.
	headBumpTex = [[CC3Texture textureFromFile: kHeadBumpFile] retain];
	headBumpTex.textureUnit = [CC3BumpMapTextureUnit textureUnit];
	headBumpTex.textureUnit.rgbNormalMap = kCC3DOT3RGB_YZX;
	
	// Load the visible texture of the floating head, and add it as an overlay on the bump map texture.
	headTex = [[CC3Texture textureFromFile: kHeadTextureFile] retain];

	// The two textures are PVR textures pre-loaded with mipmaps.
	// However, using the mipmap for this mesh creates a visual artifact around the
	// fringe of the model. So we'll just use linear filtering on the main texture.
	// Comment out these two lines if you want to see the difference.
	headBumpTex.minifyingFunction = GL_LINEAR;
	headTex.minifyingFunction = GL_LINEAR;

	// Add the bump-map texture and the color texture to the material.
	[floatingHead.material addTexture: headBumpTex];
	[floatingHead.material addTexture: headTex];
	
	// Put the head node in an orienting wrapper so that we can orient it to face
	// the camera. First turn the floating head to face right so that it points
	// towards the side of the wrapper that will be kept facing the camera, and
	// move the head to the origin of the wrapper.
	// Add the orienting node to the bump-map light tracker so that the bump-map
	// in the floating head will interact with the light source.
	floatingHead.rotation = cc3v(0, -90, 0);
	floatingHead.location = kCC3VectorZero;
	CC3Node* headHolder = [floatingHead asCameraTrackingWrapper];
	headHolder.location = cc3v(-500.0, 200.0, 0.0);
	[bumpMapLightTracker addChild: headHolder];
}

/**
 * Loads a POD file containing the cocos3d mascot, and creates a copy of it so that we have
 * two mascots. One mascot always stares back at the camera, regardless of where the camera
 * moves to. The other is distracted by the rainbow teapot and its gaze follows the teapot
 * as the rainbow teapot moves.
 *
 * The cocos2d/cocos3d mascot model was created by Alexandru Barbulescu, and used by permission.
 */
-(void) addMascots {

	// Create the mascots. Load the first from file, then copy to create the second.
	CC3PODResourceNode* podRezNode = [CC3PODResourceNode nodeFromFile: kMascotPODFile];
	mascot = [podRezNode getMeshNodeNamed: kMascotName];
	CC3MeshNode* distractedMascot = [[mascot copyWithName: kDistractedMascotName] autorelease];
	
	// Allow the mascots to be selected by touch events.
	mascot.isTouchEnabled = YES;
	distractedMascot.isTouchEnabled = YES;

	// Scale the mascots
	mascot.uniformScale = 22.0;
	distractedMascot.uniformScale = 22.0;
	
	// Create the wrapper for the mascot that stares back at the camera.
	// Rotate the mascot in the wrapper so that the correct side faces the camera
	// as the wrapper tracks the camera.
	CC3Node* mascotHolder = [mascot asCameraTrackingWrapper];
	mascot.rotation = cc3v(0, -90, 0);
	mascotHolder.location = cc3v(-450.0, 100.0, -575.0);
	[self addChild: mascotHolder];

	// Arrange for the mascot to be distracted by the rainbow teapot's movements.
	// We could have the mascot track the teapot itself. But, the wrong side would
	// face the teapot. To have the correct side of the mascot face the teapot, we
	// add it to a wrapper, turn it to look to the right within the wrapper, and
	// then arrange for the wrapper to track the rainbow teapot.
	CC3Node* distractedMascotHolder = [distractedMascot asTrackingWrapper];
	distractedMascot.rotation = cc3v(0, -90, 0);
	distractedMascotHolder.location = cc3v(-375.0, 100.0, -700.0);
	distractedMascotHolder.target = teapotSatellite;
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
 * Adds a sun in the sky, in the form of a standard cocos2d particle emitter,
 * held in the 3D scene by a CC3Billboard. The sun is a very large particle
 * emitter, and you should notice a drop in frame rate when it is visible.
 */
-(void) addSun {
	// Create the cocos2d 2D particle emitter.
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

	bb.shouldUseLighting = NO;		// Sun material not affected by lighting!
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
	spotLight.attenuationCoefficients = CC3AttenuationCoefficientsMake(0.0, 0.002, 0.000001);
	spotLight.isDirectionalOnly = NO;
	[self.activeCamera addChild: spotLight];
}

/**
 * Adds fog to the scene. The fog is initially turned off, but will be turned on when
 * the sun button is toggled. The fog cycles in color between bluish and reddish tones.
 */
-(void) addFog {
	self.fog = [CC3Fog fog];
	fog.visible = NO;
	fog.color = ccc3(128, 128, 180);		// A slightly bluish fog.

	// Choose one of GL_LINEAR, GL_EXP and GL_EXP2
	fog.attenuationMode = GL_EXP2;

	// If using GL_EXP or GL_EXP2, the density property will have effect.
	fog.density = 0.0017;
	
	// If using GL_LINEAR, the start and end distance properties will have effect.
	fog.startDistance = 200.0;
	fog.endDistance = 1500.0;

	// To make things a bit more interesting, set up a repeating up/down cycle to
	// change the color of the fog from the original bluish to reddish, and back again.
	GLfloat tintTime = 4.0f;
	ccColor3B startColor = fog.color;
	ccColor3B endColor = ccc3(180, 128, 128);		// A slightly redish fog.
	CCActionInterval* tintDown = [CCTintTo actionWithDuration: tintTime
														  red: endColor.r
														green: endColor.g
														 blue: endColor.b];
	CCActionInterval* tintUp = [CCTintTo actionWithDuration: tintTime
														red: startColor.r
													  green: startColor.g
													   blue: startColor.b];
	CCActionInterval* tintCycle = [CCSequence actionOne: tintDown two: tintUp];
	[fog runAction: [CCRepeatForever actionWithAction: tintCycle]];
}

/**
 * Adds a mallet that moves back and forth, alternately hammering two anvils.
 * The mallet's mesh employs vertex skinning and an animated bone skeleton to
 * simulate smooth motion and realistic flexibility.
 */
-(void) addSkinnedMallet {
	// Load the POD file and remove its cmera since we won't need it.
	// This is not actually necessary, but demonstrates that the resources loaded from
	// a POD file, including the resource node, are just nodes that can be manipulated
	// like any other node assembly.
	CC3PODResourceNode* malletAndAnvils = [CC3PODResourceNode nodeFromFile: kMalletPODFile];
	[[malletAndAnvils getNodeNamed: @"Camera01"] remove];
	[[malletAndAnvils getNodeNamed: @"Camera01Target"] remove];

	CC3MeshNode* mallet = [malletAndAnvils getMeshNodeNamed: kMalletName];
	
	// Mallet normal transforms are scaled too far during transforms, so force
	// the normals to be individually re-normalized after being transformed.
	mallet.normalScalingMethod = kCC3NormalScalingNormalize;

	// The mallet can flex well outside its initial mesh bounding box.
	// Define a fixed bounding volume that includes the full range of the mallet motion
	// during vertex skinning. In this case, a simple way of determining this is to use the
	// bounding box of the parent node that includes the anvils, which we can get by logging.
	// The first two commented lines below were used during development to help determine
	// the size of the bounding box of the parent node.
//	mallet.shouldDrawLocalContentWireframeBox = YES;
//	LogDebug(@"%@ bounding box %@", malletAndAnvils, NSStringFromCC3BoundingBox(malletAndAnvils.boundingBox));

	mallet.shouldUseFixedBoundingVolume = YES;
	CC3NodeSphereThenBoxBoundingVolume* bv = (CC3NodeSphereThenBoxBoundingVolume*)mallet.boundingVolume;
	bv.sphericalBoundingVolume.radius = 1500.0;
	bv.boxBoundingVolume.boundingBox = CC3BoundingBoxMake(-257.0, -1685.0, -1200.0, 266.0, 0.0, 1200.0);

	malletAndAnvils.isTouchEnabled = YES;		// make the mallet touchable
	
	malletAndAnvils.location = cc3v(300.0, 95.0, 300.0);
	malletAndAnvils.rotation = cc3v(0.0, -45.0, 0.0);
	malletAndAnvils.uniformScale = 0.15;
	[self addChild: malletAndAnvils];
	
	CCActionInterval* hammering = [CC3Animate actionWithDuration: 3.0];
	[malletAndAnvils runAction: [CCRepeatForever actionWithAction: hammering]];

	// Spin the mallet and anvils around for effect
	[malletAndAnvils runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																						  rotateBy: cc3v(0.0, 10.0, 0.0)]]];
}

/**
 * Adds two running men to the scene. The men runs endless laps around the scene.
 * The men's meshes employ vertex skinning and an animated bone skeleton to
 * simulate smooth motion and realistic joint flexibility.
 */
-(void) addSkinnedRunners {

	// Load the first running man from the POD file. Since the meshes were not
	// specifically created for iOS, the textures will appear upside-down because
	// it uses a texture type (png) that is loaded upside-down by iOS. We tell
	// the resource loader that the mesh is not aligned to upside-down textures
	// so that the texture coordinates will be flipped upside down automatically
	// so that the textures will appear right-way up.
	CC3ResourceNode* runner = [CC3PODResourceNode nodeWithName: kRunnerName];
	runner.resource.expectsVerticallyFlippedTextures = NO;
	[runner loadFromFile: kRunningManPODFile];

	// Remove the light provided in the POD so that it does not contribute to the
	// lighting of the scene. We don't remove the POD's camera, but we rename it
	// so that we can retrieve it distinctly from the camera loaded with the robot
	// arm POD. All SDK POD files seem to use the same name for their included cameras.
	// We also adjust the far clipping distance of the runner camera to match the
	// main camera, and we set the depth of field to infinite so that it will display
	// shadow volumes correctly.
	[runner getNodeNamed: kRunnerLampName].visible = NO;
	CC3Camera* runnerCam = (CC3Camera*)[runner getNodeNamed: @"Camera01"];
	runnerCam.name = kRunnerCameraName;
	runnerCam.farClippingDistance = self.activeCamera.farClippingDistance;
	runnerCam.hasInfiniteDepthOfField = YES;

	runner.isTouchEnabled = YES;		// make the runner touchable
	
	// Create a running track at the scene's center.
	// This "running track" is really just a structural node on which we can place the man
	// and then rotate the "track" to move the man. It's really just an invisible boom
	// holding the man.
	CC3Node* runningTrack = [CC3Node nodeWithName: kRunningTrackName];
	runningTrack.location = ground.location;
	[self addChild: runningTrack];

	// Place the man on the track, near the edge of the ground frame
	runner.location = cc3v(0, 0, 900);
	runner.rotation = cc3v(0, 90, 0);	// Rotate the entire POD resource so camera rotates as well
	[runningTrack addChild: runner];

	// Run, man, run!
	// The POD node contains animation to move the skinned character through a running stride.
	// Make each stride 1.2 seconds in duration.
	CCActionInterval* stride = [CC3Animate actionWithDuration: 2.4];
	[runner runAction: [CCRepeatForever actionWithAction: stride]];

	// Make him run around a circular track by rotating the "track" around the scene's center,
	// and it will carry the man around in a circle with it. By trial and error, set the
	// rotation to match to take 15 seconds for a full circle, to match the man's stride.
	CCActionInterval* runLap = [CC3RotateBy actionWithDuration: 30.0 rotateBy: cc3v(0.0, 360.0, 0.0)];
	[runningTrack runAction: [CCRepeatForever actionWithAction: runLap]];

	// To demonstrate copying of skinned nodes, add another runner that is a copy, but smaller and
	// with a faster stride. We don't want the runner's POD camera or light, so we'll retrieve the
	// running figure from the POD resource and just copy that. This demonstrates how we can animate
	// either the whole POD resource node, or the specific soft-body node.
	NSString* runnerFigureName = [NSString stringWithFormat: @"%@-SoftBody", kRunningManPODFile];
	CC3Node* runnerFigure = [runner getNodeNamed: runnerFigureName];
	CC3Node* littleBrother = [[runnerFigure copyWithName: kLittleBrotherName] autorelease];
	littleBrother.uniformScale = 0.75f;
	littleBrother.location = cc3v(0, 0, 800);
	littleBrother.rotation = cc3v(0, 90, 0);	// Copied runner was not rotated (its parent was)
	littleBrother.isTouchEnabled = YES;		// make the runner touchable

	[runningTrack addChild: littleBrother];
	stride = [CC3Animate actionWithDuration: 1.6];
	[littleBrother runAction: [CCRepeatForever actionWithAction: stride]];
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
	// Each particle has an individual location, color, size, and normal vector so that it
	// interacts with light sources. You can change this parameter to see different options.
	CC3PointParticleEmitter* emitter = [CC3PointParticleEmitter nodeWithName: @"Particles"];
	emitter.particleClass = [HangingPointParticle class];
	emitter.maximumParticleCapacity = 1000;
	emitter.vertexContentTypes = kCC3VertexContentLocation |
								 kCC3VertexContentColor |
								 kCC3VertexContentNormal |
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

	// Uncomment to see effect of not using lighting.
	// Can also get same effect by not including kCC3VertexContentNormal in particle content above.
//	emitter.material.shouldUseLighting = NO;

	// Shows the bounding volume. The boundingVolumePadding gives the boundary some depth
	// so that the emitter doesn't disappear if particles are still on-screen.
	emitter.boundingVolumePadding = 20.0;
	emitter.shouldDrawLocalContentWireframeBox = YES;
	emitter.shouldUseFixedBoundingVolume = NO;

	emitter.isTouchEnabled = YES;		// Shows the emitter name when touched
	
	// Set the location of the emitter, and set it rotating for effect.
	emitter.location = cc3v(0.0, 150.0, kParticlesPerSide * kParticlesSpacing / 2.0f);
//	[emitter runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
//																				  rotateBy: cc3v(0.0, 15.0, 0.0)]]];
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
	[templateModel populateAsSolidBox: CC3BoundingBoxMake(-kMeshParticleCubeExtent,
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
	templateModel.texture = [CC3Texture textureFromFile: kMeshPartileTextureFile];
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
//	emitter.material.shouldUseLighting = NO;
	
	// Shows the bounding volume. The boundingVolumePadding gives the boundary some depth
	// so that the emitter doesn't disappear if particles are still on-screen.
	emitter.boundingVolumePadding = 20.0;
	emitter.shouldDrawLocalContentWireframeBox = YES;
	emitter.shouldUseFixedBoundingVolume = NO;
	
	emitter.isTouchEnabled = YES;		// Shows the emitter name when touched
	
	// Set the location of the emitter, and set it rotating for effect.
	emitter.location = cc3v(0.0, 150.0, kParticlesPerSide * kParticlesSpacing / 2.0f);
//	[emitter runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
//																				  rotateBy: cc3v(0.0, 15.0, 0.0)]]];
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
//	bv.boxBoundingVolume.boundingBox = CC3BoundingBoxMake(-659.821, -408.596, -657.981, 651.606, 806.223, 637.516);

	// Shows the emitter name and location when the particles are touched
	emitter.isTouchEnabled = YES;
	
	// We don't want the emitter's bounding volume (which will be quite large)
	// participating in any ray tracing.
	emitter.shouldIgnoreRayIntersection = YES;

	// Configure the ranges for the beginning and ending particle size and color.
	emitter.minParticleStartingSize = 20.0f;
	emitter.maxParticleStartingSize = 40.0f;					// Starting at 20-40 pixels wide
	emitter.minParticleEndingSize = kCC3ParticleConstantSize;
	emitter.maxParticleEndingSize = kCC3ParticleConstantSize;	// Stay same size will alive
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

	// To see the bounding volumes of the emitter, uncomment the following line.
	// The bounding volume of most nodes contains both a spherical and bounding-box
	// bounding volume to optimize intersection testing. Touch the robot arm to see
	// the bounding volume of the particle emitter grow and shrink dynamically.
	// Use the joystick controls to back the camera away to get the full effect.
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
	[boxModel populateAsSolidBox: CC3BoundingBoxMake(-kPartMeshDim, -kPartMeshDim, -kPartMeshDim,
													  kPartMeshDim, kPartMeshDim, kPartMeshDim)];
	boxModel.texture = [CC3Texture textureFromFile: kMeshPartileTextureFile];
	boxModel.textureRectangle = CGRectMake(0, 0, 1, 0.75);	// Bottom part of texture is box texture
	CC3VertexArrayMesh* boxMesh = (CC3VertexArrayMesh*)boxModel.mesh;

	// Sphere template mesh
	CC3MeshNode* ballModel = [CC3MeshNode node];
	[ballModel populateAsSphereWithRadius: (kPartMeshDim * 1.5) andTessellation: ccg(8, 7)];
	ballModel.texture = [CC3Texture textureFromFile: kMeshPartileTextureFile];
	ballModel.textureRectangle = CGRectMake(0, 0.75, 1, 0.25);	// Top part of texture is ball texture
	CC3VertexArrayMesh* ballMesh = (CC3VertexArrayMesh*)ballModel.mesh;
	
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
	emitter.texture = [CC3Texture textureFromFile: kMeshPartileTextureFile];
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
//	bv.boxBoundingVolume.boundingBox = CC3BoundingBoxMake(-400.0, -100.0, -500.0, 500.0, 750.0, 500.0);
	
	// Even without a fixed bounding volume, you can still improve performance when the particles
	// are not in view of the camera by setting the following property to NO.
	// However, this can sometimes create a visually jarring effect when the particles come back
	// into view. See the notes of the shouldTransformUnseenParticles property for more info.
	emitter.shouldTransformUnseenParticles = YES;
	
	// Shows the emitter name and location when the particles are touched
	emitter.isTouchEnabled = YES;
	
	// We don't want the emitter's bounding volume (which will be quite large)
	// participating in any ray tracing.
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
 * Adds a temporary fiery explosion on top of the specified node, using a cocos2d
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
	bb.shouldUseLighting = NO;								// Solid coloring
	bb.shouldInheritTouchability = NO;						// Don't allow flames to be touched

	// If the 2D particle system uses point particles instead of quads, attenuate the
	// particle sizes with distance realistically. This is not needed if the particle
	// system will always use quads, but it doesn't hurt to set it.
	bb.particleSizeAttenuationCoefficients = CC3AttenuationCoefficientsMake(0.05, 0.02, 0.0001);
	
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

	// Uncomment the first line to have the camera move to show the entire scene.
	// Uncomment the second line to draw the bounding box of the scene.
//	[self.activeCamera moveWithDuration: kCameraMoveDuration toShowAllOf: self];
//	self.shouldDrawWireframeBox = YES;

	// Or uncomment this line to have the camera pan and zoom to focus on the cocos3d mascot.
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
	
	// To show where the POD light is, track the small white teapot to the current location
	// of the light. The actual direction vector is of unit length, so scale it to show the
	// direction of the light (through the white teapot towards the origin).
	teapotWhite.location = podLight.location;
 }

/** After all the nodes have been updated, check for collisions. */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor { [self checkForCollisions]; }

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
	if ( [teapotSatellite doesIntersectNode: brickWall] ) {

		// Get the direction from the teapot to the wall.
		CC3Vector tpDir = CC3VectorDifference(brickWall.globalLocation, teapotSatellite.globalLocation);		

		// If the teapot velocity is in the same direction as the vector from the
		// teapot to the wall, it is heading towards the wall. If so, turn it around
		// by getting the current spin action on the teapot holder and replacing it
		// with the reverse spin.
		if (CC3VectorDot(teapotSatellite.velocity, tpDir) > 0.0f) {
			LogInfo(@"BANG! %@ hit %@", teapotSatellite, brickWall);
			
			// Get the current spinning action.
			CCAction* spinAction = [teapotTextured getActionByTag: kTeapotRotationActionTag];
			
			// Reverse it and give it a tag so we can find it again.
			CCAction* revSpinAction = [spinAction reverse];
			revSpinAction.tag = kTeapotRotationActionTag;

			// Stop the old action and start the new one. 
			[teapotTextured stopAction: spinAction];
			[teapotTextured runAction: revSpinAction];
		}
	}
}

/** Update the location and direction of looking of the 3D camera */
-(void) updateCameraFromControls: (ccTime) dt {
	
	// Update the location of the player (the camera)
	if ( playerLocationControl.x || playerLocationControl.y ) {
		
		// Get the X-Y delta value of the control and scale it to something suitable
		CGPoint delta = ccpMult(playerLocationControl, dt * 100.0);

		// We want to move the camera forward and backward, and side-to-side,
		// from the camera's (the user's) point of view.
		// Forward and backward will be along the globalForwardDirection of the camera,
		// and side-to-side will be along the globalRightDirection of the camera.
		// These two directions are scaled by Y and X delta components respectively, which
		// in turn are set by the joystick, and combined into a single directional vector.
		// This represents the movement of the camera. The new location is simply the old
		// camera location plus the movement.
		CC3Vector moveVector = CC3VectorAdd(CC3VectorScaleUniform(activeCamera.globalRightDirection, delta.x),
											CC3VectorScaleUniform(activeCamera.globalForwardDirection, delta.y));
		activeCamera.location = CC3VectorAdd(activeCamera.location, moveVector);
	}

	// Update the direction the camera is pointing by panning and inclining using rotation.
	if ( playerDirectionControl.x || playerDirectionControl.y ) {
		CGPoint delta = ccpMult(playerDirectionControl, dt * 30.0);		// Factor to set speed of rotation.
		CC3Vector camRot = activeCamera.rotation;
		camRot.y -= delta.x;
		camRot.x += delta.y;
		activeCamera.rotation = camRot;	
	}
}

/**
 * When the user hits the switch-camera-target button, cycle through a series of four
 * different camera targets. The actual movement of the camera to home in on a new target
 * is handled by a CCActionInterval, so that the movement appears smooth and animated.
 */
-(void) switchCameraTarget {
	if (camTarget == origCamTarget) {
		camTarget = globe;
	} else if (camTarget == globe) {
		camTarget = beachBall;
	} else if (camTarget == beachBall) {
		camTarget = teapotTextured;
	} else if (camTarget == teapotTextured) {
		camTarget = mascot;
	} else if (camTarget == mascot) {
		camTarget = woodenSign;
	} else if (camTarget == woodenSign) {
		camTarget = floatingHead;
	} else if (camTarget == floatingHead) {
		camTarget = dieCube;
	} else {
		camTarget = origCamTarget;
	}
	self.activeCamera.target = nil;			// Ensure the camera is not locked to the original target
	[self.activeCamera stopAllActions];
	[self.activeCamera runAction: [CC3RotateToLookAt actionWithDuration: 2.0
														 targetLocation: camTarget.globalLocation]];
	LogInfo(@"Camera target toggled to %@", camTarget);
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
	CC3Node* robotTemplate = [[self getNodeNamed: kPODRobotRezNodeName] autoreleasedCopy];
	[[robotTemplate getNodeNamed: kPODLightName] remove];
	[[robotTemplate getNodeNamed: kPODCameraName] remove];
	[[robotTemplate getNodeNamed: kBillboardName] remove];

	// In the original robot arm, each component is individually selectable.
	// For the army, we wont bother with this level of detail, and we'll just
	// select the whole assembly (actually the resource node) whenever any part
	// of the robot is touched. This is done by first removing the individual
	// enablement that we set on the original, and then just enabling the top level.
	[robotTemplate touchDisableAll];
	robotTemplate.isTouchEnabled = YES;

	// Make these robots smaller to distinguish them from the original
	robotTemplate.uniformScale = 0.5;
	
	[self invadeWithArmyOf: robotTemplate];
}

/** Create a landing craft and populate it with an army of teapots. */
-(void) invadeWithTeapotArmy {
	// First create a template node by copying the POD resource node.
	CC3Node* teapotTemplate = [[self getNodeNamed: kTeapotWhiteName] autoreleasedCopy];
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
	landingCraft.location = ground.location;
	[ground addAndLocalizeChild: landingCraft];
}

/** Cycle between sunshine, fog and spotlight. */
-(BOOL) cycleLights {
	CC3Node* sun = [self getNodeNamed: kSunName];
	CC3Node* spotLight = [self getNodeNamed: kSpotlightName];
	
	if (sun.visible) {
		if (fog.visible) {		// Cycle to spotlight
			sun.visible = NO;
			fog.visible = NO;
		} else {				// Cycle to fog
			fog.visible = YES;
		}
	} else {					// Cycle to sun and clear skies
		fog.visible = NO;
		sun.visible = YES;
	}
	// If the sun is shining, turn on the CC3Light from the POD file, and turn off the
	// spotlight, and vice-versa if the sun is not shining. Set the target of the bump-map
	// tracker to be the active light source.
	podLight.visible = sun.visible;
	spotLight.visible = !podLight.visible;
	bumpMapLightTracker.target = podLight.visible ? podLight : spotLight;
	return sun.visible;
}

/**
 * Cycle between current camera view and two views showing the complete scene.
 * When the full scene is showing, a wireframe is drawn so we can easily see its extent.
 */
-(void) cycleZoom {
	CC3Camera* cam = self.activeCamera;
	[cam stopAllActions];						// Stop any current camera motion
	switch (cameraZoomType) {

		// Currently in normal view. Remember orientation of camera, turn on wireframe
		// and move away from the scene along the line between the center of the scene
		// and the camera until everything in the scene is visible.
		case kCameraZoomNone:
			lastCameraOrientation = CC3RayFromLocDir(cam.globalLocation, cam.globalForwardDirection);
			self.shouldDrawWireframeBox = YES;
			[cam moveWithDuration: kCameraMoveDuration toShowAllOf: self];
			cameraZoomType = kCameraZoomStraightBack;	// Mark new state
			break;
		
		// Currently looking at the full scene.
		// Move to view the scene from a different direction.
		case kCameraZoomStraightBack:
			self.shouldDrawWireframeBox = YES;
			[cam moveWithDuration: kCameraMoveDuration
					  toShowAllOf: self
					fromDirection: cc3v(-1.0, 1.0, 1.0)];
			cameraZoomType = kCameraZoomBackTopRight;	// Mark new state
			break;

		// Currently in second full-scene view.
		// Turn off wireframe and move back to the original location and orientation.
		case kCameraZoomBackTopRight:
		default:
			self.shouldDrawDescriptor = NO;
			self.shouldDrawWireframeBox = NO;
			[cam runAction: [CC3MoveTo actionWithDuration: kCameraMoveDuration
												   moveTo: lastCameraOrientation.startLocation]];
			[cam runAction: [CC3RotateToLookTowards actionWithDuration: kCameraMoveDuration
													  forwardDirection: lastCameraOrientation.direction]];
			cameraZoomType = kCameraZoomNone;	// Mark new state
			break;
	}
}


#pragma mark Gesture handling

-(void) startMovingCamera { cameraMoveStartLocation = activeCamera.location; }

-(void) stopMovingCamera {}

/** Set this parameter to adjust the rate of camera movement during a pinch gesture. */
#define kCamPinchMovementUnit		250

-(void) moveCameraBy:  (CGFloat) aMovement {

	// Convert to a logarithmic scale, zero is backwards, one is unity, and above one is forward.
	GLfloat camMoveDist = logf(aMovement) * kCamPinchMovementUnit;

	CC3Vector moveVector = CC3VectorScaleUniform(activeCamera.globalForwardDirection, camMoveDist);
	activeCamera.location = CC3VectorAdd(cameraMoveStartLocation, moveVector);
}

-(void) startPanningCamera { cameraPanStartRotation = activeCamera.rotation; }

-(void) stopPanningCamera {}

-(void) panCameraBy:  (CGPoint) aMovement {
	CC3Vector camRot = cameraPanStartRotation;
	CGPoint panRot = ccpMult(aMovement, 90);		// Full pan swipe is 90 degrees
	camRot.y += panRot.x;
	camRot.x -= panRot.y;
	activeCamera.rotation = camRot;	
}

-(void) startDraggingAt: (CGPoint) touchPoint { [self pickNodeFromTapAt: touchPoint]; }

-(void) dragBy: (CGPoint) aMovement atVelocity: (CGPoint) aVelocity {
	if (selectedNode == dieCube || selectedNode == texCubeSpinner) {
		[self rotate: ((SpinningNode*)selectedNode) fromSwipeVelocity: aVelocity];
	}
}

-(void) stopDragging { selectedNode = nil; }

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
 * If gestures are being used (see the shouldUseGestures variable in the initializeControls method
 * of CC3DemoMashUpLayer), this method will not be invoked. Instead, the gestures invoke handler
 * methods on the CC3DemoMashUpLayer, which then issues higher-level control messages to this scene.
 *
 * It is generally recommended that you use gestures to provide user interaction with the 3D scene.
 */
-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
	struct timeval now;
	gettimeofday(&now, NULL);

	// Time since last event
	ccTime dt = (now.tv_sec - lastTouchEventTime.tv_sec) + (now.tv_usec - lastTouchEventTime.tv_usec) / 1000000.0f;

	switch (touchType) {
		case kCCTouchBegan:
			[self pickNodeFromTouchEvent: touchType at: touchPoint];
			break;
		case kCCTouchMoved:
			if (selectedNode == dieCube || selectedNode == texCubeSpinner) {
				[self rotate: ((SpinningNode*)selectedNode) fromSwipeAt: touchPoint interval: dt];
			}
			break;
		case kCCTouchEnded:
			if (selectedNode == dieCube || selectedNode == texCubeSpinner) {
				// If the user lifted the finger while in motion, let the cubes know
				// that they can freewheel now. But if the user paused before lifting
				// the finger, consider it stopped.
				((SpinningNode*)selectedNode).isFreeWheeling = (dt < 0.5);
			}
			selectedNode = nil;
			break;
		default:
			break;
	}
	
	// For all event types, remember when and where the touchpoint was, for subsequent events.
	lastTouchEventPoint = touchPoint;
	lastTouchEventTime = now;
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
-(void) rotate: (SpinningNode*) aNode fromSwipeAt: (CGPoint) touchPoint interval: (ccTime) dt {
	
	CC3Camera* cam = self.activeCamera;

	// Get the direction and length of the movement since the last touch move event, in
	// 2D screen coordinates. The 2D rotation axis is perpendicular to this movement.
	CGPoint swipe2d = ccpSub(touchPoint, lastTouchEventPoint);
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
 * Most nodes are simply temporarily highlighted by running a cocos2d tinting action on
 * the emission color property of the node (which affects the emission color property of
 * the materials underlying the node).
 *
 * Some nodes have other, or additional, behaviour. Nodes with special behaviour include
 * the ground, the die cube, the beach ball, the textured and rainbow teapots, and the wooden sign.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {

	// If in "managing shadows" mode, cycle through a variety of shadowing techniques.
	if (isManagingShadows) {
		[self cycleShadowFor: aNode];
		return;
	}
	
	// Remember the node that was selected
	selectedNode = aNode;
	
	// Uncomment to toggle the display of a descriptor label on the node
//	aNode.shouldDrawDescriptor = !aNode.shouldDrawDescriptor;

	// Briefly highlight the location where the node was touched.
	[self markTouchPoint: touchPoint on: aNode];
	
	// Don't visually highlight ground or wooden sign when touched. Handle these objects differently.
	if (aNode == ground) {
		[self touchGroundAt: touchPoint];
	} else if (aNode == beachBall) {
		// If the beach ball is touched toggle its opacity.
		[self touchBeachBallAt: touchPoint];
		
		// For fun, uncomment the following line to draw a wireframe box around the beachball
//		aNode.shouldDrawWireframeBox = !aNode.shouldDrawWireframeBox;
		
	} else if (aNode == brickWall) {
		[self touchBrickWallAt: touchPoint];
	} else if (aNode == woodenSign) {
		[self switchWoodenSign];
	} else if (aNode == floatingHead) {
		[self toggleFloatingHeadDefinition];
	} else if (aNode == dieCube || aNode == texCubeSpinner) {
		// These are spun by touch movement. Do nothing...and don't highlight
	} else if (aNode == [self getNodeNamed: kRunnerName]) {
		[self toggleActiveCamera];
	} else if (aNode == [self getNodeNamed: kLittleBrotherName]) {
		[self toggleActiveCamera];
	} else if (aNode == [self getNodeNamed: kBitmapLabelName]) {
		[self cycleLabelOf: (CC3BitmapLabelNode*)aNode];
	} else {
		
		// If the node is either the textured or rainbow teapot, toggle the display of
		// a wireframe of its bounding box, plus a wireframe around both teapots.
		if (aNode == teapotTextured || aNode == teapotSatellite) {
			
			// Toggle wireframe box around the touched teapot's mesh
			CC3LocalContentNode* lcNode = (CC3LocalContentNode*)aNode;
			lcNode.shouldDrawLocalContentWireframeBox = !lcNode.shouldDrawLocalContentWireframeBox;

			// Toggle the large wireframe box around both teapots
			teapotTextured.shouldDrawWireframeBox = !teapotTextured.shouldDrawWireframeBox;
		}

		// If the robot was touched, cycle through three particle hose options.
		// If no particles are being emitting, turn on the point particle hose.
		// If the point particle hose is emitting, turn it off and turn on the mesh particle hose.
		// If the mesh particle hose is emitting, turn it off so neither hose is emitting.
		if (aNode == [self getNodeNamed: kPODRobotRezNodeName] ) {
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
		}
		
		// If the globe was touched, toggle the opening of a HUD window displaying it up close.
		if (aNode == globe ) {
			[((CC3DemoMashUpLayer*)self.cc3Layer) toggleGlobeHUDFromTouchAt: touchPoint];
		}
	}
}

/**
 * Unproject the 2D touch point into a 3D global-coordinate ray running from
 * the camera through the touched node. Find the node that is punctured by the
 * ray, the location at which the ray punctures the node's bounding volume
 * in the local coordinates of the node, and add a temporary visible marker
 * at that local location that fades in and out, and then removes itself.
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
	CCActionInterval* fadeIn = [CCFadeIn actionWithDuration: 0.3];
	CCActionInterval* fadeOut = [CCFadeOut actionWithDuration: 5.0];
	CCActionInstant* remove = [CCCallFunc actionWithTarget: dn selector: @selector(remove)];
	[dn runAction: [CCSequence actions: fadeIn, fadeOut, remove, nil]];
	
	// Set the location of the descriptor node to the touch location,
	// which are in the touched node's local coordinates, and add the
	// descriptor node to the touched node.
	dn.location = nodeTouchLoc;
	[localNode addChild: dn];

	// Log everything that happened.
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"You selected %@", aNode];
	[desc appendFormat: @" located at %@", NSStringFromCC3Vector(aNode.globalLocation)];
	[desc appendFormat: @", or at %@ in 2D.", NSStringFromCC3Vector([activeCamera projectNode: aNode])];
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
 * ability to add cocos2d CCParticleSystems into the 3D scene.
 */
-(void) touchGroundAt: (CGPoint) touchPoint {
	CC3Plane groundPlane = ground.plane;
	CC3Vector4 touchLoc = [self.activeCamera unprojectPoint: touchPoint ontoPlane: groundPlane];

	// Make sure the projected touch is in front of the camera, not behind it
	// (ie- cam is facing towards, not away from, the ground)
	if (touchLoc.w > 0.0) {
		CC3MeshNode* tp = [[teapotWhite copyWithName: kTeapotOrangeName] autorelease];
		tp.color = ccORANGE;
		tp.location = CC3VectorFromTruncatedCC3Vector4(touchLoc);
		
		[self addExplosionTo: tp];	// For effect, add an explosion as the teapot is placed
		
		// We've set the teapot location to the global 3D point that was derived from the
		// touch point, and the teapot has a global rotation of zero, and a global scale.
		// When we add it to the ground plane, we don't want those properties to be further
		// transformed by the ground plane's existing transform. Therefore, the teapot
		// transform properties must be localized to properties that are relative to those
		// of the ground plane. We can do that using the addAndLocalizeChild: method.
		[ground addAndLocalizeChild: tp];
	}
}

/**
 * If the node is the beach ball, toggle it between opaque and translucent.
 * Note that the alpha values of all the colors stay the same, it's only
 * the blending functions that change. See the notes for the isOpaque property
 * of CC3Material for more on the interaction between this property and the
 * other material properties.
 */
-(void) touchBeachBallAt: (CGPoint) touchPoint {

	// Because the beach ball is a composite node, and we add a fading touch location
	// descriptor node as a child to it when the beach ball is touched we can't trust
	// the value of the isOpaque property of the beach ball node. Instead, we need to
	// dig into one of its mesh node segments to determine its opaqueness.
	BOOL isBallOpaque = [beachBall getNodeNamed: kBeachBallWhiteSegment].isOpaque;
	beachBall.isOpaque = !isBallOpaque;

	// Also toggle the opacity. This is necessary only if the background layer
	// is translucent and showing the device camera scene.
	beachBall.opacity = beachBall.isOpaque ? 255 : (255 * 0.75);
}

/** When the brick wall is touched, slide it back and forth to open or close it. */
-(void) touchBrickWallAt: (CGPoint) touchPoint {
	CC3Vector destination = brickWall.isOpen ? kBrickWallClosedLocation : kBrickWallOpenLocation;
	CCActionInterval* moveAction = [CC3MoveTo actionWithDuration: 3.0 moveTo: destination];
	// Add a little bounce for realism.
	moveAction = [CCEaseElasticOut actionWithAction: moveAction period: 0.5];
	[brickWall stopAllActions];
	[brickWall runAction: moveAction];
	brickWall.isOpen = !brickWall.isOpen;
}

/**
 * Switch the multi-texture displayed on the wooden sign node to the next texture
 * combination function in the cycle. There are two basic examples of texture combining
 * demonstrated here. The first is a series of methods of combining regular RGB textures.
 * The second is DOT3 bump-mapping which uses the main texture as a normal map to
 * interact with the lighting, and then overlaying the wooden sign texture onto it.
 * The effect of this last type of combining is to add perceived embossing to the
 * wooden texture.
 *
 * Once the multi-texture combining function is determined, the name of it is set in
 * the label that hovers above the wooden sign.
 */
-(void) switchWoodenSign {
	CC3Texture* mainTex = woodenSign.texture;
	CC3Texture* stampOverlay = stampTex;
	CC3ConfigurableTextureUnit* stampTU = (CC3ConfigurableTextureUnit*)stampOverlay.textureUnit;

	// If showing embossed DOT3 multi-texture, switch it to stamped texture with modulation.
	if (mainTex == embossedStampTex) {
		[woodenSign removeAllTextures];
		[woodenSign addTexture: signTex];
		[woodenSign addTexture: stampTex];
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
				[woodenSign removeAllTextures];
				[woodenSign addTexture: embossedStampTex];
				[woodenSign addTexture: signTex];
				stampOverlay = embossedStampTex;		// For bump-map, the combiner function is in the main texture
				stampTU = (CC3ConfigurableTextureUnit*)stampOverlay.textureUnit;
				break;
			default:
				break;
		}
	}
	
	// Get the label on top of the wooden sign, and update its contents to be
	// the name of the new multi-texture combining function, and re-measure the
	// bounding box of the CC3Billboard from the new size of the label.
	// Alternately, we could have set the shouldAlwaysMeasureBillboardBoundingRect
	// property on the CC3Billboard to have the bounding box measured automatically
	// on every update pass, at the cost of many unneccessary measurements when the
	// label text does not change.
	CC3Billboard* bbSign = (CC3Billboard*)[woodenSign getNodeNamed: kSignLabelName];
	id<CCLabelProtocol> signLabel = (id<CCLabelProtocol>)bbSign.billboard;
	[signLabel setString: [NSString stringWithFormat: kMultiTextureCombinerLabel,
						   NSStringFromGLEnum(stampTU.combineRGBFunction)]];
	[bbSign resetBillboardBoundingRect];
}

-(void) toggleFloatingHeadDefinition; {
	if (floatingHead.texture == headBumpTex) {
		[floatingHead.material removeAllTextures];
		[floatingHead.material addTexture: headTex];
	} else {
		[floatingHead.material removeAllTextures];
		[floatingHead.material addTexture: headBumpTex];
		[floatingHead.material addTexture: headTex];
	}
	
	// Demonstrate the use of application-specific data attached to a node, by logging the data.
	if (floatingHead.userData) {
		LogInfo(@"%@ says '%@'", floatingHead, floatingHead.userData);
	}
}

/** 
 * Toggle between the main scene camera and the camera running along with the runner.
 * When the runner's camera is active, turn on a local light to illuminate him.
 */
-(void) toggleActiveCamera {
	CC3Camera* robotCam = (CC3Camera*)[self getNodeNamed: kRobotCameraName];
	CC3Camera* runnerCam = (CC3Camera*)[self getNodeNamed: kRunnerCameraName];
	CC3Light* runnerLamp = (CC3Light*)[self getNodeNamed: kRunnerLampName];

	if (self.activeCamera == robotCam) {
		self.activeCamera = runnerCam;
		runnerLamp.visible = YES;
	} else {
		self.activeCamera = robotCam;
		runnerLamp.visible = NO;
	}
}

/** Cycles the specified bitmapped label node through a selection of label strings. */
-(void) cycleLabelOf: (CC3BitmapLabelNode*) bmLabel {
	switch (bmLabelMessageIndex) {
		case 0:
			bmLabel.labelString = @"Goodbye,\ncruel world.";
			bmLabel.color = ccRED;
			bmLabelMessageIndex++;
			break;
		default:
			bmLabel.labelString = @"Why,\nhello again,\nworld!";
			bmLabel.color = ccYELLOW;
			bmLabelMessageIndex = 0;
			break;
	}
}

/** Cycles through a variety of shadowing options for the specified node. */
-(void) cycleShadowFor: (CC3Node*) aNode {
	
	// Don't add a shadow to the ground
	if (aNode == ground) return;

	// If the node already has a shadow volume, remove it, otherwise add one.
	if ( [aNode hasShadowVolumesForLight: podLight] ) {
		[aNode removeShadowVolumesForLight: podLight];
		LogInfo(@"Removed shadow from: %@", aNode);
	} else {
		[aNode addShadowVolumesForLight: podLight];
		
		// The wooden sign is a planar mesh with no "other side", so it requires special
		// configuration. We indicate that we want to shadow back faces as well as front
		// faces, and we use vertex offsetting instead of decal offsetting.
		if (aNode == woodenSign) {
			aNode.shouldShadowBackFaces = YES;
			aNode.shadowOffsetUnits = 0;
			aNode.shadowVolumeVertexOffsetFactor = kCC3DefaultShadowVolumeVertexOffsetFactor;
		}
		LogInfo(@"Added shadow to: %@", aNode);
	}
}

@end

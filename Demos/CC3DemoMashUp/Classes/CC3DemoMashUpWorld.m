/*
 * CC3DemoMashUpWorld.m
 *
 * cocos3d 0.5.4
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3DemoMashUpWorld.h for full API documentation.
 */

#import "CC3DemoMashUpWorld.h"
#import "CC3Billboard.h"
#import "CC3ActionInterval.h"
#import "CC3ModelSampleFactory.h"
#import "LandingCraft.h"
#import "CCLabelTTF.h"
#import "CGPointExtension.h"
#import "CCTouchDispatcher.h"

// File names
#define kRobotPODFile			@"IntroducingPOD_float.pod"
#define kBallsPODFile			@"Balls.pod"
#define kGroundTextureFile		@"Default.png"
#define kFloaterTextureFile		@"ButtonRing48x48.png"

// Model names
#define kLandingCraftName		@"LandingCraft"
#define kPODRobotRezNodeName	@"RobotPODRez"
#define kPODLightName			@"FDirect01"
#define kPODCameraName			@"Camera01"
#define kRobotTopArm			@"TopArm"
#define kRobotBottomArm			@"BottomArm"
#define kRobotCylinder			@"Cylinder01"
#define kRobotBase				@"GeoSphere01"
#define kBeachBallName			@"BeachBall"
#define kGlobeName				@"Globe"
#define kTexturedTeapotName		@"Teapot"
#define kRainbowTeapotName		@"Satellite"
#define kTeapotHolderName		@"TeapotHolder"
#define kTeapotRedName			@"TeapotRed"
#define kTeapotGreenName		@"TeapotGreen"
#define kTeapotBlueName			@"TeapotBlue"
#define kTeapotWhiteName		@"TeapotWhite"
#define	kBillboardName			@"Billboard"
#define kGroundName				@"Ground"
#define kFloaterName			@"Floater"


@interface CC3DemoMashUpWorld (Private)
-(void) addRobot;
-(void) addGround;
-(void) addFloatingRing;
-(void) addAxisMarkers;
-(void) addLightMarker;
-(void) addProjectedLabel;
-(void) addTeapotAndSatellite;
-(void) addBalls;
-(void) configureCamera;
-(void) updateCameraFromControls: (ccTime) dt;
-(void) invadeWithRobotArmy;
-(void) invadeWithTeapotArmy;
-(void) invadeWithArmyOf: (CC3Node*) invaderTemplate;
@end


@implementation CC3DemoMashUpWorld

@synthesize playerDirectionControl, playerLocationControl;

-(void) dealloc {
	ground = nil;
	teapotWhite = nil;			// not retained
	teapotTextured = nil;		// not retained
	teapotSatellite = nil;		// not retained
	podLight = nil;				// not retained
	beachBall = nil;			// not retained
	globe = nil;				// not retained
	camTarget = nil;			// not retained
	origCamTarget = nil;		// not retained

	[super dealloc];
}

/**
 * Adds the 3D objects to the world, loading some models from POD files, and building
 * others algorithmically. The loading of different features within the scene is
 * broken into a sequence of template methods. If you want to play with not loading
 * certain elements, simply comment out one the invocations of these template methods
 * within this method.
 */
-(void) initializeWorld {

	// The order in which meshes are drawn to the GL engine can be tailored to your needs.
	// The default is to draw opaque objects first, then alpha-blended objects in reverse
	// Z-order. Since this example has lots of similar teapots and robots to draw in this
	// example, we choose to also group objects by meshes here, while also drawing opaque
	// objects first, and translucent objects in reverse Z-order.
	//
	// To experiment with an alternate drawing order, set a different node sequence sorter
	// by uncommenting one of the lines here and commenting out the others. The third option
	// performs no grouping and draws the objects in the order they are added to the world
	// below. The fourth option does not use a drawing sequencer, and draws the objects
	// hierarchically instead. With this, notice that the transparent beach ball now appears
	// opaque, because it was added first, and is traversed ahead of other objects in the
	// hierarchical assembly, resulting it in being drawn first, and so it cannot blend with
	// the background.
	//
	// You can of course write your own node sequencers to customize to your specific
	// app needs. Best to change the node sequencer before any model objects are added.
	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirstGroupMeshes];
//	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirstGroupTextures];
//	self.drawingSequencer = [CC3BTreeNodeSequencer sequencerLocalContentOpaqueFirst];
//	self.drawingSequencer = nil;

	[self addBalls];				// Add a transparent bouncing beach ball and a rotating globe...exported from Blender
	
	[self addTeapotAndSatellite];	// Add a large textured teapot with a smaller satellite teapot

	[self addRobot];				// Add an animated robot arm, a light, and a camera
	
//	[self addFloatingRing];			// Uncomment to add a large yellow band floating above the ground,
									// using a texture containing transparency. The band as a whole
									// will fade in and out periodically. This demonstrates managing
									// opacity and translucency at both the texture and material level.

	[self addAxisMarkers];			// Add colored teapots to mark each coordinate axis
	
	[self addLightMarker];			// Add a small white teapot to show where the light is coming from

	[self addProjectedLabel];		// Attach a text label to the hand of the animated robot.
	
	[self addGround];				// Add a ground plane to provide some perspective to the user
	
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];

	[self configureCamera];			// Check out some interesting camera options.
}

// Various options for configuring interesting camera behaviours.
-(void) configureCamera {
	
	// The camera comes from the POD file and is actually animated.
	// Stop the camera from being animated so the user can control it via the user interface.
	[self.activeCamera disableAnimation];
	
	// Keep track of which object the camera is pointing at.
	origCamTarget = self.activeCamera.target;
	camTarget = origCamTarget;

	// For cameras, the scale property determines camera zooming, and the effective
	// field-of-view. You can adjust this value to play with camera zooming.
	// Conversely, if you find that objects in the periphery of your view appear elongated,
	// you can adjust the fieldOfView and/or uniformScale properties to reduce this
	// "fish-eye" effect. See the notes of the CC3Camera fieldOfView property for more on this.
	self.activeCamera.uniformScale = 0.7;
	
	// You can configure the camera to use orthographic projection instead of the default
	// perspective projection by setting the isUsingParallelProjection property to YES.
	// You will also need to adjust the scale to match the different projection.
//	self.activeCamera.isUsingParallelProjection = YES;
//	self.activeCamera.uniformScale = 0.015;
	
	// To see the effect of mounting a camera on a moving object, uncomment the following
	// five lines to mount the camera on a virtual boom attached to the beach ball.
	// Since the beach ball rotates as it bounces, you might also want to comment out the
	// CC3RotateBy action that is run on the beachBall in the addBalls method!
//	CC3Camera* cam = self.activeCamera;
//	cam.target = nil;						// so we can point it manually now
//	cam.location = cc3v(4.0, 1.0, 0.0);		// relative to the parent beach ball
//	cam.rotation = cc3v(0.0, 90.0, 0.0);	// point camera out over the beach ball
//	[beachBall addChild: cam];
}

/** Add a large cocos2d logo as a rectangular ground to give everything perspective */
-(void) addGround {
	ground = [CC3PlaneNode nodeWithName: kGroundName];
	[ground populateAsCenteredRectangleWithSize: CGSizeMake(2000.0, 2000.0)
									withTexture: [CC3Texture textureFromFile: kGroundTextureFile]
								  invertTexture: YES];
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
 * Adds a large yellow band floating above the ground. This band is created from a 
 * plane using a texture that combines transparency and opacity. It demonstrates
 * the use of transparency in textures. You can see through the transparent areas
 * to the scene behind the texture. The texture as a whole fades in and out periodically.
 */
-(void) addFloatingRing {
	CC3MeshNode* floater = [CC3PlaneNode nodeWithName: kFloaterName];
	[floater populateAsCenteredRectangleWithSize: CGSizeMake(500.0, 500.0)
									 withTexture: [CC3Texture textureFromFile: kFloaterTextureFile]
								   invertTexture: NO];
	floater.location = cc3v(0.0, 100.0, 0.0);
	floater.rotation = cc3v(-90.0, 0.0, 0.0);
	floater.isOpaque = NO;
	floater.shouldCullBackFaces = NO;			// Show from below as well.
	[self addChild: floater];

	CCActionInterval* fadeOut = [CCFadeOut actionWithDuration: 3.0];
	CCActionInterval* fadeIn = [CCFadeIn actionWithDuration: 3.0];
	CCActionInterval* fadeCycle = [CCSequence actionOne: fadeOut two: fadeIn];
	[floater runAction: [CCRepeatForever actionWithAction: fadeCycle]];
}

/**
 * Loads a POD file containing a semi-transparent beach ball sporting multiple materials,
 * and a globe with UV texture mapping, both exported from Blender.
 */
-(void) addBalls {
	// This is the simplest, most convenient way to load a POD resource file and add
	// the nodes to the CC3World, if no customized resource subclasses are needed.
	[self addContentFromPODResourceFile: kBallsPODFile];
	
	// Configure the bouncing beach ball
	beachBall = (CC3MeshNode*)[self getNodeNamed: kBeachBallName];
	beachBall.location = cc3v(300.0, 200.0, -200.0);
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
	
	// Configure the rotating globe
	globe = (CC3MeshNode*)[self getNodeNamed: kGlobeName];
	globe.location = cc3v(-300.0, 200.0, -200.0);
	globe.uniformScale = 50.0;
	globe.isTouchEnabled = YES;			// allow this node to be selected by touch events
	
	// Rotate the globe
	[globe runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																				rotateBy: cc3v(0.0, 30.0, 0.0)]]];
}

/** Add a large textured teapot and a small multicolored teapot orbiting it. */
-(void) addTeapotAndSatellite {
	teapotTextured = [[CC3ModelSampleFactory factory] makeLogoTexturedTeapotNamed: kTexturedTeapotName];
	teapotTextured.isTouchEnabled = YES;		// allow this node to be selected by touch events
	
	teapotSatellite = [[CC3ModelSampleFactory factory] makeMultiColoredTeapotNamed: kRainbowTeapotName];
	teapotSatellite.location = cc3v(0.3, 0.1, 0.0);
	teapotSatellite.uniformScale = 0.4;
	teapotSatellite.isTouchEnabled = YES;		// allow this node to be selected by touch events
	
	// Because we want to highlight the satellite and textured teapot separately, we can't make
	// the satellite teapot a child of the textured teapot, otherwise it would get highlighted
	// when the textured teapot was highlighted. So...we create a node that holds onto both
	// teapots and rotates them together, but allows each to be individually highlighted.
	CC3Node* teapotHolder = [CC3Node nodeWithName: kTeapotHolderName];
	teapotHolder.location = cc3v(0.0, 150.0, -650.0);
	teapotHolder.uniformScale = 500.0;
	[teapotHolder addChild: teapotTextured];
	[teapotHolder addChild: teapotSatellite];
	[self addChild: teapotHolder];
	
	// Rotate the teapots. The satellite orbits the textured teapot because it is a child node
	// of the teapot holder, and orbits as the parent node rotates. 
	[teapotHolder runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																						 rotateBy: cc3v(0.0, 60.0, 0.0)]]];
	// For effect, also rotate the satellite around its own axes.
	[teapotSatellite runAction: [CCRepeatForever actionWithAction: [CC3RotateBy actionWithDuration: 1.0
																						  rotateBy: cc3v(30.0, 0.0, 45.0)]]];
}

/** Loads a POD file containing an animated robot arm, a camera, and an animated light. */
-(void) addRobot {
	// We introduce a specialized resource subclass, not because it is needed in general,
	// but because the original PVR demo app ignores some data in the POD file. To replicate
	// the PVR demo faithfully, we must do the same, by tweaking the loader to act accordingly
	// by creating a specialized subclass.
	CC3PODResourceNode* podRezNode = [CC3PODResourceNode nodeWithName: kPODRobotRezNodeName];
	podRezNode.resource = [IntroducingPODResource resourceFromResourceFile: kRobotPODFile];

	// The PVR demo that the POD file is taken from ignores the ambient light in the POD file,
	// so we do the same. But normally, we could set the world ambient light from the POD file.
//	self.ambientLight = podRezNode.resource.ambientLight;		// usually...set ambient light in world
	self.ambientLight = kCC3DefaultLightColorAmbientWorld;		// but this example ignores value in POD file

	[podRezNode touchEnableAll];		// enable ALL component nodes to be individually selected by touch events
	[self addChild: podRezNode];
	
	// Retrieve the light from the POD resource so we can track its location as it moves via animation
	podLight = (IntroducingPODLight*)[self getNodeNamed: kPODLightName];
	
	// The light from the POD file is animated to move back and forth, changing the lighting
	// of the world as it moves. To turn this off and view steady lighting, uncomment the
	// following line.
//	[podLight disableAnimation];
	
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
	CC3Node* teapotGreen = [teapotRed copyWithName:  kTeapotGreenName];
	teapotGreen.diffuseColor = CCC4FMake(0.0, 0.7, 0.0, 1.0);
	teapotGreen.location = cc3v(0.0, 100.0, 0.0);
	[self addChild: teapotGreen];
	
	// Blue teapot is at postion 100 on the Z-axis
	// Create it by copying the red teapot.
	CC3Node* teapotBlue = [teapotRed copyWithName:  kTeapotBlueName];
	teapotBlue.diffuseColor = CCC4FMake(0.0, 0.0, 0.7, 1.0);
	teapotBlue.location = cc3v(0.0, 0.0, 100.0);
	[self addChild: teapotBlue];
}

/**
 * Add a small white teapot that will be used to indicate the current position of the light
 * that illuminates the scene. The light is animated and moves up and down according to
 * animation data from the POD file, and the white teapot tracks its location (actually its
 * direction, since it is a directional light).
 */
-(void) addLightMarker {
	teapotWhite = [[CC3ModelSampleFactory factory] makeUniColoredTeapotNamed: kTeapotWhiteName withColor: kCCC4FWhite];
	teapotWhite.uniformScale = 100.0;
	teapotWhite.isTouchEnabled = YES;		// allow this node to be selected by touch events
	[self addChild: teapotWhite];
}

/**
 * Add a billboard text label attached to the animated arm.
 * This label tracks along with the robot hand, and always faces the camera.
 * This demonstrates a projecting a location in the 3D world to the 2D display surface.
 * Instead of a simple text label, the billboard could be a "health meter" or ballon speech
 * text for a character, or a targetting reticle, or any other 2D artifact.
 */
-(void) addProjectedLabel {
	CCLabelTTF* bbLabel = [CCLabelTTF labelWithString: @"Whoa...I'm dizzy!"
											 fontName: @"Marker Felt"
											 fontSize: 30.0];
	bbLabel.color = ccYELLOW;
	CC3Billboard* bb = [CC3Billboard nodeWithName: kBillboardName withBillboard:bbLabel];
	bb.unityScaleDistance = 250.0;
	bb.location = cc3v( 0.0, 80.0, 0.0 );
	bb.offsetPosition = ccp( 0.0, 15.0 );
	[[self getNodeNamed: kRobotTopArm] addChild: bb];
}


#pragma mark Updating and user interactions

/** 
 * Called periodically as part of the CCLayer scheduled update mechanism.
 * This is where model objects are updated.
 *
 * For this world, the camera direction and location are updated
 * under control of the user interface, and the location of the white teapot that
 * indicates the direction of the light is updated as the light moves. All other motion
 * in the world is handled by CCActions.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {

	[self updateCameraFromControls: visitor.deltaTime];
		
	// To show where the POD light is, track the small white teapot to the current location
	// of the light. The actual direction vector is of unit length, so scale it to show the
	// direction of the light (through the white teapot towards the origin).
	teapotWhite.location = CC3VectorScaleUniform(CC3VectorFromCC3Vector4(podLight.homogeneousLocation), 100.0);
}

/** Update the location and direction of looking of the 3D camera */
-(void) updateCameraFromControls: (ccTime) dt {
	
	// Update the location of the player (the camera)
	if ( playerLocationControl.x || playerLocationControl.y ) {
		// Get the X-Y delta value of the control and scale it to something suitable
		CGPoint delta = ccpMult(playerLocationControl, dt * 100.0);

		// We want to move the camera up and down and side to side. Up will always be
		// world up (typically Y-axis), and side to side will be a line in the X-Z plane
		// along the "right" vector of the camera. Since the world up is orthogonal to
		// the X-Z plane, for convenience, combine these two axes (world up and camera right)
		// into a single control vector by simply adding them. You could also run these
		// calculations independently instead of combining into one vector.
		CC3Vector controlVector = CC3VectorAdd(activeCamera.rightDirection, activeCamera.worldUpDirection);

		// Scale the control vector by the control delta, using the X-component of the control
		// delta value for both the X and Z axes of the camera's right vector. This represents
		// the movement of the camera. The new location is simply the old location plus the movement.
		activeCamera.location = CC3VectorAdd(activeCamera.location,
											 CC3VectorScale(controlVector,
															cc3v(delta.x, delta.y, delta.x)));
	}

	// Update the direction the camera is pointing by panning and inclining.
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
		camTarget = beachBall;
	} else if (camTarget == beachBall) {
		camTarget = teapotTextured;
	} else if (camTarget == teapotTextured) {
		camTarget = globe;
	} else {
		camTarget = origCamTarget;
	}
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
	CC3Node* robotTemplate = [[self getNodeNamed: kPODRobotRezNodeName] copyAutoreleased];
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
	CC3Node* teapotTemplate = [[self getNodeNamed: kTeapotWhiteName] copyAutoreleased];
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

/** 
 * This callback method is automatically invoked when a touchable 3D node is touched
 * by the user. If the touch event indicates that the user has raised the finger,
 * thus completing the touch action, the node is temporarily highlighted by running
 * a tinting action on its emission color property (which affects the emission color
 * property of the materials underlying the node).
 *
 * In addition, if it is the beach ball that the user touched, toggle it between
 * translucent and fully opaque by simply setting the isOpqaue property on the beach ball.
 * If either the textured or rainbow teapots is selected, toggle the display of a wire-frame
 * of the node's bounding box.
 *
 * If the ground plane is touched, the ground plane node is not highlighted. Instead, an orange
 * teapot is dropped at the location of the touch. This demonstrates the ability to drop objects
 * into the 3D world using touch events.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
	if (touchType == kCCTouchEnded) {
		LogInfo(@"You selected %@ at %@, or %@ in 2D.", aNode,
				NSStringFromCC3Vector(aNode ? aNode.globalLocation : kCC3VectorZero),
				NSStringFromCC3Vector(aNode ? [activeCamera projectNode: aNode] : kCC3VectorZero));

		// If the touched node is the ground, place a little orange teapot at the location
		// on the ground corresponding to the touch-point.
		if (aNode == ground) {
			CC3Plane groundPlane = ((CC3PlaneNode*)aNode).plane;
			CC3Vector4 touchLoc = [self.activeCamera unprojectPoint: touchPoint ontoPlane: groundPlane];
			if (touchLoc.w > 0.0) {
				CC3MeshNode* tp = [teapotWhite copy];
				tp.color = ccORANGE;
				tp.location = cc3v(touchLoc.x, touchLoc.y, touchLoc.z);
				
				// We've set the teapot location to the global 3D point that was derived from the
				// touch point, and the teapot has a global rotation of zero, and a global scale.
				// When we add it to the ground plane, we don't want those properties to be further
				// transformed by the ground plane's existing transform. Therefore, the teapot
				// transform properties must be localized to properties that are relative to those
				// of the ground plane. We can do that using the addAndLocalizeChild: method.
				[aNode addAndLocalizeChild: tp];
			}
		} else {
			CCActionInterval* tintUp = [CC3TintEmissionTo actionWithDuration: 0.3f colorTo: kCCC4FMagenta];
			CCActionInterval* tintDown = [CC3TintEmissionTo actionWithDuration: 0.9f colorTo: kCCC4FBlack];
			[aNode runAction: [CCSequence actionOne: tintUp two: tintDown]];
			
			// If the node is the beach ball, toggle it between opaque and translucent.
			// Note that the alpha values of all the colors stay the same, it's only
			// the blending functions that change. See the notes for the isOpaque property
			// of CC3Material for more on the interaction between this property and the
			// other material properties.
			if (aNode == beachBall) {
				aNode.isOpaque = !aNode.isOpaque;
			}
			
			// If the node is either the textured or rainbow teapot, toggle the display of
			// a wire-frame of its bounding box. This is done by either adding or removing
			// a CC3LineNode as a child of the teapot node. The CC3LineNode is populated
			// from the bounding box of the teapot mesh.
			if (aNode == teapotTextured || aNode == teapotSatellite) {
				NSString* boxName = [NSString stringWithFormat: @"%@-Box", aNode.name];
				
				// See if the wire-frame node exists already as a child of the teapot.
				CC3LineNode* box = (CC3LineNode*)[aNode getNodeNamed: boxName];
				if (box) {
					[box remove];		// If so...remove it.
				} else {
					// Otherwise, create a new CC3LineNode from the bounding box of the
					// teapot mesh and add it as a child of the teapot, so that it will
					// move and scale with the teapot.
					box = [CC3LineNode nodeWithName: boxName];
					[box populateAsWireBox: ((CC3MeshNode*)aNode).meshModel.boundingBox];
					box.pureColor = kCCC4FYellow;
					//				box.shouldSmoothLines = YES;	// Uncomment to see the difference
					[aNode addChild: box];
				}
			}
		}

	}
}

@end


#pragma mark -
#pragma mark IntroducingPODResource

@implementation IntroducingPODResource

/**
 * Return a customized light class, to handle the idiosyncracies of the way the original
 * PVR demo app uses the POD file data. This shouldn't usually be necessary.
 */
-(CC3Light*) buildLightAtIndex: (uint) lightIndex {
	return [IntroducingPODLight nodeAtIndex: lightIndex fromPODResource: self];
}

/**
 * The PVRT example ignores all but ambient and diffuse material properties from the POD
 * file and uses default values instead. To duplicate...force other properties to defaults.
 */
-(CC3Material*) buildMaterialAtIndex: (uint) materialIndex {
	CC3Material* mat = [super buildMaterialAtIndex: materialIndex];
	mat.specularColor = kCC3DefaultMaterialColorSpecular;
	mat.emissionColor = kCC3DefaultMaterialColorEmission;
	mat.shininess = kCC3DefaultMaterialShininess;
	return mat;
}

@end


#pragma mark -
#pragma mark IntroducingPODLight

@interface CC3Node (TemplateMethods)
-(void) applyTranslation;
@end

@implementation IntroducingPODLight

/**
 * Idiosyncratically...the PVRT example that this demo is taken from actually extracts
 * the transformed UP DIRECTION from the POD file and uses it as the light POSITION.
 */
-(void) applyTranslation {
	[super applyTranslation];
	GLfloat w = isDirectionalOnly ? 0.0f : 1.0f;
	CC3Vector dir = self.upDirection;
	homogeneousLocation = CC3Vector4FromCC3Vector(dir, w);
	LogTrace(@"Updating homoLoc to upDir in %@ to %@", self, NSStringFromCC3Vector4(homogeneousLocation));
}

/** Although the POD file contains direction info, it is ignored in this demo (as in the PVRT example). */
-(void) applyDirection {}

/** 
 * Although the POD file contains light color info, it is ignored in this demo (as in the PVRT example)
 * and the GL default values are used instead.
 */
-(void) applyColor {
	gles11Light.ambientColor.value = kCC3DefaultLightColorAmbient;
	gles11Light.diffuseColor.value = kCC3DefaultLightColorDiffuse;
	gles11Light.specularColor.value = kCC3DefaultLightColorSpecular;
}

@end



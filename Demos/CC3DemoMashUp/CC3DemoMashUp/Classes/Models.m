/*
 * Models.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file Models.h for full API documentation.
 */

#import "Models.h"
#import "CC3ActionInterval.h"
#import "CCActionInstant.h"
#import "CC3IOSExtensions.h"

#define kDropHeight 700.0


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

@implementation IntroducingPODLight

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


#pragma mark -
#pragma mark HeadPODResource

@implementation HeadPODResource

/**
 * The POD file does not contain any real textures, but does contain a reference
 * to a texture that does not exist. Simply override to skip all texture building.
 * This shouldn't usually be necessary.
 */
-(CC3Texture*) buildTextureAtIndex: (uint) textureIndex { return nil; }

@end


#pragma mark -
#pragma mark PhysicsMeshNode

@implementation PhysicsMeshNode

@synthesize velocity, previousGlobalLocation;

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		velocity = kCC3VectorZero;
		previousGlobalLocation = kCC3VectorZero;
	}
	return self;
}

/** After the node has been transformed, calculated its new velocity. */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	CC3Vector currGlobalLoc = self.globalLocation;
	CC3Vector movement = CC3VectorDifference(currGlobalLoc, self.previousGlobalLocation);
	velocity = CC3VectorScaleUniform(movement, 1.0f / visitor.deltaTime);
	previousGlobalLocation = currGlobalLoc;
}

@end


#pragma mark -
#pragma mark DoorMeshNode

@implementation DoorMeshNode

@synthesize isOpen;

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		isOpen = NO;
	}
	return self;
}


@end

#pragma mark -
#pragma mark SpinningNode

@implementation SpinningNode

@synthesize spinAxis, spinSpeed, friction, isFreeWheeling;

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		spinAxis = kCC3VectorZero;
		spinSpeed = 0.0f;
		friction = 0.0f;
		isFreeWheeling = NO;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Node*) another {
	[super populateFrom: another];
	
	// Only copy these properties if the original is of the same class
	if ( [another isKindOfClass: [SpinningNode class]] ) {
		SpinningNode* anotherSpinningNode = (SpinningNode*)another;
		spinAxis = anotherSpinningNode.spinAxis;
		spinSpeed = anotherSpinningNode.spinSpeed;
		friction = anotherSpinningNode.friction;
		isFreeWheeling = anotherSpinningNode.isFreeWheeling;
	}
}

// Don't bother continuing to rotate once below this speed (in degrees per second)
#define kSpinningMinSpeed	6.0

/**
 * On each update, if freewheeling, rotate the node around the spinAxis, by an
 * angle determined by the spinSpeed. Then slow the spinSpeed down based on the
 * friction value and how long the friction has been applied since the last update.
 * Stop rotating altogether once the speed is low enough to be unnoticable, so that
 * we don't continue to perform transforms (and rebuilding shadows) unnecessarily.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	GLfloat dt = visitor.deltaTime;
	if (isFreeWheeling && spinSpeed > kSpinningMinSpeed) {
		GLfloat deltaAngle = spinSpeed * dt;
		[self rotateByAngle: deltaAngle aroundAxis: spinAxis];
		spinSpeed -= (deltaAngle * friction);
		LogTrace(@"Spinning %@ by %.3f at speed %.3f", self, deltaAngle, spinSpeed);
	}
}

@end


#pragma mark -
#pragma mark CC3Node extension for user data

/**
 * Demonstrates the initialization and disposal of application-specific userData by adding custom
 * extension categories to subclasses of CC3Identifiable (nodes, materials, meshes, textures, etc).
 */
@implementation CC3Node (MashUpUserData)

// Change the LogTrace to LogDebug to see when userData would be initialized for each node
-(void) initUserData {
	LogTrace(@"%@ initializing userData reference.", self);
}

// Change the LogTrace to LogDebug and then click the invade button when running the app.
-(void) releaseUserData {
	LogTrace(@"%@ disposing of userData.", self);
}

@end


#pragma mark -
#pragma mark LandingCraft

@implementation LandingCraft

-(void) populateArmyWith: (CC3Node*) templateNode {
	
	// To help demonstrate that the hordes of actioned nodes that make up this army are being managed
	// correctly, log the current number of nodes and actions, before the army has been created.
	LogInfo(@"Before populating %@ there are %i instances of CC3Identifiable subclasses in existance, and  %u actions running.",
			self, [CC3Identifiable instanceCount], [[CCActionManager sharedManager] numberOfRunningActions]);
	
	// Create many copies (invadersPerHalfSide * 2) ^ 2,
	// and space them out throughout the area of the ground plane, in a grid pattern.
	int invadersPerHalfSide = 5;
	GLfloat spacing = 1000.0f / invadersPerHalfSide;
	for (int ix = -invadersPerHalfSide; ix <= invadersPerHalfSide; ix++) {
		for (int iz = -invadersPerHalfSide; iz <= invadersPerHalfSide; iz++) {
			GLfloat xLoc = spacing * ix;
			GLfloat zLoc = spacing * iz;
			
			// Don't drop invaders into the central area where the main robot is.
			if (fabsf(xLoc) > 100.0f || fabsf(zLoc) > 100.0f) {
				CC3Node* invader = [templateNode autoreleasedCopy];
				invader.location = cc3v(xLoc, kDropHeight, zLoc);
				
				// If the invader has an animation, run its animation, otherwise rotate
				// it horizontally. In either case, the rate of motion is randomized so
				// that each invader moves at its own speed.
				CCActionInterval* invaderAction;
				if (invader.containsAnimation) {
					invaderAction = [CC3Animate actionWithDuration: CC3RandomFloatBetween(2.5, 10.0)];
				} else {
					invaderAction = [CC3RotateBy actionWithDuration: 1.0
														   rotateBy: cc3v(0.0, CC3RandomFloatBetween(30.0, 90.0), 0.0)];
				}
				CCActionInterval* groundAction = [CCRepeat actionWithAction: invaderAction times: kCC3MaxGLuint];
				
				// Create a landing action that is a bouncing drop of random duration, to simulate raining down.
				CC3Vector landingLocation = cc3v(invader.location.x, 0.0, invader.location.z);
				CCActionInterval* landingAction = [CCEaseBounceOut actionWithAction:
												   [CC3MoveTo actionWithDuration: CC3RandomFloatBetween(1.0, 2.0) 
																		  moveTo: landingLocation]];
				
				// Set up a sequence on the invader...first drop, and then animate or rotate
				[invader runAction: [CCSequence actionOne: landingAction two: groundAction]];
				[invader runAction: landingAction];
				
				[self addChild: invader];		// Add the child to the landing craft
			}
		}
	}
	
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];
	
	// To help demonstrate that the hordes of actioned nodes that make up this army are being managed
	// correctly, log the current number of nodes and actions, now that the army has been created.
	LogInfo(@"After populating %@ there are %i instances of CC3Identifiable subclasses in existance, and  %u actions running.",
			self, [CC3Identifiable instanceCount], [[CCActionManager sharedManager] numberOfRunningActions]);
}

/**
 * Uses a CCSequence action to first fade the army away,
 * and then invokes the cleanUp callback to remove the invaders.
 */
-(void) evaporate {
	CCActionInterval* fadeOut = [CCFadeOut actionWithDuration: 1.0];
	CCActionInstant* remove = [CCCallFunc actionWithTarget: self selector: @selector(remove)];
	[self runAction: [CCSequence actionOne: fadeOut two: remove]];
}

@end


@implementation CCActionManager (LandingCraft)

-(uint) numberOfRunningActions {
	uint total = 0;
	for(tHashElement *element=targets; element != NULL; ) {	
		id target = element->target;
		element = element->hh.next;
		total += [self numberOfRunningActionsInTarget:target];
	}
	return total;
}

@end


#pragma mark -
#pragma mark HangingPointParticle

@implementation HangingPointParticle

/**
 * Uses the index of the particle to determine its location relative to the origin of
 * the emitter. The particles are laid out in a simple rectangular grid in the X-Z plane,
 * with kParticlesPerSide particles on each side of the grid.
 *
 * Each particle is assigned a random color and size.
 */
-(void) initializeParticle {
	[super initializeParticle];
	GLint zIndex = particleIndex / kParticlesPerSide;
	GLint xIndex = particleIndex % kParticlesPerSide;
	
	GLfloat xStart = -kParticlesPerSide * kParticlesSpacing / 2.0f;
	GLfloat zStart = -kParticlesPerSide * kParticlesSpacing / 2.0f;
	
	self.location = cc3v(xStart + (xIndex * kParticlesSpacing),
						 0.0,
						 zStart + (zIndex * kParticlesSpacing) );
	
	self.color4F = RandomCCC4FBetween(kCCC4FDarkGray, kCCC4FWhite);
	
	GLfloat avgSize = self.emitter.particleSize;
	self.size = CC3RandomFloatBetween(avgSize * 0.75, avgSize * 1.25);
}

@end


#pragma mark -
#pragma mark HangingMeshParticle

@implementation HangingMeshParticle

@synthesize rotationSpeed;

/**
 * Uses the index of the particle to determine its location relative to the origin of
 * the emitter. The particles are laid out in a simple rectangular grid in the X-Z plane,
 * with kParticlesPerSide particles on each side of the grid.
 */
-(void) initializeParticle {
	[super initializeParticle];

	NSUInteger particleIndex = emitter.particleCount;
	GLint zIndex = particleIndex / kParticlesPerSide;
	GLint xIndex = particleIndex % kParticlesPerSide;
	
	GLfloat xStart = -kParticlesPerSide * kParticlesSpacing / 2.0f;
	GLfloat zStart = -kParticlesPerSide * kParticlesSpacing / 2.0f;
	
	self.location = cc3v(xStart + (xIndex * kParticlesSpacing),
						 0.0,
						 zStart + (zIndex * kParticlesSpacing) );

	
	// Apply a texture rectangle based on the particleIndex.
	self.textureRectangle = self.textureRectangle;
	
	self.rotationAxis = CC3VectorNormalize(cc3v(CC3RandomFloatBetween(0.0, 1.0),
												CC3RandomFloatBetween(0.0, 1.0),
												CC3RandomFloatBetween(0.0, 1.0)));
	self.rotationSpeed = CC3RandomFloatBetween(-30.0, 30.0);
	
	// To improve performance, accumulate rotational changes and apply
	// only when a threshold has been reached.
	accumulatedAngleChange = 0.0f;
}

/** Derive the texture rectangle from the particle index, in a modulus of eight options . */
-(CGRect) textureRectangle {
	NSUInteger particleIndex = emitter.particleCount;
	switch (particleIndex % 8) {
		case 1:
			return CGRectMake(0.25, kCC3OneThird, 0.25, kCC3OneThird);	// Front
		case 2:
			return CGRectMake(0.0, kCC3OneThird, 0.25, kCC3OneThird);	// Left
		case 3:
			return CGRectMake(0.5, kCC3OneThird, 0.25, kCC3OneThird);	// Right
		case 4:
			return CGRectMake(0.75, kCC3OneThird, 0.25, kCC3OneThird);	// Back
		case 5:
			return CGRectMake(0.25, (kCC3OneThird + kCC3OneThird), 0.25, kCC3OneThird);	// Top
		case 6:
			return CGRectMake(0.25, 0.0, 0.25, kCC3OneThird);			// Bottom
		case 0:
		case 7:
		default:
			return kCC3UnitTextureRectangle;							// Entire texture
	}
}

/**
 * Angular threshold, in degrees, that must be reached before accumulated rotational changes
 * are applied to the particle.
 *
 * You can experiment with different values for this threshold and observe how it changes the
 * performance in terms of frames-per-second. A value of zero for the threshold will update the
 * rotation on every frame.
 */
#define kRotationalUpdateThreshold	6.0

/**
 * Rotate the particle around the rotation axis that was picked in the initializeParticle method.
 * To avoid processing rotations and vertices that are not noticable, small rotational changes
 * are accumultated until the kRotationalUpdateThreshold angle is reached, and then are applied.
 *
 * You can experiment with different values for this threshold and observe how it changes the
 * performance in terms of frames-per-second. A value of zero for the threshold will update the
 * rotation on every frame.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	accumulatedAngleChange += (self.rotationSpeed * visitor.deltaTime);
	if (accumulatedAngleChange > kRotationalUpdateThreshold) {
		self.rotationAngle += accumulatedAngleChange;
		accumulatedAngleChange = 0.0f;
	}
}

// Protected properties for copying
-(GLfloat) accumulatedAngleChange { return accumulatedAngleChange; }

-(void) populateFrom: (HangingMeshParticle*) another {
	[super populateFrom: another];
	rotationSpeed = another.rotationSpeed;
	accumulatedAngleChange = another.accumulatedAngleChange;
}

@end


#pragma mark -
#pragma mark RotatingFadingMeshParticle

@implementation RotatingFadingMeshParticle

/** Picks a random rotational axis and rotational velocity, and fades the particle over its lifetime. */
-(void) initializeParticle {
	[super initializeParticle];
	
	// Select a random rotation axis and velocity
	self.rotationAxis = CC3VectorNormalize(cc3v(CC3RandomFloatBetween(0.0, 1.0),
												CC3RandomFloatBetween(0.0, 1.0),
												CC3RandomFloatBetween(0.0, 1.0)));
	
	// Alternate between rotating right or left.
	// Particles are always emitted at the end, so particle index should be randomly odd/even.
	NSUInteger particleIndex = emitter.particleCount;
	float dirSign = CC3IntIsEven(particleIndex) ? 1 : -1;
	self.rotationAngle = 0.0f;
	self.rotationAngleVelocity = dirSign * CC3RandomFloatBetween(45.0, 120.0);
	
	self.uniformScale = CC3RandomFloatBetween(0.5, 2.0);
	
	// Set the color velocity to change only the opacity, to fade the particle away
	self.color4F = emitter.diffuseColor;
	self.colorVelocity = CCC4FMake(0.0f, 0.0f, 0.0f, -(1.0 / self.lifeSpan));
}

@end


#pragma mark -
#pragma mark CylinderLabel

@implementation CylinderLabel

@synthesize radius;

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		radius = 1000;
	}
	return self;
}

-(void) populateFrom: (CylinderLabel*) another {
	[super populateFrom: another];
	radius = another.radius;
}

/**
 * At this point, the vertices lie in the X-Y plane. Wrap them around around a circle whose radius
 * is defined by the radius property, and whose center lies behind the X-Y text plane at (0, 0, -radius).
 *
 * The current X-component of the vertex location defines how far around the circle the vertex
 * will be located. Dividing this by the radius determines its positional angle in radians.
 * The new X- and Z-components of the vertex location can then be determined by trigonometry.
 *
 * Finally, the origin of the mesh is moved to the center of the circle, so that when this mesh
 * is positioned or rotated, it will be relative to the center of the circle. Since this may all be done
 * dynamically whenever the label text changes, update any GL buffers with the new mesh vertex locations.
 */
-(void) wrapTextToArc {
	GLuint vtxCount = self.vertexCount;
	for (GLuint vIdx = 0; vIdx < vtxCount; vIdx++) {
		CC3Vector vtxLoc = [self vertexLocationAt: vIdx];
		GLfloat angleInRads = vtxLoc.x / radius;
		[self setVertexLocation: cc3v((radius * sinf(angleInRads)),
									  vtxLoc.y,
									  (radius * (cosf(angleInRads) - 1.0f)))
							 at: vIdx];
	}
	[self moveMeshOriginTo: cc3v(0, 0, -radius)];
	[self updateGLBuffers];
}

-(void) populateAsBitmapFontLabelFromString: (NSString*) lblString
							   fromFontFile: (NSString*) fontFile
							  andLineHeight: (GLfloat) lineHt
						   andTextAlignment: (UITextAlignment) textAlign
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (ccGridSize) divsPerChar {
	[super populateAsBitmapFontLabelFromString: lblString
								  fromFontFile: fontFile
								 andLineHeight: lineHt
							  andTextAlignment: textAlign
							 andRelativeOrigin: origin
							   andTessellation: divsPerChar];
	[self wrapTextToArc];
}

@end

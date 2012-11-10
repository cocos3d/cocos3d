/*
 * CC3Light.m
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
 * See header file CC3Light.h for full API documentation.
 */

#import "CC3Light.h"
#import "CC3Camera.h"
#import "CC3ShadowVolumes.h"
#import "CC3Scene.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3CC2Extensions.h"


#pragma mark CC3Light 

@interface CC3Node (TemplateMethods)
-(void) updateGlobalLocation;
-(void) updateGlobalScale;
-(void) transformMatrixChanged;
@end

@interface CC3Camera (TemplateMethods)
-(void) loadProjectionMatrix;
-(void) loadModelviewMatrix;
@end

@interface CC3Light (TemplateMethods)
-(void) applyLocation;
-(void) applyDirection;
-(void) applyAttenuation;
-(void) applyColor;
-(GLuint) nextLightIndex;
-(void) returnLightIndex: (GLuint) aLightIndex;
+(BOOL*) lightIndexPool;
-(void) cleanupShadows;
-(void) configureStencilParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) paintStenciledShadowsWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupStencilParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) checkShadowCastingVolume;
-(void) checkCameraShadowVolume;
-(void) checkStencilledShadowPainter;
@end

@interface CC3LightCameraBridgeVolume (TemplateMethods)
@property(nonatomic, assign) CC3Light* light;
@end


@implementation CC3Light

@synthesize lightIndex, shouldCopyLightIndex;
@synthesize shadows, shadowCastingVolume, cameraShadowVolume;
@synthesize stencilledShadowPainter, shadowIntensityFactor;
@synthesize ambientColor, diffuseColor, specularColor;
@synthesize spotExponent, spotCutoffAngle, isDirectionalOnly;
@synthesize homogeneousLocation, attenuationCoefficients;

-(void) dealloc {
	[self cleanupShadows];		// Includes releasing the shadows array, camera shadow volume & shadow painter
	[gles11Light release];
	[self returnLightIndex: lightIndex];
	[super dealloc];
}

-(BOOL) isLight { return YES; }

/** Overridden to return NO so that the forwardDirection aligns with the negative-Z-axis. */
-(BOOL) shouldReverseForwardDirection { return NO; }

// Clamp to valid range.
-(void) setSpotExponent: (GLfloat) spotExp {
	spotExponent = CLAMP(spotExp, 0.0f, 128.0f);
}

-(void) setAmbientColor: (ccColor4F) aColor {
	ambientColor = aColor;
	[self.scene updateRelativeLightIntensities];
}

-(void) setDiffuseColor: (ccColor4F) aColor {
	diffuseColor = aColor;
	[self.scene updateRelativeLightIntensities];
}

-(void) setShadowIntensityFactor: (GLfloat) shdwIntFactor {
	shadowIntensityFactor = shdwIntFactor;
	[self.scene updateRelativeLightIntensities];
}

-(void) setVisible: (BOOL) isVisible {
	super.visible = isVisible;
	[self.scene updateRelativeLightIntensities];
}

// Keep the compiler happy with the additional declaration
// of this property on this class for documentation purposes
-(CC3Vector) forwardDirection { return super.forwardDirection; }
-(void) setForwardDirection: (CC3Vector) aDirection { super.forwardDirection = aDirection; }


#pragma mark CCRGBAProtocol support

/** Returns diffuse color. */
-(ccColor3B) color { return CCC3BFromCCC4F(diffuseColor); }

// Set both diffuse and ambient colors, retaining the alpha of each
-(void) setColor: (ccColor3B) color {
	self.ambientColor = CCC4FFromColorAndOpacity(color, ambientColor.a);
	self.diffuseColor = CCC4FFromColorAndOpacity(color, diffuseColor.a);

	super.color = color;
}

/** Returns diffuse alpha. */
-(GLubyte) opacity { return CCColorByteFromFloat(diffuseColor.a); }

/** Set opacity of all colors, retaining the colors of each. */
-(void) setOpacity: (GLubyte) opacity {
	GLfloat af = CCColorFloatFromByte(opacity);
	ambientColor.a = af;
	diffuseColor.a = af;
	specularColor.a = af;

	super.opacity = opacity;
}

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName withLightIndex: (GLuint) ltIndx {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		if (ltIndx == UINT_MAX) {		// All the lights have been used already.
			[self release];
			return nil;
		}
		lightIndex = ltIndx;
		gles11Light = [[[CC3OpenGLES11Engine engine].lighting lightAt: lightIndex] retain];
		shadows = nil;
		shadowCastingVolume = nil;
		cameraShadowVolume = nil;
		stencilledShadowPainter = nil;
		homogeneousLocation = kCC3Vector4Zero;
		ambientColor = kCC3DefaultLightColorAmbient;
		diffuseColor = kCC3DefaultLightColorDiffuse;
		specularColor = kCC3DefaultLightColorSpecular;
		spotExponent = 0;
		spotCutoffAngle = kCC3SpotCutoffNone;
		attenuationCoefficients = kCC3DefaultLightAttenuationCoefficients;
		shadowIntensityFactor = 1.0;
		isDirectionalOnly = YES;
		shouldCopyLightIndex = NO;
		shouldCastShadowsWhenInvisible = NO;
	}
	return self;
}

-(id) initWithLightIndex: (GLuint) ltIndx {
	return [self initWithName: nil withLightIndex: ltIndx];
}

-(id) initWithTag: (GLuint) aTag withLightIndex: (GLuint) ltIndx {
	return [self initWithTag: aTag withName: nil withLightIndex: ltIndx];
}

-(id) initWithName: (NSString*) aName withLightIndex: (GLuint) ltIndx {
	return [self initWithTag: [self nextTag] withName: aName withLightIndex: ltIndx];
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [self initWithTag: aTag withName: aName withLightIndex: [self nextLightIndex]];
}

+(id) nodeWithLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithLightIndex: ltIndx] autorelease];
}

+(id) lightWithLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithLightIndex: ltIndx] autorelease];
}

+(id) lightWithTag: (GLuint) aTag withLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithTag: aTag withLightIndex: ltIndx] autorelease];
}

+(id) lightWithName: (NSString*) aName withLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithName: aName withLightIndex: ltIndx] autorelease];
}

+(id) lightWithTag: (GLuint) aTag withName: (NSString*) aName withLightIndex: (GLuint) ltIndx {
	return [[[self alloc] initWithTag: aTag withName: aName withLightIndex: ltIndx] autorelease];
}

// Keep the compiler happy with additional declaration for documentation purposes
-(id) init { return [super init]; }
-(id) initWithTag: (GLuint) aTag { return [super initWithTag: aTag]; }
-(id) initWithName: (NSString*) aName { return [super initWithName: aName]; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// The lightIndex property is NOT copied, since we want each light to have a different value.
-(void) populateFrom: (CC3Light*) another {
	[super populateFrom: another];

	// Shadows are not copied, because each shadow connects
	// one-and-only-one shadow casting node to one-and-only-one light.
	
	homogeneousLocation = another.homogeneousLocation;
	ambientColor = another.ambientColor;
	diffuseColor = another.diffuseColor;
	specularColor = another.specularColor;
	spotExponent = another.spotExponent;
	spotCutoffAngle = another.spotCutoffAngle;
	attenuationCoefficients = another.attenuationCoefficients;
	shadowIntensityFactor = another.shadowIntensityFactor;
	isDirectionalOnly = another.isDirectionalOnly;
	shouldCopyLightIndex = another.shouldCopyLightIndex;
	shouldCastShadowsWhenInvisible = another.shouldCastShadowsWhenInvisible;
}

/**
 * Creates a copy of this node. The value of the lightIndex property of the new copy is
 * determined by the value of the shouldCopyLightIndex property of this node. The copy
 * will be assigned either the same lightIndex as this node, or a new lightIndex value.
 */
-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName asClass: (Class) aClass {
	GLuint ltIndx = shouldCopyLightIndex ? lightIndex : [self nextLightIndex];
	CC3Light* aCopy = [[aClass allocWithZone: zone] initWithName: aName withLightIndex: ltIndx];
	[aCopy populateFrom: self];
	return aCopy;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ light index: %u", [super description], lightIndex];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, homoLoc: %@, ambient: %@, diffuse: %@, specular: %@, spotAngle: %.2f, attenuation: %@",
			[super fullDescription], NSStringFromCC3Vector4(homogeneousLocation), NSStringFromCCC4F(ambientColor),
			NSStringFromCCC4F(diffuseColor), NSStringFromCCC4F(specularColor), spotCutoffAngle,
			NSStringFromCC3AttenuationCoefficients(attenuationCoefficients)];
}

/** Scaling does not apply to lights. */
-(void) applyScaling {
	[self updateGlobalScale];
}

/**
 * Overridden to determine the overall absolute location (taking into consideration
 * ancestor location) in the 4D homogeneous coordinates used by GL lights. The w component
 * of the homogeneous location is determined by the value of the isDirectionalOnly property.
 */
-(void) updateGlobalLocation {
	[super updateGlobalLocation];
	GLfloat w = isDirectionalOnly ? 0.0 : 1.0;
	homogeneousLocation = CC3Vector4FromCC3Vector(globalLocation, w);
}

/**
 * Scaling does not apply to lights. Sets the globalScale to that of the parent node,
 * or to unit scaling if no parent.
 */
-(void) updateGlobalScale {
	globalScale = parent ? parent.globalScale : kCC3VectorUnitCube;
}

/** Overridden to update the camera shadow frustum with the global location of this light */
-(void) transformMatrixChanged {
	[super transformMatrixChanged];
	[shadowCastingVolume markDirty];
	[cameraShadowVolume markDirty];
}


#pragma mark Drawing

-(void) turnOn {
	if (self.visible) {
		LogTrace(@"Turning on %@", self);
		[gles11Light.light enable];
		[self applyLocation];
		[self applyDirection];
		[self applyAttenuation];
		[self applyColor];
	} else {
		[gles11Light.light disable];
	}
}

/**
 * Template method that sets the position of this light in the GL engine to the value of
 * the homogeneousLocation property of this node.
 */	
-(void) applyLocation { gles11Light.position.value = homogeneousLocation; }

/**
 * Template method that sets the spot direction, spot exponent, and spot cutoff angle of this light
 * in the GL engine to the values of the globalForwardDirection, spotExponent and spotCutoffAngle
 * properties of this node, respectively. The direction and exponent are only valid if a cutoff has
 * been specified and less than 90 degrees, otherwise the light is treated as omnidirectional.
 * OpenGL ES only supports angles less than 90 degrees, so anything above is treated as omnidirectional.
 */
-(void) applyDirection {
	if (spotCutoffAngle <= 90.0f) {
		gles11Light.spotCutoffAngle.value = spotCutoffAngle;
		gles11Light.spotDirection.value = self.globalForwardDirection;
		gles11Light.spotExponent.value = spotExponent;
	} else {
		gles11Light.spotCutoffAngle.value = kCC3SpotCutoffNone;
	}
}

/**
 * Template method that sets the light intensity attenuation characteristics
 * in the GL engine from the attenuationCoefficients property of this light.
 */
-(void) applyAttenuation {
	if ( !isDirectionalOnly ) {
		gles11Light.constantAttenuation.value = attenuationCoefficients.a;
		gles11Light.linearAttenuation.value = attenuationCoefficients.b;
		gles11Light.quadraticAttenuation.value = attenuationCoefficients.c;
	}
}

/**
 * Template method that sets the ambient, diffuse and specular colors of this light
 * in the GL engine to the values of the ambientColor, diffuseColor and specularColor
 * properties of this node, respectively.
 */
-(void) applyColor {
	gles11Light.ambientColor.value = ambientColor;
	gles11Light.diffuseColor.value = diffuseColor;
	gles11Light.specularColor.value = specularColor;
}


#pragma mark Shadows

-(BOOL) shouldCastShadowsWhenInvisible { return shouldCastShadowsWhenInvisible; }

-(void) setShouldCastShadowsWhenInvisible: (BOOL) shouldCast {
	shouldCastShadowsWhenInvisible = shouldCast;
	super.shouldCastShadowsWhenInvisible = shouldCast;
}

-(void) addShadow: (id<CC3ShadowProtocol>) aShadowNode {
	NSAssert(aShadowNode, @"Shadow cannot be nil");		// Don't add if child is nil
	
	if(!shadows) shadows = [[CCArray array] retain];
	[shadows addObject: aShadowNode];
	aShadowNode.light = self;

	[self addTransformListener: aShadowNode];	// Update the shadow when this light moves.
	[self checkShadowCastingVolume];			// Make sure we have the shadow casting volume
	[self checkCameraShadowVolume];				// Make sure we have the camera shadow volume
	[self checkStencilledShadowPainter];		// Make sure we have the shadow painter
}

-(void) removeShadow: (id<CC3ShadowProtocol>) aShadowNode {
	[shadows removeObjectIdenticalTo: aShadowNode];
	aShadowNode.light = nil;					// So it can't call back here if I'm gone
	if (shadows && shadows.count == 0) {
		[shadows release];
		shadows = nil;
		[self checkShadowCastingVolume];		// Remove the shadow casting volume
		[self checkCameraShadowVolume];			// Remove the camera shadow volume
		[self checkStencilledShadowPainter];	// Remove the stencilled shadow painter
	}
	[self removeTransformListener: aShadowNode];
}

-(BOOL) hasShadows { return shadows && shadows.count > 0; }

-(void) updateShadows {
	for (id<CC3ShadowProtocol> sv in shadows) {
		[sv updateShadow];
	}
}

/** Detaches old as camera listener, attaches new as camera listener, and attaches light. */
-(void) setShadowCastingVolume: (CC3ShadowCastingVolume*) scVolume {
	if (scVolume != shadowCastingVolume) {

		CC3Camera* cam = self.activeCamera;
		[cam removeTransformListener: shadowCastingVolume];
		[shadowCastingVolume release];

		shadowCastingVolume = [scVolume retain];
		shadowCastingVolume.light = self;
		[cam addTransformListener: shadowCastingVolume];
	}
}

/**
 * If there are shadows and the shadow casting volume has not been added, add it now,
 * and tell the camera to let the shadow casting volume know whenever the camera moves
 * so the shadow casting volume can determine which objects are casting shadows that
 * are visible within the camera frustum.
 *
 * If there are no more shadows, disconnect the shadow casting volume from the camera,
 * and remove the shadow casting volume.
 */
-(void) checkShadowCastingVolume {
	if (shadows) {
		if (!shadowCastingVolume) {
			self.shadowCastingVolume = [CC3ShadowCastingVolume boundingVolume];
		}
	} else {
		[self.activeCamera removeTransformListener: shadowCastingVolume];
		[shadowCastingVolume release];
		shadowCastingVolume = nil;
	}
}

/** Detaches old as camera listener, attaches new as camera listener, and attaches light. */
-(void) setCameraShadowVolume: (CC3CameraShadowVolume*) csVolume {
	if (csVolume != cameraShadowVolume) {
		
		CC3Camera* cam = self.activeCamera;
		[cam removeTransformListener: cameraShadowVolume];
		[cameraShadowVolume release];
		
		cameraShadowVolume = [csVolume retain];
		cameraShadowVolume.light = self;
		[cam addTransformListener: cameraShadowVolume];
	}
}

/**
 * If there are shadows and the camera shadow volume has not been added, add it now,
 * and tell the camera to let the camera shadow volume know whenever the camera moves
 * so the camera shadow volume can determine which objects are shadowing the camera.
 *
 * If there are no more shadows, disconnect the camera shadow volume from the camera,
 * and remove the camera shadow volume.
 */
-(void) checkCameraShadowVolume {
	if (shadows) {
		if (!cameraShadowVolume) {
			self.cameraShadowVolume = [CC3CameraShadowVolume boundingVolume];
			[self.activeCamera addTransformListener: cameraShadowVolume];
		}
	} else {
		[self.activeCamera removeTransformListener: cameraShadowVolume];
		[cameraShadowVolume release];
		cameraShadowVolume = nil;
	}
}

/**
 * Creates or removes the stenciled shadow painter mesh node, as needed.
 * 
 * Sets the intensity of the shadow from the intensity of the diffuse component
 * of this light relative to the intensity of all other illumination in the scene.
 */
-(void) checkStencilledShadowPainter {
	if (shadows) {
		if (!stencilledShadowPainter) {
			self.stencilledShadowPainter = [CC3StencilledShadowPainterNode nodeWithName: @"SSP"];
			self.stencilledShadowPainter.light = self;
			[self.scene updateRelativeLightIntensities];	//  Must be done after the ivar is set.
		}
	} else {
		[stencilledShadowPainter release];
		stencilledShadowPainter = nil;
	}
}

-(void) updateRelativeIntensityFrom: (ccColor4F) totalLight {
	if (stencilledShadowPainter) {
		GLfloat dIntensity = CCC4FIntensity(self.diffuseColor);
		GLfloat totIntensity = CCC4FIntensity(totalLight);
		GLfloat shadowIntensity =  (dIntensity / totIntensity) * shadowIntensityFactor;
		stencilledShadowPainter.opacity = CCColorByteFromFloat(shadowIntensity);
		LogTrace(@"%@ updated shadow intensity to %u from light illumination %@ against total illumination %@ and shadow intensity factor %.3f",
					  self, stencilledShadowPainter.opacity,
					  NSStringFromCCC4F(self.diffuseColor), NSStringFromCCC4F(self.scene.totalIllumination), shadowIntensityFactor);
	}
}

// TODO - combine with other shadow techniques - how to make polymorphic?
-(void) drawShadowsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if ( shadows && (self.visible || self.shouldCastShadowsWhenInvisible) ) {
		LogTrace(@"%@ drawing %u shadows", self, shadows.count);
		[self configureStencilParameters: visitor];
		
		for (CC3ShadowVolumeMeshNode* sv in shadows) {
			[sv drawToStencilWithVisitor: visitor];
		}
		
		[self paintStenciledShadowsWithVisitor: visitor];
		[self cleanupStencilParameters: visitor];
	}
}

-(void) configureStencilParameters: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11State* gles11State = gles11Engine.state;
	
	[gles11Engine.serverCapabilities.stencilTest enable];
	gles11State.colorMask.fixedValue = ccc4(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
	[gles11State.stencilFunction applyFunction: GL_ALWAYS andReference: 0 andMask: ~0];
}

-(void) paintStenciledShadowsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
	CC3OpenGLES11State* gles11State = gles11Engine.state;
	CC3OpenGLES11Matrices* gles11Matrices = gles11Engine.matrices;
	CC3OpenGLES11MatrixStack* gles11ProjMtx = gles11Matrices.projection;
	CC3OpenGLES11MatrixStack* gles11MVMtx = gles11Matrices.modelview;
	
	// Turn color masking back on so that shadow will be painted on the scene.
	// The depth mask will be turned on by the mesh node
	gles11State.colorMask.fixedValue = ccc4(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	
	// Set the stencil function so that only those pixels that have a non-zero
	// value in the stencil (and that pass the depth test) will be painted.
	[gles11State.stencilFunction applyFunction: GL_NOTEQUAL andReference: 0 andMask: ~0];
	
	// Clear any non-zero values from the stencil buffer as we paint the shadow.
	// This saves having to make the effort to clear the stencil buffer on the next round.
	[gles11State.stencilOperation applyStencilFail: GL_ZERO
									  andDepthFail: GL_ZERO
									  andDepthPass: GL_ZERO];
	
	// Set the projection and modelview matrices to identity to transform the simple
	// rectangular stenciled shadow painter mesh so that it covers the full viewport.
	[gles11ProjMtx identity];
	[gles11MVMtx identity];
	
	// Paint the shadow to the screen. Only areas that have been marked as being
	// in the stencil buffer as being in the shadow of this light will be shaded.
	[visitor visit: stencilledShadowPainter];
	
	// Restore the projection and modelview matrices back to those of the camera
	CC3Camera* cam = visitor.camera;
	[cam loadModelviewMatrix];
	[cam loadProjectionMatrix];
}

-(void) cleanupStencilParameters: (CC3NodeDrawingVisitor*) visitor {
	[[CC3OpenGLES11Engine engine].serverCapabilities.stencilTest disable];
}

/**
 * Invoked when this light is being deallocated. Removes all associated
 * shadow nodes from this scene, which also removes the shadows array.
 */
-(void) cleanupShadows {
	CCArray* myShadows = [shadows copy];
	for (CC3Node* sv in myShadows) {
		[sv remove];
	}
	[myShadows release];
}


#pragma mark Managing the pool of available GL lights

// Class variable that tracks the indexes of the lights that are in use.
// When a new instance is instantiated, it's lightIndex property is assigned from the pool
// of indexes. When the instance is deallocated, its index is returned to the pool for use
// by any subsequently instantiated lights.
static BOOL* _lightIndexPool = NULL;

+(BOOL*) lightIndexPool {
	if (!_lightIndexPool) {
		GLint platformMaxLights = [CC3OpenGLES11Engine engine].platform.maxLights.value;
		_lightIndexPool = calloc(platformMaxLights, sizeof(BOOL));
	}
	return _lightIndexPool;
}

// Indicates the staring index to use when instantiating new lights.
static GLuint lightPoolStartIndex = 0;

/**
 * Assigns and returns the next available light index from the pool.
 * If no more lights are available, returns UINT_MAX.
 */
-(GLuint) nextLightIndex {
	BOOL* indexPool = [[self class] lightIndexPool];
	GLint platformMaxLights = [CC3OpenGLES11Engine engine].platform.maxLights.value;
	for (int lgtIdx = lightPoolStartIndex; lgtIdx < platformMaxLights; lgtIdx++) {
		if (!indexPool[lgtIdx]) {
			LogTrace(@"Allocating light index %u", lgtIdx);
			indexPool[lgtIdx] = YES;
			return lgtIdx;
		}
	}
	NSAssert1(NO, @"Too many lights. Only %u lights may be created.", platformMaxLights);
	return UINT_MAX;
}

/** Returns the specified light index to the pool. */
-(void) returnLightIndex: (GLuint) aLightIndex {
	LogTrace(@"Returning light index %u", aLightIndex);
	BOOL* indexPool = [[self class] lightIndexPool];
	indexPool[aLightIndex] = NO;
	[gles11Light.light disable];
}

+(GLuint) lightCount {
	GLuint count = 0;
	BOOL* indexPool = [self lightIndexPool];
	GLint platformMaxLights = [CC3OpenGLES11Engine engine].platform.maxLights.value;
	for (int i = lightPoolStartIndex; i < platformMaxLights; i++) {
		if (indexPool[i]) {
			count++;
		}
	}
	return lightPoolStartIndex + count;
}

+(GLuint) lightPoolStartIndex {
	return lightPoolStartIndex;
}

+(void) setLightPoolStartIndex: (GLuint) newStartIndex {
	lightPoolStartIndex = newStartIndex;
}

+(void) disableReservedLights {
	for (int i = 0; i < lightPoolStartIndex; i++) {
		[[[CC3OpenGLES11Engine engine].lighting lightAt: i].light disable];
	}
}

@end


#pragma mark -
#pragma mark CC3LightCameraBridgeVolume

@interface CC3BoundingVolume (TemplateMethods)
-(void) updateIfNeeded;
-(void) appendPlanesTo: (NSMutableString*) desc;
-(void) appendVerticesTo: (NSMutableString*) desc;
-(BOOL) areAllVerticesInFrontOf: (CC3Plane) plane;
@end

@implementation CC3LightCameraBridgeVolume

-(void) dealloc {
	light = nil;			// Not retained
	cameraFrustum = nil;	// Not retained
	[super dealloc];
}

// Included to satisfy compiler because property appears in interface for documentation purposes
-(GLuint) vertexCount { return super.vertexCount; }

-(CC3Light*) light { return light; }

-(void) setLight: (CC3Light*) aLight {
	light = aLight;			// Not retained
	[self markDirty];
}

/**
 * Returns the position of the light, as a 3D vector.
 *
 * This could be a location or direction, depending on whether the
 * 4D homogeneous location has a definite location, or is directional.
 */
-(CC3Vector) lightPosition { return CC3VectorFromTruncatedCC3Vector4(light.homogeneousLocation); }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		light = nil;
		cameraFrustum = nil;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3LightCameraBridgeVolume*) another {
	[super populateFrom: another];
	
	light = another.light;		// Not retained
}


#pragma mark Updating

/**
 * Callback indicating that the camera has been transformed.
 * Sets the camera frustum (in case the camera has changed), and marks this volume as dirty.
 */
-(void) nodeWasTransformed: (CC3Node*) aNode {
	if (aNode.isCamera) {
		LogTrace(@"Updating %@ from transform notification from %@", self, aNode.fullDescription);
		cameraFrustum = ((CC3Camera*)aNode).frustum;
		[self markDirty];
	}
}

/** The camera was destroyed. Clear the cached camera frustum. */
-(void) nodeWasDestroyed: (CC3Node*) aNode {
	if (aNode.isCamera) cameraFrustum = nil;
}

/**
 * Returns whether the light is located in front of the plane.
 *
 * Performs a 4D dot-product between the plane definition, and the homegeneous location
 * of the light, which magically works for both directional and positional lights.
 */
-(BOOL) isLightInFrontOfPlane: (CC3Plane) aPlane {
	return CC3Vector4IsInFrontOfPlane(light.homogeneousLocation, aPlane);
}


#pragma mark Intersection testing

/** Overridden to include the homogeneous location of the light into the vertex test. */
-(BOOL) areAllVerticesInFrontOf: (CC3Plane) plane {
	return [self isLightInFrontOfPlane: plane] && [super areAllVerticesInFrontOf: plane];
}

@end


#pragma mark -
#pragma mark CC3ShadowCastingVolume

@implementation CC3ShadowCastingVolume

-(CC3Plane*) planes {
	[self updateIfNeeded];
	return planes;
}

-(GLuint) planeCount {
	[self updateIfNeeded];
	return planeCount;
}

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return vertices;
}

-(GLuint) vertexCount {
	[self updateIfNeeded];
	return vertexCount;
}

/**
 * If the specified vertex does not already exist in the vertices array,
 * it is added to the array, and the vertexCount property is incremented.
 */
-(void) addUniqueVertex: (CC3Vector) aLocation {
	for (GLuint vtxIdx = 0; vtxIdx < vertexCount; vtxIdx++) {
		if (CC3VectorsAreEqual(aLocation, vertices[vtxIdx])) return;
	}
	vertices[vertexCount++] = aLocation;
}

/** Adds the specified plane to the planes array, and increments the planeCount property. */
-(void) addPlane: (CC3Plane) aPlane { planes[planeCount++] = aPlane; }

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @" from light at %@", NSStringFromCC3Vector4(light.homogeneousLocation)];
	[self appendPlanesTo: desc];
	[self appendVerticesTo: desc];
	return desc;
}


#pragma mark Updating

-(void) checkPlaneEdge: (CC3Plane) edgePlane start: (CC3Vector) v1 end:  (CC3Vector) v2 {
	if ( [self isLightInFrontOfPlane: edgePlane] ) {
		CC3Vector v3 = light.isDirectionalOnly
							? CC3VectorAdd(v2, self.lightPosition) 
							: self.lightPosition;
		[self addPlane: CC3PlaneFromLocations(v1, v2, v3)];
	}
}

-(void) checkPlane: (CC3Plane) aPlane
		  withEdge: (CC3Plane) edgePlane1 at: (CC3Vector) v1
		  withEdge: (CC3Plane) edgePlane2 at: (CC3Vector) v2
		  withEdge: (CC3Plane) edgePlane3 at: (CC3Vector) v3
		  withEdge: (CC3Plane) edgePlane4 at: (CC3Vector) v4 {
	
	if( ![self isLightInFrontOfPlane: aPlane] ) {
		[self addPlane: aPlane];
		
		[self addUniqueVertex: v1];
		[self addUniqueVertex: v2];
		[self addUniqueVertex: v3];
		[self addUniqueVertex: v4];
		
		[self checkPlaneEdge: edgePlane1 start: v1 end: v2];
		[self checkPlaneEdge: edgePlane2 start: v2 end: v3];
		[self checkPlaneEdge: edgePlane3 start: v3 end: v4];
		[self checkPlaneEdge: edgePlane4 start: v4 end: v1];
	}
}

-(void) buildPlanes {
	
	planeCount = 0;
	vertexCount = 0;
	
	CC3Frustum* cf = cameraFrustum;
	
	[self checkPlane: cf.leftPlane
			withEdge: cf.farPlane at: cf.farBottomLeft
			withEdge: cf.topPlane at: cf.farTopLeft
			withEdge: cf.nearPlane at: cf.nearTopLeft
			withEdge: cf.bottomPlane at: cf.nearBottomLeft];
	
	[self checkPlane: cf.rightPlane
			withEdge: cf.nearPlane at: cf.nearBottomRight
			withEdge: cf.topPlane at: cf.nearTopRight
			withEdge: cf.farPlane at: cf.farTopRight
			withEdge: cf.bottomPlane at: cf.farBottomRight];
	
	[self checkPlane: cf.topPlane
			withEdge: cf.leftPlane at: cf.nearTopLeft
			withEdge: cf.farPlane at: cf.farTopLeft
			withEdge: cf.rightPlane at: cf.farTopRight
			withEdge: cf.nearPlane at: cf.nearTopRight];
	
	[self checkPlane: cf.bottomPlane
			withEdge: cf.rightPlane at: cf.nearBottomRight
			withEdge: cf.farPlane at: cf.farBottomRight
			withEdge: cf.leftPlane at: cf.farBottomLeft
			withEdge: cf.nearPlane at: cf.nearBottomLeft];
	
	[self checkPlane: cf.nearPlane
			withEdge: cf.leftPlane at: cf.nearBottomLeft
			withEdge: cf.topPlane at: cf.nearTopLeft
			withEdge: cf.rightPlane at: cf.nearTopRight
			withEdge: cf.bottomPlane at: cf.nearBottomRight];
	
	[self checkPlane: cf.farPlane
			withEdge: cf.rightPlane at: cf.farBottomRight
			withEdge: cf.topPlane at: cf.farTopRight
			withEdge: cf.leftPlane at: cf.farTopLeft
			withEdge: cf.bottomPlane at: cf.farBottomLeft];

	if ( !light.isDirectionalOnly ) [self addUniqueVertex: self.lightPosition];
	
	LogTrace(@"Built %@ from %@", self.fullDescription, cameraFrustum.fullDescription);
}

@end


#pragma mark -
#pragma mark CC3CameraShadowVolume

// Indices of the five boundary vertices
#define kCC3TopLeftIdx	0
#define kCC3TopRgtIdx	1
#define kCC3BtmLeftIdx	2
#define kCC3BtmRgtIdx	3
#define kCC3LightIdx	4

// Indices of the six boundary planes
#define kCC3TopIdx		0
#define kCC3BotmIdx		1
#define kCC3LeftIdx		2
#define kCC3RgtIdx		3
#define kCC3NearIdx		4
#define kCC3FarIdx		5

@implementation CC3CameraShadowVolume

-(CC3Vector) topLeft { return self.vertices[kCC3TopLeftIdx]; }
-(CC3Vector) topRight { return self.vertices[kCC3TopRgtIdx]; }
-(CC3Vector) bottomLeft { return self.vertices[kCC3BtmLeftIdx]; }
-(CC3Vector) bottomRight { return self.vertices[kCC3BtmRgtIdx]; }

-(CC3Plane*) planes {
	[self updateIfNeeded];
	return planes;
}

-(GLuint) planeCount { return 6; }

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return vertices;
}

-(GLuint) vertexCount {
	[self updateIfNeeded];
	return light.isDirectionalOnly ? 4 : 5;
}

-(CC3Plane) topPlane { return self.planes[kCC3TopIdx]; }
-(CC3Plane) bottomPlane { return self.planes[kCC3BotmIdx]; }
-(CC3Plane) leftPlane { return self.planes[kCC3LeftIdx]; }
-(CC3Plane) rightPlane { return self.planes[kCC3RgtIdx]; }
-(CC3Plane) nearPlane { return self.planes[kCC3NearIdx]; }
-(CC3Plane) farPlane { return self.planes[kCC3FarIdx]; }


#pragma mark Updating

/** Updates the vertices from the camera frustum. */
-(void) buildVolume {
	vertices[kCC3TopLeftIdx] = cameraFrustum.nearTopLeft;
	vertices[kCC3TopRgtIdx] = cameraFrustum.nearTopRight;
	vertices[kCC3BtmLeftIdx] = cameraFrustum.nearBottomLeft;
	vertices[kCC3BtmRgtIdx] = cameraFrustum.nearBottomRight;
	vertices[kCC3LightIdx] = self.lightPosition;
}

/**
 * Builds the planes of the pyramid by taking points on the near clipping plane
 * as the base of the pyramid, and the light location as the apex of the pyramid.
 *
 * If the light is directional, then the pyramid will actually become an elongated
 * box extending out to infinity, with opposite sides parallel.
 *
 * If the light is actually behind the camera, then the planes are adjusted so that
 * they are oriented correctly for a pyramid behind the near camera plane.
 *
 * All planes have their normals pointing outward.
 */
-(void) buildPlanes {
	
	// Get the 3D position that corresponds to either a location or a direction
	CC3Vector lightPos = self.lightPosition;
	CC3Vector lightDir;
	CC3Vector tl = vertices[kCC3TopLeftIdx];
	CC3Vector tr = vertices[kCC3TopRgtIdx];
	CC3Vector bl = vertices[kCC3BtmLeftIdx];
	CC3Vector br = vertices[kCC3BtmRgtIdx];
	
	// The near plane does not depend on the light position
	planes[kCC3NearIdx] = CC3PlaneFromLocations(bl, br, tr);
	
	if (light.isDirectionalOnly) {
		
		// The light is infinitely far away. The light position is actually a direction to it.
		// Opposite sides are parallel and pointing in the direction of the light source.
		// For each edge of the near clipping rectangle, generate the third location on the
		// plane by adding the light direction to one of the locations on the edge. 
		lightDir = lightPos;
		
		planes[kCC3LeftIdx] = CC3PlaneFromLocations(bl, tl, CC3VectorAdd(tl, lightDir));
		planes[kCC3RgtIdx] = CC3PlaneFromLocations(tr, br, CC3VectorAdd(br, lightDir));
		
		planes[kCC3TopIdx] = CC3PlaneFromLocations(tl, tr, CC3VectorAdd(tr, lightDir));
		planes[kCC3BotmIdx] = CC3PlaneFromLocations(br, bl, CC3VectorAdd(bl, lightDir));
		
		// The far plane is parallel to the near plane, but the normal points in
		// the opposite direction. Locate the far plane at the light position,
		// and then move it out an infinite distance, in the same direction.
		planes[kCC3FarIdx] = CC3PlaneNegate(planes[kCC3NearIdx]);
		planes[kCC3FarIdx].d = -CC3VectorDot(lightPos, CC3PlaneNormal(planes[kCC3FarIdx]));
		planes[kCC3FarIdx].d = SIGN(planes[kCC3FarIdx].d) * INFINITY;

	} else {
		
		// The light is at a definite position. All side planes meet at the light position.
		// The direction is taken from the center of the near clipping rectangle.
		lightDir = CC3VectorDifference(lightPos, CC3VectorAverage(tl, br));
		
		planes[kCC3LeftIdx] = CC3PlaneFromLocations(bl, tl, lightPos);
		planes[kCC3RgtIdx] = CC3PlaneFromLocations(tr, br, lightPos);
		
		planes[kCC3TopIdx] = CC3PlaneFromLocations(tl, tr, lightPos);
		planes[kCC3BotmIdx] = CC3PlaneFromLocations(br, bl, lightPos);
		
		// The far plane is parallel to the near plane, but the normal points in
		// the opposite direction. Locate the far plane at the light position.
		planes[kCC3FarIdx] = CC3PlaneNegate(planes[kCC3NearIdx]);
		planes[kCC3FarIdx].d = -CC3VectorDot(lightPos, CC3PlaneNormal(planes[kCC3FarIdx]));

	}
	
	// Finally, determine if the light source is actually behind the camera, by crossing
	// two sides of the near plane to determine the camera direction, and dotting with a
	// vector from the light position and a point on the near plane.
	CC3Vector left = CC3VectorDifference(tl, bl);
	CC3Vector bottom = CC3VectorDifference(br, bl);
	CC3Vector camDir = CC3VectorCross(left, bottom);
	BOOL isBehindCamera = (CC3VectorDot(camDir, lightDir) < 0);
	
	if ( isBehindCamera ) {
		planes[kCC3LeftIdx] = CC3PlaneNegate(planes[kCC3LeftIdx]);
		planes[kCC3RgtIdx] = CC3PlaneNegate(planes[kCC3RgtIdx]);
		planes[kCC3TopIdx] = CC3PlaneNegate(planes[kCC3TopIdx]);
		planes[kCC3BotmIdx] = CC3PlaneNegate(planes[kCC3BotmIdx]);
		planes[kCC3NearIdx] = CC3PlaneNegate(planes[kCC3NearIdx]);
		planes[kCC3FarIdx] = CC3PlaneNegate(planes[kCC3FarIdx]);
	}
	
	LogTrace(@"Built %@ from %@ light %@ the camera",
				  self.fullDescription, (self.isLightDirectional ? @"directional" : @"positional"),
				  (isBehindCamera ? @"behind" : @"in front of"));
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @" from light at %@", NSStringFromCC3Vector4(light.homogeneousLocation)];
	[desc appendFormat: @"\n\tleftPlane: %@", NSStringFromCC3Plane(self.leftPlane)];
	[desc appendFormat: @"\n\trightPlane: %@", NSStringFromCC3Plane(self.rightPlane)];
	[desc appendFormat: @"\n\ttopPlane: %@", NSStringFromCC3Plane(self.topPlane)];
	[desc appendFormat: @"\n\tbottomPlane: %@", NSStringFromCC3Plane(self.bottomPlane)];
	[desc appendFormat: @"\n\tnearPlane: %@", NSStringFromCC3Plane(self.nearPlane)];
	[desc appendFormat: @"\n\tfarPlane: %@", NSStringFromCC3Plane(self.farPlane)];
	[desc appendFormat: @"\n\ttopLeft: %@", NSStringFromCC3Vector(self.topLeft)];
	[desc appendFormat: @"\n\ttopRight: %@", NSStringFromCC3Vector(self.topRight)];
	[desc appendFormat: @"\n\tbottomLeft: %@", NSStringFromCC3Vector(self.bottomLeft)];
	[desc appendFormat: @"\n\tbottomRight: %@", NSStringFromCC3Vector(self.bottomRight)];
	return desc;
}

@end


#pragma mark -
#pragma mark CC3Node extension for lights

@implementation CC3Node (Lighting)

-(BOOL) isLight { return NO; }

@end

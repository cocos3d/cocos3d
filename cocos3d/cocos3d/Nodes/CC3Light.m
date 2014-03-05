/*
 * CC3Light.m
 *
 * cocos3d 2.0.0
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
 * See header file CC3Light.h for full API documentation.
 */

#import "CC3Light.h"
#import "CC3Camera.h"
#import "CC3ShadowVolumes.h"
#import "CC3Scene.h"
#import "CC3CC2Extensions.h"
#import	"CC3ProjectionMatrix.h"


#pragma mark CC3Light 

@interface CC3LightCameraBridgeVolume (TemplateMethods)
@property(nonatomic, assign) CC3Light* light;
@end

@interface CC3Node (TemplateMethods)
-(void) updateTargetLocation;
@end


@implementation CC3Light

@synthesize lightIndex=_lightIndex, shouldCopyLightIndex=_shouldCopyLightIndex;
@synthesize ambientColor=_ambientColor, diffuseColor=_diffuseColor, specularColor=_specularColor;
@synthesize spotExponent=_spotExponent, spotCutoffAngle=_spotCutoffAngle;
@synthesize attenuation=_attenuation, isDirectionalOnly=_isDirectionalOnly;
@synthesize shadows=_shadows, shadowIntensityFactor=_shadowIntensityFactor;

-(void) dealloc {
	[self cleanupShadows];		// Includes releasing the shadows array, camera shadow volume & shadow painter
	[self returnLightIndex: _lightIndex];
	[super dealloc];
}

-(BOOL) isLight { return YES; }

// Overridden to take into consideration the isDirectionalOnly property
-(CC3Vector4) globalHomogeneousPosition {
	return (self.isDirectionalOnly
			? CC3Vector4FromDirection(self.globalLocation)
			: CC3Vector4FromLocation(self.globalLocation));
}

/** Overridden to return NO so that the forwardDirection aligns with the negative-Z-axis. */
-(BOOL) shouldReverseForwardDirection { return NO; }

// Clamp to valid range.
-(void) setSpotExponent: (GLfloat) spotExp { _spotExponent = CLAMP(spotExp, 0.0f, 128.0f); }

-(void) setAmbientColor: (ccColor4F) aColor {
	_ambientColor = aColor;
	[self.scene updateRelativeLightIntensities];
}

-(void) setDiffuseColor: (ccColor4F) aColor {
	_diffuseColor = aColor;
	[self.scene updateRelativeLightIntensities];
}

-(void) setShadowIntensityFactor: (GLfloat) shdwIntFactor {
	_shadowIntensityFactor = shdwIntFactor;
	[self.scene updateRelativeLightIntensities];
}

-(void) setVisible: (BOOL) isVisible {
	super.visible = isVisible;
	[self.scene updateRelativeLightIntensities];
}

// Deprecated property
-(CC3AttenuationCoefficients) attenuationCoefficients { return self.attenuation; }
-(void) setAttenuationCoefficients: (CC3AttenuationCoefficients) attenuationCoefficients {
	self.attenuation = attenuationCoefficients;
}

// Keep the compiler happy with the additional declaration
// of this property on this class for documentation purposes
-(CC3Vector) forwardDirection { return super.forwardDirection; }
-(void) setForwardDirection: (CC3Vector) aDirection { super.forwardDirection = aDirection; }


#pragma mark CCRGBAProtocol support

/** Returns diffuse color. */
-(ccColor3B) color { return CCC3BFromCCC4F(_diffuseColor); }

// Set both diffuse and ambient colors, retaining the alpha of each
-(void) setColor: (ccColor3B) color {
	self.ambientColor = CCC4FFromColorAndOpacity(color, _ambientColor.a);
	self.diffuseColor = CCC4FFromColorAndOpacity(color, _diffuseColor.a);

	super.color = color;
}

/** Returns diffuse alpha. */
-(GLubyte) opacity { return CCColorByteFromFloat(_diffuseColor.a); }

/** Set opacity of all colors, retaining the colors of each. */
-(void) setOpacity: (GLubyte) opacity {
	GLfloat af = CCColorFloatFromByte(opacity);
	_ambientColor.a = af;
	_diffuseColor.a = af;
	_specularColor.a = af;

	super.opacity = opacity;
}

#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName withLightIndex: (GLuint) ltIndx {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		if (ltIndx == UINT_MAX) return nil;		// All the lights have been used already.
			
		_lightIndex = ltIndx;
		_shadows = nil;
		_shadowCastingVolume = nil;
		_cameraShadowVolume = nil;
		_stencilledShadowPainter = nil;
		_ambientColor = kCC3DefaultLightColorAmbient;
		_diffuseColor = kCC3DefaultLightColorDiffuse;
		_specularColor = kCC3DefaultLightColorSpecular;
		_spotExponent = 0;
		_spotCutoffAngle = kCC3SpotCutoffNone;
		_attenuation = kCC3DefaultLightAttenuationCoefficients;
		_shadowIntensityFactor = 1.0;
		_isDirectionalOnly = YES;
		_shouldCopyLightIndex = NO;
		_shouldCastShadowsWhenInvisible = NO;
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
	
	_ambientColor = another.ambientColor;
	_diffuseColor = another.diffuseColor;
	_specularColor = another.specularColor;
	_spotExponent = another.spotExponent;
	_spotCutoffAngle = another.spotCutoffAngle;
	_attenuation = another.attenuation;
	_shadowIntensityFactor = another.shadowIntensityFactor;
	_isDirectionalOnly = another.isDirectionalOnly;
	_shouldCopyLightIndex = another.shouldCopyLightIndex;
	_shouldCastShadowsWhenInvisible = another.shouldCastShadowsWhenInvisible;
}

/**
 * Creates a copy of this node. The value of the lightIndex property of the new copy is
 * determined by the value of the shouldCopyLightIndex property of this node. The copy
 * will be assigned either the same lightIndex as this node, or a new lightIndex value.
 */
-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName asClass: (Class) aClass {
	GLuint ltIndx = _shouldCopyLightIndex ? _lightIndex : [self nextLightIndex];
	CC3Light* aCopy = [[aClass allocWithZone: zone] initWithName: aName withLightIndex: ltIndx];
	[aCopy populateFrom: self];
	return aCopy;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ light index: %u", [super description], _lightIndex];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, (%@), ambient: %@, diffuse: %@, specular: %@, spotAngle: %.2f, spotExponent: %.6f, attenuation: %@",
			[super fullDescription], (self.isDirectionalOnly ? @"directional" : @"positional"),
			NSStringFromCCC4F(_ambientColor), NSStringFromCCC4F(_diffuseColor),
			NSStringFromCCC4F(_specularColor), _spotCutoffAngle, _spotExponent,
			NSStringFromCC3AttenuationCoefficients(_attenuation)];
}

/** Scaling does not apply to lights. */
-(void) applyScaling {}

/**
 * Scaling does not apply to lights. Return the globalScale of the parent node,
 * or unit scaling if no parent.
 */
-(CC3Vector) globalScale { return _parent ? _parent.globalScale : kCC3VectorUnitCube; }

/** Overridden to update the camera shadow frustum with the global location of this light */
-(void) markTransformDirty {
	[super markTransformDirty];
	[_shadowCastingVolume markDirty];
	[_cameraShadowVolume markDirty];
}


#pragma mark Drawing

-(void) turnOnWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	if (self.visible) {
		LogTrace(@"Turning on %@", self);
		[gl enableLight: YES at: _lightIndex];
		[self applyPositionWithVisitor: visitor];
		[self applyDirectionWithVisitor: visitor];
		[self applyAttenuationWithVisitor: visitor];
		[self applyColorWithVisitor: visitor];
	} else {
		[gl enableLight: NO at: _lightIndex];
	}
}

-(void) turnOffWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor.gl enableLight: NO at: _lightIndex];
}

/**
 * Template method that sets the position of this light in the GL engine to the value of
 * the globalHomogeneousPosition property of this node.
 */	
-(void) applyPositionWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[visitor.gl setLightPosition: self.globalHomogeneousPosition at: _lightIndex];
}

/**
 * Template method that sets the spot direction, spot exponent, and spot cutoff angle of this light
 * in the GL engine to the values of the globalForwardDirection, spotExponent and spotCutoffAngle
 * properties of this node, respectively. The direction and exponent are only valid if a cutoff has
 * been specified and less than 90 degrees, otherwise the light is treated as omnidirectional.
 * OpenGL ES only supports angles less than 90 degrees, so anything above is treated as omnidirectional.
 */
-(void) applyDirectionWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	if (_spotCutoffAngle <= 90.0f) {
		[gl setSpotlightDirection: self.globalForwardDirection at: _lightIndex];
		[gl setSpotlightCutoffAngle: _spotCutoffAngle at: _lightIndex];
		[gl setSpotlightFadeExponent: _spotExponent at: _lightIndex];
	} else {
		[gl setSpotlightCutoffAngle: kCC3SpotCutoffNone at: _lightIndex];
	}
}

/**
 * Template method that sets the light intensity attenuation characteristics
 * in the GL engine from the attenuation property of this light.
 */
-(void) applyAttenuationWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if ( !_isDirectionalOnly ) [visitor.gl setLightAttenuation: _attenuation at: _lightIndex];
}

/**
 * Template method that sets the ambient, diffuse and specular colors of this light
 * in the GL engine to the values of the ambientColor, diffuseColor and specularColor
 * properties of this node, respectively.
 */
-(void) applyColorWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	[gl setLightAmbientColor: _ambientColor at: _lightIndex];
	[gl setLightDiffuseColor: _diffuseColor at: _lightIndex];
	[gl setLightSpecularColor: _specularColor at: _lightIndex];
}


#pragma mark Shadows

-(BOOL) shouldCastShadowsWhenInvisible { return _shouldCastShadowsWhenInvisible; }

-(void) setShouldCastShadowsWhenInvisible: (BOOL) shouldCast {
	_shouldCastShadowsWhenInvisible = shouldCast;
	super.shouldCastShadowsWhenInvisible = shouldCast;
}

/**
 * If this action is occuring on a background thread, and this node is already part of the
 * scene being rendered, the operation is queued for execution on the rendering thread, to
 * avoid the possibility of adding a shadow in the middle of a render iteration.
 */
-(void) addShadow: (id<CC3ShadowProtocol>) aShadowNode {
	if ( !CC3OpenGL.sharedGL.isRenderingContext && self.scene )
		[self addShadowFromBackgroundThread: aShadowNode];
	else
		[self addShadowNow: aShadowNode];
}

/** Adds the specified shadow to this light without queuing. */
-(void) addShadowNow: (id<CC3ShadowProtocol>) aShadowNode {
	CC3Assert(aShadowNode, @"Shadow cannot be nil");		// Don't add if shadow is nil
	
	if(!_shadows) _shadows = [NSMutableArray new];			// retained
	[_shadows addObject: aShadowNode];
	aShadowNode.light = self;
	[self addTransformListener: aShadowNode];	// Update the shadow when this light moves.
	
	[self checkShadowCastingVolume];			// Make sure we have the shadow casting volume
	[self checkCameraShadowVolume];				// Make sure we have the camera shadow volume
	[self checkStencilledShadowPainter];		// Make sure we have the shadow painter
}

/**
 * Invoked when a shadow is being added on a background thread, and this parent node is
 * already part of the scene.
 *
 * Since the scene may be in the process of being rendered, the shadow is not added immediately.
 * Instead, all GL activity on this thread is allowed to finish, to ensure all GL components of
 * the shadow node are in place, and then an operation to add the specified shadow is queued to
 * the thread that is performing rendering.
 */
-(void) addShadowFromBackgroundThread: (id<CC3ShadowProtocol>) aShadowNode {
	[CC3OpenGL.sharedGL finish];
	[CC3OpenGL.renderThread runBlockAsync: ^{ [self addShadowNow: aShadowNode]; } ];
	
	// A better design would be to use dispatch queues, but OSX typically
	// renders using a DisplayLink thread instead of the main thread.
//	dispatch_async(dispatch_get_main_queue(), ^{ [self addShadowNow: aShadowNode]; });
}

-(void) removeShadow: (id<CC3ShadowProtocol>) aShadowNode {
	[_shadows removeObjectIdenticalTo: aShadowNode];
	aShadowNode.light = nil;					// So it can't call back here if I'm gone
	if (_shadows && _shadows.count == 0) {
		[_shadows release];
		_shadows = nil;
		[self checkShadowCastingVolume];		// Remove the shadow casting volume
		[self checkCameraShadowVolume];			// Remove the camera shadow volume
		[self checkStencilledShadowPainter];	// Remove the stencilled shadow painter
	}
	[self removeTransformListener: aShadowNode];
}

-(BOOL) hasShadows { return _shadows && _shadows.count > 0; }

-(void) updateShadows { for (id<CC3ShadowProtocol> sv in _shadows) [sv updateShadow]; }

-(CC3ShadowCastingVolume*) shadowCastingVolume { return _shadowCastingVolume; }

/** Detaches old as camera listener, attaches new as camera listener, and attaches light. */
-(void) setShadowCastingVolume: (CC3ShadowCastingVolume*) scVolume {
	if (scVolume == _shadowCastingVolume) return;

	CC3Camera* cam = self.activeCamera;
	[cam removeTransformListener: _shadowCastingVolume];
	[_shadowCastingVolume release];
	
	_shadowCastingVolume = [scVolume retain];
	_shadowCastingVolume.light = self;
	[cam addTransformListener: _shadowCastingVolume];
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
	if (self.hasShadows) {
		if (!_shadowCastingVolume) self.shadowCastingVolume = [CC3ShadowCastingVolume boundingVolume];
	} else {
		self.shadowCastingVolume = nil;
	}
}

-(CC3CameraShadowVolume*) cameraShadowVolume { return _cameraShadowVolume; }

/** Detaches old as camera listener, attaches new as camera listener, and attaches light. */
-(void) setCameraShadowVolume: (CC3CameraShadowVolume*) csVolume {
	if (csVolume == _cameraShadowVolume) return;
		
	CC3Camera* cam = self.activeCamera;
	[cam removeTransformListener: _cameraShadowVolume];
	[_cameraShadowVolume release];
	
	_cameraShadowVolume = [csVolume retain];
	_cameraShadowVolume.light = self;
	[cam addTransformListener: _cameraShadowVolume];
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
	if (self.hasShadows) {
		if (!_cameraShadowVolume) self.cameraShadowVolume = [CC3CameraShadowVolume boundingVolume];
	} else {
		self.cameraShadowVolume = nil;
	}
}

-(CC3StencilledShadowPainterNode*) stencilledShadowPainter { return _stencilledShadowPainter; }

-(void) setStencilledShadowPainter: (CC3StencilledShadowPainterNode*) sspNode {
	if (sspNode == _stencilledShadowPainter) return;
	
	[_stencilledShadowPainter release];
	_stencilledShadowPainter = [sspNode retain];

	[self.scene updateRelativeLightIntensities];	//  Must be done after the ivar is set.
}

/**
 * Creates or removes the stenciled shadow painter mesh node, as needed.
 * 
 * Sets the intensity of the shadow from the intensity of the diffuse component
 * of this light relative to the intensity of all other illumination in the scene.
 */
-(void) checkStencilledShadowPainter {
	if (self.hasShadows) {
		if (!_stencilledShadowPainter)
			self.stencilledShadowPainter = [CC3StencilledShadowPainterNode nodeWithColor: kCCC4FBlack];
	} else {
		self.stencilledShadowPainter = nil;
	}
}

-(void) updateRelativeIntensityFrom: (ccColor4F) totalLight {
	if (_stencilledShadowPainter) {
		GLfloat dIntensity = CCC4FIntensity(self.diffuseColor);
		GLfloat totIntensity = CCC4FIntensity(totalLight);
		GLfloat shadowIntensity =  (dIntensity / totIntensity) * _shadowIntensityFactor;
		_stencilledShadowPainter.opacity = CCColorByteFromFloat(shadowIntensity);
		LogTrace(@"%@ updated shadow intensity to %u from light illumination %@ against total illumination %@ and shadow intensity factor %.3f",
					  self, _stencilledShadowPainter.opacity,
					  NSStringFromCCC4F(self.diffuseColor), NSStringFromCCC4F(self.scene.totalIllumination), _shadowIntensityFactor);
	}
}

// TODO - combine with other shadow techniques - how to make polymorphic?
-(void) drawShadowsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (_shadows && (self.visible || self.shouldCastShadowsWhenInvisible) ) {
		LogTrace(@"%@ drawing %u shadows", self, _shadows.count);
		[self configureStencilParameters: visitor];
		
		for (CC3ShadowVolumeMeshNode* sv in _shadows) [sv drawToStencilWithVisitor: visitor];
		
		[self paintStenciledShadowsWithVisitor: visitor];
		[self cleanupStencilParameters: visitor];
	}
}

/**
 * Turns on stenciling and ensure the stencil buffer can be updated.
 * Turns off writing to the color buffer, because the shadow volumes themselves are invisible.
 */
-(void) configureStencilParameters: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	[gl enableStencilTest: YES];
	gl.stencilMask = ~0;
	gl.colorMask = ccc4(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
	[gl setStencilFunc: GL_ALWAYS reference: 0 mask: ~0];
}

/** Draws the clip-space rectangle on the screen, coloring only those pixels where the stencil is non-zero. */
-(void) paintStenciledShadowsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	
	// Turn color masking back on so that shadow will be painted on the scene.
	// The depth mask will be turned on by the mesh node
	gl.colorMask = ccc4(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
	
	// Set the stencil function so that only those pixels that have a non-zero
	// value in the stencil (and that pass the depth test) will be painted.
	[gl setStencilFunc: GL_NOTEQUAL reference: 0 mask: ~0];
	
	// Don't waste time updating the stencil buffer now.
	gl.stencilMask = 0;
	
	// Paint the shadow to the screen. Only areas that have been marked as being
	// in the stencil buffer as being in the shadow of this light will be shaded.
	[visitor visit: _stencilledShadowPainter];
}

/** Turns stenciling back off. */
-(void) cleanupStencilParameters: (CC3NodeDrawingVisitor*) visitor {
	[visitor.gl enableStencilTest: NO];
}

/**
 * Invoked when this light is being deallocated. Removes all associated
 * shadow nodes from this scene, which also removes the shadows array.
 */
-(void) cleanupShadows {
	NSArray* myShadows = [_shadows copy];
	for (CC3Node* sv in myShadows) [sv remove];
	[myShadows release];
}


#pragma mark Managing the pool of available GL lights

// Class variable that tracks the indexes of the lights that are in use.
// When a new instance is instantiated, it's lightIndex property is assigned from the pool
// of indexes. When the instance is deallocated, its index is returned to the pool for use
// by any subsequently instantiated lights.
static BOOL _lightIndexPool[32] = {NO};

+(BOOL*) lightIndexPool { return _lightIndexPool; }

// Indicates the staring index to use when instantiating new lights.
static GLuint lightPoolStartIndex = 0;

/**
 * Assigns and returns the next available light index from the pool.
 * If no more lights are available, returns UINT_MAX.
 */
-(GLuint) nextLightIndex {
	BOOL* indexPool = [[self class] lightIndexPool];
	GLuint platformMaxLights = CC3OpenGL.sharedGL.maxNumberOfLights;
	for (int lgtIdx = lightPoolStartIndex; lgtIdx < platformMaxLights; lgtIdx++) {
		if (!indexPool[lgtIdx]) {
			LogTrace(@"Allocating light index %u", lgtIdx);
			indexPool[lgtIdx] = YES;
			return lgtIdx;
		}
	}
	CC3Assert(NO, @"Too many lights. Only %u lights may be created.", platformMaxLights);
	return UINT_MAX;
}

/** Returns the specified light index to the pool. */
-(void) returnLightIndex: (GLuint) aLightIndex {
	LogTrace(@"Returning light index %u", aLightIndex);
	BOOL* indexPool = [[self class] lightIndexPool];
	indexPool[aLightIndex] = NO;
}

+(GLuint) lightCount {
	GLuint count = 0;
	BOOL* indexPool = [self lightIndexPool];
	GLuint platformMaxLights = CC3OpenGL.sharedGL.maxNumberOfLights;
	for (int i = lightPoolStartIndex; i < platformMaxLights; i++) if (indexPool[i]) count++;
	return lightPoolStartIndex + count;
}

+(GLuint) lightPoolStartIndex { return lightPoolStartIndex; }

+(void) setLightPoolStartIndex: (GLuint) newStartIndex { lightPoolStartIndex = newStartIndex; }

+(void) disableReservedLightsWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	for (int ltIdx = 0; ltIdx < lightPoolStartIndex; ltIdx++) [visitor.gl enableLight: NO at: ltIdx];
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
	_light = nil;		// weak reference
	[super dealloc];
}

// Included to satisfy compiler because property appears in interface for documentation purposes
-(GLuint) vertexCount { return super.vertexCount; }

-(CC3Light*) light { return _light; }

-(void) setLight: (CC3Light*) aLight {
	_light = aLight;			// weak reference
	[self markDirty];
}

/**
 * Returns the position of the light, as a 3D vector.
 *
 * This could be a location or direction, depending on whether the
 * 4D homogeneous location has a definite location, or is directional.
 */
-(CC3Vector) lightPosition { return _light.globalHomogeneousPosition.v; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_light = nil;
	}
	return self;
}

-(void) populateFrom: (CC3LightCameraBridgeVolume*) another {
	[super populateFrom: another];
	
	_light = another.light;		// weak reference
}


#pragma mark Updating

/**
 * Callback indicating that the camera has been transformed.
 * Sets the camera frustum (in case the camera has changed), and marks this volume as dirty.
 */
-(void) nodeWasTransformed: (CC3Node*) aNode { if (aNode.isCamera) [self markDirty]; }

-(void) nodeWasDestroyed: (CC3Node*) aNode {}

/**
 * Returns whether the light is located in front of the plane.
 *
 * Performs a 4D dot-product between the plane definition, and the homegeneous location
 * of the light, which magically works for both directional and positional lights.
 */
-(BOOL) isLightInFrontOfPlane: (CC3Plane) aPlane {
	return CC3Vector4IsInFrontOfPlane(_light.globalHomogeneousPosition, aPlane);
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
	return _planes;
}

-(GLuint) planeCount {
	[self updateIfNeeded];
	return _planeCount;
}

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return _vertices;
}

-(GLuint) vertexCount {
	[self updateIfNeeded];
	return _vertexCount;
}

/**
 * If the specified vertex does not already exist in the vertices array,
 * it is added to the array, and the vertexCount property is incremented.
 */
-(void) addUniqueVertex: (CC3Vector) aLocation {
	for (GLuint vtxIdx = 0; vtxIdx < _vertexCount; vtxIdx++)
		if (CC3VectorsAreEqual(aLocation, _vertices[vtxIdx])) return;
	_vertices[_vertexCount++] = aLocation;
}

/** Adds the specified plane to the planes array, and increments the planeCount property. */
-(void) addPlane: (CC3Plane) aPlane { _planes[_planeCount++] = aPlane; }

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @" from light at %@", NSStringFromCC3Vector4(_light.globalHomogeneousPosition)];
	[self appendPlanesTo: desc];
	[self appendVerticesTo: desc];
	return desc;
}


#pragma mark Updating

-(void) checkPlaneEdge: (CC3Plane) edgePlane start: (CC3Vector) v1 end:  (CC3Vector) v2 {
	if ( [self isLightInFrontOfPlane: edgePlane] ) {
		CC3Vector v3 = _light.isDirectionalOnly
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
	
	_planeCount = 0;
	_vertexCount = 0;
	
    CC3Frustum* cf = _light.activeCamera.frustum;
	
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

	if ( !_light.isDirectionalOnly ) [self addUniqueVertex: self.lightPosition];
	
	LogTrace(@"Built %@ from %@", self.fullDescription, cf.fullDescription);
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
	return _planes;
}

-(GLuint) planeCount { return 6; }

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return _vertices;
}

-(GLuint) vertexCount {
	[self updateIfNeeded];
	return _light.isDirectionalOnly ? 4 : 5;
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
    CC3Frustum* cf = _light.activeCamera.frustum;
	_vertices[kCC3TopLeftIdx] = cf.nearTopLeft;
	_vertices[kCC3TopRgtIdx] = cf.nearTopRight;
	_vertices[kCC3BtmLeftIdx] = cf.nearBottomLeft;
	_vertices[kCC3BtmRgtIdx] = cf.nearBottomRight;
	_vertices[kCC3LightIdx] = self.lightPosition;
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
	CC3Vector tl = _vertices[kCC3TopLeftIdx];
	CC3Vector tr = _vertices[kCC3TopRgtIdx];
	CC3Vector bl = _vertices[kCC3BtmLeftIdx];
	CC3Vector br = _vertices[kCC3BtmRgtIdx];
	
	// The near plane does not depend on the light position
	_planes[kCC3NearIdx] = CC3PlaneFromLocations(bl, br, tr);
	
	if (_light.isDirectionalOnly) {
		
		// The light is infinitely far away. The light position is actually a direction to it.
		// Opposite sides are parallel and pointing in the direction of the light source.
		// For each edge of the near clipping rectangle, generate the third location on the
		// plane by adding the light direction to one of the locations on the edge. 
		lightDir = lightPos;
		
		_planes[kCC3LeftIdx] = CC3PlaneFromLocations(bl, tl, CC3VectorAdd(tl, lightDir));
		_planes[kCC3RgtIdx] = CC3PlaneFromLocations(tr, br, CC3VectorAdd(br, lightDir));
		
		_planes[kCC3TopIdx] = CC3PlaneFromLocations(tl, tr, CC3VectorAdd(tr, lightDir));
		_planes[kCC3BotmIdx] = CC3PlaneFromLocations(br, bl, CC3VectorAdd(bl, lightDir));
		
		// The far plane is parallel to the near plane, but the normal points in
		// the opposite direction. Locate the far plane at the light position,
		// and then move it out an infinite distance, in the same direction.
		_planes[kCC3FarIdx] = CC3PlaneNegate(_planes[kCC3NearIdx]);
		_planes[kCC3FarIdx].d = -CC3VectorDot(lightPos, CC3PlaneNormal(_planes[kCC3FarIdx]));
		_planes[kCC3FarIdx].d = SIGN(_planes[kCC3FarIdx].d) * INFINITY;

	} else {
		
		// The light is at a definite position. All side planes meet at the light position.
		// The direction is taken from the center of the near clipping rectangle.
		lightDir = CC3VectorDifference(lightPos, CC3VectorAverage(tl, br));
		
		_planes[kCC3LeftIdx] = CC3PlaneFromLocations(bl, tl, lightPos);
		_planes[kCC3RgtIdx] = CC3PlaneFromLocations(tr, br, lightPos);
		
		_planes[kCC3TopIdx] = CC3PlaneFromLocations(tl, tr, lightPos);
		_planes[kCC3BotmIdx] = CC3PlaneFromLocations(br, bl, lightPos);
		
		// The far plane is parallel to the near plane, but the normal points in
		// the opposite direction. Locate the far plane at the light position.
		_planes[kCC3FarIdx] = CC3PlaneNegate(_planes[kCC3NearIdx]);
		_planes[kCC3FarIdx].d = -CC3VectorDot(lightPos, CC3PlaneNormal(_planes[kCC3FarIdx]));

	}
	
	// Finally, determine if the light source is actually behind the camera, by crossing
	// two sides of the near plane to determine the camera direction, and dotting with a
	// vector from the light position and a point on the near plane.
	CC3Vector left = CC3VectorDifference(tl, bl);
	CC3Vector bottom = CC3VectorDifference(br, bl);
	CC3Vector camDir = CC3VectorCross(left, bottom);
	BOOL isBehindCamera = (CC3VectorDot(camDir, lightDir) < 0);
	
	if ( isBehindCamera ) {
		_planes[kCC3LeftIdx] = CC3PlaneNegate(_planes[kCC3LeftIdx]);
		_planes[kCC3RgtIdx] = CC3PlaneNegate(_planes[kCC3RgtIdx]);
		_planes[kCC3TopIdx] = CC3PlaneNegate(_planes[kCC3TopIdx]);
		_planes[kCC3BotmIdx] = CC3PlaneNegate(_planes[kCC3BotmIdx]);
		_planes[kCC3NearIdx] = CC3PlaneNegate(_planes[kCC3NearIdx]);
		_planes[kCC3FarIdx] = CC3PlaneNegate(_planes[kCC3FarIdx]);
	}
	
	LogTrace(@"Built %@ from %@ light %@ the camera",
				  self.fullDescription, (_light.isDirectionalOnly ? @"directional" : @"positional"),
				  (isBehindCamera ? @"behind" : @"in front of"));
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @" from light at %@", NSStringFromCC3Vector4(_light.globalHomogeneousPosition)];
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

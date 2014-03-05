/*
 * CC3Billboard.m
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
 * See header file CC3Billboard.h for full API documentation.
 */

#import "CC3Billboard.h"
#import "CC3UtilityMeshNodes.h"
#import "CC3Scene.h"
#import "CC3CC2Extensions.h"
#import "CC3OpenGLFixedPipeline.h"


@interface CC3MeshNode (TemplateMethods)
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) applyMaterialWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) applyShaderProgramWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end

@implementation CC3Billboard

@synthesize billboard=_billboard, offsetPosition=_offsetPosition, unityScaleDistance=_unityScaleDistance;
@synthesize minimumBillboardScale=_minimumBillboardScale, maximumBillboardScale=_maximumBillboardScale;
@synthesize shouldNormalizeScaleToDevice=_shouldNormalizeScaleToDevice;
@synthesize shouldDrawAs2DOverlay=_shouldDrawAs2DOverlay, textureUnitIndex=_textureUnitIndex;
@synthesize shouldAlwaysMeasureBillboardBoundingRect=_shouldAlwaysMeasureBillboardBoundingRect;
@synthesize shouldMaximizeBillboardBoundingRect=_shouldMaximizeBillboardBoundingRect;
@synthesize shouldUpdateUnseenBillboard=_shouldUpdateUnseenBillboard;

-(void) dealloc {
	self.billboard = nil;		// Use setter to cleanup and release the 2D billboard.
	[super dealloc];
}

-(BOOL) isBillboard { return YES; }

-(void) setBillboard: (CCNode*)aCCNode {
	if (aCCNode == _billboard) return;	// Don't do anything if it's the same 2D billboard...
										// ...otherwise it will be detached from scheduler.
	// Old 2D billboard
	[_billboard onExit];				// Turn off running state and pause activity.
	[_billboard cleanup];				// Detach billboard from scheduler and actions.
	[_billboard release];

	// New 2D billboard
	_billboard = [aCCNode retain];
	_billboard.visible = self.visible;
	// Retrieve the blend function from the 2D node and align this 3D node's material with it.
	if ([_billboard conformsToProtocol: @protocol(CCBlendProtocol)]) {
		self.blendFunc = ((id<CCBlendProtocol>)_billboard).blendFunc;
	}
	[self normalizeBillboardScaleToDevice];
	if (self.isRunning) [_billboard onEnter];	// If running, start scheduled activities on new billboard
}

-(void) setShouldDrawAs2DOverlay: (BOOL) drawAsOverlay {
	_shouldDrawAs2DOverlay = drawAsOverlay;
	[self normalizeBillboardScaleToDevice];
}

-(void) setShouldNormalizeScaleToDevice: (BOOL) normalizeToDevice {
	_shouldNormalizeScaleToDevice = normalizeToDevice;
	[self normalizeBillboardScaleToDevice];
}

/**
 * If in 3D mode and should be normalized, force scale of billboard
 * to a factor determined by the type of billboard.
 */
-(void) normalizeBillboardScaleToDevice {
	if (!_shouldDrawAs2DOverlay && _shouldNormalizeScaleToDevice)
		_billboard.scale = _billboard.billboard3DContentScaleFactor;
}

// Overridden to enable or disable the CCNode
// Thanks to cocos3d user Sev_Inf for submitting this patch
-(void) setIsRunning: (BOOL) shouldRun {
    [super setIsRunning:shouldRun];
	
	if (self.isRunning && !_billboard.isRunning)
		[_billboard onEnter];
	else if (!self.isRunning && _billboard.isRunning)
		[_billboard onExit];
}

/** Returns whether the bounding rectangle needs to be measured on each update pass. */
-(BOOL) hasDynamicBoundingRect {
	return (_shouldDrawAs2DOverlay
			|| _shouldAlwaysMeasureBillboardBoundingRect
			|| _shouldMaximizeBillboardBoundingRect);
}

-(CGRect) billboardBoundingRect {
	if (_billboard && (self.hasDynamicBoundingRect || CGRectIsNull(_billboardBoundingRect))) {
		
		CGRect currRect = [self measureBillboardBoundingRect];
		
		if (_shouldMaximizeBillboardBoundingRect && !CGRectIsNull(_billboardBoundingRect))
			self.billboardBoundingRect = CGRectUnion(_billboardBoundingRect, currRect);
		else
			self.billboardBoundingRect = currRect;
		
		LogTrace(@"%@ billboard bounding rect updated to %@", [self class], NSStringFromCGRect(_billboardBoundingRect));
	}
	return _billboardBoundingRect;
}

/**
 * If we're drawning in 2D, simply get the 2D node's cocos2d bounding box.
 * If we're drawing in 3D, measure the 2D nodes bounding box using an extension method.
 */
-(CGRect) measureBillboardBoundingRect {
	return _shouldDrawAs2DOverlay
				? _billboard.boundingBoxInPixels
				: _billboard.measureBoundingBoxInPixels;
}

/** If the bounding mesh exists, update it from the new bounding rect. */
-(void) setBillboardBoundingRect: (CGRect) aRect {
	_billboardBoundingRect = aRect;
	[self updateBoundingMesh];
}

-(void) resetBillboardBoundingRect { self.billboardBoundingRect = CGRectNull; }

/** Calculate bounding box from bounding rect of 2D node. */
-(CC3Box) localContentBoundingBox {
	CGRect bRect = self.billboardBoundingRect;
	return CC3BoxMake(CGRectGetMinX(bRect), CGRectGetMinY(bRect), 0.0,
							  CGRectGetMaxX(bRect), CGRectGetMaxY(bRect), 0.0);
}

-(void) setVisible:(BOOL) isVisible {
	[super setVisible: isVisible];
	_billboard.visible = isVisible;
}

/** Only touchable if drawing in 3D. */
-(BOOL) isTouchable { return (!_shouldDrawAs2DOverlay) && [super isTouchable]; }

/** Overridden to ignore lighting, since cocos2d nodes have no normals. */
-(void) setMaterial: (CC3Material*) aMaterial {
	[super setMaterial: aMaterial];
	aMaterial.shouldUseLighting = NO;
}


#pragma mark CCRGBAProtocol support

/** Returns color of billboard if it has a color, otherwise falls back to superclass implementation. */
-(ccColor3B) color {
	return ([_billboard conformsToProtocol: @protocol(CCRGBAProtocol)])
				? [((id<CCRGBAProtocol>)_billboard) color]
				: [super color];
}

/** Also sets color of billboard if it can be set. */
-(void) setColor: (ccColor3B) color {
	if ([_billboard conformsToProtocol: @protocol(CCRGBAProtocol)])
		[((id<CCRGBAProtocol>)_billboard) setColor: color];
	[super setColor: color];
}

/** Returns opacity of billboard if it has an opacity, otherwise falls back to superclass implementation. */
-(GLubyte) opacity {
	return ([_billboard conformsToProtocol: @protocol(CCRGBAProtocol)])
				? [((id<CCRGBAProtocol>)_billboard) opacity]
				: [super opacity];
}

/** Also sets opacity of billboard if it can be set. */
-(void) setOpacity: (GLubyte) opacity {
	if ([_billboard conformsToProtocol: @protocol(CCRGBAProtocol)])
		[((id<CCRGBAProtocol>)_billboard) setOpacity: opacity];
	[super setOpacity: opacity];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.color = ccWHITE;
		self.billboard = nil;
		_billboardBoundingRect = CGRectNull;
		_offsetPosition = CGPointZero;
		_minimumBillboardScale = CGPointZero;
		_maximumBillboardScale = CGPointZero;
		_unityScaleDistance = 0.0;
		_shouldNormalizeScaleToDevice = YES;
		_shouldDrawAs2DOverlay = NO;
		_shouldAlwaysMeasureBillboardBoundingRect = NO;
		_shouldMaximizeBillboardBoundingRect = NO;
		_textureUnitIndex = 0;
		_shouldUpdateUnseenBillboard = YES;
		_billboardIsPaused = NO;
	}
	return self;
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName withBillboard: (CCNode*) a2DNode {
	if ( (self = [self initWithTag: aTag withName: aName]) ) {
		self.billboard = a2DNode;
	}
	return self;
}

-(id) initWithBillboard: (CCNode*) a2DNode {
	if ( (self = [self init]) ) {
		self.billboard = a2DNode;
	}
	return self;
}

+(id) nodeWithBillboard: (CCNode*) a2DNode {
	return [[[self alloc] initWithBillboard: a2DNode] autorelease];
}

-(id) initWithName: (NSString*) aName withBillboard: (CCNode*) a2DNode {
	if ( (self = [self initWithName: aName]) ) {
		self.billboard = a2DNode;
	}
	return self;
}

+(id) nodeWithName: (NSString*) aName withBillboard: (CCNode*) a2DNode {
	return [[[self alloc] initWithName: aName withBillboard: a2DNode] autorelease];
}

// Protected properties for copying
-(BOOL) billboardIsPaused { return _billboardIsPaused; }

-(void) populateFrom: (CC3Billboard*) another {
	[super populateFrom: another];
	
	// Since the billboard can be any kind of CCNode, check if it supports NSCopying.
	// If it does...copy it...otherwise don't attach it. Attaching a single CCNode to multiple
	// CC3Billboards is fraught with peril, because the position and scale of the CCNode will
	// be set by multiple CC3Billboards, and the last one to do so is where the CCNode will be
	// drawn (but over and over, once per CC3Billboard that references it).
	CCNode* bb = another.billboard;
	self.billboard = [bb conformsToProtocol: @protocol(NSCopying)] ? [bb autoreleasedCopy] : nil;
	
	_billboardBoundingRect = another.billboardBoundingRect;
	_offsetPosition = another.offsetPosition;
	_unityScaleDistance = another.unityScaleDistance;
	_minimumBillboardScale = another.minimumBillboardScale;
	_maximumBillboardScale = another.maximumBillboardScale;
	_shouldNormalizeScaleToDevice = another.shouldNormalizeScaleToDevice;
	_shouldDrawAs2DOverlay = another.shouldDrawAs2DOverlay;
	_shouldAlwaysMeasureBillboardBoundingRect = another.shouldAlwaysMeasureBillboardBoundingRect;
	_shouldMaximizeBillboardBoundingRect = another.shouldMaximizeBillboardBoundingRect;
	_shouldUpdateUnseenBillboard = self.shouldUpdateUnseenBillboard;
	_billboardIsPaused = self.billboardIsPaused;
}

/** Ensure that the bounding rectangle mesh has been created. */
-(void) ensureBoundingMesh { if (!_mesh) [self populateAsBoundingRectangle]; }

-(void) populateAsBoundingRectangle {
	CC3Vector* vertices;		// Array of simple vertex location data

	// Start with default initial values
	GLfloat xMin = 0.0f;
	GLfloat xMax = 1.0f;
	GLfloat yMin = 0.0f;
	GLfloat yMax = 1.0f;
	int vCount = 4;
	
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArray];
	locArray.drawingMode = GL_TRIANGLE_STRIP;			// Location array will do the drawing as a strip
	locArray.vertexStride = 0;							// Tightly packed locations only
	locArray.elementOffset = 0;							// Only locations
	locArray.allocatedVertexCapacity = vCount;
	vertices = locArray.vertices;
	
	// Populate vertex locations in the X-Y plane
	vertices[0] = (CC3Vector){xMax, yMax, 0.0};
	vertices[1] = (CC3Vector){xMin, yMax, 0.0};
	vertices[2] = (CC3Vector){xMax, yMin, 0.0};
	vertices[3] = (CC3Vector){xMin, yMin, 0.0};
	
	// Create mesh with vertex location array
	CC3Mesh* aMesh = [CC3Mesh mesh];
	aMesh.vertexLocations = locArray;
	self.mesh = aMesh;

	[self updateBoundingMesh];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, billboard: %@, offset: %@, unity distance: %.2f, min: %@, max: %@, normalizing: %@",
			[super fullDescription], _billboard, NSStringFromCGPoint(_offsetPosition), _unityScaleDistance,
			NSStringFromCGPoint(_minimumBillboardScale), NSStringFromCGPoint(_maximumBillboardScale),
			(_shouldNormalizeScaleToDevice ? @"YES" : @"NO")];
}


#pragma mark Updating

-(void) alignToCamera:(CC3Camera*) camera {
	if (camera && _billboard) {
		if (_shouldDrawAs2DOverlay)
			[self align2DToCamera: camera];
		else
			[self align3DToCamera: camera];
	}
}

/**
 * When drawing in 2D, this method is invoked automatically to dynamically scale the
 * node so that it appears with the correct perspective. This is required because
 * when drawing as a 2D overlay, the node will not otherwise be drawn with the
 * perspective of the 3D billboard's location.
 */
-(void) align2DToCamera:(CC3Camera*) camera {
	// Use the camera to project the 3D location of this node
	// into 2D and then set the billboard to that position
	[camera projectNode: self];
	CGPoint pPos = self.projectedPosition;
	_billboard.position = ccpAdd(pPos, _offsetPosition);
	
	CGPoint newBBScale;
	// If only one non-zero scale is allowed (min == max), ensure that the billboard is set to that scale
	if (!CGPointEqualToPoint(_minimumBillboardScale, CGPointZero)
		&& CGPointEqualToPoint(_maximumBillboardScale, _minimumBillboardScale)) {
		newBBScale = _minimumBillboardScale;
		LogTrace(@"Projecting billboard %@ to %@ with fixed scaling %@", self,
				 NSStringFromCGPoint(pPos), NSStringFromCGPoint(newBBScale));
	} else {
		// Calc how much to scale the billboard by comparing distance from camera to billboard
		// and camera to the defined unity-scale distance. Neither may be smaller than the near
		// clipping plane.
		GLfloat camNear = camera.nearClippingDistance;
		GLfloat camDist = MAX(CC3VectorDistance(self.globalLocation, camera.globalLocation), camNear);
		GLfloat unityDist = MAX(self.unityScaleDistance, camNear);
		GLfloat distScale = unityDist / camDist;
		newBBScale.x = distScale;
		newBBScale.y = distScale;
		
		// Ensure result is within any defined min and max scales
		newBBScale.x = MAX(newBBScale.x, _minimumBillboardScale.x);
		newBBScale.y = MAX(newBBScale.y, _minimumBillboardScale.y);
		
		newBBScale.x = (_maximumBillboardScale.x != 0.0) ? MIN(newBBScale.x, _maximumBillboardScale.x) : newBBScale.x;
		newBBScale.y = (_maximumBillboardScale.y != 0.0) ? MIN(newBBScale.y, _maximumBillboardScale.y) : newBBScale.y;
		
		// Factor in the scale of this CC3Billboard node.
		CC3Vector myScale = self.scale;
		newBBScale.x *= myScale.x;
		newBBScale.y *= myScale.y;
		LogTrace(@"Projecting billboard %@ to %@, scaled to %@ using distance %.2f and unity distance %.2f",
				 self, NSStringFromCGPoint(pPos), NSStringFromCGPoint(newBBScale), camDist, unityDist);
	}
	
	// If consistency across devices is desired, adjust size of 2D billboard so that
	// it appears the same size relative to 3D artifacts across all device resolutions
	if (_shouldNormalizeScaleToDevice) newBBScale = ccpMult(newBBScale, [[self class] deviceScaleFactor]);
	
	// Set the new scale only if it has changed. 
	if (_billboard.scaleX != newBBScale.x) _billboard.scaleX = newBBScale.x;
	if (_billboard.scaleY != newBBScale.y) _billboard.scaleY = newBBScale.y;
}

/**
 * When drawing in 3D, thd 2D node will automatically be drawn with the correct
 * perspective projection, but this method is invoked automatically to enforce
 * the minimum and maximum scales.
 */
-(void) align3DToCamera:(CC3Camera*) camera {

	// Don't waste time if no min or max scale has been set.
	if (CGPointEqualToPoint(_minimumBillboardScale, CGPointZero) &&
		CGPointEqualToPoint(_maximumBillboardScale, CGPointZero)) return;

	GLfloat camNear = camera.nearClippingDistance;
	GLfloat unityDist = MAX(self.unityScaleDistance, camNear);
	GLfloat camDist = MAX(CC3VectorDistance(self.globalLocation, camera.globalLocation), camNear);

	CGPoint newBBScale = ccp(_billboard.scaleX, _billboard.scaleY);

	if (_minimumBillboardScale.x > 0.0) {
		GLfloat minScaleDistX = unityDist / _minimumBillboardScale.x;
		newBBScale.x = (camDist > minScaleDistX) ? (camDist / minScaleDistX) : 1.0f;
	}
	
	if (_minimumBillboardScale.y > 0.0) {
		GLfloat minScaleDistY = unityDist / _minimumBillboardScale.y;
		newBBScale.y = (camDist > minScaleDistY) ? (camDist / minScaleDistY) : 1.0f;
	}
	
	if (_maximumBillboardScale.x > 0.0) {
		GLfloat maxScaleDistX = unityDist / _maximumBillboardScale.x;
		newBBScale.x = (camDist < maxScaleDistX) ? (camDist / maxScaleDistX) : 1.0f;
	}
	
	if (_maximumBillboardScale.y > 0.0) {
		GLfloat maxScaleDistY = unityDist / _maximumBillboardScale.y;
		newBBScale.y = (camDist < maxScaleDistY) ? (camDist / maxScaleDistY) : 1.0f;
	}
	
	// Set the new scale only if it has changed. 
	if (_billboard.scaleX != newBBScale.x) _billboard.scaleX = newBBScale.x;
	if (_billboard.scaleY != newBBScale.y) _billboard.scaleY = newBBScale.y;
}

#define kCC3DeviceScaleFactorBase 480.0f
static GLfloat deviceScaleFactor = 0.0f;

+(GLfloat) deviceScaleFactor {
	if (deviceScaleFactor == 0.0f) {
		CGSize winSz = [[CCDirector sharedDirector] winSize];
		deviceScaleFactor = MAX(winSz.height, winSz.width) / kCC3DeviceScaleFactorBase;
	}
	return deviceScaleFactor;
}


#pragma mark Bounding volumes

-(CC3NodeBoundingArea*) boundingVolume { return (CC3NodeBoundingArea*)super.boundingVolume; }

/** Verify that the bounding volume is of the right type. */
-(void) setBoundingVolume: (CC3NodeBoundingArea*) boundingVolume {
	CC3Assert( [boundingVolume isKindOfClass: [CC3NodeBoundingArea class]],
			  @"%@ requires that the boundingVolume property be of type CC3NodeBoundingArea.", self);
	super.boundingVolume = boundingVolume;
}

-(CC3NodeBoundingVolume*) defaultBoundingVolume {
	return [CC3BillboardBoundingBoxArea boundingVolume];
}

/** Overridden to return YES only if this billboard should draw in 3D. */
-(BOOL) hasLocalContent { return !_shouldDrawAs2DOverlay; }

/** 
 * Overridden to possibly turn scheduled update activity on or off whenever this node
 * transitions from being inside or outside the camera frustum.
 */
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	BOOL doesIntersect = [super doesIntersectFrustum: aFrustum];

	if (_billboard && !_shouldUpdateUnseenBillboard) {
		if (doesIntersect && _billboardIsPaused) {
			[CCDirector.sharedDirector.scheduler resumeTarget: _billboard];
			_billboardIsPaused = NO;
		} else if (!doesIntersect && !_billboardIsPaused) {
			[CCDirector.sharedDirector.scheduler pauseTarget: _billboard];
			_billboardIsPaused = YES;
		}
	}

	return doesIntersect;
}

/** Only intersect frustum when drawing in 3D mode. */
-(BOOL) doesIntersectBoundingVolume: (CC3BoundingVolume*) otherBoundingVolume {
	return (!_shouldDrawAs2DOverlay) && [super doesIntersectBoundingVolume: otherBoundingVolume];
}


#pragma mark Drawing

#if !CC3_GLSL
/** Restore lights to previous state. */
-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLFixedPipeline* gl = (CC3OpenGLFixedPipeline*)visitor.gl;
	
	BOOL isLit = gl->valueCap_GL_LIGHTING;
	
	[super drawWithVisitor: visitor];

	[gl enableLighting: isLit];
}
#endif	// !CC3_GLSL

/**
 * During normal drawing, establish 2D drawing environment.
 * Don't configure anything if painting for node picking.
 */
-(void) applyMaterialWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super applyMaterialWithVisitor: visitor];
	if (visitor.shouldDecorateNode) {
		CC3OpenGL* gl = visitor.gl;
		[gl alignFor2DDrawing];
		gl.depthMask = !_shouldDisableDepthMask;
	}
}

/** The cocos2d CCNode will supply its own shaders, but still need shader during node picking. */
-(void) applyShaderProgramWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (visitor.shouldDecorateNode) return;
	[super applyShaderProgramWithVisitor: visitor];
}

/**
 * During normal drawing, draw the cocos2d node.
 * When painting for node picking, update the bounding box mesh vertices and draw it.
 */
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (visitor.shouldDecorateNode) {
		[_billboard visit];		// Draw the 2D CCNode
	} else {
		// We're drawing a colored box to allow this node to be picked by a touch.
		// This is done by creating and drawing an underlying rectangle mesh that
		// is sized the same as the 2D node.
		[self ensureBoundingMesh];
		[super drawMeshWithVisitor: visitor];
	}
}

/**
 * During normal drawing, restore 3D drawing environment.
 * Don't configure anything if painting for node picking.
 */
-(void) cleanupDrawingParameters: (CC3NodeDrawingVisitor*) visitor {
	if (visitor.shouldDecorateNode) [visitor.gl alignFor3DDrawing];
	[super cleanupDrawingParameters: visitor];
}

/** If the bounding mesh exists, update its vertices to match the bounding box of the 2D node. */
-(void) updateBoundingMesh {
	if (_mesh) {
		CGRect bRect = self.billboardBoundingRect;
		GLfloat xMin = CGRectGetMinX(bRect);
		GLfloat xMax = CGRectGetMaxX(bRect);
		GLfloat yMin = CGRectGetMinY(bRect);
		GLfloat yMax = CGRectGetMaxY(bRect);
		[_mesh setVertexLocation: cc3v(xMax, yMax, 0.0) at: 0];
		[_mesh setVertexLocation: cc3v(xMin, yMax, 0.0) at: 1];
		[_mesh setVertexLocation: cc3v(xMax, yMin, 0.0) at: 2];
		[_mesh setVertexLocation: cc3v(xMin, yMin, 0.0) at: 3];
	}
}

-(BOOL) doesIntersectBounds: (CGRect) bounds {
	if (_boundingVolume) {
		BOOL intersects = [self.boundingVolume doesIntersectBounds: bounds];
		LogTrace(@"%@ bounded by %@ %@ %@", self, _boundingVolume,
					  (intersects ? @"intersects" : @"does not intersect"), NSStringFromCGRect(bounds));

		// Uncomment and change name to verify culling:
//		if (!intersects && ([self.name isEqualToString: @"MyNodeName"])) {
//			LogDebug(@"%@ bounded by %@ does not intersect %@",
//						  self, _boundingVolume, NSStringFromCGRect(bounds));
//		}
		return intersects;
	}
	return YES;
}

-(void) draw2dWithinBounds: (CGRect) bounds {
	if(_shouldDrawAs2DOverlay && self.visible && [self doesIntersectBounds: bounds ])
		[_billboard visit];
}


#pragma mark CC3Node Actions

- (void) resumeAllActions {
	[super resumeAllActions];
	[_billboard resumeSchedulerAndActions];
}

- (void) pauseAllActions {
	[super pauseAllActions];
	[_billboard pauseSchedulerAndActions];
}


#pragma mark Wireframe box and descriptor

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {
	[super setShouldDrawLocalContentWireframeBox: shouldDraw];

	// If we're adding a wireframe and this node has a dynamic boundary,
	// fetch the new wireframe node from the child nodes and set it to
	// measure the local content of this node on each update.
	if (shouldDraw && self.hasDynamicBoundingRect) {
		self.localContentWireframeBoxNode.shouldAlwaysMeasureParentBoundingBox = YES;
	}
}

@end


#pragma mark -
#pragma mark CC3BillboardBoundingBoxArea

@interface CC3NodeBoundingVolume (TemplateMethods)
-(void) transformVolume;
-(void) updateIfNeeded;
-(CC3BoundingVolumeDisplayNode*) displayNode;
-(CC3Plane) buildPlaneFromNormal: (CC3Vector) normal
						 andFace: (CC3Face) face
			  andOrientationAxis: (CC3Vector) orientationAxis;
-(void) appendPlanesTo: (NSMutableString*) desc;
-(void) appendVerticesTo: (NSMutableString*) desc;
@end

@implementation CC3BillboardBoundingBoxArea

-(CC3Plane*) planes {
	[self updateIfNeeded];
	return _planes;
}

-(GLuint) planeCount { return 6; }

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return _vertices;
}

-(GLuint) vertexCount { return 4; }

// Deprecated
-(CC3Vector*) globalBoundingRectVertices { return _vertices; }

/**
 * Return the bounding rectangle of the 2D node held in the CC3Billboard node.
 * If its not valid, return a zero rectangle.
 */
-(CGRect) billboardBoundingRect {
	CGRect bRect = ((CC3Billboard*)_node).billboardBoundingRect;
	LogTrace(@"%@ bounding rect: %@", _node, NSStringFromCGRect(bRect));
	return CGRectIsNull(bRect) ? CGRectZero : bRect;
}

/** Transform the bounding rectangle of the 2D node on the X-Y plane into 3D. */
-(void) transformVolume {
	[super transformVolume];

	// Get the corners of the CCNode bounding box
	CGRect br = [self billboardBoundingRect];
	CGPoint bbMin = ccp(CGRectGetMinX(br), CGRectGetMinY(br));
	CGPoint bbMax = ccp(CGRectGetMaxX(br), CGRectGetMaxY(br));
	
	// Construct all 4 corner vertices of the local bounding box and transform each to global coordinates
	_vertices[0] = [_node.globalTransformMatrix transformLocation: cc3v(bbMin.x, bbMin.y, 0.0)];
	_vertices[1] = [_node.globalTransformMatrix transformLocation: cc3v(bbMin.x, bbMax.y, 0.0)];
	_vertices[2] = [_node.globalTransformMatrix transformLocation: cc3v(bbMax.x, bbMin.y, 0.0)];
	_vertices[3] = [_node.globalTransformMatrix transformLocation: cc3v(bbMax.x, bbMax.y, 0.0)];
	
	LogTrace(@"%@ bounding volume transformed %@ MinMax(%@, %@) to (%@, %@, %@, %@)", _node,
			 NSStringFromCGRect(br),
			 NSStringFromCGPoint(bbMin), NSStringFromCGPoint(bbMax), 
			 NSStringFromCC3Vector(_vertices[0]), NSStringFromCC3Vector(_vertices[1]),
			 NSStringFromCC3Vector(_vertices[2]), NSStringFromCC3Vector(_vertices[3]));
}

/**
 * Constructs the six box face planes from normals and vertices.
 * The plane normals are the transformed face normals of the original box.
 * The vertices are the transformed min-max corners of the rectangle.
 */
-(void) buildPlanes {
	CC3Vector normal;
	CC3Matrix* tMtx = _node.globalTransformMatrix;
	CC3Vector bbMin = _vertices[0];
	CC3Vector bbMax = _vertices[3];
	
	// Front plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitZPositive]);
	_planes[0] = CC3PlaneFromNormalAndLocation(normal, bbMax);
	
	// Back plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitZNegative]);
	_planes[1] = CC3PlaneFromNormalAndLocation(normal, bbMin);
	
	// Right plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitXPositive]);
	_planes[2] = CC3PlaneFromNormalAndLocation(normal, bbMax);
	
	// Left plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitXNegative]);
	_planes[3] = CC3PlaneFromNormalAndLocation(normal, bbMin);
	
	// Top plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitYPositive]);
	_planes[4] = CC3PlaneFromNormalAndLocation(normal, bbMax);
	
	// Bottom plane
	normal = CC3VectorNormalize([tMtx transformDirection: kCC3VectorUnitYNegative]);
	_planes[5] = CC3PlaneFromNormalAndLocation(normal, bbMin);
}

-(CC3Vector) locationOfRayIntesection: (CC3Ray) localRay {
	if (_shouldIgnoreRayIntersection) return kCC3VectorNull;

	// Get the location where the ray intersects the plane of the billboard,
	// which is the Z=0 plane, and ensure that the ray is not parallel to that plane.
	CC3Plane bbPlane = CC3PlaneFromNormalAndLocation(kCC3VectorUnitZPositive, kCC3VectorZero);
	CC3Vector4 pLoc4 = CC3RayIntersectionWithPlane(localRay, bbPlane);
	if (CC3Vector4IsNull(pLoc4)) return kCC3VectorNull;
	
	// Convert the location to a 2D point on the Z=0 plane, and check
	// if that point is inside the rectangular bounds of the billboard.
	BOOL intersects = CGRectContainsPoint([self billboardBoundingRect], ccp(pLoc4.x, pLoc4.y));

	// Return the 3D puncture location, or null if the ray did not intersect the boundary rectangle
	return intersects ? pLoc4.v : kCC3VectorNull;
}

-(NSString*) fullDescription {
	CCNode* bb = ((CC3Billboard*)_node).billboard;
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @" with 2D bounding rect: %@", (bb ? NSStringFromCGRect(bb.boundingBoxInPixels): @"none")];
	[self appendPlanesTo: desc];
	[self appendVerticesTo: desc];
	return desc;
}


#pragma mark Drawing bounding volume

-(NSString*) displayNodeNameSuffix { return @"BV-Billboard"; }

-(ccColor3B) displayNodeColor { return ccc3(0,255,255); }	// Cyan

-(GLubyte) displayNodeOpacity { return 64; }				// Cyan is heavy...reduce to 25% opacity

/** Get the mesh from the rectangular bounding mesh of the billboard node, which is used for node picking. */
-(void) populateDisplayNode {
	CC3Billboard* bbNode = (CC3Billboard*)_node;
	[bbNode ensureBoundingMesh];
	CC3BoundingVolumeDisplayNode* dn = self.displayNode;
	dn.mesh = bbNode.mesh;
	dn.shouldCullBackFaces = NO;	// Make it a two-sided rectangle
}

@end


#pragma mark -
#pragma mark CC3ParticleSystemBillboard

@implementation CC3ParticleSystemBillboard

@synthesize particleSizeAttenuation=_particleSizeAttenuation;

// Deprecated property
-(CC3AttenuationCoefficients) particleSizeAttenuationCoefficients { return self.particleSizeAttenuation; }
-(void) setParticleSizeAttenuationCoefficients: (CC3AttenuationCoefficients) attenuationCoefficients {
	self.particleSizeAttenuation = attenuationCoefficients;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_particleSizeAttenuation = kCC3AttenuationNone;
		_shouldDisableDepthMask = YES;
	}
	return self;
}

-(void) populateFrom: (CC3ParticleSystemBillboard*) another {
	[super populateFrom: another];
	
	_particleSizeAttenuation = another.particleSizeAttenuation;
}


#pragma mark Updating

-(BOOL) shouldTransformUnseenParticles { return self.shouldUpdateUnseenBillboard; }

-(void) setShouldTransformUnseenParticles: (BOOL) shouldTransform {
	self.shouldUpdateUnseenBillboard = shouldTransform;
}

/**
 * If the particle system has exhausted and it is set to auto-remove, remove this
 * node from the scene so that this node and the particle system will be released.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	if (_billboard) {
		CCParticleSystem* ps = (CCParticleSystem*)_billboard;
		if (ps.autoRemoveOnFinish && !ps.active && ps.particleCount == 0) {
			LogTrace(@"2D particle system exhausted. Removing %@", self);
			[visitor requestRemovalOf: self];
		}
	}
}


#pragma mark Drawing

/** Overridden to add setting the point size attenuation parameters. */
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor {
	[super configureDrawingParameters: visitor];
	visitor.gl.pointSizeAttenuation = _particleSizeAttenuation;
}

@end


#pragma mark -
#pragma mark CC3NodeDescriptor

@implementation CC3NodeDescriptor

-(CC3Box) localContentBoundingBox { return kCC3BoxNull; }

-(CC3Box) globalLocalContentBoundingBox { return kCC3BoxNull; }

-(BOOL) shouldIncludeInDeepCopy { return NO; }

-(BOOL) shouldDrawDescriptor { return YES; }

-(void) setShouldDrawDescriptor: (BOOL) shouldDraw {}

-(BOOL) shouldDrawWireframeBox { return YES; }

-(void) setShouldDrawWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldDrawLocalContentWireframeBox { return YES; }

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldContributeToParentBoundingBox { return NO; }

-(BOOL) shouldDrawBoundingVolume { return NO; }

-(void) setShouldDrawBoundingVolume: (BOOL) shouldDraw {}


// Overridden so that not touchable unless specifically set as such
-(BOOL) isTouchable { return self.isTouchEnabled; }

// Overridden so that can still be visible if parent is invisible, unless explicitly turned off.
-(BOOL) visible { return _visible; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_minimumBillboardScale = ccp(1.0, 1.0);
		_maximumBillboardScale = ccp(1.0, 1.0);
		_shouldDrawAs2DOverlay = YES;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3Node extension for billboards

@implementation CC3Node (Billboards)

-(BOOL) isBillboard { return NO; }

@end


#pragma mark -
#pragma mark CCNode extensions

@implementation CCNode (CC3Billboard)

-(CGFloat) billboard3DContentScaleFactor {
#if CC3_CC2_2
	return 1.0f;
#endif	// CC3_CC2_2
#if CC3_CC2_1
	return 1.0f / CC_CONTENT_SCALE_FACTOR();
#endif	// CC3_CC2_1
}

/** Simply return the bounding box of this node. */
-(CGRect) measureBoundingBoxInPixels { return self.boundingBoxInPixels; }

@end


#pragma mark -
#pragma mark CCParticleSystemQuad extensions

@implementation CCParticleSystemQuad (CC3)

// cocos2d 1.0 and below use 2D structures for particle quad vertices
// cocos2d 1.1 and above use 3D structures for particle quad vertices
#if COCOS2D_VERSION < 0x010100
	#define CC_PARTICLE_QUAD_TYPE ccV2F_C4B_T2F_Quad
#else
	#define CC_PARTICLE_QUAD_TYPE ccV3F_C4B_T2F_Quad
#endif

/** Returns a pointer to the internal quads. */
-(CC_PARTICLE_QUAD_TYPE*) cc3Quads {
#if COCOS2D_VERSION < 0x020100
	return quads_;
#else
	return _quads;
#endif
}

/** Returns the particle index. */
-(NSUInteger) cc3ParticleIndex {
#if COCOS2D_VERSION < 0x020100
	return particleIdx;
#else
	return _particleIdx;
#endif
}

/**
 * Find the absolute bottom left and top right from all four vertices in the quad,
 * assuming that the bl and tr of the quad are nominal representations and do not
 * necessarily represent the true corners of the quad. Then create a rectangle from
 * these true bottom left and top right corners.
 */
-(CGRect) makeRectFromQuad: (CC_PARTICLE_QUAD_TYPE) quad {
	CC3_PUSH_NOSHADOW
	CGFloat blx = MIN(quad.bl.vertices.x, MIN(quad.br.vertices.x, MIN(quad.tl.vertices.x, quad.tr.vertices.x)));
	CGFloat bly = MIN(quad.bl.vertices.y, MIN(quad.br.vertices.y, MIN(quad.tl.vertices.y, quad.tr.vertices.y)));
	CGFloat trx = MAX(quad.bl.vertices.x, MAX(quad.br.vertices.x, MAX(quad.tl.vertices.x, quad.tr.vertices.x)));
	CGFloat try = MAX(quad.bl.vertices.y, MAX(quad.br.vertices.y, MAX(quad.tl.vertices.y, quad.tr.vertices.y)));
	CC3_POP_NOSHADOW
	return CGRectMake(blx, bly, trx - blx, try - bly);
}

/** Build the bounding box to encompass the locations of all of the particles. */
-(CGRect) measureBoundingBoxInPixels {
	// Must have at least one quad
	NSUInteger partCnt = self.cc3ParticleIndex;
	CC_PARTICLE_QUAD_TYPE* pQuads = self.cc3Quads;

	if (pQuads && partCnt > 0) {
		// Get the first quad as a starting point
		CGRect boundingRect = [self makeRectFromQuad: self.cc3Quads[0]];
		
		// Iterate through all the remaining quads, taking the union of the
		// current bounding rect and each quad to find the rectangle that
		// bounds all the quads.
		for(NSUInteger i = 1; i < partCnt; i++) {
			CGRect quadRect = [self makeRectFromQuad: pQuads[i]];
			boundingRect = CGRectUnion(boundingRect, quadRect);
		}
		LogTrace(@"%@ bounding rect measured as %@ across %u active of %u possible particles",
				 [self class], NSStringFromCGRect(boundingRect), particleIdx, totalParticles);
		return boundingRect;
	} else {
		// Otherwise simply return a zero rect
		return CGRectZero;
	}
}

@end


#pragma mark -
#pragma mark CCParticleSystemPoint extensions

#if CC3_CC2_1 && CC3_IOS
@implementation CCParticleSystemPoint (CC3)

/** Constructs a rectangle whose origin is at the specified vertex, and with zero size. */
-(CGRect) makeRectFromVertex: (ccVertex2F) aVertex {
	return CGRectMake(aVertex.x, aVertex.y, 0.0, 0.0);
}

/** Build the bounding box to encompass the locations of all of the particles. */
-(CGRect) measureBoundingBoxInPixels {
	// Must have at least one particle
	if (vertices && particleIdx > 0) {
		// Get the first particle as a starting point
		CGRect boundingRect = [self makeRectFromVertex: vertices[0].pos];
		
		// Iterate through all the remaining particles, taking the union of
		// the current bounding rect and each particle location to find the
		// rectangle that bounds all the vertices.
		for(NSUInteger i = 1; i < particleIdx; i++) {
			CGRect vertexRect = [self makeRectFromVertex: vertices[i].pos];
			boundingRect = CGRectUnion(boundingRect, vertexRect);
		}
		LogTrace(@"%@ bounding rect measured as %@ across %u active of %u possible particles",
				 [self class], NSStringFromCGRect(boundingRect), particleIdx, totalParticles);
		return boundingRect;
	} else {
		// Otherwise simply return a zero rect
		return CGRectZero;
	}
}

@end
#endif	// CC3_CC2_1 && CC3_IOS


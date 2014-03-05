/*
 * CC3Camera.m
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
 * See header file CC3Camera.h for full API documentation.
 */

#import "CC3Camera.h"
#import "CC3Scene.h"
#import "CC3ProjectionMatrix.h"
#import "CC3Actions.h"
#import "CC3CC2Extensions.h"
#import "CC3AffineMatrix.h"

/** The maximum allowed effective field of view. */
#define kMaxEffectiveFOV 179.9


#pragma mark CC3Camera implementation

@interface CC3Node (TemplateMethods)
-(void) notifyTransformListeners;
@end

@implementation CC3Camera

@synthesize hasInfiniteDepthOfField=_hasInfiniteDepthOfField, isOpen=_isOpen;
@synthesize shouldClipToViewport=_shouldClipToViewport;

-(void) dealloc {
	[_frustum release];
	[super dealloc];
}

-(BOOL) isCamera { return YES; }

/** Overridden to return NO so that the forwardDirection aligns with the negative-Z-axis. */
-(BOOL) shouldReverseForwardDirection { return NO; }

-(CC3Frustum*) frustum {
	[self buildProjection];
	return _frustum;
}

/** Establish backpointer from frustum. */
-(void) setFrustum: (CC3Frustum*) frustum {
	if (frustum == _frustum) return;
	
	[_frustum release];
	_frustum = [frustum retain];
	_frustum.camera = self;
}

-(CC3Matrix*) projectionMatrix {
	[self buildProjection];
	return _hasInfiniteDepthOfField
				? _frustum.infiniteProjectionMatrix
				: _frustum.finiteProjectionMatrix;
}

-(GLfloat) fieldOfView { return _fieldOfView; }

-(void) setFieldOfView:(GLfloat) anAngle {
	if (anAngle == _fieldOfView) return;
	_fieldOfView = anAngle;
	[self markProjectionDirty];
}

-(GLfloat) effectiveFieldOfView { return MIN(self.fieldOfView / self.uniformScale, kMaxEffectiveFOV); }

-(CC3FieldOfViewOrientation) fieldOfViewOrientation { return _fieldOfViewOrientation; }

-(void) setFieldOfViewOrientation: (CC3FieldOfViewOrientation) fieldOfViewOrientation {
	if (fieldOfViewOrientation == _fieldOfViewOrientation) return;
	_fieldOfViewOrientation = fieldOfViewOrientation;
	[self markProjectionDirty];
}

-(UIInterfaceOrientation) fieldOfViewAspectOrientation { return _fieldOfViewAspectOrientation; }

-(void) setFieldOfViewAspectOrientation: (UIInterfaceOrientation) fieldOfViewAspectOrientation {
	if (fieldOfViewAspectOrientation == _fieldOfViewAspectOrientation) return;
	_fieldOfViewAspectOrientation = fieldOfViewAspectOrientation;
	[self markProjectionDirty];
}

-(GLfloat) nearClippingDistance { return _nearClippingDistance; }

-(void) setNearClippingDistance: (GLfloat) aDistance {
	if (aDistance == _nearClippingDistance) return;
	_nearClippingDistance = aDistance;
	[self markProjectionDirty];
}

-(GLfloat) farClippingDistance { return _farClippingDistance; }

-(void) setFarClippingDistance: (GLfloat) aDistance {
	if (aDistance == _farClippingDistance) return;
	_farClippingDistance = aDistance;
	[self markProjectionDirty];
}

-(CC3Viewport) viewport { return _viewport; }

-(void) setViewport: (CC3Viewport) viewport {
	if (CC3ViewportsAreEqual(viewport, _viewport)) return;
	_viewport = viewport;
	[self markProjectionDirty];
}

// Deprecated
-(GLfloat) nearClippingPlane { return self.nearClippingDistance; }
-(void) setNearClippingPlane: (GLfloat) aDistance { self.nearClippingDistance = aDistance; }
-(GLfloat) farClippingPlane { return self.farClippingDistance; }
-(void) setFarClippingPlane: (GLfloat) aDistance { self.farClippingDistance = aDistance; }

// Overridden to mark the frustum's projection matrix dirty instead of the
// globalTransformMatrix. This is because for a camera, scale acts as a zoom to change
// the effective FOV, which is a projection quality, not a transformation quality.
-(void) setScale: (CC3Vector) aScale {
	_scale = aScale;
	[self markProjectionDirty];
}

-(BOOL) isUsingParallelProjection { return _frustum.isUsingParallelProjection; }

-(void) setIsUsingParallelProjection: (BOOL) shouldUseParallelProjection {
	_frustum.isUsingParallelProjection = shouldUseParallelProjection;
	[self markProjectionDirty];
}

// Keep the compiler happy with the additional declaration
// of this property on this class for documentation purposes
-(CC3Vector) forwardDirection { return super.forwardDirection; }
-(void) setForwardDirection: (CC3Vector) aDirection { super.forwardDirection = aDirection; }

// Deprecated
-(CC3Matrix*) modelviewMatrix { return self.viewMatrix; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.frustum = [CC3Frustum frustum];		// use setter for backpointer
		_isProjectionDirty = YES;
		_fieldOfView = kCC3DefaultFieldOfView;
		_fieldOfViewOrientation = CC3FieldOfViewOrientationDiagonal;
		_fieldOfViewAspectOrientation = UIInterfaceOrientationLandscapeLeft;
		_nearClippingDistance = kCC3DefaultNearClippingDistance;
		_farClippingDistance = kCC3DefaultFarClippingDistance;
		_viewport = CC3ViewportMake(0, 0, 0, 0);
		_shouldClipToViewport = NO;
		_hasInfiniteDepthOfField = NO;
		_isOpen = NO;
	}
	return self;
}

// Protected properties for copying
-(BOOL) isProjectionDirty { return _isProjectionDirty; }
-(CC3Frustum*) rawFrustum { return _frustum; }

-(void) populateFrom: (CC3Camera*) another {
	[super populateFrom: another];
	
	self.frustum = [another.rawFrustum autoreleasedCopy];

	_fieldOfView = another.fieldOfView;
	_fieldOfViewOrientation = another.fieldOfViewOrientation;
	_fieldOfViewAspectOrientation = another.fieldOfViewAspectOrientation;
	_nearClippingDistance = another.nearClippingDistance;
	_farClippingDistance = another.farClippingDistance;
	_isProjectionDirty = another.isProjectionDirty;
	_isOpen = another.isOpen;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, FOV: %.2f, near: %.2f, far: %.2f",
			[super fullDescription], _fieldOfView, _nearClippingDistance, _farClippingDistance];
}


#pragma mark Transformations

/** Overridden to also force the frustum to be rebuilt. */
-(void) markTransformDirty {
	[super markTransformDirty];
	[_frustum markDirty];
}

-(void) markProjectionDirty { _isProjectionDirty = YES; }

/**
 * Scaling the camera is a null operation because it scales everything, including the size
 * of objects, but also the distance from the camera to those objects. The effects cancel
 * out, and visually, it appears that nothing has changed. Therefore, the scale property
 * is not applied to the transform matrix of the camera. Instead it is used to adjust the
 * field of view to create a zooming effect. See the notes for the fieldOfView property.
 *
 * This implementation uses the globalScale property to unwind all scaling from the camera,
 * globally, because any inherited scaling will scale the frustum, and cause undesirable
 * clipping artifacts, particularly at the near clipping plane.
 *
 * For example, if the camera is mounted on another node that is scaled to ten times, the
 * near clipping plane of the camera will be scaled away from the camera by ten times,
 * resulting in unwanted clipping around the fringes of the view. For this reason, an inverse
 * scale of 1/10 is applied to the transform to counteract this effect.
 */
-(void) applyScaling { [_globalTransformMatrix scaleBy: CC3VectorInvert(self.globalScale)]; }

/**
 * Scaling does not apply to cameras. Return the globalScale of the parent node, 
 * or unit scaling if no parent.
 */
-(CC3Vector) globalScale { return _parent ? _parent.globalScale : kCC3VectorUnitCube; }

-(CC3Matrix*) viewMatrix { return self.globalTransformMatrixInverted; }

/**
 * Template method to rebuild the frustum's projection matrix if the
 * projection parameters have been changed since the last rebuild.
 */
-(void) buildProjection  {
	if(!_isProjectionDirty) return;
	
	CC3Assert(_viewport.h > 0 && _viewport.w > 0, @"%@ does not have a valid viewport: %@.",
			  self, NSStringFromCC3Viewport(_viewport));
	
	CGPoint fovAspect = [self orientedFieldOfViewAspect];
	[_frustum populateRight: (_nearClippingDistance * fovAspect.x)
					 andTop: (_nearClippingDistance * fovAspect.y)
					andNear: _nearClippingDistance
					 andFar: _farClippingDistance];
	
	_isProjectionDirty = NO;
	
	[self notifyTransformListeners];	// Notify the transform listeners that the projection has changed
}

/**
 * Returns a point representing the top-right corner of the near clipping plane,
 * expressed as a proportional multiple of the nearClippingDistance.
 *
 * The returned point will have the same aspect ratio as the viewport. The component 
 * values of the point are calculated taking into consideration the effectiveFieldOfView,
 * fieldOfViewOrientation, and fieldOfViewAspectOrientation properties.
 */
-(CGPoint) orientedFieldOfViewAspect {
	GLfloat halfFOV = self.effectiveFieldOfView / 2.0f;
	GLfloat aspect = ((GLfloat) _viewport.w / (GLfloat) _viewport.h);
	GLfloat right, top, diag, orientationCorrection;

	switch (_fieldOfViewOrientation) {
		
		case CC3FieldOfViewOrientationVertical:
			top = tanf(CC3DegToRad(halfFOV));
			right = top * aspect;
			orientationCorrection = 1.0f / aspect;
			break;

		case CC3FieldOfViewOrientationDiagonal:
			diag = tanf(CC3DegToRad(halfFOV));
			top = diag / sqrtf((aspect * aspect) + 1.0f);
			right = top * aspect;
			orientationCorrection = 1.0f;
			break;
		
		case CC3FieldOfViewOrientationHorizontal:
		default:
			right = tanf(CC3DegToRad(halfFOV));
			top = right / aspect;
			orientationCorrection = aspect;
			break;
	}

	// If the aspect doesn't match the intended orientation,
	// bring them in alignment by scaling by the orientation correction.
	if ((UIInterfaceOrientationIsLandscape(_fieldOfViewAspectOrientation) && (aspect < 1.0f)) ||
		(UIInterfaceOrientationIsPortrait(_fieldOfViewAspectOrientation) && (aspect > 1.0f))) {
		right *= orientationCorrection;
		top *= orientationCorrection;
	}

	return ccp(right, top);
}


#pragma mark Drawing

-(void) openWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ opening with %@", self, visitor);
	_isOpen = YES;
	[self openViewportWithVisitor: visitor];
	[self openProjectionWithVisitor: visitor];
	[self openViewWithVisitor: visitor];
}

-(void) closeWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ closing with %@", self, visitor);
	_isOpen = NO;
	[self closeViewWithVisitor: visitor];
	[self closeProjectionWithVisitor: visitor];
}

-(void) openViewportWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ opening viewport %@ with %@", self, NSStringFromCC3Viewport(_viewport), visitor);
	CC3OpenGL* gl = visitor.gl;
	gl.viewport = _viewport;
	[gl enableScissorTest: _shouldClipToViewport];
	if (_shouldClipToViewport) gl.scissor = _viewport;
}

/** Template method that pushes the GL projection matrix stack, and loads the projectionMatrix into it. */
-(void) openProjectionWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ opening projection with %@", self, visitor);
	[visitor.gl pushProjectionMatrixStack];
	[self loadProjectionMatrixWithVisitor: visitor];
}

/** Template method that pops the projectionMatrix from the GL projection matrix stack. */
-(void) closeProjectionWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ closing projection with %@", self, visitor);
	[visitor.gl popProjectionMatrixStack];
}

/** Template method that pushes the GL modelview matrix stack, and loads the viewMatrix into it. */
-(void) openViewWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ opening modelview with %@", self, visitor);
	[visitor.gl pushModelviewMatrixStack];
	[self loadViewMatrixWithVisitor: visitor];
}

/** Template method that pops the viewMatrix from the GL modelview matrix stack. */
-(void) closeViewWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ closing modelview with %@", self, visitor);
	[visitor.gl popModelviewMatrixStack];
}

/** Template method that loads the viewMatrix into the current GL modelview matrix. */
-(void) loadViewMatrixWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ loading modelview matrix into GL: %@", self, self.viewMatrix);
	[visitor populateViewMatrixFrom: self.viewMatrix];
}

/**
 * Template method that loads either the projectionMatrix or the
 * infiniteProjectionMatrix into the current GL projection matrix,
 * depending on the currents state of the hasInfiniteDepthOfField property.
 */
-(void) loadProjectionMatrixWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"%@ loading %@finite projection matrix into GL: %@",
			 self, (_hasInfiniteDepthOfField ? @"in" : @""), self.projectionMatrix);
	[visitor populateProjMatrixFrom: self.projectionMatrix];
}


#pragma mark Viewing nodes

-(void) moveToShowAllOf: (CC3Node*) aNode {
	[self moveToShowAllOf: aNode withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveToShowAllOf: (CC3Node*) aNode withPadding: (GLfloat) padding {
	[self ensureSceneUpdated: YES];
	CC3Vector moveDir = CC3VectorDifference(self.globalLocation, aNode.globalLocation);
	[self moveToShowAllOf: aNode
		   whileLookingAt: kCC3VectorNull
			fromDirection: moveDir
			  withPadding: padding
			   checkScene: NO];
}

-(void) moveToShowAllOf: (CC3Node*) aNode fromDirection: (CC3Vector) aDirection {
	[self moveToShowAllOf: aNode fromDirection: aDirection withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveToShowAllOf: (CC3Node*) aNode
		  fromDirection: (CC3Vector) aDirection
			withPadding: (GLfloat) padding {
	[self moveToShowAllOf: aNode
		   whileLookingAt: kCC3VectorNull
			fromDirection: aDirection
			  withPadding: padding
			   checkScene: YES];
}

-(void) moveToShowAllOf: (CC3Node*) aNode whileLookingAt: (CC3Vector) targetLoc {
	[self moveToShowAllOf: aNode
		   whileLookingAt: targetLoc
			  withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveToShowAllOf: (CC3Node*) aNode
		 whileLookingAt: (CC3Vector) targetLoc
			withPadding: (GLfloat) padding {
	[self ensureSceneUpdated: YES];
	CC3Vector moveDir = CC3VectorDifference(self.globalLocation, aNode.globalLocation);
	[self moveToShowAllOf: aNode
		   whileLookingAt: targetLoc
			fromDirection: moveDir
			  withPadding: padding
			   checkScene: NO];
}

-(void) moveToShowAllOf: (CC3Node*) aNode
		 whileLookingAt: (CC3Vector) targetLoc
		  fromDirection: (CC3Vector) aDirection {
	[self moveToShowAllOf: aNode
		   whileLookingAt: targetLoc
			fromDirection: aDirection
			  withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveToShowAllOf: (CC3Node*) aNode
		 whileLookingAt: (CC3Vector) targetLoc
		  fromDirection: (CC3Vector) aDirection
			withPadding: (GLfloat) padding {
	[self moveToShowAllOf: aNode
		   whileLookingAt: targetLoc
			fromDirection: aDirection
			  withPadding: padding
			   checkScene: YES];
}

-(void) moveToShowAllOf: (CC3Node*) aNode
		 whileLookingAt: (CC3Vector) targetLoc
		  fromDirection: (CC3Vector) aDirection
			withPadding: (GLfloat) padding
			 checkScene: (BOOL) checkScene {
	[self moveWithDuration: 0.0f
			   toShowAllOf: aNode
			whileLookingAt: targetLoc
			 fromDirection: aDirection
			   withPadding: padding
				checkScene: checkScene];
}

-(void) moveWithDuration: (CCTime) t toShowAllOf: (CC3Node*) aNode {
	[self moveWithDuration: t toShowAllOf: aNode withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
			 withPadding: (GLfloat) padding {
	[self ensureSceneUpdated: YES];
	CC3Vector moveDir = CC3VectorDifference(self.globalLocation, aNode.globalLocation);
	[self moveWithDuration: t
			   toShowAllOf: aNode
			whileLookingAt: kCC3VectorNull
			 fromDirection: moveDir
			   withPadding: padding
				checkScene: NO];
}

-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		   fromDirection: (CC3Vector) aDirection {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			 fromDirection: aDirection
			   withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		   fromDirection: (CC3Vector) aDirection
			 withPadding: (GLfloat) padding {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			whileLookingAt: kCC3VectorNull
			 fromDirection: aDirection
			   withPadding: padding
				checkScene: YES ];
}

-(void) moveWithDuration: (CCTime) t
		  whileLookingAt: (CC3Vector) targetLoc
			 toShowAllOf: (CC3Node*) aNode {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			whileLookingAt: targetLoc
			   withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		  whileLookingAt: (CC3Vector) targetLoc
			 withPadding: (GLfloat) padding {
	[self ensureSceneUpdated: YES];
	CC3Vector moveDir = CC3VectorDifference(self.globalLocation, aNode.globalLocation);
	[self moveWithDuration: t
			   toShowAllOf: aNode
			whileLookingAt: targetLoc
			 fromDirection: moveDir
			   withPadding: padding
				checkScene: NO];
}

-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		  whileLookingAt: (CC3Vector) targetLoc
		   fromDirection: (CC3Vector) aDirection {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			whileLookingAt: targetLoc
			 fromDirection: aDirection
			   withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		  whileLookingAt: (CC3Vector) targetLoc
		   fromDirection: (CC3Vector) aDirection
			 withPadding: (GLfloat) padding {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			whileLookingAt: targetLoc
			 fromDirection: aDirection
			   withPadding: padding
				checkScene: YES ];
}

-(void) moveWithDuration: (CCTime) t
			 toShowAllOf: (CC3Node*) aNode
		  whileLookingAt: (CC3Vector) targetLoc
		   fromDirection: (CC3Vector) aDirection
			 withPadding: (GLfloat) padding
			  checkScene: (BOOL) checkScene {
	CC3Vector newLoc = [self calculateLocationToShowAllOf: aNode
										   whileLookingAt: targetLoc
											fromDirection: aDirection
											  withPadding: padding
											   checkScene: checkScene];
	CC3Vector newFwdDir = CC3VectorNegate(aDirection);
	LogInfo(@"%@ \n\tmoving to: %@ \n\tpointing towards: %@ \n\tnear clipping distance: %.3f"
			 @"\n\tfar clipping distance: %.3f \n\tto show all of: %@",
			 self, NSStringFromCC3Vector(newLoc), NSStringFromCC3Vector(newFwdDir),
			 self.nearClippingDistance, self.farClippingDistance, aNode);

	[self ensureAtRootAncestor];
	if (t > 0.0f) {
		[self runAction: [CC3MoveTo actionWithDuration: t moveTo: newLoc]];
		[self runAction: [CC3RotateToLookTowards actionWithDuration: t forwardDirection: newFwdDir]];
	} else {
		self.location = newLoc;
		self.forwardDirection = newFwdDir;
	}
}

/**
 * Padding to add to the near & far clipping plane when it is adjusted as a result of showing
 * all of a node, to ensure that all of the node is within the far end of the frustum.
 */
#define kCC3FrustumFitPadding 0.01

-(CC3Vector) calculateLocationToShowAllOf: (CC3Node*) aNode
							fromDirection: (CC3Vector) aDirection
							  withPadding: (GLfloat) padding {
	return [self calculateLocationToShowAllOf: aNode
							   whileLookingAt: kCC3VectorNull
								fromDirection: aDirection
								  withPadding: padding];
}

-(CC3Vector) calculateLocationToShowAllOf: (CC3Node*) aNode
						   whileLookingAt: (CC3Vector) targetLoc
							fromDirection: (CC3Vector) aDirection
							  withPadding: (GLfloat) padding {
	return [self calculateLocationToShowAllOf: aNode
							   whileLookingAt: targetLoc
								fromDirection: aDirection
								  withPadding: padding
								   checkScene: YES];
}

-(CC3Vector) calculateLocationToShowAllOf: (CC3Node*) aNode
						   whileLookingAt: (CC3Vector) targLoc
							fromDirection: (CC3Vector) aDirection
							  withPadding: (GLfloat) padding
							   checkScene: (BOOL) checkScene {
	
	[self ensureSceneUpdated: checkScene];
	
	// Complementary unit vectors pointing towards camera from node, and vice versa
	CC3Vector camDir = CC3VectorNormalize(aDirection);
	CC3Vector viewDir = CC3VectorNegate(camDir);
	
	// The camera's new forward direction will be viewDir. Use a matrix to detrmine
	// the camera's new up and right directions assuming the same scene up direction.
	CC3Matrix3x3 rotMtx;
	CC3Matrix3x3PopulateToPointTowards(&rotMtx, viewDir, self.referenceUpDirection);
	CC3Vector upDir = CC3Matrix3x3ExtractUpDirection(&rotMtx);
	CC3Vector rtDir = CC3Matrix3x3ExtractRightDirection(&rotMtx);
	
	// Determine the eight vertices, of the node's bounding box, in the global coordinate system
	CC3Box gbb = aNode.globalBoundingBox;

	// If a target location has not been specified, use the center of the node's global bounding box
	if (CC3VectorIsNull(targLoc)) targLoc = CC3BoxCenter(gbb);

	CC3Vector bbMin = gbb.minimum;
	CC3Vector bbMax = gbb.maximum;
	CC3Vector bbVertices[8];
	bbVertices[0] = cc3v(bbMin.x, bbMin.y, bbMin.z);
	bbVertices[1] = cc3v(bbMin.x, bbMin.y, bbMax.z);
	bbVertices[2] = cc3v(bbMin.x, bbMax.y, bbMin.z);
	bbVertices[3] = cc3v(bbMin.x, bbMax.y, bbMax.z);
	bbVertices[4] = cc3v(bbMax.x, bbMin.y, bbMin.z);
	bbVertices[5] = cc3v(bbMax.x, bbMin.y, bbMax.z);
	bbVertices[6] = cc3v(bbMax.x, bbMax.y, bbMin.z);
	bbVertices[7] = cc3v(bbMax.x, bbMax.y, bbMax.z);
	
	// Express the camera's FOV in terms of ratios of the near clip bounds to
	// the near clip distance, so we can determine distances using similar triangles.
	CGSize fovRatios = self.fovRatios;
	
	// Iterate through all eight vertices of the node's bounding box, and calculate
	// the largest distance required to place the camera away from the center of the
	// node in order to fit all eight vertices within the camera's frustum.
	// Simultaneously, calculate the extra distance from the center of the node to
	// the vertex that will be farthest from the camera, so we can ensure that all
	// vertices will fall within the frustum's far end.
	GLfloat maxCtrDist = 0;
	GLfloat maxVtxDeltaDist = 0;
	GLfloat minVtxDeltaDist = 0;
	for (int i = 0; i < 8; i++) {
		
		// Get a vector from the target location to the vertex 
		CC3Vector relVtx = CC3VectorDifference(bbVertices[i], targLoc);
		
		// Project that vector onto each of the camera's new up and right directions,
		// and use similar triangles to determine the distance at which to place the
		// camera so that the vertex will fit in both the up and right directions.
		GLfloat vtxDistUp = ABS(CC3VectorDot(relVtx, upDir) / fovRatios.height);
		GLfloat vtxDistRt = ABS(CC3VectorDot(relVtx, rtDir) / fovRatios.width);
		GLfloat vtxDist = MAX(vtxDistUp, vtxDistRt);
		
		// Calculate how far along the view direction the vertex is from the center
		GLfloat vtxDeltaDist = CC3VectorDot(relVtx, viewDir);
		GLfloat ctrDist = vtxDist - vtxDeltaDist;
		
		// Accumulate the maximum distance from the node's center to the camera
		// required to fit all eight points, and the distance from the node's
		// center to the vertex that will be farthest away from the camera. 
		maxCtrDist = MAX(maxCtrDist, ctrDist);
		maxVtxDeltaDist = MAX(maxVtxDeltaDist, vtxDeltaDist);
		minVtxDeltaDist = MIN(minVtxDeltaDist, vtxDeltaDist);
	}
	
	// Add some padding so we will have a bit of space around the node when it fills the view.
	maxCtrDist *= (1 + padding);
	
	// Determine if we need to move the far end of the camera frustum farther away
	GLfloat farClip = CC3VectorLength(CC3VectorScaleUniform(viewDir, maxCtrDist + maxVtxDeltaDist));
	farClip *= (1 + kCC3FrustumFitPadding);		// Include a little bit of padding
	if (farClip > self.farClippingDistance) self.farClippingDistance = farClip;
	
	// Determine if we need to move the near end of the camera frustum closer
	GLfloat nearClip = CC3VectorLength(CC3VectorScaleUniform(viewDir, maxCtrDist + minVtxDeltaDist));
	nearClip *= (1 - kCC3FrustumFitPadding);		// Include a little bit of padding
	if (nearClip < self.nearClippingDistance) self.nearClippingDistance = nearClip;
	
	LogTrace(@"%@ moving to %@ to show %@ at %@ within %@ with new farClip: %.3f", self,
				  NSStringFromCC3Vector(CC3VectorAdd(targLoc, CC3VectorScaleUniform(camDir, maxCtrDist))),
				  aNode, NSStringFromCC3Vector(targLoc), _frustum, self.farClippingDistance);
	
	// Return the new location of the camera,
	return CC3VectorAdd(targLoc, CC3VectorScaleUniform(camDir, maxCtrDist));
}

/**
 * If the checkScene arg is YES, and the scene is not running, force an update
 * to ensure that all nodes are transformed to their global coordinates.
 */
-(void) ensureSceneUpdated: (BOOL) checkScene {
	if (checkScene) {
		CC3Scene* myScene = self.scene;
		if ( !myScene.isRunning ) [myScene updateScene];
	}
}

/**
 * Returns the camera's FOV in terms of ratios of the near clip bounds
 * (width & height) to the near clip distance.
 */
-(CGSize) fovRatios {
	[self buildProjection];
	switch(CCDirector.sharedDirector.deviceOrientation) {
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			return CGSizeMake(_frustum.top / _frustum.near, _frustum.right / _frustum.near);
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
		default:
			return CGSizeMake(_frustum.right / _frustum.near, _frustum.top / _frustum.near);
	}
}

/**
 * Ensures that this camera is a direct child of its root ancestor, which in almost all
 * cases will be your CC3Scene. This is done by simply adding this camera to the root ancestor.
 * The request will be ignored if this camera is already a direct child of the root ancestor.
 */
-(void) ensureAtRootAncestor { [self.rootAncestor addChild: self]; }


#pragma mark 3D <-> 2D mapping functionality

-(CC3Vector) projectLocation: (CC3Vector) a3DLocation {
	
	// Convert specified location to a 4D homogeneous location vector
	// and transform it using the modelview and projection matrices.
	CC3Vector4 hLoc = CC3Vector4FromLocation(a3DLocation);
	hLoc = [self.viewMatrix transformHomogeneousVector: hLoc];
	hLoc = [self.projectionMatrix transformHomogeneousVector: hLoc];
	
	// Convert projected 4D vector back to 3D.
	CC3Vector projectedLoc = CC3VectorFromHomogenizedCC3Vector4(hLoc);

	// The projected vector is in a projection coordinate space between -1 and +1 on all axes.
	// Normalize the vector so that each component is between 0 and 1 by calculating ( v = (v + 1) / 2 ).
	projectedLoc = CC3VectorAverage(projectedLoc, kCC3VectorUnitCube);
	
	// Map the X & Y components of the projected location (now between 0 and 1) to viewport coordinates.
	CC3Assert(_viewport.h > 0 && _viewport.w > 0, @"%@ does not have a valid viewport: %@.",
			  self, NSStringFromCC3Viewport(_viewport));
	projectedLoc.x = _viewport.x + (_viewport.w * projectedLoc.x);
	projectedLoc.y = _viewport.y + (_viewport.h * projectedLoc.y);
	
	// Using the vector from the camera to the 3D location, determine whether or not the
	// 3D location is in front of the camera by using the dot-product of that vector and
	// the direction the camera is pointing. Set the Z-component of the projected location
	// to be the signed distance from the camera to the 3D location, with a positive sign
	// indicating the location is in front of the camera, and a negative sign indicating
	// the location is behind the camera.
	CC3Vector camToLocVector = CC3VectorDifference(a3DLocation, self.globalLocation);
	GLfloat camToLocDist = CC3VectorLength(camToLocVector);
	GLfloat frontOrBack = SIGN(CC3VectorDot(camToLocVector, self.globalForwardDirection));
	projectedLoc.z = frontOrBack * camToLocDist;
	
	// Map the projected point to the device orientation then return it
	CGPoint ppt = [self cc2PointFromGLPoint: ccp(projectedLoc.x, projectedLoc.y)];
	CC3Vector orientedLoc = cc3v(ppt.x, ppt.y, projectedLoc.z);
	
	LogTrace(@"%@ projecting location %@ to %@ and orienting with device to %@ using viewport %@",
				  self, NSStringFromCC3Vector(a3DLocation), NSStringFromCC3Vector(projectedLoc),
				  NSStringFromCC3Vector(orientedLoc), NSStringFromCC3Viewport(_viewport));
	return orientedLoc;
}

-(CC3Vector) projectLocation: (CC3Vector) aLocal3DLocation onNode: (CC3Node*) aNode {
	return [self projectLocation: [aNode.globalTransformMatrix transformLocation: aLocal3DLocation]];
}

-(CGPoint) glPointFromCC2Point: (CGPoint) cc2Point {
	// Scale from points to pixels, then add the viewport corner.
	return ccpAdd(ccpMult(cc2Point, CC_CONTENT_SCALE_FACTOR()), ccp(_viewport.x, _viewport.y));
}

-(CGPoint) cc2PointFromGLPoint: (CGPoint) glPoint {
	// Subtract the viewport corner, then scale from pixels to points.
	return ccpMult(ccpSub(glPoint, ccp(_viewport.x, _viewport.y)), 1.0f / CC_CONTENT_SCALE_FACTOR());
}

-(CC3Vector) projectNode: (CC3Node*) aNode {
	CC3Assert(aNode, @"Camera cannot project a nil node.");
	CC3Vector pLoc = [self projectLocation: aNode.globalLocation];
	aNode.projectedLocation = pLoc;
	return pLoc;
}

-(CC3Ray) unprojectPoint: (CGPoint) cc2Point {

	// CC_CONTENT_SCALE_FACTOR = 2.0 if Retina display active, or 1.0 otherwise.
	CGPoint glPoint = ccpMult(cc2Point, CC_CONTENT_SCALE_FACTOR());
	
	// Express the glPoint X & Y as proportion of the viewport dimensions.
	CC3Viewport vp = self.viewport;
	GLfloat xp = ((2.0 * glPoint.x) / vp.w) - 1;
	GLfloat yp = ((2.0 * glPoint.y) / vp.h) - 1;

	// Ensure that the camera's frustum is up to date, and then map the proportional point
	// on the viewport to its position on the near clipping rectangle. The Z-coordinate is
	// negative because the camera points down the negative Z axis in its local coordinates.
	[self buildProjection];
	CC3Vector pointLocNear = cc3v(_frustum.right * xp, _frustum.top * yp, -_frustum.near);

	CC3Ray ray;
	if (self.isUsingParallelProjection) {
		// The location on the near clipping plane is relative to the camera's
		// local coordinates. Convert it to global coordinates before returning.
		// The ray direction is straight out from that global location in the 
		// camera's globalForwardDirection.
		ray.startLocation =  [self.globalTransformMatrix transformLocation: pointLocNear];
		ray.direction = self.globalForwardDirection;
	} else {
		// The location on the near clipping plane is relative to the camera's local
		// coordinates. Since the camera's origin is zero in its local coordinates,
		// this point on the near clipping plane forms a directional vector from the
		// camera's origin. Rotate this directional vector with the camera's rotation
		// matrix to convert it to a global direction vector in global coordinates.
		// Thanks to cocos3d forum user Rogs for suggesting the use of the globalRotationMatrix.
		ray.startLocation = self.globalLocation;
		ray.direction = [self.globalRotationMatrix transformDirection: pointLocNear];
	}
	
	// Ensure the direction component is normalized before returning.
	ray.direction = CC3VectorNormalize(ray.direction);
	
	LogTrace(@"%@ unprojecting point %@ to near plane location %@ and to ray starting at %@ and pointing towards %@",
				  [self class], NSStringFromCGPoint(glPoint), NSStringFromCC3Vector(pointLocNear),
				  NSStringFromCC3Vector(ray.startLocation), NSStringFromCC3Vector(ray.direction));

	return ray;
}

-(CC3Vector4) unprojectPoint:(CGPoint) cc2Point ontoPlane: (CC3Plane) plane {
	return CC3RayIntersectionWithPlane([self unprojectPoint: cc2Point], plane);
}

@end


#pragma mark -
#pragma mark CC3Frustum

// Indices of the six boundary planes
#define kCC3TopIdx		0
#define kCC3BotmIdx		1
#define kCC3LeftIdx		2
#define kCC3RgtIdx		3
#define kCC3NearIdx		4
#define kCC3FarIdx		5

// Indices of the eight boundary vertices
#define kCC3NearTopLeftIdx	0
#define kCC3NearTopRgtIdx	1
#define kCC3NearBtmLeftIdx	2
#define kCC3NearBtmRgtIdx	3
#define kCC3FarTopLeftIdx	4
#define kCC3FarTopRgtIdx	5
#define kCC3FarBtmLeftIdx	6
#define kCC3FarBtmRgtIdx	7

@interface CC3BoundingVolume (TemplateMethods)
-(void) updateIfNeeded;
@end

@implementation CC3Frustum

@synthesize top=_top, bottom=_bottom, left=_left, right=_right, near=_near, far=_far;
@synthesize camera=_camera, isUsingParallelProjection=_isUsingParallelProjection;

-(void) dealloc {
	_camera = nil;			// weak reference
	[_finiteProjectionMatrix release];
	[_infiniteProjectionMatrix release];

	[super dealloc];
}

-(void) setTop: (GLfloat) aValue {
	_top = aValue;
	[self markProjectionDirty];
}

-(void) setBottom: (GLfloat) aValue {
	_bottom = aValue;
	[self markProjectionDirty];
}

-(void) setLeft: (GLfloat) aValue {
	_left = aValue;
	[self markProjectionDirty];
}

-(void) setRight: (GLfloat) aValue {
	_right = aValue;
	[self markProjectionDirty];
}

-(void) setNear: (GLfloat) aValue {
	_near = aValue;
	[self markProjectionDirty];
}

-(void) setFar: (GLfloat) aValue {
	_far = aValue;
	[self markProjectionDirty];
}

-(CC3Plane*) planes {
	[self updateIfNeeded];
	return _planes;
}

-(GLuint) planeCount { return 6; }

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return _vertices;
}

-(GLuint) vertexCount { return 8; }

-(CC3Plane) topPlane { return self.planes[kCC3TopIdx]; }
-(CC3Plane) bottomPlane { return self.planes[kCC3BotmIdx]; }
-(CC3Plane) leftPlane { return self.planes[kCC3LeftIdx]; }
-(CC3Plane) rightPlane { return self.planes[kCC3RgtIdx]; }
-(CC3Plane) nearPlane { return self.planes[kCC3NearIdx]; }
-(CC3Plane) farPlane { return self.planes[kCC3FarIdx]; }

-(CC3Vector) nearTopLeft { return self.vertices[kCC3NearTopLeftIdx]; }
-(CC3Vector) nearTopRight { return self.vertices[kCC3NearTopRgtIdx]; }
-(CC3Vector) nearBottomLeft { return self.vertices[kCC3NearBtmLeftIdx]; }
-(CC3Vector) nearBottomRight { return self.vertices[kCC3NearBtmRgtIdx]; }
-(CC3Vector) farTopLeft { return self.vertices[kCC3FarTopLeftIdx]; }
-(CC3Vector) farTopRight { return self.vertices[kCC3FarTopRgtIdx]; }
-(CC3Vector) farBottomLeft { return self.vertices[kCC3FarBtmLeftIdx]; }
-(CC3Vector) farBottomRight { return self.vertices[kCC3FarBtmRgtIdx]; }

// Deprecated
-(CC3Matrix*) viewMatrix { return _camera.viewMatrix; }
-(CC3Matrix*) modelviewMatrix { return self.viewMatrix; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_camera = nil;
		_top = _bottom = _left = _right = _near = _far = 0.0f;
		_finiteProjectionMatrix = [CC3ProjectionMatrix new];	// retained
		_infiniteProjectionMatrix = nil;
		_isUsingParallelProjection = NO;
	}
	return self;
}

+(id) frustum { return [[[self alloc] init] autorelease]; }

-(void) populateFrom: (CC3Frustum*) another {
	[super populateFrom: another];

	_isUsingParallelProjection = another.isUsingParallelProjection;
	[self populateRight: another.right andTop: another.top andNear: another.near andFar: another.far];
}

-(void) populateRight: (GLfloat) right
			   andTop: (GLfloat) top
			  andNear: (GLfloat) near
			   andFar: (GLfloat) far {
	
	_right = right;
	_left = -right;
	_top = top;
	_bottom = -top;
	_near = near;
	_far = far;
	
	[self markProjectionDirty];
	
	LogTrace(@"%@ updated from FOV: %.3f, Aspect: %.3f, Near: %.3f, Far: %.3f",
			 self, fieldOfView, nearClip, nearClip, farClip);
}

-(void) populateFrom: (GLfloat) fieldOfView
		   andAspect: (GLfloat) aspect
		 andNearClip: (GLfloat) nearClip
		  andFarClip: (GLfloat) farClip {

	GLfloat rightClip, topClip;
	GLfloat halfFOV = fieldOfView / 2.0f;

	// Apply the field of view angle to the narrower aspect.
	if (aspect >= 1.0f) {			// Landscape
		topClip = nearClip * tanf(CC3DegToRad(halfFOV));
		rightClip = topClip * aspect;
	} else {						// Portrait
		rightClip = nearClip * tanf(CC3DegToRad(halfFOV));
		topClip = rightClip / aspect;
	}

	[self populateRight: rightClip andTop: topClip andNear: nearClip andFar: farClip];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ of %@", super.description, _camera];
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @" left: %.3f, right: %.3f", _left, _right];
	[desc appendFormat: @", top: %.3f, bottom: %.3f", _top, _bottom];
	[desc appendFormat: @", near: %.3f, far: %.3f", _near, _far];
	[desc appendFormat: @"\n\tleftPlane: %@", NSStringFromCC3Plane(self.leftPlane)];
	[desc appendFormat: @"\n\trightPlane: %@", NSStringFromCC3Plane(self.rightPlane)];
	[desc appendFormat: @"\n\ttopPlane: %@", NSStringFromCC3Plane(self.topPlane)];
	[desc appendFormat: @"\n\tbottomPlane: %@", NSStringFromCC3Plane(self.bottomPlane)];
	[desc appendFormat: @"\n\tnearPlane: %@", NSStringFromCC3Plane(self.nearPlane)];
	[desc appendFormat: @"\n\tfarPlane: %@", NSStringFromCC3Plane(self.farPlane)];
	[desc appendFormat: @"\n\tnearTopLeft: %@", NSStringFromCC3Vector(self.nearTopLeft)];
	[desc appendFormat: @"\n\tnearTopRight: %@", NSStringFromCC3Vector(self.nearTopRight)];
	[desc appendFormat: @"\n\tnearBottomLeft: %@", NSStringFromCC3Vector(self.nearBottomLeft)];
	[desc appendFormat: @"\n\tnearBottomRight: %@", NSStringFromCC3Vector(self.nearBottomRight)];
	[desc appendFormat: @"\n\tfarTopLeft: %@", NSStringFromCC3Vector(self.farTopLeft)];
	[desc appendFormat: @"\n\tfarTopRight: %@", NSStringFromCC3Vector(self.farTopRight)];
	[desc appendFormat: @"\n\tfarBottomLeft: %@", NSStringFromCC3Vector(self.farBottomLeft)];
	[desc appendFormat: @"\n\tfarBottomRight: %@", NSStringFromCC3Vector(self.farBottomRight)];
	return desc;
}


#pragma mark Projection matrices

-(void) markProjectionDirty {
	_finiteProjectionMatrix.isDirty = YES;
	_infiniteProjectionMatrix.isDirty = YES;
	[self markDirty];
}

-(CC3Matrix*) finiteProjectionMatrix {
	if (_finiteProjectionMatrix.isDirty) {
		if (_isUsingParallelProjection)
			[_finiteProjectionMatrix populateOrthoFromFrustumLeft: _left andRight: _right
														   andTop: _top andBottom: _bottom
														  andNear: _near andFar: _far];
		else
			[_finiteProjectionMatrix populateFromFrustumLeft: _left andRight: _right
													  andTop: _top andBottom: _bottom
													 andNear: _near andFar: _far];
		_finiteProjectionMatrix.isDirty = NO;
	}
	return _finiteProjectionMatrix;
}

-(CC3Matrix*) infiniteProjectionMatrix {
	// Since this matrix is not commonly used, it is only calculated when the
	// finiateProjectionMatrix has changed, and then only on demand.
	if (!_infiniteProjectionMatrix) {
		_infiniteProjectionMatrix = [CC3ProjectionMatrix new];		// retained
		_infiniteProjectionMatrix.isDirty = YES;
	}
	if (_infiniteProjectionMatrix.isDirty) {
		if (_isUsingParallelProjection)
			[_infiniteProjectionMatrix populateOrthoFromFrustumLeft: _left andRight: _right
															 andTop: _top andBottom: _bottom
															andNear: _near];
		else
			[_infiniteProjectionMatrix populateFromFrustumLeft: _left andRight: _right
														andTop: _top andBottom: _bottom
													   andNear: _near];
		_infiniteProjectionMatrix.isDirty = NO;
	}
	return _infiniteProjectionMatrix;
}


#pragma mark Updating

/**
 * Builds the six planes that define the frustum volume,
 * using the modelview matrix and the finite projection matrix.
 */
-(void) buildPlanes{
	CC3Matrix4x4 projMtx, viewMtx, m;
	[self.finiteProjectionMatrix populateCC3Matrix4x4: &projMtx];
	[_camera.viewMatrix populateCC3Matrix4x4: &viewMtx];
	CC3Matrix4x4Multiply(&m, &projMtx, &viewMtx);
	
	_planes[kCC3BotmIdx] = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 + m.c1r2), (m.c2r4 + m.c2r2),
																		 (m.c3r4 + m.c3r2), (m.c4r4 + m.c4r2))));
	_planes[kCC3TopIdx]  = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 - m.c1r2), (m.c2r4 - m.c2r2),
																		 (m.c3r4 - m.c3r2), (m.c4r4 - m.c4r2))));
	
	_planes[kCC3LeftIdx] = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 + m.c1r1), (m.c2r4 + m.c2r1),
																		 (m.c3r4 + m.c3r1), (m.c4r4 + m.c4r1))));
	_planes[kCC3RgtIdx]  = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 - m.c1r1), (m.c2r4 - m.c2r1),
																		 (m.c3r4 - m.c3r1), (m.c4r4 - m.c4r1))));
	
	_planes[kCC3NearIdx] = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 + m.c1r3), (m.c2r4 + m.c2r3),
																		 (m.c3r4 + m.c3r3), (m.c4r4 + m.c4r3))));
	_planes[kCC3FarIdx]  = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 - m.c1r3), (m.c2r4 - m.c2r3),
																		 (m.c3r4 - m.c3r3), (m.c4r4 - m.c4r3))));
	[self buildVertices];
	
	LogTrace(@"Built planes for %@ from projection: %@ and view: %@", self, self.finiteProjectionMatrix, _camera.viewMatrix);
}

-(void) buildVertices {
	CC3Plane tp = _planes[kCC3TopIdx];
	CC3Plane bp = _planes[kCC3BotmIdx];
	CC3Plane lp = _planes[kCC3LeftIdx];
	CC3Plane rp = _planes[kCC3RgtIdx];
	CC3Plane np = _planes[kCC3NearIdx];
	CC3Plane fp = _planes[kCC3FarIdx];
	
	_vertices[kCC3NearTopLeftIdx] = CC3TriplePlaneIntersection(np, tp, lp);
	_vertices[kCC3NearTopRgtIdx] = CC3TriplePlaneIntersection(np, tp, rp);
	
	_vertices[kCC3NearBtmLeftIdx] = CC3TriplePlaneIntersection(np, bp, lp);
	_vertices[kCC3NearBtmRgtIdx] = CC3TriplePlaneIntersection(np, bp, rp);
	
	_vertices[kCC3FarTopLeftIdx] = CC3TriplePlaneIntersection(fp, tp, lp);
	_vertices[kCC3FarTopRgtIdx] = CC3TriplePlaneIntersection(fp, tp, rp);
	
	_vertices[kCC3FarBtmLeftIdx] = CC3TriplePlaneIntersection(fp, bp, lp);
	_vertices[kCC3FarBtmRgtIdx] = CC3TriplePlaneIntersection(fp, bp, rp);
}

// Deprecated method
-(void) markPlanesDirty { [self markDirty]; }

// Deprecated method
-(BOOL) doesIntersectPointAt: (CC3Vector) aLocation {
	return [self doesIntersectLocation: aLocation];
}

// Deprecated method
-(BOOL) doesIntersectSphereAt: (CC3Vector) aLocation withRadius: (GLfloat) radius {
	return [self doesIntersectSphere: CC3SphereMake(aLocation, radius)];
}

@end


#pragma mark -
#pragma mark CC3Node extension for cameras

@implementation CC3Node (Camera)

-(BOOL) isCamera { return NO; }

@end


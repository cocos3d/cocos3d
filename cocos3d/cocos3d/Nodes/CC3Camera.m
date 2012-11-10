/*
 * CC3Camera.m
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
 * See header file CC3Camera.h for full API documentation.
 */

#import "CC3Camera.h"
#import "CC3Scene.h"
#import "CC3ProjectionMatrix.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3ActionInterval.h"
#import "CC3IOSExtensions.h"
#import "CGPointExtension.h"
#import "CC3AffineMatrix.h"
#import "ccMacros.h"


#pragma mark CC3Camera implementation

@interface CC3Node (TemplateMethods)
-(void) transformMatrixChanged;
-(void) notifyTransformListeners;
-(void) updateGlobalScale;
@property(nonatomic, readonly) CC3Matrix* globalRotationMatrix;
@end

@interface CC3Camera (TemplateMethods)
@property(nonatomic, readonly) CC3ViewportManager* viewportManager;
-(void) buildModelViewMatrix;
-(void) buildProjectionMatrix;
-(void) openProjection;
-(void) closeProjection;
-(void) openModelView;
-(void) closeModelView;
-(void) loadProjectionMatrix;
-(void) loadModelviewMatrix;
-(void) ensureAtRootAncestor;
-(void) ensureSceneUpdated: (BOOL) checkScene;
-(void) moveToShowAllOf: (CC3Node*) aNode
		 whileLookingAt: (CC3Vector) targetLoc
		  fromDirection: (CC3Vector) aDirection
			withPadding: (GLfloat) padding
			 checkScene: (BOOL) checkScene;
-(void) moveWithDuration: (ccTime) t
			 toShowAllOf: (CC3Node*) aNode
		  whileLookingAt: (CC3Vector) targetLoc
		   fromDirection: (CC3Vector) aDirection
			 withPadding: (GLfloat) padding
			  checkScene: (BOOL) checkScene;
-(CC3Vector) calculateLocationToShowAllOf: (CC3Node*) aNode
						   whileLookingAt: (CC3Vector) targetLoc
							fromDirection: (CC3Vector) aDirection
							  withPadding: (GLfloat) padding
							   checkScene: (BOOL) checkScene;
@property(nonatomic, readonly) CGSize fovRatios;
@property(nonatomic, readonly) BOOL isProjectionDirty;
@end


@implementation CC3Camera

@synthesize fieldOfView, nearClippingDistance, farClippingDistance;
@synthesize frustum, modelviewMatrix;
@synthesize hasInfiniteDepthOfField, isOpen;

-(void) dealloc {
	[modelviewMatrix release];
	[frustum release];
	[super dealloc];
}

-(BOOL) isCamera { return YES; }

/** Overridden to return NO so that the forwardDirection aligns with the negative-Z-axis. */
-(BOOL) shouldReverseForwardDirection { return NO; }

-(CC3Matrix*) projectionMatrix { return frustum.projectionMatrix; }

-(CC3Matrix*) infiniteProjectionMatrix { return frustum.infiniteProjectionMatrix; }

-(void) setFieldOfView:(GLfloat) anAngle {
	fieldOfView = anAngle;
	[self markProjectionDirty];
}

-(void) setNearClippingDistance: (GLfloat) aDistance {
	nearClippingDistance = aDistance;
	[self markProjectionDirty];
}

-(void) setFarClippingDistance: (GLfloat) aDistance {
	farClippingDistance = aDistance;
	[self markProjectionDirty];
}

// Deprecated
-(GLfloat) nearClippingPlane { return self.nearClippingDistance; }
-(void) setNearClippingPlane: (GLfloat) aDistance { self.nearClippingDistance = aDistance; }
-(GLfloat) farClippingPlane { return self.farClippingDistance; }
-(void) setFarClippingPlane: (GLfloat) aDistance { self.farClippingDistance = aDistance; }

// Overridden to mark the frustum's projectionMatrix dirty instead of the
// transformMatrix. This is because for a camera, scale acts as a zoom to change
// the effective FOV, which is a projection quality, not a transformation quality.
-(void) setScale: (CC3Vector) aScale {
	scale = aScale;
	[self markProjectionDirty];
}

-(BOOL) isUsingParallelProjection {
	return frustum.isUsingParallelProjection;
}

-(void) setIsUsingParallelProjection: (BOOL) shouldUseParallelProjection {
	frustum.isUsingParallelProjection = shouldUseParallelProjection;
	[self markProjectionDirty];
}

-(void) setIsDepthOfFieldInfinite: (BOOL) isInfinite {
	hasInfiniteDepthOfField = isInfinite;
	if (isOpen) {
		[self loadProjectionMatrix];
	}
}

// The CC3Scene's viewport manager.
-(CC3ViewportManager*) viewportManager { return self.scene.viewportManager; }

// Keep the compiler happy with the additional declaration
// of this property on this class for documentation purposes
-(CC3Vector) forwardDirection { return super.forwardDirection; }
-(void) setForwardDirection: (CC3Vector) aDirection { super.forwardDirection = aDirection; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		modelviewMatrix = [CC3AffineMatrix new];
		self.frustum = [CC3Frustum frustumOnModelviewMatrix: modelviewMatrix];
		isProjectionDirty = YES;
		fieldOfView = kCC3DefaultFieldOfView;
		nearClippingDistance = kCC3DefaultNearClippingDistance;
		farClippingDistance = kCC3DefaultFarClippingDistance;
		hasInfiniteDepthOfField = NO;
		isOpen = NO;
	}
	return self;
}

// Protected properties for copying
-(BOOL) isProjectionDirty { return isProjectionDirty; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Camera*) another {
	[super populateFrom: another];
	
	self.frustum = [another.frustum autoreleasedCopy];		// retained

	[modelviewMatrix release];
	modelviewMatrix = [another.modelviewMatrix copy];		// retained

	fieldOfView = another.fieldOfView;
	nearClippingDistance = another.nearClippingDistance;
	farClippingDistance = another.farClippingDistance;
	isProjectionDirty = another.isProjectionDirty;
	isOpen = another.isOpen;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, FOV: %.2f, near: %.2f, far: %.2f",
			[super fullDescription], fieldOfView, nearClippingDistance, farClippingDistance];
}


#pragma mark Transformations

-(void) markProjectionDirty { isProjectionDirty = YES; }

/**
 * Scaling the camera is a null operation because it scales everything, including the size
 * of objects, but also the distance from the camera to those objects. The effects cancel
 * out, and visually, it appears that nothing has changed. Therefore, the scale property
 * is not applied to the transform matrix of the camera. Instead it is used to adjust the
 * field of view to create a zooming effect. See the notes for the fieldOfView property.
 *
 * This implementation sets the globalScale to that of the parent node, or to unit scaling
 * if no parent. The globalScale is then used to unwind all scaling from the camera, globally,
 * because any inherited scaling will scale the frustum, and cause undesirable clipping
 * artifacts, particularly at the near clipping plane.
 *
 * For example, if the camera is mounted on another node that is scaled to ten times, the
 * near clipping plane of the camera will be scaled away from the camera by ten times,
 * resulting in unwanted clipping around the fringes of the view. For this reason, an inverse
 * scale of 1/10 is applied to the transform to counteract this effect.
 */
-(void) applyScaling {
	[self updateGlobalScale];	// Make sure globalScale is current first.
	[transformMatrix scaleBy: CC3VectorInvert(globalScale)];
	LogTrace(@"%@ scaled back by global %@ to counter parent scaling %@",
			 self, NSStringFromCC3Vector(globalScale), transformMatrix);
}

/**
 * Scaling does not apply to cameras. Sets the globalScale to that of the parent node,
 * or to unit scaling if no parent.
 */
-(void) updateGlobalScale {
	globalScale = parent ? parent.globalScale : kCC3VectorUnitCube;
}

/** Overridden to also build the modelview matrix. */
-(void) transformMatrixChanged {
	[super transformMatrixChanged];
	[self buildModelViewMatrix];
}

/**
 * Template method to rebuild the modelviewMatrix from the deviceRotationMatrix, which
 * is managed by the CC3Scene's viewportManager, and the inverse of the transformMatrix.
 * Invoked automatically whenever the transformMatrix or device orientation are changed.
 */
-(void) buildModelViewMatrix {
	[modelviewMatrix populateFrom: self.viewportManager.deviceRotationMatrix];
	LogTrace(@"%@ applied device rotation matrix %@", self, modelviewMatrix);

	[modelviewMatrix multiplyBy: self.transformMatrixInverted];
	LogTrace(@"%@ inverted transform applied to modelview matrix %@", self, modelviewMatrix);

	// Let the frustum know that the contents of the modelview matrix have changed. 
	[frustum markDirty];
}

/**
 * Template method to rebuild the frustum's projectionMatrix if the
 * projection parameters have been changed since the last rebuild.
 */
-(void) buildProjection  {
	if(isProjectionDirty) {
		CC3Viewport vp = self.viewportManager.viewport;
		NSAssert(vp.h, @"Camera projection matrix cannot be updated before setting the viewport");

		[frustum populateFrom: fieldOfView
					andAspect: ((GLfloat) vp.w / (GLfloat) vp.h)
				  andNearClip: nearClippingDistance
				   andFarClip: farClippingDistance
					  andZoom: self.uniformScale];

		isProjectionDirty = NO;
		
		// Notify the transform listeners that the projection has changed
		[self notifyTransformListeners];
	}
}

-(void) buildPerspective { [self buildProjection]; }	// Deprecated


#pragma mark Drawing

-(void) open {
	LogTrace(@"Opening %@", self);
	isOpen = YES;
	[self openProjection];
	[self openModelView];
}

-(void) close {
	LogTrace(@"Closing %@", self);
	isOpen = NO;
	[self closeModelView];
	[self closeProjection];
}

/** Template method that pushes the GL projection matrix stack, and loads the projectionMatrix into it. */
-(void) openProjection {
	LogTrace(@"Opening %@ 3D projection", self);
	[[CC3OpenGLES11Engine engine].matrices.projection push];
	[self loadProjectionMatrix];
}

/** Template method that pops the projectionMatrix from the GL projection matrix stack. */
-(void) closeProjection {
	LogTrace(@"Closing %@ 3D projection", self);
	[[CC3OpenGLES11Engine engine].matrices.projection pop];
}

/** Template method that pushes the GL modelview matrix stack, and loads the modelviewMatrix into it. */
-(void) openModelView {
	LogTrace(@"Opening %@ modelview", self);
	[[CC3OpenGLES11Engine engine].matrices.modelview push];
	[self loadModelviewMatrix];
}

/** Template method that pops the modelviewMatrix from the GL modelview matrix stack. */
-(void) closeModelView {
	LogTrace(@"Closing %@ modelview", self);
	[[CC3OpenGLES11Engine engine].matrices.modelview pop];
}

/** Template method that loads the modelviewMatrix into the current GL projection matrix. */
-(void) loadModelviewMatrix {
	LogTrace(@"%@ loading modelview matrix into GL: %@", self, modelviewMatrix);
	CC3Matrix4x4 glMtx;
	[modelviewMatrix populateCC3Matrix4x4: &glMtx];
	[[CC3OpenGLES11Engine engine].matrices.modelview load: glMtx.elements];
}

/**
 * Template method that loads either the projectionMatrix or the
 * infiniteProjectionMatrix into the current GL projection matrix,
 * depending on the currents state of the hasInfiniteDepthOfField property.
 */
-(void) loadProjectionMatrix {
	CC3Matrix* projMtx = hasInfiniteDepthOfField
								? frustum.infiniteProjectionMatrix
								: frustum.projectionMatrix;
	LogTrace(@"%@ loaded %@finite projection matrix into GL: %@",
			 self, (hasInfiniteDepthOfField ? @"in" : @""), projMtx);
	
	CC3Matrix4x4 glMtx;
	[projMtx populateCC3Matrix4x4: &glMtx];
	[[CC3OpenGLES11Engine engine].matrices.projection load: glMtx.elements];
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
	self.location = [self calculateLocationToShowAllOf: aNode
										whileLookingAt: targetLoc
										 fromDirection: aDirection
										   withPadding: padding
											checkScene: checkScene];
	self.forwardDirection = CC3VectorNegate(aDirection);
	[self ensureAtRootAncestor];
	[self updateTransformMatrices];
}

-(void) moveWithDuration: (ccTime) t toShowAllOf: (CC3Node*) aNode {
	[self moveWithDuration: t toShowAllOf: aNode withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (ccTime) t
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

-(void) moveWithDuration: (ccTime) t
			 toShowAllOf: (CC3Node*) aNode
		   fromDirection: (CC3Vector) aDirection {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			 fromDirection: aDirection
			   withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (ccTime) t
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

-(void) moveWithDuration: (ccTime) t
		  whileLookingAt: (CC3Vector) targetLoc
			 toShowAllOf: (CC3Node*) aNode {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			whileLookingAt: targetLoc
			   withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (ccTime) t
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

-(void) moveWithDuration: (ccTime) t
			 toShowAllOf: (CC3Node*) aNode
		  whileLookingAt: (CC3Vector) targetLoc
		   fromDirection: (CC3Vector) aDirection {
	[self moveWithDuration: t
			   toShowAllOf: aNode
			whileLookingAt: targetLoc
			 fromDirection: aDirection
			   withPadding: kCC3DefaultFrustumFitPadding];
}

-(void) moveWithDuration: (ccTime) t
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

-(void) moveWithDuration: (ccTime) t
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
	[self ensureAtRootAncestor];
	[self runAction: [CC3MoveTo actionWithDuration: t moveTo: newLoc]];
	[self runAction: [CC3RotateToLookTowards actionWithDuration: t forwardDirection: newFwdDir]];
}

/**
 * Padding to add to the far clipping plane when it is adjusted as a result of showing
 * all of a node, to ensure that all of the node is within the far end of the frustum.
 */
#define kCC3FrustumFitFarPadding 0.01

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
	
	// Determine the eight vertices, of the node's
	// bounding box, in the global coordinate system
	CC3BoundingBox gbb = aNode.globalBoundingBox;

	// If a target location has not been specified, use the center of the node's global bounding box
	if (CC3VectorIsNull(targLoc)) targLoc = CC3BoundingBoxCenter(gbb);

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
	}
	
	// Add some padding so we will have a bit of space around the node when it fills the view.
	maxCtrDist *= (1 + padding);
	
	// Determine if we need to move the far end of the camera frustum farther away
	GLfloat farClip = CC3VectorLength(CC3VectorScaleUniform(viewDir, maxCtrDist + maxVtxDeltaDist));
	farClip *= (1 + kCC3FrustumFitFarPadding);		// Include a little bit of padding
	if (farClip > self.farClippingDistance) {
		self.farClippingDistance = farClip;
	}
	
	LogTrace(@"%@ moving to %@ to show %@ at %@ within %@ with new farClip: %.3f", self,
				  NSStringFromCC3Vector(CC3VectorAdd(targLoc, CC3VectorScaleUniform(camDir, maxCtrDist))),
				  aNode, NSStringFromCC3Vector(targLoc), frustum, self.farClippingDistance);
	
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
	switch([[CCDirector sharedDirector]deviceOrientation]) {
		case kCCDeviceOrientationLandscapeLeft:
		case kCCDeviceOrientationLandscapeRight:
			return CGSizeMake(frustum.top / frustum.near, frustum.right / frustum.near);
		case kCCDeviceOrientationPortrait:
			case kCCDeviceOrientationPortraitUpsideDown:
		default:
			return CGSizeMake(frustum.right / frustum.near, frustum.top / frustum.near);
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
	CC3Vector4 hLoc = CC3Vector4FromCC3Vector(a3DLocation, 1.0);
	hLoc = [modelviewMatrix transformHomogeneousVector: hLoc];
	hLoc = [frustum.projectionMatrix transformHomogeneousVector: hLoc];
	
	// Convert projected 4D vector back to 3D.
	CC3Vector projectedLoc = CC3VectorFromHomogenizedCC3Vector4(hLoc);

	// The projected vector is in a projection coordinate space between -1 and +1 on all axes.
	// Normalize the vector so that each component is between 0 and 1 by calculating ( v = (v + 1) / 2 ).
	projectedLoc = CC3VectorAverage(projectedLoc, kCC3VectorUnitCube);
	
	// Map the X & Y components of the projected location (now between 0 and 1) to viewport coordinates.
	CC3Viewport vp = self.viewportManager.viewport;
	projectedLoc.x = vp.x + (vp.w * projectedLoc.x);
	projectedLoc.y = vp.y + (vp.h * projectedLoc.y);
	
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
	CGPoint ppt = [self.viewportManager cc2PointFromGLPoint: ccp(projectedLoc.x, projectedLoc.y)];
	CC3Vector orientedLoc = cc3v(ppt.x, ppt.y, projectedLoc.z);
	
	LogTrace(@"%@ projecting location %@ to %@ and orienting with device to %@ using viewport %@",
				  self, NSStringFromCC3Vector(a3DLocation), NSStringFromCC3Vector(projectedLoc),
				  NSStringFromCC3Vector(orientedLoc), NSStringFromCC3Viewport(self.viewportManager.viewport));
	return orientedLoc;
}

-(CC3Vector) projectLocation: (CC3Vector) aLocal3DLocation onNode: (CC3Node*) aNode {
	return [self projectLocation: [aNode.transformMatrix transformLocation: aLocal3DLocation]];
}

-(CC3Vector) projectNode: (CC3Node*) aNode {
	NSAssert(aNode, @"Camera cannot project a nil node.");
	CC3Vector pLoc = [self projectLocation: aNode.globalLocation];
	aNode.projectedLocation = pLoc;
	return pLoc;
}

-(CC3Ray) unprojectPoint: (CGPoint) cc2Point {

	// CC_CONTENT_SCALE_FACTOR = 2.0 if Retina display active, or 1.0 otherwise.
	CGPoint glPoint = ccpMult(cc2Point, CC_CONTENT_SCALE_FACTOR());
	
	// Express the glPoint X & Y as proportion of the layer dimensions, based
	// on an origin in the center of the layer (the center of the camera's view).
	CGSize lb = self.viewportManager.layerBounds.size;
	GLfloat xp = ((2.0 * glPoint.x) / lb.width) - 1;
	GLfloat yp = ((2.0 * glPoint.y) / lb.height) - 1;
	
	// Now that we have the location of the glPoint proportional to the layer dimensions,
	// we need to map the layer dimensions onto the frustum near clipping plane.
	// The layer dimensions change as device orientation changes, but the viewport
	// dimensions remain the same. The field of view is always measured relative to the
	// viewport height, independent of device orientation. We can find the top-right
	// corner of the view on the near clipping plane (top-right is positive X & Y from
	// the center of the camera's view) by multiplying by an orientation aspect in each
	// direction. This orientation aspect depends on the device orientation, which can
	// be expressed in terms of the relationship between the layer width and height and
	// the constant viewport height. The Z-coordinate at the near clipping plane is
	// negative since the camera points down the negative Z axis in its local coordinates.
	CGFloat vph = self.viewportManager.viewport.h;
	GLfloat xNearTopRight = frustum.top * (lb.width / vph);
	GLfloat yNearTopRight = frustum.top * (lb.height / vph);
	GLfloat zNearTopRight = -frustum.near;
	
	LogTrace(@"%@ view point %@ mapped to proportion (%.3f, %.3f) of top-right corner: (%.3f, %.3f) of view bounds %@ and viewport %@",
				  [self class], NSStringFromCGPoint(glPoint), xp, yp, xNearTopRight, yNearTopRight,
				  NSStringFromCGSize(lb), NSStringFromCC3Viewport(self.viewportManager.viewport));
	
	// We now have the location of the the top-right corner of the view, at the near
	// clipping plane, taking into account device orientation. We can now map the glPoint
	// onto the near clipping plane by multiplying by the glPoint's proportional X & Y
	// location, relative to the top-right corner of the view, which was calculated above.
	CC3Vector pointLocNear = cc3v(xNearTopRight * xp,
								  yNearTopRight * yp,
								  zNearTopRight);
	CC3Ray ray;
	if (self.isUsingParallelProjection) {
		// The location on the near clipping plane is relative to the camera's
		// local coordinates. Convert it to global coordinates before returning.
		// The ray direction is straight out from that global location in the 
		// camera's globalForwardDirection.
		ray.startLocation =  [transformMatrix transformLocation: pointLocNear];
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

@interface CC3Frustum (TemplateMethods)
-(void) populateProjectionMatrix;
-(void) buildVertices;
@end

@implementation CC3Frustum

@synthesize top, bottom, left, right, near, far;
@synthesize modelviewMatrix, isUsingParallelProjection;

-(void) dealloc {
	[modelviewMatrix release];
	[projectionMatrix release];
	[infiniteProjectionMatrix release];
	[modelviewProjectionMatrix release];
	[super dealloc];
}

-(void) setTop: (GLfloat) aValue {
	top = aValue;
	[self markDirty];
}

-(void) setBottom: (GLfloat) aValue {
	bottom = aValue;
	[self markDirty];
}

-(void) setLeft: (GLfloat) aValue {
	left = aValue;
	[self markDirty];
}

-(void) setRight: (GLfloat) aValue {
	right = aValue;
	[self markDirty];
}

-(void) setNear: (GLfloat) aValue {
	near = aValue;
	[self markDirty];
}

-(void) setFar: (GLfloat) aValue {
	far = aValue;
	[self markDirty];
}

-(CC3Plane*) planes {
	[self updateIfNeeded];
	return planes;
}

-(GLuint) planeCount { return 6; }

-(CC3Vector*) vertices {
	[self updateIfNeeded];
	return vertices;
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

-(void) setModelviewMatrix: (CC3Matrix*) aMatrix {
	id oldMtx = modelviewMatrix;
	modelviewMatrix = [aMatrix retain];
	[oldMtx release];
	[self markDirty];
}

-(CC3Matrix*) modelviewProjectionMatrix {
	[self updateIfNeeded];
	return modelviewProjectionMatrix;
}

-(CC3Matrix*) projectionMatrix {
	[self updateIfNeeded];
	return projectionMatrix;
}


#pragma mark Allocation and initialization

-(id) init { return [self initOnModelviewMatrix: [CC3AffineMatrix matrix]]; }

-(id) initOnModelviewMatrix: (CC3Matrix*) aMtx {
	if ( (self = [super init]) ) {
		top = bottom = left = right = near = far = 0.0f;
		modelviewMatrix = [aMtx retain];
		projectionMatrix = [CC3ProjectionMatrix new];
		modelviewProjectionMatrix = [CC3ProjectionMatrix new];;
		infiniteProjectionMatrix = nil;
		isUsingParallelProjection = NO;
		isInfiniteProjectionDirty = YES;
	}
	return self;
}

+(id) frustumOnModelviewMatrix: (CC3Matrix*) aMtx {
	return [[[self alloc] initOnModelviewMatrix: aMtx] autorelease];
}

// Protected properties for copying
-(BOOL) isInfiniteProjectionDirty { return isInfiniteProjectionDirty; }

-(void) populateFrom: (CC3Frustum*) another {
	[super populateFrom: another];
	
	top = another.top;
	bottom = another.bottom;
	left = another.left;
	right = another.right;
	near = another.near;
	far = another.far;
	
	[projectionMatrix release];
	projectionMatrix = [another.projectionMatrix copy];		// retained
	
	[modelviewProjectionMatrix release];
	modelviewProjectionMatrix = [another.modelviewProjectionMatrix copy];	// retained
	
	[infiniteProjectionMatrix release];
	infiniteProjectionMatrix = [another.infiniteProjectionMatrix copy];		// retained
	isInfiniteProjectionDirty = another.isInfiniteProjectionDirty;
	
	isUsingParallelProjection = another.isUsingParallelProjection;
}

/** The maximum allowed effective field of view. */
#define kMaxEffectiveFOV 179.9

-(void) populateFrom: (GLfloat) fieldOfView
		   andAspect: (GLfloat) aspect
		 andNearClip: (GLfloat) nearClip
		  andFarClip: (GLfloat) farClip
			 andZoom: (GLfloat) zoomFactor {
	
	// The zoomFactor arg modifies the effective field of view.
	// The effective FOV is clamped to keep it below 180 degrees, because
	// the scene disappears into the distance as the tangent goes to infinity.
	GLfloat halfFOV = MIN(fieldOfView / zoomFactor, kMaxEffectiveFOV) / 2.0f;

	near = nearClip;
	far = farClip;

	// Apply the field of view angle to the narrower aspect.
	if (aspect >= 1.0f) {			// Landscape
		top = near * tanf(DegreesToRadians(halfFOV));
		right = top * aspect;
	} else {						// Portrait
		right = near * tanf(DegreesToRadians(halfFOV));
		top = right / aspect;
	}
	
	bottom = -top;
	left = -right;
	
	[self markDirty];
	
	LogTrace(@"%@ updated from FOV: %.3f, Aspect: %.3f, Near: %.3f, Far: %.3f, Zoom: %.3f",
			 self, fieldOfView, nearClip, nearClip, farClip, zoomFactor);
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @"left: %.3f, right: %.3f, ", left, right];
	[desc appendFormat: @"top: %.3f, bottom: %.3f, ", top, bottom];
	[desc appendFormat: @"near: %.3f, far: %.3f", near, far];
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

/**
 * Template method that populates the projection matrix from the frustum.
 * Uses either orthographic or perspective projection, depending on the value
 * of the isUsingParallelProjection property.
 */
-(void) populateProjectionMatrix {
	if (isUsingParallelProjection) {
		[projectionMatrix populateOrthoFromFrustumLeft: left andRight: right andTop: top
											 andBottom: bottom andNear: near andFar: far];
	} else {
		[projectionMatrix populateFromFrustumLeft: left andRight: right andTop: top
										andBottom: bottom andNear: near andFar: far];
	}
	isInfiniteProjectionDirty = YES;
}

/**
 * Returns the projection matrix modified to have an infinite depth of view,
 * by assuming a farClippingDistance set at infinity.
 *
 * Since this matrix is not commonly used, it is only calculated when the
 * projectionMatrix has changed, and then only on demand.
 *
 * When the projectionMatrix is recalculated, the infiniteProjectionMatrix
 * is marked as dirty. It is then recalculated the next time this property
 * is accessed, and is cached until it is marked dirty again.
 */
-(CC3Matrix*) infiniteProjectionMatrix {
	[self updateIfNeeded];		// Make sure properties are up to date
	if (!infiniteProjectionMatrix) {
		infiniteProjectionMatrix = [CC3ProjectionMatrix new];
		isInfiniteProjectionDirty = YES;
	}
	if (isInfiniteProjectionDirty) {
		if (isUsingParallelProjection) {
			[infiniteProjectionMatrix populateOrthoFromFrustumLeft: left andRight: right
															andTop: top andBottom: bottom
														   andNear: near];
		} else {
			[infiniteProjectionMatrix populateFromFrustumLeft: left andRight: right
													   andTop: top andBottom: bottom
													  andNear: near];
		}
		isInfiniteProjectionDirty = NO;
	}
	return infiniteProjectionMatrix;
}


#pragma mark Updating

/** Make sure projection matrix is current, then create the modelview projection matrix. */
-(void) buildVolume {
	[self populateProjectionMatrix];
	[modelviewProjectionMatrix populateFrom: projectionMatrix];
	[modelviewProjectionMatrix multiplyBy: modelviewMatrix];
}

/**
 * Builds the six planes that define the frustum volume,
 * using the modelview matrix and the finite projection matrix.
 */
-(void) buildPlanes{
	CC3Matrix4x4 m;
	[modelviewProjectionMatrix populateCC3Matrix4x4: &m];
	
	planes[kCC3BotmIdx] = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 + m.c1r2), (m.c2r4 + m.c2r2),
																		(m.c3r4 + m.c3r2), (m.c4r4 + m.c4r2))));
	planes[kCC3TopIdx]  = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 - m.c1r2), (m.c2r4 - m.c2r2),
																		(m.c3r4 - m.c3r2), (m.c4r4 - m.c4r2))));
	
	planes[kCC3LeftIdx] = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 + m.c1r1), (m.c2r4 + m.c2r1),
																		(m.c3r4 + m.c3r1), (m.c4r4 + m.c4r1))));
	planes[kCC3RgtIdx]  = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 - m.c1r1), (m.c2r4 - m.c2r1),
																		(m.c3r4 - m.c3r1), (m.c4r4 - m.c4r1))));
	
	planes[kCC3NearIdx] = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 + m.c1r3), (m.c2r4 + m.c2r3),
																		(m.c3r4 + m.c3r3), (m.c4r4 + m.c4r3))));
	planes[kCC3FarIdx]  = CC3PlaneNegate(CC3PlaneNormalize(CC3PlaneMake((m.c1r4 - m.c1r3), (m.c2r4 - m.c2r3),
																		(m.c3r4 - m.c3r3), (m.c4r4 - m.c4r3))));
	
	[self buildVertices];
	
	LogTrace(@"Built planes for %@ from projection: %@ and modelview: %@ combined: %@",
				  self.fullDescription, projectionMatrix, modelviewMatrix, modelviewProjectionMatrix);
}

-(void) buildVertices {
	CC3Plane tp = planes[kCC3TopIdx];
	CC3Plane bp = planes[kCC3BotmIdx];
	CC3Plane lp = planes[kCC3LeftIdx];
	CC3Plane rp = planes[kCC3RgtIdx];
	CC3Plane np = planes[kCC3NearIdx];
	CC3Plane fp = planes[kCC3FarIdx];
	
	vertices[kCC3NearTopLeftIdx] = CC3TriplePlaneIntersection(np, tp, lp);
	vertices[kCC3NearTopRgtIdx] = CC3TriplePlaneIntersection(np, tp, rp);
	
	vertices[kCC3NearBtmLeftIdx] = CC3TriplePlaneIntersection(np, bp, lp);
	vertices[kCC3NearBtmRgtIdx] = CC3TriplePlaneIntersection(np, bp, rp);
	
	vertices[kCC3FarTopLeftIdx] = CC3TriplePlaneIntersection(fp, tp, lp);
	vertices[kCC3FarTopRgtIdx] = CC3TriplePlaneIntersection(fp, tp, rp);
	
	vertices[kCC3FarBtmLeftIdx] = CC3TriplePlaneIntersection(fp, bp, lp);
	vertices[kCC3FarBtmRgtIdx] = CC3TriplePlaneIntersection(fp, bp, rp);
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


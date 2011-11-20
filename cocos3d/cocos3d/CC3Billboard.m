/*
 * CC3Billboard.m
 *
 * cocos3d 0.6.4
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
 * See header file CC3Billboard.h for full API documentation.
 */

#import "CC3Billboard.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3VertexArrayMesh.h"
#import "CCParticleSystemQuad.h"
#import "CCLabelTTF.h"
#import "CGPointExtension.h"
#import "ccMacros.h"


@interface CC3Node (TemplateMethods)
-(void) populateFrom: (CC3Node*) another;
-(void) resumeActions;
-(void) pauseActions;
@end

@interface CC3MeshNode (TemplateMethods)
-(void) configureDrawingParameters: (CC3NodeDrawingVisitor*) visitor;
-(void) configureMaterialWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor;
@end

@interface CC3Billboard (TemplateMethods)
-(CGRect) measureBillboardBoundingRect;
-(void) align2DToCamera:(CC3Camera*) camera;
-(void) align3DToCamera:(CC3Camera*) camera;
-(void) populateAsBoundingRectangle;
-(void) updatePickingBoundingRect;
-(void) normalizeBillboardScaleToDevice;
@property(nonatomic, readonly) BOOL hasDynamicBoundingRect;
@end

@implementation CC3Billboard

@synthesize billboard, offsetPosition, unityScaleDistance;
@synthesize minimumBillboardScale, maximumBillboardScale;
@synthesize shouldNormalizeScaleToDevice, shouldDrawAs2DOverlay, textureUnitIndex;
@synthesize shouldAlwaysMeasureBillboardBoundingRect, shouldMaximizeBillboardBoundingRect;

-(void) dealloc {
	[billboard release];
	[super dealloc];
}

-(void) setBillboard:(CCNode*) aCCNode {
	[billboard onExit];					// Stop scheduled activities on old billboard
	[billboard autorelease];			// Autorelease (not release) in case its same instance
	billboard = [aCCNode retain];
	billboard.visible = self.visible;
	[self normalizeBillboardScaleToDevice];
	// Retrieve the blend function from the 2D node and align this 3D node's material with it.
	if ([billboard conformsToProtocol: @protocol(CCBlendProtocol)]) {
		material.blendFunc = ((id<CCBlendProtocol>)billboard).blendFunc;
	}
	[self normalizeBillboardScaleToDevice];
	if (isRunning) [billboard onEnter];	// If running, start scheduled activities on new billboard
} 

-(void) setShouldDrawAs2DOverlay: (BOOL) drawAsOverlay {
	shouldDrawAs2DOverlay = drawAsOverlay;
	[self normalizeBillboardScaleToDevice];
}

-(void) setShouldNormalizeScaleToDevice: (BOOL) normalizeToDevice {
	shouldNormalizeScaleToDevice = normalizeToDevice;
	[self normalizeBillboardScaleToDevice];
}

/**
 * If in 3D mode and should be normalized, force scale of billboard
 * to a factor determined by the type of billboard.
 */
-(void) normalizeBillboardScaleToDevice {
	if (!shouldDrawAs2DOverlay && shouldNormalizeScaleToDevice) {
		billboard.scale = billboard.billboard3DContentScaleFactor;
	}
}

// Overridden to enable or disable the CCNode
// Thanks to cocos3d user Sev_Inf for submitting this patch
-(void) setIsRunning: (BOOL) shouldRun {
    [super setIsRunning:shouldRun];
	
    if (self.isRunning && !billboard.isRunning) {
        [billboard onEnter];
    } else if (!self.isRunning && billboard.isRunning) {
        [billboard onExit];
    }
}

/** Returns whether the bounding rectangle needs to be measured on each update pass. */
-(BOOL) hasDynamicBoundingRect {
	return (shouldDrawAs2DOverlay
			|| shouldAlwaysMeasureBillboardBoundingRect
			|| shouldMaximizeBillboardBoundingRect);
}

-(CGRect) billboardBoundingRect {
	if (billboard && (self.hasDynamicBoundingRect || CGRectIsNull(billboardBoundingRect))) {
		
		CGRect currRect = [self measureBillboardBoundingRect];
		
		if (shouldMaximizeBillboardBoundingRect && !CGRectIsNull(billboardBoundingRect)) {
			billboardBoundingRect = CGRectUnion(billboardBoundingRect, currRect);
		} else {
			billboardBoundingRect = currRect;
		}
		LogTrace(@"%@ billboard bounding rect updated to %@", [self class], NSStringFromCGRect(billboardBoundingRect));
	}
	return billboardBoundingRect;
}

/**
 * If we're drawning in 2D, simply get the 2D node's cocos2d bounding box.
 * If we're drawing in 3D, measure the 2D nodes bounding box using an extension method.
 */
-(CGRect) measureBillboardBoundingRect {
	return shouldDrawAs2DOverlay
			? billboard.boundingBoxInPixels 
			: billboard.measureBoundingBoxInPixels;
}

-(void) setBillboardBoundingRect: (CGRect) aRect {
	billboardBoundingRect = aRect;
}

-(void) resetBillboardBoundingRect {
	billboardBoundingRect = CGRectNull;
}

/** Calculate bounding box from bounding rect of 2D node. */
-(CC3BoundingBox) localContentBoundingBox {
	CGRect bRect = self.billboardBoundingRect;
	return CC3BoundingBoxMake(CGRectGetMinX(bRect), CGRectGetMinY(bRect), 0.0,
							  CGRectGetMaxX(bRect), CGRectGetMaxY(bRect), 0.0);
}

-(void) setVisible:(BOOL) isVisible {
	[super setVisible: isVisible];
	billboard.visible = isVisible;
}

/** Only touchable if drawing in 3D. */
-(BOOL) isTouchable {
	return (!shouldDrawAs2DOverlay) && [super isTouchable];
}


#pragma mark CCRGBAProtocol support

/** Returns color of billboard if it has a color, otherwise falls back to superclass implementation. */
-(ccColor3B) color {
	return ([billboard conformsToProtocol: @protocol(CCRGBAProtocol)])
				? [((id<CCRGBAProtocol>)billboard) color]
				: [super color];
}

/** Also sets color of billboard if it can be set. */
-(void) setColor: (ccColor3B) color {
	if ([billboard conformsToProtocol: @protocol(CCRGBAProtocol)]) {
		[((id<CCRGBAProtocol>)billboard) setColor: color];
	}
	[super setColor: color];
}

/** Returns opacity of billboard if it has an opacity, otherwise falls back to superclass implementation. */
-(GLubyte) opacity {
	return ([billboard conformsToProtocol: @protocol(CCRGBAProtocol)])
				? [((id<CCRGBAProtocol>)billboard) opacity]
				: [super opacity];
}

/** Also sets opacity of billboard if it can be set. */
-(void) setOpacity: (GLubyte) opacity {
	if ([billboard conformsToProtocol: @protocol(CCRGBAProtocol)]) {
		[((id<CCRGBAProtocol>)billboard) setOpacity: opacity];
	}
	[super setOpacity: opacity];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.boundingVolume = [CC3BillboardBoundingBoxArea boundingVolume];
		self.material = [CC3Material materialWithName: [NSString stringWithFormat: @"%@-Mat", aName]];
		material.color = ccWHITE;
		self.billboard = nil;
		billboardBoundingRect = CGRectNull;
		offsetPosition = CGPointZero;
		minimumBillboardScale = CGPointZero;
		maximumBillboardScale = CGPointZero;
		unityScaleDistance = 0.0;
		shouldNormalizeScaleToDevice = YES;
		shouldDrawAs2DOverlay = NO;
		shouldAlwaysMeasureBillboardBoundingRect = NO;
		shouldMaximizeBillboardBoundingRect = NO;
		textureUnitIndex = 0;
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

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Billboard*) another {
	[super populateFrom: another];
	
	// Since the billboard can be any kind of CCNode, check if it supports NSCopying.
	// If it does...copy it...otherwise don't attach it.
	// Attaching a single CCNode to multiple CC3Billboards is fraught with peril,
	// because the position and scale of the CCNode will be set by multiple CC3Billboards,
	// and the last one to do so is where the CCNode will be drawn (but over and over,
	// once per CC3Billboard that references it).
	[billboard release];
	CCNode* bb = another.billboard;
	if ([bb conformsToProtocol: @protocol(NSCopying)]) {
		billboard = [bb copy];				// retained
	} else {
		billboard = nil;
	}

	billboardBoundingRect = another.billboardBoundingRect;
	offsetPosition = another.offsetPosition;
	unityScaleDistance = another.unityScaleDistance;
	minimumBillboardScale = another.minimumBillboardScale;
	maximumBillboardScale = another.maximumBillboardScale;
	shouldNormalizeScaleToDevice = another.shouldNormalizeScaleToDevice;
	shouldDrawAs2DOverlay = another.shouldDrawAs2DOverlay;
	shouldAlwaysMeasureBillboardBoundingRect = another.shouldAlwaysMeasureBillboardBoundingRect;
	shouldMaximizeBillboardBoundingRect = another.shouldMaximizeBillboardBoundingRect;
}

/**
 * If this node is drawing in 3D and is touchable, this method can be used to create
 * a simple rectangle mesh to use when painting the node during node picking.
 *
 * We need to do this because the cocos2d is incompatible with the node picking
 * painting algorithm.
 *
 * This method will be invoked automatically when needed for node picking.
 * The rectangle mesh starts out with unit size, but the vertices are manipulated
 * during picking to size the rectangle to the bounding rectangle of the 2D node.
 */
-(void) populateAsBoundingRectangle {
	NSString* itemName;
	CC3Vector* vertices;		// Array of simple vertex location data

	// Start with default initial values
	GLfloat xMin = 0.0f;
	GLfloat xMax = 1.0f;
	GLfloat yMin = 0.0f;
	GLfloat yMax = 1.0f;
	int vCount = 4;
	
	// Interleave the vertex locations, normals and tex coords
	// Create vertex location array, allocating enough space for the stride of the full structure
	itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
	CC3VertexLocations* locArray = [CC3VertexLocations vertexArrayWithName: itemName];
	locArray.drawingMode = GL_TRIANGLE_STRIP;			// Location array will do the drawing as a strip
	locArray.elementStride = sizeof(CC3TexturedVertex);	// Set stride before allocating elements.
	locArray.elementOffset = 0;							// Only locations
	vertices = [locArray allocateElements: vCount];
	
	// Populate vertex locations in the X-Y plane
	vertices[0] = (CC3Vector){xMax, yMax, 0.0};
	vertices[1] = (CC3Vector){xMin, yMax, 0.0};
	vertices[2] = (CC3Vector){xMax, yMin, 0.0};
	vertices[3] = (CC3Vector){xMin, yMin, 0.0};
	
	// Create mesh model with vertex location array
	itemName = [NSString stringWithFormat: @"%@-Mesh", self.name];
	CC3VertexArrayMesh* aMesh = [CC3VertexArrayMesh meshWithName: itemName];
	aMesh.vertexLocations = locArray;
	self.mesh = aMesh;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, billboard: %@, offset: %@, unity distance: %.2f, min: %@, max: %@, normalizing: %@",
			[super fullDescription], billboard, NSStringFromCGPoint(offsetPosition), unityScaleDistance,
			NSStringFromCGPoint(minimumBillboardScale), NSStringFromCGPoint(maximumBillboardScale),
			(shouldNormalizeScaleToDevice ? @"YES" : @"NO")];
}


#pragma mark Updating

-(void) alignToCamera:(CC3Camera*) camera {
	if (camera && billboard) {
		if (shouldDrawAs2DOverlay) {
			[self align2DToCamera: camera];
		} else {
			[self align3DToCamera: camera];
		}
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
	billboard.position = ccpAdd(pPos, offsetPosition);
	
	CGPoint newBBScale;
	// If only one non-zero scale is allowed (min == max), ensure that the billboard is set to that scale
	if (!CGPointEqualToPoint(minimumBillboardScale, CGPointZero)
		&& CGPointEqualToPoint(maximumBillboardScale, minimumBillboardScale)) {
		newBBScale = minimumBillboardScale;
		LogTrace(@"Projecting billboard %@ to %@ with fixed scaling %@", self,
				 NSStringFromCGPoint(pPos), NSStringFromCGPoint(newBBScale));
	} else {
		// Calc how much to scale the billboard by comparing distance from camera to billboard
		// and camera to the defined unity-scale distance. Neither may be smaller than the near
		// clipping plane.
		GLfloat camNear = camera.nearClippingPlane;
		GLfloat camDist = MAX(CC3VectorDistance(self.globalLocation, camera.globalLocation), camNear);
		GLfloat unityDist = MAX(self.unityScaleDistance, camNear);
		GLfloat distScale = unityDist / camDist;
		newBBScale.x = distScale;
		newBBScale.y = distScale;
		
		// Ensure result is within any defined min and max scales
		newBBScale.x = MAX(newBBScale.x, minimumBillboardScale.x);
		newBBScale.y = MAX(newBBScale.y, minimumBillboardScale.y);
		
		newBBScale.x = (maximumBillboardScale.x != 0.0) ? MIN(newBBScale.x, maximumBillboardScale.x) : newBBScale.x;
		newBBScale.y = (maximumBillboardScale.y != 0.0) ? MIN(newBBScale.y, maximumBillboardScale.y) : newBBScale.y;
		
		// Factor in the scale of this CC3Billboard node.
		CC3Vector myScale = self.scale;
		newBBScale.x *= myScale.x;
		newBBScale.y *= myScale.y;
		LogTrace(@"Projecting billboard %@ to %@, scaled to %@ using distance %.2f and unity distance %.2f",
				 self, NSStringFromCGPoint(pPos), NSStringFromCGPoint(newBBScale), camDist, unityDist);
	}
	
	// If consistency across devices is desired, adjust size of 2D billboard so that
	// it appears the same size relative to 3D artifacts across all device resolutions
	if (shouldNormalizeScaleToDevice) {
		newBBScale = ccpMult(newBBScale, [[self class] deviceScaleFactor]);
	}
	
	// Set the new scale only if it has changed. 
	if (billboard.scaleX != newBBScale.x) billboard.scaleX = newBBScale.x;
	if (billboard.scaleY != newBBScale.y) billboard.scaleY = newBBScale.y;
}

/**
 * When drawing in 3D, thd 2D node will automatically be drawn with the correct
 * perspective projection, but this method is invoked automatically to enforce
 * the minimum and maximum scales.
 */
-(void) align3DToCamera:(CC3Camera*) camera {
	GLfloat camNear = camera.nearClippingPlane;
	GLfloat camDist = MAX(CC3VectorDistance(self.globalLocation, camera.globalLocation), camNear);
	GLfloat unityDist = MAX(self.unityScaleDistance, camNear);

	CGPoint newBBScale = ccp(billboard.scaleX, billboard.scaleY);

	if (minimumBillboardScale.x > 0.0) {
		GLfloat minScaleDistX = unityDist / minimumBillboardScale.x;
		newBBScale.x = (camDist > minScaleDistX) ? (camDist / minScaleDistX) : 1.0f;
	}
	
	if (minimumBillboardScale.y > 0.0) {
		GLfloat minScaleDistY = unityDist / minimumBillboardScale.y;
		newBBScale.y = (camDist > minScaleDistY) ? (camDist / minScaleDistY) : 1.0f;
	}
	
	if (maximumBillboardScale.x > 0.0) {
		GLfloat maxScaleDistX = unityDist / maximumBillboardScale.x;
		newBBScale.x = (camDist < maxScaleDistX) ? (camDist / maxScaleDistX) : 1.0f;
	}
	
	if (maximumBillboardScale.y > 0.0) {
		GLfloat maxScaleDistY = unityDist / maximumBillboardScale.y;
		newBBScale.y = (camDist < maxScaleDistY) ? (camDist / maxScaleDistY) : 1.0f;
	}
	
	// Set the new scale only if it has changed. 
	if (billboard.scaleX != newBBScale.x) billboard.scaleX = newBBScale.x;
	if (billboard.scaleY != newBBScale.y) billboard.scaleY = newBBScale.y;
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


#pragma mark Drawing

/** Overridden to return YES only if this billboard should draw in 3D. */
-(BOOL) hasLocalContent {
	return !shouldDrawAs2DOverlay;
}

/** Only intersect frustum when drawing in 3D mode. */
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	BOOL intersects = (!shouldDrawAs2DOverlay) && ([super doesIntersectFrustum: aFrustum]);
	LogTrace(@"%@ bounded by %@ %@\n%@", self, boundingVolume,
			 (intersects ? @"intersects" : @"does not intersect"), aFrustum);

	// Uncomment and change name to verify culling:
//	if (!intersects && ([self.name isEqualToString: @"MyNodeName"])) {
//		LogDebug(@"%@ with anchor: %@ & bounding box: %@ does not intersect\n%@",
//				 self, NSStringFromCGPoint(billboard.anchorPoint),
//				 NSStringFromCGRect(billboard.boundingBoxInPixels), aFrustum);
//	}
	return intersects;
}

/**
 * During normal drawing, configure the material, texture, and vertex arrays environments
 * for cocos2d node drawing. Don't configure anything if painting for node picking.
 */
-(void) configureMaterialWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super configureMaterialWithVisitor: visitor];
	
	if (visitor.shouldDecorateNode) {
		
		// 2D drawing might change material properties unbeknownst to cocos3d,
		// so force the material to be respecified on next 3D draw
		[CC3Material resetSwitching];

		CC3OpenGLES11Engine* gles11Engine = [CC3OpenGLES11Engine engine];
		
		// Set blending to the value expected by cocos2d
		CC3OpenGLES11StateTrackerServerCapability* gles11Blend = gles11Engine.serverCapabilities.blend;
		gles11Blend.value = gles11Blend.originalValue;
		
		// Set the blend functions to those expected by cocos2d
		CC3OpenGLES11StateTrackerMaterialBlend* gles11MatBlend = gles11Engine.materials.blendFunc;
		[gles11MatBlend applySource: gles11MatBlend.sourceBlend.originalValue
					 andDestination: gles11MatBlend.destinationBlend.originalValue];
		
		// Enable the texture unit to draw the 2D texture mesh (usually GL_TEXTURE0)
		// and bind the default texture unit parameters
		CC3OpenGLES11Textures* gles11Textures = gles11Engine.textures;
		CC3OpenGLES11TextureUnit* gles11TexUnit = [gles11Textures textureUnitAt: textureUnitIndex];
		[gles11TexUnit.texture2D enable];
		[CC3TextureUnit bindDefaultTo: gles11TexUnit];
		[gles11TexUnit.textureCoordArray enable];
		
		// Clear the texture unit binding so we start afresh on next 3D binding
		gles11TexUnit.textureBinding.value = 0;
		
		// Disable all other texture units
		[CC3Texture unbindRemainingFrom: textureUnitIndex + 1];
		[CC3VertexTextureCoordinates unbindRemainingFrom: textureUnitIndex + 1];
		
		// Make sure the 2D texture unit is active
		gles11Textures.activeTexture.value = textureUnitIndex;
		gles11Textures.clientActiveTexture.value = textureUnitIndex;
		
		// Enable vertex and color arrays, and disable normal and point size arrays.
		CC3OpenGLES11ClientCapabilities* gles11ClientCaps = gles11Engine.clientCapabilities;
		[gles11ClientCaps.vertexArray enable];
		[gles11ClientCaps.colorArray enable];
		[gles11ClientCaps.normalArray disable];
		[gles11ClientCaps.pointSizeArray disable];
		
		// 2D drawing might change buffer properties unbeknownst to cocos3d,
		// so force the buffers to be respecified on next 3D draw
		CC3OpenGLES11VertexArrays* gles11Vertices = gles11Engine.vertices;
		[gles11Vertices.arrayBuffer unbind];
		[gles11Vertices.indexBuffer unbind];
		
		// 2D drawing might change mesh properties unbeknownst to cocos3d,
		// so force the mesh to be respecified on next 3D draw
		[CC3VertexArrayMesh resetSwitching];
	}
}

/**
 * During normal drawing, draw the cocos2d node.
 * When painting for node picking, update the bounding box mesh vertices and draw it.
 */
-(void) drawMeshWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	
	if (visitor.shouldDecorateNode) {
		
		// If things get weird when drawing some CCNode subclasses, use the following
		// to log the full GL engine state prior to drawing the 2D node
		LogTrace(@"%@ drawing 2D node with GL engine state:\n %@", self, gles11Engine);
		
		[billboard visit];		// Draw the 2D CCNode
		
	} else {
		// We're drawing a colored box to allow this node to be picked by a touch.
		// This is done by creating and drawing an underlying rectangle mesh that
		// is sized the same as the 2D node.
		if (!mesh) {
			[self populateAsBoundingRectangle];
		}
		[self updatePickingBoundingRect];
		LogTrace(@"%@ drawing picking rectangle mesh %@", self, mesh);
		[super drawMeshWithVisitor: visitor];
	}
}

/** Update the vertices of the node picking mesh to match the bounding box of the 2D node. */
-(void) updatePickingBoundingRect {
	CGRect bRect = self.billboardBoundingRect;
	GLfloat xMin = CGRectGetMinX(bRect);
	GLfloat xMax = CGRectGetMaxX(bRect);
	GLfloat yMin = CGRectGetMinY(bRect);
	GLfloat yMax = CGRectGetMaxY(bRect);
	[self setVertexLocation: cc3v(xMax, yMax, 0.0) at: 0];
	[self setVertexLocation: cc3v(xMin, yMax, 0.0) at: 1];
	[self setVertexLocation: cc3v(xMax, yMin, 0.0) at: 2];
	[self setVertexLocation: cc3v(xMin, yMin, 0.0) at: 3];
}

-(BOOL) doesIntersectBounds: (CGRect) bounds {
	if (boundingVolume) {
		BOOL intersects = [((CC3NodeBoundingArea*)boundingVolume) doesIntersectBounds: bounds];
		LogTrace(@"%@ bounded by %@ %@ %@", self, boundingVolume,
				 (intersects ? @"intersects" : @"does not intersect"), NSStringFromCGRect(bounds));

		// Uncomment and change name to verify culling:
//		if (!intersects && ([self.name isEqualToString: @"MyNodeName"])) {
//			LogDebug(@"%@ bounded by %@ does not intersect %@",
//					self, boundingVolume, NSStringFromCGRect(bounds));
//		}
		return intersects;
	}
	return YES;
}

-(void) draw2dWithinBounds: (CGRect) bounds {
	if(shouldDrawAs2DOverlay && self.visible && [self doesIntersectBounds: bounds ]) {
		[billboard visit];
	}
}


#pragma mark CC3Node Actions

- (void) resumeActions {
	[super resumeActions];
	[billboard resumeSchedulerAndActions];
}

- (void) pauseActions {
	[super pauseActions];
	[billboard pauseSchedulerAndActions];
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


#pragma mark CC3Targetting wrappers

-(CC3TargettingNode*) asTargettingNode {
	self.rotation = cc3v(0.0, 180.0, 0.0);
	return [super asTargettingNode];
}

-(CC3TargettingNode*) asLightTracker {
	self.rotation = cc3v(0.0, 180.0, 0.0);
	return [super asLightTracker];
}

@end


#pragma mark -
#pragma mark CC3BillboardBoundingBoxArea

@interface CC3NodeBoundingVolume (TemplateMethods)
-(void) populateFrom: (CC3NodeBoundingVolume*) another;
-(void) transformVolume;
@end

@interface CC3BillboardBoundingBoxArea (TemplateMethods)
	@property(nonatomic, readonly) CGRect billboardBoundingRect;
@end

@implementation CC3BillboardBoundingBoxArea

-(CC3Vector*) globalBoundingRectVertices {
	return globalBoundingRectVertices;
}

-(id) init {
	if ( (self = [super init]) ) {
		for (int i=0; i < 4; i++) {
			globalBoundingRectVertices[i] = kCC3VectorZero;
		}
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3BillboardBoundingBoxArea*) another {
	[super populateFrom: another];
	
	for (int i = 0; i < 4; i++) {
		globalBoundingRectVertices[i] = another.globalBoundingRectVertices[i];
	}
}

/**
 * Return the bounding rectangle of the 2D node held in the CC3Billboard node.
 * If its not valid, return a zero rectangle.
 */
-(CGRect) billboardBoundingRect {
	CGRect bRect = ((CC3Billboard*)node).billboardBoundingRect;
	LogTrace(@"%@ bounding rect: %@", node, NSStringFromCGRect(bRect));
	return CGRectIsNull(bRect) ? CGRectZero : bRect;
}

/** Transform the bounding rectangle of the 2D node on the X-Y plane into 3D. */
-(void) transformVolume {
	[super transformVolume];

	// Get the corners of the CCNode bounding box
	CGRect bb = [self billboardBoundingRect];
	CGPoint bbMin = ccp(CGRectGetMinX(bb), CGRectGetMinY(bb));
	CGPoint bbMax = ccp(CGRectGetMaxX(bb), CGRectGetMaxY(bb));
	
	// Construct all 4 corner vertices of the local bounding box and transform each to global coordinates
	globalBoundingRectVertices[0] = [node.transformMatrix transformLocation: cc3v(bbMin.x, bbMin.y, 0.0)];
	globalBoundingRectVertices[1] = [node.transformMatrix transformLocation: cc3v(bbMin.x, bbMax.y, 0.0)];
	globalBoundingRectVertices[2] = [node.transformMatrix transformLocation: cc3v(bbMax.x, bbMin.y, 0.0)];
	globalBoundingRectVertices[3] = [node.transformMatrix transformLocation: cc3v(bbMax.x, bbMax.y, 0.0)];
	
	LogTrace(@"%@ bounding volume transformed %@ MinMax(%@, %@) to (%@, %@, %@, %@)", self.node,
			 NSStringFromCGRect(bb),
			 NSStringFromCGPoint(bbMin), NSStringFromCGPoint(bbMax), 
			 NSStringFromCC3Vector(globalBoundingRectVertices[0]), NSStringFromCC3Vector(globalBoundingRectVertices[1]),
			 NSStringFromCC3Vector(globalBoundingRectVertices[2]), NSStringFromCC3Vector(globalBoundingRectVertices[3]));
}

/** Returns whether the specified location lies inside the specified plane. */
-(BOOL) isLocation: (CC3Vector) location insidePlane: (CC3Plane) plane {
	return (CC3DistanceFromNormalizedPlane(plane, location) > 0);
}

/**
 * Returns whether this bounding box lies completely outside the specified plane
 * by testing each of the eight verticies of the global bounding box, and returning
 * as soon as one vertex is found to lie inside the plane.
 */
-(BOOL) isOutsidePlane: (CC3Plane) plane {
	for (int i=0; i < 4; i++) {
		if ([self isLocation: globalBoundingRectVertices[i] insidePlane: plane]) {
			return NO;
		}
	}
	return YES;
}

/**
 * Rejects quickly, so check in a sensible order of realism.
 * In most scenes, most objects that are outside the frustum will be behind
 * the camera or off to the left or right. Least likely is something that is
 * so far away as to be outside the far clip plane.
 */
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	BOOL isOutside = [self isOutsidePlane: aFrustum.nearPlane] ||
	[self isOutsidePlane: aFrustum.leftPlane] ||
	[self isOutsidePlane: aFrustum.rightPlane] ||
	[self isOutsidePlane: aFrustum.topPlane] ||
	[self isOutsidePlane: aFrustum.bottomPlane] ||
	[self isOutsidePlane: aFrustum.farPlane];
	return !isOutside;
}

-(BOOL) doesIntersectBounds: (CGRect) bounds {
	return CGRectIntersectsRect([self billboardBoundingRect], bounds);
}

-(NSString*) description {
	CCNode* billboard = ((CC3Billboard*)node).billboard;
	CC3Vector gbbv, gbbvMin, gbbvMax;
	gbbv = globalBoundingRectVertices[0];
	gbbvMin = gbbv;
	gbbvMax = gbbv;
	for (GLsizei i = 1; i < 4; i++) {
		gbbv = globalBoundingRectVertices[i];
		gbbvMin = CC3VectorMinimize(gbbvMin, gbbv);
		gbbvMax = CC3VectorMaximize(gbbvMax, gbbv);
	}
	return [NSString stringWithFormat: @"%@ with 2D bounding box: %@ and 3D global bounding box: (%@, %@)",
			[self class], (billboard ? NSStringFromCGRect(billboard.boundingBoxInPixels): @"none"),
			NSStringFromCC3Vector(gbbvMin), NSStringFromCC3Vector(gbbvMax)];
}

@end


#pragma mark -
#pragma mark CC3ParticleSystemBillboard

@implementation CC3ParticleSystemBillboard

@synthesize particleSizeAttenuationCoefficients;


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		particleSizeAttenuationCoefficients = kCC3ParticleSizeAttenuationNone;
		shouldDisableDepthMask = YES;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3ParticleSystemBillboard*) another {
	[super populateFrom: another];
	
	particleSizeAttenuationCoefficients = another.particleSizeAttenuationCoefficients;
}


#pragma mark Updating

/**
 * If the particle system has exhausted and it is set to auto-remove, remove this
 * node from the world so that this node and the particle system will be released.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	if (billboard) {
		CCParticleSystem* ps = (CCParticleSystem*)billboard;
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

	[CC3OpenGLES11Engine engine].state.pointSizeAttenuation.value = *(CC3Vector*)&particleSizeAttenuationCoefficients;
}

@end


#pragma mark -
#pragma mark CC3NodeDescriptor

@implementation CC3NodeDescriptor

-(CC3BoundingBox) localContentBoundingBox {
	return kCC3BoundingBoxNull;
}

-(CC3BoundingBox) globalLocalContentBoundingBox {
	return kCC3BoundingBoxNull;
}

-(BOOL) shouldIncludeInDeepCopy { return NO; }

-(BOOL) shouldDrawDescriptor { return YES; }

-(void) setShouldDrawDescriptor: (BOOL) shouldDraw {}

-(BOOL) shouldDrawWireframeBox { return YES; }

-(void) setShouldDrawWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldDrawLocalContentWireframeBox { return YES; }

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {}

-(BOOL) shouldContributeToParentBoundingBox { return NO; }


// Overridden so that not touchable unless specifically set as such
-(BOOL) isTouchable {
	return isTouchEnabled;
}

// Overridden so that will still be visible if parent is invisible,
// unless explicitly set off.
-(BOOL) visible {
	return visible;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		minimumBillboardScale = ccp(1.0, 1.0);
		maximumBillboardScale = ccp(1.0, 1.0);
		shouldDrawAs2DOverlay = YES;
	}
	return self;
}

@end

#pragma mark -
#pragma mark CCNode extensions

@implementation CCNode (CC3Billboard)

-(CGFloat) billboard3DContentScaleFactor {
	return 1.0;
}

/** Simply return the bounding box of this node. */
-(CGRect) measureBoundingBoxInPixels {
	return self.boundingBoxInPixels;
}

@end


#pragma mark -
#pragma mark CCParticleSystemQuad extensions

@implementation CCParticleSystemQuad (CC3)

/** Scales by the inverse of the retina content scale factor. */
-(CGFloat) billboard3DContentScaleFactor {
	return 1.0 / CC_CONTENT_SCALE_FACTOR();
}

// cocos2d 1.0 and below use 2D structures for particle quad vertices
// cocos2d 1.1 and above use 3D structures for particle quad vertices
#ifndef CC_USES_2D_PARTICLES
	#define CC_USES_2D_PARTICLES	1
#endif
#if defined(CC_USES_2D_PARTICLES) && CC_USES_2D_PARTICLES
	#define CC_PARTICLE_QUAD_TYPE ccV2F_C4B_T2F_Quad
#else
	#define CC_PARTICLE_QUAD_TYPE ccV3F_C4B_T2F_Quad
#endif

/**
 * Find the absolute bottom left and top right from all four vertices in the quad,
 * assuming that the bl and tr of the quad are nominal representations and do not
 * necessarily represent the true corners of the quad. Then create a rectangle from
 * these true bottom left and top right corners.
 */
-(CGRect) makeRectFromQuad: (CC_PARTICLE_QUAD_TYPE) quad {
	CGFloat blx = MIN(quad.bl.vertices.x, MIN(quad.br.vertices.x, MIN(quad.tl.vertices.x, quad.tr.vertices.x)));
	CGFloat bly = MIN(quad.bl.vertices.y, MIN(quad.br.vertices.y, MIN(quad.tl.vertices.y, quad.tr.vertices.y)));
	CGFloat trx = MAX(quad.bl.vertices.x, MAX(quad.br.vertices.x, MAX(quad.tl.vertices.x, quad.tr.vertices.x)));
	CGFloat try = MAX(quad.bl.vertices.y, MAX(quad.br.vertices.y, MAX(quad.tl.vertices.y, quad.tr.vertices.y)));
	return CGRectMake(blx, bly, trx - blx, try - bly);
}

/** Build the bounding box to encompass the locations of all of the particles. */
-(CGRect) measureBoundingBoxInPixels {
	// Must have at least one quad
	if (quads_ && particleIdx > 0) {
		// Get the first quad as a starting point
		CGRect boundingRect = [self makeRectFromQuad: quads_[0]];
		
		// Iterate through all the remaining quads, taking the union of the
		// current bounding rect and each quad to find the rectangle that
		// bounds all the quads.
		for(NSUInteger i = 1; i < particleIdx; i++) {
			CGRect quadRect = [self makeRectFromQuad: quads_[i]];
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

@implementation CCParticleSystemPoint (CC3)

/** Scales by the inverse of the retina content scale factor. */
-(CGFloat) billboard3DContentScaleFactor {
	return 1.0 / CC_CONTENT_SCALE_FACTOR();
}

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


#pragma mark -
#pragma mark CCLabelTTF extensions

@implementation CCLabelTTF (CC3)

/** Scales by the inverse of the retina content scale factor. */
-(CGFloat) billboard3DContentScaleFactor {
	return 1.0 / CC_CONTENT_SCALE_FACTOR();
}

@end
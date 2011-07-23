/*
 * CC3Billboard.h
 *
 * cocos3d 0.6.0-sp
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
 */

/** @file */	// Doxygen marker

#import "CC3Camera.h"
#import "CC3BoundingVolumes.h"
#import "CCNode.h"


/**
 * This CC3Node displays a 2D cocos2d CCNode at the projectedPosition of this node.
 * Since the  cocos2d node is displayed in 2D, it always appears to face the camera,
 * and it is never occluded by any 3D objects.
 *
 * CC3Billboards are useful for drawing a label, health-bar, or some other 2D artifact
 * on or near the projected position of a 3D object, and have that 2D artifact
 * apparently move along with the 3D object as it moves through the 3D world.
 *
 * CC3Billboard is a type of CC3Node, and can therefore participate in a structural
 * node assembly. An instance can be the child of another node, and the billboard
 * itself can have child nodes.
 *
 * The size of the 2D node can be automatically scaled based on the distance between
 * the 3D billboard node and the 3D camera. Doing so will keep the 2D artifact at the
 * same proportional size to the 3D object, as the 3D object moves toward or away from
 * the camera.
 * 
 * This dyanamic scaling of the 2D artifact is the default behaviour. To fix the 2D
 * artifact to a single static scale, set both the minimumBillboardScale and
 * minimumBillboardScale properties to the same non-zero value.
 *
 * As with all CC3Nodes, CC3Billboards support the protocol CCRGBAProtocol.
 * When wrapping a 2D CCNode billboard that also supports CCRGBAProtocol, changes to
 * the CC3Billboard color and opacity properties will change those same properties in
 * the encapsulated 2D CCNode billboard. When reading the color and opacity properties
 * of the CC3Billboard, the value returned will be that of the 2D CCNode.
 *
 * Using the shouldNormalizeScaleToDevice property, you can choose whether the 2D
 * billboard should be scaled to appear to be the same size, relative to the 3D
 * artifacts around it, across all screen resolutions, or whether the 2D billboard
 * should be drawn in its natural resolution, which may make it appear to be larger
 * or smaller, relative to the 3D artifacts around it, on different devices.
 *
 * Generally, CC3Billboards return NO for the hasLocalContent property, and are not
 * drawn along with other nodes that do have local content. Instead, CC3Billboards
 * are drawn by the CC3World after all 3D drawing has been completed. To do this,
 * the CC3World invokes the draw2dWithinBounds: method on each CC3Billboard instance.
 *
 * A CC3Billboard can, and should, have a bounding volume, but the bounding volume
 * must be an instance of a subclass of CC3NodeBoundingArea, because the boundary
 * is tested against the viewport instead of the camera frustum. The default bounding
 * volume is an instance of CC3BillboardBoundingBoxArea, which tests for overlap
 * between the bounding box of the CC3Layer and the boundingBox of the enclosed
 * 2D CCNode instance.
 */
@interface CC3Billboard : CC3Node {
	CCNode* billboard;
	CGPoint offsetPosition;
	GLfloat unityScaleDistance;
	CGPoint minimumBillboardScale;
	CGPoint maximumBillboardScale;
	BOOL shouldNormalizeScaleToDevice;
}

/** The 2D artifact that this node will display. This can be any CCNode subclass. */
@property(nonatomic, retain) CCNode* billboard;

/**
 * An offset, measured in 2D display points, at which the 2D billboard should be positioned
 * relative to the 2D projectedPosition of this node. The initial value is {0, 0}.
 * This property can be useful in helping to center or positionally justify the 2D artifact.
 */
@property(nonatomic, assign) CGPoint offsetPosition;

/**
 * The distance from the camera, in 3D space, at which the 2D artifact will be displayed
 * at unity scale (its natural size). If this node is closer to the camera than this
 * distance, the 2D artifact will be scaled up proportionally. If this node is farther
 * from the camera than this distance, the 2D artifact will be scaled down proportionally.
 *
 * If the value of this property is zero, the camera's near clip plane distance will be
 * used as the unity scale distance, and therefore the 2D artifact will only ever appear
 * smaller than its natural size. The initial value of this property is zero.
 */
@property(nonatomic, assign) GLfloat unityScaleDistance;


/** 
 * Indicates whether the size of the 2D billboard should be adjusted so that its size
 * relative to the 3D artifacts appears to be the same across all devices.
 *
 * The 3D camera frustum is consistent across all devices, making the view of the 3D scene
 * consistent across all devices. The result is that on devices with larger screen resolutions,
 * each 3D artifact will be drawn across more pixels, and may appear visually larger. 
 * 
 * If this property is set to YES, the scale of the 2D billboard will be adjusted so
 * that it appears to be the same size across all devices, relative to the 3D artifacts.
 *
 * If this property is set to NO, the 2D billboard will be drawn in the same absolute
 * pixel size across all devices, which may make it appear to be smaller or larger,
 * relative to the 3D artifacts around it, on different devices.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldNormalizeScaleToDevice;

/**
 * The scaling factor used to adjust the scale of the 2D billboard so that it's size
 * relative to the 3D artifacts appears consistent across all device screen resolutions,
 * if the shouldNormalizeScaleToDevice property is set to YES.
 *
 * The value returned depends on the device screen window size and is normalized to the
 * original iPhone/iPod Touch screen size of 480 x 320. The value returned for an original
 * iPhone or iPod Touch will be 1.0. The value returned for other devices depends on the
 * screen resolution, and formally, on the screen height as measured in pixels.
 * Devices with larger screen heights in pixels will return a value greater than 1.0.
 * Devices with smaller screen heights in pixels will return a value less than 1.0
 */
+(GLfloat) deviceScaleFactor;

/**
 * The minimum scale that will be applied to the 2D artifact. Setting this property to a
 * non-zero value will stop the 2D artifact from shrinking away to nothing as the 3D object
 * recedes far from the camera. For example, you may want to keep a name label readable,
 * even if the character it labels is far from the camera.
 *
 * If this property is zero, no minimum will be applied. If this property is non-zero and
 * is equal to the maximumBillboardScale, the 2D artifact will always be displayed at that
 * single scale, regardless of how near or far the 3D object is from the camera. 
 */
@property(nonatomic, assign) CGPoint minimumBillboardScale;

/**
 * The maximum scale that will be applied to the 2D artifact. Setting this property to a
 * non-zero value will stop the 2D artifact from growing too large as the 3D object
 * approaches very close to the camera. For example, you may want to keep a name label
 * at a readable size, even if the character it labels comes right up to the camera.
 *
 * If this property is zero, no maximum will be applied. If this property is non-zero and
 * is equal to the minimumBillboardScale, the 2D artifact will always be displayed at that
 * single scale, regardless of how near or far the 3D object is from the camera. 
 */
@property(nonatomic, assign) CGPoint maximumBillboardScale;


#pragma mark Allocation and initialization

/** Initializes this instance with the specified tag, name and 2D node to be drawn. */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName withBillboard: (CCNode*) a2DNode;

/**
 * Initializes this unnamed instance with an automatically generated unique tag value,
 * and the specified 2D node to be drawn.
 */
-(id) initWithBillboard: (CCNode*) a2DNode;

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value, and the specified 2D node to be drawn.
 */
+(id) nodeWithBillboard: (CCNode*) a2DNode;

/**
 * Initializes this instance with an automatically generated unique tag value,
 * and the specified name and 2D node to be drawn.
 */
-(id) initWithName: (NSString*) aName withBillboard: (CCNode*) a2DNode;

/**
 * Allocates and initializes an autoreleased instance with an automatically generated
 * unique tag value, and the specified name and 2D node to be drawn.
 */
+(id) nodeWithName: (NSString*) aName withBillboard: (CCNode*) a2DNode;


#pragma mark Updating

/**
 * Uses the specified camera to project the 3D location of this node into 2D, sets the
 * position of the 2D artifact in the billboard property to that position, and if dynamic
 * scaling is being used, calculates and sets the scale of the 2D billboard artifact
 * appropriately, based on the distance this node is from the specified camera.
 *
 * This method is invoked automatically by CC3World during model updating.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) faceCamera: (CC3Camera*) camera;


#pragma mark Drawing

/**
 * Draws the 2D artifact at the 2D position calculated in the faceCamera: method.
 *
 * This method is invoked automatically by CC3World at the end of each frame drawing cycle.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) draw2dWithinBounds: (CGRect) bounds;

/**
 * Returns whether the local content of this node intersects the given bounding rectangle.
 * This check does not include checking children, only the local content.
 *
 * This method is called during the drawing operations of each frame to determine whether
 * this node should be culled from the visible nodes and not drawn. A return value of YES
 * will cause the node to be drawn, a return value of NO will cause the node to be culled
 * and not drawn.
 *
 * Culling nodes that are not visible to the camera is an important performance enhancement.
 * The node should strive to be as accurate as possible in returning whether it intersects
 * the viewport. Incorrectly returning YES will cause wasted processing within the GL engine.
 * Incorrectly returning NO will cause a node that should at least be partially visible to
 * not be drawn.
 *
 * In this implementation, if this node has a boundingVolume, this method delegates to it.
 * Otherwise, it simply returns YES. Subclasses may override to change this standard behaviour.
 *
 * The boundingVolume of a CC3Billboard must be an instance of a subclass of CC3NodeBoundingArea.
 */
-(BOOL) doesIntersectBounds: (CGRect) bounds;

	
@end


#pragma mark -
#pragma mark CC3ParticleSystemBillboard interface

/**
 * A CC3Billboard node customized to display and manage a cocos2d 2D CCParticleSystem.
 *
 * You can use the base CC3Billboard class to display a 2D CCParticleSystem, but this
 * class adds some additional management features, including:
 *   - If the CCParticleSystem has a finite duration and its autoRemoveOnFinish property
 *     is set to YES, the CC3ParticleSystemBillboard node is automatically removed from
 *     its parent once the particle system has finished emitting.
 */
@interface CC3ParticleSystemBillboard : CC3Billboard
@end


#pragma mark -
#pragma mark CC3BillboardBoundingBoxArea interface

/**
 * A CC3NodeBoundingArea, used exclusively with CC3Billboards, that uses the boundingBox
 * property of the 2D CCNode contained within a CC3Billboard instance as the bounding area,
 * and checks the bounding area against a given bounding box (typically from the CC3Layer),
 * using the doesIntersectBounds: method.
 */
@interface CC3BillboardBoundingBoxArea : CC3NodeBoundingArea
@end

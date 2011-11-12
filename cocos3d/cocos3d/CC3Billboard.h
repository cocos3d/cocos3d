/*
 * CC3Billboard.h
 *
 * cocos3d 0.6.3
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
#import "CC3MeshNode.h"
#import "CCNode.h"
#import "CCParticleSystemPoint.h"


/**
 * This CC3Node displays a 2D cocos2d CCNode as part of the 3D world.
 *
 * The 2D node can be displayed in one of two ways, as determined by the value of
 * the shouldDrawAs2DOverlay property:
 *
 *   - When shouldDrawAs2DOverlay is set to NO (the default), the 2D CCNode will
 *     be embedded in the 3D world and will be drawn at the Z-depth of this node.
 *     Like all 3D nodes, the 2D node will be occluded if other 3D nodes are between
 *     this node and the camera, it can be rotated in 3D to face away from the camera,
 *     and can be selected by touch events.
 *
 *   - When shouldDrawAs2DOverlay is set to YES, the 2D CCNode will be drawn at the
 *     projectedPosition of this node, after the 3D world has completed drawing,
 *     and the GL engine has reverted to 2D rendering. The 2D node will ignore 3D
 *     depth testing, and will be drawn on top of all 3D nodes, even if there are
 *     other 3D nodes between this node and the camera. The 2D node will always appear
 *     to face directly towards the camera, and cannot be selected by touch events.
 *
 * CC3Billboards are useful for drawing a label, health-bar, speech-balloon, or some
 * other 2D artifact in or on the 3D world, and have that 2D artifact move along with
 * this node as it moves through the 3D world.
 *
 * CC3Billboard is a type of CC3Node, and can therefore participate in a structural
 * node assembly. An instance can be the child of another node, and the CC3Billboard
 * itself can have child nodes.
 *
 * The size of the 2D node will be automatically scaled based on the distance between
 * the 3D billboard node and the 3D camera to keep the 2D artifact at the correct
 * perspective as this node moves toward or away from the camera.
 *
 * The perspective sizing of the 2D node can be influenced by two properties:
 * minimumBillboardScale and maximumBillboardScale, which can define a minimum and
 * maximum limits to which the node will be sized, respectively, relative to a nominal
 * size. This capability is useful when the 2D node is a label, health-bar, or
 * speech-balloon, and it is desirable to keep the text at a readable size, regardless
 * of how near or far the node moves in the 3D world, relative to the camera.
 *
 * Since the scale of the 2D billboard is often automatically adjusted, you should be
 * careful when setting the scale property of the 2D billboard. In particular, when
 * the 2D node is embedded in the 3D world, (the shouldDrawAs2DOverlay property is set
 * to the default NO), the scale property of the 2D node will be directly manipulated
 * if the value of the shouldNormalizeScaleToDevice property on this CC3Billboard is
 * set to YES, and any value you set for the 2D node scale property will be ignored.
 *
 * As with all CC3Nodes, CC3Billboards support the protocol CCRGBAProtocol.
 * When wrapping a 2D CCNode billboard that also supports CCRGBAProtocol, changes to
 * the CC3Billboard color and opacity properties will change those same properties in
 * the encapsulated 2D CCNode billboard. When reading the color and opacity properties
 * of the CC3Billboard, the value returned will be that of the 2D CCNode.
 *
 * A CC3Billboard can, and should, have a bounding volume, but the bounding volume
 * must be an instance of a subclass of CC3NodeBoundingArea, which maps the 2D boundary
 * of the 2D node into the 3D world, and when shouldDrawAs2DOverlay is YES, handles
 * testing the 2D bounds of the 2D node against the bounds of the 2D drawing plane. 
 */
@interface CC3Billboard : CC3MeshNode {
	CCNode* billboard;
	CGRect billboardBoundingRect;
	CGPoint offsetPosition;
	GLfloat unityScaleDistance;
	CGPoint minimumBillboardScale;
	CGPoint maximumBillboardScale;
	GLuint textureUnitIndex;
	BOOL shouldNormalizeScaleToDevice;
	BOOL shouldDrawAs2DOverlay;
	BOOL shouldAlwaysMeasureBillboardBoundingRect;
	BOOL shouldMaximizeBillboardBoundingRect;
}

/** The 2D artifact that this node will display. This can be any CCNode subclass. */
@property(nonatomic, retain) CCNode* billboard;

/**
 * Indicates whether this instance should be drawn in 2D as an overlay on top of
 * the 3D world, or embedded into the 3D world.
 *
 * When set to NO, the 2D CCNode will be drawn at the Z-depth of this node, and
 * will be occluded if other 3D nodes are between this node and the camera.
 * And, like other 3D nodes, it can be rotated in 3D to face away from the camera,
 * and can be selected by touch events.
 *
 * When set to YES, the 2D CCNode will be drawn after the 3D world has completed
 * drawing, and the GL engine has reverted to 2D rendering. The 2D node will ignore
 * 3D depth testing, and will be drawn on top of all 3D nodes, even if there are
 * other 3D nodes between this node and the camera. The CCNode will always appear
 * to face directly towards the camera, and cannot be selected by touch events.
 * 
 * The initial value of this property is NO, indicating that the 2D node will be
 * embedded into the 3D world.
 *
 * In most cases, you will simply want to leave this property with the default NO
 * value. However, there are some cases where you want the 2D node to truly be
 * displayed on top of the whole 3D world. An example might be an identifier label
 * or speech-balloon attached to a character in the game. You might want to display
 * the label or speech-balloon even when the character is not visible becuase it is
 * behind another object, or inside a building. You can attach this node to the
 * character node and set the value of this property to YES. The label or speech-
 * balloon will then move around as the character moves, but will remain visible
 * even if the character moves behind another object in the scene.
 */
@property(nonatomic, assign) BOOL shouldDrawAs2DOverlay;

/**
 * The rectangle, in pixels, bounding the 2D CCNode, in the local coordinate system
 * of the 2D node. This property is used by cocos3d when each frame is drawn, to test
 * whether this node is within the field of view of the camera and should be drawn.
 * It is accessed on each rendering frame. The value of this property is also used
 * when picking nodes from touch events.
 *
 * The value of this property can be set directly, or it can be measured automatically
 * from the size of the 2D node when accesssed as follows:
 *
 *  - If the value of this property is left unset, the value will be lazily measured
 *    from the size of the 2D node the first time this property is accessed. The value
 *    of this property will then be cached for subsequent accesses, and will not be
 *    remeasured from the 2D node unless the resetBillboardBoundingRect method is invoked.
 *  - If the value of either of the shouldAlwaysMeasureBillboardBoundingRect or
 *    shouldDrawAs2DOverlay properties is YES, the value of this property will be
 *    measured from the size of the 2D node each time this property is accessed.
 *  - If the value of the shouldMaximizeBillboardBoundingRect property is YES,
 *    the value of this property will be measured from the size of the 2D node each
 *    time this property is accessed, and the maximum value of this property will be
 *    retained. In this situation, for a 2D node that changes shape and size over time,
 *    such as a particle system, the value of this property will grow over time to to
 *    the maximum size that the 2D node has become since this property was initialized
 *    or last reset using the resetBillboardBoundingRect method.
 *
 * The choice of how to use this property depends on the type of 2D node being held.
 * If the value of the shouldDrawAs2DOverlay property is set to NO (the default),
 * the 2D node is embedded in the 3D world, and the following applies:
 *  - For static 2D nodes, such as buttons, 2D sprites, or static text labels, the
 *    simplest thing to do is leave this property with the default value and allow
 *    it to be lazily measureed from the 2D node the first time it is accessed, and
 *    cached for subsequent accesses.
 *  - For 2D nodes whose boundary change under app control, such as a text label,
 *    you can also allow this property to be lazily initialized, and then use the
 *    resetBillboardBoundingRect method whenever you know the size or shape of the
 *    2D node has changed (eg- the text of the label has changed), to reset this
 *    property so that it will be measured again from the 2D node the next time this
 *    property is accessed.
 *  - For 2D nodes whose boundary changes dynamically, such as a text label that is
 *    frequently changed, or a 2D node whose scale or rotation changes under control
 *    of a CCAction, or a particle system, you can cause the boundary of the 2D node
 *    to be measured on each access of this property by setting the value of the
 *    shouldAlwaysMeasureBillboardBoundingRect property to YES.
 *  - For a particle system with many particles, measuring the boundary of the 2D
 *    every time this property is accessed (which is on each rendering frame) can
 *    be very computationally expensive. For a particle system that has a reasonable
 *    maximum boundary (like a flame, explosion, etc), you can pre-compute the
 *    boundary, and explicitly set this property to that pre-computed value.
 *    If the value of the shouldAlwaysMeasureBillboardBoundingRect property is left
 *    set to NO, then this pre-computed boundary will be retained and used for the
 *    life of the particle system, and the boundary will not be measured on each
 *    frame render.
 *  - To pre-compute the maximum boundary of a dynamic node like a particle system,
 *    you can temporarily set the shouldMaximizeBillboardBoundingRect property to
 *    YES (either at development time, or runtime start-up), running the particle
 *    system, and then extracting (or logging at development time) the maximum
 *    boundary that is accumulated.
 *  - For a particle system that spans a large amount of screen space, like rain
 *    or stars, you can either pre-compute a large boundary, or simply set the
 *    boundingVolume of this node to nil, in which case this property will be
 *    ignored, and the particle system will be drawn on every frame render,
 *    regardless of where the camera is pointed.
 *
 * If the shouldDrawAs2DOverlay property is set to YES, the 2D node will be drawn as
 * a 2D overlay, and the value of this property will be measured from the 2D node each
 * time this property is accessed. This is because the boundary of the 2D overlay node
 * changes dynamically as either the node or the camera is moved.
 *
 * The initial value of this property is CGRectNull. If this node contains a 2D node,
 * the value returned will be measured from the 2D node the first time this property
 * is accessed, and cached for future access. If this node does not contain a 2D node,
 * this property will simply return the CGRectNull value.
 */
@property(nonatomic, assign) CGRect billboardBoundingRect;

/**
 * Resets the value of the billboardBoundingRect property so that it will be measured
 * again from the 2D node the next time the billboardBoundingRect is accessed.
 *
 * You can use this method after you change the 2D node is a way that changes its
 * boundary, to force the bounding rectangle of the 2D node to be re-measured and
 * re-cached. An example might be when you change the text of a 2D label, which will
 * change the boundary of the label.
 */
-(void) resetBillboardBoundingRect;

/**
 * Indicates whether the value of the billboardBoundingRect property should be
 * measured from the 2D node each time the billboardBoundingRect property is accessed.
 *
 * If the values of this property and the shouldMaximizeBillboardBoundingRect
 * property are both set to  NO, the boundary of the 2D node will only be measured
 * the first time the billboardBoundingRect is accessed.
 *
 * You can set this property to YES for dynamic 2D nodes whose boundary changes
 * frequently or unpredicatably.
 *
 * You should exercise caution in deciding to set this property to YES.
 * The billboardBoundingRect property is accessed at least once per rendering frame
 * during node culling, and the cost of re-measuring the boundary of some types of
 * 2D nodes can be quite high. In particular, measuring the boundary of a particle
 * system involves iterating though every particle vertex.
 *
 * For 2D nodes whose boundary is expensive to measure, consider leaving this property
 * set to NO, and either pre-calculating the maximum value of the billboardBoundingRect,
 * and setting it explicitly, or using the resetBillboardBoundingRect method to measure
 * the boundary of the 2D node only when necessary.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldAlwaysMeasureBillboardBoundingRect;

/**
 * If the value of this property is set to YES, the boundary of the 2D node will be
 * measured each time the billboardBoundingRect property is accessed, and the resulting
 * value will be accumulated in the billboardBoundingRect property so that the resulting
 * value of the billboardBoundingRect property will be an ever-growing rectangle that
 * covers all areas covered by the 2D node since initialization of this node, or since
 * the resetBillboardBoundingRect method was last invoked.
 *
 * If the values of this property and the shouldAlwaysMeasureBillboardBoundingRect
 * property are both set to  NO, the boundary of the 2D node will only be measured
 * the first time the billboardBoundingRect is accessed.
 *
 * This property can be useful when pre-computing an appropriate fixed boundary for a
 * dynamic 2D node such as a particle system, and is often used at development time.
 * The resulting accumulated boundary can then be explicitly set into the
 * billboardBoundingRect property (with both this property and the
 * shouldAlwaysMeasureBillboardBoundingRect property set to NO) so that the cost of
 * measuring the 2D boundary is not incurred during each rendering frame at runtime.
 * 
 * If a truly dynamic boundary is required at runtime, there is no advantage to using
 * this property instead of the shouldAlwaysMeasureBillboardBoundingRect property.
 * The performance cost is the same, and the resulting boundary will be less accurate.
 *
 * The initial value of this property is NO.
 */
@property(nonatomic, assign) BOOL shouldMaximizeBillboardBoundingRect;

/**
 * The distance from the camera, in 3D space, at which the 2D artifact will be
 * displayed at unity scale (its natural size). This effect this property has
 * depends on the value of the shouldDrawAs2DOverlay property.
 *
 * If the value of the shouldDrawAs2DOverlay property is NO, the 2D node is embedded
 * in the 3D world. As such, like all other nodes, the size of the 2D node
 * automatically changes as this node moves closer to or farther away from the camera.
 * As such, this property has no effect on the size of the 2D node, and is used only
 * as a reference when calculating the effect of the minimumBillboardScale and
 * maximumBillboardScale properties.
 *
 * If the value of the shouldDrawAs2DOverlay property is YES, the 2D node is overlaid
 * on the 3D world. As such, if this node is closer to the camera than the distance
 * value of this property, the 2D artifact will be scaled up proportionally.
 * If this node is farther from the camera than this distance, the 2D artifact
 * will be scaled down proportionally.
 *
 * If the value of this property is zero, the camera's near clip plane distance
 * will be used as the unity scale distance.
 *
 * The initial value of this property is zero.
 */
@property(nonatomic, assign) GLfloat unityScaleDistance;

/**
 * The minimum scale to which the 2D node will be allowed to shrink as it moves
 * away from the camera.
 *
 * Setting this property to a non-zero value will stop the 2D node from shrinking
 * away to nothing as the 3D object recedes far from the camera. For example, you
 * may want to keep a name label or speech-balloon readable, even if the character
 * it is attached to is far from the camera.
 *
 * The value of this property is relative to the unityScaleDistance. The 2D node
 * will not shrink to a size smaller than its size at the unity distance multiplied
 * by the value of this property. For example, if this property is set to 0.5, the
 * 2D node will not shrink to less than one-half the size it appears when at the
 * unityScaleDistance.
 *
 * If this property is zero, no minimum will be applied. If this property is non-zero
 * and is equal to the maximumBillboardScale, the 2D node will always be displayed at
 * that single scale, regardless of how near or far this node is from the camera. 
 *
 * It is possible to specify different scales for each of the X and Y dimensions,
 * if such behaviour makes sense.
 */
@property(nonatomic, assign) CGPoint minimumBillboardScale;

/**
 * The maximum scale to which the 2D node will be allowed to grow as it approaches
 * the camera.
 *
 * Setting this property to a non-zero value will stop the 2D node from growing
 * too large as the 3D object approaches the camera. For example, you may want to
 * keep a name label or speech-balloon at a readable text size, even if the character
 * it is attached to is right in front of the camera.
 *
 * The value of this property is relative to the unityScaleDistance. The 2D node will
 * not grow to a size larger than its size at the unity distance multiplied by the
 * value of this property. For example, if this property is set to 2.0, the 2D node
 * will not grow to more than twice the size it appears when at the unityScaleDistance.
 *
 * If this property is zero, no maximum will be applied. If this property is non-zero
 * and is equal to the minimumBillboardScale, the 2D node will always be displayed at
 * that single scale, regardless of how near or far this node is from the camera. 
 *
 * It is possible to specify different scales for each of the X and Y dimensions,
 * if such behaviour makes sense.
 */
@property(nonatomic, assign) CGPoint maximumBillboardScale;

/**
 * An offset, measured in 2D display points, at which the 2D node should be positioned
 * relative to the 2D projectedPosition of this node. The initial value is {0, 0}.
 * This property can be useful in helping to center or positionally justify the 2D
 * artifact.
 *
 * This property only has effect when the shouldDrawAs2DOverlay property is set to YES,
 * indicating that the 2D node is being drawn as a 2D overlay to the 3D world.
 */
@property(nonatomic, assign) CGPoint offsetPosition;

/**
 * Indicates whether the size of the 2D billboard node should be adjusted so that
 * its size relative to the 3D artifacts appears to be the same across all devices.
 *
 * The 3D camera frustum is consistent across all devices, making the view of the 3D
 * scene consistent across all devices. The result is that on devices with larger
 * screen resolutions, the 2D overlay node will be drawn across more pixels, and may
 * appear visually larger. 
 * 
 * If this property is set to YES, the scale of the 2D overlay node will be adjusted so
 * that it appears to be the same size across all devices, relative to the 3D nodes.
 *
 * If this property is set to NO, the 2D overlay node will be drawn in the same absolute
 * pixel size across all devices, which may make it appear to be smaller or larger,
 * relative to the 3D artifacts around it, on different devices.
 *
 * This property has different effects, depending on the value of the shouldDrawAs2DOverlay
 * property. If that property is set to YES, and the 2D node is being drawn as an overlay
 * over the entire 3D scene, all 2D nodes will be adjusted.
 *
 * However, if the shouldDrawAs2DOverlay property is set to NO, indicating that the 2D
 * node is embedded in the 3D world, the 2D node will be scaled by the value of the
 * billboardContentScaleFactor property of the 2D node. Most 2D nodes do not require
 * scaling adjustment when being drawn embedded in the 3D world and will return 1.0
 * for this property. However, some 2D nodes, such as text labels and particle systems
 * actively compensate for the screen resolution when drawing to a retina screen,
 * and do need to be adjusted.
 *
 * The initial value of this property is YES.
 */
@property(nonatomic, assign) BOOL shouldNormalizeScaleToDevice;

/**
 * The index of the GL texture unit to use when drawing the 2D CCNode.
 *
 * The initial value of this property is zero. cocos2d uses texture unit zero by
 * default, and in most cases it is recommended that you use this initial value.
 *
 * The value of this property must be between zero and one less than the maximum number
 * of supported texture units. The maximum number of texture units is platform dependent,
 * and can be read from [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 */
@property(nonatomic, assign) GLuint textureUnitIndex;

/**
 * The scaling factor used to adjust the scale of the 2D overlay node so that it's size
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
 * Invoked automatically by the CC3World to configure the 2D node relative to
 * the location of the camera, including ensuring the correct perspective.
 *
 * If the value of the shouldDrawAs2DOverlay property is NO, the 2D node is embedded
 * in the 3D world. As such, the 2D node will naturally be drawn with the correct
 * perspective projection, but invoking this method enforces the sizing restrictions
 * specified in the minimumBillboardScale and maximumBillboardScale properties.
 *
 * If the value of the shouldDrawAs2DOverlay property is YES, the 2D node is overlaid
 * on the 3D world at a 2D position determined by projecting the location of the node
 * onto the camera view. This position is cached in the projectedPosition property
 * of this node.
 *
 * In addition, with the shouldDrawAs2DOverlay property set to YES, since the 2D node
 * is drawn over the whole 3D world, As such, the 2D node will not have natural
 * perspective projection. To mimic perspetive sizing, this method scales the 2D node
 * according to the distance between this node and the camera, relative to a scale of
 * one at the unityScaleDistance, taking into consideration the sizing restrictions
 * specified in the minimumBillboardScale and maximumBillboardScale properties.
 * 
 * This method is invoked automatically by CC3World. Usually, the application never
 * needs to invoke this method directly.
 */
-(void) alignToCamera: (CC3Camera*) camera;


#pragma mark Drawing

/**
 * If the value of the shouldDrawAs2DOverlay property is YES, and the 2D node is
 * within the given bounds, draws the 2D node at the projected 2D position calculated
 * in the alignToCamera: method.
 *
 * This method is invoked automatically by CC3World at the end of each frame drawing
 * cycle. Usually, the application never needs to invoke this method directly.
 */
-(void) draw2dWithinBounds: (CGRect) bounds;

/**
 * Returns whether the local content of this node intersects the given bounding rectangle.
 * This check does not include checking children, only the local content.
 *
 * If the value of the shouldDrawAs2DOverlay property is YES, this method is invoked during
 * the drawing operations of each frame to determine whether this node should be culled
 * from the visible nodes and not drawn. A return value of YES will cause the node to be
 * drawn, a return value of NO will cause the node to be culled and not drawn.
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
#pragma mark CC3BillboardBoundingBoxArea interface

/**
 * A CC3NodeBoundingArea, used exclusively with CC3Billboards, that uses the
 * billboardBoundingRect property of the CC3Billboard as the bounding area, and checks
 * the bounding area against a given bounding box (typically from the CC3Layer), using
 * the doesIntersectBounds: method.
 */
@interface CC3BillboardBoundingBoxArea : CC3NodeBoundingArea {
	CC3Vector globalBoundingRectVertices[4];
}

/**
 * An array of the four vertices of the bounding rectangle, in the global coordinate
 * system, after the bounding rectangle has been transformed (translated, rotated and
 * scaled) to match the transformation of the node. For a node to be definitively
 * outside the frustum, all four vertices of the global bounding box must be outside
 * each of the planes of the frustum.
 *
 * This property is used only when the value of the shouldDrawAs2DOverlay property
 * of the CC3Bllboard is NO, and the 2D node is embedded in the 3D world.
 */
@property(nonatomic, readonly) CC3Vector* globalBoundingRectVertices;

@end


#pragma mark -
#pragma mark CC3ParticleSystemBillboard

/**
 * A CC3Billboard node customized to display and manage a cocos2d 2D CCParticleSystem.
 *
 * This specialized subclass adds some specific features to aid with drawing particle
 * systems, including:
 *   - Setting the particle size attenuation before drawing.
 *   - If the CCParticleSystem has a finite duration and its autoRemoveOnFinish property
 *     is set to YES, the CC3ParticleSystemBillboard node is automatically removed from
 *     its parent once the particle system has finished emitting.
 *   - In cocos2d, particle systems draw all particles at the same Z-distance.
 *     When undergoing transforms in the 3D world, the result is that the Z-distances
 *     are very close but not equal, resulting in Z-fighting between the particles.
 *     To avoid this, if the shouldDisableDepthMask property is set to YES, the GL depth
 *     mask is temporarily disabled during drawing so that particles will not update the
 *     depth buffer, meaning that the Z-distance of each particle will be compared against
 *     previously drawn objects, but not against each other. For CC3Billboard, the default
 *     value of the shouldDisableDepthMask is YES, indicating that the GL depth mask will
 *     be disabled during the drawing of the particles.
 */
@interface CC3ParticleSystemBillboard : CC3Billboard {
	CC3AttenuationCoefficients particleSizeAttenuationCoefficients;
}

/**
 * The coefficients of the attenuation function that affects the size of a particle
 * based on its distance from the camera. The sizes of the particles are attenuated
 * according to the formula 1/sqrt(a + b * r + c * r * r), where r is the radial
 * distance from the particle to the camera, and a, b and c are the coefficients
 * from this property.
 *
 * The initial value of this property is kCC3ParticleSizeAttenuationNone,
 * indicating no attenuation with distance.
 */
@property(nonatomic, assign) CC3AttenuationCoefficients particleSizeAttenuationCoefficients;

@end


#pragma mark -
#pragma mark CC3NodeDescriptor

/**
 * CC3NodeDescriptor is a type of CC3Billboard specialized for attaching a descriptive
 * text label to another node. A CC3NodeDescriptor is typically added as a child node
 * to the node whose description is to be displayed.
 *
 * Since we don't want to add descriptor labels or wireframe boxes to
 * descriptor nodes, the shouldDrawDescriptor, shouldDrawWireframeBox,
 * and shouldDrawLocalContentWireframeBox properties are overridden to
 * do nothing when set, and to always return YES.
 *
 * Similarly, CC3NodeDescriptor node does not participate in calculating the
 * bounding box of the node whose bounding box it is drawing, since, as a child
 * of that node, it would interfere with accurate measurement of the bounding box.
 *
 * The shouldIncludeInDeepCopy property returns NO, so that the CC3NodeDescriptor
 * will not be copied when the parent node is copied. A descriptor node for the copy
 * will be created automatically when the shouldDrawDescriptor property is copied,
 * if it was set to YES on the original node that is copied.
 * 
 * A CC3NodeDescriptor will continue to be visible even when its ancestor
 * nodes are invisible, unless the CC3NodeDescriptor itself is made invisible.
 */
@interface CC3NodeDescriptor : CC3Billboard
@end


#pragma mark -
#pragma mark CCNode extension

/** CCNode extension to support embedding 2D CCNodes in the 3D world. */
@interface CCNode (CC3Billboard)

/**
 * Returns a scaling factor to be applied to this node when it is set as the
 * 2D billboard in a CC3Billboard.
 *
 * The default value is 1.0, indicating no scaling will occur.
 * Subclasses will override where necessary.
 */
@property(nonatomic, readonly) CGFloat billboard3DContentScaleFactor;

/**
 * Returns the bounding box of this node in pixels, measuring it if necessary.
 *
 * The default behaviour for CCNode is simply to return the value of the
 * boundingBoxInPixels property. However, some subclasses, notably CCParticleSystem
 * and its subclasses, do not maintain a fixed bounding box boundary, and it must
 * be measured directly from the particle vertices. Such subclasses will override
 * this method to return a value different than the value in the boundingBoxInPixels
 * property.
 *
 * When overriding this method for a subclass, it is understood that the execution
 * of this method may be computationally expensive. It is not the responsibility
 * of this method to cache the returned value, or otherwise attempt to short-circuit
 * the calculation. That is handled in the CC3Billboard.
 */
-(CGRect) measureBoundingBoxInPixels;

@end


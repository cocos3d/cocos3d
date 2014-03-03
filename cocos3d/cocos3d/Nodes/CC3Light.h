/*
 * CC3Light.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Node.h"
#import "CC3MeshNode.h"

@protocol CC3ShadowProtocol;
@class CC3ShadowCastingVolume, CC3CameraShadowVolume, CC3StencilledShadowPainterNode;

/** Constant indicating that the light is not directional. */
static const GLfloat kCC3SpotCutoffNone = 180.0f;

/** Default ambient light color. */
static const ccColor4F kCC3DefaultLightColorAmbient = { 0.0, 0.0, 0.0, 1.0 };

/** Default diffuse light color. */
static const ccColor4F kCC3DefaultLightColorDiffuse = { 1.0, 1.0, 1.0, 1.0 };

/** Default specular light color. */
static const ccColor4F kCC3DefaultLightColorSpecular = { 1.0, 1.0, 1.0, 1.0 };

/** Default light attenuation coefficients */
static const CC3AttenuationCoefficients kCC3DefaultLightAttenuationCoefficients = {1.0, 0.0, 0.0};

#pragma mark -
#pragma mark CC3Light

/**
 * CC3Light represents the light in the 3D scene.
 *
 * CC3Light is a type of CC3Node, and can therefore participate in a structural node
 * assembly. An instance can be the child of another node, and the light itself can
 * have child nodes. For example, a light can be mounted on a boom object or camera,
 * and will move along with the parent node.
 *
 * CC3Light can be pointed so that it shines in a particular direction, or can be
 * made to track a target node as that node moves.
 *
 * To turn a CC3Light on or off, set the visible property.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 *
 * Lights in different scenes (different instances of CC3Scene) can have the same
 * GL lightIndex value. Applications that make use of multiple CC3Scenes, either as
 * a sequence of scenes, or as multiple scenes (and multiple CC3Layers) displayed
 * on the screen at once, can reuse a light index across the scenes.
 * The shouldCopyLightIndex property can be used to help copy lights across scenes.
 *
 * If the application uses lights in the 2D scene as well, the indexes of those lights
 * can be reserved by invoking the class method setLightPoolStartIndex:. Light indexes
 * reserved for use by the 2D scene will not be used by the 3D scene.
 */
@interface CC3Light : CC3Node {
	CC3ShadowCastingVolume* _shadowCastingVolume;
	CC3CameraShadowVolume* _cameraShadowVolume;
	CC3StencilledShadowPainterNode* _stencilledShadowPainter;
	NSMutableArray* _shadows;
	ccColor4F _ambientColor;
	ccColor4F _diffuseColor;
	ccColor4F _specularColor;
	CC3AttenuationCoefficients _attenuation;
	GLfloat _spotExponent;
	GLfloat _spotCutoffAngle;
	GLfloat _shadowIntensityFactor;
	GLuint _lightIndex;
	BOOL _isDirectionalOnly : 1;
	BOOL _shouldCopyLightIndex : 1;
	BOOL _shouldCastShadowsWhenInvisible : 1;
}

/** Returns whether this node is a light. Returns YES. */
@property(nonatomic, readonly) BOOL isLight;

/**
 * The index of this light to identify it to the GL engine. This is automatically assigned
 * during instance initialization. The value of lightIndex will be between zero and one 
 * less than the maximium number of available lights, inclusive.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
@property(nonatomic, readonly) GLuint lightIndex;

/** The ambient color of this light. Initially set to kCC3DefaultLightColorAmbient. */
@property(nonatomic, assign) ccColor4F ambientColor;

/** The diffuse color of this light. Initially set to kCC3DefaultLightColorDiffuse. */
@property(nonatomic, assign) ccColor4F diffuseColor;

/** The specular color of this light. Initially set to kCC3DefaultLightColorSpecular. */
@property(nonatomic, assign) ccColor4F specularColor;

/**
 * Indicates whether this light is directional and without a specified location.
 * Directional-only light is good for modeling sunlight, or other flat overhead
 * lighting. Positional lighting is good for point-source lights like a single
 * bulb, flare, etc.
 *
 * The value of this property impacts features like attenuation, and the angle
 * of reflection to the user view. A directional-only light is not subject to
 * attenuation over distance, where an absolutely located light is. In addition,
 * directional-only light bounces off a flat surface at a single angle, whereas
 * the angle for a point-source light also depends on the location of the camera.
 *
 * The value of this property also impacts performance. Because positional light
 * involves significantly more calculations within the GL engine, setting this
 * property to YES (the initial value) will improve lighting performance.
 * You should only set this property to NO if you need to make use of the
 * positional features described above.
 *
 * The initial value is YES, indicating directional-only lighting.
 */
@property(nonatomic, assign) BOOL isDirectionalOnly;

/**
 * The position of this light in a global 4D homogeneous coordinate space.
 *
 * The X, Y & Z components of the returned 4D vector are the same as those in the globalLocation
 * property. The W-component will be zero if the isDirectionalOnly property is set to YES, indicating
 * that this position represents a direction. The W-component will be one if the isDirectionalOnly
 * property is set to NO, indicating that this position represents a specific location.
 */
@property(nonatomic, readonly) CC3Vector4 globalHomogeneousPosition;

/**
 * Indicates the intensity distribution of the light.
 *
 * Effective light intensity is attenuated by the cosine of the angle between the
 * direction of the light and the direction from the light to the vertex being lighted,
 * raised to the power of the value of this property. Thus, higher spot exponents result
 * in a more focused light source, regardless of the value of the spotCutoffAngle property.
 *
 * The value of this property must be in the range [0, 128], and is clamped to that
 * range if an attempt is made to set the value outside this range.
 *
 * The initial value of this property is zero, indicating a uniform light distribution.
 */
@property(nonatomic, assign) GLfloat spotExponent;

/**
 * Indicates the angle, in degrees, of dispersion of the light from the direction of the light.
 * Setting this value to any angle between zero and 90 degrees, inclusive, will cause this light
 * to be treated as a spotlight whose direction is set by the forwardDirection property of this
 * light, and whose angle of dispersion is controlled by this property. Setting this property to
 * any value above 90 degrees will cause this light to be treated as an omnidirectional light.
 *
 * This property is initially set to kCC3SpotCutoffNone (180 degrees).
 */
@property(nonatomic, assign) GLfloat spotCutoffAngle;

/**
 * The coefficients of the attenuation function that reduces the intensity of the light
 * based on the distance from the light source. The intensity of the light is attenuated
 * according to the formula 1/sqrt(a + b * r + c * r * r), where r is the radial distance
 * from the light source, and a, b and c are the coefficients from this property.
 *
 * The initial value of this property is kCC3DefaultLightAttenuationCoefficients.
 */
@property(nonatomic, assign) CC3AttenuationCoefficients attenuation;

/** @deprecated Property renamed to attenuation */
@property(nonatomic, assign) CC3AttenuationCoefficients attenuationCoefficients DEPRECATED_ATTRIBUTE;

/**
 * When a copy is made of this node, indicates whether this node should copy the value
 * of the lightIndex property to the new node when performing a copy of this node.
 *
 * The initial value of this property is NO.
 *
 * When this property is set to NO, and this light node is copied, the new copy will
 * be assigned its own lightIndex, to identify it to the GL engine. This allows both
 * lights to illuminate the same scene (instance of CC3Scene), and is the most common
 * mechanism for assigning the lightIndex property.
 *
 * OpenGL ES limits the number of lights available to illuminate a single scene.
 * Once that limit is reached, additional lights cannot be created, and attempting
 * to copy this node will fail, returning a nil node.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 *
 * When this property is set to YES, and this light node is copied, the new copy will
 * be assigned the same lightIndex as this node. This means that the copy may not be
 * used in the same scene as the original light, but it may be used in another scene
 * (another CC3Scene instance).
 *
 * Applications that make use of multiple CC3Scenes, either as a sequence of scenes,
 * or as multiple scenes (and multiple CC3Layers) displayed on the screen at once,
 * can set this property to YES when making copies of a light to be placed in
 * different CC3Scene instances.
 */
@property(nonatomic, assign) BOOL shouldCopyLightIndex;

/**
 * The direction in which this light is pointing, relative to the coordinate
 * system of this light, which is relative to the parent's rotation.
 *
 * The initial value of this property is kCC3VectorUnitZNegative, pointing
 * down the negative Z-axis in the local coordinate system of this light.
 * When this light is rotated, the original negative-Z axis of the camera's
 * local coordinate system will point in this direction.
 *
 * This orientation is opposite that for most other nodes, whose forwardDirection
 * property orients the positve Z-axis of the node's coordinate system in
 * the stated direction. This arrangement allows unrotated nodes to face the
 * light in a natural stance, and allows the unrotated light to face the nodes.
 *
 * See further notes in the notes for this property in the CC3Node class.
 */
@property(nonatomic, assign) CC3Vector forwardDirection;


#pragma mark Allocation and initialization

/**
 * Initializes this unnamed instance with an automatically generated unique tag value.
 * The tag value will be generated automatically via the method nextTag.
 *
 * The lightIndex property will be set to the next available GL light index.
 * This method will return nil if all GL light indexes have been consumed.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
-(id) init;

/**
 * Initializes this unnamed instance with the specified tag.
 *
 * The lightIndex property will be set to the next available GL light index.
 * This method will return nil if all GL light indexes have been consumed.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
-(id) initWithTag: (GLuint) aTag;

/**
 * Initializes this instance with the specified name and an automatically generated unique
 * tag value. The tag value will be generated automatically via the method nextTag.
 *
 * The lightIndex property will be set to the next available GL light index.
 * This method will return nil if all GL light indexes have been consumed.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
-(id) initWithName: (NSString*) aName;

/**
 * Initializes this instance with the specified tag and name.
 *
 * The lightIndex property will be set to the next available GL light index.
 * This method will return nil if all GL light indexes have been consumed.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName;

/**
 * Initializes this unnamed instance with the specified GL light index, and an
 * automatically generated unique tag value. The tag value will be generated
 * automatically via the method nextTag.
 *
 * If multiple lights are used to illumniate a scene (a CC3Scene instance),
 * each light must have its own GL light index. Do not assign the same light
 * index to more than one light in a scene.
 *
 * This method will return nil if the specified light index is not less than the
 * maximum number of lights available.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
-(id) initWithLightIndex: (GLuint) ltIndx;

/**
 * Initializes this unnamed instance with the specified GL light index, and the
 * specified tag.
 *
 * If multiple lights are used to illumniate a scene (a CC3Scene instance),
 * each light must have its own GL light index. Do not assign the same light
 * index to more than one light in a scene.
 *
 * This method will return nil if the specified light index is not less than the
 * maximum number of lights available.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
-(id) initWithTag: (GLuint) aTag withLightIndex: (GLuint) ltIndx;

/**
 * Initializes this instance with the specified GL light index, the specified name,
 * and an automatically generated unique tag value. The tag value will be generated
 * automatically via the method nextTag.
 *
 * If multiple lights are used to illumniate a scene (a CC3Scene instance),
 * each light must have its own GL light index. Do not assign the same light
 * index to more than one light in a scene.
 *
 * This method will return nil if the specified light index is not less than the
 * maximum number of lights available.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
-(id) initWithName: (NSString*) aName withLightIndex: (GLuint) ltIndx;

/**
 * Initializes this instance with the specified GL light index, the specified name,
 * and the specified tag.
 *
 * If multiple lights are used to illumniate a scene (a CC3Scene instance),
 * each light must have its own GL light index. Do not assign the same light
 * index to more than one light in a scene.
 *
 * This method will return nil if the specified light index is not less than the
 * maximum number of lights available.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName withLightIndex: (GLuint) ltIndx;

/**
 * Allocates and initializes an autoreleased unnamed instance with the specified
 * GL light index, and an automatically generated unique tag value. The tag value
 * will be generated automatically via the method nextTag.
 *
 * If multiple lights are used to illumniate a scene (a CC3Scene instance),
 * each light must have its own GL light index. Do not assign the same light
 * index to more than one light in a scene.
 *
 * This method will return nil if the specified light index is not less than the
 * maximum number of lights available.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
+(id) lightWithLightIndex: (GLuint) ltIndx;

/**
 * Allocates and initializes an autoreleased unnamed instance with the specified
 * GL light index, and the specified tag.
 *
 * If multiple lights are used to illumniate a scene (a CC3Scene instance),
 * each light must have its own GL light index. Do not assign the same light
 * index to more than one light in a scene.
 *
 * This method will return nil if the specified light index is not less than the
 * maximum number of lights available.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
+(id) lightWithTag: (GLuint) aTag withLightIndex: (GLuint) ltIndx;

/**
 * Allocates and initializes an autoreleased instance with the specified GL light
 * index, the specified name, and an automatically generated unique tag value.
 * The tag value will be generated automatically via the method nextTag.
 *
 * If multiple lights are used to illumniate a scene (a CC3Scene instance),
 * each light must have its own GL light index. Do not assign the same light
 * index to more than one light in a scene.
 *
 * This method will return nil if the specified light index is not less than the
 * maximum number of lights available.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
+(id) lightWithName: (NSString*) aName withLightIndex: (GLuint) ltIndx;

/**
 * Allocates and initializes an autoreleased instance with the specified GL light
 * index, the specified name, and the specified tag.
 *
 * If multiple lights are used to illumniate a scene (a CC3Scene instance),
 * each light must have its own GL light index. Do not assign the same light
 * index to more than one light in a scene.
 *
 * This method will return nil if the specified light index is not less than the
 * maximum number of lights available.
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
+(id) lightWithTag: (GLuint) aTag withName: (NSString*) aName withLightIndex: (GLuint) ltIndx;


#pragma mark Shadows

/**
 * Indicates whether this light should cast shadows even when invisible.
 *
 * Normally, when a light is turned off, any shadows cast by that light should
 * disappear as well. However, there are certain lighting situations where you
 * might want a light to cast shadows, even when turned off, such as using one
 * light to accent the shadows cast by another light that has different ambient
 * or diffuse lighting characteristics.
 *
 * The initial value of this propety is NO.
 *
 * Setting this value sets the same property on any descendant mesh and light nodes.
 */
@property(nonatomic, assign) BOOL shouldCastShadowsWhenInvisible;

/**
 * The shadows cast by this light.
 *
 * If this light is casting no shadows, this property will be nil.
 */
@property(nonatomic, retain, readonly) NSArray* shadows;

/**
 * Adds a shadow to the shadows cast by this light.
 *
 * This method is invoked automatically when a shadow is added to a mesh node.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) addShadow: (id<CC3ShadowProtocol>) shadowNode;

/** Removes a shadow from the shadows cast by this light. */
-(void) removeShadow: (id<CC3ShadowProtocol>) shadowNode;

/**
 * Returns whether this light is casting shadows.
 *
 * It is if any shadows have been added and not yet removed.
 */
@property(nonatomic, readonly) BOOL hasShadows;

/** Update the shadows that are cast by this light. */
-(void) updateShadows;

/** Draws any shadows cast by this light. */
-(void) drawShadowsWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * A specialized bounding volume that encloses a volume that includes the camera
 * frustum plus the space between the camera frustum and this light.
 *
 * Nodes that intersect this volume will cast a shadow from this light into the
 * camera frustum, and that shadow will be visible. Shadows cast by nodes outside
 * this volume will not intersect the frustum and will not be visible.
 *
 * This volume is used to cull the updating and drawing of shadows that will not
 * be visible, to enhance performance.
 *
 * If not set directly, this property is lazily created when a shadow is added.
 * If no shadow has been added, this property will return nil.
 */
@property(nonatomic, retain) CC3ShadowCastingVolume* shadowCastingVolume;

/**
 * A specialized bounding volume that encloses a pyramidal volume between the
 * view plane (near clipping plane) of the camera, and this light.
 *
 * Nodes that intersect this volume will cast a shadow from that light across
 * the camera. The shadow volume of nodes that cast a shadow across the camera
 * view plane are rendered differently than shadow volumes for nodes that do
 * not cast their shadow across the camera.
 *
 * If not set directly, this property is lazily created when a shadow is added.
 * If no shadow has been added, this property will return nil.
 */
@property(nonatomic, retain) CC3CameraShadowVolume* cameraShadowVolume;

/**
 * The mesh node used to draw the shadows cast by any shadow volumes that have
 * been added to mesh nodes for this light.
 *
 * Shadow volumes are used to define a stencil that is then used to draw dark
 * areas onto the viewport where mesh nodes are casting shadows. This painter
 * is used to draw those dark areas where the stencil indicates.
 *
 * If not set directly, this property is lazily created when a shadow is added.
 * If no shadow has been added, this property will return nil.
 */
@property(nonatomic, retain) CC3StencilledShadowPainterNode* stencilledShadowPainter;

/**
 * This property is used to adjust the shadow intensity as calculated when the 
 * updateRelativeIntensityFrom: method is invoked. This property increases flexibility
 * by allowing the shadow intensity to be ajusted relative to that calculated value to
 * improve realisim.
 *
 * The intensity of shadows cast by this light is calculated by comparing the intensity of
 * the diffuse component of this light against the total ambient and diffuse illumination
 * from all lights, to get a measure of the fraction of total scene illumination that is
 * contributed by this light.
 *
 * Using this technique, the presence of multiple lights, or strong ambient light, will
 * serve to lighten the shadows cast by any single light. A single light with no ambient
 * light will cast completely opaque, black shadows.
 *
 * That fraction, representing the fraction of overall light coming from this light, is
 * then multiplied by the value of this property to determine the intensity (opacity) of
 * the shadows cast by this light.
 *
 * This property must be zero or a positive value. A value between zero and one will serve
 * to to lighten the shadow, relative to the shadow intensity (opacity) calculated from the
 * relative intensity of this light, and a value of greater than one will serve to darken
 * the shadow, relative to that calculated intensity.
 *
 * The initial value of this property is one, meaning that the shadow intensity
 * calculated from the relative intensity of this light will be used without adjustment.
 */
@property(nonatomic, assign) GLfloat shadowIntensityFactor;

/**
 * Updates the relative intensity of this light, as compared to the specified
 * total scene illumination.
 *
 * Certain characteristics, such as shadow intensities, depend on the relative
 * intensity of this light, relative to the total intensity of all lights in
 * the scene.
 *
 * Sets the intensity of shadows cast by this light by comparing the intensity of
 * the diffuse component of this light against the total ambient and diffuse
 * illumination from all lights, to get a measure of the fraction of total scene
 * illumination that is contributed by this light.
 *
 * Using this technique, the presence of multiple lights, or strong ambient light,
 * will serve to lighten the shadows cast by any single light. A single light with
 * no ambient light will cast completely black opaque shadows.
 *
 * That calculated fraction is then multiplied by the value of the shadowIntensityFactor
 * property to determine the intensity (opacity) of the shadows cast by this light.
 * The shadowIntensityFactor increases flexibility by allowing the shadow intensity
 * to be adjusted relative to the calculated value to improve realisim.
 *
 * This method is invoked automatically when any of the the ambientColor, diffuseColor,
 * visible, or shadowIntensityFactor properties of any light in the scene is changed,
 * or if the ambientLight property of the CC3Scene is changed.
 */
-(void) updateRelativeIntensityFrom: (ccColor4F) totalLight;


#pragma mark Drawing

/**
 * If this light is visible, turns it on by enabling this light in the GL engine,
 * and then applies the properties of this light to the GL engine.
 *
 * This method is invoked automatically by CC3Scene near the beginning of each frame
 * drawing cycle. Usually, the application never needs to invoke this method directly.
 */
-(void) turnOnWithVisitor: (CC3NodeDrawingVisitor*) visitor;

/**
 * Turns this light off on by disabling this light in the GL engine.
 *
 * This method is invoked automatically by CC3Scene at the end of each frame drawing cycle.
 * Usually, the application never needs to invoke this method directly.
 */
-(void) turnOffWithVisitor: (CC3NodeDrawingVisitor*) visitor;


#pragma mark Managing the pool of available GL lights

/**
 * Returns the number of lights that have already been instantiated (and not yet deallocated).
 *
 * The maximum number of lights available is determined by the platform. That number can be retrieved
 * from the CC3OpenGL.sharedGL.maxNumberOfLights property. All platforms support at least eight lights.
 */
+(GLuint) lightCount;

/**
 * Indicates the smallest index number to assign to a 3D light.
 * 
 * See the description of the setLightPoolStartIndex: method for more information on this value.
 */
+(GLuint) lightPoolStartIndex;

/**
 * Sets the smallest index number to assign to a 3D light. This value should be between
 * zero inclusive and CC3OpenGL.sharedGL.maxNumberOfLights exclusive.
 *
 * If the 2D scene uses lights, setting this value to a number above zero will reserve
 * the indexes below this number for the 2D scene and those indexes will not be used in
 * lights in the 3D scene.
 * 
 * This value defaults to zero. If your application requires light indexes to be reserved
 * and not assigned in the 3D scene, set this value.
 */
+(void) setLightPoolStartIndex: (GLuint) newStartIndex;

/**
 * Disables the lights that were reserved for the 2D scene by setLightPoolStartIndex:.
 *
 * This method is invoked automatically by CC3Scene near the beginning of each frame
 * drawing cycle. Usually, the application never needs to invoke this method directly.
 */
+(void) disableReservedLightsWithVisitor: (CC3NodeDrawingVisitor*) visitor;

@end


#pragma mark -
#pragma mark CC3ShadowProtocol

/**
 * The behaviour required by objects that represent shadows cast by a light.
 *
 * CAUTION: The signature of this protocol may evolve as additional shadowing
 *          techniques are introduced.
 */
@protocol CC3ShadowProtocol <CC3NodeTransformListenerProtocol>

/** The light casting this shadow. */
@property(nonatomic, assign) CC3Light* light;

/**
 * Updates the shape and location of the shadow.
 *
 * This is invoked automatically by the light during each update frame
 * to udpate the shape and location of the shadow.
 */
-(void) updateShadow;

@end


#pragma mark -
#pragma mark CC3LightCameraBridgeVolume

/**
 * A bounding volume that encloses a volume between a light and all or part of
 * the frustum of the camera. This is an abstract class. Subclasses will define
 * the actual appropriate bounding volume.
 *
 * As a bounding volume, this class supports methods for testing whether
 * locations, rays, shapes, and other bounding volumes intersect its volume.
 */
@interface CC3LightCameraBridgeVolume : CC3BoundingVolume <CC3NodeTransformListenerProtocol> {
	CC3Light* _light;
}

/**
 * Returns the number of vertices in the array returned by the vertices property.
 *
 * The value returned depends on whether the light has a specific location,
 * or is directional. If the light is directional, the location of the light
 * is at infinity, and is not used when comparing the vertices with other
 * bounding volumes.
 *
 * Consequently, if the light has a specific location, that location will be
 * included in the array returned by the vertices property, and the value
 * returned by this property will reflect that. If the light is directional,
 * the light location will not be included in the array returned by the vertices
 * property, and the value returned by this property reflects that, and will be
 * one less than if the light has a specific location.
 */
@property(nonatomic, readonly) GLuint vertexCount;

@end


#pragma mark -
#pragma mark CC3ShadowCastingVolume

/**
 * A bounding volume that encloses a volume that includes the camera frustum plus
 * the space between the camera frustum and a light.
 *
 * Nodes that intersect this volume will cast a shadow from that light into the frustum,
 * and that shadow will be visible. Shadows cast by nodes outside this volume will not
 * intersect the frustum and will not be visible. This volume is used to cull the
 * updating and drawing of shadows, that will not be visible, to improve performance.
 *
 * The number of planes in this bounding volume will be between six and eleven, depending
 * on where the light is located. The number of vertices will be between five and nine.
 *
 * The shadow casting volume is a type of bounding volume and therefore supports methods for
 * testing whether locations, rays, shapes, and other bounding volumes intersect its volume.
 */
@interface CC3ShadowCastingVolume : CC3LightCameraBridgeVolume {
	CC3Plane _planes[11];
	CC3Vector _vertices[9];
	GLuint _planeCount;
	GLuint _vertexCount;
}

@end


#pragma mark -
#pragma mark CC3CameraShadowVolume

/**
 * A bounding volume that encloses a pyramidal volume between the view plane
 * (near clipping plane) of the camera, and a light.
 *
 * Nodes that intersect this volume will cast a shadow from that light across the camera.
 * The shadow volume of nodes that cast a shadow across the camera view plane are rendered
 * differently than shadow volumes for nodes that do not cast their shadow across the camera.
 *
 * The camera shadow volume is a type of bounding volume and therefore supports methods for
 * testing whether locations, rays, shapes, and other bounding volumes intersect its volume.
 */
@interface CC3CameraShadowVolume : CC3LightCameraBridgeVolume {
	CC3Plane _planes[6];
	CC3Vector _vertices[5];
}

/** The frustum vertex on the near clipping plane of the camera, at the intersection of the top and left sides. */
@property(nonatomic, readonly) CC3Vector topLeft;

/** The frustum vertex on the near clipping plane of the camera, at the intersection of the top and right sides. */
@property(nonatomic, readonly) CC3Vector topRight;

/** The frustum vertex on the near clipping plane of the camera, at the intersection of the bottom and left sides. */
@property(nonatomic, readonly) CC3Vector bottomLeft;

/** The frustum vertex on the near clipping plane of the camera, at the intersection of the bottom and right sides. */
@property(nonatomic, readonly) CC3Vector bottomRight;

/** The clip plane at the top of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane topPlane;

/** The clip plane at the bottom of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane bottomPlane;

/** The clip plane at the left side of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane leftPlane;

/** The clip plane at the right side of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane rightPlane;

/** The clip plane at the near end of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane nearPlane;

/** The clip plane at the far end of this frustum, in global coordinates. */
@property(nonatomic, readonly) CC3Plane farPlane;

@end


#pragma mark -
#pragma mark CC3Node extension for lights

@interface CC3Node (Lighting)

/** Returns whether this node is a light.
 *
 * This implementation returns NO. Subclasses that are lights will override to return YES.
 */
@property(nonatomic, readonly) BOOL isLight;

@end

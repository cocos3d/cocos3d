/*
 * CC3Light.h
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

#import "CC3TargettingNode.h"
#import "CC3OpenGLES11Lighting.h"

/** Cosntant indicating that the light is not directional. */
static const GLfloat kCC3SpotCutoffNone = 180.0;

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
 * CC3Light represents the light in the 3D world.
 *
 * CC3Light is a type of CC3Node, and can therefore participate in a structural node assembly.
 * An instance can be the child of another node, and the light itself can have child nodes.
 * For example, a light can be mounted on a boom object or camera, and will move along with
 * the parent node.
 *
 * CC3Light is also a type of CC3TargettingNode, and can be pointed so that it shines in a
 * particular direction, or can be made to track a target node as that node moves.
 *
 * To turn a CC3Light on or off, set the visible property.
 *
 * The maximum number of lights available is determined by the platform. That number can
 * be retrieved from [CC3OpenGLES11Engine engine].platform.maxLights.value. All platforms
 * support at least eight lights.
 *
 * If the application uses lights in the 2D world as well, the indexes of those lights can
 * be reserved by invoking the class method setLightPoolStartIndex:. Light indexes reserved
 * for use by the 2D world will not be used by the 3D world.
 */
@interface CC3Light : CC3TargettingNode {
	CC3OpenGLES11Light* gles11Light;
	CC3Vector4 homogeneousLocation;
	ccColor4F ambientColor;
	ccColor4F diffuseColor;
	ccColor4F specularColor;
	CC3AttenuationCoefficients attenuationCoefficients;
	GLfloat spotCutoffAngle;
	GLenum lightIndex;
	BOOL isDirectionalOnly;
 }

/**
 * The index of this light to identify it to the GL engine. This is automatically assigned
 * during instance initialization. The value of lightIndex will be between zero and one 
 * less than the maximium number of available lights, inclusive.
 *
 * The maximum number of lights available is determined by the platform. That number can
 * be retrieved from [CC3OpenGLES11Engine engine].platform.maxLights.value. All platforms
 * support at least eight lights.
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
 * The initial value is YES, indicating directional-only lighting.
 */
@property(nonatomic, assign) BOOL isDirectionalOnly;

/**
 * The location of this light in the 4D homogeneous coordinate space. The x, y and z
 * components of the returned value will be the same as those in the globalLocation
 * property. The w-component will be one if the light is considered to be actually
 * located at the globalLocation property, or zero if the globalLocation property is
 * an indication of the direction the light is coming from, and not an absolute location.
 */
@property(nonatomic, readonly) CC3Vector4 homogeneousLocation;

/**
 * Indicates the angle, in degrees, of dispersion of the light from the direction of the light.
 * Setting this value to any angle below kCC3SpotCutoffNone (180 degrees) will cause this light
 * to be treated as a spotlight whose direction is set by the forwardDirection property of
 * this light, and whose angle of dispersion is controlled by this property. Setting this
 * property to kCC3SpotCutoffNone or above will cause this light to be treated as an
 * omnidirectional light. Initially set to kCC3SpotCutoffNone.
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
@property(nonatomic, assign) CC3AttenuationCoefficients attenuationCoefficients;


#pragma mark Drawing

/**
 * If this light is visible, turns it on by enabling this light in the GL engine,
 * and then applies the properties of this light to the GL engine.
 *
 * This method is invoked automatically by CC3World near the beginning of each frame
 * drawing cycle. Usually, the application never needs to invoke this method directly.
 */
-(void) turnOn;


#pragma mark Managing the pool of available GL lights

/**
 * Returns the number of lights that have already been instantiated (and not yet deallocated).
 *
 * The maximum number of lights available is determined by the platform. That number can
 * be retrieved from [CC3OpenGLES11Engine engine].platform.maxLights.value. All platforms
 * support at least eight lights.
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
 * zero inclusive and [CC3OpenGLES11Engine engine].platform.maxLights.value exclusive.
 *
 * If the 2D world uses lights, setting this value to a number above zero will reserve
 * the indexes below this number for the 2D world and those indexes will not be used in
 * lights in the 3D world.
 * 
 * This value defaults to zero. If your application requires light indexes to be reserved
 * and not assigned in the 3D world, set this value.
 */
+(void) setLightPoolStartIndex: (GLuint) newStartIndex;

/**
 * Disables the lights that were reserved for the 2D world by setLightPoolStartIndex:.
 *
 * This method is invoked automatically by CC3World near the beginning of each frame
 * drawing cycle. Usually, the application never needs to invoke this method directly.
 */
+(void) disableReservedLights;
	
@end

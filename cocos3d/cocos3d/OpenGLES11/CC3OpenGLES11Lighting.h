/*
 * CC3OpenGLES11Lighting.h
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
 */

/** @file */	// Doxygen marker


#import "CC3OpenGLES11Capabilities.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerLightFloat

/**
 * CC3OpenGLES11StateTrackerLightFloat tracks a float GL state value for an
 * individual light. The property lightIndex identifies the particular light
 * for which the state is being tracked.
 *
 * This implementation uses GL function glGetLightfv to read the value from
 * the GL engine, and GL function glLightf to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and
 * will not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerLightFloat : CC3OpenGLES11StateTrackerFloat {
	GLuint lightIndex;
}

/** The index of the light being tracked. */
@property(nonatomic, readonly) GLuint lightIndex;

/** The GL enumeration value GL_LIGHTi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glLightIndex;

/**
 * Initialize this instance to track the GL state with
 * the specified name for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) qName
	   andLightIndex: (GLuint) ltIndx;

/**
 * Allocates and initializes an autoreleased instance to track the GL state with
 * the specified name for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) qName
		  andLightIndex: (GLuint) ltIndx;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerLightColor

/**
 * CC3OpenGLES11StateTrackerLightColor tracks a color GL state value for an
 * individual light. The property lightIndex identifies the particular light
 * for which the state is being tracked.
 *
 * This implementation uses GL function glGetLightfv to read the value from
 * the GL engine, and GL function glLightfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and
 * will not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerLightColor : CC3OpenGLES11StateTrackerColor {
	GLuint lightIndex;
}

/** The index of the light being tracked. */
@property(nonatomic, readonly) GLuint lightIndex;

/** The GL enumeration value GL_LIGHTi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glLightIndex;

/**
 * Initialize this instance to track the GL state with
 * the specified name for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) qName
	   andLightIndex: (GLuint) ltIndx;

/**
 * Allocates and initializes an autoreleased instance to track the GL state with
 * the specified name for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) qName
		  andLightIndex: (GLuint) ltIndx;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerLightVector

/**
 * CC3OpenGLES11StateTrackerLightVector tracks a 3D vector GL state value for
 * an individual light. The property lightIndex identifies the particular light
 * for which the state is being tracked.
 *
 * This implementation uses GL function glGetLightfv to read the value from
 * the GL engine, and GL function glLightfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and
 * will not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerLightVector : CC3OpenGLES11StateTrackerVector {
	GLuint lightIndex;
}

/** The index of the light being tracked. */
@property(nonatomic, readonly) GLuint lightIndex;

/** The GL enumeration value GL_LIGHTi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glLightIndex;

/**
 * Initialize this instance to track the GL state with
 * the specified name for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) qName
	   andLightIndex: (GLuint) ltIndx;

/**
 * Allocates and initializes an autoreleased instance to track the GL state with
 * the specified name for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) qName
		  andLightIndex: (GLuint) ltIndx;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerLightVector4

/**
 * CC3OpenGLES11StateTrackerLightVector4 tracks a 4D vector GL state value for
 * an individual light. The property lightIndex identifies the particular light
 * for which the state is being tracked.
 *
 * This implementation uses GL function glGetLightfv to read the value from
 * the GL engine, and GL function glLightfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and
 * will not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerLightVector4 : CC3OpenGLES11StateTrackerVector4 {
	GLuint lightIndex;
}

/** The index of the light being tracked. */
@property(nonatomic, readonly) GLuint lightIndex;

/** The GL enumeration value GL_LIGHTi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glLightIndex;

/**
 * Initialize this instance to track the GL state with
 * the specified name for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) qName
	   andLightIndex: (GLuint) ltIndx;

/**
 * Allocates and initializes an autoreleased instance to track the GL state with
 * the specified name for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) qName
		  andLightIndex: (GLuint) ltIndx;

@end


#pragma mark -
#pragma mark CC3OpenGLES11Light

/**
 * CC3OpenGLES11Light manages trackers for an individual light. The property
 * lightIndex identifies the particular light for which state is being tracked.
 */
@interface CC3OpenGLES11Light : CC3OpenGLES11StateTrackerManager {
	GLuint lightIndex;
	CC3OpenGLES11StateTrackerServerCapability* light;
	CC3OpenGLES11StateTrackerLightColor* ambientColor;
	CC3OpenGLES11StateTrackerLightColor* diffuseColor;
	CC3OpenGLES11StateTrackerLightColor* specularColor;
	CC3OpenGLES11StateTrackerLightVector4* position;
	CC3OpenGLES11StateTrackerLightVector* spotDirection;
	CC3OpenGLES11StateTrackerLightFloat* spotExponent;
	CC3OpenGLES11StateTrackerLightFloat* spotCutoffAngle;
	CC3OpenGLES11StateTrackerLightFloat* constantAttenuation;
	CC3OpenGLES11StateTrackerLightFloat* linearAttenuation;
	CC3OpenGLES11StateTrackerLightFloat* quadraticAttenuation;
}

/** Tracks the light capability (GL capability name GL_LIGHTi). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerServerCapability* light;

/** Tracks ambient color (GL name GL_AMBIENT). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightColor* ambientColor;

/** Tracks diffuse color (GL name GL_DIFFUSE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightColor* diffuseColor;

/** Tracks specular color (GL name GL_SPECULAR). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightColor* specularColor;

/** Tracks position (GL name GL_POSITION). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightVector4* position;

/** Tracks spot direction (GL name GL_SPOT_DIRECTION). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightVector* spotDirection;

/** Tracks spot cutoff angle (GL name GL_SPOT_EXPONENT). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightFloat* spotExponent;

/** Tracks spot cutoff angle (GL name GL_SPOT_CUTOFF). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightFloat* spotCutoffAngle;

/** Tracks spot cutoff angle (GL name GL_CONSTANT_ATTENUATION). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightFloat* constantAttenuation;

/** Tracks spot cutoff angle (GL name GL_LINEAR_ATTENUATION). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightFloat* linearAttenuation;

/** Tracks spot cutoff angle (GL name GL_QUADRATIC_ATTENUATION). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerLightFloat* quadraticAttenuation;

/**
 * Initializes this instance to track GL state
 * for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
	  withLightIndex: (GLuint) ltIndx;

/**
 * Allocates and initializes an autoreleased instance to track GL state
 * for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
		 withLightIndex: (GLuint) ltIndx;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerSceneLightColor

/**
 * CC3OpenGLES11StateTrackerSceneLightColor tracks the color GL state value
 * for the ambient scene light.
 *
 * This implementation uses GL function glLightModelfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and will
 * not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerSceneLightColor : CC3OpenGLES11StateTrackerColor {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11Lighting

/** CC3OpenGLES11Lighting manages trackers for lighting state. */
@interface CC3OpenGLES11Lighting : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerSceneLightColor* sceneAmbientLight;
	CCArray* lights;
}

/** Tracks scene ambient light color (GL name GL_LIGHT_MODEL_AMBIENT). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerSceneLightColor* sceneAmbientLight;

/**
 * Tracks lighting state for each light (GL capability name GL_LIGHTi).
 *
 * Do not access individual light trackers through this property.
 * Use the lightAt: method instead.
 *
 * The number of available lights is retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 *
 * To conserve memory, lights are lazily allocated when requested by the
 * lightAt: method. The array returned by this property will initially be
 * empty, and will subsequently contain a number of lights one more than
 * the largest value passed to lightAt:.
 */
@property(nonatomic, retain) CCArray* lights;

/**
 * Returns the number of active lights.
 *
 * This value will be between zero and the maximum number of lights, as determined
 * from [CC3OpenGLES11Engine engine].platform.maxLights.value.
 *
 * To conserve memory, lights are lazily allocated when requested by the
 * lightAt: method. The value of this property will initially be zero, and
 * will subsequently be one more than the largest value passed to lightAt:.
 */
@property(nonatomic, readonly) GLuint lightCount;

/**
 * Returns the tracker for the light with the specified index.
 *
 * Index ltIndx corresponds to i in the GL capability name GL_LIGHTi, and must
 * be between zero and the number of available lights minus one, inclusive.
 *
 * The number of available lights can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxLights.value.
 */
-(CC3OpenGLES11Light*) lightAt: (GLuint) ltIndx;

@end

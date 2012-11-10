/*
 * CC3OpenGLES11Textures.h
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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
#import "CC3OpenGLES11VertexArrays.h"
#import "CC3OpenGLES11Matrices.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerActiveTexture

/**
 * CC3OpenGLES11StateTrackerActiveTexture tracks an enumerated GL state value for
 * identifying the active texture.
 *
 * The active texture value can be between zero and the number of available texture
 * units minus one, inclusive.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerActiveTexture : CC3OpenGLES11StateTrackerEnumeration {}

/** The GL enumeration value GL_TEXTUREi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glEnumValue;

@end

@class CC3OpenGLES11TextureUnit;


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTextureBinding

/**
 * CC3OpenGLES11StateTrackerTextureBinding tracks an integer GL state value for
 * texture binding.
 *
 * This implementation uses the GL function glBindTexture to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and will
 * not restore the value in the close method.
 */
@interface CC3OpenGLES11StateTrackerTextureBinding : CC3OpenGLES11StateTrackerInteger

/** Unbinds all textures by setting the value property to zero. */
-(void) unbind;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexEnvEnumeration

/**
 * CC3OpenGLES11StateTrackerTexEnvEnumeration tracks an enumerated GL state value for the texture environment.
 *
 * This implementation uses GL function glGetTexEnviv to read the value from the
 * GL engine, and GL function glTexEnvi to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerTexEnvEnumeration : CC3OpenGLES11StateTrackerEnumeration
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexParameterEnumeration

/**
 * CC3OpenGLES11StateTrackerTexParameterEnumeration tracks an enumerated GL state value for a texture parameter.
 *
 * This implementation uses GL function glGetTexParameteri to read the value from the
 * GL engine, and GL function glTexParameteri to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 *
 * The shouldAlwaysSetGL property is set to YES, which causes the state in the
 * GL engine to be updated whenever the value is set in the tracker.
 */
@interface CC3OpenGLES11StateTrackerTexParameterEnumeration : CC3OpenGLES11StateTrackerEnumeration
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexParameterCapability

/**
 * CC3OpenGLES11StateTrackerTexParameterCapability tracks a boolean GL capability for a texture parameter.
 *
 * This implementation uses GL function glGetTexParameteri to read the value from the
 * GL engine, and GL function glTexParameteri to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerTexParameterCapability : CC3OpenGLES11StateTrackerCapability
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexEnvColor

/**
 * CC3OpenGLES11StateTrackerTexEnvColor tracks a color GL state value for the texture environment.
 *
 * This implementation uses GL function glGetTexEnvfv to read the value from the
 * GL engine, and GL function glTexEnvfv to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and will
 * not restore the value in the close method.
 *
 */
@interface CC3OpenGLES11StateTrackerTexEnvColor : CC3OpenGLES11StateTrackerColor
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTextureServerCapability

/**
 * CC3OpenGLES11StateTrackerTextureServerCapability tracks a boolean GL capability for
 * the point sprite texture environment.
 *
 * This implementation uses GL function glGetTexEnviv to read the value from the
 * GL engine, and GL function glTexEnvi to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerTextureServerCapability : CC3OpenGLES11StateTrackerServerCapability
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability

/**
 * CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability tracks a boolean GL capability for
 * the point sprite texture environment.
 *
 * This implementation uses GL function glGetTexEnviv to read the value from the
 * GL engine, and GL function glTexEnvi to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability : CC3OpenGLES11StateTrackerTextureServerCapability {}
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTextureClientCapability

/**
 * CC3OpenGLES11StateTrackerTextureClientCapability tracks a boolean GL capability for
 * the point sprite texture environment.
 *
 * This implementation uses GL function glGetTexEnviv to read the value from the
 * GL engine, and GL function glTexEnvi to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerTextureClientCapability : CC3OpenGLES11StateTrackerClientCapability
@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexTexCoordsPointer

/**
 * CC3OpenGLES11StateTrackerVertexTexCoordsPointer tracks the parameters
 * of the vertex texture coordinates pointer.
 *   - use the useElementsAt:withSize:withType:withStride: method to set the values
 *   - elementSize uses GL name GL_TEXTURE_COORD_ARRAY_SIZE.
 *   - elementType uses GL name GL_TEXTURE_COORD_ARRAY_TYPE.
 *   - vertexStride uses GL name GL_TEXTURE_COORD_ARRAY_STRIDE.
 *   - the values are set in the GL engine using the glTexCoordPointer method
 */
@interface CC3OpenGLES11StateTrackerVertexTexCoordsPointer : CC3OpenGLES11StateTrackerVertexPointer
@end


#pragma mark -
#pragma mark CC3OpenGLES11TextureMatrixStack

/**
 * CC3OpenGLES11MatrixStack provides access to several commands that operate
 * on the texture matrix stacks, none of which require state tracking.
 *
 * Even though this class does not track any state, it does rely on the
 * tracker for the matrix mode, to ensure that the matrix mode associated
 * with this matrix stack is active before calling a GL function.
 */
@interface CC3OpenGLES11TextureMatrixStack : CC3OpenGLES11MatrixStack
@end


#pragma mark -
#pragma mark CC3OpenGLES11TextureUnit

@class CC3OpenGLES11Textures;

/** CC3OpenGLES11Textures manages trackers for texture and texture environment state. */
@interface CC3OpenGLES11TextureUnit : CC3OpenGLES11StateTrackerManager {
	GLuint textureUnitIndex;
	CC3OpenGLES11StateTrackerTextureServerCapability* texture2D;
	CC3OpenGLES11StateTrackerTextureClientCapability* textureCoordArray;
	CC3OpenGLES11StateTrackerVertexTexCoordsPointer* textureCoordinates;
	CC3OpenGLES11StateTrackerTextureBinding* textureBinding;
	CC3OpenGLES11StateTrackerTexParameterEnumeration* minifyingFunction;
	CC3OpenGLES11StateTrackerTexParameterEnumeration* magnifyingFunction;
	CC3OpenGLES11StateTrackerTexParameterEnumeration* horizontalWrappingFunction;
	CC3OpenGLES11StateTrackerTexParameterEnumeration* verticalWrappingFunction;
	CC3OpenGLES11StateTrackerTexParameterCapability* autoGenerateMipMap;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* textureEnvironmentMode;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* combineRGBFunction;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbSource0;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbSource1;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbSource2;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbOperand0;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbOperand1;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbOperand2;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbScale;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* combineAlphaFunction;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaSource0;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaSource1;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaSource2;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaOperand0;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaOperand1;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaOperand2;
	CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaScale;
	CC3OpenGLES11StateTrackerTexEnvColor* color;
	CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability* pointSpriteCoordReplace;
	CC3OpenGLES11TextureMatrixStack* matrixStack;
}

/** The GL enumeration value for this texture unit in the form GL_TEXTUREi. */
@property(nonatomic, readonly) GLenum glEnumValue;

/** Tracks the texturing capability (GL capability name GL_TEXTURE_2D). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTextureServerCapability* texture2D;

/** Tracks the texture coordinate array capability (GL capability name GL_TEXTURE_COORD_ARRAY). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTextureClientCapability* textureCoordArray;

/** Tracks the vertex texture coordinates pointer. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerVertexTexCoordsPointer* textureCoordinates;

/** Tracks texture binding (GL get name GL_TEXTURE_BINDING_2D and set function glBindTexture). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTextureBinding* textureBinding;

/** Tracks texture minifying function (GL name GL_TEXTURE_MIN_FILTER). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexParameterEnumeration* minifyingFunction;

/** Tracks texture magnifying function (GL name GL_TEXTURE_MAG_FILTER). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexParameterEnumeration* magnifyingFunction;

/** Tracks texture horizontal (S) wrapping function (GL name GL_TEXTURE_WRAP_S). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexParameterEnumeration* horizontalWrappingFunction;

/** Tracks texture vertical (T) wrapping function (GL name GL_TEXTURE_WRAP_T). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexParameterEnumeration* verticalWrappingFunction;

/** Tracks whether automatica mipmaps are enabled (GL name GL_GENERATE_MIPMAP). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexParameterCapability* autoGenerateMipMap;

/** Tracks texture environment mode (GL name GL_TEXTURE_ENV_MODE). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* textureEnvironmentMode;

/** Tracks texture combine RGB function (GL name GL_COMBINE_RGB). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* combineRGBFunction;

/** Tracks RGB source 0 (GL name GL_SRC0_RGB). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbSource0;

/** Tracks RGB source 1 (GL name GL_SRC1_RGB). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbSource1;

/** Tracks RGB source 2 (GL name GL_SRC2_RGB). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbSource2;

/** Tracks RGB operand 0 (GL name GL_OPERAND0_RGB). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbOperand0;

/** Tracks RGB operand 1 (GL name GL_OPERAND1_RGB). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbOperand1;

/** Tracks RGB operand 2 (GL name GL_OPERAND2_RGB). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* rgbOperand2;

/** Tracks texture combine alpha function (GL name GL_COMBINE_ALPHA). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* combineAlphaFunction;

/** Tracks alpha source 0 (GL name GL_SRC0_ALPHA). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaSource0;

/** Tracks alpha source 1 (GL name GL_SRC1_ALPHA). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaSource1;

/** Tracks alpha source 2 (GL name GL_SRC2_ALPHA). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaSource2;

/** Tracks alpha operand 0 (GL name GL_OPERAND0_ALPHA). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaOperand0;

/** Tracks alpha operand 1 (GL name GL_OPERAND1_ALPHA). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaOperand1;

/** Tracks alpha operand 2 (GL name GL_OPERAND2_ALPHA). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvEnumeration* alphaOperand2;

/** Tracks the texture unit color constant (GL name GL_TEXTURE_ENV_COLOR). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvColor* color;

/** Tracks whether point sprite texture environment variable GL_COORD_REPLACE_OES is set on or off. */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability* pointSpriteCoordReplace;

/** Manages the texture matrix stack. */
@property(nonatomic, retain) CC3OpenGLES11TextureMatrixStack* matrixStack;

/**
 * Initialize this instance to track GL state for the specified texture unit.
 *
 * Index texUnit corresponds to i in the GL capability name GL_TEXTUREi, and must
 * be between zero and the number of available texture units minus one, inclusive.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 *
 * The parent is the CC3OpenGLES11Textures state manager that is holding this manager.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker withTextureUnitIndex: (GLuint) texUnit;

/**
 * Allocates and initializes an autoreleased instance to track GL state for
 * the specified texture unit.
 *
 * Index texUnit corresponds to i in the GL capability name GL_TEXTUREi, and must
 * be between zero and the number of available texture units minus one, inclusive.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 *
 * The parent is the CC3OpenGLES11Textures state manager that is holding this manager.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker withTextureUnitIndex: (GLuint) texUnit;

/**
 * Make this texture unit the active texture unit.
 *
 * This is invoked automatically whenever the state of one of the properties changes.
 */
-(void) activate;

/**
 * Make this texture unit the active client texture unit.
 *
 * This is invoked automatically whenever the client state of one of the properties changes.
 */
-(void) clientActivate;

@end


#pragma mark -
#pragma mark CC3OpenGLES11Textures

/** CC3OpenGLES11Textures manages trackers for texture and texture environment state. */
@interface CC3OpenGLES11Textures : CC3OpenGLES11StateTrackerManager {
	CC3OpenGLES11StateTrackerActiveTexture* activeTexture;
	CC3OpenGLES11StateTrackerActiveTexture* clientActiveTexture;
	CCArray* textureUnits;
}

/** Tracks active texture (GL get name GL_ACTIVE_TEXTURE and set function glActiveTexture). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerActiveTexture* activeTexture;

/** Tracks active client texture (GL get name GL_CLIENT_ACTIVE_TEXTURE and set function glClientActiveTexture). */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerActiveTexture* clientActiveTexture;

/**
 * Tracks state for each texture unit (GL name GL_TEXTUREi).
 *
 * Do not access individual texture unit trackers through this property.
 * Use the textureUnitAt: method instead.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 *
 * To conserve memory, texture units are lazily allocated when requested by the
 * textureUnitAt: method. The array returned by this property will initially be
 * empty, and will subsequently contain a number of texture units one more than
 * the largest value passed to textureUnitAt:.
 */
@property(nonatomic, retain) CCArray* textureUnits;

/**
 * Returns the number of active texture units.
 *
 * This value will be between zero and the maximum number of texture units,
 * as determined from [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 *
 * To conserve memory, texture units are lazily allocated when requested by the
 * textureUnitAt: method. The value of this property will initially be zero, and
 * will subsequently be one more than the largest value passed to textureUnitAt:.
 */
@property(nonatomic, readonly) GLuint textureUnitCount;

/**
 * Returns the tracker for the texture unit with the specified index.
 *
 * Index texUnit corresponds to i in the GL capability name GL_TEXTUREi, and must
 * be between zero and the number of available texture units minus one, inclusive.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value.
 *
 * To conserve memory, texture units are lazily allocated when requested by this method.
 */
-(CC3OpenGLES11TextureUnit*) textureUnitAt: (GLuint) texUnit;

/**
 * The minimum number of GL texture unit trackers to create initially. This value
 * should be at least equal to the number of texture units that have been activated
 * by cocos2d.
 *
 * Normally, cocos2d only uses texture unit GL_TEXTURE0, so the initial value of
 * this property is one. If your cocos2d application performs multi-texturing and
 * has activated texture unit GL_TEXTURE1 or beyond, make sure that you set the value
 * of this property to the number of texture units used by your cocos2d application.
 *
 * The value of this property must be set before this class is instantiated when
 * the CC3OpenGLES11Engine is created.
 */
+(GLuint) minimumTextureUnits;

/**
 * The minimum number of GL texture unit trackers to create initially. This value
 * should be at least equal to the number of texture units that have been activated
 * by cocos2d.
 *
 * Normally, cocoss2d only uses texture unit GL_TEXTURE0, so the initial value of
 * this property is one. If your cocos2d application performs multi-texturing and
 * has activated texture unit GL_TEXTURE1 or beyond, make sure that you set the value
 * of this property to the number of texture units used by your cocos2d application.
 *
 * The value of this property must be set before this class is instantiated when
 * the CC3OpenGLES11Engine is created.
 */
+(void) setMinimumTextureUnits: (GLuint) minTexUnits;


@end

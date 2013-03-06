/*
 * CC3OpenGLESTextures.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2013 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3OpenGLESCapabilities.h"
#import "CC3OpenGLES1Capabilities.h"
#import "CC3OpenGLESVertexArrays.h"
#import "CC3OpenGLESMatrices.h"


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerActiveTexture

/**
 * CC3OpenGLESStateTrackerActiveTexture tracks an enumerated GL state value for
 * identifying the active texture.
 *
 * The active texture value can be between zero and the number of available texture
 * units minus one, inclusive.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLESEngine engine].platform.maxTextureUnits.value.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerActiveTexture : CC3OpenGLESStateTrackerEnumeration {}

/** The GL enumeration value GL_TEXTUREi, where i is determined by the value property. */
@property(nonatomic, readonly) GLenum glEnumValue;

@end

@class CC3OpenGLESTextureUnit;


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerTextureBinding

/**
 * CC3OpenGLESStateTrackerTextureBinding tracks an integer GL state value for texture binding.
 *
 * This implementation uses the GL function glBindTexture to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueIgnore,
 * which will not read the GL value from the GL engine in the open method, and will
 * not restore the value in the close method.
 */
@interface CC3OpenGLESStateTrackerTextureBinding : CC3OpenGLESStateTrackerInteger

/** Unbinds all textures by setting the value property to zero. */
-(void) unbind;

@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerTexParameterEnumeration

/**
 * CC3OpenGLESStateTrackerTexParameterEnumeration tracks an enumerated GL state value for a texture parameter.
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
@interface CC3OpenGLESStateTrackerTexParameterEnumeration : CC3OpenGLESStateTrackerEnumeration
@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerTexParameterCapability

/**
 * CC3OpenGLESStateTrackerTexParameterCapability tracks a boolean GL capability for a texture parameter.
 *
 * This implementation uses GL function glGetTexParameteri to read the value from the
 * GL engine, and GL function glTexParameteri to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerTexParameterCapability : CC3OpenGLESStateTrackerCapability
@end


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerTextureCapability

/**
 * CC3OpenGLESStateTrackerTextureCapability tracks a boolean GL capability for
 * the point sprite texture environment.
 *
 * This implementation uses GL function glGetTexEnviv to read the value from the
 * GL engine, and GL function glTexEnvi to set the value in the GL engine.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLESStateTrackerTextureCapability : CC3OpenGLESStateTrackerCapability
@end


#pragma mark -
#pragma mark CC3OpenGLESTextureUnit

@class CC3OpenGLESTextures;

/** CC3OpenGLESTextures manages trackers for texture and texture environment state. */
@interface CC3OpenGLESTextureUnit : CC3OpenGLESStateTrackerManager {
	GLuint textureUnitIndex;
	CC3OpenGLESStateTrackerTextureCapability* texture2D;
	CC3OpenGLESStateTrackerVertexPointer* textureCoordinates;
	CC3OpenGLESStateTrackerTextureBinding* textureBinding;
	CC3OpenGLESStateTrackerEnumeration* minifyingFunction;
	CC3OpenGLESStateTrackerEnumeration* magnifyingFunction;
	CC3OpenGLESStateTrackerEnumeration* horizontalWrappingFunction;
	CC3OpenGLESStateTrackerEnumeration* verticalWrappingFunction;
	CC3OpenGLESStateTrackerCapability* autoGenerateMipMap;
	CC3OpenGLESStateTrackerEnumeration* textureEnvironmentMode;
	CC3OpenGLESStateTrackerEnumeration* combineRGBFunction;
	CC3OpenGLESStateTrackerEnumeration* rgbSource0;
	CC3OpenGLESStateTrackerEnumeration* rgbSource1;
	CC3OpenGLESStateTrackerEnumeration* rgbSource2;
	CC3OpenGLESStateTrackerEnumeration* rgbOperand0;
	CC3OpenGLESStateTrackerEnumeration* rgbOperand1;
	CC3OpenGLESStateTrackerEnumeration* rgbOperand2;
	CC3OpenGLESStateTrackerEnumeration* combineAlphaFunction;
	CC3OpenGLESStateTrackerEnumeration* alphaSource0;
	CC3OpenGLESStateTrackerEnumeration* alphaSource1;
	CC3OpenGLESStateTrackerEnumeration* alphaSource2;
	CC3OpenGLESStateTrackerEnumeration* alphaOperand0;
	CC3OpenGLESStateTrackerEnumeration* alphaOperand1;
	CC3OpenGLESStateTrackerEnumeration* alphaOperand2;
	CC3OpenGLESStateTrackerColor* color;
	CC3OpenGLESStateTrackerCapability* pointSpriteCoordReplace;
	CC3OpenGLESMatrixStack* matrixStack;
}

/** The GL texture unit index. */
@property(nonatomic, readonly) GLuint textureUnitIndex;

/** The GL enumeration value for this texture unit in the form GL_TEXTUREi. */
@property(nonatomic, readonly) GLenum glEnumValue;

/** Tracks the texturing capability (GL capability name GL_TEXTURE_2D). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerTextureCapability* texture2D;

/** Tracks the vertex texture coordinates pointer. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerVertexPointer* textureCoordinates;

/** Tracks texture binding (GL get name GL_TEXTURE_BINDING_2D and set function glBindTexture). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerTextureBinding* textureBinding;

/** Tracks texture minifying function (GL name GL_TEXTURE_MIN_FILTER). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* minifyingFunction;

/** Tracks texture magnifying function (GL name GL_TEXTURE_MAG_FILTER). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* magnifyingFunction;

/** Tracks texture horizontal (S) wrapping function (GL name GL_TEXTURE_WRAP_S). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* horizontalWrappingFunction;

/** Tracks texture vertical (T) wrapping function (GL name GL_TEXTURE_WRAP_T). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* verticalWrappingFunction;

/** Tracks whether automatica mipmaps are enabled (GL name GL_GENERATE_MIPMAP). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* autoGenerateMipMap;

/** Tracks texture environment mode (GL name GL_TEXTURE_ENV_MODE). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* textureEnvironmentMode;

/** Tracks texture combine RGB function (GL name GL_COMBINE_RGB). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* combineRGBFunction;

/** Tracks RGB source 0 (GL name GL_SRC0_RGB). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* rgbSource0;

/** Tracks RGB source 1 (GL name GL_SRC1_RGB). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* rgbSource1;

/** Tracks RGB source 2 (GL name GL_SRC2_RGB). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* rgbSource2;

/** Tracks RGB operand 0 (GL name GL_OPERAND0_RGB). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* rgbOperand0;

/** Tracks RGB operand 1 (GL name GL_OPERAND1_RGB). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* rgbOperand1;

/** Tracks RGB operand 2 (GL name GL_OPERAND2_RGB). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* rgbOperand2;

/** Tracks texture combine alpha function (GL name GL_COMBINE_ALPHA). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* combineAlphaFunction;

/** Tracks alpha source 0 (GL name GL_SRC0_ALPHA). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* alphaSource0;

/** Tracks alpha source 1 (GL name GL_SRC1_ALPHA). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* alphaSource1;

/** Tracks alpha source 2 (GL name GL_SRC2_ALPHA). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* alphaSource2;

/** Tracks alpha operand 0 (GL name GL_OPERAND0_ALPHA). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* alphaOperand0;

/** Tracks alpha operand 1 (GL name GL_OPERAND1_ALPHA). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* alphaOperand1;

/** Tracks alpha operand 2 (GL name GL_OPERAND2_ALPHA). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerEnumeration* alphaOperand2;

/** Tracks the texture unit color constant (GL name GL_TEXTURE_ENV_COLOR). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerColor* color;

/** Tracks whether point sprite texture environment variable GL_COORD_REPLACE_OES is set on or off. */
@property(nonatomic, retain) CC3OpenGLESStateTrackerCapability* pointSpriteCoordReplace;

/** Manages the texture matrix stack. */
@property(nonatomic, retain) CC3OpenGLESMatrixStack* matrixStack;

/**
 * Initialize this instance to track GL state for the specified texture unit.
 *
 * Index texUnit corresponds to i in the GL capability name GL_TEXTUREi, and must
 * be between zero and the number of available texture units minus one, inclusive.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLESEngine engine].platform.maxTextureUnits.value.
 *
 * The parent is the CC3OpenGLESTextures state manager that is holding this manager.
 */
-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker withTextureUnitIndex: (GLuint) texUnit;

/**
 * Allocates and initializes an autoreleased instance to track GL state for
 * the specified texture unit.
 *
 * Index texUnit corresponds to i in the GL capability name GL_TEXTUREi, and must
 * be between zero and the number of available texture units minus one, inclusive.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLESEngine engine].platform.maxTextureUnits.value.
 *
 * The parent is the CC3OpenGLESTextures state manager that is holding this manager.
 */
+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker withTextureUnitIndex: (GLuint) texUnit;

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
#pragma mark CC3OpenGLESTextures

/** CC3OpenGLESTextures manages trackers for texture and texture environment state. */
@interface CC3OpenGLESTextures : CC3OpenGLESStateTrackerManager {
	CC3OpenGLESStateTrackerActiveTexture* _activeTexture;
	CC3OpenGLESStateTrackerActiveTexture* _clientActiveTexture;
	CCArray* _textureUnits;
}

/** Tracks active texture (GL get name GL_ACTIVE_TEXTURE and set function glActiveTexture). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerActiveTexture* activeTexture;

/** Tracks active client texture (GL get name GL_CLIENT_ACTIVE_TEXTURE and set function glClientActiveTexture). */
@property(nonatomic, retain) CC3OpenGLESStateTrackerActiveTexture* clientActiveTexture;

/**
 * Tracks state for each texture unit (GL name GL_TEXTUREi).
 *
 * Do not access individual texture unit trackers through this property.
 * Use the textureUnitAt: method instead.
 *
 * The number of available texture units can be retrieved from
 * [CC3OpenGLESEngine engine].platform.maxTextureUnits.value.
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
 * as determined from [CC3OpenGLESEngine engine].platform.maxTextureUnits.value.
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
 * [CC3OpenGLESEngine engine].platform.maxTextureUnits.value.
 *
 * To conserve memory, texture units are lazily allocated when requested by this method.
 */
-(CC3OpenGLESTextureUnit*) textureUnitAt: (GLuint) texUnit;

/** Clears the tracking of unbound texture coordinate vertex pointers. */
-(void) clearUnboundVertexPointers;

/** Disables any texture coordinate vertex pointers that have not been bound to the GL engine. */
-(void) disableUnboundVertexPointers;

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
 * the CC3OpenGLESEngine is created.
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
 * the CC3OpenGLESEngine is created.
 */
+(void) setMinimumTextureUnits: (GLuint) minTexUnits;


@end

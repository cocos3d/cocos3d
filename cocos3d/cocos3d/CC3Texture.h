/*
 * CC3Texture.h
 *
 * cocos3d 0.5.4
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3Identifiable.h"
#import "CCTexture2D.h"

/** 
 * Default texture parameters assigned to the textureParameters property
 * of each instance during instance initialization.
 */
static const ccTexParams kCC3DefaultTextureParameters = { GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT };

/** 
 * Each instanc of CC3Texture wraps a cocos2d CCTexture2D instance, and manages
 * applying that texture to the GL engine.
 */
@interface CC3Texture : CC3Identifiable {
	CCTexture2D* texture;
	ccTexParams textureParameters;
	GLenum textureChannel;
}

/**
 * The index of the texture channel used to draw this texture to the GL engine.
 * More than one texture channel may be used when textures are to be overlaid on each other.
 *
 * This value should be set to a number between zero and the maximum number of texture
 * channels. The initial value of this property is zero.
 *
 * The maximum number of texture channels available is determined by the platform. That number
 * can be retrieved from [CC3OpenGLES11Engine engine].platform.maxTextureChannels.value.
 * All platforms support at least two texture channels.
 *
 * When a copy is made of a CC3Texture instance, a copy is not made of the encapsulated
 * CCTexture2D instance. Instead, the CCTexture2D is retained by reference and shared between
 * both the original CC3Texture, and the new copy.
 */
@property(nonatomic, assign) GLenum textureChannel;

/** The 2D texture being managed by this instance. */
@property(nonatomic, retain) CCTexture2D* texture;

/**
 * An set of texture parameters used to optimize the display of the contained texture in the GL engine.
 *
 * The initial value of these parameters are:
 *   - Minifying function: GL_LINEAR
 *   - Magnifying function: GL_LINEAR
 *   - Texture wrap S: GL_REPEAT
 *   - Texture wrap T: GL_REPEAT
 */
@property(nonatomic, assign) ccTexParams textureParameters;

/**
 * Returns the proportional size of the usable image in the contained CCTexture2D,
 * relative to its physical size.
 *
 * The physical size of most textures is some power-of-two (POT), whereas the usable image
 * size is the actual portion of it that contains the image. The value returned by this
 * method contains two fractional floats (u & v), each between zero and one, representing
 * the proportional size of the usable image
 *
 * As an example, an image whose dimensions are actually 320 x 480 pixels will result in
 * a texture that is 512 x 512 pixels, and the mapSize returned by this method will be
 * {0.625, 0.9375}, calculated from {320/512, 480/512}.
 */
@property(nonatomic, readonly) ccTex2F mapSize;

/**
 * Indicates whether the RGB components of each pixel of the encapsulated texture
 * have had the corresponding alpha component applied already.
 *
 * Returns YES if this instance contains a CCTexture2D instance, and that texture
 * instance indicates that it contains pre-mulitiplied alpha.
 */
@property(nonatomic,readonly) BOOL hasPremultipliedAlpha;


#pragma mark Allocation and Initialization

/**
 * Initializes this unnamed instance with an automatically generated unique tag value.
 * The tag value will be generated automatically via the method nextTag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
-(id) initFromFile: (NSString*) aFileName;

/**
 * Allocates and initializes an autoreleased unnamed instance with an automatically
 * generated unique tag value. The tag value is generated using a call to nextTag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
+(id) textureFromFile: (NSString*) aFileName;

/**
 * Initializes this unnamed instance with the specified tag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
-(id) initWithTag: (GLuint) aTag fromFile: (NSString*) aFileName;

/**
 * Allocates and initializes an unnamed autoreleased instance with the specified tag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
+(id) textureWithTag: (GLuint) aTag fromFile: (NSString*) aFileName;

/**
 * Initializes this instance with the specified name and an automatically generated unique tag value.
 * The tag value will be generated automatically via the method nextTag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFileName;

/**
 * Allocates and initializes an autoreleased instance with the specified name and an
 * automatically generated unique tag value. The tag value is generated using a call to nextTag.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
+(id) textureWithName: (NSString*) aName fromFile: (NSString*) aFileName;

/**
 * Initializes this instance with the specified tag and name.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFileName;

/**
 * Allocates and initializes an autoreleased instance with the specified tag and name.
 * The texture file with the specified fileName will be loaded into the texture property.
 */
+(id) textureWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFileName;

/**
 * Loads the specified texture file into the texture property,
 * and returns whether the loading was successful.
 */
-(BOOL) loadTextureFile: (NSString*) aFileName;


#pragma mark Drawing

/**
 * If the texture property is not nil, binds this texture to the  GL engine, in the
 * texture channel indicated by the textureChannel property. If the texture property
 * is nil, invokes the unbind method to disable texture handling in the GL engine.
 */
-(void) draw;

/** Convenience method that simple delegates to the unbind class method. */
-(void) unbind;

/** Unbinds all textures from the GL engine by disabling texture handling in the GL engine. */
+(void) unbind;

@end

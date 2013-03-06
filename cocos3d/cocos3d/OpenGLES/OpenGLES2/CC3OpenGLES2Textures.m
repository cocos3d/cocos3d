/*
 * CC3OpenGLES2Textures.m
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
 * 
 * See header file CC3OpenGLESTextures.h for full API documentation.
 */

#import "CC3OpenGLES2Textures.h"
#import "CC3CC2Extensions.h"

#if CC3_OGLES_2


#pragma mark -
#pragma mark CC3OpenGLES2StateTrackerTextureBinding

@implementation CC3OpenGLES2StateTrackerTextureBinding

// The parent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent; }

-(void) close {
	[super close];
	ccGLBindTexture2DN(self.textureUnit.textureUnitIndex, 0);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES2TextureUnit

@implementation CC3OpenGLES2TextureUnit

-(void) initializeTrackers {
	self.texture2D = nil;
	self.textureCoordinates = nil;
	
	self.textureBinding = [CC3OpenGLES2StateTrackerTextureBinding trackerWithParent: self
																		   forState: GL_TEXTURE_BINDING_2D];
	self.minifyingFunction = [CC3OpenGLESStateTrackerTexParameterEnumeration trackerWithParent: self
																					  forState: GL_TEXTURE_MIN_FILTER];
	self.magnifyingFunction = [CC3OpenGLESStateTrackerTexParameterEnumeration trackerWithParent: self
																					   forState: GL_TEXTURE_MAG_FILTER];
	self.horizontalWrappingFunction = [CC3OpenGLESStateTrackerTexParameterEnumeration trackerWithParent: self
																							   forState: GL_TEXTURE_WRAP_S];
	self.verticalWrappingFunction = [CC3OpenGLESStateTrackerTexParameterEnumeration trackerWithParent: self
																							 forState: GL_TEXTURE_WRAP_T];
	self.autoGenerateMipMap = nil;
	
	self.textureEnvironmentMode = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.combineRGBFunction = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.rgbSource0 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.rgbSource1 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.rgbSource2 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.rgbOperand0 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.rgbOperand1 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.rgbOperand2 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.combineAlphaFunction = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.alphaSource0 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.alphaSource1 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.alphaSource2 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.alphaOperand0 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.alphaOperand1 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.alphaOperand2 = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self];
	self.color = [CC3OpenGLESStateTrackerColor trackerWithParent: self];
	self.pointSpriteCoordReplace = nil;
	self.matrixStack = nil;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES2Textures

@implementation CC3OpenGLES2Textures

/** Template method returns an autoreleased instance of a texture unit tracker. */
-(CC3OpenGLESTextureUnit*) makeTextureUnit: (GLuint) texUnit {
	return [CC3OpenGLES2TextureUnit trackerWithParent: self withTextureUnitIndex: texUnit];
}

-(void) initializeTrackers {
	[super initializeTrackers];
	self.clientActiveTexture = nil;
}

@end

#endif
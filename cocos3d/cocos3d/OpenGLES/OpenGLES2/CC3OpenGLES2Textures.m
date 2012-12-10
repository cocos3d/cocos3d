/*
 * CC3OpenGLES2Textures.m
 *
 * cocos3d 2.0.0
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
 * 
 * See header file CC3OpenGLESTextures.h for full API documentation.
 */

#import "CC3OpenGLES2Textures.h"

#if CC3_OGLES_2

#pragma mark -
#pragma mark CC3OpenGLES2TextureUnit

@implementation CC3OpenGLES2TextureUnit

-(void) initializeTrackers {
//	self.texture2D = [CC3OpenGLESStateTrackerTextureCapability trackerWithParent: self
//																		forState: GL_TEXTURE_2D];
	self.texture2D = nil;
	self.textureCoordArray = nil;
	self.textureCoordinates = nil;
	
	self.textureBinding = [CC3OpenGLESStateTrackerTextureBinding trackerWithParent: self
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
	self.textureEnvironmentMode = nil;
	self.combineRGBFunction = nil;
	self.rgbSource0 = nil;
	self.rgbSource1 = nil;
	self.rgbSource2 = nil;
	self.rgbOperand0 = nil;
	self.rgbOperand1 = nil;
	self.rgbOperand2 = nil;
	self.combineAlphaFunction = nil;
	self.alphaSource0 = nil;
	self.alphaSource1 = nil;
	self.alphaSource2 = nil;
	self.alphaOperand0 = nil;
	self.alphaOperand1 = nil;
	self.alphaOperand2 = nil;
	self.color = nil;
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
/*
 * CC3OpenGLES1Textures.m
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

#import "CC3OpenGLES1Textures.h"
#import "CC3OpenGLESEngine.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerTexEnvEnumeration

@implementation CC3OpenGLES1StateTrackerTexEnvEnumeration

// The parent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent; }

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) getGLValue {
	[self.textureUnit activate];
	glGetTexEnviv(GL_TEXTURE_ENV, name, (GLint*)&originalValue);
}

-(void) setGLValue {
	[self.textureUnit activate];
	glTexEnvi(GL_TEXTURE_ENV, name, value);
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerTexEnvColor

@implementation CC3OpenGLES1StateTrackerTexEnvColor

// The parent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent; }

-(void) getGLValue {
	[self.textureUnit activate];
	glGetTexEnvfv(GL_TEXTURE_ENV, name, (GLfloat*)&originalValue);
}

-(void) setGLValue {
	[self.textureUnit activate];
	glTexEnvfv(GL_TEXTURE_ENV, name, (GLfloat*)&value);
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerTexEnvPointSpriteCapability

@interface CC3OpenGLESStateTrackerTextureCapability (TemplateMethods)
-(CC3OpenGLESTextureUnit*) textureUnit;
@end

@implementation CC3OpenGLES1StateTrackerTexEnvPointSpriteCapability

-(void) getGLValue {
	GLint* origIntVal;
	[self.textureUnit activate];
	glGetTexEnviv(GL_POINT_SPRITE_OES, name, (GLint*)&origIntVal);
	originalValue = (origIntVal != GL_FALSE);
}

-(void) setGLValue {
	[self.textureUnit activate];
	glTexEnvi(GL_POINT_SPRITE_OES, name, (value ? GL_TRUE : GL_FALSE));
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerTextureClientCapability

@implementation CC3OpenGLES1StateTrackerTextureClientCapability

// The grandparent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent.parent; }

-(void) getGLValue {
	[self.textureUnit clientActivate];
	[super getGLValue];
}

-(void) setGLValue {
	[self.textureUnit clientActivate];
	[super setGLValue];
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexTexCoordsPointer

@implementation CC3OpenGLES1StateTrackerVertexTexCoordsPointer

// The parent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent; }

-(void) initializeTrackers {
	self.capability = [CC3OpenGLES1StateTrackerTextureClientCapability trackerWithParent: self
																				forState: GL_TEXTURE_COORD_ARRAY];
	self.elementSize = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																forState: GL_TEXTURE_COORD_ARRAY_SIZE];
	self.elementType = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_TEXTURE_COORD_ARRAY_TYPE];
	self.vertexStride = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																 forState: GL_TEXTURE_COORD_ARRAY_STRIDE];
	self.vertices = [CC3OpenGLESStateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	[self.textureUnit clientActivate];
	glTexCoordPointer(_elementSize.value, _elementType.value, _vertexStride.value, _vertices.value);
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1TextureMatrixStack

@implementation CC3OpenGLES1TextureMatrixStack

// The parent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent; }

-(void) activate {
	[super activate];
	[self.textureUnit activate];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1TextureUnit

@implementation CC3OpenGLES1TextureUnit

-(void) initializeTrackers {
	self.texture2D = [CC3OpenGLESStateTrackerTextureCapability trackerWithParent: self
																		forState: GL_TEXTURE_2D];
	self.textureCoordinates = [CC3OpenGLES1StateTrackerVertexTexCoordsPointer trackerWithParent: self];
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
	self.autoGenerateMipMap = [CC3OpenGLESStateTrackerTexParameterCapability trackerWithParent: self
																					  forState: GL_GENERATE_MIPMAP];
	self.textureEnvironmentMode = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																					  forState: GL_TEXTURE_ENV_MODE];
	self.combineRGBFunction = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																				  forState: GL_COMBINE_RGB];
	self.rgbSource0 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																		  forState: GL_SRC0_RGB];
	self.rgbSource1 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																		  forState: GL_SRC1_RGB];
	self.rgbSource2 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																		  forState: GL_SRC2_RGB];
	self.rgbOperand0 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																		   forState: GL_OPERAND0_RGB];
	self.rgbOperand1 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																		   forState: GL_OPERAND1_RGB];
	self.rgbOperand2 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																		   forState: GL_OPERAND2_RGB];
	self.combineAlphaFunction = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																					forState: GL_COMBINE_ALPHA];
	self.alphaSource0 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																			forState: GL_SRC0_ALPHA];
	self.alphaSource1 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																			forState: GL_SRC1_ALPHA];
	self.alphaSource2 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																			forState: GL_SRC2_ALPHA];
	self.alphaOperand0 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																			 forState: GL_OPERAND0_ALPHA];
	self.alphaOperand1 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																			 forState: GL_OPERAND1_ALPHA];
	self.alphaOperand2 = [CC3OpenGLES1StateTrackerTexEnvEnumeration trackerWithParent: self
																			 forState: GL_OPERAND2_ALPHA];
	self.color = [CC3OpenGLES1StateTrackerTexEnvColor trackerWithParent: self
															   forState: GL_TEXTURE_ENV_COLOR];
	self.pointSpriteCoordReplace = [CC3OpenGLES1StateTrackerTexEnvPointSpriteCapability trackerWithParent: self
																								 forState: GL_COORD_REPLACE_OES];
	self.matrixStack = [CC3OpenGLES1TextureMatrixStack trackerWithParent: self
																withMode: GL_TEXTURE
															  andTopName: GL_TEXTURE_MATRIX
															andDepthName: GL_TEXTURE_STACK_DEPTH
														  andModeTracker: self.engine.matrices.mode];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES1Textures

@implementation CC3OpenGLES1Textures

/** Template method returns an autoreleased instance of a texture unit tracker. */
-(CC3OpenGLESTextureUnit*) makeTextureUnit: (GLuint) texUnit {
	return [CC3OpenGLES1TextureUnit trackerWithParent: self withTextureUnitIndex: texUnit];
}

-(void) initializeTrackers {
	[super initializeTrackers];
	self.clientActiveTexture = [CC3OpenGLESStateTrackerActiveTexture trackerWithParent: self
																			  forState: GL_CLIENT_ACTIVE_TEXTURE
																	  andGLSetFunction: glClientActiveTexture];
}

@end

#endif
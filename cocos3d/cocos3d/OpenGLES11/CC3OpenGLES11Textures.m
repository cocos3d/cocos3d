/*
 * CC3OpenGLES11Textures.m
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
 * 
 * See header file CC3OpenGLES11Textures.h for full API documentation.
 */

#import "CC3OpenGLES11Textures.h"
#import "CC3OpenGLES11Engine.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerActiveTexture

@implementation CC3OpenGLES11StateTrackerActiveTexture

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(GLenum) glEnumValue { return GL_TEXTURE0 + value; }

-(void) setGLValue { if( setGLFunction ) setGLFunction(self.glEnumValue); }

-(void) getGLValue {
	[super getGLValue];
	originalValue -= GL_TEXTURE0;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@ = %u (orig %u)",
			[self class], NSStringFromGLEnum(self.name), self.value, self.originalValue];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTextureBinding

@implementation CC3OpenGLES11StateTrackerTextureBinding

// The parent cast as the appropriate type
-(CC3OpenGLES11TextureUnit*) textureUnit { return (CC3OpenGLES11TextureUnit*)parent; }

-(void) getGLValue {
	[self.textureUnit activate];
	[super getGLValue];
}

-(void) setGLValue {
	[self.textureUnit activate];
	glBindTexture(GL_TEXTURE_2D, value);
}

-(void) unbind { self.value = 0; }

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexEnvEnumeration

@implementation CC3OpenGLES11StateTrackerTexEnvEnumeration

// The parent cast as the appropriate type
-(CC3OpenGLES11TextureUnit*) textureUnit {
	return (CC3OpenGLES11TextureUnit*)parent;
}

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
#pragma mark CC3OpenGLES11StateTrackerTexParameterEnumeration

@implementation CC3OpenGLES11StateTrackerTexParameterEnumeration

// The parent cast as the appropriate type
-(CC3OpenGLES11TextureUnit*) textureUnit { return (CC3OpenGLES11TextureUnit*)parent; }

+(BOOL) defaultShouldAlwaysSetGL { return YES; }

-(void) getGLValue {
	[self.textureUnit activate];
	glGetTexParameteriv(GL_TEXTURE_2D, name, (GLint*)&originalValue);
}

-(void) setGLValue {
	[self.textureUnit activate];
	glTexParameteri(GL_TEXTURE_2D, name, value);
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexParameterCapability

@implementation CC3OpenGLES11StateTrackerTexParameterCapability

// The parent cast as the appropriate type
-(CC3OpenGLES11TextureUnit*) textureUnit { return (CC3OpenGLES11TextureUnit*)parent; }

-(void) getGLValue {
	[self.textureUnit activate];
	GLint glValue;
	glGetTexParameteriv(GL_TEXTURE_2D, name, &glValue);
	originalValue = (glValue != GL_FALSE);
}

-(void) setGLValue {
	[self.textureUnit activate];
	glTexParameteri(GL_TEXTURE_2D, name, (value ? GL_TRUE : GL_FALSE));
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexEnvColor

@implementation CC3OpenGLES11StateTrackerTexEnvColor

// The parent cast as the appropriate type
-(CC3OpenGLES11TextureUnit*) textureUnit {
	return (CC3OpenGLES11TextureUnit*)parent;
}

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
#pragma mark CC3OpenGLES11StateTrackerTextureServerCapability

@implementation CC3OpenGLES11StateTrackerTextureServerCapability

// The parent cast as the appropriate type
-(CC3OpenGLES11TextureUnit*) textureUnit {
	return (CC3OpenGLES11TextureUnit*)parent;
}

-(void) getGLValue {
	[self.textureUnit activate];
	[super getGLValue];
}

-(void) setGLValue {
	[self.textureUnit activate];
	[super setGLValue];
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability

@implementation CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability

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
#pragma mark CC3OpenGLES11StateTrackerTextureClientCapability

@implementation CC3OpenGLES11StateTrackerTextureClientCapability

// The parent cast as the appropriate type
-(CC3OpenGLES11TextureUnit*) textureUnit {
	return (CC3OpenGLES11TextureUnit*)parent;
}

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
#pragma mark CC3OpenGLES11StateTrackerVertexTexCoordsPointer

@implementation CC3OpenGLES11StateTrackerVertexTexCoordsPointer

// The parent cast as the appropriate type
-(CC3OpenGLES11TextureUnit*) textureUnit {
	return (CC3OpenGLES11TextureUnit*)parent;
}

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																  forState: GL_TEXTURE_COORD_ARRAY_SIZE];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerWithParent: self
																	  forState: GL_TEXTURE_COORD_ARRAY_TYPE];
	self.vertexStride = [CC3OpenGLES11StateTrackerInteger trackerWithParent: self
																	forState: GL_TEXTURE_COORD_ARRAY_STRIDE];
	self.vertices = [CC3OpenGLES11StateTrackerPointer trackerWithParent: self];
}

-(void) setGLValues {
	[self.textureUnit clientActivate];
	glTexCoordPointer(elementSize.value, elementType.value, vertexStride.value, vertices.value);
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%@ for texture unit %@",
			[super description], NSStringFromGLEnum(self.textureUnit.glEnumValue)];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11TextureMatrixStack

@implementation CC3OpenGLES11TextureMatrixStack

// The parent cast as the appropriate type
-(CC3OpenGLES11TextureUnit*) textureUnit {
	return (CC3OpenGLES11TextureUnit*)parent;
}

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
#pragma mark CC3OpenGLES11TextureUnit

@implementation CC3OpenGLES11TextureUnit

@synthesize texture2D;
@synthesize textureCoordArray;
@synthesize textureCoordinates;
@synthesize textureBinding;
@synthesize minifyingFunction;
@synthesize magnifyingFunction;
@synthesize horizontalWrappingFunction;
@synthesize verticalWrappingFunction;
@synthesize autoGenerateMipMap;
@synthesize textureEnvironmentMode;
@synthesize combineRGBFunction;
@synthesize rgbSource0;
@synthesize rgbSource1;
@synthesize rgbSource2;
@synthesize rgbOperand0;
@synthesize rgbOperand1;
@synthesize rgbOperand2;
@synthesize combineAlphaFunction;
@synthesize alphaSource0;
@synthesize alphaSource1;
@synthesize alphaSource2;
@synthesize alphaOperand0;
@synthesize alphaOperand1;
@synthesize alphaOperand2;
@synthesize color;
@synthesize pointSpriteCoordReplace;
@synthesize matrixStack;

-(void) dealloc {
	[texture2D release];
	[textureCoordArray release];
	[textureCoordinates release];
	[textureBinding release];
	[minifyingFunction release];
	[magnifyingFunction release];
	[horizontalWrappingFunction release];
	[verticalWrappingFunction release];
	[autoGenerateMipMap release];
	[textureEnvironmentMode release];
	[combineRGBFunction release];
	[rgbSource0 release];
	[rgbSource1 release];
	[rgbSource2 release];
	[rgbOperand0 release];
	[rgbOperand1 release];
	[rgbOperand2 release];
	[combineAlphaFunction release];
	[alphaSource0 release];
	[alphaSource1 release];
	[alphaSource2 release];
	[alphaOperand0 release];
	[alphaOperand1 release];
	[alphaOperand2 release];
	[color release];
	[pointSpriteCoordReplace release];
	[matrixStack release];

	[super dealloc];
}

-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker withTextureUnitIndex: (GLuint) texUnit {
	if ( (self = [super initMinimalWithParent: aTracker]) ) {
		textureUnitIndex = texUnit;
		[self initializeTrackers];
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker withTextureUnitIndex: (GLuint) texUnit {
	return [[[self alloc] initWithParent: aTracker withTextureUnitIndex: texUnit] autorelease];
}

-(void) initializeTrackers {
	self.texture2D = [CC3OpenGLES11StateTrackerTextureServerCapability trackerWithParent: self
																				forState: GL_TEXTURE_2D];
	self.textureCoordArray = [CC3OpenGLES11StateTrackerTextureClientCapability trackerWithParent: self
																						forState: GL_TEXTURE_COORD_ARRAY];
	self.textureCoordinates = [CC3OpenGLES11StateTrackerVertexTexCoordsPointer trackerWithParent: self];
	self.textureBinding = [CC3OpenGLES11StateTrackerTextureBinding trackerWithParent: self
																			forState: GL_TEXTURE_BINDING_2D];
	self.minifyingFunction = [CC3OpenGLES11StateTrackerTexParameterEnumeration trackerWithParent: self
																						forState: GL_TEXTURE_MIN_FILTER];
	self.magnifyingFunction = [CC3OpenGLES11StateTrackerTexParameterEnumeration trackerWithParent: self
																						 forState: GL_TEXTURE_MAG_FILTER];
	self.horizontalWrappingFunction = [CC3OpenGLES11StateTrackerTexParameterEnumeration trackerWithParent: self
																								 forState: GL_TEXTURE_WRAP_S];
	self.verticalWrappingFunction = [CC3OpenGLES11StateTrackerTexParameterEnumeration trackerWithParent: self
																							   forState: GL_TEXTURE_WRAP_T];
	self.autoGenerateMipMap = [CC3OpenGLES11StateTrackerTexParameterCapability trackerWithParent: self
																					forState: GL_GENERATE_MIPMAP];
	self.textureEnvironmentMode = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																					   forState: GL_TEXTURE_ENV_MODE];
	self.combineRGBFunction = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																				   forState: GL_COMBINE_RGB];
	self.rgbSource0 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																		   forState: GL_SRC0_RGB];
	self.rgbSource1 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																		   forState: GL_SRC1_RGB];
	self.rgbSource2 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																		   forState: GL_SRC2_RGB];
	self.rgbOperand0 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																			forState: GL_OPERAND0_RGB];
	self.rgbOperand1 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																			forState: GL_OPERAND1_RGB];
	self.rgbOperand2 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																			forState: GL_OPERAND2_RGB];
	self.combineAlphaFunction = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																					 forState: GL_COMBINE_ALPHA];
	self.alphaSource0 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																			 forState: GL_SRC0_ALPHA];
	self.alphaSource1 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																			 forState: GL_SRC1_ALPHA];
	self.alphaSource2 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																			 forState: GL_SRC2_ALPHA];
	self.alphaOperand0 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																			  forState: GL_OPERAND0_ALPHA];
	self.alphaOperand1 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																			  forState: GL_OPERAND1_ALPHA];
	self.alphaOperand2 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerWithParent: self
																			  forState: GL_OPERAND2_ALPHA];
	self.color = [CC3OpenGLES11StateTrackerTexEnvColor trackerWithParent: self
																forState: GL_TEXTURE_ENV_COLOR];
	self.pointSpriteCoordReplace = [CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability trackerWithParent: self
																								  forState: GL_COORD_REPLACE_OES];
	self.matrixStack = [CC3OpenGLES11TextureMatrixStack trackerWithParent: self
																 withMode: GL_TEXTURE 
															   andTopName: GL_TEXTURE_MATRIX
															 andDepthName: GL_TEXTURE_STACK_DEPTH
														   andModeTracker: self.engine.matrices.mode];
}

-(CC3OpenGLES11Textures*) texturesState { return (CC3OpenGLES11Textures*)parent; }

-(void) activate { self.texturesState.activeTexture.value = textureUnitIndex; }

-(void) clientActivate { self.texturesState.clientActiveTexture.value = textureUnitIndex; }

-(GLenum) glEnumValue { return GL_TEXTURE0 + textureUnitIndex; }

/**
 * Since this class can be instantiated dynamically, when opened,
 * open each contained primitive tracker.
 */
-(void) open {
	[super open];
	[texture2D open];
	[textureCoordArray open];
	[textureCoordinates open];
	[textureBinding open];
	[minifyingFunction open];
	[magnifyingFunction open];
	[horizontalWrappingFunction open];
	[verticalWrappingFunction open];
	[autoGenerateMipMap open];
	[textureEnvironmentMode open];
	[combineRGBFunction open];
	[rgbSource0 open];
	[rgbSource1 open];
	[rgbSource2 open];
	[rgbOperand0 open];
	[rgbOperand1 open];
	[rgbOperand2 open];
	[combineAlphaFunction open];
	[alphaSource0 open];
	[alphaSource1 open];
	[alphaSource2 open];
	[alphaOperand0 open];
	[alphaOperand1 open];
	[alphaOperand2 open];
	[color open];
	[pointSpriteCoordReplace open];
	[matrixStack open];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 1000];
	[desc appendFormat: @"%@ for %@:", [self class], NSStringFromGLEnum(self.glEnumValue)];
	[desc appendFormat: @"\n    %@", texture2D];
	[desc appendFormat: @"\n    %@", textureCoordArray];
	[desc appendFormat: @"\n    %@", textureCoordinates];
	[desc appendFormat: @"\n    %@", textureBinding];
	[desc appendFormat: @"\n    %@", minifyingFunction];
	[desc appendFormat: @"\n    %@", magnifyingFunction];
	[desc appendFormat: @"\n    %@", horizontalWrappingFunction];
	[desc appendFormat: @"\n    %@", verticalWrappingFunction];
	[desc appendFormat: @"\n    %@", autoGenerateMipMap];
	[desc appendFormat: @"\n    %@", textureEnvironmentMode];
	[desc appendFormat: @"\n    %@", combineRGBFunction];
	[desc appendFormat: @"\n    %@", rgbSource0];
	[desc appendFormat: @"\n    %@", rgbSource1];
	[desc appendFormat: @"\n    %@", rgbSource2];
	[desc appendFormat: @"\n    %@", rgbOperand0];
	[desc appendFormat: @"\n    %@", rgbOperand1];
	[desc appendFormat: @"\n    %@", rgbOperand2];
	[desc appendFormat: @"\n    %@", combineAlphaFunction];
	[desc appendFormat: @"\n    %@", alphaSource0];
	[desc appendFormat: @"\n    %@", alphaSource1];
	[desc appendFormat: @"\n    %@", alphaSource2];
	[desc appendFormat: @"\n    %@", alphaOperand0];
	[desc appendFormat: @"\n    %@", alphaOperand1];
	[desc appendFormat: @"\n    %@", alphaOperand2];
	[desc appendFormat: @"\n    %@", color];
	[desc appendFormat: @"\n    %@", pointSpriteCoordReplace];
	return desc;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11Textures

@interface CC3OpenGLES11Textures (TemplateMethods)
-(CC3OpenGLES11TextureUnit*) makeTextureUnit: (GLuint) texUnit;
@end

@implementation CC3OpenGLES11Textures

@synthesize activeTexture;
@synthesize clientActiveTexture;
@synthesize textureUnits;

-(void) dealloc {
	[activeTexture release];
	[clientActiveTexture release];
	[textureUnits release];
	
	[super dealloc];
}

-(GLuint) textureUnitCount {
	return textureUnits ? textureUnits.count : 0;
}

// The minimum number of GL texture unit trackers to create initially.
// See the description of the class-side minimumTextureUnits property.
GLuint minimumTextureUnits = 1;

+(GLuint) minimumTextureUnits {
	return minimumTextureUnits;
}

+(void) setMinimumTextureUnits: (GLuint) minTexUnits {
	minimumTextureUnits = minTexUnits;
}

/** Template method returns an autoreleased instance of a texture unit tracker. */
-(CC3OpenGLES11TextureUnit*) makeTextureUnit: (GLuint) texUnit {
	return [CC3OpenGLES11TextureUnit trackerWithParent: self withTextureUnitIndex: texUnit];
}

-(CC3OpenGLES11TextureUnit*) textureUnitAt: (GLuint) texUnit {
	// If the requested texture unit hasn't been allocated yet, add it.
	if (texUnit >= self.textureUnitCount) {
		// Make sure we don't add beyond the max number of texture units for the platform
		NSAssert2(texUnit < self.engine.platform.maxTextureUnits.value,
				  @"Request for texture unit %u exceeds maximum of %u texture units",
				  texUnit, self.engine.platform.maxTextureUnits.value);

		// Add all texture units between the current count and the requested texture unit.
		for (GLuint i = self.textureUnitCount; i <= texUnit; i++) {
			CC3OpenGLES11TextureUnit* tu = [self makeTextureUnit: i];
			[tu open];		// Read the initial values
			[textureUnits addObject: tu];
			LogTrace(@"%@ added texture unit %u:\n%@", [self class], i, tu);
		}
	}
	return [textureUnits objectAtIndex: texUnit];
}

-(void) initializeTrackers {
	self.activeTexture = [CC3OpenGLES11StateTrackerActiveTexture trackerWithParent: self
																		  forState: GL_ACTIVE_TEXTURE
																  andGLSetFunction: glActiveTexture];
	self.clientActiveTexture = [CC3OpenGLES11StateTrackerActiveTexture trackerWithParent: self
																				forState: GL_CLIENT_ACTIVE_TEXTURE
																		andGLSetFunction: glClientActiveTexture];

	// Start with the min number of texture unit trackers. Add more as requested by textureUnitAt:.
	self.textureUnits = [CCArray array];
	for (GLuint i = 0; i < minimumTextureUnits; i++) {
		[textureUnits addObject: [self makeTextureUnit: i]];
	}
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity:10000];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@", activeTexture];
	[desc appendFormat: @"\n    %@", clientActiveTexture];
	for (id tu in textureUnits) {
		[desc appendFormat: @"\n%@", tu];
	}
	return desc;
}

@end
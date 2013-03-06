/*
 * CC3OpenGLESTextures.m
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

#import "CC3OpenGLESTextures.h"
#import "CC3OpenGLESEngine.h"


#pragma mark -
#pragma mark CC3OpenGLESStateTrackerActiveTexture

@implementation CC3OpenGLESStateTrackerActiveTexture

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
#pragma mark CC3OpenGLESStateTrackerTextureBinding

@implementation CC3OpenGLESStateTrackerTextureBinding

// The parent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent; }

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
#pragma mark CC3OpenGLESStateTrackerTexParameterEnumeration

@implementation CC3OpenGLESStateTrackerTexParameterEnumeration

// The parent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent; }

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
#pragma mark CC3OpenGLESStateTrackerTexParameterCapability

@implementation CC3OpenGLESStateTrackerTexParameterCapability

// The parent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent; }

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
#pragma mark CC3OpenGLESStateTrackerTextureCapability

@implementation CC3OpenGLESStateTrackerTextureCapability

// The parent cast as the appropriate type
-(CC3OpenGLESTextureUnit*) textureUnit { return (CC3OpenGLESTextureUnit*)parent; }

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
#pragma mark CC3OpenGLESTextureUnit

@implementation CC3OpenGLESTextureUnit

@synthesize textureUnitIndex;
@synthesize texture2D;
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

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker withTextureUnitIndex: (GLuint) texUnit {
	if ( (self = [super initMinimalWithParent: aTracker]) ) {
		textureUnitIndex = texUnit;
		[self initializeTrackers];
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker withTextureUnitIndex: (GLuint) texUnit {
	return [[[self alloc] initWithParent: aTracker withTextureUnitIndex: texUnit] autorelease];
}

-(CC3OpenGLESTextures*) texturesState { return (CC3OpenGLESTextures*)parent; }

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
#pragma mark CC3OpenGLESTextures

@implementation CC3OpenGLESTextures

@synthesize activeTexture=_activeTexture;
@synthesize clientActiveTexture=_clientActiveTexture;
@synthesize textureUnits=_textureUnits;

-(void) dealloc {
	[_activeTexture release];
	[_clientActiveTexture release];
	[_textureUnits release];
	
	[super dealloc];
}

-(GLuint) textureUnitCount { return _textureUnits.count; }

// The minimum number of GL texture unit trackers to create initially.
// See the description of the class-side minimumTextureUnits property.
GLuint minimumTextureUnits = 1;

+(GLuint) minimumTextureUnits { return minimumTextureUnits; }

+(void) setMinimumTextureUnits: (GLuint) minTexUnits { minimumTextureUnits = minTexUnits; }

/** Template method returns an autoreleased instance of a texture unit tracker. */
-(CC3OpenGLESTextureUnit*) makeTextureUnit: (GLuint) texUnit {
	CC3Assert(NO, @"%@ does not implement the makeTextureUnit: method.", self);
	return nil;
}

-(CC3OpenGLESTextureUnit*) textureUnitAt: (GLuint) texUnit {
	// If the requested texture unit hasn't been allocated yet, add it.
	GLuint tuCnt = self.textureUnitCount;
	if (texUnit >= tuCnt) {
		// Make sure we don't add beyond the max number of texture units for the platform
		CC3Assert(texUnit < self.engine.platform.maxTextureUnits.value,
				  @"Request for texture unit %u exceeds maximum of %u texture units",
				  texUnit, self.engine.platform.maxTextureUnits.value);

		// Add all texture units between the current count and the requested texture unit.
		for (GLuint i = tuCnt; i <= texUnit; i++) {
			CC3OpenGLESTextureUnit* tu = [self makeTextureUnit: i];
			[tu open];		// Read the initial values
			[_textureUnits addObject: tu];
			LogTrace(@"%@ added texture unit %u:\n%@", [self class], i, tu);
		}
	}
	return [_textureUnits objectAtIndex: texUnit];
}

-(void) clearUnboundVertexPointers {
	for (CC3OpenGLESTextureUnit* tu in _textureUnits) tu.textureCoordinates.wasBound = NO;
}

-(void) disableUnboundVertexPointers {
	for (CC3OpenGLESTextureUnit* tu in _textureUnits) [tu.textureCoordinates disableIfUnbound];
}

-(void) initializeTrackers {
	self.activeTexture = [CC3OpenGLESStateTrackerActiveTexture trackerWithParent: self
																		  forState: GL_ACTIVE_TEXTURE
																  andGLSetFunction: glActiveTexture];

	// Start with the min number of texture unit trackers. Add more as requested by textureUnitAt:.
	self.textureUnits = [CCArray array];
	for (GLuint i = 0; i < minimumTextureUnits; i++) {
		[_textureUnits addObject: [self makeTextureUnit: i]];
	}
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity:10000];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@", _activeTexture];
	[desc appendFormat: @"\n    %@", _clientActiveTexture];
	for (id tu in _textureUnits) [desc appendFormat: @"\n%@", tu];
	return desc;
}

@end
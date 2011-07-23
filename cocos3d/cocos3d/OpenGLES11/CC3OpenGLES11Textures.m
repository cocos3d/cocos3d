/*
 * CC3OpenGLES11Textures.m
 *
 * cocos3d 0.6.0-sp
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

-(GLenum) glEnumValue {
	return GL_TEXTURE0 + value;
}

-(void) setGLValue {
	if( setGLFunction ) {
		setGLFunction(self.glEnumValue);
	}
}

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

-(void) dealloc {
	textureUnit = nil;		// not retained
	[super dealloc];
}

-(id) initForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	if ( (self = [super initForState: qName]) ) {
		textureUnit = aTexUnit;
	}
	return self;
}

+(id) trackerForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	return [[[self alloc] initForState: qName withParent: aTexUnit] autorelease];
}

-(void) getGLValue {
	[textureUnit activate];
	[super getGLValue];
}

-(void) setGLValue {
	[textureUnit activate];
	glBindTexture(GL_TEXTURE_2D, value);
}

-(void) unbind {
	self.value = 0;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexEnvEnumeration

@implementation CC3OpenGLES11StateTrackerTexEnvEnumeration

-(void) dealloc {
	textureUnit = nil;		// not retained
	[super dealloc];
}

-(id) initForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	if ( (self = [super initForState: qName]) ) {
		textureUnit = aTexUnit;
	}
	return self;
}

+(id) trackerForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	return [[[self alloc] initForState: qName withParent: aTexUnit] autorelease];
}

+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling {
	return kCC3GLESStateOriginalValueReadOnceAndRestore;
}

-(void) getGLValue {
	[textureUnit activate];
	glGetTexEnviv(GL_TEXTURE_ENV, name, (GLint*)&originalValue);
}

-(void) setGLValue {
	[textureUnit activate];
	glTexEnvi(GL_TEXTURE_ENV, name, value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexEnvColor

@implementation CC3OpenGLES11StateTrackerTexEnvColor

-(void) dealloc {
	textureUnit = nil;		// not retained
	[super dealloc];
}

-(id) initForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	if ( (self = [super initForState: qName]) ) {
		textureUnit = aTexUnit;
	}
	return self;
}

+(id) trackerForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	return [[[self alloc] initForState: qName withParent: aTexUnit] autorelease];
}

-(void) getGLValue {
	[textureUnit activate];
	glGetTexEnvfv(GL_TEXTURE_ENV, name, (GLfloat*)&originalValue);
}

-(void) setGLValue {
	[textureUnit activate];
	glTexEnvfv(GL_TEXTURE_ENV, name, (GLfloat*)&value);
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTextureServerCapability

@implementation CC3OpenGLES11StateTrackerTextureServerCapability

-(void) dealloc {
	textureUnit = nil;		// not retained
	[super dealloc];
}

-(id) initForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	if ( (self = [super initForState: qName]) ) {
		textureUnit = aTexUnit;
	}
	return self;
}

+(id) trackerForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	return [[[self alloc] initForState: qName withParent: aTexUnit] autorelease];
}

-(void) getGLValue {
	[textureUnit activate];
	[super getGLValue];
}

-(void) setGLValue {
	[textureUnit activate];
	[super setGLValue];
}


@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability

@implementation CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability

-(void) getGLValue {
	GLint* origIntVal;
	[textureUnit activate];
	glGetTexEnviv(GL_POINT_SPRITE_OES, name, (GLint*)&origIntVal);
	originalValue = (origIntVal != GL_FALSE);
}

-(void) setGLValue {
	[textureUnit activate];
	glTexEnvi(GL_POINT_SPRITE_OES, name, (value ? GL_TRUE : GL_FALSE));
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerTextureClientCapability

@implementation CC3OpenGLES11StateTrackerTextureClientCapability

-(void) dealloc {
	textureUnit = nil;		// not retained
	[super dealloc];
}

-(id) initForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	if ( (self = [super initForState: qName]) ) {
		textureUnit = aTexUnit;
	}
	return self;
}

+(id) trackerForState: (GLenum) qName withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	return [[[self alloc] initForState: qName withParent: aTexUnit] autorelease];
}

-(void) getGLValue {
	[textureUnit clientActivate];
	[super getGLValue];
}

-(void) setGLValue {
	[textureUnit clientActivate];
	[super setGLValue];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVertexTexCoordsPointer

@implementation CC3OpenGLES11StateTrackerVertexTexCoordsPointer

-(void) dealloc {
	textureUnit = nil;		// not retained
	[super dealloc];
}

-(id) initWithParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	if ( (self = [super init]) ) {
		textureUnit = aTexUnit;
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	return [[[self alloc] initWithParent: aTexUnit] autorelease];
}

-(void) initializeTrackers {
	self.elementSize = [CC3OpenGLES11StateTrackerInteger trackerForState: GL_TEXTURE_COORD_ARRAY_SIZE];
	self.elementType = [CC3OpenGLES11StateTrackerEnumeration trackerForState: GL_TEXTURE_COORD_ARRAY_TYPE];
	self.elementStride = [CC3OpenGLES11StateTrackerInteger trackerForState: GL_TEXTURE_COORD_ARRAY_STRIDE];
	self.elementPointer = [CC3OpenGLES11StateTrackerPointer tracker];
}

-(void) setGLValues {
	[textureUnit clientActivate];
	glTexCoordPointer(elementSize.value, elementType.value, elementStride.value, elementPointer.value);
}

-(void) open {
	[textureUnit clientActivate];
	[super open];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11TextureMatrixStack

@implementation CC3OpenGLES11TextureMatrixStack

-(void) dealloc {
	textureUnit = nil;		// not retained
	[super dealloc];
}

-(id) initWithMode: (GLenum) matrixMode
		andTopName: (GLenum) tName
	  andDepthName: (GLenum) dName
	andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) tracker
		withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	if ( (self = [super initWithMode: matrixMode
						  andTopName: tName
						andDepthName: dName
					  andModeTracker: tracker]) ) {
		textureUnit = aTexUnit;
	}
	return self;
}

+(id) trackerWithMode: (GLenum) matrixMode
		   andTopName: (GLenum) tName
		 andDepthName: (GLenum) dName
	   andModeTracker: (CC3OpenGLES11StateTrackerEnumeration*) tracker
		   withParent: (CC3OpenGLES11TextureUnit*) aTexUnit {
	return [[[self alloc] initWithMode: matrixMode
							andTopName: tName
						  andDepthName: dName
						andModeTracker: tracker
							withParent: aTexUnit] autorelease];
}

-(void) activate {
	[super activate];
	[textureUnit activate];
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11TextureUnit

@implementation CC3OpenGLES11TextureUnit

@synthesize texture2D;
@synthesize textureCoordArray;
@synthesize textureCoordinates;
@synthesize textureBinding;
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

-(id) initWithTextureUnitIndex: (GLuint) texUnit withParent: (CC3OpenGLES11Textures*) aTexState {
	if ( (self = [super initMinimal]) ) {
		texturesState = aTexState;
		textureUnitIndex = texUnit;
		[self initializeTrackers];
	}
	return self;
}

+(id) trackerWithTextureUnitIndex: (GLuint) texUnit withParent: (CC3OpenGLES11Textures*) aTexState {
	return [[[self alloc] initWithTextureUnitIndex: texUnit withParent: aTexState] autorelease];
}

-(void) initializeTrackers {
	self.texture2D = [CC3OpenGLES11StateTrackerTextureServerCapability trackerForState: GL_TEXTURE_2D
																			withParent: self];
	self.textureCoordArray = [CC3OpenGLES11StateTrackerTextureClientCapability trackerForState: GL_TEXTURE_COORD_ARRAY
																					withParent: self];
	self.textureCoordinates = [CC3OpenGLES11StateTrackerVertexTexCoordsPointer trackerWithParent: self];
	self.textureBinding = [CC3OpenGLES11StateTrackerTextureBinding trackerForState: GL_TEXTURE_BINDING_2D
																		withParent: self];
	self.textureEnvironmentMode = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_TEXTURE_ENV_MODE
																				   withParent: self];
	self.combineRGBFunction = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_COMBINE_RGB
																			   withParent: self];
	self.rgbSource0 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_SRC0_RGB
																	   withParent: self];
	self.rgbSource1 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_SRC1_RGB
																	   withParent: self];
	self.rgbSource2 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_SRC2_RGB
																	   withParent: self];
	self.rgbOperand0 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_OPERAND0_RGB
																		withParent: self];
	self.rgbOperand1 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_OPERAND1_RGB
																		withParent: self];
	self.rgbOperand2 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_OPERAND2_RGB
																		withParent: self];
	self.combineAlphaFunction = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_COMBINE_ALPHA
																				 withParent: self];
	self.alphaSource0 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_SRC0_ALPHA
																		 withParent: self];
	self.alphaSource1 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_SRC1_ALPHA
																		 withParent: self];
	self.alphaSource2 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_SRC2_ALPHA
																		 withParent: self];
	self.alphaOperand0 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_OPERAND0_ALPHA
																		  withParent: self];
	self.alphaOperand1 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_OPERAND1_ALPHA
																		  withParent: self];
	self.alphaOperand2 = [CC3OpenGLES11StateTrackerTexEnvEnumeration trackerForState: GL_OPERAND2_ALPHA
																		  withParent: self];
	self.color = [CC3OpenGLES11StateTrackerTexEnvColor trackerForState: GL_TEXTURE_ENV_COLOR
															withParent: self];
	self.pointSpriteCoordReplace = [CC3OpenGLES11StateTrackerTexEnvPointSpriteCapability trackerForState: GL_COORD_REPLACE_OES
																							  withParent: self];
	self.matrixStack = [CC3OpenGLES11TextureMatrixStack trackerWithMode: GL_TEXTURE 
															 andTopName: GL_TEXTURE_MATRIX
														   andDepthName: GL_TEXTURE_STACK_DEPTH
														 andModeTracker: [CC3OpenGLES11Engine engine].matrices.mode
															 withParent: self];
}

-(void) open {
	LogTrace("Opening %@", [self class]);
	[texture2D open];
	[textureCoordArray open];
	[textureCoordinates open];
	[textureBinding open];
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

-(void) close {
	LogTrace("Closing %@", [self class]);
	[texture2D close];
	[textureCoordArray close];
	[textureCoordinates close];
	[textureBinding close];
	[textureEnvironmentMode close];
	[combineRGBFunction close];
	[rgbSource0 close];
	[rgbSource1 close];
	[rgbSource2 close];
	[rgbOperand0 close];
	[rgbOperand1 close];
	[rgbOperand2 close];
	[combineAlphaFunction close];
	[alphaSource0 close];
	[alphaSource1 close];
	[alphaSource2 close];
	[alphaOperand0 close];
	[alphaOperand1 close];
	[alphaOperand2 close];
	[color close];
	[pointSpriteCoordReplace close];
	[matrixStack close];
}

-(void) activate {
	texturesState.activeTexture.value = textureUnitIndex;
}

-(void) clientActivate {
	texturesState.clientActiveTexture.value = textureUnitIndex;
}

-(GLenum) glEnumValue {
	return GL_TEXTURE0 + textureUnitIndex;
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 1000];
	[desc appendFormat: @"%@ for %@:", [self class], NSStringFromGLEnum(self.glEnumValue)];
	[desc appendFormat: @"\n    %@", texture2D];
	[desc appendFormat: @"\n    %@", textureCoordArray];
	[desc appendFormat: @"\n    %@", textureCoordinates];
	[desc appendFormat: @"\n    %@", textureBinding];
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
	return [CC3OpenGLES11TextureUnit trackerWithTextureUnitIndex: texUnit withParent: self];
}

-(CC3OpenGLES11TextureUnit*) textureUnitAt: (GLuint) texUnit {
	// If the requested texture unit hasn't been allocated yet, add it.
	if (texUnit >= self.textureUnitCount) {
		// Make sure we don't add beyond the max number of texture units for the platform
		GLuint platformMaxTexUnits = [CC3OpenGLES11Engine engine].platform.maxTextureUnits.value;
		GLuint tuMax = MIN(texUnit, platformMaxTexUnits);

		// Add all texture units between the current count and the requested texture unit.
		for (GLuint i = self.textureUnitCount; i <= tuMax; i++) {
			CC3OpenGLES11TextureUnit* tu = [self makeTextureUnit: i];
			[tu open];		// Read the initial values
			[textureUnits addObject: tu];
			LogTrace(@"%@ added texture unit %u:\n%@", [self class], i, tu);
		}
	}
	return [textureUnits objectAtIndex: texUnit];
}

-(void) initializeTrackers {
	self.activeTexture = [CC3OpenGLES11StateTrackerActiveTexture trackerForState: GL_ACTIVE_TEXTURE
																andGLSetFunction: glActiveTexture];
	self.clientActiveTexture = [CC3OpenGLES11StateTrackerActiveTexture trackerForState: GL_CLIENT_ACTIVE_TEXTURE
																	  andGLSetFunction: glClientActiveTexture];

	// Start with the min number of texture unit trackers. Add more as requested by textureUnitAt:.
	self.textureUnits = [NSMutableArray array];
	for (GLuint i = 0; i < minimumTextureUnits; i++) {
		[textureUnits addObject: [self makeTextureUnit: i]];
	}
}

-(void) open {
	LogTrace("Opening %@", [self class]);
	[activeTexture open];
	[clientActiveTexture open];
	[self openTrackers: textureUnits];
}

-(void) close {
	LogTrace("Closing %@", [self class]);
	[self closeTrackers: textureUnits];
	[activeTexture close];					// Close after texture units because they can change this.
	[clientActiveTexture close];			// Close after texture units because they can change this.
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
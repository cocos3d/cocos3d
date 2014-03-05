/*
 * CC3TextureUnit.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3TextureUnit.h for full API documentation.
 */

#import "CC3TextureUnit.h"

#pragma mark -
#pragma mark CC3TextureUnit

@implementation CC3TextureUnit

@synthesize textureEnvironmentMode=_textureEnvironmentMode, constantColor=_constantColor;
@synthesize rgbNormalMap=_rgbNormalMap;

-(CC3Vector) lightDirection {
	
	// Extract half-scaled normal vector from constantColor, according to RGB <-> normal mapping
	CC3Vector hv;
	switch (_rgbNormalMap) {
		case kCC3DOT3RGB_XZY:
			hv = cc3v(_constantColor.r, _constantColor.b, _constantColor.g);
			break;
		case kCC3DOT3RGB_YXZ:
			hv = cc3v(_constantColor.g, _constantColor.r, _constantColor.b);
			break;
		case kCC3DOT3RGB_YZX:
			hv = cc3v(_constantColor.b, _constantColor.r, _constantColor.g);
			break;
		case kCC3DOT3RGB_ZXY:
			hv = cc3v(_constantColor.g, _constantColor.b, _constantColor.r);
			break;
		case kCC3DOT3RGB_ZYX:
			hv = cc3v(_constantColor.b, _constantColor.g, _constantColor.r);
			break;
		case kCC3DOT3RGB_XYZ:
		default:
			hv = cc3v(_constantColor.r, _constantColor.g, _constantColor.b);
			break;
	}
	// Convert half-scaled vector between 0.0 and 1.0 to range +/- 1.0.
	return CC3VectorDifference(CC3VectorScaleUniform(hv, 2.0f), kCC3VectorUnitCube);
}

-(void) setLightDirection: (CC3Vector) aDirection {
	
	// Normalize direction, then half-shift to move value from +/-1.0 to between 0.0 and 1.0
	aDirection = CC3VectorNormalize(aDirection);
	CC3Vector hv = CC3VectorAverage(aDirection, kCC3VectorUnitCube);
	
	// Set constantColor from normal direction, according to RGB <-> normal mapping
	switch (_rgbNormalMap) {
		case kCC3DOT3RGB_XYZ:
			_constantColor = ccc4f(hv.x, hv.y, hv.z, 1.0f);
			break;
		case kCC3DOT3RGB_XZY:
			_constantColor = ccc4f(hv.x, hv.z, hv.y, 1.0f);
			break;
		case kCC3DOT3RGB_YXZ:
			_constantColor = ccc4f(hv.y, hv.x, hv.z, 1.0f);
			break;
		case kCC3DOT3RGB_YZX:
			_constantColor = ccc4f(hv.y, hv.z, hv.x, 1.0f);
			break;
		case kCC3DOT3RGB_ZXY:
			_constantColor = ccc4f(hv.z, hv.x, hv.y, 1.0f);
			break;
		case kCC3DOT3RGB_ZYX:
			_constantColor = ccc4f(hv.z, hv.y, hv.x, 1.0f);
			break;
	}
}

-(BOOL) isBumpMap { return NO; }


#pragma mark CCRGBAProtocol support

-(ccColor3B) color {
	return ccc3(CCColorByteFromFloat(_constantColor.r),
				CCColorByteFromFloat(_constantColor.g),
				CCColorByteFromFloat(_constantColor.b));
}

-(void) setColor: (ccColor3B) aColor {
	_constantColor.r = CCColorFloatFromByte(aColor.r);
	_constantColor.g = CCColorFloatFromByte(aColor.g);
	_constantColor.b = CCColorFloatFromByte(aColor.b);
}

-(GLubyte) opacity { return CCColorByteFromFloat(_constantColor.a); }

-(void) setOpacity: (GLubyte) opacity { _constantColor.a = CCColorFloatFromByte(opacity); }

-(ccColor3B) displayedColor { return self.color; }

-(BOOL) isCascadeColorEnabled { return NO; }

-(void) setCascadeColorEnabled:(BOOL)cascadeColorEnabled {}

-(void) updateDisplayedColor: (ccColor3B) color {}

-(GLubyte) displayedOpacity { return self.opacity; }

-(BOOL) isCascadeOpacityEnabled { return NO; }

-(void) setCascadeOpacityEnabled: (BOOL) cascadeOpacityEnabled {}

-(void) updateDisplayedOpacity: (GLubyte) opacity {}


#pragma mark Allocation and Initialization

-(id) init {
	if ( (self = [super init]) ) {
		_textureEnvironmentMode = GL_MODULATE;
		_constantColor = kCCC4FBlackTransparent;
		_rgbNormalMap = kCC3DOT3RGB_XYZ;
	}
	return self;
}

+(id) textureUnit { return [[[self alloc] init] autorelease]; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3TextureUnit*) another {
	_textureEnvironmentMode = another.textureEnvironmentMode;
	_constantColor = another.constantColor;
	_rgbNormalMap = another.rgbNormalMap;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3TextureUnit* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}


#pragma mark Drawing

-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	GLuint tuIdx = visitor.current2DTextureUnit;
	[gl setTextureEnvMode: _textureEnvironmentMode at: tuIdx];
	[gl setTextureEnvColor: _constantColor at: tuIdx];
}

+(void) bindDefaultWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGL* gl = visitor.gl;
	GLuint tuIdx = visitor.current2DTextureUnit;
	[gl setTextureEnvMode: GL_MODULATE at: tuIdx];
	[gl setTextureEnvColor: kCCC4FBlackTransparent at: tuIdx];
}

@end


#pragma mark -
#pragma mark CC3ConfigurableTextureUnit

@implementation CC3ConfigurableTextureUnit

@synthesize combineRGBFunction=_combineRGBFunction;
@synthesize rgbSource0=_rgbSource0;
@synthesize rgbSource1=_rgbSource1;
@synthesize rgbSource2=_rgbSource2;
@synthesize rgbOperand0=_rgbOperand0;
@synthesize rgbOperand1=_rgbOperand1;
@synthesize rgbOperand2=_rgbOperand2;
@synthesize combineAlphaFunction=_combineAlphaFunction;
@synthesize alphaSource0=_alphaSource0;
@synthesize alphaSource1=_alphaSource1;
@synthesize alphaSource2=_alphaSource2;
@synthesize alphaOperand0=_alphaOperand0;
@synthesize alphaOperand1=_alphaOperand1;
@synthesize alphaOperand2=_alphaOperand2;

-(BOOL) isBumpMap {
	return self.textureEnvironmentMode == GL_COMBINE &&
			(_combineRGBFunction == GL_DOT3_RGB || _combineRGBFunction == GL_DOT3_RGBA);
}

// Keep the compiler happy because the property is re-declared in this subclass
-(GLenum) textureEnvironmentMode { return super.textureEnvironmentMode; }
-(void) setTextureEnvironmentMode: (GLenum) envMode { super.textureEnvironmentMode = envMode; }


#pragma mark Allocation and Initialization

-(id) init {
	if ( (self = [super init]) ) {
		self.textureEnvironmentMode = GL_COMBINE;
		_combineRGBFunction = GL_MODULATE;
		_rgbSource0 = GL_TEXTURE;
		_rgbSource1 = GL_PREVIOUS;
		_rgbSource2 = GL_CONSTANT;
		_rgbOperand0 = GL_SRC_COLOR;
		_rgbOperand1 = GL_SRC_COLOR;
		_rgbOperand2 = GL_SRC_ALPHA;
		_combineAlphaFunction = GL_MODULATE;
		_alphaSource0 = GL_TEXTURE;
		_alphaSource1 = GL_PREVIOUS;
		_alphaSource2 = GL_CONSTANT;
		_alphaOperand0 = GL_SRC_ALPHA;
		_alphaOperand1 = GL_SRC_ALPHA;
		_alphaOperand2 = GL_SRC_ALPHA;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3ConfigurableTextureUnit*) another {
	[super populateFrom: another];
	
	_combineRGBFunction = another.combineRGBFunction;
	_rgbSource0 = another.rgbSource0;
	_rgbSource1 = another.rgbSource1;
	_rgbSource2 = another.rgbSource2;
	_rgbOperand0 = another.rgbOperand0;
	_rgbOperand1 = another.rgbOperand1;
	_rgbOperand2 = another.rgbOperand2;
	_combineAlphaFunction = another.combineAlphaFunction;
	_alphaSource0 = another.alphaSource0;
	_alphaSource1 = another.alphaSource1;
	_alphaSource2 = another.alphaSource2;
	_alphaOperand0 = another.alphaOperand0;
	_alphaOperand1 = another.alphaOperand1;
	_alphaOperand2 = another.alphaOperand2;
}

#pragma mark Drawing

#if !CC3_GLSL
-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super bindWithVisitor: visitor];

	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, _combineRGBFunction);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, _rgbSource0);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, _rgbSource1);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC2_RGB, _rgbSource2);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, _rgbOperand0);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, _rgbOperand1);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND2_RGB, _rgbOperand2);
	
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, _combineAlphaFunction);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, _alphaSource0);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_ALPHA, _alphaSource1);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC2_ALPHA, _alphaSource2);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, _alphaOperand0);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, _alphaOperand1);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND2_ALPHA, _alphaOperand2);
	
	LogTrace(@"%@ bound to texture unit %u", self, tuIdx);
}
#endif	// !CC3_GLSL

@end


#pragma mark -
#pragma mark CC3BumpMapTextureUnit

@implementation CC3BumpMapTextureUnit

-(BOOL) isBumpMap { return YES; }


#pragma mark Allocation and Initialization

-(id) init {
	if ( (self = [super init]) ) {
		_textureEnvironmentMode = GL_COMBINE;
	}
	return self;
}


#pragma mark Drawing

#if !CC3_GLSL
-(void) bindWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super bindWithVisitor: visitor];
	
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_DOT3_RGB);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_CONSTANT);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
	
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_ALPHA, GL_CONSTANT);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
	
	LogTrace(@"%@ bound to texture unit %u", self, tuIdx);
}
#endif	// !CC3_GLSL

@end



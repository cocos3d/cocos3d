/*
 * CC3TextureUnit.m
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
 * See header file CC3TextureUnit.h for full API documentation.
 */

#import "CC3TextureUnit.h"

#pragma mark -
#pragma mark CC3TextureUnit

@implementation CC3TextureUnit

@synthesize textureEnvironmentMode, constantColor;

-(CC3DOT3RGB) rgbNormalMap { return rgbNormalMap; }

-(void) setRgbNormalMap: (CC3DOT3RGB) rgbNormMap { rgbNormalMap = rgbNormMap; }

-(CC3Vector) lightDirection {
	
	// Extract half-scaled normal vector from constantColor, according to RGB <-> normal mapping
	CC3Vector hv;
	switch (rgbNormalMap) {
		case kCC3DOT3RGB_XZY:
			hv = cc3v(constantColor.r, constantColor.b, constantColor.g);
			break;
		case kCC3DOT3RGB_YXZ:
			hv = cc3v(constantColor.g, constantColor.r, constantColor.b);
			break;
		case kCC3DOT3RGB_YZX:
			hv = cc3v(constantColor.b, constantColor.r, constantColor.g);
			break;
		case kCC3DOT3RGB_ZXY:
			hv = cc3v(constantColor.g, constantColor.b, constantColor.r);
			break;
		case kCC3DOT3RGB_ZYX:
			hv = cc3v(constantColor.b, constantColor.g, constantColor.r);
			break;
		case kCC3DOT3RGB_XYZ:
		default:
			hv = cc3v(constantColor.r, constantColor.g, constantColor.b);
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
	switch (rgbNormalMap) {
		case kCC3DOT3RGB_XYZ:
			constantColor = CCC4FMake(hv.x, hv.y, hv.z, 1.0f);
			break;
		case kCC3DOT3RGB_XZY:
			constantColor = CCC4FMake(hv.x, hv.z, hv.y, 1.0f);
			break;
		case kCC3DOT3RGB_YXZ:
			constantColor = CCC4FMake(hv.y, hv.x, hv.z, 1.0f);
			break;
		case kCC3DOT3RGB_YZX:
			constantColor = CCC4FMake(hv.y, hv.z, hv.x, 1.0f);
			break;
		case kCC3DOT3RGB_ZXY:
			constantColor = CCC4FMake(hv.z, hv.x, hv.y, 1.0f);
			break;
		case kCC3DOT3RGB_ZYX:
			constantColor = CCC4FMake(hv.z, hv.y, hv.x, 1.0f);
			break;
	}
}

-(BOOL) isBumpMap { return NO; }


#pragma mark CCRGBAProtocol support

-(ccColor3B) color {
	return ccc3(CCColorByteFromFloat(constantColor.r),
				CCColorByteFromFloat(constantColor.g),
				CCColorByteFromFloat(constantColor.b));
}

-(void) setColor: (ccColor3B) aColor {
	constantColor.r = CCColorFloatFromByte(aColor.r);
	constantColor.g = CCColorFloatFromByte(aColor.g);
	constantColor.b = CCColorFloatFromByte(aColor.b);
}

-(GLubyte) opacity { return CCColorByteFromFloat(constantColor.a); }

-(void) setOpacity: (GLubyte) opacity { constantColor.a = CCColorFloatFromByte(opacity); }


#pragma mark Allocation and Initialization

-(id) init {
	if ( (self = [super init]) ) {
		textureEnvironmentMode = GL_MODULATE;
		constantColor = kCCC4FBlackTransparent;
		rgbNormalMap = kCC3DOT3RGB_XYZ;
	}
	return self;
}

+(id) textureUnit { return [[[self alloc] init] autorelease]; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3TextureUnit*) another {
	textureEnvironmentMode = another.textureEnvironmentMode;
	constantColor = another.constantColor;
	rgbNormalMap = another.rgbNormalMap;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3TextureUnit* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}


#pragma mark Drawing

-(void) bindTo: (CC3OpenGLES11TextureUnit*) gles11TexUnit withVisitor: (CC3NodeDrawingVisitor*) visitor {
	gles11TexUnit.textureEnvironmentMode.value = textureEnvironmentMode;
	gles11TexUnit.color.value = constantColor;
}

+(void) bindDefaultTo: (CC3OpenGLES11TextureUnit*) gles11TexUnit {
	gles11TexUnit.textureEnvironmentMode.value = GL_MODULATE;
	gles11TexUnit.color.value = kCCC4FBlackTransparent;
}

@end


#pragma mark -
#pragma mark CC3ConfigurableTextureUnit

@implementation CC3ConfigurableTextureUnit

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

-(BOOL) isBumpMap {
	return self.textureEnvironmentMode == GL_COMBINE &&
			(combineRGBFunction == GL_DOT3_RGB || combineRGBFunction == GL_DOT3_RGBA);
}

// Keep the compiler happy because the property is re-declared in this subclass
-(GLenum) textureEnvironmentMode { return super.textureEnvironmentMode; }
-(void) setTextureEnvironmentMode: (GLenum) envMode { super.textureEnvironmentMode = envMode; }


#pragma mark Allocation and Initialization

-(id) init {
	if ( (self = [super init]) ) {
		self.textureEnvironmentMode = GL_COMBINE;
		combineRGBFunction = GL_MODULATE;
		rgbSource0 = GL_TEXTURE;
		rgbSource1 = GL_PREVIOUS;
		rgbSource2 = GL_CONSTANT;
		rgbOperand0 = GL_SRC_COLOR;
		rgbOperand1 = GL_SRC_COLOR;
		rgbOperand2 = GL_SRC_ALPHA;
		combineAlphaFunction = GL_MODULATE;
		alphaSource0 = GL_TEXTURE;
		alphaSource1 = GL_PREVIOUS;
		alphaSource2 = GL_CONSTANT;
		alphaOperand0 = GL_SRC_ALPHA;
		alphaOperand1 = GL_SRC_ALPHA;
		alphaOperand2 = GL_SRC_ALPHA;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3ConfigurableTextureUnit*) another {
	[super populateFrom: another];
	
	combineRGBFunction = another.combineRGBFunction;
	rgbSource0 = another.rgbSource0;
	rgbSource1 = another.rgbSource1;
	rgbSource2 = another.rgbSource2;
	rgbOperand0 = another.rgbOperand0;
	rgbOperand1 = another.rgbOperand1;
	rgbOperand2 = another.rgbOperand2;
	combineAlphaFunction = another.combineAlphaFunction;
	alphaSource0 = another.alphaSource0;
	alphaSource1 = another.alphaSource1;
	alphaSource2 = another.alphaSource2;
	alphaOperand0 = another.alphaOperand0;
	alphaOperand1 = another.alphaOperand1;
	alphaOperand2 = another.alphaOperand2;
}

#pragma mark Drawing

-(void) bindTo: (CC3OpenGLES11TextureUnit*) gles11TexUnit withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super bindTo: gles11TexUnit withVisitor: visitor];
	
	gles11TexUnit.combineRGBFunction.value = combineRGBFunction;
	gles11TexUnit.rgbSource0.value = rgbSource0;
	gles11TexUnit.rgbSource1.value = rgbSource1;
	gles11TexUnit.rgbSource2.value = rgbSource2;
	gles11TexUnit.rgbOperand0.value = rgbOperand0;
	gles11TexUnit.rgbOperand1.value = rgbOperand1;
	gles11TexUnit.rgbOperand2.value = rgbOperand2;
	gles11TexUnit.combineAlphaFunction.value = combineAlphaFunction;
	gles11TexUnit.alphaSource0.value = alphaSource0;
	gles11TexUnit.alphaSource1.value = alphaSource1;
	gles11TexUnit.alphaSource2.value = alphaSource2;
	gles11TexUnit.alphaOperand0.value = alphaOperand0;
	gles11TexUnit.alphaOperand1.value = alphaOperand1;
	gles11TexUnit.alphaOperand2.value = alphaOperand2;
	
	LogTrace(@"%@ bound to %@", self, gles11TexUnit);
}

@end


#pragma mark -
#pragma mark CC3BumpMapTextureUnit

@implementation CC3BumpMapTextureUnit

-(BOOL) isBumpMap { return YES; }


#pragma mark Drawing

-(void) bindTo: (CC3OpenGLES11TextureUnit*) gles11TexUnit withVisitor: (CC3NodeDrawingVisitor*) visitor {
	gles11TexUnit.textureEnvironmentMode.value = GL_COMBINE;
	gles11TexUnit.combineRGBFunction.value = GL_DOT3_RGB;
	gles11TexUnit.rgbSource0.value = GL_TEXTURE;
	gles11TexUnit.rgbSource1.value = GL_CONSTANT;
	gles11TexUnit.rgbOperand0.value = GL_SRC_COLOR;
	gles11TexUnit.rgbOperand1.value = GL_SRC_COLOR;
	gles11TexUnit.combineAlphaFunction.value = GL_MODULATE;
	gles11TexUnit.alphaSource0.value = GL_TEXTURE;
	gles11TexUnit.alphaSource1.value = GL_CONSTANT;
	gles11TexUnit.alphaOperand0.value = GL_SRC_ALPHA;
	gles11TexUnit.alphaOperand1.value = GL_SRC_ALPHA;
	gles11TexUnit.color.value = constantColor;
	
	LogTrace(@"%@ bound to %@", self, gles11TexUnit);
}

@end
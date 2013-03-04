/*
 * CC3OpenGLESMatrices.m
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
 * See header file CC3OpenGLESMatrices.h for full API documentation.
 */

#import "CC3OpenGLESMatrices.h"
#import "CC3OpenGLESEngine.h"


#pragma mark -
#pragma mark CC3OpenGLESMatrixStack

@implementation CC3OpenGLESMatrixStack

-(GLuint) depth { return 0; }

// Deprecated
-(GLuint) getDepth { return self.depth; }

-(void) push {}

-(void) pop {}

-(void) identity {}

-(void) load: (CC3Matrix*) mtx {}

-(void) multiply: (CC3Matrix*) mtx {}

-(void) loadFromModelView {}

@end


#pragma mark -
#pragma mark CC3OpenGLESMatrices

@implementation CC3OpenGLESMatrices

@synthesize mode=_mode;
@synthesize modelview=_modelview;
@synthesize projection=_projection;
@synthesize activePalette=_activePalette;

-(void) dealloc {
	[_mode release];
	[_modelview release];
	[_projection release];
	[_activePalette release];
	[_paletteMatrices release];

	[super dealloc];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", _mode];
	[desc appendFormat: @"\n    %@ ", _modelview];
	[desc appendFormat: @"\n    %@ ", _projection];
	[desc appendFormat: @"\n    %@ ", _activePalette];
	for (id pm in _paletteMatrices) [desc appendFormat: @"\n%@", pm];
	return desc;
}


#pragma mark Matrix palette

-(GLuint) paletteMatrixCount { return _paletteMatrices ? _paletteMatrices.count : 0; }

-(CC3OpenGLESMatrixStack*) paletteMatrixAt: (GLuint) index { return nil; }

@end

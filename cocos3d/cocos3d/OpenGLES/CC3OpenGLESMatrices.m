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


NSString* NSStringFromCC3MatrixSemantic(CC3MatrixSemantic semantic) {
	switch (semantic) {
		case kCC3MatrixSemanticModelLocal: return @"kCC3MatrixSemanticModelLocal";
		case kCC3MatrixSemanticModelLocalInv: return @"kCC3MatrixSemanticModelLocalInv";
		case kCC3MatrixSemanticModelLocalInvTran: return @"kCC3MatrixSemanticModelLocalInvTran";
		case kCC3MatrixSemanticModel: return @"kCC3MatrixSemanticModel";
		case kCC3MatrixSemanticModelInv: return @"kCC3MatrixSemanticModelInv";
		case kCC3MatrixSemanticModelInvTran: return @"kCC3MatrixSemanticModelInvTran";
		case kCC3MatrixSemanticView: return @"kCC3MatrixSemanticView";
		case kCC3MatrixSemanticViewInv: return @"kCC3MatrixSemanticViewInv";
		case kCC3MatrixSemanticViewInvTran: return @"kCC3MatrixSemanticViewInvTran";
		case kCC3MatrixSemanticModelView: return @"kCC3MatrixSemanticModelView";
		case kCC3MatrixSemanticModelViewInv: return @"kCC3MatrixSemanticModelViewInv";
		case kCC3MatrixSemanticModelViewInvTran: return @"kCC3MatrixSemanticModelViewInvTran";
		case kCC3MatrixSemanticProj: return @"kCC3MatrixSemanticProj";
		case kCC3MatrixSemanticProjInv: return @"kCC3MatrixSemanticProjInv";
		case kCC3MatrixSemanticProjInvTran: return @"kCC3MatrixSemanticProjInvTran";
		case kCC3MatrixSemanticViewProj: return @"kCC3MatrixSemanticViewProj";
		case kCC3MatrixSemanticViewProjInv: return @"kCC3MatrixSemanticViewProjInv";
		case kCC3MatrixSemanticViewProjInvTran: return @"kCC3MatrixSemanticViewProjInvTran";
		case kCC3MatrixSemanticModelViewProj: return @"kCC3MatrixSemanticModelViewProj";
		case kCC3MatrixSemanticModelViewProjInv: return @"kCC3MatrixSemanticModelViewProjInv";
		case kCC3MatrixSemanticModelViewProjInvTran: return @"kCC3MatrixSemanticModelViewProjInvTran";

		case kCC3MatrixSemanticCount: return @"kCC3MatrixSemanticCount";
		default: return [NSString stringWithFormat: @"Unknown matrix semantic (%u)", semantic];
	}
}

BOOL CC3MatrixSemanticIs3x3(CC3MatrixSemantic semantic) {
	switch (semantic) {
		case kCC3MatrixSemanticModelLocalInvTran:
		case kCC3MatrixSemanticModelInvTran:
		case kCC3MatrixSemanticViewInvTran:
		case kCC3MatrixSemanticModelViewInvTran:
		case kCC3MatrixSemanticProjInvTran:
		case kCC3MatrixSemanticViewProjInvTran:
		case kCC3MatrixSemanticModelViewProjInvTran:
			return YES;
		default:
			return NO;
	}
}

BOOL CC3MatrixSemanticIs4x3(CC3MatrixSemantic semantic) {
	switch (semantic) {
		case kCC3MatrixSemanticModelLocal:
		case kCC3MatrixSemanticModelLocalInv:
		case kCC3MatrixSemanticModel:
		case kCC3MatrixSemanticModelInv:
		case kCC3MatrixSemanticView:
		case kCC3MatrixSemanticViewInv:
		case kCC3MatrixSemanticModelView:
		case kCC3MatrixSemanticModelViewInv:
			return YES;
		default:
			return NO;
	}
}

BOOL CC3MatrixSemanticIs4x4(CC3MatrixSemantic semantic) {
	switch (semantic) {
		case kCC3MatrixSemanticProj:
		case kCC3MatrixSemanticProjInv:
		case kCC3MatrixSemanticViewProj:
		case kCC3MatrixSemanticViewProjInv:
		case kCC3MatrixSemanticModelViewProj:
		case kCC3MatrixSemanticModelViewProjInv:
			return YES;
		default:
			return NO;
	}
}


#pragma mark -
#pragma mark CC3OpenGLESMatrixStack

@implementation CC3OpenGLESMatrixStack

-(void) push {}

-(void) pop {}

-(GLuint) depth { return 0; }

-(GLuint) maxDepth { return 0; }

-(void) setMaxDepth: (GLuint) maxDepth {}

// Deprecated
-(GLuint) getDepth { return self.depth; }

-(void) identity {}

-(void) load: (CC3Matrix*) glMatrix {}

-(void) getTop: (CC3Matrix4x4*) mtx {}

-(void) multiply: (CC3Matrix*) mtx {}

-(void) loadFromModelView {}

-(void) wasChanged { [((CC3OpenGLESMatrices*)self.parent) stackChanged: self]; }

@end


#pragma mark -
#pragma mark CC3OpenGLESMatrices

@implementation CC3OpenGLESMatrices

@synthesize mode;
@synthesize modelview;
@synthesize projection;
@synthesize activePalette;
@synthesize paletteMatrices;

-(void) dealloc {
	[mode release];
	[modelview release];
	[projection release];
	[activePalette release];
	[paletteMatrices release];

	[super dealloc];
}

-(GLuint) paletteMatrixCount { return paletteMatrices ? paletteMatrices.count : 0; }

/** Template method returns an autoreleased instance of a palette matrix tracker. */
-(CC3OpenGLESMatrixStack*) makePaletteMatrix: (GLuint) index {
	CC3Assert(NO, @"%@ does not implement the makePaletteMatrix: method.", self);
	return nil;
}

-(CC3OpenGLESMatrixStack*) paletteAt: (GLuint) index {
	// If the requested palette matrix hasn't been allocated yet, add it.
	if (index >= self.paletteMatrixCount) {
		// Make sure we don't add beyond the max number of texture units for the platform
		CC3Assert(index < self.engine.platform.maxPaletteMatrices.value,
				  @"Request for palette matrix index %u exceeds maximum palette size of %u matrices",
				  index, self.engine.platform.maxPaletteMatrices.value);
		
		// Add all palette matrices between the current count and the requested index.
		for (GLuint i = self.paletteMatrixCount; i <= index; i++) {
			CC3OpenGLESMatrixStack* pm = [self makePaletteMatrix: i];
			[pm open];		// Read the initial values
			if (!paletteMatrices) self.paletteMatrices = [CCArray array];
			[paletteMatrices addObject: pm];
			LogTrace(@"%@ added palette matrix %u:\n%@", [self class], i, pm);
		}
	}
	return [paletteMatrices objectAtIndex: index];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", mode];
	[desc appendFormat: @"\n    %@ ", modelview];
	[desc appendFormat: @"\n    %@ ", projection];
	[desc appendFormat: @"\n    %@ ", activePalette];
	for (id pm in paletteMatrices) [desc appendFormat: @"\n%@", pm];
	return desc;
}


#pragma mark Accessing matrices

-(void) stackChanged: (CC3OpenGLESMatrixStack*) stack {}

-(CC3Matrix3x3*) matrix3x3ForSemantic: (CC3MatrixSemantic) semantic { return NULL; }

-(CC3Matrix4x3*) matrix4x3ForSemantic: (CC3MatrixSemantic) semantic { return NULL; }

-(CC3Matrix4x4*) matrix4x4ForSemantic: (CC3MatrixSemantic) semantic { return NULL; }

@end

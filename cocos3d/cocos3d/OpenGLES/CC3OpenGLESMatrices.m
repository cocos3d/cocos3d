/*
 * CC3OpenGLESMatrices.m
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
 * See header file CC3OpenGLESMatrices.h for full API documentation.
 */

#import "CC3OpenGLESMatrices.h"
#import "CC3OpenGLESEngine.h"


#pragma mark -
#pragma mark CC3OpenGLESMatrixStack

@implementation CC3OpenGLESMatrixStack

-(void) dealloc {
	[modeTracker release];
	[super dealloc];
}

-(void) activate { modeTracker.value = mode; }

-(void) push {}

-(void) pop {}

-(GLuint) getDepth { return 0; }

-(void) identity {}

-(void) load: (GLvoid*) glMatrix {}

-(void) getTop: (GLvoid*) glMatrix {}

-(void) multiply: (GLvoid*) glMatrix {}

-(void) loadFromModelView {}

-(id) initWithParent: (CC3OpenGLESStateTracker*) aTracker
			withMode: (GLenum) matrixMode
		  andTopName: (GLenum) tName
		andDepthName: (GLenum) dName
	  andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker {
	if ( (self = [super initWithParent: aTracker]) ) {
		mode = matrixMode;
		topName = tName;
		depthName = dName;
		modeTracker = [aModeTracker retain];
	}
	return self;
}

+(id) trackerWithParent: (CC3OpenGLESStateTracker*) aTracker
			   withMode: (GLenum) matrixMode
			 andTopName: (GLenum) tName
		   andDepthName: (GLenum) dName
		 andModeTracker: (CC3OpenGLESStateTrackerEnumeration*) aModeTracker {
	return [[[self alloc] initWithParent: aTracker
								withMode: matrixMode
							  andTopName: tName
							andDepthName: dName
						  andModeTracker: aModeTracker] autorelease];
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ %@", [super description], NSStringFromGLEnum(mode)];
}

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
	NSAssert1(NO, @"%@ does not implement the makePaletteMatrix: method.", self);
	return nil;
}

-(CC3OpenGLESMatrixStack*) paletteAt: (GLuint) index {
	// If the requested palette matrix hasn't been allocated yet, add it.
	if (index >= self.paletteMatrixCount) {
		// Make sure we don't add beyond the max number of texture units for the platform
		NSAssert2(index < self.engine.platform.maxPaletteMatrices.value,
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

@end

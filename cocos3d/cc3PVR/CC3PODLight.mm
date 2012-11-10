/*
 * CC3PODLight.mm
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3PODLight.h for full API documentation.
 */

extern "C" {
	#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}
#import "CC3PODLight.h"
#import "CC3PVRTModelPOD.h"
#import "CC3Math.h"


@implementation CC3PODLight

-(int) podIndex { return podIndex; }

-(void) setPodIndex: (int) aPODIndex { podIndex = aPODIndex; }

-(int) podContentIndex { return podContentIndex; }

-(void) setPodContentIndex: (int) aPODIndex { podContentIndex = aPODIndex; }

-(int) podParentIndex { return podParentIndex; }

-(void) setPodParentIndex: (int) aPODIndex { podParentIndex = aPODIndex; }

-(int) podTargetIndex { return podTargetIndex; }

-(void) setPodTargetIndex: (int) aPODIndex { podTargetIndex = aPODIndex; }

-(id) initAtIndex: (int) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	if ( (self = [super initAtIndex: aPODIndex fromPODResource: aPODRez]) ) {
		// Get the light content
		if (self.podContentIndex >= 0) {
			SPODLight* psl = (SPODLight*)[aPODRez lightPODStructAtIndex: self.podContentIndex];
			LogRez(@"Setting %@ parameters from %@", [self class], NSStringFromSPODLight(psl));
			self.podTargetIndex = psl->nIdxTarget;
			self.diffuseColor = CCC4FMake(psl->pfColour[0], psl->pfColour[1], psl->pfColour[2], 1.0);
			self.ambientColor = kCC3DefaultLightColorAmbient;
			self.specularColor = kCC3DefaultLightColorSpecular;
//			self.ambientColor = kCCC4FBlack;
//			self.specularColor = kCCC4FBlack;
			switch (psl->eType) {
				case ePODDirectional:
					self.isDirectionalOnly = YES;
					break;
				case ePODPoint:
					self.isDirectionalOnly = NO;
					break;
				case ePODSpot:
					self.isDirectionalOnly = NO;
					self.spotCutoffAngle = RadiansToDegrees(psl->fFalloffAngle);
					break;
				default:
					break;
			}
		}
	}
	return self; 
}

-(PODStructPtr) nodePODStructAtIndex: (uint) aPODIndex fromPODResource: (CC3PODResource*) aPODRez {
	return [aPODRez lightNodePODStructAtIndex: aPODIndex];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3PODLight*) another {
	[super populateFrom: another];

	podIndex = another.podIndex;
	podContentIndex = another.podContentIndex;
	podParentIndex = another.podParentIndex;
	podTargetIndex = another.podTargetIndex;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ (POD index: %i)", [super description], podIndex];
}

@end

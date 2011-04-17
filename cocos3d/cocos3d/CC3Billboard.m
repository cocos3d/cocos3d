/*
 * CC3Billboard.m
 *
 * cocos3d 0.5.4
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3Billboard.h for full API documentation.
 */

#import "CC3Billboard.h"
#import "CGPointExtension.h"


@interface CC3Node (TemplateMethods)
-(void) populateFrom: (CC3Node*) another;
@end


@implementation CC3Billboard

@synthesize billboard, offsetPosition, unityScaleDistance;
@synthesize minimumBillboardScale, maximumBillboardScale;

-(void) dealloc {
	[billboard release];
	[super dealloc];
}

-(void) setBillboard:(CCNode*) aCCNode {
	id oldBB = billboard;
	billboard = [aCCNode retain];
	billboard.visible = self.visible;
	[oldBB release];
} 

-(void) setVisible:(BOOL) isVisible {
	[super setVisible: isVisible];
	billboard.visible = isVisible;
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.boundingVolume = [CC3BillboardBoundingBoxArea boundingVolume];
		self.billboard = nil;
		offsetPosition = CGPointZero;
		minimumBillboardScale = CGPointZero;
		maximumBillboardScale = CGPointZero;
		unityScaleDistance = 0.0;
	}
	return self;
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName withBillboard: (CCNode*) a2DNode {
	if ( (self = [self initWithTag: aTag withName: aName]) ) {
		self.billboard = a2DNode;
	}
	return self;
}

-(id) initWithBillboard: (CCNode*) a2DNode {
	if ( (self = [self init]) ) {
		self.billboard = a2DNode;
	}
	return self;
}

+(id) nodeWithBillboard: (CCNode*) a2DNode {
	return [[[self alloc] initWithBillboard: a2DNode] autorelease];
}

-(id) initWithName: (NSString*) aName withBillboard: (CCNode*) a2DNode {
	if ( (self = [self initWithName: aName]) ) {
		self.billboard = a2DNode;
	}
	return self;
}

+(id) nodeWithName: (NSString*) aName withBillboard: (CCNode*) a2DNode {
	return [[[self alloc] initWithName: aName withBillboard: a2DNode] autorelease];
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Billboard*) another {
	[super populateFrom: another];
	
	// Since the billboard can be any kind of CCNode, check if it supports NSCopying.
	// If it does...copy it...otherwise don't attach it.
	// Attaching a single CCNode to multiple CC3Billboards is fraught with peril,
	// because the position and scale of the CCNode will be set by multiple CC3Billboards,
	// and the last one to do so is where the CCNode will be drawn (but over and over,
	// once per CC3Billboard that references it).
	[billboard release];
	CCNode* bb = another.billboard;
	if ([bb conformsToProtocol: @protocol(NSCopying)]) {
		billboard = [bb copy];				// retained
	} else {
		billboard = nil;
	}

	offsetPosition = another.offsetPosition;
	unityScaleDistance = another.unityScaleDistance;
	minimumBillboardScale = another.minimumBillboardScale;
	maximumBillboardScale = another.maximumBillboardScale;
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@, billboard: %@, offset: %@, unity distance: %.2f, min: %@, max: %@",
				[super fullDescription], billboard, NSStringFromCGPoint(offsetPosition), unityScaleDistance,
				NSStringFromCGPoint(minimumBillboardScale), NSStringFromCGPoint(maximumBillboardScale)];
}


#pragma mark Updating

-(void) faceCamera:(CC3Camera*) camera {
	if (camera && billboard) {

		// Use the camera to project the 3D location of this node
		// into 2D and then set the billboard to that position
		[camera projectNode: self];
		CGPoint pPos = self.projectedPosition;
		billboard.position = ccpAdd(pPos, offsetPosition);
		
		CGPoint newBBScale;
		// If only one non-zero scale is allowed (min == max), ensure that the billboard is set to that scale
		if (!CGPointEqualToPoint(minimumBillboardScale, CGPointZero)
				&& CGPointEqualToPoint(maximumBillboardScale, minimumBillboardScale)) {
			newBBScale = minimumBillboardScale;
			LogTrace(@"Projecting billboard %@ to %@ with fixed scaling %@", self,
					   NSStringFromCGPoint(pPos), NSStringFromCGPoint(newBBScale));
		} else {
			// Calc how much to scale the billboard by comparing distance from camera to billboard
			// and camera to the defined unity-scale distance. Neither may be smaller than the near
			// clipping plane.
			GLfloat camNear = camera.nearClippingPlane;
			GLfloat camDist = MAX(CC3VectorDistance(self.globalLocation, camera.globalLocation), camNear);
			GLfloat unityDist = MAX(self.unityScaleDistance, camNear);
			GLfloat distScale = unityDist / camDist;
			newBBScale.x = distScale;
			newBBScale.y = distScale;
			
			// Ensure result is within any defined min and max scales
			newBBScale.x = MAX(newBBScale.x, minimumBillboardScale.x);
			newBBScale.y = MAX(newBBScale.y, minimumBillboardScale.y);
			
			newBBScale.x = (maximumBillboardScale.x != 0.0) ? MIN(newBBScale.x, maximumBillboardScale.x) : newBBScale.x;
			newBBScale.y = (maximumBillboardScale.y != 0.0) ? MIN(newBBScale.y, maximumBillboardScale.y) : newBBScale.y;
			
			// Factor in the scale of this CC3Billboard node.
			CC3Vector myScale = self.scale;
			newBBScale.x *= myScale.x;
			newBBScale.y *= myScale.y;
			LogTrace(@"Projecting billboard %@ to %@, scaled to %@ using distance %.2f and unity distance %.2f",
					 self, NSStringFromCGPoint(pPos), NSStringFromCGPoint(newBBScale), camDist, unityDist);
		}
		
		// Set the new scale only if it has changed. 
		if (billboard.scaleX != newBBScale.x) billboard.scaleX = newBBScale.x;
		if (billboard.scaleY != newBBScale.y) billboard.scaleY = newBBScale.y;
	}
}


#pragma mark Drawing

-(void) draw2dWithinBounds: (CGRect) bounds {
	if(self.visible && [self doesIntersectBounds: bounds ]) {
		[billboard visit];
	}
}

-(BOOL) doesIntersectBounds: (CGRect) bounds {
	if (boundingVolume) {
		BOOL intersects = [((CC3NodeBoundingArea*)boundingVolume) doesIntersectBounds: bounds];
		LogTrace(@"%@ bounded by %@ %@ %@", self, boundingVolume,
				 (intersects ? @"intersects" : @"does not intersect"), NSStringFromCGRect(bounds));
		// Uncomment to verify culling
//			if (!intersects) {
//				LogDebug(@"%@ bounded by %@ does not intersect %@",
//						 self, boundingVolume, NSStringFromCGRect(bounds));
//			}
		return intersects;
	}
	return YES;
}

@end


#pragma mark -
#pragma mark CC3BillboardBoundingBoxArea interface

@implementation CC3BillboardBoundingBoxArea


#pragma mark Updating

// Override to do nothing, since there's nothing to update from the CC3Billboard
// until after faceCamera: has been invoked.
-(void) update {}


#pragma mark Drawing

-(BOOL) doesIntersectBounds: (CGRect) bounds {
	CCNode* billboard = ((CC3Billboard*)node).billboard;
	return billboard && CGRectIntersectsRect(billboard.boundingBoxInPixels, bounds);
}

-(NSString*) description {
	CCNode* billboard = ((CC3Billboard*)node).billboard;
	return [NSString stringWithFormat: @"%@ with bounding box: %@", [self class],
			(billboard ? NSStringFromCGRect(billboard.boundingBoxInPixels): @"none")];
}

@end


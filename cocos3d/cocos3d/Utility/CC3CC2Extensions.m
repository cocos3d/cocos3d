/*
 * CC3CC2Extensions.m
 *
 * cocos3d 0.7.1
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
 * See header file CC3CC2Extensions.h for full API documentation.
 */

#import "CC3CC2Extensions.h"
#import "CC3IOSExtensions.h"
#import "CC3Logging.h"
#import "CCDirectorIOS.h"
#import "CGPointExtension.h"
#import "CCTouchDispatcher.h"


#pragma mark -
#pragma mark CCNode extension

@implementation CCNode (CC3)

- (CGRect) globalBoundingBoxInPixels {
	CGRect rect = CGRectMake(0, 0, contentSizeInPixels_.width, contentSizeInPixels_.height);
	return CGRectApplyAffineTransform(rect, [self nodeToWorldTransform]);
}

-(void) updateViewport {
	[children_ makeObjectsPerformSelector:@selector(updateViewport)];	
}

-(CGPoint) cc3ConvertUIPointToNodeSpace: (CGPoint) viewPoint {
	CGPoint glPoint = [[CCDirector sharedDirector] convertToGL: viewPoint];
	return [self convertToNodeSpace: glPoint];
}

-(CGPoint) cc3ConvertUIMovementToNodeSpace: (CGPoint) uiMovement {
	switch ( [[CCDirector sharedDirector] deviceOrientation] ) {
		case CCDeviceOrientationLandscapeLeft:
			return ccp( uiMovement.y, uiMovement.x );
		case CCDeviceOrientationLandscapeRight:
			return ccp( -uiMovement.y, -uiMovement.x );
		case CCDeviceOrientationPortraitUpsideDown:
			return ccp( -uiMovement.x, uiMovement.y );
		case CCDeviceOrientationPortrait:
		default:
			return ccp( uiMovement.x, -uiMovement.y );
	}
}

-(CGPoint) cc3NormalizeUIMovement: (CGPoint) uiMovement {
	CGSize cs = self.contentSize;
	CGPoint glMovement = [self cc3ConvertUIMovementToNodeSpace: uiMovement];
	return ccp(glMovement.x / cs.width, glMovement.y / cs.height);
}

-(BOOL) cc3IsTouchEnabled { return NO; }

/**
 * Based on cocos2d Gesture Recognizer ideas by Krzysztof Zabłocki at:
 * http://www.merowing.info/2012/03/using-gesturerecognizers-in-cocos2d/
 */
-(BOOL) cc3WillConsumeTouchEventAt: (CGPoint) viewPoint {
	
	if (self.cc3IsTouchEnabled &&
		self.visible &&
		self.isRunning &&
		[self cc3ContainsTouchPoint: viewPoint] ) return YES;
	
	CCArray* myKids = self.children;
	for (CCNode* child in myKids) {
		if ( [child cc3WillConsumeTouchEventAt: viewPoint] ) return YES;
	}

	LogCleanTrace(@"%@ will NOT consume event at %@", [self class], NSStringFromCGPoint(viewPoint));

	return NO;
}

-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint {
	CGPoint nodePoint = [self cc3ConvertUIPointToNodeSpace: viewPoint];
	CGSize cs = self.contentSize;
	CGRect nodeBounds = CGRectMake(0, 0, cs.width, cs.height);
	if (CGRectContainsPoint(nodeBounds, nodePoint)) {
		LogCleanTrace(@"%@ will consume event at %@ in bounds %@",
					  [self class],
					  NSStringFromCGPoint(nodePoint),
					  NSStringFromCGRect(nodeBounds));
		return YES;
	}
	return NO;
}

-(BOOL) cc3ValidateGesture: (UIGestureRecognizer*) gesture {
	if ( [self cc3WillConsumeTouchEventAt: gesture.location] ) {
		[gesture cancel];
		return NO;
	} else {
		return YES;
	}
}

@end


#pragma mark -
#pragma mark CCLayer extension

@implementation CCLayer (CC3)

-(BOOL) cc3IsTouchEnabled { return self.isTouchEnabled; }

@end


#pragma mark -
#pragma mark CCMenu extension

@implementation CCMenu (CC3)

-(BOOL) cc3ContainsTouchPoint: (CGPoint) viewPoint {
	CCArray* myKids = self.children;
	for (CCNode* child in myKids) {
		if ( [child cc3ContainsTouchPoint: viewPoint] ) return YES;
	}
	return NO;
}

@end


#pragma mark -
#pragma mark CCDirector extension

@implementation CCDirector (CC3)

-(ccTime) frameInterval { return dt; }

-(ccTime) frameRate { return frameRate_; }

@end


#pragma mark -
#pragma mark CCArray extension

@implementation CCArray (CC3)

-(NSUInteger) indexOfObjectIdenticalTo: (id) anObject {
	return [self indexOfObject: anObject];
}

-(void) removeObjectIdenticalTo: (id) anObject {
	[self removeObject: anObject];
}

-(void) fastReplaceObjectAtIndex: (NSUInteger) index withObject: (id) anObject {
	NSAssert(index < data->num, @"Invalid index. Out of bounds");

	id oldObj = data->arr[index];
	data->arr[index] = [anObject retain];
	[oldObj release];						// Release after in case new is same as old
}


#pragma mark Support for unretained objects

- (void) addUnretainedObject: (id) anObject {
	ccCArrayAppendValueWithResize(data, anObject);
}

- (void) insertUnretainedObject: (id) anObject atIndex: (NSUInteger) index {
	ccCArrayEnsureExtraCapacity(data, 1);
	ccCArrayInsertValueAtIndex(data, anObject, index);
}

- (void) removeUnretainedObjectIdenticalTo: (id) anObject {
	ccCArrayRemoveValue(data, anObject);
}

- (void) removeUnretainedObjectAtIndex: (NSUInteger) index {
	ccCArrayRemoveValueAtIndex(data, index);
}

- (void) removeAllObjectsAsUnretained {
	ccCArrayRemoveAllValues(data);
}

-(void) releaseAsUnretained {
	[self removeAllObjectsAsUnretained];
	[self release];
}

- (NSString*) fullDescription {
	NSMutableString *desc = [NSMutableString stringWithFormat:@"%@ (", [self class]];
	if (data->num > 0) {
		[desc appendFormat:@"\n\t%@", data->arr[0]];
	}
	for (NSUInteger i = 1; i < data->num; i++) {
		[desc appendFormat:@",\n\t%@", data->arr[i]];
	}
	[desc appendString:@")"];
	return desc;
}

@end


#pragma mark -
#pragma mark Miscellaneous extensions and functionality

NSString* NSStringFromTouchType(uint tType) {
	switch (tType) {
		case kCCTouchBegan:
			return @"kCCTouchBegan";
		case kCCTouchMoved:
			return @"kCCTouchMoved";
		case kCCTouchEnded:
			return @"kCCTouchEnded";
		case kCCTouchCancelled:
			return @"kCCTouchCancelled";
		default:
			return [NSString stringWithFormat: @"unknown touch type (%u)", tType];
	}
}


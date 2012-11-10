/*
 * Joystick.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd.
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
 * This code was inspired by code donated to the cocos2d user community
 * by cocos2d user "adunsmoor". The original code can be found here:
 *     http://www.cocos2d-iphone.org/forum/topic/1418
 *
 * See header file Joystick.h for full API documentation of this code.
 */

#import "Joystick.h"
#import "CCNodeExtensions.h"

/** The time it takes the thumb to spring back to center once the user lets go. */
#define kThumbSpringBackDuration 1.0

@interface Joystick (Private)
-(void) trackVelocity:(CGPoint) nodeTouchPoint;
-(void) resetVelocity;
-(CGPoint) anchorPointInPoints;
@end


@implementation Joystick

@synthesize velocity, angularVelocity;

- (void)dealloc {
	thumbNode = nil;	// retained via child node
    [super dealloc];
}

/** The anchor point in terms of cocos2d points. */
-(CGPoint) anchorPointInPoints {
	return ccpCompMult(ccpFromSize(self.contentSize), self.anchorPoint);
}

-(id) initWithThumb: (CCNode*) aNode andSize: (CGSize) size {
	NSAssert(aNode, @"Thumb node must not be nil");
	if( (self = [super init]) ) {
		self.isTouchEnabled = YES;
		isTracking = NO;
		velocity = CGPointZero;
		angularVelocity = AngularPointZero;

		// Add thumb node as a child and position it at the center
		// Must do following in this order: set thumb / set size / get anchor point
		thumbNode = aNode;
		[self addChild: thumbNode z: 1];
		self.contentSize = size;
		[thumbNode setPosition: self.anchorPointInPoints];
	}
	return self;
}

+(id) joystickWithThumb: (CCNode*) aNode andSize: (CGSize) size {
	return [[[self alloc] initWithThumb: aNode andSize: size] autorelease];
}

-(id) initWithThumb: (CCNode*) aNode andBackdrop: (CCNode*) bgNode {
	NSAssert(bgNode, @"Backdrop node must not be nil");
	if( (self = [self initWithThumb: aNode andSize: bgNode.scaledSize]) ) {
		// Position the background node at the center and behind the thumb node 
		[bgNode setPosition: self.anchorPointInPoints];
		[self addChild: bgNode z: 0];
	}
	return self;
}

+(id) joystickWithThumb: (CCNode*) thumbNode andBackdrop: (CCNode*) backgroundNode {
	return [[[self alloc] initWithThumb: thumbNode andBackdrop: backgroundNode] autorelease];
}

/**
 * Overridden to also set the limit of travel for the thumb node to
 * keep it at all times within the bound of the Joystick contentSize.
 */
-(void) setContentSize: (CGSize) newSize {
	[super setContentSize: newSize];
	travelLimit = ccpMult(ccpSub(ccpFromSize(self.contentSize), 
								 ccpFromSize(thumbNode.scaledSize)), 0.5);
}

#pragma mark Event handling

/** Handle touch events one at a time. */
-(void) registerWithTouchDispatcher {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self
													 priority: kCCMenuTouchPriority
											  swallowsTouches:YES];
	// Start with fresh state each time we register.
	// Certain transitions, such as dynamically overlaying the device camera
	// can cause abrupt breaks in targeted event state.
	[self resetVelocity];
}

-(BOOL) ccTouchBegan: (UITouch *)touch withEvent: (UIEvent *)event {
	if(!isTracking) {
		CGSize cs = self.contentSize;
		CGRect nodeBounds = CGRectMake(0, 0, cs.width, cs.height);
		CGPoint nodeTouchPoint = [self convertTouchToNodeSpace: touch];
		if(CGRectContainsPoint(nodeBounds, nodeTouchPoint)) {
			isTracking = YES;
			[thumbNode stopAllActions];
			[self trackVelocity: nodeTouchPoint];
			return YES;
		}
	}
	return NO;
}

-(void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
	NSAssert(isTracking, @"Touch ended that was never begun");
	[self resetVelocity];
}

-(void) ccTouchCancelled: (UITouch *)touch withEvent: (UIEvent *)event {
	NSAssert(isTracking, @"Touch cancelled that was never begun");
	[self resetVelocity];
}

-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	NSAssert(isTracking, @"Touch moved that was never begun");
	[self trackVelocity: [self convertTouchToNodeSpace: touch]];
}

/**
 * Calculates and sets the velocity based on the specified touch point
 * which is relative to the Joystick coordinate space. Updates the
 * position of the thumb node to track the users movements, but constrained
 * to the bounds of a circle inscribed within the Joystick contentSize.
 */
-(void) trackVelocity:(CGPoint) nodeTouchPoint {
	CGPoint ankPt = self.anchorPointInPoints;

	// Get the touch point relative to the joystick home (anchor point)
	CGPoint relPoint = ccpSub(nodeTouchPoint, ankPt);
	
	// Determine the raw unconstrained velocity vector
	CGPoint rawVelocity = CGPointMake(relPoint.x / travelLimit.x,
									  relPoint.y / travelLimit.y);

	// If necessary, normalize the velocity vector relative to the travel limits
	CGFloat rawVelLen = ccpLength(rawVelocity);
	velocity = (rawVelLen <= 1.0) ? rawVelocity : ccpMult(rawVelocity, 1.0f/rawVelLen);

	// Calculate the vector in angular coordinates
	// ccpToAngle returns counterclockwise positive relative to X-axis.
	// We want clockwise positive relative to the Y-axis.
	CGFloat angle = 90.0 - CC_RADIANS_TO_DEGREES(ccpToAngle(velocity));
	if(angle > 180.0) {
		angle -= 360.0;
	}
	angularVelocity.radius = ccpLength(velocity);
	angularVelocity.heading = angle;
	
	// Update the thumb's position, clamping it within the contentSize of the Joystick
	[thumbNode setPosition: ccpAdd(ccpCompMult(velocity, travelLimit), ankPt)];
}

/**
 * Immediately zeros the velocity vectors and then animates moving the thumb back
 * to the center, using ElasticOut to give it a bounce as it centers.
 */
-(void) resetVelocity {
	isTracking = NO;
	velocity = CGPointZero;
	angularVelocity = AngularPointZero;
	[thumbNode runAction: [CCEaseElasticOut actionWithAction:
								[CCMoveTo actionWithDuration: kThumbSpringBackDuration 
										  position: self.anchorPointInPoints]]];
}

@end

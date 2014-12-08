/*
 * Joystick.m
 *
 * Cocos3D 2.0.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * This code was inspired by code donated to the Cocos2D user community
 * by Cocos2D user "adunsmoor". The original code can be found here:
 *     http://www.cocos2d-iphone.org/forum/topic/1418
 *
 * See header file Joystick.h for full API documentation of this code.
 */

#import "Joystick.h"
#import "CCNodeExtensions.h"
#import "CC3CC2Extensions.h"
#import "CC3Logging.h"

/** The time it takes the thumb to spring back to center once the user lets go. */
#define kThumbSpringBackDuration 1.0

#if CC3_CC2_1
#	define kJoystickEventPriority	kCCMenuTouchPriority
#elif CC3_CC2_2
#	define kJoystickEventPriority	kCCMenuHandlerPriority
#else
#	define kJoystickEventPriority	0
#endif


@interface Joystick (Private)
-(void) trackVelocity:(CGPoint) nodeTouchPoint;
-(void) resetVelocity;
-(CGPoint) anchorPointInPoints;
@end


@implementation Joystick

@synthesize velocity=_velocity, angularVelocity=_angularVelocity;

-(id) initWithThumb: (CCNode*) aNode andSize: (CGSize) size {
	CC3Assert(aNode, @"Thumb node must not be nil");
	if( (self = [super init]) ) {
		[self initializeEvents];
		_isTracking = NO;
		_velocity = CGPointZero;
		_angularVelocity = AngularPointZero;
		self.ignoreAnchorPointForPosition = NO;
		self.anchorPoint = ccp(0.5f, 0.5f);

		// Add thumb node as a child and position it at the center
		// Must do following in this order: add thumb / set size / get anchor point
		_thumbNode = aNode;
		_thumbNode.anchorPoint = ccp(0.5f, 0.5f);
		[self addChild: _thumbNode z: 1];
		self.contentSize = size;
		[_thumbNode setPosition: self.anchorPointInPoints];
	}
	return self;
}

-(void) initializeEvents {
	self.userInteractionEnabled = YES;
	self.mousePriority = kJoystickEventPriority;
}

+(id) joystickWithThumb: (CCNode*) aNode andSize: (CGSize) size {
	return [[self alloc] initWithThumb: aNode andSize: size];
}

-(id) initWithThumb: (CCNode*) aNode andBackdrop: (CCNode*) bgNode {
	if( (self = [self initWithThumb: aNode andSize: bgNode.scaledSize]) ) {
		// Position the background node at the center and behind the thumb node 
		bgNode.anchorPoint = ccp(0.5f, 0.5f);
		[bgNode setPosition: self.anchorPointInPoints];
		if (bgNode) [self addChild: bgNode];
	}
	return self;
}

+(id) joystickWithThumb: (CCNode*) thumbNode andBackdrop: (CCNode*) backgroundNode {
	return [[self alloc] initWithThumb: thumbNode andBackdrop: backgroundNode];
}

/**
 * Overridden to also set the limit of travel for the thumb node to
 * keep it at all times within the bound of the Joystick contentSize.
 */
-(void) setContentSize: (CGSize) newSize {
	[super setContentSize: newSize];
	_travelLimit = ccpMult(ccpSub(ccpFromSize(self.contentSize),
								  ccpFromSize(_thumbNode.scaledSize)), 0.5);
}

#pragma mark Event handling

/**
 * Start with fresh state each time we register. Certain transitions, such as dynamically
 * overlaying the device camera can cause abrupt breaks in targeted event state.
 */
-(void) onEnter {
	[super onEnter];
	[self resetVelocity];
}

#if CC3_CC2_CLASSIC

#if CC3_IOS

/** Handle touch events one at a time. */
-(void) registerWithTouchDispatcher {
	[CCDirector.sharedDirector.touchDispatcher addTargetedDelegate: self
														  priority: kJoystickEventPriority
												   swallowsTouches:YES];
}

-(NSInteger) mouseDelegatePriority { return kJoystickEventPriority; }

-(BOOL) ccTouchBegan: (UITouch*) touch withEvent: (UIEvent*) event {
	return [self processTouchDownAt: [self convertTouchToNodeSpace: touch]];
}

-(void) ccTouchEnded: (UITouch *)touch withEvent: (UIEvent *)event {
	CC3Assert(_isTracking, @"Touch ended that was never begun");
	[self resetVelocity];
}

-(void) ccTouchCancelled: (UITouch *)touch withEvent: (UIEvent *)event {
	CC3Assert(_isTracking, @"Touch cancelled that was never begun");
	[self resetVelocity];
}

-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	CC3Assert(_isTracking, @"Touch moved that was never begun");
	[self trackVelocity: [self convertTouchToNodeSpace: touch]];
}

#endif	// CC3_IOS

#if CC3_OSX

-(BOOL) ccMouseDown: (NSEvent*) event {
	return [self processTouchDownAt: [self cc3ConvertNSEventToNodeSpace: event]];
}

-(BOOL) ccMouseDragged: (NSEvent*) event {
	BOOL isMine = _isTracking;
	if (isMine) [self trackVelocity: [self cc3ConvertNSEventToNodeSpace: event]];
	return isMine;
}

-(BOOL) ccMouseUp: (NSEvent*) event {
	BOOL isMine = _isTracking;
	if (isMine) [self resetVelocity];
	return isMine;
}

#endif	// CC3_OSX

#else

#if CC3_IOS

-(void) touchBegan: (UITouch*) touch withEvent: (UIEvent*) event {
	[self processTouchDownAt: [touch locationInNode: self]];
}

-(void) touchMoved: (UITouch*) touch withEvent: (UIEvent*) event {
	CC3Assert(_isTracking, @"Touch moved that was never begun");
	[self trackVelocity: [touch locationInNode: self]];
}

-(void) touchEnded: (UITouch*) touch withEvent: (UIEvent*) event {
	CC3Assert(_isTracking, @"Touch ended that was never begun");
	[self resetVelocity];
}

-(void) touchCancelled: (UITouch*) touch withEvent: (UIEvent*) event {
	CC3Assert(_isTracking, @"Touch cancelled that was never begun");
	[self resetVelocity];
}

#endif	// CC3_IOS

#if CC3_OSX

-(void) mouseDown: (NSEvent*) event {
	[self processTouchDownAt: [event locationInNode: self]];
}

-(void) mouseDragged: (NSEvent*) event {
	if (_isTracking) [self trackVelocity: [event locationInNode: self]];
}

-(void) mouseUp: (NSEvent*) event {
	if (_isTracking) [self resetVelocity];
}

#endif	// CC3_OSX

#endif	// CC3_CC2_CLASSIC

/** Process an iOS touch down or OSX mouse down event at the specified point. */
-(BOOL) processTouchDownAt: (CGPoint) localPoint {
	if(_isTracking) return NO;
	
	CGSize cs = self.contentSize;
	CGRect nodeBounds = CGRectMake(0, 0, cs.width, cs.height);
	if(CGRectContainsPoint(nodeBounds, localPoint)) {
		_isTracking = YES;
		[_thumbNode stopAllActions];
		[self trackVelocity: localPoint];
		return YES;
	}
	return NO;
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
	CGPoint rawVelocity = CGPointMake(relPoint.x / _travelLimit.x,
									  relPoint.y / _travelLimit.y);

	// If necessary, normalize the velocity vector relative to the travel limits
	CGFloat rawVelLen = ccpLength(rawVelocity);
	_velocity = (rawVelLen <= 1.0) ? rawVelocity : ccpMult(rawVelocity, 1.0f/rawVelLen);

	// Calculate the vector in angular coordinates
	// ccpToAngle returns counterclockwise positive relative to X-axis.
	// We want clockwise positive relative to the Y-axis.
	CGFloat angle = 90.0 - CC_RADIANS_TO_DEGREES(ccpToAngle(_velocity));
	if(angle > 180.0) angle -= 360.0;
	_angularVelocity.radius = ccpLength(_velocity);
	_angularVelocity.heading = angle;
	
	// Update the thumb's position, clamping it within the contentSize of the Joystick
	[_thumbNode setPosition: ccpAdd(ccpCompMult(_velocity, _travelLimit), ankPt)];
}

/**
 * Immediately zeros the velocity vectors and then animates moving the thumb back
 * to the center, using ElasticOut to give it a bounce as it centers.
 */
-(void) resetVelocity {
	_isTracking = NO;
	_velocity = CGPointZero;
	_angularVelocity = AngularPointZero;
	[_thumbNode runAction: [CCActionEaseElasticOut actionWithAction:
								[CCActionMoveTo actionWithDuration: kThumbSpringBackDuration
														  position: self.anchorPointInPoints]]];
}

@end

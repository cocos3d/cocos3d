/*
 * CC3ActionInterval.m
 *
 * cocos3d 0.6.0-sp
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
 * See header file CC3ActionInterval.h for full API documentation.
 */

#import "CC3ActionInterval.h"
#import "CC3TargettingNode.h"


#pragma mark CC3TransformTo

@implementation CC3TransformTo

-(id) initWithDuration: (ccTime) t endVector: (CC3Vector) aVector {
	if( (self = [super initWithDuration: t]) ) {
		endVector = aVector;
	}
	return self;
}

+(id) actionWithDuration: (ccTime) t endVector: (CC3Vector) aVector {
	return [[[self alloc] initWithDuration: t endVector: aVector] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration] endVector: endVector];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration endVector: startVector];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	startVector = self.targetVector;
	differenceVector = CC3VectorDifference(endVector, startVector);
}

-(void) update: (ccTime) t {	
	self.targetVector = CC3VectorAdd(startVector, CC3VectorScaleUniform(differenceVector, t));
}

-(CC3Vector) targetVector {
	return kCC3VectorZero;
}

-(void) setTargetVector: (CC3Vector) aVector {}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ start: %@, end: %@, diff: %@", [self class],
			NSStringFromCC3Vector(startVector), NSStringFromCC3Vector(endVector),
			NSStringFromCC3Vector(differenceVector)];
}

@end


#pragma mark -
#pragma mark CC3MoveTo

@implementation CC3MoveTo

-(id) initWithDuration: (ccTime) t moveTo: (CC3Vector) aLocation {
	return [self initWithDuration: t endVector: aLocation];
}

+(id) actionWithDuration: (ccTime) t moveTo: (CC3Vector) aLocation {
	return [self actionWithDuration: t endVector: aLocation];
}

-(CC3Vector) targetVector {
	return ((CC3Node*)self.target).location;
}

-(void) setTargetVector: (CC3Vector) aLocation {
	((CC3Node*)self.target).location = aLocation;
}

@end


#pragma mark -
#pragma mark CC3RotateTo

@implementation CC3RotateTo

-(id) initWithDuration: (ccTime) t rotateTo: (CC3Vector) aRotation {
	return [self initWithDuration: t endVector: aRotation];
}

+(id) actionWithDuration: (ccTime) t rotateTo: (CC3Vector) aRotation {
	return [self actionWithDuration: t endVector: aRotation];
}

// We want to rotate the minimal angles to get from the startVector to the endVector,
// taking into consideration the cyclical nature of rotation. Therefore, a rotation
// from 10 degrees to 350 degrees should travel -20 degrees, not the +340 degrees
// that would result from simple subtraction.
-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	differenceVector = CC3VectorRotationalDifference(endVector, startVector);
}

-(CC3Vector) targetVector {
	return ((CC3Node*)self.target).rotation;
}

-(void) setTargetVector: (CC3Vector) aRotation {
	((CC3Node*)self.target).rotation = aRotation;
}


@end


#pragma mark -
#pragma mark CC3RotateToLookTowards

@implementation CC3RotateToLookTowards

-(id) initWithDuration: (ccTime) t forwardDirection: (CC3Vector) aDirection {
	return [self initWithDuration: t endVector: CC3VectorNormalize(aDirection)];
}

+(id) actionWithDuration: (ccTime) t forwardDirection: (CC3Vector) aDirection {
	return [self actionWithDuration: t endVector: CC3VectorNormalize(aDirection)];
}

-(CC3Vector) targetVector {
	return ((CC3TargettingNode*)self.target).forwardDirection;
}

-(void) setTargetVector: (CC3Vector) aDirection {
	((CC3TargettingNode*)self.target).forwardDirection = aDirection;
}

@end


#pragma mark -
#pragma mark CC3RotateToLookAt

@implementation CC3RotateToLookAt

-(id) initWithDuration: (ccTime) t targetLocation: (CC3Vector) aLocation {
	return [self initWithDuration: t endVector: aLocation];
}

+(id) actionWithDuration: (ccTime) t targetLocation: (CC3Vector) aLocation {
	return [self actionWithDuration: t endVector: aLocation];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	endVector = CC3VectorNormalize(CC3VectorDifference(endVector, aTarget.globalLocation));
	[super startWithTarget: aTarget];
}

@end


#pragma mark -
#pragma mark CC3ScaleTo

@implementation CC3ScaleTo

-(id) initWithDuration: (ccTime) t scaleTo: (CC3Vector) aScale {
	return [self initWithDuration: t endVector: aScale];
}

+(id) actionWithDuration: (ccTime) t scaleTo: (CC3Vector) aScale {
	return [self actionWithDuration: t endVector: aScale];
}

-(CC3Vector) targetVector {
	return ((CC3Node*)self.target).scale;
}

-(void) setTargetVector: (CC3Vector) aScale {
	((CC3Node*)self.target).scale = aScale;
}

@end


#pragma mark -
#pragma mark CC3TransformBy

@implementation CC3TransformBy

-(id) initWithDuration: (ccTime) t differenceVector: (CC3Vector) aVector {
	if( (self = [super initWithDuration: t]) ) {
		differenceVector = aVector;
	}
	return self;
}

+(id) actionWithDuration: (ccTime) t differenceVector: (CC3Vector) aVector {
	return [[[self alloc] initWithDuration: t differenceVector: aVector] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration] differenceVector: differenceVector];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration differenceVector: CC3VectorNegate(differenceVector)];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	CC3Vector diffTmp = differenceVector;
	[super startWithTarget: aTarget];
	differenceVector = diffTmp;
	endVector = CC3VectorAdd(startVector, differenceVector);
}

@end


#pragma mark -
#pragma mark CC3MoveBy

@implementation CC3MoveBy

-(id) initWithDuration: (ccTime) t moveBy: (CC3Vector) aTranslation {
	return [self initWithDuration: t differenceVector: aTranslation];
}

+(id) actionWithDuration: (ccTime) t moveBy: (CC3Vector) aTranslation {
	return [self actionWithDuration: t differenceVector: aTranslation];
}

-(CC3Vector) targetVector {
	return ((CC3Node*)self.target).location;
}

-(void) setTargetVector: (CC3Vector) aLocation {
	((CC3Node*)self.target).location = aLocation;
}

@end


#pragma mark -
#pragma mark CC3RotateBy

@implementation CC3RotateBy

-(id) initWithDuration: (ccTime) t rotateBy: (CC3Vector) aRotation {
	return [self initWithDuration: t differenceVector: aRotation];
}

+(id) actionWithDuration: (ccTime) t rotateBy: (CC3Vector) aRotation {
	return [self actionWithDuration: t differenceVector: aRotation];
}

-(CC3Vector) targetVector {
	return ((CC3Node*)self.target).rotation;
}

-(void) setTargetVector: (CC3Vector) aRotation {
	((CC3Node*)self.target).rotation = aRotation;
}

@end


#pragma mark -
#pragma mark CC3ScaleBy

@implementation CC3ScaleBy

-(id) initWithDuration: (ccTime) t scaleBy: (CC3Vector) aScale {
	return [self initWithDuration: t differenceVector: aScale];
}

+(id) actionWithDuration: (ccTime) t scaleBy: (CC3Vector) aScale {
	return [self actionWithDuration: t differenceVector: aScale];
}

-(CC3Vector) targetVector {
	return ((CC3Node*)self.target).scale;
}

-(void) setTargetVector: (CC3Vector) aScale {
	((CC3Node*)self.target).scale = aScale;
}

@end

#pragma mark -
#pragma mark CC3TintTo

@interface CC3TintTo (TemplateMethods)
@property(nonatomic, assign) ccColor4F targetColor;
@property(nonatomic, readonly) CC3Node* targetNode;
@end

@implementation CC3TintTo

-(CC3Node*) targetNode {
	return (CC3Node*)self.target;
}

-(ccColor4F) targetColor {
	NSAssert1(NO, @"%@ is abstract. Property targetColor must be implemented in a concrete subclass", self);
	return kCCC4FBlackTransparent;
}

-(void) setTargetColor: (ccColor4F) aColor {
	NSAssert1(NO, @"%@ is abstract. Property targetColor must be implemented in a concrete subclass", self);
}

-(id) initWithDuration: (ccTime) t colorTo: (ccColor4F) aColor {
	if( (self = [super initWithDuration: t]) ) {
		endColor = aColor;
	}
	return self;
}

+(id) actionWithDuration:(ccTime) t colorTo: (ccColor4F) aColor {
	return [[[self alloc] initWithDuration: t colorTo: aColor] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[self class] actionWithDuration: [self duration] colorTo: endColor];
}

-(void) startWithTarget: (id) aTarget {
	[super startWithTarget: aTarget];
	startColor = self.targetColor;
}

-(void) update: (ccTime) t {
	self.targetColor = CCC4FBlend(startColor, endColor, t);
}

@end


#pragma mark -
#pragma mark CC3TintAmbientTo

@implementation CC3TintAmbientTo

-(ccColor4F) targetColor {
	return self.targetNode.ambientColor;
}

-(void) setTargetColor: (ccColor4F) aColor {
	self.targetNode.ambientColor = aColor;
}

@end


#pragma mark -
#pragma mark CC3TintDiffuseTo

@implementation CC3TintDiffuseTo

-(ccColor4F) targetColor {
	return self.targetNode.diffuseColor;
}

-(void) setTargetColor: (ccColor4F) aColor {
	self.targetNode.diffuseColor = aColor;
}

@end


#pragma mark -
#pragma mark CC3TintSpecularTo

@implementation CC3TintSpecularTo

-(ccColor4F) targetColor {
	return self.targetNode.specularColor;
}

-(void) setTargetColor: (ccColor4F) aColor {
	self.targetNode.specularColor = aColor;
}

@end


#pragma mark -
#pragma mark CC3TintEmissionTo

@implementation CC3TintEmissionTo

-(ccColor4F) targetColor {
	return self.targetNode.emissionColor;
}

-(void) setTargetColor: (ccColor4F) aColor {
	self.targetNode.emissionColor = aColor;
}

@end


#pragma mark -
#pragma mark CC3Animate

@implementation CC3Animate

@synthesize isReversed;

-(id) initWithDuration: (ccTime) d {
	if ( (self = [super initWithDuration: d]) ) {
		isReversed = NO;
	}
	return self;
}

-(CCActionInterval*) asActionLimitedFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange {
	return [CC3ActionRangeLimit actionWithAction: self limitFrom: startOfRange to: endOfRange];
}

+(id) actionWithDuration: (ccTime) d limitFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange {
	return [[self actionWithDuration: d] asActionLimitedFrom: startOfRange to: endOfRange];
}

-(void) update: (ccTime) t {
	CC3Node* node = target_;
	[node establishAnimationFrameAt: (isReversed ? (1.0 - t) : t)];
}

- (CCActionInterval *) reverse {
	CC3Animate* newAnim = [[self class] actionWithDuration: duration_];
	newAnim.isReversed = !self.isReversed;
	return newAnim;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3Animate* newAnim = [[[self class] allocWithZone:zone] initWithDuration: duration_];
	newAnim.isReversed = self.isReversed;
	return newAnim;
}


@end


#pragma mark -
#pragma mark CC3ActionRangeLimit

@implementation CC3ActionRangeLimit

-(id) initWithAction: (CCActionInterval*) action
		   limitFrom: (GLfloat) startOfRange
				  to: (GLfloat) endOfRange {
	if ( (self = [super initWithAction: action]) ) {
		rangeStart = startOfRange;
		rangeSpan = endOfRange - startOfRange;
	}
	return self;
}

+(id) actionWithAction: (CCActionInterval*) action
			 limitFrom: (GLfloat) startOfRange
					to: (GLfloat) endOfRange {
	return [[[self alloc] initWithAction: action limitFrom: startOfRange to: endOfRange] autorelease];
}

-(void) update: (ccTime) t {
	[other update: (rangeStart + (rangeSpan * t))];
}

- (CCActionInterval *) reverse {
	return [[self class] actionWithAction: other limitFrom: (rangeStart + rangeSpan) to: rangeStart];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone:zone] initWithAction: other limitFrom: rangeStart to: (rangeStart + rangeSpan)];
}

@end


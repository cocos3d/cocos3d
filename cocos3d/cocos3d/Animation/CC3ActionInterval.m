/*
 * CC3ActionInterval.m
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
 * See header file CC3ActionInterval.h for full API documentation.
 */

#import "CC3ActionInterval.h"
#import "CC3Node.h"


#pragma mark -
#pragma mark CCActionInterval

@implementation CCActionInterval (CC3)

-(CC3Node*) targetCC3Node { return (CC3Node*)self.target; }

@end


#pragma mark -
#pragma mark CC3TransformVectorAction

@interface CC3TransformVectorAction (TemplateMethods)
@property(nonatomic, assign) CC3Vector targetVector;
@end

@implementation CC3TransformVectorAction

-(id) initWithDuration: (ccTime) t differenceVector: (CC3Vector) aVector {
	if( (self = [super initWithDuration: t]) ) {
		diffVector = aVector;
	}
	return self;
}

+(id) actionWithDuration: (ccTime) t differenceVector: (CC3Vector) aVector {
	return [[[self alloc] initWithDuration: t differenceVector: aVector] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration] differenceVector: diffVector];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration differenceVector: CC3VectorNegate(diffVector)];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	startVector = self.targetVector;
}

-(void) update: (ccTime) t {	
	self.targetVector = CC3VectorAdd(startVector, CC3VectorScaleUniform(diffVector, t));
}

-(CC3Vector) targetVector { return kCC3VectorZero; }

-(void) setTargetVector: (CC3Vector) aVector {}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ start: %@, diff: %@", [self class],
			NSStringFromCC3Vector(startVector), NSStringFromCC3Vector(diffVector)];
}

@end


#pragma mark -
#pragma mark CC3TransformBy

@implementation CC3TransformBy
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

-(CC3Vector) targetVector { return self.targetCC3Node.location; }

-(void) setTargetVector: (CC3Vector) aLocation { self.targetCC3Node.location = aLocation; }

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

-(CC3Vector) targetVector { return self.targetCC3Node.rotation; }

-(void) setTargetVector: (CC3Vector) aRotation { self.targetCC3Node.rotation = aRotation; }

@end


#pragma mark -
#pragma mark CC3ScaleBy

@implementation CC3ScaleBy

/**
 * Scale is multiplicative. Scaling BY 5 means take whatever the current scale is
 * and multiply it by 5. If the previous scale was 3, then the future scale
 * will be 15, not 8 if the numbers were simply added as in the superclass.
 */
-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	CC3Vector endVector = CC3VectorScale(startVector, diffVector);
	scaledDiffVector = CC3VectorDifference(endVector, startVector);
}

-(id) initWithDuration: (ccTime) t scaleBy: (CC3Vector) aScale {
	return [self initWithDuration: t differenceVector: aScale];
}

+(id) actionWithDuration: (ccTime) t scaleBy: (CC3Vector) aScale {
	return [self actionWithDuration: t differenceVector: aScale];
}

-(id) initWithDuration: (ccTime) t scaleUniformlyBy: (GLfloat) aScale {
	return [self initWithDuration: t scaleBy: cc3v(aScale, aScale, aScale)];
}

+(id) actionWithDuration: (ccTime) t scaleUniformlyBy: (GLfloat) aScale {
	return [self actionWithDuration: t scaleBy: cc3v(aScale, aScale, aScale)];
}

-(void) update: (ccTime) t {	
	self.targetVector = CC3VectorAdd(startVector, CC3VectorScaleUniform(scaledDiffVector, t));
}

-(CC3Vector) targetVector { return self.targetCC3Node.scale; }

-(void) setTargetVector: (CC3Vector) aScale { self.targetCC3Node.scale = aScale; }

@end


#pragma mark -
#pragma mark CC3RotateByAngle

@implementation CC3RotateByAngle

-(id) initWithDuration: (ccTime) t rotateByAngle: (GLfloat) anAngle {
	return [self initWithDuration: t rotateByAngle: anAngle aroundAxis: kCC3VectorNull];
}

+(id) actionWithDuration: (ccTime) t rotateByAngle: (GLfloat) anAngle {
	return [[[self alloc] initWithDuration: t rotateByAngle: anAngle] autorelease];
}

-(id) initWithDuration: (ccTime) t rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	if( (self = [super initWithDuration: t]) ) {
		diffAngle = anAngle;
		rotationAxis = anAxis;
	}
	return self;
}

+(id) actionWithDuration: (ccTime) t rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	return [[[self alloc] initWithDuration: t rotateByAngle: anAngle aroundAxis: anAxis] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration]
												  rotateByAngle: diffAngle
													 aroundAxis: rotationAxis];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration
							  rotateByAngle: -diffAngle
								 aroundAxis: rotationAxis];
}

/** If no explicit rotation axis was set, retrieve it from the target node. */
-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	activeRotationAxis = CC3VectorIsNull(rotationAxis) ? aTarget.rotationAxis : rotationAxis;
	prevTime = 0;
}

-(void) update: (ccTime) t {
	GLfloat deltaTime = t - prevTime;
	GLfloat deltaAngle = diffAngle * deltaTime;
	[self.targetCC3Node rotateByAngle: deltaAngle aroundAxis: activeRotationAxis];
	prevTime = t;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ angle: %.3f, axis: %@",
			[self class], diffAngle, NSStringFromCC3Vector(rotationAxis)];
}

@end


#pragma mark -
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
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration]
													  endVector: endVector];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration endVector: startVector];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	diffVector = CC3VectorDifference(endVector, startVector);
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ start: %@, end: %@, diff: %@", [self class],
			NSStringFromCC3Vector(startVector), NSStringFromCC3Vector(endVector),
			NSStringFromCC3Vector(diffVector)];
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

-(CC3Vector) targetVector { return self.targetCC3Node.location; }

-(void) setTargetVector: (CC3Vector) aLocation { self.targetCC3Node.location = aLocation; }

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
	diffVector = CC3VectorRotationalDifference(endVector, startVector);
}

-(CC3Vector) targetVector { return self.targetCC3Node.rotation; }

-(void) setTargetVector: (CC3Vector) aRotation { self.targetCC3Node.rotation = aRotation; }

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

-(id) initWithDuration: (ccTime) t scaleUniformlyTo: (GLfloat) aScale {
	return [self initWithDuration: t scaleTo: cc3v(aScale, aScale, aScale)];
}

+(id) actionWithDuration: (ccTime) t scaleUniformlyTo: (GLfloat) aScale {
	return [self actionWithDuration: t scaleTo: cc3v(aScale, aScale, aScale)];
}

-(CC3Vector) targetVector { return self.targetCC3Node.scale; }

-(void) setTargetVector: (CC3Vector) aScale { self.targetCC3Node.scale = aScale; }

@end


#pragma mark -
#pragma mark CC3RotateToAngle

@implementation CC3RotateToAngle

-(id) initWithDuration: (ccTime) t rotateToAngle: (GLfloat) anAngle {
	if( (self = [super initWithDuration: t]) ) {
		endAngle = anAngle;
	}
	return self;
}

+(id) actionWithDuration: (ccTime) t rotateToAngle: (GLfloat) anAngle {
	return [[[self alloc] initWithDuration: t rotateToAngle: anAngle] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration]
												  rotateToAngle: endAngle];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration rotateToAngle: startAngle];
}

// We want to rotate the minimal angles to get from the startAngle to the endAngle,
// taking into consideration the cyclical nature of rotation. Therefore, a rotation
// from 10 degrees to 350 degrees should travel -20 degrees, not the +340 degrees
// that would result from simple subtraction.
-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	startAngle = aTarget.rotationAngle;
	diffAngle = CC3SemiCyclicAngle(endAngle - startAngle);
}

-(void) update: (ccTime) t {	
	self.targetCC3Node.rotationAngle = startAngle + (diffAngle * t);
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ start: %.3f, end: %.3f, diff: %.3f",
			[self class], startAngle, endAngle, diffAngle];
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

-(CC3Vector) targetVector { return self.targetCC3Node.forwardDirection;
}

-(void) setTargetVector: (CC3Vector) aDirection { self.targetCC3Node.forwardDirection = aDirection; }

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
#pragma mark CC3MoveDirectionallyBy

@interface CC3MoveDirectionallyBy (TemplateMethods)
@property(nonatomic, readonly) CC3Vector targetDirection;
@end

@implementation CC3MoveDirectionallyBy

-(id) initWithDuration: (ccTime) t moveBy: (GLfloat) aDistance {
	if( (self = [super initWithDuration: t]) ) {
		distance = aDistance;
	}
	return self;
}

+(id) actionWithDuration: (ccTime) t moveBy: (GLfloat) aDistance {
	return [[(CC3MoveDirectionallyBy*)[self alloc] initWithDuration: t moveBy: aDistance] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [(CC3MoveDirectionallyBy*)[[self class] allocWithZone: zone] initWithDuration: [self duration]
																				  moveBy: distance];
}

-(id) reverse {
	return [[(CC3MoveDirectionallyBy*)[[self class] alloc]
					initWithDuration: self.duration
					moveBy: -distance] autorelease];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	prevTime = 0;
}

-(void) update: (ccTime) t {
	GLfloat deltaTime = t - prevTime;
	GLfloat deltaDist = distance * deltaTime;
	CC3Vector moveDir = CC3VectorNormalize(self.targetDirection);
	CC3Vector prevLoc = self.targetCC3Node.location;
	self.targetCC3Node.location = CC3VectorAdd(prevLoc, CC3VectorScaleUniform(moveDir, deltaDist));
	prevTime = t;
	
	LogTrace(@"%@: time: %.3f, delta time: %.3f, delta dist: %.3f, was at: %@, now at: %@",
				  self, t, deltaTime, deltaDist,
				  NSStringFromCC3Vector(prevLoc),
				  NSStringFromCC3Vector(self.targetCC3Node.location));
}

/** The direction in which to move. Subclasses will override. */
-(CC3Vector) targetDirection { return kCC3VectorZero; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ distance: %.3f", [self class], distance];
}

@end


#pragma mark -
#pragma mark CC3MoveForwardBy

@implementation CC3MoveForwardBy

-(CC3Vector) targetDirection { return self.targetCC3Node.forwardDirection; }

@end


#pragma mark -
#pragma mark CC3MoveRightBy

@implementation CC3MoveRightBy

-(CC3Vector) targetDirection { return self.targetCC3Node.rightDirection; }

@end


#pragma mark -
#pragma mark CC3MoveUpBy

@implementation CC3MoveUpBy

-(CC3Vector) targetDirection { return self.targetCC3Node.upDirection; }

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
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration] colorTo: endColor];
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

-(ccColor4F) targetColor { return self.targetNode.ambientColor; }

-(void) setTargetColor: (ccColor4F) aColor { self.targetNode.ambientColor = aColor; }

@end


#pragma mark -
#pragma mark CC3TintDiffuseTo

@implementation CC3TintDiffuseTo

-(ccColor4F) targetColor { return self.targetNode.diffuseColor; }

-(void) setTargetColor: (ccColor4F) aColor { self.targetNode.diffuseColor = aColor; }

@end


#pragma mark -
#pragma mark CC3TintSpecularTo

@implementation CC3TintSpecularTo

-(ccColor4F) targetColor { return self.targetNode.specularColor; }

-(void) setTargetColor: (ccColor4F) aColor { self.targetNode.specularColor = aColor; }

@end


#pragma mark -
#pragma mark CC3TintEmissionTo

@implementation CC3TintEmissionTo

-(ccColor4F) targetColor { return self.targetNode.emissionColor; }

-(void) setTargetColor: (ccColor4F) aColor { self.targetNode.emissionColor = aColor; }

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


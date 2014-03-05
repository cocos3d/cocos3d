/*
 * CC3Actions.m
 *
 * cocos3d 2.0.0
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
 * See header file CC3Actions.h for full API documentation.
 */

#import "CC3Actions.h"
#import "CC3NodeAnimation.h"


#pragma mark -
#pragma mark CCAction

@implementation CCAction (CC3)

-(CC3Node*) targetCC3Node { return (CC3Node*)self.target; }

@end


#pragma mark -
#pragma mark CC3TransformVectorAction

@interface CC3TransformVectorAction (TemplateMethods)
@property(nonatomic, assign) CC3Vector targetVector;
@end

@implementation CC3TransformVectorAction

-(id) initWithDuration: (CCTime) t differenceVector: (CC3Vector) aVector {
	if( (self = [super initWithDuration: t]) ) {
		_diffVector = aVector;
	}
	return self;
}

+(id) actionWithDuration: (CCTime) t differenceVector: (CC3Vector) aVector {
	return [[[self alloc] initWithDuration: t differenceVector: aVector] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration] differenceVector: _diffVector];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration differenceVector: CC3VectorNegate(_diffVector)];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	_startVector = self.targetVector;
}

-(void) update: (CCTime) t {	
	self.targetVector = CC3VectorAdd(_startVector, CC3VectorScaleUniform(_diffVector, t));
}

-(CC3Vector) targetVector { return kCC3VectorZero; }

-(void) setTargetVector: (CC3Vector) aVector {}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ start: %@, diff: %@", [self class],
			NSStringFromCC3Vector(_startVector), NSStringFromCC3Vector(_diffVector)];
}

@end


#pragma mark -
#pragma mark CC3TransformBy

@implementation CC3TransformBy
@end


#pragma mark -
#pragma mark CC3MoveBy

@implementation CC3MoveBy

-(id) initWithDuration: (CCTime) t moveBy: (CC3Vector) aTranslation {
	return [self initWithDuration: t differenceVector: aTranslation];
}

+(id) actionWithDuration: (CCTime) t moveBy: (CC3Vector) aTranslation {
	return [self actionWithDuration: t differenceVector: aTranslation];
}

-(CC3Vector) targetVector { return self.targetCC3Node.location; }

-(void) setTargetVector: (CC3Vector) aLocation { self.targetCC3Node.location = aLocation; }

@end


#pragma mark -
#pragma mark CC3RotateBy

@implementation CC3RotateBy

-(id) initWithDuration: (CCTime) t rotateBy: (CC3Vector) aRotation {
	return [self initWithDuration: t differenceVector: aRotation];
}

+(id) actionWithDuration: (CCTime) t rotateBy: (CC3Vector) aRotation {
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
	CC3Vector endVector = CC3VectorScale(_startVector, _diffVector);
	_scaledDiffVector = CC3VectorDifference(endVector, _startVector);
}

-(id) initWithDuration: (CCTime) t scaleBy: (CC3Vector) aScale {
	return [self initWithDuration: t differenceVector: aScale];
}

+(id) actionWithDuration: (CCTime) t scaleBy: (CC3Vector) aScale {
	return [self actionWithDuration: t differenceVector: aScale];
}

-(id) initWithDuration: (CCTime) t scaleUniformlyBy: (GLfloat) aScale {
	return [self initWithDuration: t scaleBy: cc3v(aScale, aScale, aScale)];
}

+(id) actionWithDuration: (CCTime) t scaleUniformlyBy: (GLfloat) aScale {
	return [self actionWithDuration: t scaleBy: cc3v(aScale, aScale, aScale)];
}

-(void) update: (CCTime) t {	
	self.targetVector = CC3VectorAdd(_startVector, CC3VectorScaleUniform(_scaledDiffVector, t));
}

-(CC3Vector) targetVector { return self.targetCC3Node.scale; }

-(void) setTargetVector: (CC3Vector) aScale { self.targetCC3Node.scale = aScale; }

@end


#pragma mark -
#pragma mark CC3RotateByAngle

@implementation CC3RotateByAngle

-(id) initWithDuration: (CCTime) t rotateByAngle: (GLfloat) anAngle {
	return [self initWithDuration: t rotateByAngle: anAngle aroundAxis: kCC3VectorNull];
}

+(id) actionWithDuration: (CCTime) t rotateByAngle: (GLfloat) anAngle {
	return [[[self alloc] initWithDuration: t rotateByAngle: anAngle] autorelease];
}

-(id) initWithDuration: (CCTime) t rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	if( (self = [super initWithDuration: t]) ) {
		_diffAngle = anAngle;
		_rotationAxis = anAxis;
	}
	return self;
}

+(id) actionWithDuration: (CCTime) t rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	return [[[self alloc] initWithDuration: t rotateByAngle: anAngle aroundAxis: anAxis] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration]
												  rotateByAngle: _diffAngle
													 aroundAxis: _rotationAxis];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration
							  rotateByAngle: -_diffAngle
								 aroundAxis: _rotationAxis];
}

/** If no explicit rotation axis was set, retrieve it from the target node. */
-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	_activeRotationAxis = CC3VectorIsNull(_rotationAxis) ? aTarget.rotationAxis : _rotationAxis;
	_prevTime = 0;
}

-(void) update: (CCTime) t {
	GLfloat deltaTime = t - _prevTime;
	GLfloat deltaAngle = _diffAngle * deltaTime;
	[self.targetCC3Node rotateByAngle: deltaAngle aroundAxis: _activeRotationAxis];
	_prevTime = t;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ angle: %.3f, axis: %@",
			[self class], _diffAngle, NSStringFromCC3Vector(_rotationAxis)];
}

@end


#pragma mark -
#pragma mark CC3TransformTo

@implementation CC3TransformTo

-(id) initWithDuration: (CCTime) t endVector: (CC3Vector) aVector {
	if( (self = [super initWithDuration: t]) ) {
		_endVector = aVector;
	}
	return self;
}

+(id) actionWithDuration: (CCTime) t endVector: (CC3Vector) aVector {
	return [[[self alloc] initWithDuration: t endVector: aVector] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration]
													  endVector: _endVector];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration endVector: _startVector];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	_diffVector = CC3VectorDifference(_endVector, _startVector);
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ start: %@, end: %@, diff: %@", [self class],
			NSStringFromCC3Vector(_startVector), NSStringFromCC3Vector(_endVector),
			NSStringFromCC3Vector(_diffVector)];
}

@end


#pragma mark -
#pragma mark CC3MoveTo

@implementation CC3MoveTo

-(id) initWithDuration: (CCTime) t moveTo: (CC3Vector) aLocation {
	return [self initWithDuration: t endVector: aLocation];
}

+(id) actionWithDuration: (CCTime) t moveTo: (CC3Vector) aLocation {
	return [self actionWithDuration: t endVector: aLocation];
}

-(CC3Vector) targetVector { return self.targetCC3Node.location; }

-(void) setTargetVector: (CC3Vector) aLocation { self.targetCC3Node.location = aLocation; }

@end


#pragma mark -
#pragma mark CC3RotateTo

@implementation CC3RotateTo

-(id) initWithDuration: (CCTime) t rotateTo: (CC3Vector) aRotation {
	return [self initWithDuration: t endVector: aRotation];
}

+(id) actionWithDuration: (CCTime) t rotateTo: (CC3Vector) aRotation {
	return [self actionWithDuration: t endVector: aRotation];
}

// We want to rotate the minimal angles to get from the startVector to the endVector,
// taking into consideration the cyclical nature of rotation. Therefore, a rotation
// from 10 degrees to 350 degrees should travel -20 degrees, not the +340 degrees
// that would result from simple subtraction.
-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	_diffVector = CC3VectorRotationalDifference(_endVector, _startVector);
}

-(CC3Vector) targetVector { return self.targetCC3Node.rotation; }

-(void) setTargetVector: (CC3Vector) aRotation { self.targetCC3Node.rotation = aRotation; }

@end


#pragma mark -
#pragma mark CC3ScaleTo

@implementation CC3ScaleTo

-(id) initWithDuration: (CCTime) t scaleTo: (CC3Vector) aScale {
	return [self initWithDuration: t endVector: aScale];
}

+(id) actionWithDuration: (CCTime) t scaleTo: (CC3Vector) aScale {
	return [self actionWithDuration: t endVector: aScale];
}

-(id) initWithDuration: (CCTime) t scaleUniformlyTo: (GLfloat) aScale {
	return [self initWithDuration: t scaleTo: cc3v(aScale, aScale, aScale)];
}

+(id) actionWithDuration: (CCTime) t scaleUniformlyTo: (GLfloat) aScale {
	return [self actionWithDuration: t scaleTo: cc3v(aScale, aScale, aScale)];
}

-(CC3Vector) targetVector { return self.targetCC3Node.scale; }

-(void) setTargetVector: (CC3Vector) aScale { self.targetCC3Node.scale = aScale; }

@end


#pragma mark -
#pragma mark CC3RotateToAngle

@implementation CC3RotateToAngle

-(id) initWithDuration: (CCTime) t rotateToAngle: (GLfloat) anAngle {
	if( (self = [super initWithDuration: t]) ) {
		_endAngle = anAngle;
	}
	return self;
}

+(id) actionWithDuration: (CCTime) t rotateToAngle: (GLfloat) anAngle {
	return [[[self alloc] initWithDuration: t rotateToAngle: anAngle] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration]
												  rotateToAngle: _endAngle];
}

-(id) reverse {
	return [[self class] actionWithDuration: self.duration rotateToAngle: _startAngle];
}

// We want to rotate the minimal angles to get from the startAngle to the endAngle,
// taking into consideration the cyclical nature of rotation. Therefore, a rotation
// from 10 degrees to 350 degrees should travel -20 degrees, not the +340 degrees
// that would result from simple subtraction.
-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	_startAngle = aTarget.rotationAngle;
	_diffAngle = CC3SemiCyclicAngle(_endAngle - _startAngle);
}

-(void) update: (CCTime) t {	
	self.targetCC3Node.rotationAngle = _startAngle + (_diffAngle * t);
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ start: %.3f, end: %.3f, diff: %.3f",
			[self class], _startAngle, _endAngle, _diffAngle];
}

@end


#pragma mark -
#pragma mark CC3RotateToLookTowards

@implementation CC3RotateToLookTowards

-(id) initWithDuration: (CCTime) t forwardDirection: (CC3Vector) aDirection {
	return [self initWithDuration: t endVector: CC3VectorNormalize(aDirection)];
}

+(id) actionWithDuration: (CCTime) t forwardDirection: (CC3Vector) aDirection {
	return [self actionWithDuration: t endVector: CC3VectorNormalize(aDirection)];
}

-(CC3Vector) targetVector { return self.targetCC3Node.forwardDirection;
}

-(void) setTargetVector: (CC3Vector) aDirection { self.targetCC3Node.forwardDirection = aDirection; }

@end


#pragma mark -
#pragma mark CC3RotateToLookAt

@implementation CC3RotateToLookAt

-(id) initWithDuration: (CCTime) t targetLocation: (CC3Vector) aLocation {
	return [self initWithDuration: t endVector: aLocation];
}

+(id) actionWithDuration: (CCTime) t targetLocation: (CC3Vector) aLocation {
	return [self actionWithDuration: t endVector: aLocation];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	_endVector = CC3VectorNormalize(CC3VectorDifference(_endVector, aTarget.globalLocation));
	[super startWithTarget: aTarget];
}

@end


#pragma mark -
#pragma mark CC3MoveDirectionallyBy

@interface CC3MoveDirectionallyBy (TemplateMethods)
@property(nonatomic, readonly) CC3Vector targetDirection;
@end

@implementation CC3MoveDirectionallyBy

-(id) initWithDuration: (CCTime) t moveBy: (GLfloat) aDistance {
	if( (self = [super initWithDuration: t]) ) {
		_distance = aDistance;
	}
	return self;
}

+(id) actionWithDuration: (CCTime) t moveBy: (GLfloat) aDistance {
	return [[(CC3MoveDirectionallyBy*)[self alloc] initWithDuration: t moveBy: aDistance] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [(CC3MoveDirectionallyBy*)[[self class] allocWithZone: zone] initWithDuration: [self duration]
																				  moveBy: _distance];
}

-(id) reverse {
	return [[(CC3MoveDirectionallyBy*)[[self class] alloc] initWithDuration: self.duration
																	 moveBy: -_distance] autorelease];
}

-(void) startWithTarget:(CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	_prevTime = 0;
}

-(void) update: (CCTime) t {
	GLfloat deltaTime = t - _prevTime;
	GLfloat deltaDist = _distance * deltaTime;
	CC3Vector moveDir = CC3VectorNormalize(self.targetDirection);
	CC3Vector prevLoc = self.targetCC3Node.location;
	self.targetCC3Node.location = CC3VectorAdd(prevLoc, CC3VectorScaleUniform(moveDir, deltaDist));
	_prevTime = t;
	
	LogTrace(@"%@: time: %.3f, delta time: %.3f, delta dist: %.3f, was at: %@, now at: %@",
				  self, t, deltaTime, deltaDist,
				  NSStringFromCC3Vector(prevLoc),
				  NSStringFromCC3Vector(self.targetCC3Node.location));
}

/** The direction in which to move. Subclasses will override. */
-(CC3Vector) targetDirection { return kCC3VectorZero; }

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ distance: %.3f", [self class], _distance];
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
	CC3Assert(NO, @"%@ is abstract. Property targetColor must be implemented in a concrete subclass", self);
	return kCCC4FBlackTransparent;
}

-(void) setTargetColor: (ccColor4F) aColor {
	CC3Assert(NO, @"%@ is abstract. Property targetColor must be implemented in a concrete subclass", self);
}

-(id) initWithDuration: (CCTime) t colorTo: (ccColor4F) aColor {
	if( (self = [super initWithDuration: t]) ) {
		_endColor = aColor;
	}
	return self;
}

+(id) actionWithDuration:(CCTime) t colorTo: (ccColor4F) aColor {
	return [[[self alloc] initWithDuration: t colorTo: aColor] autorelease];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: [self duration] colorTo: _endColor];
}

-(void) startWithTarget: (id) aTarget {
	[super startWithTarget: aTarget];
	_startColor = self.targetColor;
}

-(void) update: (CCTime) t {
	self.targetColor = CCC4FBlend(_startColor, _endColor, t);
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

@synthesize trackID = _trackID, isReversed=_isReversed;

-(id) initWithDuration: (CCTime) t { return [self initWithDuration: t onTrack: 0]; }

+(id) actionWithDuration: (CCTime) t { return [self actionWithDuration: t onTrack: 0]; }

-(id) initWithDuration: (CCTime) t onTrack: (GLuint) trackID {
	if ( (self = [super initWithDuration: t]) ) {
		_trackID = trackID;
		_isReversed = NO;
	}
	return self;
}

+(id) actionWithDuration: (CCTime) t onTrack: (GLuint) trackID {
	return [[[self alloc] initWithDuration: t onTrack: trackID] autorelease];
}

+(id) actionWithDuration: (CCTime) t limitFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange {
	return [self actionWithDuration: t onTrack: 0 limitFrom: startOfRange to: endOfRange];
}

+(id) actionWithDuration: (CCTime) t onTrack: (GLuint) trackID limitFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange {
	return [[self actionWithDuration: t onTrack: trackID] asActionLimitedFrom: startOfRange to: endOfRange];
}

-(CCActionInterval*) asActionLimitedFrom: (GLfloat) startOfRange to: (GLfloat) endOfRange {
	return [CC3ActionRangeLimit actionWithAction: self limitFrom: startOfRange to: endOfRange];
}

-(void) update: (CCTime) t {
	[self.targetCC3Node establishAnimationFrameAt: (_isReversed ? (1.0 - t) : t) onTrack: _trackID];
}

-(CCActionInterval*) reverse {
	CC3Animate* newAnim = [[self class] actionWithDuration: self.duration];
	newAnim.isReversed = !self.isReversed;
	return newAnim;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3Animate* newAnim = [[[self class] allocWithZone: zone] initWithDuration: self.duration];
	newAnim.isReversed = self.isReversed;
	return newAnim;
}

@end


#pragma mark -
#pragma mark CC3AnimationBlendingFadeTrackTo

@implementation CC3AnimationBlendingFadeTrackTo

@synthesize trackID=_trackID;

-(id) initWithDuration: (CCTime) t onTrack: (GLuint) trackID blendingWeight: (GLfloat) blendingWeight {
	if ( (self = [super initWithDuration: t]) ) {
		_trackID = trackID;
		_endWeight = blendingWeight;
	}
	return self;
}

+(id) actionWithDuration: (CCTime) t onTrack: (GLuint) trackID blendingWeight: (GLfloat) blendingWeight {
	return [[[self alloc] initWithDuration: t onTrack: trackID blendingWeight: blendingWeight] autorelease];
}

-(void) startWithTarget: (CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	_startWeight = [aTarget animationBlendingWeightOnTrack: _trackID];
}

-(void) update: (CCTime) t {
	[self.targetCC3Node setAnimationBlendingWeight: (_startWeight + (t * (_endWeight - _startWeight)))
										  onTrack: _trackID];
}

-(CCActionInterval*) reverse {
	return [[self class] actionWithDuration: self.duration onTrack: _trackID blendingWeight: _startWeight];
}
	
-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: self.duration
														onTrack: _trackID
												 blendingWeight: _endWeight];
}

@end


#pragma mark -
#pragma mark CC3AnimationCrossFade

@implementation CC3AnimationCrossFade

@synthesize fromTrackID=_fromTrackID, toTrackID=_toTrackID;

-(id) initWithDuration: (CCTime) t
			 fromTrack: (GLuint) fromTrackID
			   toTrack: (GLuint) toTrackID {
	return [self initWithDuration: t fromTrack: fromTrackID toTrack: toTrackID withBlendingWeight: 1.0f];
}

-(id) initWithDuration: (CCTime) t
			 fromTrack: (GLuint) fromTrackID
			   toTrack: (GLuint) toTrackID
	withBlendingWeight: (GLfloat) toBlendingWeight {
	if ( (self = [super initWithDuration: t]) ) {
		_fromTrackID = fromTrackID;
		_toTrackID = toTrackID;
		_endWeight = toBlendingWeight;
	}
	return self;
}

+(id) actionWithDuration: (CCTime) t
			   fromTrack: (GLuint) fromTrackID
				 toTrack: (GLuint) toTrackID {
	return [self actionWithDuration: t fromTrack: fromTrackID toTrack: toTrackID withBlendingWeight: 1.0f];
}

+(id) actionWithDuration: (CCTime) t
			   fromTrack: (GLuint) fromTrackID
				 toTrack: (GLuint) toTrackID
	  withBlendingWeight: (GLfloat) toBlendingWeight {
	return [[[self alloc] initWithDuration: t
								 fromTrack: fromTrackID
								   toTrack: toTrackID
						withBlendingWeight: toBlendingWeight] autorelease];
}

-(void) startWithTarget: (CC3Node*) aTarget {
	[super startWithTarget: aTarget];
	_startWeight = [aTarget animationBlendingWeightOnTrack: _fromTrackID];
}

-(void) update: (CCTime) t {
	CC3Node* node = self.targetCC3Node;
	[node setAnimationBlendingWeight: ((1 - t) * _startWeight) onTrack: _fromTrackID];
	[node setAnimationBlendingWeight: (t * _endWeight) onTrack: _toTrackID];
}

-(CCActionInterval*) reverse {
	return [[self class] actionWithDuration: self.duration
								  fromTrack: self.toTrackID
									toTrack: self.fromTrackID
						 withBlendingWeight: _startWeight];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone: zone] initWithDuration: self.duration
													  fromTrack: self.fromTrackID
														toTrack: self.toTrackID
											 withBlendingWeight: _endWeight];
}

@end


#pragma mark -
#pragma mark CC3AnimationBlendingSetTrackTo

@implementation CC3AnimationBlendingSetTrackTo

@synthesize trackID=_trackID;

-(id) initOnTrack: (GLuint) trackID blendingWeight: (GLfloat) blendingWeight {
	if ( (self = [super init]) ) {
		_trackID = trackID;
		_endWeight = blendingWeight;
	}
	return self;
}

+(id) actionOnTrack: (GLuint) trackID blendingWeight: (GLfloat) blendingWeight {
	return [[[self alloc] initOnTrack: trackID blendingWeight: blendingWeight] autorelease];
}

-(void) update: (CCTime) t {
	[self.targetCC3Node setAnimationBlendingWeight: _endWeight onTrack: _trackID];
}

@end


#pragma mark -
#pragma mark CC3EnableAnimationTrack

@implementation CC3EnableAnimationTrack

@synthesize trackID=_trackID;

-(id) initOnTrack: (GLuint) trackID {
	if ( (self = [super init]) ) {
		_trackID = trackID;
	}
	return self;
}

+(id) actionOnTrack: (GLuint) trackID { return [[[self alloc] initOnTrack: trackID] autorelease]; }

-(void) update: (CCTime) t { [self.targetCC3Node enableAllAnimationOnTrack: _trackID]; }

@end


#pragma mark -
#pragma mark CC3DisableAnimationTrack

@implementation CC3DisableAnimationTrack

@synthesize trackID=_trackID;

-(id) initOnTrack: (GLuint) trackID {
	if ( (self = [super init]) ) {
		_trackID = trackID;
	}
	return self;
}

+(id) actionOnTrack: (GLuint) trackID { return [[[self alloc] initOnTrack: trackID] autorelease]; }

-(void) update: (CCTime) t { [self.targetCC3Node disableAllAnimationOnTrack: _trackID]; }

@end



#pragma mark -
#pragma mark CC3ActionRangeLimit

@implementation CC3ActionRangeLimit

-(id) initWithAction: (CCActionInterval*) action
		   limitFrom: (GLfloat) startOfRange
				  to: (GLfloat) endOfRange {
	if ( (self = [super initWithAction: action]) ) {
		_rangeStart = startOfRange;
		_rangeSpan = endOfRange - startOfRange;
	}
	return self;
}

+(id) actionWithAction: (CCActionInterval*) action
			 limitFrom: (GLfloat) startOfRange
					to: (GLfloat) endOfRange {
	return [[[self alloc] initWithAction: action limitFrom: startOfRange to: endOfRange] autorelease];
}

-(void) update: (CCTime) t { [self.inner update: (_rangeStart + (_rangeSpan * t))]; }

- (CCActionInterval *) reverse {
	return [[self class] actionWithAction: self.inner limitFrom: (_rangeStart + _rangeSpan) to: _rangeStart];
}

-(id) copyWithZone: (NSZone*) zone {
	return [[[self class] allocWithZone:zone] initWithAction: self.inner
												   limitFrom: _rangeStart
														  to: (_rangeStart + _rangeSpan)];
}

#if COCOS2D_VERSION < 0x020100
-(CCActionInterval*) inner { return other; }
#endif

@end


#pragma mark -
#pragma mark CC3Remove

@implementation CC3Remove

-(void) update: (CCTime) t { [self.targetCC3Node remove]; }

@end

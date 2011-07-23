/**
 * CC3Node.m
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
 * See header file CC3Node.h for full API documentation.
 */

#import "CC3World.h"
#import "CC3BoundingVolumes.h"
#import "CC3NodeAnimation.h"
#import "CCActionManager.h"
#import "CC3OpenGLES11Foundation.h"
#import "CC3OpenGLES11Engine.h"
#import "CGPointExtension.h"


#pragma mark CC3Node

@interface CC3Identifiable (TemplateMethods)
-(void) populateFrom: (CC3Identifiable*) another;
@end

// Template methods that can be overridden and invoked by subclasses
@interface CC3Node (TemplateMethods)
-(void) applyLocalTransforms;
-(void) applyTranslation;
-(void) applyRotation;
-(void) applyScaling;
-(void) updateWithVisitor: (CC3NodeTransformingVisitor*) visitor;
-(id) transformVisitorClass;
-(void) transformMatrixChanged;
-(void) updateGlobalOrientation;
-(void) updateGlobalLocation;
-(void) updateGlobalRotation;
-(void) updateGlobalScale;
-(void) updateBoundingVolume;
-(void) drawChildrenWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) transformAndDrawWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawLocalContentWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) didAddDescendant: (CC3Node*) aNode;
-(void) didRemoveDescendant: (CC3Node*) aNode;
-(void) descendantDidModifySequencingCriteria: (CC3Node*) aNode;
-(id) rotatorClass;
-(void) populateFrom: (CC3Node*) another;
-(void) copyChildrenFrom: (CC3Node*) another;
-(void) resumeActions;
-(void) pauseActions;
@property(nonatomic, readonly) CC3Rotator* rotator;
@property(nonatomic, readonly) CC3GLMatrix* globalRotationMatrix;
@end

@implementation CC3Node

@synthesize location, scale, globalLocation, globalScale;
@synthesize boundingVolume, projectedLocation, transformMatrix, animation;
@synthesize visible, isTouchEnabled, isAnimationEnabled, isRunning;
@synthesize parent, children;

-(void) dealloc {
	[children release];
	parent = nil;						// not retained
	[transformMatrix release];
	[transformMatrixInverted release];
	[globalRotationMatrix release];
	[rotator release];
	[boundingVolume release];
	[animation release];
	[super dealloc];
}

-(void) setLocation: (CC3Vector) aLocation {
	location = aLocation;
	[self markTransformDirty];
}

-(CC3Vector) rotation {
	return rotator.rotation;
}

-(void) setRotation: (CC3Vector) aRotation {
	rotator.rotation = aRotation;
	[self markTransformDirty];
}

-(CC3Vector4) quaternion {
	return rotator.quaternion;
}

-(void) setQuaternion: (CC3Vector4) aQuaternion {
	rotator.quaternion = aQuaternion;
	[self markTransformDirty];
}

-(CC3Vector) globalRotation {
	return [self.globalRotationMatrix extractRotation];
}

-(void) setScale: (CC3Vector) aScale {
	scale = aScale;
	[self markTransformDirty];
}

-(GLfloat) uniformScale {
	if (self.isUniformlyScaledLocally) {
		return scale.x;
	} else {
		return CC3VectorLength(scale) / kCC3VectorUnitCubeLength;
	}
}

-(void) setUniformScale:(GLfloat) aValue {
	self.scale = cc3v(aValue, aValue, aValue);
}

-(BOOL) isUniformlyScaledLocally {
	return (scale.x == scale.y && scale.x == scale.z);
}

-(BOOL) isUniformlyScaledGlobally {
	return self.isUniformlyScaledLocally && (parent ? parent.isUniformlyScaledGlobally : YES);
}

-(BOOL) isTransformRigid {
	return (scale.x == 1.0f && scale.y == 1.0f && scale.z == 1.0f) && (parent ? parent.isTransformRigid : YES);
}

-(void) setBoundingVolume:(CC3NodeBoundingVolume *) aBoundingVolume {
	id oldBV = boundingVolume;
	boundingVolume = [aBoundingVolume retain];
	[oldBV release];
	boundingVolume.node = self;
}

// Derived from projected location, but only if in front of the camera
-(CGPoint) projectedPosition {
	return (projectedLocation.z > 0.0)
				? ccp(projectedLocation.x, projectedLocation.y)
				: ccp(-CGFLOAT_MAX, -CGFLOAT_MAX);
}

-(void) setIsRunning: (BOOL) shouldRun {
	if (!isRunning && shouldRun) [self resumeActions];
	if (isRunning && !shouldRun) [self pauseActions];
	isRunning = shouldRun;
	if (children) {
		for (CC3Node* child in children) {
			child.isRunning = isRunning;
		}
	}
}

-(BOOL) shouldCullBackFaces {
	if (children) {
		for (CC3Node* child in children) {
			if (child.shouldCullBackFaces == NO) {
				return NO;
			}
		}
	}
	return YES;
}

-(void) setShouldCullBackFaces: (BOOL) shouldCull {
	if (children) {
		for (CC3Node* child in children) {
			child.shouldCullBackFaces = shouldCull;
		}
	}
}

-(BOOL) shouldCullFrontFaces {
	if (children) {
		for (CC3Node* child in children) {
			if (child.shouldCullFrontFaces) {
				return YES;
			}
		}
	}
	return NO;
}

-(void) setShouldCullFrontFaces: (BOOL) shouldCull {
	if (children) {
		for (CC3Node* child in children) {
			child.shouldCullFrontFaces = shouldCull;
		}
	}
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ location: %@, global: %@, %@, scale: %@, projected to: %@, bounded by: %@",
			[super description],
			NSStringFromCC3Vector(self.location),
			NSStringFromCC3Vector(self.globalLocation),
			rotator,
			NSStringFromCC3Vector(self.scale),
			NSStringFromCGPoint(self.projectedPosition),
			boundingVolume];
}


#pragma mark Matierial coloring

-(BOOL) shouldUseLighting {
	if (children) {
		for (CC3Node* child in children) {
			if(child.shouldUseLighting) {
				return YES;
			}
		}
	}
	return NO;
}

-(void) setShouldUseLighting: (BOOL) useLighting {
	if (children) {
		for (CC3Node* child in children) {
			child.shouldUseLighting = useLighting;
		}
	}
}

-(ccColor4F) ambientColor {
	ccColor4F col = kCCC4FBlackTransparent;
	int childCnt = 0;
	if (children && (childCnt = children.count) > 0) {
		GLfloat rSum, bSum, gSum, aSum;
		rSum = bSum = gSum = aSum = 0.0f;
		for (CC3Node* child in children) {
			ccColor4F childColor = child.ambientColor;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
			aSum += childColor.a;
		}
		col = CCC4FMake(rSum / childCnt, gSum / childCnt, bSum / childCnt, aSum / childCnt);
	}
	return col;
}

-(void) setAmbientColor: (ccColor4F) color {
	if (children) {
		for (CC3Node* child in children) {
			child.ambientColor = color;
		}
	}
}

-(ccColor4F) diffuseColor {
	ccColor4F col = kCCC4FBlackTransparent;
	int childCnt = 0;
	if (children && (childCnt = children.count) > 0) {
		GLfloat rSum, bSum, gSum, aSum;
		rSum = bSum = gSum = aSum = 0.0f;
		for (CC3Node* child in children) {
			ccColor4F childColor = child.diffuseColor;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
			aSum += childColor.a;
		}
		col = CCC4FMake(rSum / childCnt, gSum / childCnt, bSum / childCnt, aSum / childCnt);
	}
	return col;
}

-(void) setDiffuseColor: (ccColor4F) color {
	if (children) {
		for (CC3Node* child in children) {
			child.diffuseColor = color;
		}
	}
}

-(ccColor4F) specularColor {
	ccColor4F col = kCCC4FBlackTransparent;
	int childCnt = 0;
	if (children && (childCnt = children.count) > 0) {
		GLfloat rSum, bSum, gSum, aSum;
		rSum = bSum = gSum = aSum = 0.0f;
		for (CC3Node* child in children) {
			ccColor4F childColor = child.specularColor;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
			aSum += childColor.a;
		}
		col = CCC4FMake(rSum / childCnt, gSum / childCnt, bSum / childCnt, aSum / childCnt);
	}
	return col;
}

-(void) setSpecularColor: (ccColor4F) color {
	if (children) {
		for (CC3Node* child in children) {
			child.specularColor = color;
		}
	}
}

-(ccColor4F) emissionColor {
	ccColor4F col = kCCC4FBlackTransparent;
	int childCnt = 0;
	if (children && (childCnt = children.count) > 0) {
		GLfloat rSum, bSum, gSum, aSum;
		rSum = bSum = gSum = aSum = 0.0f;
		for (CC3Node* child in children) {
			ccColor4F childColor = child.emissionColor;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
			aSum += childColor.a;
		}
		col = CCC4FMake(rSum / childCnt, gSum / childCnt, bSum / childCnt, aSum / childCnt);
	}
	return col;
}

-(void) setEmissionColor: (ccColor4F) color {
	if (children) {
		for (CC3Node* child in children) {
			child.emissionColor = color;
		}
	}
}

-(CC3Vector) globalLightLocation {
	if (children) {
		for (CC3Node* child in children) {
			CC3Vector cgll = child.globalLightLocation;
			if ( !CC3VectorsAreEqual(cgll, kCC3VectorZero) ) {
				return cgll;
			}
		}
	}
	return kCC3VectorZero;
}

-(void) setGlobalLightLocation: (CC3Vector) aDirection {
	if (children) {
		for (CC3Node* child in children) {
			child.globalLightLocation = aDirection;
		}
	}
}


#pragma mark CCRGBAProtocol support

-(ccColor3B) color {
	ccColor3B col = ccBLACK;
	int childCnt = 0;
	if (children && (childCnt = children.count) > 0) {
		GLuint rSum, bSum, gSum;
		rSum = bSum = gSum = 0;
		for (CC3Node* child in children) {
			ccColor3B childColor = child.color;
			rSum += childColor.r;
			gSum += childColor.g;
			bSum += childColor.b;
		}
		col = ccc3(rSum / childCnt, gSum / childCnt, bSum / childCnt);
	}
	return col;
}

-(void) setColor: (ccColor3B) color {
	if (children) {
		for (CC3Node* child in children) {
			child.color = color;
		}
	}
}

-(GLubyte) opacity {
	GLubyte opc = 0;
	int childCnt = 0;
	if (children && (childCnt = children.count) > 0) {
		GLuint oSum = 0;
		for (CC3Node* child in children) {
			oSum += child.opacity;
		}
		opc = oSum / childCnt;
	}
	return opc;
}

-(void) setOpacity: (GLubyte) opacity {
	if (children) {
		for (CC3Node* child in children) {
			child.opacity = opacity;
		}
	}
}

-(BOOL) isOpaque {
	if (children) {
		for (CC3Node* child in children) {
			if(!child.isOpaque) {
				return NO;
			}
		}
	}
	return YES;
}

-(void) setIsOpaque: (BOOL) opaque {
	if (children) {
		for (CC3Node* child in children) {
			child.isOpaque = opaque;
		}
	}
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		transformMatrixInverted = nil;
		globalRotationMatrix = nil;
		rotator = [[[self rotatorClass] rotator] retain];
		boundingVolume = nil;
		location = kCC3VectorZero;
		globalLocation = kCC3VectorZero;
		projectedLocation = kCC3VectorZero;
		scale = kCC3VectorUnitCube;
		globalScale = kCC3VectorUnitCube;
		isTransformDirty = NO;			// everything starts out at identity
		isTouchEnabled = NO;
		isAnimationEnabled = YES;
		visible = YES;
		isRunning = NO;
		self.transformMatrix = [CC3GLMatrix identity];		// Has side effects...so do last (transformMatrixInverted is built in some subclasses)
	}
	return self;
}

+(id) node {
	return [[[self alloc] init] autorelease];
}

+(id) nodeWithTag: (GLuint) aTag {
	return [[[self alloc] initWithTag: aTag] autorelease];
}

+(id) nodeWithName: (NSString*) aName {
	return [[[self alloc] initWithName: aName] autorelease];
}

+(id) nodeWithTag: (GLuint) aTag withName: (NSString*) aName {
	return [[[self alloc] initWithTag: aTag withName: aName] autorelease];
}

/**
 * Populates this instance with content copied from the specified other node.
 *
 * The population of this node from the content of the other node effects a deep copy.
 * For any content that is held by reference (eg- objects), and subject to future
 * modification, a copy is created, so that both this instance and the other instance can
 * be treated independently.
 * 
 * Child nodes are not copied in this method. Once this node has been populated with
 * configuration content by this method, invoke the copyChildrenFrom: method to copy
 * the child nodes from the other node.
 * 
 * Subclasses that extend copying should extend this method, and honour the deep copy
 * design pattern, making exceptions only for content that is both large and not subject
 * to modifications, such as mesh data.
 */
-(void) populateFrom: (CC3Node*) another {
	[super populateFrom: another];

	// Bypass setter method to avoid side effects.
	[transformMatrix release];
	transformMatrix = [another.transformMatrix copy];		// retained

	isTransformInvertedDirty = YES;							// create or rebuild lazily
	isGlobalRotationDirty = YES;							// create or rebuild lazily

	[rotator release];
	rotator = [another.rotator copy];						// retained
	
	[boundingVolume release];
	boundingVolume = [another.boundingVolume copy];			// retained
	boundingVolume.node = self;

	[animation release];
	animation = [another.animation retain];					// retained...not copied

	location = another.location;
	globalLocation = another.globalLocation;
	projectedLocation = another.projectedLocation;
	scale = another.scale;
	globalScale = another.globalScale;
	isTransformDirty = another.isTransformDirty;
	isTouchEnabled = another.isTouchEnabled;
	isAnimationEnabled = another.isAnimationEnabled;
	visible = another.visible;
	isRunning = another.isRunning;
}

// Protected properties for copying
-(BOOL) isTransformDirty { return isTransformDirty; }
-(CC3Rotator*) rotator { return rotator; }

/**
 * Copying of children is performed here instead of in populateFrom:
 * so that subclasses will be completely configured before children are added.
 * Subclasses that extend copying should not override this method,
 * but should override the populateFrom: method instead.
 */
-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName {
	CC3Node* aCopy = (CC3Node*)[super copyWithZone: zone withName: aName];
	[aCopy copyChildrenFrom: self];
	return aCopy;
}

/** Adds copies of the child nodes of the other node to this node. */
-(void) copyChildrenFrom: (CC3Node*) another {
	[self removeAllChildren];
	NSArray* otherKids = another.children;
	if (otherKids) {
		for (CC3Node* n in otherKids) {
			[self addChild: [n copyAutoreleased]];	// retained by collection
		}
	}
}

// Implementations to keep compiler happy so this method can be included in interface for documentation.
-(id) copy { return [super copy]; }
-(id) copyWithName: (NSString*) aName { return [super copyWithName: aName]; }

-(void) createGLBuffers {
	if (children) {
		for (CC3Node* child in children) {
			[child createGLBuffers];
		}
	}
}

-(void) deleteGLBuffers {
	if (children) {
		for (CC3Node* child in children) {
			[child deleteGLBuffers];
		}
	}
}

-(void) releaseRedundantData {
	if (children) {
		for (CC3Node* child in children) {
			[child releaseRedundantData];
		}
	}
}

-(void) retainVertexLocations {
	if (children) {
		for (CC3Node* child in children) {
			[child retainVertexLocations];
		}
	}
}

/**
 * Rotation tracking for each node is handled by a encapsulated instance of CC3Rotator.
 * This method returns the subclass of CC3Rotator that will be instantiated and used by
 * instances of this node class. The default is CC3Rotator, but subclasses my override
 * to establish other rotational tracking functionality.
 */
-(id) rotatorClass {
	return [CC3Rotator class];
}

#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Nodes.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedNodeTag;

-(GLuint) nextTag {
	return ++lastAssignedNodeTag;
}

+(void) resetTagAllocation {
	lastAssignedNodeTag = 0;
}

#pragma mark Type testing

-(BOOL) hasLocalContent {
	return NO;
}

-(BOOL) isMeshNode {
	return NO;
}

-(BOOL) visible {
	return visible && (!parent || parent.visible);
}


#pragma mark Updating

/**
 * Builds the transformation matrices of this node and all descendent nodes.
 * Each node rebuilds its transformation matrix if either its own transform is dirty,
 * or if an ancestor's transform was dirty.
 *
 * This implementation delegates to the visitor, which controls updating activities.
 */
-(void) updateWithVisitor: (CC3NodeTransformingVisitor*) visitor {
	[visitor updateNode: self];
}

/**
 * Passes along the updateWithVisitor: request to all child nodes,
 * then processes any descendants that have requested removal.
 */
-(void) updateChildrenWithVisitor: (CC3NodeTransformingVisitor*) visitor {
	if (children) {
		for (CC3Node* child in children) {
			[child updateWithVisitor: visitor];
		}
	}
}

// Deprecated legacy method - supported for backwards compatibility
-(void) update: (ccTime)dt {}

// Deprecated legacy method - supported for backwards compatibility
-(void) updateBeforeChildren: (CC3NodeUpdatingVisitor*) visitor {}

// Deprecated legacy method - supported for backwards compatibility
-(void) updateAfterChildren: (CC3NodeUpdatingVisitor*) visitor {}

// Default invokes legacy updateBeforeChildren: and update: methods, for backwards compatibility.
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self updateBeforeChildren: visitor];
	[self update: visitor.deltaTime];
}

// Default invokes legacy updateAfterChildren: method, for backwards compatibility.
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
	[self updateAfterChildren: visitor];
}


#pragma mark Transformations

-(void) setTransformMatrix: (CC3GLMatrix*) aCC3GLMatrix {
	if (transformMatrix != aCC3GLMatrix) {
		[transformMatrix release];
		transformMatrix = [aCC3GLMatrix retain];
		[self updateGlobalOrientation];
		[self transformMatrixChanged];
	}
}

/** Marks the node's transformMatrix as requiring a recalculation. */
-(void) markTransformDirty {
	isTransformDirty = YES;
}

-(void) updateTransformMatrix {
	CC3NodeTransformingVisitor* visitor = [[self transformVisitorClass] visitor];
	visitor.shouldVisitChildren = NO;
	[self updateWithVisitor: visitor];
}

-(void) updateTransformMatrices {
	[self updateWithVisitor: [[self transformVisitorClass] visitor]];
}

/**
 * Returns the class of visitor that will be instantiated in the updateWorld: method,
 * and passed to the updateTransformMatrices method when the transformation matrices
 * of the nodes are being rebuilt.
 *
 * The returned class must be a subclass of CC3NodeTransformingVisitor. This implementation
 * returns CC3NodeTransformingVisitor. Subclasses may override to customized the behaviour
 * of the update visits.
 */
-(id) transformVisitorClass {
	return [CC3NodeTransformingVisitor class];
}

/**
 * Template method that recalculates the transform matrix of this node from the location,
 * rotation and scale properties.
 */
-(void) buildTransformMatrix {
	[transformMatrix populateFrom: (parent ? parent.transformMatrix : [CC3GLMatrix identity])];
	[self applyLocalTransforms];
	[self transformMatrixChanged];
}

/**
 * Template method that applies the local location, rotation and scale properties to
 * the transform matrix. Subclasses may override to enhance or modify this behaviour.
 */
-(void) applyLocalTransforms {
	[self applyTranslation];
	[self applyRotation];
	[self applyScaling];
}

/** Template method that applies the local location property to the transform matrix. */
-(void) applyTranslation {
	[transformMatrix translateBy: location];
	[self updateGlobalLocation];
	LogTrace(@"%@ translated to %@, globally %@ %@", self, NSStringFromCC3Vector(location),
			 NSStringFromCC3Vector(globalLocation), transformMatrix);
}

/** Template method that applies the local rotation property to the transform matrix. */
-(void) applyRotation {
	[rotator applyRotationTo: transformMatrix];
	[self updateGlobalRotation];
	LogTrace(@"%@ rotated to %@ %@", self, NSStringFromCC3Vector(rotator.rotation), transformMatrix);
}

/** Template method that applies the local scale property to the transform matrix. */
-(void) applyScaling {
	[transformMatrix scaleBy: scale];
	[self updateGlobalScale];
	LogTrace(@"%@ scaled to %@, globally %@ %@", self, NSStringFromCC3Vector(scale),
			 NSStringFromCC3Vector(globalScale), transformMatrix);
}

/**
 * Template method that is invoked automatically whenever the transform matrix of this node
 * is changed. Updates the bounding volume of this node, and marks the globalRotationMatrix
 * and transformInvertedMatrix as dirty so they will be lazily rebuilt.
 */
-(void) transformMatrixChanged {
	[self updateBoundingVolume];
	isTransformDirty = NO;
	isTransformInvertedDirty = YES;
}

/**
 * Template method that updates the global orientation properties
 * (globalLocation, globalRotation & globalScale).
 */
-(void) updateGlobalOrientation {
	[self updateGlobalLocation];
	[self updateGlobalRotation];
	[self updateGlobalScale];
}

/** Template method to update the globalLocation property. */
-(void) updateGlobalLocation {
	globalLocation = [transformMatrix transformLocation: kCC3VectorZero];
}

/** Template method to update the globalRotation property. */
-(void) updateGlobalRotation {
	isGlobalRotationDirty = YES;
}

/** Template method to update the globalScale property. */
-(void) updateGlobalScale {
	globalScale = parent ? CC3VectorScale(parent.globalScale, scale) : scale;
}

/**
 * Returns the inverse of the transformMatrix.
 *
 * Since this inverse matrix is not commonly used, and is often expensive to compute,
 * it is only calculated when the transformMatrix has changed, and then only on demand.
 * When the transformMatrix is marked as dirty, the tansformMatrixInverted is marked
 * as dirty as well. It is then recalculated the next time this property is accessed,
 * and is cached until it is marked dirty again.
 *
 * The calculation of the inverse is optimized where possible. If the transformMatrix
 * is rigid, as indicated by the isTransformRigid property, the inversion calculation
 * is optimized to a rotational transposition and reverse translation, which is many
 * times faster than a full matrix inversion calculation.
 */
-(CC3GLMatrix*) transformMatrixInverted {
	if (!transformMatrixInverted) {
		transformMatrixInverted = [[CC3GLMatrix matrix] retain];
		isTransformInvertedDirty = YES;
	}
	if (isTransformInvertedDirty) {
		[transformMatrixInverted populateFrom: transformMatrix];
		
		// If the transform is rigid (only rotation & translation), use faster inversion.
		// It would be better to move this test to the matrix itself, but there is no
		// known quick and accurate test to tell if a matrix represents a rigid transform.
		if (self.isTransformRigid) {
			[transformMatrixInverted invertRigid];
		} else {
			[transformMatrixInverted invertAffine];
		}
		isTransformInvertedDirty = NO;

		LogTrace(@"%@ transform %@ inverted %@to %@", self, transformMatrix,
				 (self.isTransformRigid ? @"rigidly " : @""), transformMatrixInverted);
	}
	return transformMatrixInverted;
}

/**
 * Returns a matrix representing all of the rotations that make up this node,
 * including ancestor nodes.
 *
 * Since this matrix is not commonly used, and is expensive to compute, it is only
 * calculated when the transformMatrix has changed, and then only on demand.
 * When the transformMatrix is marked as dirty, the globalRotationMatrix is marked
 * as dirty as well. It is then recalculated the next time this property is accessed,
 * and is cached until it is marked dirty again.
 */
-(CC3GLMatrix*) globalRotationMatrix {
	if (!globalRotationMatrix) {
		globalRotationMatrix = [[CC3GLMatrix matrix] retain];
		isGlobalRotationDirty = YES;
	}
	if (isGlobalRotationDirty) {
		if (parent) {
			[globalRotationMatrix populateFrom: parent.globalRotationMatrix];
			[globalRotationMatrix multiplyByMatrix: rotator.rotationMatrix];
		} else {
			[globalRotationMatrix populateFrom: rotator.rotationMatrix];
		}
		isGlobalRotationDirty = NO;
	}
	return globalRotationMatrix;
}

/** Template method that updates the bounding volume. */
-(void) updateBoundingVolume {
	[boundingVolume update];
}


#pragma mark Drawing

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	NSAssert1(visitor, @"%@ drawing visitor must not be nil", [self class]);
	LogTrace(@"Visiting %@ %@ children", self, (visitor.shouldVisitChildren ? @"and" : @"but not"));
	[visitor.performanceStatistics incrementNodesVisitedForDrawing];

	if(self.visible) {
		if (self.hasLocalContent && [self doesIntersectFrustum: visitor.frustum]) {
			[self transformAndDrawWithVisitor: visitor];
		}
		if (visitor.shouldVisitChildren) {
			[self drawChildrenWithVisitor: visitor];
		}
	}
}

/** Passes along the drawWithVisitor: request to all child nodes. */
-(void) drawChildrenWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (children) {
		for (CC3Node* child in children) {
			[child drawWithVisitor: visitor];
		}
	}
}

/**
 * Returns whether the local content of this node intersects the given frustum. If this node
 * has a boundingVolume, it delegates to it, otherwise, it simply returns YES.
 * Subclasses may override to change this standard behaviour. 
 */
-(BOOL) doesIntersectFrustum: (CC3Frustum*) aFrustum {
	if (boundingVolume && aFrustum) {
		BOOL intersects = [boundingVolume doesIntersectFrustum: aFrustum];
		LogTrace(@"%@ bounded by %@ %@\n%@", self, boundingVolume,
				 (intersects ? @"intersects" : @"does not intersect"), aFrustum);
		// Uncomment to verify culling
//			if (!intersects) {
//				LogDebug(@"%@ does not intersect\n%@", self, aFrustum);
//			}
		return intersects;
	}
	return YES;
}

/** Template method that applies this node's transform matrix to the GL matrix stack and draws this node. */
-(void) transformAndDrawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@", self);
	CC3OpenGLES11MatrixStack* gles11MatrixStack = [CC3OpenGLES11Engine engine].matrices.modelview;

	[gles11MatrixStack push];

	LogTrace(@"%@ applying transform matrix: %@", self, transformMatrix);
	[gles11MatrixStack multiply: transformMatrix.glMatrix];

	[visitor drawLocalContentOf: self];

	[gles11MatrixStack pop];
}

/**
 * Draws the raw, untransformed local content of this node. This implementation does nothing.
 * Subclasses with drawable local content will override as appropriate to draw their content.
 *
 * As described in the class documentation, in keeping with best practices, drawing and frame
 * rendering should be kept separate from updating the model state. Therefore, when overriding
 * this method in a subclass, do not update any model state. This method should perform only
 * frame rendering operations.
 */
-(void) drawLocalContentWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

-(void) checkDrawingOrder {
	if (children) {
		for (CC3Node* child in children) {
			[child checkDrawingOrder];
		}
	}
}


#pragma mark Node structural hierarchy

/**
 * When assigned to a new parent, ensure that the transform will be recalculated,
 * since it changes this child's overall transform.
 */
-(void) setParent: (CC3Node *) aNode {
	parent = aNode;
	[self markTransformDirty];
}

/** Adds a child node and invokes didAddDescendant: so action can be taken by subclasses. */
-(void) addChild: (CC3Node*) aNode {
	NSAssert(aNode, @"Child CC3Node cannot be nil");
	[aNode remove];				// remove node from its existing parent
	if(!children) {
		children = [[NSMutableArray array] retain];
	}
	LogTrace(@"Adding %@ to %@", aNode, self);
	[children addObject: aNode];
	aNode.parent = self;
	aNode.isRunning = self.isRunning;
	[self didAddDescendant: aNode];
}

/**
 * To transform location and rotation, we invert the matrix of this node,
 * and multiply it by the matrix of the child node. The incoming child's
 * matrix is in global form. We want a local form that will provide the
 * local location and rotation. We can then extract local location,
 * rotation, and scale from the local matrix.
 *
 * Mathematically, if Mcg is the global matrix of the child node, Mpg is the
 * matrix of this parent, and Mcl is the desired local matrix, we have:
 *     Normally: Mcg = Mpg.Mcl
 * Multiplying both sides by  Mpg(-1), the inverse of the parent's matrix:
 *     Mpg(-1).Mcg = Mpg(-1).Mpg.Mcl
 *     Mcl = Mpg(-1).Mcg
 */
-(void) addAndLocalizeChild: (CC3Node*) aNode {
	CC3GLMatrix* g2LMtx;		// Global to local transformation matrix
	
	// Since this calculation depends both the parent and child transformMatrixes,
	// make sure they are up to date.
	[self updateTransformMatrix];
	[aNode updateTransformMatrix];
	
	// Localize the child node's location by finding the right local matrix,
	// and then translating the child node's local origin by the resulting matrix.
	// This is what the location property does. It instructs the local matrix
	// to move the node's origin. By transforming the origin, we determine what
	// that location property needs to be.
	g2LMtx = [self.transformMatrixInverted copyAutoreleased];
	[g2LMtx multiplyByMatrix: aNode.transformMatrix];
	aNode.location = [g2LMtx transformLocation: kCC3VectorZero];

	// Localize the child node's rotation by finding the right rotation matrix.
	// For rotation, we use the globalRotationMatrix, which is free of scale
	// and translation content. Otherwise it would be impossible to extract
	// the local rotation from an arbitrarily scaled and translated matrix.
	g2LMtx = [self.globalRotationMatrix copyAutoreleased];
	[g2LMtx invertRigid];		// Only contains rotation...so it's rigid.
	[g2LMtx multiplyByMatrix: aNode.globalRotationMatrix];
	aNode.rotation = [g2LMtx extractRotation];

	// Scale cannot readily be extracted from the inverted and multiplied matrix,
	// but we can get it by scaling the node's scale down by the globalScale
	// of this parent, so that when they are recombined, the original globalScale
	// of the child node.
	aNode.scale = CC3VectorScale(aNode.globalScale, CC3VectorInvert(self.globalScale));

	[self addChild:aNode];		// Finally, add the child node to this parent
}

/**
 * Removes a child node and invokes didRemoveDescendant: so action can be taken by subclasses.
 * First locates the object to make sure it is in the child node collection, and only performs
 * the removal and related actions if the specified node really is a child of this node.
 */
-(void) removeChild: (CC3Node*) aNode {
	if (children && aNode) {
		NSUInteger indx = [children indexOfObjectIdenticalTo: aNode];
		if (indx != NSNotFound) {

			// If the children collection is the only thing referencing the node, it will be
			// deallocated as soon as it is removed, and will be invalid when passed to the
			// didRemoveDescendant: method, or to other activities that it may be subject to
			// in the processing loop. To avoid problems, retain it for the duration of
			// this processing loop, so that it will still be valid until we're done with it.
			[[aNode retain] autorelease];

			aNode.parent = nil;
			[children removeObjectAtIndex: indx];
			if (children.count == 0) {
				[children release];
				children = nil;
			}
			aNode.isRunning = NO;
			[self didRemoveDescendant: aNode];
		}
	}
}

-(void) removeAllChildren {
	if (children) {
		NSArray* myKids = [children copy];
		for (CC3Node* child in myKids) {
			[self removeChild: child];
		}
		[myKids release];
	}
}

-(void) remove {
	[parent removeChild: self];
}

-(BOOL) isDescendantOf: (CC3Node*) aNode {
	return parent ? (parent == aNode || [parent isDescendantOf: aNode]) : NO;
}

/**
 * Invoked automatically when a node is added as a child somewhere in the descendant structural
 * hierarchy of this node. The method is not only invoked on the immediate parent of the newly
 * added node, but is actually invoked on all ancestors as well (parents of the parent).
 * This default implementation simply passes the notification up the parental ancestor chain.
 * Subclasses may override to take a specific interest in which nodes are being added below them.
 */
-(void) didAddDescendant: (CC3Node*) aNode {
	[parent didAddDescendant: (CC3Node*) aNode];
}

/**
 * Invoked automatically when a node is removed as a child somewhere in the descendant structural
 * hierarchy of this node. The method is not only invoked on the immediate parent of the removed
 * node, but is actually invoked on all ancestors as well (parents of the parent).
 * This default implementation simply passes the notification up the parental ancestor chain.
 * Subclasses may override to take a specific interest in which nodes are being removed below them.
 */
-(void) didRemoveDescendant: (CC3Node*) aNode {
	[parent didRemoveDescendant: (CC3Node*) aNode];
}

/**
 * Invoked automatically when a property was modified on a descendant node that potentially
 * affects its drawing order, relative to other nodes. This default implementation simply
 * passes the notification up the parental ancestor chain. Subclasses may override to take
 * a specific interest in which nodes need resorting below them.
 */
-(void) descendantDidModifySequencingCriteria: (CC3Node*) aNode {
	[parent descendantDidModifySequencingCriteria: aNode];
}

-(CC3Node*) getNodeNamed: (NSString*) aName {
	if ([name isEqual: aName] || (!name && !aName)) {	// my name equal or both nil
		return self;
	}
	if (children) {
		for (CC3Node* child in children) {
			CC3Node* childResult = [child getNodeNamed: aName];
			if (childResult) {
				return childResult;
			}
		}
	}
	return nil;
}

-(CC3Node*) getNodeTagged: (GLuint) aTag {
	if (tag == aTag) {
		return self;
	}
	if (children) {
		for (CC3Node* child in children) {
			CC3Node* childResult = [child getNodeTagged: aTag];
			if (childResult) {
				return childResult;
			}
		}
	}
	return nil;
}

-(NSArray*) flatten {
	NSMutableArray* allNodes = [NSMutableArray array];
	[self flattenInto: allNodes];
	return allNodes;
}

-(void) flattenInto: (NSMutableArray*) anArray {
	[anArray addObject: self];
	if (children) {
		for (CC3Node* child in children) {
			[child flattenInto: anArray];
		}
	}
}


#pragma mark CC3Node Actions

-(CCAction*) runAction:(CCAction*) action {
	NSAssert( action != nil, @"Argument must be non-nil");
	[[CCActionManager sharedManager] addAction: action target: self paused: !isRunning];
	return action;
}

-(void) stopAllActions {
	[[CCActionManager sharedManager] removeAllActionsFromTarget: self];
}

-(void) stopAction: (CCAction*) action {
	[[CCActionManager sharedManager] removeAction: action];
}

-(void) stopActionByTag:(int)aTag {
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	[[CCActionManager sharedManager] removeActionByTag: aTag target: self];
}

-(CCAction*) getActionByTag:(int) aTag {
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	return [[CCActionManager sharedManager] getActionByTag: aTag target: self];
}

-(int) numberOfRunningActions {
	return [[CCActionManager sharedManager] numberOfRunningActionsInTarget: self];
}

- (void) resumeActions {
	[[CCActionManager sharedManager] resumeTarget: self];
}

- (void) pauseActions {
	[[CCActionManager sharedManager] pauseTarget: self];
}

- (void)cleanup {
	[self stopAllActions];
	if (children) {
		for (CC3Node* child in children) {
			[child cleanup];
		}
	}
}


#pragma mark Touch handling

-(BOOL) isTouchable {
	return isTouchEnabled || (parent ? parent.isTouchable : NO);
}

-(CC3Node*) touchableNode {
	return isTouchEnabled ? self : (parent ? parent.touchableNode : nil);
}

-(void) touchEnableAll {
	isTouchEnabled = YES;
	if (children) {
		for (CC3Node* child in children) {
			[child touchEnableAll];
		}
	}
}

-(void) touchDisableAll {
	isTouchEnabled = NO;
	if (children) {
		for (CC3Node* child in children) {
			[child touchDisableAll];
		}
	}
}


#pragma mark Animation

-(BOOL) containsAnimation {
	if (animation) {
		return YES;
	}
	if (children) {
		for (CC3Node* child in children) {
			if (child.containsAnimation) {
				return YES;
			}
		}
	}
	return NO;
}

-(void) enableAnimation {
	isAnimationEnabled = YES;
}

-(void) disableAnimation {
	isAnimationEnabled = NO;
}

-(void) enableAllAnimation {
	[self enableAnimation];
	if (children) {
		for (CC3Node* child in children) {
			[child enableAllAnimation];
		}
	}
}

-(void) disableAllAnimation {
	[self disableAnimation];
	if (children) {
		for (CC3Node* child in children) {
			[child disableAllAnimation];
		}
	}
}

-(void) establishAnimationFrameAt: (ccTime) t {
	if (animation && isAnimationEnabled) {
		LogTrace(@"%@ animating frame at %.3f ms", self, t);
		[animation establishFrameAt: t forNode: self];
	}
	if (children) {
		for (CC3Node* child in children) {
			[child establishAnimationFrameAt: t];
		}
	}
}

@end


#pragma mark -
#pragma mark CC3LocalContentNode

@implementation CC3LocalContentNode

-(BOOL) hasLocalContent {
	return YES;
}

/** Notify up the ancestor chain...then check my children by invoking superclass implementation. */
-(void) checkDrawingOrder {
	[parent descendantDidModifySequencingCriteria: self];
	[super checkDrawingOrder];
}

@end


#pragma mark -
#pragma mark CC3Rotator

@interface CC3Rotator (TemplateMethods)
-(CC3Vector) extractRotationFromMatrix;
-(CC3Vector4) extractQuaternionFromMatrix;
-(void) applyRotation;
-(void) populateFrom: (CC3Rotator*) another;
@property(nonatomic, readonly) BOOL isRotationDirty;
@property(nonatomic, readonly) BOOL isMatrixDirtyByRotation;
@property(nonatomic, readonly) BOOL isQuaternionDirty;
@property(nonatomic, readonly) BOOL isMatrixDirtyByQuaternion;
@end

@implementation CC3Rotator

-(void) dealloc {
	[rotationMatrix release];
	[super dealloc];
}

-(CC3Vector) rotation {
	if (isRotationDirty) {
		rotation = [self extractRotationFromMatrix];
		isRotationDirty = NO;
	}
	return rotation;
}

-(void) setRotation:(CC3Vector) aRotation {
	rotation = aRotation;

	isRotationDirty = NO;
	isQuaternionDirty = YES;

	isMatrixDirtyByRotation = YES;
	isMatrixDirtyByQuaternion = NO;
}

-(CC3Vector4) quaternion {
	if (isQuaternionDirty) {
		quaternion = [self extractQuaternionFromMatrix];
		isQuaternionDirty = NO;
	}
	return quaternion;
}

-(void) setQuaternion:(CC3Vector4) aQuaternion {
	quaternion = aQuaternion;

	isRotationDirty = YES;
	isQuaternionDirty = NO;

	isMatrixDirtyByRotation = NO;
	isMatrixDirtyByQuaternion = YES;
}

-(CC3GLMatrix*) rotationMatrix {
	[self applyRotation];
	return rotationMatrix;
}

-(void) setRotationMatrix:(CC3GLMatrix*) aGLMatrix {
	id oldMtx = rotationMatrix;
	rotationMatrix = [aGLMatrix retain];
	[oldMtx release];
	
	isRotationDirty = YES;
	isQuaternionDirty = YES;

	isMatrixDirtyByRotation = NO;
	isMatrixDirtyByQuaternion = NO;
}

-(id) init {
	return [self initOnRotationMatrix: [CC3GLMatrix identity]];
}

+(id) rotator {
	return [[[self alloc] init] autorelease];
}

-(id) initOnRotationMatrix: (CC3GLMatrix*) aGLMatrix {
	if ( (self = [super init]) ) {
		self.rotationMatrix = aGLMatrix;
		rotation = kCC3VectorZero;
		quaternion = CC3Vector4Make(0.0, 0.0, 0.0, 0.0);
		isRotationDirty = NO;
		isMatrixDirtyByRotation = NO;
		isQuaternionDirty = NO;
		isMatrixDirtyByQuaternion = NO;
	}
	return self;
}

+(id) rotatorOnRotationMatrix: (CC3GLMatrix*) aGLMatrix {
	return [[[self alloc] initOnRotationMatrix: aGLMatrix] autorelease];
}

// Protected properties for copying
-(BOOL) isRotationDirty { return isRotationDirty; }
-(BOOL) isMatrixDirtyByRotation { return isMatrixDirtyByRotation; }
-(BOOL) isQuaternionDirty { return isQuaternionDirty; }
-(BOOL) isMatrixDirtyByQuaternion { return isMatrixDirtyByQuaternion; }

-(id) copyWithZone: (NSZone*) zone {
	CC3Rotator* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Rotator*) another {

	[rotationMatrix release];
	rotationMatrix = [another.rotationMatrix copy];			// retained

	rotation = another.rotation;
	quaternion = another.quaternion;
	isRotationDirty = another.isRotationDirty;
	isMatrixDirtyByRotation = another.isMatrixDirtyByRotation;
	isQuaternionDirty = another.isQuaternionDirty;
	isMatrixDirtyByQuaternion = another.isMatrixDirtyByQuaternion;
}

/** Extracts and returns Euler angles from the encapsulated rotation matrix. */
-(CC3Vector) extractRotationFromMatrix {
	return [self.rotationMatrix extractRotation];
}

/** Extracts and returns a quaternion from the encapsulated rotation matrix. */
-(CC3Vector4) extractQuaternionFromMatrix {
	return [self.rotationMatrix extractQuaternion];
}

/** Recalculates the rotation matrix from the most recently set rotation or quaternion property. */
-(void) applyRotation {
	if (isMatrixDirtyByRotation) {
		[rotationMatrix populateFromRotation: self.rotation];
		isMatrixDirtyByRotation = NO;
	}
	if (isMatrixDirtyByQuaternion) {
		[rotationMatrix populateFromQuaternion: self.quaternion];
		isMatrixDirtyByQuaternion = NO;
	}
}

-(void) applyRotationTo: (CC3GLMatrix*) aMatrix {
	[aMatrix multiplyByMatrix: self.rotationMatrix];	// Rotation matrix is built lazily if needed
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@: %@, quaternion: %@",
			[self class],
			NSStringFromCC3Vector(self.rotation),
			NSStringFromCC3Vector4(self.quaternion)];
}

@end

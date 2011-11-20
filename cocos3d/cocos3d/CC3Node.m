/**
 * CC3Node.m
 *
 * cocos3d 0.6.4
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
#import "CC3MeshNode.h"
#import "CC3BoundingVolumes.h"
#import "CC3NodeAnimation.h"
#import "CC3Billboard.h"
#import "CC3OpenGLES11Foundation.h"
#import "CC3OpenGLES11Engine.h"
#import "CC3ParametricMeshNodes.h"
#import "CCActionManager.h"
#import "CCLabelTTF.h"
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
-(void) transformMatrixChanged;
-(void) updateGlobalOrientation;
-(void) updateGlobalLocation;
-(void) updateGlobalRotation;
-(void) updateGlobalScale;
-(void) updateBoundingVolume;
-(void) transformAndDrawWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) didAddDescendant: (CC3Node*) aNode;
-(void) didRemoveDescendant: (CC3Node*) aNode;
-(void) descendantDidModifySequencingCriteria: (CC3Node*) aNode;
-(id) rotatorClass;
-(void) populateFrom: (CC3Node*) another;
-(void) copyChildrenFrom: (CC3Node*) another;
-(void) resumeActions;
-(void) pauseActions;
@property(nonatomic, readonly) CC3GLMatrix* globalRotationMatrix;
@property(nonatomic, readonly) ccColor4F initialWireframeBoxColor;
@property(nonatomic, readonly) ccColor4F initialDirectionMarkerColor;
@property(nonatomic, readonly) BOOL rawVisible;
@end

@implementation CC3Node

@synthesize rotator, location, scale, globalLocation, globalScale, scaleTolerance;
@synthesize boundingVolume, boundingVolumePadding, projectedLocation;
@synthesize transformMatrix, animation, isRunning, visible, isAnimationEnabled;
@synthesize isTouchEnabled, shouldInheritTouchability, shouldAllowTouchableWhenInvisible;
@synthesize parent, children, shouldAutoremoveWhenEmpty, shouldUseFixedBoundingVolume;
@synthesize shouldCleanupWhenRemoved;

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

-(void) translateBy: (CC3Vector) aVector {
	self.location = CC3VectorAdd(self.location, aVector);
}

-(CC3Vector) rotation {
	return rotator.rotation;
}

-(void) setRotation: (CC3Vector) aRotation {
	rotator.rotation = aRotation;
	[self markTransformDirty];
}

-(void) rotateBy: (CC3Vector) aRotation {
	[rotator rotateBy: aRotation];
	[self markTransformDirty];
}

-(CC3Vector4) quaternion {
	return rotator.quaternion;
}

-(void) setQuaternion: (CC3Vector4) aQuaternion {
	rotator.quaternion = aQuaternion;
	[self markTransformDirty];
}

-(void) rotateByQuaternion: (CC3Vector4) aQuaternion {
	[rotator rotateByQuaternion: aQuaternion];
	[self markTransformDirty];
}

-(CC3Vector) rotationAxis {
	return rotator.rotationAxis;
}

-(void) setRotationAxis: (CC3Vector) aDirection {
	rotator.rotationAxis = aDirection;
	[self markTransformDirty];
}

-(GLfloat) rotationAngle {
	return rotator.rotationAngle;
}

-(void) setRotationAngle: (GLfloat) anAngle {
	rotator.rotationAngle = anAngle;
	[self markTransformDirty];
}

-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	[rotator rotateByAngle: anAngle aroundAxis: anAxis];
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
	return (CC3IsWithinTolerance(scale.x, scale.y, scaleTolerance) &&
			CC3IsWithinTolerance(scale.x, scale.z, scaleTolerance));
}

//-(BOOL) isUniformlyScaledLocally {
//	return (scale.x == scale.y && scale.x == scale.z);
//}

-(BOOL) isUniformlyScaledGlobally {
	return self.isUniformlyScaledLocally && (parent ? parent.isUniformlyScaledGlobally : YES);
}

//-(BOOL) isTransformRigid {
//	return (scale.x == 1.0f && scale.y == 1.0f && scale.z == 1.0f) && (parent ? parent.isTransformRigid : YES);
//}

-(BOOL) isTransformRigid {
	return (CC3IsWithinTolerance(scale.x, 1.0f, scaleTolerance) &&
			CC3IsWithinTolerance(scale.y, 1.0f, scaleTolerance) &&
			CC3IsWithinTolerance(scale.z, 1.0f, scaleTolerance) &&
			(parent ? parent.isTransformRigid : YES));
}

-(void) setScaleTolerance: (GLfloat) aTolerance {
	scaleTolerance = aTolerance;
	for (CC3Node* child in children) {
		child.scaleTolerance = aTolerance;
	}
}

// Class-side property used to set the initial value of the unityScaleTolerance property.
static GLfloat defaultScaleTolerance = 0.0f;

+(GLfloat) defaultScaleTolerance { return defaultScaleTolerance; }

+(void) setDefaultScaleTolerance: (GLfloat) aTolerance {
	defaultScaleTolerance = aTolerance;
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
	for (CC3Node* child in children) {
		child.isRunning = isRunning;
	}
}


#pragma mark Mesh configuration

-(BOOL) shouldCullBackFaces {
	for (CC3Node* child in children) {
		if (child.shouldCullBackFaces == NO) {
			return NO;
		}
	}
	return YES;
}

-(void) setShouldCullBackFaces: (BOOL) shouldCull {
	for (CC3Node* child in children) {
		child.shouldCullBackFaces = shouldCull;
	}
}

-(BOOL) shouldCullFrontFaces {
	for (CC3Node* child in children) {
		if (child.shouldCullFrontFaces) {
			return YES;
		}
	}
	return NO;
}

-(void) setShouldCullFrontFaces: (BOOL) shouldCull {
	for (CC3Node* child in children) {
		child.shouldCullFrontFaces = shouldCull;
	}
}

-(BOOL) shouldUseClockwiseFrontFaceWinding {
	for (CC3Node* child in children) {
		if (child.shouldUseClockwiseFrontFaceWinding) {
			return YES;
		}
	}
	return NO;
}

-(void) setShouldUseClockwiseFrontFaceWinding: (BOOL) shouldWindCW {
	for (CC3Node* child in children) {
		child.shouldUseClockwiseFrontFaceWinding = shouldWindCW;
	}
}

-(BOOL) shouldUseSmoothShading {
	for (CC3Node* child in children) {
		if (child.shouldUseSmoothShading == NO) {
			return NO;
		}
	}
	return YES;
}

-(void) setShouldUseSmoothShading: (BOOL) shouldSmooth {
	for (CC3Node* child in children) {
		child.shouldUseSmoothShading = shouldSmooth;
	}
}

-(CC3NormalScaling) normalScalingMethod {
	for (CC3Node* child in children) {
		CC3NormalScaling csm = child.normalScalingMethod;
		if (csm != kCC3NormalScalingNone) {
			return csm;
		}
	}
	return kCC3NormalScalingNone;
}

-(void) setNormalScalingMethod: (CC3NormalScaling) nsMethod {
	for (CC3Node* child in children) {
		child.normalScalingMethod = nsMethod;
	}
}

-(BOOL) shouldDisableDepthMask {
	for (CC3Node* child in children) {
		if (child.shouldDisableDepthMask) {
			return YES;
		}
	}
	return NO;
}

-(void) setShouldDisableDepthMask: (BOOL) shouldDisable {
	for (CC3Node* child in children) {
		child.shouldDisableDepthMask = shouldDisable;
	}
}

-(BOOL) shouldDisableDepthTest {
	for (CC3Node* child in children) {
		if (child.shouldDisableDepthTest) {
			return YES;
		}
	}
	return NO;
}

-(void) setShouldDisableDepthTest: (BOOL) shouldDisable {
	for (CC3Node* child in children) {
		child.shouldDisableDepthTest = shouldDisable;
	}
}

-(GLenum) depthFunction {
	for (CC3Node* child in children) {
		GLenum df = child.depthFunction;
		if (df != GL_NEVER) {
			return df;
		}
	}
	return GL_NEVER;
}

-(void) setDepthFunction: (GLenum) depthFunc {
	for (CC3Node* child in children) {
		child.depthFunction = depthFunc;
	}
}

// Creates a specialized transforming visitor that traverses the node hierarchy below
// this node, accumulating a bounding box that surrounds all descendant nodes.
-(CC3BoundingBox) boundingBox {
	CC3NodeBoundingBoxVisitor* bbVisitor = [CC3NodeBoundingBoxVisitor visitor];
	bbVisitor.shouldLocalizeToStartingNode = YES;
	[bbVisitor visit: self];
	LogTrace(@"Measured %@ bounding box: %@", self, NSStringFromCC3BoundingBox(bbVisitor.boundingBox));
	return bbVisitor.boundingBox;
}

// Creates a specialized transforming visitor that traverses the node hierarchy below
// this node, accumulating a bounding box that surrounds all descendant nodes.
-(CC3BoundingBox) globalBoundingBox {
	CC3NodeBoundingBoxVisitor* bbVisitor = [CC3NodeBoundingBoxVisitor visitor];
	[bbVisitor visit: self];
	LogTrace(@"Measured %@ global bounding box: %@", self, NSStringFromCC3BoundingBox(bbVisitor.boundingBox));
	return bbVisitor.boundingBox;
}

// By default, individual nodes do not collect their own performance statistics
-(CC3PerformanceStatistics*) performanceStatistics { return nil; }
-(void) setPerformanceStatistics: (CC3PerformanceStatistics*) aPerfStats {}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ location: %@, global: %@, %@, scale: %@, projected to: %@, bounded by: %@",
			[self description],
			NSStringFromCC3Vector(self.location),
			NSStringFromCC3Vector(self.globalLocation),
			rotator,
			NSStringFromCC3Vector(self.scale),
			NSStringFromCGPoint(self.projectedPosition),
			boundingVolume];
}

-(NSString*) structureDescription {
	return [self appendStructureDescriptionTo: [NSMutableString stringWithCapacity: 1000] withIndent: 0];
}

-(NSString*) appendStructureDescriptionTo: (NSMutableString*) desc withIndent: (NSUInteger) indentLevel {
	[desc appendFormat: @"\n"];
	for (int i = 0; i < indentLevel; i++) {
		[desc appendFormat: @"  "];
	}
	[desc appendFormat: @"%@", self];
	for (CC3Node* child in children) {
		[child appendStructureDescriptionTo: desc withIndent: indentLevel + 1];
	}
	return desc;
}

#pragma mark Matierial coloring

-(BOOL) shouldUseLighting {
	for (CC3Node* child in children) {
		if (child.shouldUseLighting) {
			return YES;
		}
	}
	return NO;
}

-(void) setShouldUseLighting: (BOOL) useLighting {
	for (CC3Node* child in children) {
		child.shouldUseLighting = useLighting;
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
	for (CC3Node* child in children) {
		child.ambientColor = color;
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
	for (CC3Node* child in children) {
		child.diffuseColor = color;
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
	for (CC3Node* child in children) {
		child.specularColor = color;
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
	for (CC3Node* child in children) {
		child.emissionColor = color;
	}
}

-(CC3Vector) globalLightLocation {
	for (CC3Node* child in children) {
		CC3Vector cgll = child.globalLightLocation;
		if ( !CC3VectorsAreEqual(cgll, kCC3VectorZero) ) {
			return cgll;
		}
	}
	return kCC3VectorZero;
}

-(void) setGlobalLightLocation: (CC3Vector) aDirection {
	for (CC3Node* child in children) {
		child.globalLightLocation = aDirection;
	}
}


#pragma mark CCRGBAProtocol and CCBlendProtocol support

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
	for (CC3Node* child in children) {
		child.color = color;
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
	for (CC3Node* child in children) {
		child.opacity = opacity;
	}
}

-(BOOL) isOpaque {
	for (CC3Node* child in children) {
		if(!child.isOpaque) {
			return NO;
		}
	}
	return YES;
}

-(void) setIsOpaque: (BOOL) opaque {
	for (CC3Node* child in children) {
		child.isOpaque = opaque;
	}
}

-(ccBlendFunc) blendFunc {
	for (CC3Node* child in children) {
		return child.blendFunc;
	}
	return (ccBlendFunc){GL_ONE, GL_ZERO};
}

-(void) setBlendFunc: (ccBlendFunc) aBlendFunc {
	for (CC3Node* child in children) {
		child.blendFunc = aBlendFunc;
	}
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		transformMatrixInverted = nil;
		globalRotationMatrix = nil;
		rotator = [[[self rotatorClass] rotator] retain];
		boundingVolume = nil;
		boundingVolumePadding = 0.0f;
		shouldUseFixedBoundingVolume = NO;
		location = kCC3VectorZero;
		globalLocation = kCC3VectorZero;
		projectedLocation = kCC3VectorZero;
		scale = kCC3VectorUnitCube;
		globalScale = kCC3VectorUnitCube;
		scaleTolerance = [[self class] defaultScaleTolerance];
		isTransformDirty = NO;			// everything starts out at identity
		isTouchEnabled = NO;
		shouldInheritTouchability = YES;
		shouldAllowTouchableWhenInvisible = NO;
		isAnimationEnabled = YES;
		visible = YES;
		isRunning = NO;
		shouldCleanupWhenRemoved = YES;
		shouldAutoremoveWhenEmpty = NO;
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

// Protected properties for copying
-(BOOL) rawVisible { return visible; }
-(BOOL) isTransformDirty { return isTransformDirty; }

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

	[transformMatrix populateFrom: another.transformMatrix];

	isTransformInvertedDirty = YES;							// create or rebuild lazily
	isGlobalRotationDirty = YES;							// create or rebuild lazily

	[rotator release];
	rotator = [another.rotator copy];						// retained
	
	[boundingVolume release];
	boundingVolume = [another.boundingVolume copy];			// retained
	boundingVolume.node = self;
	boundingVolumePadding = another.boundingVolumePadding;
	shouldUseFixedBoundingVolume = another.shouldUseFixedBoundingVolume;

	[animation release];
	animation = [another.animation retain];					// retained...not copied

	location = another.location;
	globalLocation = another.globalLocation;
	projectedLocation = another.projectedLocation;
	scale = another.scale;
	globalScale = another.globalScale;
	scaleTolerance = another.scaleTolerance;
	isTransformDirty = another.isTransformDirty;
	isTouchEnabled = another.isTouchEnabled;
	shouldInheritTouchability = another.shouldInheritTouchability;
	shouldAllowTouchableWhenInvisible = another.shouldAllowTouchableWhenInvisible;
	isAnimationEnabled = another.isAnimationEnabled;
	visible = another.rawVisible;
	isRunning = another.isRunning;
	shouldCleanupWhenRemoved = another.shouldCleanupWhenRemoved;
	shouldAutoremoveWhenEmpty = another.shouldAutoremoveWhenEmpty;
	self.shouldDrawDescriptor = another.shouldDrawDescriptor;		// May create a child node
	self.shouldDrawWireframeBox = another.shouldDrawWireframeBox;	// May create a child node
}

/**
 * Copying of children is performed here instead of in populateFrom:
 * so that subclasses will be completely configured before children are added.
 * Subclasses that extend copying should not override this method,
 * but should override the populateFrom: method instead.
 */
-(id) copyWithZone: (NSZone*) zone withName: (NSString*) aName asClass: (Class) aClass {
	CC3Node* aCopy = (CC3Node*)[super copyWithZone: zone withName: aName asClass: aClass];
	[aCopy copyChildrenFrom: self];
	return aCopy;
}

/**
 * Adds copies of the child nodes of the other node to this node.
 * Only the children that have the shouldIncludeInDeepCopy property
 * set to YES are copied.
 */
-(void) copyChildrenFrom: (CC3Node*) another {
	[self removeAllChildren];
	CCArray* otherKids = another.children;
	for (CC3Node* n in otherKids) {
		if (n.shouldIncludeInDeepCopy) {
			[self addChild: [n copyAutoreleased]];	// retained by collection
		}
	}
}

// Implementations to keep compiler happy so this method can be included in interface for documentation.
-(id) copy { return [super copy]; }
-(id) copyWithName: (NSString*) aName { return [super copyWithName: aName]; }

-(void) createGLBuffers {
	for (CC3Node* child in children) {
		[child createGLBuffers];
	}
}

-(void) deleteGLBuffers {
	for (CC3Node* child in children) {
		[child deleteGLBuffers];
	}
}

-(void) releaseRedundantData {
	for (CC3Node* child in children) {
		[child releaseRedundantData];
	}
}

-(void) retainVertexLocations {
	for (CC3Node* child in children) {
		[child retainVertexLocations];
	}
}

-(void) retainVertexNormals {
	for (CC3Node* child in children) {
		[child retainVertexNormals];
	}
}

-(void) retainVertexColors {
	for (CC3Node* child in children) {
		[child retainVertexColors];
	}
}

-(void) retainVertexTextureCoordinates {
	for (CC3Node* child in children) {
		[child retainVertexTextureCoordinates];
	}
}

-(void) retainVertexIndices {
	for (CC3Node* child in children) {
		[child retainVertexIndices];
	}
}

-(void) doNotBufferVertexLocations {
	for (CC3Node* child in children) {
		[child doNotBufferVertexLocations];
	}
}

-(void) doNotBufferVertexNormals {
	for (CC3Node* child in children) {
		[child doNotBufferVertexNormals];
	}
}

-(void) doNotBufferVertexColors {
	for (CC3Node* child in children) {
		[child doNotBufferVertexColors];
	}
}

-(void) doNotBufferVertexTextureCoordinates {
	for (CC3Node* child in children) {
		[child doNotBufferVertexTextureCoordinates];
	}
}

-(void) doNotBufferVertexIndices {
	for (CC3Node* child in children) {
		[child doNotBufferVertexIndices];
	}
}


#pragma mark Texture alignment

-(void) alignTextures {
	for (CC3Node* child in children) {
		[child alignTextures];
	}
}

-(void) alignInvertedTextures {
	for (CC3Node* child in children) {
		[child alignInvertedTextures];
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

-(GLint) zOrder {
	GLint childCount = children ? children.count : 0;
	if (childCount > 0) {
		GLint zoSum = 0;
		for (CC3Node* child in children) {
			zoSum += child.zOrder;
		}
		return zoSum / childCount;
	}
	return 0;
}

-(void) setZOrder: (GLint) zo {
	for (CC3Node* child in children) {
		child.zOrder = zo;
	}
}


#pragma mark Updating

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

-(CC3Node*) dirtiestAncestor {
	CC3Node* dap = parent.dirtiestAncestor;
	if (dap) return dap;
	return (self.isTransformDirty) ? self : nil;
}

-(void) updateTransformMatrices {
	CC3Node* da = self.dirtiestAncestor;
	[[[self transformVisitorClass] visitor] visit: (da ? da : self)];
}

-(void) updateTransformMatrix {
	CC3Node* da = self.dirtiestAncestor;
	CC3NodeTransformingVisitor* visitor = [[self transformVisitorClass] visitor];
	visitor.shouldVisitChildren = NO;
	[visitor visit: (da ? da : self)];
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

-(CC3GLMatrix*) parentTransformMatrix {
	return parent.transformMatrix;
}

-(void) buildTransformMatrixWithVisitor: (CC3NodeTransformingVisitor*) visitor {
	[transformMatrix populateFrom: [visitor parentTansformMatrixFor: self]];
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
 * is changed. Updates the bounding volume of this node, and marks the transformInvertedMatrix
 * as dirty so it will be lazily rebuilt.
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
		
		LogCleanTrace(@"%@ with global scale (%.6f, %.6f, %.6f) and tolerance %.6f transform: %@ inverted %@to: %@",
					  self, self.globalScale.x, self.globalScale.y, self.globalScale.z,
					  self.scaleTolerance, transformMatrix,
					  (self.isTransformRigid ? @"rigidly " : @""), transformMatrixInverted);
		LogCleanTrace(@"validating right multiply: %@ \nvalidating left multiply: %@",
					  [CC3GLMatrix matrixByMultiplying: transformMatrix by: transformMatrixInverted],
					  [CC3GLMatrix matrixByMultiplying: transformMatrixInverted by: transformMatrix]);
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

/** Template method that rebuilds the bounding volume if it is not fixed. */
-(void) rebuildBoundingVolume {
	if (!shouldUseFixedBoundingVolume) {
		[boundingVolume markDirtyAndUpdate];
	}
}


#pragma mark Drawing

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {}

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

		// Uncomment and change name to verify culling:
//		if ( !intersects && [self.name isEqualToString: @"MyNodeName"] ) {
//			LogDebug(@"%@ does not intersect\n%@", self, aFrustum);
//		}
		return intersects;
	}
	return YES;
}

-(void) transformAndDrawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	LogTrace(@"Drawing %@", self);
	CC3OpenGLES11MatrixStack* gles11MatrixStack = [CC3OpenGLES11Engine engine].matrices.modelview;

	[gles11MatrixStack push];

	LogTrace(@"%@ applying transform matrix: %@", self, transformMatrix);
	[gles11MatrixStack multiply: transformMatrix.glMatrix];

	[visitor draw: self];

	[gles11MatrixStack pop];
}

-(void) checkDrawingOrder {
	for (CC3Node* child in children) {
		[child checkDrawingOrder];
	}
}


#pragma mark Node structural hierarchy

/**
 * When assigned to a new parent, ensure that the transform will be recalculated,
 * since it changes this child's overall transform.
 */
-(void) setParent: (CC3Node*) aNode {
	parent = aNode;
	[self markTransformDirty];
}

-(CC3Node*) rootAncestor {
	return parent ? parent.rootAncestor : self;
}

-(CC3World*) world {
	return parent.world;
}

-(CC3Camera*) activeCamera {
	return self.world.activeCamera;
}

/** Adds a child node and invokes didAddDescendant: so action can be taken by subclasses. */
-(void) addChild: (CC3Node*) aNode {
	// Don't add if child is nil or is already a child of this node
	NSAssert(aNode, @"Child CC3Node cannot be nil");
	if(aNode.parent == self) return;

	[aNode remove];				// Remove node from any existing parent
	if(!children) {
		children = [[CCArray array] retain];
	}
	[children addObject: aNode];
	aNode.parent = self;
	aNode.isRunning = self.isRunning;
	[self didAddDescendant: aNode];
	LogTrace(@"After adding %@, %@ now has children: %@", aNode, self, children);
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
 * Also removes this node if the shouldAutoremoveWhenEmpty property is YES, and the last
 * child has just been removed.
 */
-(void) removeChild: (CC3Node*) aNode {
	if (children && aNode) {
		NSUInteger indx = [children indexOfObjectIdenticalTo: aNode];
		if (indx != NSNotFound) {

			// If the children collection is the only thing referencing the child node, the
			// child node will be deallocated as soon as it is removed, and will be invalid
			// when passed to the didRemoveDescendant: method, or to other activities that
			// it may be subject to in the processing loop. To avoid problems, retain it for
			// the duration of this processing loop, so that it will still be valid until
			// we're done with it.
			[[aNode retain] autorelease];

			aNode.parent = nil;
			[children removeObjectAtIndex: indx];
			if (children.count == 0) {
				[children release];
				children = nil;
			}
			[aNode wasRemoved];
			[self didRemoveDescendant: aNode];
		}
		LogTrace(@"After removing %@, %@ now has children: %@", aNode, self, children);
		
		// If the last child has been removed, and this instance should autoremove when
		// that occurs, remove this node from the hierarchy as well. This must be performed
		// after everything else is done, particularly only after the didRemoveDescendant:
		// has been invoked so that that notification can propagate up the node hierarchy.
		if (!children && shouldAutoremoveWhenEmpty) {
			[self remove];
		}
	}
}

-(void) removeAllChildren {
	CCArray* myKids = [children copy];
	for (CC3Node* child in myKids) {
		[self removeChild: child];
	}
	[myKids release];
}

-(void) remove {
	[parent removeChild: self];
}

-(void) wasRemoved {
	if (shouldCleanupWhenRemoved) {
		[self cleanup];
	}
	self.isRunning = NO;
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
	[parent didAddDescendant: aNode];
}

/**
 * Invoked automatically when a node is removed as a child somewhere in the descendant structural
 * hierarchy of this node. The method is not only invoked on the immediate parent of the removed
 * node, but is actually invoked on all ancestors as well (parents of the parent).
 * This default implementation simply passes the notification up the parental ancestor chain.
 * Subclasses may override to take a specific interest in which nodes are being removed below them.
 */
-(void) didRemoveDescendant: (CC3Node*) aNode {
	[parent didRemoveDescendant: aNode];
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
	for (CC3Node* child in children) {
		CC3Node* childResult = [child getNodeNamed: aName];
		if (childResult) {
			return childResult;
		}
	}
	return nil;
}

-(CC3Node*) getNodeTagged: (GLuint) aTag {
	if (tag == aTag) {
		return self;
	}
	for (CC3Node* child in children) {
		CC3Node* childResult = [child getNodeTagged: aTag];
		if (childResult) {
			return childResult;
		}
	}
	return nil;
}

-(CCArray*) flatten {
	CCArray* allNodes = [CCArray array];
	[self flattenInto: allNodes];
	return allNodes;
}

-(void) flattenInto: (CCArray*) anArray {
	[anArray addObject: self];
	for (CC3Node* child in children) {
		[child flattenInto: anArray];
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
	for (CC3Node* child in children) {
		[child cleanup];
	}
}


#pragma mark Touch handling

-(BOOL) isTouchable {
	return (self.visible || shouldAllowTouchableWhenInvisible)
			&& (isTouchEnabled || ((parent && shouldInheritTouchability) ? parent.isTouchable : NO));
}

-(CC3Node*) touchableNode {
	return isTouchEnabled ? self : (parent ? parent.touchableNode : nil);
}

-(void) touchEnableAll {
	isTouchEnabled = YES;
	for (CC3Node* child in children) {
		[child touchEnableAll];
	}
}

-(void) touchDisableAll {
	isTouchEnabled = NO;
	for (CC3Node* child in children) {
		[child touchDisableAll];
	}
}


#pragma mark Animation

-(BOOL) containsAnimation {
	if (animation) {
		return YES;
	}
	for (CC3Node* child in children) {
		if (child.containsAnimation) {
			return YES;
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
	for (CC3Node* child in children) {
		[child enableAllAnimation];
	}
}

-(void) disableAllAnimation {
	[self disableAnimation];
	for (CC3Node* child in children) {
		[child disableAllAnimation];
	}
}

-(void) establishAnimationFrameAt: (ccTime) t {
	if (animation && isAnimationEnabled) {
		LogTrace(@"%@ animating frame at %.3f ms", self, t);
		[animation establishFrameAt: t forNode: self];
	}
	for (CC3Node* child in children) {
		[child establishAnimationFrameAt: t];
	}
}


#pragma mark Wireframe box and descriptor

/** Suffix used to name the descriptor child node. */
#define kDescriptorSuffix @"DESC"

/**
 * The name to use when creating or retrieving the descriptor child node of this node.
 * For uniqueness, includes the tag of this node in case this node has no name.
 */
-(NSString*) descriptorName {
	return [NSString stringWithFormat: @"%@-%u-%@", self.name, self.tag, kDescriptorSuffix];
}

-(CC3NodeDescriptor*) descriptorNode {
	return (CC3NodeDescriptor*)[self getNodeNamed: [self descriptorName]];
}

-(ccColor3B) initialDescriptorColor {
	return CCC3BFromCCC4F(self.initialWireframeBoxColor);
}

-(BOOL) shouldDrawDescriptor {
	return (self.descriptorNode != nil);
}

-(void) setShouldDrawDescriptor: (BOOL) shouldDraw {
	
	// Fetch the descriptor node from the child nodes.
	CC3NodeDescriptor* dn = self.descriptorNode;
	
	// If the descriptor node exists, but should not, remove it
	if (dn && !shouldDraw) {
		[dn remove];
	}
	
	// If there is no descriptor node, but there should be, add it by creating a
	// CC3NodeDescriptor from the description property and add it as a child of this node.
	if(!dn && shouldDraw) {
		CCLabelTTF* dnLabel = [CCLabelTTF labelWithString: self.description
												 fontName: @"Arial"
												 fontSize: [[self class] descriptorFontSize]];
		dn = [CC3NodeDescriptor nodeWithName: [self descriptorName] withBillboard: dnLabel];
		dn.color = self.initialDescriptorColor;
		[self addChild: dn];
	}
}

-(BOOL) shouldDrawAllDescriptors {
	if (!self.shouldDrawDescriptor) {
		return NO;
	}
	for (CC3Node* child in children) {
		if (!child.shouldDrawAllDescriptors) {
			return NO;
		}
	}
	return YES;
}

-(void) setShouldDrawAllDescriptors: (BOOL) shouldDraw {
	self.shouldDrawDescriptor = shouldDraw;
	for (CC3Node* child in children) {
		child.shouldDrawAllDescriptors = shouldDraw;
	}
}

// Initial font size for any new descriptors
static CGFloat descriptorFontSize = 14.0;

+(CGFloat) descriptorFontSize {
	return descriptorFontSize;
}

+(void) setDescriptorFontSize: (CGFloat) fontSize {
	descriptorFontSize = fontSize;
}


/** Suffix used to name the wireframe child node. */
#define kWireframeBoxSuffix @"WFB"

/**
 * The name to use when creating or retrieving the wireframe child node of this node.
 * For uniqueness, includes the tag of this node in case this node has no name.
 */
-(NSString*) wireframeBoxName {
	return [NSString stringWithFormat: @"%@-%u-%@", self.name, self.tag, kWireframeBoxSuffix];
}

-(CC3WireframeBoundingBoxNode*) wireframeBoxNode {
	return (CC3WireframeBoundingBoxNode*)[self getNodeNamed: [self wireframeBoxName]];
}

-(BOOL) shouldDrawWireframeBox {
	return (self.wireframeBoxNode != nil);
}

-(void) setShouldDrawWireframeBox: (BOOL) shouldDraw {
	
	// Fetch the wireframe node from the child nodes.
	CC3WireframeBoundingBoxNode* wf = self.wireframeBoxNode;
	
	// If the wireframe exists, but should not, remove it
	if (wf && !shouldDraw) {
		[wf remove];
	}
	
	// If there is no wireframe, but there should be, add it by creating a
	// CC3WireframeBoundingBoxNode from the boundingBox property and add it as a
	// child of this node. If the bounding box is null, don't create a wireframe.
	// The bounding box is set to update its vertices from the bounding box of
	// this node on each update pass to allow the wireframe to grow and shrink
	// along with the bounding box of this node and its descendants
	if(!wf && shouldDraw) {
		CC3BoundingBox bb = self.boundingBox;
		if ( !CC3BoundingBoxIsNull(bb) ) {
			wf = [CC3WireframeBoundingBoxNode nodeWithName: [self wireframeBoxName]];
			[wf populateAsWireBox: bb];
			wf.pureColor = self.initialWireframeBoxColor;
			wf.shouldAlwaysMeasureParentBoundingBox = YES;
			[self addChild: wf];
		}
	}
}

/** If default is transparent black, use the color of the node. */
-(ccColor4F) initialWireframeBoxColor {
	ccColor4F defaultColor = [[self class] wireframeBoxColor];
	return CCC4FAreEqual(defaultColor, kCCC4FBlackTransparent)
				? ccc4FFromccc3B(self.color) 
				: defaultColor;
}

// The default color to use when drawing the wireframes
static ccColor4F wireframeBoxColor = { 1.0, 1.0, 0.0, 1.0 };	// kCCC4FYellow

+(ccColor4F) wireframeBoxColor {
	return wireframeBoxColor;
}

+(void) setWireframeBoxColor: (ccColor4F) aColor {
	wireframeBoxColor = aColor;
}

-(BOOL) shouldDrawAllWireframeBoxes {
	if (!self.shouldDrawWireframeBox) {
		return NO;
	}
	for (CC3Node* child in children) {
		if (!child.shouldDrawAllWireframeBoxes) {
			return NO;
		}
	}
	return YES;
}

-(void) setShouldDrawAllWireframeBoxes: (BOOL) shouldDraw {
	self.shouldDrawWireframeBox = shouldDraw;
	for (CC3Node* child in children) {
		child.shouldDrawAllWireframeBoxes = shouldDraw;
	}
}

-(BOOL) shouldDrawAllLocalContentWireframeBoxes {
	for (CC3Node* child in children) {
		if (!child.shouldDrawAllLocalContentWireframeBoxes) {
			return NO;
		}
	}
	return YES;
}

-(void) setShouldDrawAllLocalContentWireframeBoxes: (BOOL) shouldDraw {
	for (CC3Node* child in children) {
		child.shouldDrawAllLocalContentWireframeBoxes = shouldDraw;
	}
}

-(void) addDirectionMarkerColored: (ccColor4F) aColor inDirection: (CC3Vector) aDirection {
	CC3BoundingBox bb = self.boundingBox;
	if ( !CC3BoundingBoxIsNull(bb) ) {
		NSString* dmName = [NSString stringWithFormat: @"%@-%u-DM-%@",
							self.name, self.tag, NSStringFromCC3Vector(aDirection)];
		CC3DirectionMarkerNode* dm = [CC3DirectionMarkerNode nodeWithName: dmName];

		CC3Vector lineVertices[2] = { kCC3VectorZero, kCC3VectorZero };
		[dm populateAsLineStripWith: 2 vertices: lineVertices andRetain: YES];

		dm.markerDirection = aDirection;
		dm.lineWidth = 4.0;
		dm.pureColor = aColor;
		[self addChild: dm];
	}
}

-(void) addDirectionMarker {
	[self addDirectionMarkerColored: [[self class] directionMarkerColor]
						inDirection: kCC3VectorUnitZNegative];
}

-(void) addAxesDirectionMarkers {
	[self addDirectionMarkerColored: kCCC4FRed inDirection: kCC3VectorUnitXPositive];
	[self addDirectionMarkerColored: kCCC4FGreen inDirection: kCC3VectorUnitYPositive];
	[self addDirectionMarkerColored: kCCC4FBlue inDirection: kCC3VectorUnitZPositive];
}

-(void) removeAllDirectionMarkers {
	CCArray* dirMks = self.directionMarkers;
	for (CC3DirectionMarkerNode* dm in dirMks) {
		[dm remove];
	}
}

-(CCArray*) directionMarkers {
	CCArray* dirMks = [CCArray array];
	for (CC3Node* child in children) {
		if ( [child isKindOfClass: [CC3DirectionMarkerNode class]] ) {
			[dirMks addObject: child];
		}
	}
	return dirMks;
}

/** If default is transparent black, use the color of the node. */
-(ccColor4F) initialDirectionMarkerColor {
	ccColor4F defaultColor = [[self class] directionMarkerColor];
	return CCC4FAreEqual(defaultColor, kCCC4FBlackTransparent)
				? ccc4FFromccc3B(self.color)
				: defaultColor;
}

// The default color to use when drawing the direction markers
static ccColor4F directionMarkerColor = { 1.0, 0.0, 0.0, 1.0 };		// kCCC4FRed

+(ccColor4F) directionMarkerColor {
	return directionMarkerColor;
}

+(void) setDirectionMarkerColor: (ccColor4F) aColor {
	directionMarkerColor = aColor;
}

-(BOOL) shouldContributeToParentBoundingBox { return NO; }

@end


#pragma mark -
#pragma mark CC3LocalContentNode

@interface CC3LocalContentNode (TemplateMethods)
@property(nonatomic, readonly) ccColor4F initialLocalContentWireframeBoxColor;
@end

@implementation CC3LocalContentNode

-(BOOL) hasLocalContent {
	return YES;
}

-(GLint) zOrder {
	return zOrder;
}

-(void) setZOrder: (GLint) zo {
	zOrder = zo;
	super.zOrder = zo;
}

-(CC3BoundingBox) localContentBoundingBox {
	return kCC3BoundingBoxNull;
}

-(CC3BoundingBox) globalLocalContentBoundingBox {
	
	// If the global bounding box is null, rebuild it, otherwise return it.
	if (CC3BoundingBoxIsNull(globalLocalContentBoundingBox)) {
		
		// Get the mesh bounding box (in local coords). If it's null, return null.
		CC3BoundingBox mbb = self.localContentBoundingBox;
		if (CC3BoundingBoxIsNull(mbb)) {
			return kCC3BoundingBoxNull;
		}
		
		// The eight vertices of the transformed mesh bounding box
		CC3Vector gbbVertices[8];
		CC3GLMatrix* tMtx = self.transformMatrix;
		
		// Get the corners of the local bounding box
		CC3Vector bbMin = mbb.minimum;
		CC3Vector bbMax = mbb.maximum;
		
		// Construct all 8 corner vertices of the local bounding box and transform each
		// to global coordinates. The result is an oriented-bounding-box.
		gbbVertices[0] = [tMtx transformLocation: cc3v(bbMin.x, bbMin.y, bbMin.z)];
		gbbVertices[1] = [tMtx transformLocation: cc3v(bbMin.x, bbMin.y, bbMax.z)];
		gbbVertices[2] = [tMtx transformLocation: cc3v(bbMin.x, bbMax.y, bbMin.z)];
		gbbVertices[3] = [tMtx transformLocation: cc3v(bbMin.x, bbMax.y, bbMax.z)];
		gbbVertices[4] = [tMtx transformLocation: cc3v(bbMax.x, bbMin.y, bbMin.z)];
		gbbVertices[5] = [tMtx transformLocation: cc3v(bbMax.x, bbMin.y, bbMax.z)];
		gbbVertices[6] = [tMtx transformLocation: cc3v(bbMax.x, bbMax.y, bbMin.z)];
		gbbVertices[7] = [tMtx transformLocation: cc3v(bbMax.x, bbMax.y, bbMax.z)];
		
		// Construct the global mesh bounding box that surrounds the eight global vertices
		for (int i = 0; i < 8; i++) {
			globalLocalContentBoundingBox = CC3BoundingBoxEngulfLocation(globalLocalContentBoundingBox, gbbVertices[i]);
		}

		LogTrace(@"%@ transformed local content bounding box: %@ to global %@ using: %@",
				 self, NSStringFromCC3BoundingBox(mbb),
				 NSStringFromCC3BoundingBox(globalLocalContentBoundingBox), tMtx);
	}
	return globalLocalContentBoundingBox;
}

/** Notify up the ancestor chain...then check my children by invoking superclass implementation. */
-(void) checkDrawingOrder {
	[parent descendantDidModifySequencingCriteria: self];
	[super checkDrawingOrder];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		globalLocalContentBoundingBox = kCC3BoundingBoxNull;
		zOrder = 0;
	}
	return self;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// The globalLocalContentBoundingBox is left uncopied so that it will start at
// kCC3BoundingBoxNull and be lazily created on next access.
-(void) populateFrom: (CC3MeshNode*) another {
	[super populateFrom: another];

	// Could create a child node
	self.shouldDrawLocalContentWireframeBox = another.shouldDrawLocalContentWireframeBox;
	
	zOrder = another.zOrder;
}


#pragma mark Transformations

/** Overridden to force a lazy recalculation of the globalLocalContentBoundingBox. */
-(void) transformMatrixChanged {
	[super transformMatrixChanged];
	globalLocalContentBoundingBox = kCC3BoundingBoxNull;
}


#pragma mark Wireframe box and descriptor

/** Overridden to return local content box color */
-(ccColor3B) initialDescriptorColor {
	return CCC3BFromCCC4F(self.initialLocalContentWireframeBoxColor);
}

/** Suffix used to name the local content wireframe. */
#define kLocalContentWireframeBoxSuffix @"LCWFB"

/**
 * The name to use when creating or retrieving the wireframe node of this node's local content.
 * For uniqueness, includes the tag of this node in case this node has no name.
 */
-(NSString*) localContentWireframeBoxName {
	return [NSString stringWithFormat: @"%@-%u-%@", self.name, self.tag, kLocalContentWireframeBoxSuffix];
}

-(CC3WireframeBoundingBoxNode*) localContentWireframeBoxNode {
	return (CC3WireframeBoundingBoxNode*)[self getNodeNamed: [self localContentWireframeBoxName]];
}

-(BOOL) shouldDrawLocalContentWireframeBox {
	return (self.localContentWireframeBoxNode != nil);
}

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {
	
	// Fetch the wireframe node from the child nodes.
	CC3WireframeBoundingBoxNode* wf = self.localContentWireframeBoxNode;
	
	// If the wireframe exists, but should not, remove it
	if (wf && !shouldDraw) {
		[wf remove];
	}
	
	// If there is no wireframe, but there should be, add it by creating a
	// CC3WireframeLocalContentBoundingBoxNode from the localContentBoundingBox
	// property and add it as a child of this node. If the bounding box is null,
	// don't create a wireframe. Since the local content of a node does not
	// normally change shape, the bounding box is NOT set to update its vertices
	// by default from the bounding box of this node on each update pass.
	if(!wf && shouldDraw) {
		CC3BoundingBox mbb = self.localContentBoundingBox;
		if ( !CC3BoundingBoxIsNull(mbb) ) {
			wf = [CC3WireframeLocalContentBoundingBoxNode nodeWithName: [self localContentWireframeBoxName]];
			[wf populateAsWireBox: mbb];
			wf.pureColor = self.initialLocalContentWireframeBoxColor;
			[self addChild: wf];
		}
	}
}

/** If default is transparent black, use the color of the node. */
-(ccColor4F) initialLocalContentWireframeBoxColor {
	ccColor4F defaultColor = [[self class] localContentWireframeBoxColor];
	return CCC4FAreEqual(defaultColor, kCCC4FBlackTransparent)
				? ccc4FFromccc3B(self.color) 
				: defaultColor;
}

// The default color to use when drawing the wireframes of the local content
static ccColor4F localContentWireframeBoxColor = { 1.0, 0.0, 1.0, 1.0 };	// kCCC4FMagenta

+(ccColor4F) localContentWireframeBoxColor {
	return localContentWireframeBoxColor;
}

+(void) setLocalContentWireframeBoxColor: (ccColor4F) aColor {
	localContentWireframeBoxColor = aColor;
}

-(BOOL) shouldDrawAllLocalContentWireframeBoxes {
	if (!self.shouldDrawLocalContentWireframeBox) {
		return NO;
	}
	return super.shouldDrawAllLocalContentWireframeBoxes;
}

-(void) setShouldDrawAllLocalContentWireframeBoxes: (BOOL) shouldDraw {
	self.shouldDrawLocalContentWireframeBox = shouldDraw;
	super.shouldDrawAllLocalContentWireframeBoxes = shouldDraw;
}

-(BOOL) shouldContributeToParentBoundingBox { return YES; }

@end


#pragma mark -
#pragma mark CC3Rotator

@interface CC3Rotator (TemplateMethods)
-(void) ensureRotationFromMatrix;
-(void) ensureQuaternionFromMatrix;
-(void) ensureQuaternionFromAxisAngle;
-(void) ensureAxisAngleFromQuaternion;
-(void) applyRotation;
-(void) populateFrom: (CC3Rotator*) another;
@property(nonatomic, readonly) BOOL isRotationDirty;
@property(nonatomic, readonly) BOOL isMatrixDirtyByRotation;
@property(nonatomic, readonly) BOOL isQuaternionDirty;
@property(nonatomic, readonly) BOOL isMatrixDirtyByQuaternion;
@property(nonatomic, readonly) BOOL isAxisAngleDirty;
@property(nonatomic, readonly) BOOL isQuaternionDirtyByAxisAngle;
@end

@implementation CC3Rotator

-(void) dealloc {
	[rotationMatrix release];
	[super dealloc];
}

-(CC3Vector) rotation {
	[self ensureRotationFromMatrix];
	return rotation;
}

-(void) setRotation:(CC3Vector) aRotation {
	rotation = CC3VectorRotationModulo(aRotation);

	isRotationDirty = NO;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;

	matrixIsDirtyBy = kCC3MatrixIsDirtyByRotation;
}

-(void) rotateBy: (CC3Vector) aRotation {
	[rotationMatrix rotateBy: CC3VectorRotationModulo(aRotation)];
	
	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;

	matrixIsDirtyBy = kCC3MatrixIsNotDirty;
}

-(CC3Vector4) quaternion {
	[self ensureQuaternionFromAxisAngle];
	[self ensureQuaternionFromMatrix];
	return quaternion;
}

-(void) setQuaternion:(CC3Vector4) aQuaternion {
	quaternion = aQuaternion;

	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = NO;
	isQuaternionDirtyByAxisAngle = NO;

	matrixIsDirtyBy = kCC3MatrixIsDirtyByQuaternion;
}

-(void) rotateByQuaternion: (CC3Vector4) aQuaternion {
	[rotationMatrix rotateByQuaternion: aQuaternion];
	
	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
	
	matrixIsDirtyBy = kCC3MatrixIsNotDirty;
}

-(CC3Vector) rotationAxis {
	[self ensureAxisAngleFromQuaternion];
	return rotationAxis;
}

-(void) setRotationAxis: (CC3Vector) aDirection {
	rotationAxis = aDirection;
	
	isRotationDirty = YES;
	isAxisAngleDirty = NO;
	isQuaternionDirty = NO;
	isQuaternionDirtyByAxisAngle = YES;
	
	matrixIsDirtyBy = kCC3MatrixIsDirtyByAxisAngle;
}

-(GLfloat) rotationAngle {
	[self ensureAxisAngleFromQuaternion];
	return rotationAngle;
}

-(void) setRotationAngle: (GLfloat) anAngle {
	rotationAngle = CC3CyclicAngle(anAngle);
	
	isRotationDirty = YES;
	isAxisAngleDirty = NO;
	isQuaternionDirty = NO;
	isQuaternionDirtyByAxisAngle = YES;
	
	matrixIsDirtyBy = kCC3MatrixIsDirtyByAxisAngle;
}

-(void) rotateByAngle: (GLfloat) anAngle aroundAxis: (CC3Vector) anAxis {
	CC3Vector4 q = CC3QuaternionFromAxisAngle(CC3Vector4FromCC3Vector(anAxis, anAngle));
	[self rotateByQuaternion: q];
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
	isAxisAngleDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;

	matrixIsDirtyBy = kCC3MatrixIsNotDirty;
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
		quaternion = kCC3Vector4QuaternionIdentity;
		rotationAxis = kCC3VectorZero;
		rotationAngle = 0.0;
		isRotationDirty = NO;
		isQuaternionDirty = NO;
		isAxisAngleDirty = NO;
		isQuaternionDirtyByAxisAngle = NO;
		matrixIsDirtyBy = kCC3MatrixIsNotDirty;
	}
	return self;
}

+(id) rotatorOnRotationMatrix: (CC3GLMatrix*) aGLMatrix {
	return [[[self alloc] initOnRotationMatrix: aGLMatrix] autorelease];
}

// Protected properties for copying
-(BOOL) isRotationDirty { return isRotationDirty; }
-(BOOL) isAxisAngleDirty { return isAxisAngleDirty; }
-(BOOL) isQuaternionDirty { return isQuaternionDirty; }
-(BOOL) isQuaternionDirtyByAxisAngle { return isQuaternionDirtyByAxisAngle; }
-(BOOL) matrixIsDirtyBy { return matrixIsDirtyBy; }

-(id) copyWithZone: (NSZone*) zone {
	CC3Rotator* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Rotator*) another {

	[rotationMatrix populateFrom: another.rotationMatrix];

	rotation = another.rotation;
	quaternion = another.quaternion;
	rotationAxis = another.rotationAxis;
	rotationAngle = another.rotationAngle;
	isRotationDirty = another.isRotationDirty;
	isAxisAngleDirty = another.isAxisAngleDirty;
	isQuaternionDirty = another.isQuaternionDirty;
	isQuaternionDirtyByAxisAngle = another.isQuaternionDirtyByAxisAngle;
	matrixIsDirtyBy = another.matrixIsDirtyBy;
}

/** If needed, extracts and sets the rotation Euler angles from the encapsulated rotation matrix. */
-(void) ensureRotationFromMatrix {
	if (isRotationDirty) {
		rotation = [self.rotationMatrix extractRotation];
		isRotationDirty = NO;
	}
}

/** If needed, extracts and sets the quaternion from the encapsulated rotation matrix. */
-(void) ensureQuaternionFromMatrix {
	if (isQuaternionDirty) {
		quaternion = [self.rotationMatrix extractQuaternion];
		isQuaternionDirty = NO;
	}
}

/** If needed, extracts and sets the quaternion from the encapsulated rotation axis and angle. */
-(void) ensureQuaternionFromAxisAngle {
	if (isQuaternionDirtyByAxisAngle) {
		quaternion = CC3QuaternionFromAxisAngle(CC3Vector4FromCC3Vector(rotationAxis, rotationAngle));
		isQuaternionDirtyByAxisAngle = NO;
	}
}

/**
 * If needed, extracts and returns a rotation axis and angle from the encapsulated quaternion.
 * If the rotation angle is zero, the axis is undefined, and will be set to the zero vector.
 *
 * The rotationAxis can point in one of two equally valid directions. THe choice is made to
 * return the direction that is closest to the previous rotation angle. This step is taken
 * for consistency, so that small changes in rotation wont suddenly flip the rotation axis
 * and angle.
 *
 * The rotation angle will be clamped to +/-180 degrees. The rotationAxis can point in one
 */
-(void) ensureAxisAngleFromQuaternion {
	if (isAxisAngleDirty) {
		CC3Vector4 axisAngle = CC3AxisAngleFromQuaternion(self.quaternion);
		CC3Vector qAxis = CC3VectorFromTruncatedCC3Vector4(axisAngle);
		GLfloat qAngle = CC3SemiCyclicAngle(axisAngle.w);
		if ( CC3VectorDot(qAxis, rotationAxis) < 0 ) {
			rotationAxis = CC3VectorNegate(qAxis);
			rotationAngle = -qAngle;
		} else {
			rotationAxis = qAxis;
			rotationAngle = qAngle;
		}
		isAxisAngleDirty = NO;
	}
}

/** Recalculates the rotation matrix from the most recently set rotation or quaternion property. */
-(void) applyRotation {
	switch (matrixIsDirtyBy) {
		case kCC3MatrixIsDirtyByRotation:
			[rotationMatrix populateFromRotation: self.rotation];
			matrixIsDirtyBy = kCC3MatrixIsNotDirty;
			break;
		case kCC3MatrixIsDirtyByQuaternion:
		case kCC3MatrixIsDirtyByAxisAngle:
			[rotationMatrix populateFromQuaternion: self.quaternion];
			matrixIsDirtyBy = kCC3MatrixIsNotDirty;
			break;
		default:
			break;
	}
}

-(void) applyRotationTo: (CC3GLMatrix*) aMatrix {
	[aMatrix multiplyByMatrix: self.rotationMatrix];	// Rotation matrix is built lazily if needed
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ with rotation: %@, quaternion: %@, rotation axis: %@, rotation angle %.3f",
			[self class],
			NSStringFromCC3Vector(self.rotation),
			NSStringFromCC3Vector4(self.quaternion),
			NSStringFromCC3Vector(self.rotationAxis),
			self.rotationAngle];
}

@end

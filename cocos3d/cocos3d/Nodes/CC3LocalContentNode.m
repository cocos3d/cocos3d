/**
 * CC3LocalContentNode.m
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
 * See header file CC3LocalContentNode.h for full API documentation.
 */

#import "CC3LocalContentNode.h"
#import "CC3UtilityMeshNodes.h"


@interface CC3Node (TemplateMethods)
-(void) descendantDidModifySequencingCriteria: (CC3Node*) aNode;
@end


#pragma mark -
#pragma mark CC3LocalContentNode

@implementation CC3LocalContentNode

-(BOOL) hasLocalContent { return YES; }

-(GLint) zOrder { return _zOrder; }

-(void) setZOrder: (GLint) zo {
	_zOrder = zo;
	super.zOrder = zo;
}

-(CC3Vector) localContentCenterOfGeometry {
	CC3Box bb = self.localContentBoundingBox;
	return CC3BoxIsNull(bb) ? kCC3VectorZero : CC3BoxCenter(bb);
}

-(CC3Vector) globalLocalContentCenterOfGeometry {
	return [self.globalTransformMatrix transformLocation: self.localContentCenterOfGeometry];
}

// Overridden to return the localContentBoundingBox if no children.
-(CC3Box) boundingBox { return _children ? [super boundingBox] : self.localContentBoundingBox; }

-(CC3Box) localContentBoundingBox { return kCC3BoxNull; }

-(CC3Box) globalLocalContentBoundingBox {
	// If the global bounding box is null, rebuild it, otherwise return it.
	if (CC3BoxIsNull(_globalLocalContentBoundingBox))
		_globalLocalContentBoundingBox = [self localContentBoundingBoxRelativeTo: nil];
	return _globalLocalContentBoundingBox;
}

-(CC3Box) localContentBoundingBoxRelativeTo: (CC3Node*) ancestor {
	CC3Box lcbb = self.localContentBoundingBox;
	if (ancestor == self) return lcbb;

	CC3Matrix4x3 tMtx;
	[self.globalTransformMatrix populateCC3Matrix4x3: &tMtx];
	[ancestor.globalTransformMatrixInverted leftMultiplyIntoCC3Matrix4x3: &tMtx];
	
	// The eight vertices of the transformed local bounding box
	CC3Vector bbVertices[8];
	
	// Get the corners of the local bounding box
	CC3Vector bbMin = lcbb.minimum;
	CC3Vector bbMax = lcbb.maximum;
	
	// Construct all 8 corner vertices of the local bounding box and transform each
	// to the coordinate system of the ancestor. The result is an oriented-bounding-box.
	bbVertices[0] = CC3Matrix4x3TransformLocation(&tMtx, cc3v(bbMin.x, bbMin.y, bbMin.z));
	bbVertices[1] = CC3Matrix4x3TransformLocation(&tMtx, cc3v(bbMin.x, bbMin.y, bbMax.z));
	bbVertices[2] = CC3Matrix4x3TransformLocation(&tMtx, cc3v(bbMin.x, bbMax.y, bbMin.z));
	bbVertices[3] = CC3Matrix4x3TransformLocation(&tMtx, cc3v(bbMin.x, bbMax.y, bbMax.z));
	bbVertices[4] = CC3Matrix4x3TransformLocation(&tMtx, cc3v(bbMax.x, bbMin.y, bbMin.z));
	bbVertices[5] = CC3Matrix4x3TransformLocation(&tMtx, cc3v(bbMax.x, bbMin.y, bbMax.z));
	bbVertices[6] = CC3Matrix4x3TransformLocation(&tMtx, cc3v(bbMax.x, bbMax.y, bbMin.z));
	bbVertices[7] = CC3Matrix4x3TransformLocation(&tMtx, cc3v(bbMax.x, bbMax.y, bbMax.z));
	
	// Construct a transformed mesh bounding box that surrounds the eight global vertices
	CC3Box bb = kCC3BoxNull;
	for (int i = 0; i < 8; i++) bb = CC3BoxEngulfLocation(bb, bbVertices[i]);
	return bb;
}

// Overridden to include local content
-(CC3Box) boundingBoxRelativeTo: (CC3Node*) ancestor {
	CC3Box lcbb = (self.shouldContributeToParentBoundingBox
				   ? [self localContentBoundingBoxRelativeTo: ancestor]
				   : kCC3BoxNull);
	return CC3BoxUnion(lcbb, [super boundingBoxRelativeTo: ancestor]);
}

/** Notify up the ancestor chain...then check my children by invoking superclass implementation. */
-(void) checkDrawingOrder {
	[_parent descendantDidModifySequencingCriteria: self];
	[super checkDrawingOrder];
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_globalLocalContentBoundingBox = kCC3BoxNull;
		_zOrder = 0;
	}
	return self;
}

-(void) populateFrom: (CC3LocalContentNode*) another {
	[super populateFrom: another];

	// The globalLocalContentBoundingBox property is left uncopied so that
	// it will start at kCC3BoxNull and be lazily created on next access.

	// Could create a child node
	self.shouldDrawLocalContentWireframeBox = another.shouldDrawLocalContentWireframeBox;
	
	_zOrder = another.zOrder;
}


#pragma mark Transformations

/** Overridden to force a lazy recalculation of the globalLocalContentBoundingBox. */
-(void) markTransformDirty {
	[super markTransformDirty];
	_globalLocalContentBoundingBox = kCC3BoxNull;
}


#pragma mark Developer support

/** Overridden to return local content box color */
-(ccColor3B) initialDescriptorColor {
	return CCC3BFromCCC4F(self.initialLocalContentWireframeBoxColor);
}

/** Suffix used to name the local content wireframe. */
#define kLocalContentWireframeBoxSuffix @"LCWFB"

/** The name to use when creating or retrieving the wireframe node of this node's local content. */
-(NSString*) localContentWireframeBoxName {
	return [NSString stringWithFormat: @"%@-%@", self.name, kLocalContentWireframeBoxSuffix];
}

-(CC3WireframeBoundingBoxNode*) localContentWireframeBoxNode {
	return (CC3WireframeBoundingBoxNode*)[self getNodeNamed: [self localContentWireframeBoxName]];
}

-(BOOL) shouldDrawLocalContentWireframeBox { return (self.localContentWireframeBoxNode != nil); }

-(void) setShouldDrawLocalContentWireframeBox: (BOOL) shouldDraw {
	
	// Fetch the wireframe node from the child nodes.
	CC3WireframeBoundingBoxNode* wf = self.localContentWireframeBoxNode;
	
	// If the wireframe exists, but should not, remove it
	if (wf && !shouldDraw) [wf remove];
	
	// If there is no wireframe, but there should be, add it by creating a
	// CC3WireframeLocalContentBoundingBoxNode from the localContentBoundingBox
	// property and add it as a child of this node. If the bounding box is null,
	// don't create a wireframe. Since the local content of a node does not
	// normally change shape, the bounding box is NOT set to update its vertices
	// by default from the bounding box of this node on each update pass.
	if(!wf && shouldDraw) {
		CC3Box mbb = self.localContentBoundingBox;
		if ( !CC3BoxIsNull(mbb) ) {
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
static ccColor4F localContentWireframeBoxColor = { 1.0, 0.5, 0.0, 1.0 };	// kCCC4FOrange

+(ccColor4F) localContentWireframeBoxColor { return localContentWireframeBoxColor; }

+(void) setLocalContentWireframeBoxColor: (ccColor4F) aColor {
	localContentWireframeBoxColor = aColor;
}

-(BOOL) shouldDrawAllLocalContentWireframeBoxes {
	if (!self.shouldDrawLocalContentWireframeBox) return NO;
	return super.shouldDrawAllLocalContentWireframeBoxes;
}

-(void) setShouldDrawAllLocalContentWireframeBoxes: (BOOL) shouldDraw {
	self.shouldDrawLocalContentWireframeBox = shouldDraw;
	super.shouldDrawAllLocalContentWireframeBoxes = shouldDraw;
}

-(BOOL) shouldContributeToParentBoundingBox { return YES; }

@end

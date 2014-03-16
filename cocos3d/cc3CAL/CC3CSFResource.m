/*
 * CC3CSFResource.m
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
 * See header file CC3CSFResource.h for full API documentation.
 */

#import "CC3CSFResource.h"
#import "CC3DataStreams.h"

#define kCC3MaxCSFFileVersion		1300


@implementation CC3CSFResource

@synthesize fileVersion=_fileVersion, allNodes=_allNodes, ambientLight=_ambientLight;

-(void) dealloc {
	[_allNodes release];
	[super dealloc];
}

-(CC3CALNode*) getNodeWithCALIndex: (GLint) calIndex {
	for (CC3CALNode* calNode in _allNodes) if (calNode.calIndex == calIndex) return calNode;
	return nil;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_allNodes = [NSMutableArray new];		// retained
		_fileVersion = -1;
		_nodeCount = 0;
		_ambientLight = kCCC4FBlack;
	}
	return self;
}

-(BOOL) processFile: (NSString*) anAbsoluteFilePath {
	
	// Load the contents of the file and create a reader to parse those contents.
	NSData* csfData = [NSData dataWithContentsOfFile: anAbsoluteFilePath];
	CC3DataReader* reader = [CC3DataReader readerOnData: csfData];
	reader.isBigEndian = self.isBigEndian;

	if (csfData) {
		BOOL wasLoaded = [self readFrom: reader];
		if (wasLoaded) [self build];
		return wasLoaded;
	} else {
		LogError(@"Could not load %@", anAbsoluteFilePath.lastPathComponent);
		return NO;
	}
}


#pragma mark File reading

/** Populates this resource from the content of the specified reader. */
-(BOOL)	readFrom: (CC3DataReader*) reader {
	BOOL wasRead = YES;

	wasRead = wasRead && [self readHeaderFrom: reader];
	CC3Assert(wasRead, @"%@ file type or version is invalid", self);

	for (int nIdx = 0; nIdx < _nodeCount; nIdx++)
		wasRead = wasRead && [self readNode: nIdx from: reader];
	
	return wasRead;
}

/** Reads and validates the content header. */
-(BOOL)	readHeaderFrom: (CC3DataReader*) reader {
	//	[header]
	//		magic token				   4       const     "CSF\0"
	//		file version               4       integer   eg. 1300
	//		number of bones            4       integer
	//		ambient light red          4       float     scene ambient light color red (version 1300 and above)
	//		ambient light green        4       float     scene ambient light color green (version 1300 and above)
	//		ambient light blue         4       float     scene ambient light color blue (version 1300 and above)
	
	// Verify ile type
	if (reader.readByte != 'C') return NO;
	if (reader.readByte != 'S') return NO;
	if (reader.readByte != 'F') return NO;
	if (reader.readByte != '\0') return NO;
	
	_fileVersion = reader.readInteger;		// File version
	CC3Assert(_fileVersion <= kCC3MaxCSFFileVersion,
			  @"%@ cannot read CSF file format version %i. The maximum supported version is %i",
			  self, _fileVersion, kCC3MaxCSFFileVersion);
	
	_nodeCount = reader.readInteger;		// Number of nodes

	if (_fileVersion >= 1300) {
		_ambientLight.r = reader.readFloat;
		_ambientLight.g = reader.readFloat;
		_ambientLight.b = reader.readFloat;
	}

	LogRez(@"Read header CSF version %i containing %i nodes and ambient light color %@",
		   _fileVersion, _nodeCount, NSStringFromCCC4F(_ambientLight));

	return !reader.wasReadBeyondEOF;
}

/** Reads a single node, with the specified index, from the content. */
-(BOOL)	readNode: (int) nodeIdx from: (CC3DataReader*) reader {
	//	[nodes]
	//		length of bone name      4       integer
	//		bone name                var     string
	//		translation x            4       float     relative translation to parent bone
	//		translation y            4       float
	//		translation z            4       float
	//		rotation x               4       float     relative rotation to parent bone
	//		rotation y               4       float     stored as a quaternion
	//		rotation z               4       float
	//		rotation w               4       float
	//		local translation x      4       float     translation to bring a vertex from
	//		local translation y      4       float     model space into bone space
	//		local translation z      4       float
	//		local rotation x         4       float     rotation to bring a vertex from
	//		local rotation y         4       float     model space into bone space
	//		local rotation z         4       float
	//		local rotation w         4       float
	//		parent bone id           4       integer   index to parent bone
	//		lighting type            4       integer   lighting type (version 1300 and above)
	//		bone color red           4       float     bone color red (version 1300 and above)
	//		bone color green         4       float     bone color green (version 1300 and above)
	//		bone color blue          4       float     bone color blue (version 1300 and above)
	//		number of children       4       integer
	//		[children]
	//			child bone id        4       integer   index to child bone

	// Retrieve the name chars into a buffer, create an NSString from it, and release the buffer.
	NSString* nodeName = nil;
	int nameLen = reader.readInteger;
	if (nameLen > 0) {
		char cNodeName[nameLen];
		[reader readAll: nameLen bytes: cNodeName];
		nodeName = [NSString stringWithUTF8String: cNodeName];
	}

	// Node location
	CC3Vector location;
	location.x = reader.readFloat;
	location.y = reader.readFloat;
	location.z = reader.readFloat;
	
	// Node rotation quaternion
	CC3Quaternion quaternion;
	quaternion.x = reader.readFloat;
	quaternion.y = reader.readFloat;
	quaternion.z = reader.readFloat;
	quaternion.w = reader.readFloat;
	
	// Node vertex translation - ignored
	CC3Vector vtxTranslation;
	vtxTranslation.x = reader.readFloat;
	vtxTranslation.y = reader.readFloat;
	vtxTranslation.z = reader.readFloat;
	
	// Node vertex rotation quaternion - ignored
	CC3Quaternion vtxQuaternion;
	vtxQuaternion.x = reader.readFloat;
	vtxQuaternion.y = reader.readFloat;
	vtxQuaternion.z = reader.readFloat;
	vtxQuaternion.w = reader.readFloat;
	
	int parentIndex = reader.readInteger;
	
	// Create the node and populate it with content extracted from the reader.
	CC3CALNode* calNode = [CC3CALNode nodeWithName: nodeName];
	calNode.calIndex = nodeIdx;
	calNode.location = location;
	calNode.quaternion = quaternion;
	calNode.calParentIndex = parentIndex;

	// Bone color
	ccColor4F boneColor = kCCC4FBlack;
	if (_fileVersion >= 1300) {
		[reader readInteger];				// Lighting type - ignored
		boneColor.r = reader.readFloat;
		boneColor.g = reader.readFloat;
		boneColor.b = reader.readFloat;
		calNode.diffuseColor = boneColor;
	}

	// Skip through the indexes of all the children. This content is ignored.
	NSInteger childCount = reader.readInteger;
	for (NSInteger i = 0; i < childCount; i++) [reader readInteger];
	
	// Add the node to the collection of unstructured nodes
	[_allNodes addObject: calNode];

	LogTrace(@"Loaded node named %@ with CAL index %i, parent index %i, color %@, location %@, quaternion %@, vertex translation %@, vertex quaternion %@",
			 nodeName, nodeIdx, parentIndex, NSStringFromCCC4F(boneColor), NSStringFromCC3Vector(location), NSStringFromCC3Quaternion(quaternion),
			 NSStringFromCC3Vector(vtxTranslation), NSStringFromCC3Quaternion(vtxQuaternion));

	return !reader.wasReadBeyondEOF;
}

/**
 * Link the nodes with each other. This includes assembling the nodes into a structural
 * parent-child hierarchy. Base nodes, which have no parent, form the entries of the nodes array.
 */
-(void) build {
	LogRez(@"Building %@", self);
	for (CC3CALNode* aNode in _allNodes) {
		[aNode linkToCALNodes: _allNodes];
		if (aNode.isBaseCALNode) [self addNode: aNode];
	}
	[self logBuild];
}

-(void) logBuild {
#if LOGGING_REZLOAD
	NSMutableString* desc = [NSMutableString stringWithCapacity: 1000];
	for (CC3CALNode* calNode in self.nodes) [calNode appendStructureDescriptionTo: desc withIndent: 1];
	LogRez(@"Built %@ with nodes:%@", self, desc);
#endif
}

@end

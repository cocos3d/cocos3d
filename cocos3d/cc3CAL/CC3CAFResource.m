/*
 * CC3CAFResource.m
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
 * See header file CC3CAFResource.h for full API documentation.
 */

#import "CC3CAFResource.h"
#import "CC3DataStreams.h"
#import "CC3VertexSkinning.h"

#define kCC3MaxCAFFileVersion		1300


@implementation CC3CAFResource

@synthesize fileVersion=_fileVersion, animationDuration=_animationDuration;
@synthesize isCompressed=_isCompressed, flags=_flags;
@synthesize wasCSFResourceAttached=_wasCSFResourceAttached;
@synthesize shouldSwapYZ=_shouldSwapYZ;

static BOOL _defaultShouldSwapYZ = YES;

+(BOOL) defaultShouldSwapYZ { return _defaultShouldSwapYZ; }

+(void) setDefaultShouldSwapYZ: (BOOL) shouldSwap { _defaultShouldSwapYZ = shouldSwap; }

-(CC3Node*) getNodeMatching: (CC3Node*) node {
	CC3CALNode* matchedNode = (CC3CALNode*)[super getNodeMatching:node];
	if ( !matchedNode.isAnimationCorrectedForScale )
		[matchedNode correctAnimationToSkeletalScale: node.skeletalScale];
	return matchedNode;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_fileVersion = -1;
		_nodeCount = 0;
		_animationDuration = 0;
		_wasCSFResourceAttached = NO;
		_shouldSwapYZ = self.class.defaultShouldSwapYZ;
		_isCompressed = NO;
		_flags = 0;
	}
	return self;
}

-(id) initFromFile: (NSString*) cafFilePath linkedToCSFFile: (NSString*) csfFilePath {
	if ( (self = [self initFromFile: cafFilePath]) ) {
		[self linkToCSFResource: [CC3CSFResource resourceFromFile: csfFilePath]];
	}
	return self;
}

+(id) resourceFromFile: (NSString*) cafFilePath linkedToCSFFile: (NSString*) csfFilePath {
	CC3CAFResource* rez = (CC3CAFResource*)[self getResourceNamed: [self resourceNameFromFilePath: cafFilePath]];
	if (rez) {
		if (!rez.wasCSFResourceAttached)
			[rez linkToCSFResource: [CC3CSFResource resourceFromFile: csfFilePath]];
		return rez;
	}
	
	rez = [[self alloc] initFromFile: cafFilePath linkedToCSFFile: csfFilePath];
	[self addResource: rez];
	return [rez autorelease];
}


#pragma mark File reading

-(BOOL) processFile: (NSString*) anAbsoluteFilePath {
	
	// Load the contents of the file and create a reader to parse those contents.
	NSData* cafData = [NSData dataWithContentsOfFile: anAbsoluteFilePath];
	if (cafData) {
		CC3DataReader* reader = [CC3DataReader readerOnData: cafData];
		reader.isBigEndian = self.isBigEndian;
		return [self readFrom: reader];
	} else {
		LogError(@"Could not load %@", anAbsoluteFilePath.lastPathComponent);
		return NO;
	}
}

/** Populates this resource from the content of the specified reader. */
-(BOOL)	readFrom: (CC3DataReader*) reader {
	BOOL wasRead = YES;

	wasRead = wasRead && [self readHeaderFrom: reader];
	CC3Assert(wasRead, @"%@ file type or version is invalid", self);

	if (_animationDuration > 0.0f)
		for (NSInteger nIdx = 0; nIdx < _nodeCount; nIdx++)
			wasRead = wasRead && [self readNodeFrom: reader];
	
	return wasRead;
}

/** Reads and validates the content header. */
-(BOOL)	readHeaderFrom: (CC3DataReader*) reader {
	//	[header]
	//		magic token              4       const     "CAF\0"
	//		file version             4       integer   eg. 1000
	//		is compressed            4       integer   whether animation content is compressed (version 1300 and above)
	//		duration                 4       float     length of animation in seconds
	//		number of tracks         4       integer
	//		flags                    4       integer   bit-wise OR flags (version 1300 and above)
	
	// Verify ile type
	if (reader.readByte != 'C') return NO;
	if (reader.readByte != 'A') return NO;
	if (reader.readByte != 'F') return NO;
	if (reader.readByte != '\0') return NO;
	
	_fileVersion = reader.readInteger;		// File version
	CC3Assert(_fileVersion <= kCC3MaxCAFFileVersion,
			  @"%@ cannot read CAF file format version %i. The maximum supported version is %i",
			  self, _fileVersion, kCC3MaxCAFFileVersion);
	
	if (_fileVersion >= 1300) _isCompressed = (reader.readInteger != 0);
	CC3Assert( !_isCompressed, @"%@ cannot read compressed animation content."
			  @" Re-export the CAF file with uncompressed animation content.", self);

	_animationDuration = reader.readFloat;	// Animation duration

	// Number of nodes (tracks)
	_nodeCount = reader.readInteger;
	
	if (_fileVersion >= 1300) _flags = reader.readInteger;		// Flags - ignored

	LogRez(@"Read header CAF version %i with %@compressed animation of duration %.3f seconds"
		   @" and containing %i nodes and format flags %d",
		   _fileVersion, (_isCompressed ? @"" : @"un"), _animationDuration, _nodeCount, _flags);

	return !reader.wasReadBeyondEOF;
}

/** Reads a single node and its animation from the content in the specified reader. */
-(BOOL)	readNodeFrom: (CC3DataReader*) reader {
	//	[tracks]
	//		bone id                  4       integer   index to bone
	//		number of keyframes      4       integer

	// Node index and keyframe count
	GLint calNodeIdx = reader.readInteger;
	GLint frameCount = reader.readInteger;
	if (reader.wasReadBeyondEOF) return NO;

	LogRez(@"Loading node with CAL index %i with %i keyframes of animation", calNodeIdx, frameCount);

	// If no animation content, skip this node
	if (frameCount <= 0) return YES;

	// Create and populate the animation instance
	CC3ArrayNodeAnimation* anim = [CC3ArrayNodeAnimation animationWithFrameCount: (GLuint)frameCount];
	if ( ![self populateAnimation: anim from: reader] ) return NO;

	// Create the node, add the animation to it, and add it to the nodes array
	CC3CALNode* calNode = [CC3CALNode node];
	calNode.calIndex = calNodeIdx;
	calNode.animation = anim;
	[self addNode: calNode];

	return YES;
}

/** Populates the specified animation from the content in the specified reader. */
-(BOOL)	populateAnimation: (CC3ArrayNodeAnimation*) anim from: (CC3DataReader*) reader {
	//	[keyframes]
	//		time                   4       float     time of keyframe in seconds
	//		translation x          4       float     relative translation to parent bone
	//		translation y          4       float
	//		translation z          4       float
	//		rotation x             4       float     relative rotation to parent bone
	//		rotation y             4       float     stored as a quaternion
	//		rotation z             4       float
	//		rotation w             4       float

	// Allocate the animation content arrays
	CCTime* frameTimes = anim.allocateFrameTimes;
	CC3Vector* locations = anim.allocateLocations;
	CC3Quaternion* quaternions = anim.allocateQuaternions;

	GLuint frameCount = anim.frameCount;
	for (GLuint fIdx = 0; fIdx < frameCount; fIdx++) {
		
		// Frame time, normalized to range between 0 and 1.
		frameTimes[fIdx] = CLAMP(reader.readFloat / _animationDuration, 0.0f, 1.0f);

		// Location and rotation at frame
		if (_shouldSwapYZ) {
			
			locations[fIdx].x = reader.readFloat;
			locations[fIdx].z = -reader.readFloat;		// Swap for negated Y
			locations[fIdx].y = reader.readFloat;		// Swap for Z

			quaternions[fIdx].x = reader.readFloat;
			quaternions[fIdx].z = -reader.readFloat;	// Swap for negated Y
			quaternions[fIdx].y = reader.readFloat;		// Swap for Z
			quaternions[fIdx].w = reader.readFloat;

		} else {

			locations[fIdx].x = reader.readFloat;
			locations[fIdx].y = reader.readFloat;
			locations[fIdx].z = reader.readFloat;

			quaternions[fIdx].x = reader.readFloat;
			quaternions[fIdx].y = reader.readFloat;
			quaternions[fIdx].z = reader.readFloat;
			quaternions[fIdx].w = reader.readFloat;

		}

		LogTrace(@"Time: %.4f Loc: %@ Quat: %@ in frame %i",
				 frameTimes[fIdx], NSStringFromCC3Vector(locations[fIdx]),
				 NSStringFromCC3Quaternion(quaternions[fIdx]), fIdx);
	}
	
	return !reader.wasReadBeyondEOF;
}


#pragma mark Linking to other CAL files

-(void) linkToCSFResource: (CC3CSFResource*) csfRez {
	// Leave if the CSF doesn't exist, it has already been attached, or I haven't been loaded yet.
	if (!csfRez || _wasCSFResourceAttached || !self.wasLoaded) return;
	
	for (CC3CALNode* cafNode in _nodes) {
		CC3CALNode* csfNode = [csfRez getNodeWithCALIndex: cafNode.calIndex];
		if (csfNode) cafNode.name = csfNode.name;
	}
	_wasCSFResourceAttached = YES;
}

@end


#pragma mark Adding animation to nodes

@implementation CC3Node (CAFAnimation)

-(void) addAnimationFromCAFFile: (NSString*) cafFilePath asTrack: (GLuint) trackID {
	[self addAnimationInResource: [CC3CAFResource resourceFromFile: cafFilePath ] asTrack: trackID];
}

-(void) addAnimationFromCAFFile: (NSString*) cafFilePath
				linkedToCSFFile: (NSString*) csfFilePath
						asTrack: (GLuint) trackID {
	[self addAnimationInResource: [CC3CAFResource resourceFromFile: cafFilePath
												   linkedToCSFFile: csfFilePath]
				  asTrack: trackID];
}

-(GLuint) addAnimationFromCAFFile: (NSString*) cafFilePath {
	return [self addAnimationInResource: [CC3CAFResource resourceFromFile: cafFilePath ]];
}

-(GLuint) addAnimationFromCAFFile: (NSString*) cafFilePath
					  linkedToCSFFile: (NSString*) csfFilePath {
	return [self addAnimationInResource: [CC3CAFResource resourceFromFile: cafFilePath
														  linkedToCSFFile: csfFilePath]];
}

@end


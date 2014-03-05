/*
 * CC3PerformanceStatistics.m
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3PerformanceStatistics.h for full API documentation.
 */

#import "CC3PerformanceStatistics.h"


#pragma mark -
#pragma mark CC3PerformanceStatistics

@implementation CC3PerformanceStatistics

@synthesize updatesHandled=_updatesHandled, accumulatedUpdateTime=_accumulatedUpdateTime;
@synthesize nodesUpdated=_nodesUpdated, nodesTransformed=_nodesTransformed;
@synthesize framesHandled=_framesHandled, accumulatedFrameTime=_accumulatedFrameTime;
@synthesize nodesDrawn=_nodesDrawn, nodesVisitedForDrawing=_nodesVisitedForDrawing;
@synthesize drawingCallsMade=_drawingCallsMade, facesPresented=_facesPresented;


#pragma mark Accumulated update statistics

-(void) addUpdateTime: (CCTime) deltaTime {
	_updatesHandled++;
	_accumulatedUpdateTime += deltaTime;
}

-(void) addNodesUpdated: (GLuint) nodeCount { _nodesUpdated += nodeCount; }

-(void) incrementNodesUpdated { _nodesUpdated++; }

-(void) addNodesTransformed: (GLuint) nodeCount { _nodesTransformed += nodeCount; }

-(void) incrementNodesTransformed { _nodesTransformed++; }


#pragma mark Accumulated frame drawing statistics

-(void) addFrameTime: (CCTime) deltaTime {
	_framesHandled++;
	_accumulatedFrameTime += deltaTime;
}

-(void) addNodesVisitedForDrawing: (GLuint) nodeCount { _nodesVisitedForDrawing += nodeCount; }

-(void) incrementNodesVisitedForDrawing { _nodesVisitedForDrawing++; }

-(void) addNodesDrawn: (GLuint) nodeCount { _nodesDrawn += nodeCount; }

-(void) incrementNodesDrawn { _nodesDrawn++; }

-(void) addDrawingCallsMade: (GLuint) callCount { _drawingCallsMade += callCount; }

-(void) addFacesPresented: (GLuint) faceCount { _facesPresented += faceCount; }

-(void) addSingleCallFacesPresented: (GLuint) faceCount {
	_drawingCallsMade++;
	_facesPresented += faceCount;
}


#pragma mark Averaged update statistics

-(GLfloat) updateRate {
	return _accumulatedUpdateTime ? ((GLfloat)_updatesHandled / _accumulatedUpdateTime) : 0.0;
}

-(GLfloat) averageNodesUpdatedPerUpdate {
	return _framesHandled ? ((GLfloat)_nodesUpdated / (GLfloat)_updatesHandled) : 0.0;
}

-(GLfloat) averageNodesTransformedPerUpdate {
	return _framesHandled ? ((GLfloat)_nodesTransformed / (GLfloat)_updatesHandled) : 0.0;
}


#pragma mark Average frame drawing statistics

-(GLfloat) frameRate {
	return (_accumulatedFrameTime != 0.0f) ? ((GLfloat)_framesHandled / _accumulatedFrameTime) : 0.0;
}

-(GLfloat) averageNodesDrawnPerFrame {
	return _framesHandled ? ((GLfloat)_nodesDrawn / (GLfloat)_framesHandled) : 0.0;
}

-(GLfloat) averageNodesVisitedForDrawingPerFrame {
	return _framesHandled ? ((GLfloat)_nodesVisitedForDrawing / (GLfloat)_framesHandled) : 0.0;
}

-(GLfloat) averageDrawingCallsMadePerFrame {
	return _framesHandled ? ((GLfloat)_drawingCallsMade / (GLfloat)_framesHandled) : 0.0;
}

-(GLfloat) averageFacesPresentedPerFrame {
	return _framesHandled ? ((GLfloat)_facesPresented / (GLfloat)_framesHandled) : 0.0;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		[self reset];
	}
	return self;
}

+(id) statistics { return [[[self alloc] init] autorelease]; }

-(void) reset {
	_updatesHandled = 0;
	_accumulatedUpdateTime = 0;
	_nodesUpdated = 0;
	_nodesTransformed = 0;
	
	_framesHandled = 0;
	_accumulatedFrameTime = 0.0;
	_nodesVisitedForDrawing = 0;
	_nodesDrawn = 0;
	_drawingCallsMade = 0;
	_facesPresented = 0;
}

-(void) populateFrom: (CC3PerformanceStatistics*) another {
	_updatesHandled = another.updatesHandled;
	_accumulatedUpdateTime = another.accumulatedUpdateTime;
	_nodesUpdated = another.nodesUpdated;
	_nodesTransformed = another.nodesTransformed;
	
	_framesHandled = another.framesHandled;
	_accumulatedFrameTime = another.accumulatedFrameTime;
	_nodesVisitedForDrawing = another.nodesVisitedForDrawing;
	_nodesDrawn = another.nodesDrawn;
	_drawingCallsMade = another.drawingCallsMade;
	_facesPresented = another.facesPresented;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3PerformanceStatistics* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}

-(NSString*) description {
	return [NSString stringWithFormat: @"%@ fps: %.0f", [self class], self.frameRate];
}

-(NSString*) fullDescription {
	return [NSString stringWithFormat: @"%@ nodes drawn: %.0f, GL calls: %.0f, faces: %.0f",
			self.description, self.averageNodesDrawnPerFrame,
			self.averageDrawingCallsMadePerFrame, self.averageFacesPresentedPerFrame];
}

@end


#pragma mark -
#pragma mark CC3PerformanceStatisticsHistogram

@implementation CC3PerformanceStatisticsHistogram

-(GLint*) updateRateHistogram { return _updateRateHistogram; }

-(GLint*) frameRateHistogram { return _frameRateHistogram; }

-(GLint) getIndexOfInterval: (CCTime) deltaTime {
	return CLAMP((GLint)(1.0 / deltaTime), 0, kCC3RateHistogramSize - 1);
}


#pragma mark Accumulated update statistics

-(void) addUpdateTime: (CCTime) deltaTime {
	[super addUpdateTime: deltaTime];
	_updateRateHistogram[[self getIndexOfInterval: deltaTime]]++;
}


#pragma mark Accumulated frame drawing statistics

-(void) addFrameTime: (CCTime) deltaTime {
	[super addFrameTime: deltaTime];
	_frameRateHistogram[[self getIndexOfInterval: deltaTime]]++;
}


#pragma mark Allocation and initialization

-(void) reset {
	[super reset];
	memset(_frameRateHistogram, 0, kCC3RateHistogramSize * sizeof(_frameRateHistogram[0]));
	memset(_updateRateHistogram, 0, kCC3RateHistogramSize * sizeof(_updateRateHistogram[0]));
}

-(void) populateFrom: (CC3PerformanceStatisticsHistogram*) another {
	[super populateFrom: another];
	memcpy(_frameRateHistogram, another.frameRateHistogram, kCC3RateHistogramSize * sizeof(_frameRateHistogram[0]));
	memcpy(_updateRateHistogram, another.updateRateHistogram, kCC3RateHistogramSize * sizeof(_updateRateHistogram[0]));
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @"\n\tRate\tFrames\tUpdates"];
	for (int i = 0; i < kCC3RateHistogramSize; i++) {
		GLint fpsCount = _frameRateHistogram[i];
		GLint upsCount = _updateRateHistogram[i];
		if (fpsCount || upsCount) [desc appendFormat: @"\n\t%u\t%u\t%u", i, fpsCount, upsCount];
	}
	return desc;
}

@end


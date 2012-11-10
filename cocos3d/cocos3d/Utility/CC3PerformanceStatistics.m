/*
 * CC3PerformanceStatistics.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2011-2012 The Brenwill Workshop Ltd. All rights reserved.
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

@synthesize updatesHandled, accumulatedUpdateTime, nodesUpdated, nodesTransformed;
@synthesize framesHandled, accumulatedFrameTime, nodesVisitedForDrawing;
@synthesize nodesDrawn, drawingCallsMade, facesPresented;

-(void) dealloc {
	[super dealloc];
}


#pragma mark Accumulated update statistics

-(void) addUpdateTime: (ccTime) deltaTime {
	updatesHandled++;
	accumulatedUpdateTime += deltaTime;
}

-(void) addNodesUpdated: (GLuint) nodeCount {
	nodesUpdated += nodeCount;
}

-(void) incrementNodesUpdated {
	nodesUpdated++;
}

-(void) addNodesTransformed: (GLuint) nodeCount {
	nodesTransformed += nodeCount;
}

-(void) incrementNodesTransformed {
	nodesTransformed++;
}


#pragma mark Accumulated frame drawing statistics

-(void) addFrameTime: (ccTime) deltaTime {
	framesHandled++;
	accumulatedFrameTime += deltaTime;
}

-(void) addNodesVisitedForDrawing: (GLuint) nodeCount {
	nodesVisitedForDrawing += nodeCount;
}

-(void) incrementNodesVisitedForDrawing {
	nodesVisitedForDrawing++;
}

-(void) addNodesDrawn: (GLuint) nodeCount {
	nodesDrawn += nodeCount;
}

-(void) incrementNodesDrawn {
	nodesDrawn++;
}

-(void) addDrawingCallsMade: (GLuint) callCount {
	drawingCallsMade += callCount;
}

-(void) addFacesPresented: (GLuint) faceCount {
	facesPresented += faceCount;
}

-(void) addSingleCallFacesPresented: (GLuint) faceCount {
	drawingCallsMade++;
	facesPresented += faceCount;
}


#pragma mark Averaged update statistics

-(GLfloat) updateRate {
	return accumulatedUpdateTime ? ((GLfloat)updatesHandled / accumulatedUpdateTime) : 0.0;
}

-(GLfloat) averageNodesUpdatedPerUpdate {
	return framesHandled ? ((GLfloat)nodesUpdated / (GLfloat)updatesHandled) : 0.0;
}

-(GLfloat) averageNodesTransformedPerUpdate {
	return framesHandled ? ((GLfloat)nodesTransformed / (GLfloat)updatesHandled) : 0.0;
}


#pragma mark Average frame drawing statistics

-(GLfloat) frameRate {
	return (accumulatedFrameTime != 0.0f) ? ((GLfloat)framesHandled / accumulatedFrameTime) : 0.0;
}

-(GLfloat) averageNodesDrawnPerFrame {
	return framesHandled ? ((GLfloat)nodesDrawn / (GLfloat)framesHandled) : 0.0;
}

-(GLfloat) averageNodesVisitedForDrawingPerFrame {
	return framesHandled ? ((GLfloat)nodesVisitedForDrawing / (GLfloat)framesHandled) : 0.0;
}

-(GLfloat) averageDrawingCallsMadePerFrame {
	return framesHandled ? ((GLfloat)drawingCallsMade / (GLfloat)framesHandled) : 0.0;
}

-(GLfloat) averageFacesPresentedPerFrame {
	return framesHandled ? ((GLfloat)facesPresented / (GLfloat)framesHandled) : 0.0;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		[self reset];
	}
	return self;
}

+(id) statistics {
	return [[[self alloc] init] autorelease];
}

-(void) reset {
	updatesHandled = 0;
	accumulatedUpdateTime = 0;
	nodesUpdated = 0;
	nodesTransformed = 0;
	
	framesHandled = 0;
	accumulatedFrameTime = 0.0;
	nodesVisitedForDrawing = 0;
	nodesDrawn = 0;
	drawingCallsMade = 0;
	facesPresented = 0;
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3PerformanceStatistics*) another {
	updatesHandled = another.updatesHandled;
	accumulatedUpdateTime = another.accumulatedUpdateTime;
	nodesUpdated = another.nodesUpdated;
	nodesTransformed = another.nodesTransformed;
	
	framesHandled = another.framesHandled;
	accumulatedFrameTime = another.accumulatedFrameTime;
	nodesVisitedForDrawing = another.nodesVisitedForDrawing;
	nodesDrawn = another.nodesDrawn;
	drawingCallsMade = another.drawingCallsMade;
	facesPresented = another.facesPresented;
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

-(GLint*) updateRateHistogram {
	return updateRateHistogram;
}

-(GLint*) frameRateHistogram {
	return frameRateHistogram;
}

-(GLint) getIndexOfInterval: (ccTime) deltaTime {
	return CLAMP((GLint)(1.0 / deltaTime), 0, kCC3RateHistogramSize - 1);
}


#pragma mark Accumulated update statistics

-(void) addUpdateTime: (ccTime) deltaTime {
	[super addUpdateTime: deltaTime];
	updateRateHistogram[[self getIndexOfInterval: deltaTime]]++;
}


#pragma mark Accumulated frame drawing statistics

-(void) addFrameTime: (ccTime) deltaTime {
	[super addFrameTime: deltaTime];
	frameRateHistogram[[self getIndexOfInterval: deltaTime]]++;
}


#pragma mark Allocation and initialization

-(void) reset {
	[super reset];
	memset(frameRateHistogram, 0, kCC3RateHistogramSize * sizeof(frameRateHistogram[0]));
	memset(updateRateHistogram, 0, kCC3RateHistogramSize * sizeof(updateRateHistogram[0]));
}

-(void) populateFrom: (CC3PerformanceStatisticsHistogram*) another {
	[super populateFrom: another];
	memcpy(frameRateHistogram, another.frameRateHistogram, kCC3RateHistogramSize * sizeof(frameRateHistogram[0]));
	memcpy(updateRateHistogram, another.updateRateHistogram, kCC3RateHistogramSize * sizeof(updateRateHistogram[0]));
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 500];
	[desc appendFormat: @"%@", self.description];
	[desc appendFormat: @"\n\tRate\tFrames\tUpdates"];
	for (int i = 0; i < kCC3RateHistogramSize; i++) {
		GLint fpsCount = frameRateHistogram[i];
		GLint upsCount = updateRateHistogram[i];
		if (fpsCount || upsCount) {
			[desc appendFormat: @"\n\t%u\t%u\t%u", i, fpsCount, upsCount];
		}
	}
	return desc;
}

@end


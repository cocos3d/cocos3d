/*
 * CC3PerformanceStatistics.h
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
 */

/** @file */	// Doxygen marker


#import "CC3Foundation.h"
#import "CC3CC2Extensions.h"


#pragma mark -
#pragma mark CC3PerformanceStatistics

/**
 * Collects statistics about the updating and drawing performance of the 3D scene.
 *
 * To allow flexibility in calculating statistics, this class does not automatically
 * clear the accumulated statistics. It is the responsibility of the application to
 * read the values, and invoke the reset method on the instance periodically, to ensure
 * this instance does not overflow. Depending on the complexity and capabilities of your
 * application, you should reset the performance statistics at least every few seconds.
 */
@interface CC3PerformanceStatistics : NSObject <NSCopying> {
	GLuint _updatesHandled;
	CCTime _accumulatedUpdateTime;
	GLuint _nodesUpdated;
	GLuint _nodesTransformed;
	
	GLuint _framesHandled;
	CCTime _accumulatedFrameTime;
	GLuint _nodesVisitedForDrawing;
	GLuint _nodesDrawn;
	GLuint _drawingCallsMade;
	GLuint _facesPresented;
}


#pragma mark Accumulated update statistics

/** The number of updates that have been processed since the reset method was last invoked. */
@property(nonatomic, readonly) GLuint updatesHandled;

/** The total time accumulated for updates since the reset method was last invoked. */
@property(nonatomic, readonly) CCTime accumulatedUpdateTime;

/**
 * Adds the specified single-update delta-time to the accumulated update time,
 * and increments the count of updates handled by one.
 */
-(void) addUpdateTime: (CCTime) deltaTime;

/** The total number of nodes updated since the reset method was last invoked. */
@property(nonatomic, readonly) GLuint nodesUpdated;

/** Adds the specified number of nodes to the nodesUpdated property.  */
-(void) addNodesUpdated: (GLuint) nodeCount;

/** Increments the nodesUpdated property by one. */
-(void) incrementNodesUpdated;

/**
 * The total number of nodes whose globalTransformMatrix was recalculated
 * since the reset method was last invoked.
 */
@property(nonatomic, readonly) GLuint nodesTransformed;

/** Adds the specified number of nodes to the nodesTransformed property.  */
-(void) addNodesTransformed: (GLuint) nodeCount;

/** Increments the nodesTransformed property by one. */
-(void) incrementNodesTransformed;


#pragma mark Accumulated frame drawing statistics

/** The number of frames that have been processed since the reset method was last invoked. */
@property(nonatomic, readonly) GLuint framesHandled;

/** The total time accumulated for frames since the reset method was last invoked. */
@property(nonatomic, readonly) CCTime accumulatedFrameTime;

/**
 * Adds the specified single-frame delta-time to the accumulated frame time,
 * and increments the count of frame handled by one.
 */
-(void) addFrameTime: (CCTime) deltaTime;

/**
 * The total number of nodes visited for drawing since the reset method was last invoked.
 * This includes both nodes that were drawn, and nodes that were culled prior to drawing.
 *
 * The difference between this property and the nodesDrawn property is the total number of
 * nodes  that were not visible or were culled and not presented to the GL engine for drawing.
 */
@property(nonatomic, readonly) GLuint nodesVisitedForDrawing;

/** Adds the specified number of nodes to the nodesVisitedForDrawing property.  */
-(void) addNodesVisitedForDrawing: (GLuint) nodeCount;

/** Increments the nodesVisitedForDrawing property by one. */
-(void) incrementNodesVisitedForDrawing;

/**
 * The total number of nodes drawn by the GL engine since the reset method was last invoked.
 *
 * The difference between the nodesVisitedForDrawing property and this property is the
 * total number of nodes that were not visible or were culled and not presented to the
 * GL engine for drawing.
 */
@property(nonatomic, readonly) GLuint nodesDrawn;

/** Adds the specified number of nodes to the nodesDrawn property.  */
-(void) addNodesDrawn: (GLuint) nodeCount;

/** Increments the nodesDrawn property by one. */
-(void) incrementNodesDrawn;

/**
 * The total number of drawing calls that were made to the GL engine
 * (glDrawArrays & glDrawElements) since the reset method was last invoked.
 */
@property(nonatomic, readonly) GLuint drawingCallsMade;

/** Adds the specified number of drawing calls to the drawingCallsMade property.  */
-(void) addDrawingCallsMade: (GLuint) callCount;

/**
 * The total number of triangle faces presented to the GL engine since the reset method
 * was last invoked.
 *
 * When drawing lines or points, this will be the total number of lines
 * or points presented to the GL engine. This is not necessarily the number of triangles
 * (or other primitives) that were actually drawn, because the GL engine will cull faces
 * that are not visible to the camera.
 */
@property(nonatomic, readonly) GLuint facesPresented;

/** Adds the specified number of faces to the facesPresented property.  */
-(void) addFacesPresented: (GLuint) faceCount;

/**
 * Canvenience method that adds the specified number of faces to the facesPresented
 * property, and increments by one the number of drawing calls made.
 */
-(void) addSingleCallFacesPresented: (GLuint) faceCount;


#pragma mark Average update statistics

/**
 * The average update rate, calculated by dividing the
 * updatesHandled property by the accumulatedUpdateTime property.
 */
@property(nonatomic, readonly) GLfloat updateRate;

/**
 * The average nodes updated per update, calculated by dividing the
 * nodesUpdated property by the updatesHandled property.
 */
@property(nonatomic, readonly) GLfloat averageNodesUpdatedPerUpdate;

/**
 * The average nodes whose globalTransformMatrix was recalculated per update, calculated
 * by dividing the nodesTransformed property by the updatesHandled property.
 */
@property(nonatomic, readonly) GLfloat averageNodesTransformedPerUpdate;


#pragma mark Average frame drawing statistics

/**
 * The average drawing frame rate, calculated by dividing the
 * framesHandled property by the accumulatedFrameTime property.
 */
@property(nonatomic, readonly) GLfloat frameRate;

/**
 * The average nodes visited per drawing frame, calculated by dividing the
 * nodesVisitedForDrawing property by the framesHandled property.
 *
 * The difference between this property and the averageNodesDrawnPerFrame property is
 * the average number of nodes per frame that were not visible or were culled and not
 * presented to the GL engine for drawing.
 */
@property(nonatomic, readonly) GLfloat averageNodesVisitedForDrawingPerFrame;

/**
 * The average nodes drawn per drawing frame, calculated by dividing the nodesDrawn
 * property by the framesHandled property.
 *
 * The difference between the averageNodesVisitedForDrawingPerFrame property and this
 * property is the average number of nodes per frame that were not visible or were
 * culled and not presented to the GL engine for drawing.
 */
@property(nonatomic, readonly) GLfloat averageNodesDrawnPerFrame;

/**
 * The average GL drawing calls made per drawing frame, calculated by dividing the
 * drawingCallsMade property by the framesHandled property.
 */
@property(nonatomic, readonly) GLfloat averageDrawingCallsMadePerFrame;

/**
 * The average number of triangle faces presented to the GL engine per drawing frame,
 * calculated by dividing the facesPresented property by the framesHandled property.
 *
 * When drawing lines or points, this will be the total number of lines
 * or points presented to the GL engine. This is not necessarily the number of triangles
 * (or other primitives) that were actually drawn, because the GL engine will cull faces
 * that are not visible to the camera.
 */
@property(nonatomic, readonly) GLfloat averageFacesPresentedPerFrame;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance. */
+(id) statistics;

/**
 * Resets all the performance statistics back to zero.
 *
 * To allow flexibility in calculating statistics, this class does not automatically
 * clear the accumulated statistics. It is the responsibility of the application to
 * read the values, and invoke the reset method on the instance periodically, to ensure
 * this instance does not overflow. Depending on the complexity and capabilities of your
 * application, you should reset the performance statistics at least every few seconds.
 */
-(void) reset;

/** Returns a detailed descripton of this instance. */
-(NSString*) fullDescription;

@end


#pragma mark -
#pragma mark CC3PerformanceStatisticsHistogram

// Number of buckets in each of the histograms
#define kCC3RateHistogramSize 80

/**
 * Collects statistics about the updating and drawing performance of the 3D scene,
 * including a histogram for each of the raw updateRate and frameRate properties.
 *
 * These histograms provide more detail than the updateRate and frameRate properties,
 * which are, respectively, averages of the individual updateRates and frameRates,
 * since the previous reset.
 *
 * To allow flexibility in calculating statistics, this class does not automatically
 * clear the accumulated statistics, including the histograms. It is the responsibility
 * of the application to read the values, and invoke the reset method on the instance
 * periodically, to ensure this instance does not overflow. Depending on the complexity
 * and capabilities of your application, you should reset the performance statistics at
 * least every few seconds.
 */
@interface CC3PerformanceStatisticsHistogram : CC3PerformanceStatistics {
	GLint _updateRateHistogram[kCC3RateHistogramSize];
	GLint _frameRateHistogram[kCC3RateHistogramSize];
}

/**
 * Returns a histogram of the value of the update rate, as calculated on each update
 * pass. This provides more detail than the updateRate property, which is an average
 * of the individual updateRates, since the previous reset.
 *
 * This histogram is cleared when the reset method is invoked.
 */
@property(nonatomic, readonly) GLint* updateRateHistogram;

/**
 * Returns a histogram of the value of the frame rate, as calculated on each frame
 * drawing pass. This provides more detail than the frameRate property, which is an
 * average of the individual frameRates, since the previous reset.
 *
 * This histogram is cleared when the reset method is invoked.
 */
@property(nonatomic, readonly) GLint* frameRateHistogram;

@end


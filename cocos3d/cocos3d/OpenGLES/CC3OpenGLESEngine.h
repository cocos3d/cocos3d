/*
 * CC3OpenGLESEngine.h
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2010-2013 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3OpenGLESPlatform.h"
#import "CC3OpenGLESCapabilities.h"
#import "CC3OpenGLESMaterials.h"
#import "CC3OpenGLESTextures.h"
#import "CC3OpenGLESLighting.h"
#import "CC3OpenGLESMatrices.h"
#import "CC3OpenGLESVertexArrays.h"
#import "CC3OpenGLESState.h"
#import "CC3OpenGLESFog.h"
#import "CC3OpenGLESHints.h"
#import "CC3OpenGLESShaders.h"


/**
 * CC3OpenGLESEngine manages the state of the OpenGL ES engine.
 *
 * OpenGL ES is designed to be a state machine that operates
 * asynchronously from the application code that calls its functions.
 * Calls to most gl* functions queue up commands to the GL engine that
 * are processed by the GL engine asynchronously from the gl* call.
 *
 * This design allows GL command execution to be run on a different
 * processor than the application is running on, specifically a
 * hardware-assisted GPU.
 *
 * To maximize the throughput and performance of this design, it is
 * important that GL state is changed only when necessary, and that
 * querying of the GL state machine is avoided wherever possible.
 * 
 * By routing all GL requests through CC3OpenGLESEngine, this class
 * can keep track of the GL state change requests made to the GL engine,
 * and will only forward such requests to the GL engine if the state
 * really is changing.
 *
 * OpenGL defines many functions and state change options. The overall GL
 * functionality covered by CC3OpenGLESEngine is broken down into the
 * major areas of interest, and each of these areas is managed by a
 * separate tracking manager. Each of these tracking managers is available
 * through a specific property on this CC3OpenGLESEngine class.
 *
 * To allow this state tracking to be available and consistently tracked 
 * across the complete application, CC3OpenGLESEngine is implemented as
 * a singleton design pattern. You can access the singleton instance by
 * invoking [CC3OpenGLESEngine engine] anywhere in your application code.
 *
 * The two methods open and close define a scope context under which
 * tracking will occur. Once the open method is called, for state tracking
 * to work, ALL OpenGL ES calls that are tracked by the engine MUST be
 * directed through it, until the matching close method is invoked.
 *
 * The open method is invoked by the CC3Scene instance when 3D drawing
 * begins, and the close method is invoked by the CC3Scene instance when
 * 3D drawing ends.
 *
 * If your application requires access to OpenGL ES state or functionality
 * that is not covered by the trackers attached to this engine, you can add
 * that functionality in one of two ways:
 *   -# Create a subclass of one of the attached tracker managers, add the
 *      additional state trackers to that subclass, and replace the existing
 *      tracker manager with your enhanced subclass in the appropriate property
 *      of the CC3OpenGLESEngine singleton.
 *   -# Create a new subclass of CC3OpenGLESStateTrackerManager, add the 
 *      additional state trackers to that subclass, and set your enhanced
 *      CC3OpenGLESStateTrackerManager into the appExtensions property,
 *      which is nil, unless your application sets a tracker manager there.
 */
@interface CC3OpenGLESEngine : CC3OpenGLESStateTracker {
	CCArray* _trackersToOpen;
	CCArray* _trackersToClose;
	CC3OpenGLESPlatform* _platform;
	CC3OpenGLESCapabilities* _capabilities;
	CC3OpenGLESMaterials* _materials;
	CC3OpenGLESTextures* _textures;
	CC3OpenGLESLighting* _lighting;
	CC3OpenGLESMatrices* _matrices;
	CC3OpenGLESVertexArrays* _vertices;
	CC3OpenGLESState* _state;
	CC3OpenGLESFog* _fog;
	CC3OpenGLESHints* _hints;
	CC3OpenGLESShaders* _shaders;
	CC3OpenGLESStateTrackerManager* _appExtensions;
	BOOL _isClosing;
	BOOL _trackerToOpenWasAdded;
}

/**
 * A collection of trackers that are to opened when this instance is opened
 * at the start of each frame render cycle.
 *
 * Initially, most trackers are added to this collection automatically, but
 * any trackers that are set to read their GL state only once are removed
 * once the GL value has been read.
 */
@property(nonatomic, readonly) CCArray* trackersToOpen;

/**
 * A collection of trackers that are to closed when this instance is closed
 * at the end of each frame render cycle.
 *
 * At the beginning of each render cycle, this collection is empty. Trackers
 * that make changes to the GL state are automatically added here when the
 * GL state change is made.
 */
@property(nonatomic, readonly) CCArray* trackersToClose;

/** The state tracking manager that tracks GL platform functionality state.  */
@property(nonatomic, retain) CC3OpenGLESPlatform* platform;

/** The state tracking manager that tracks GL server capabilities state.  */
@property(nonatomic, retain) CC3OpenGLESCapabilities* capabilities;

/** @deprecated Renamed to capabilities.  */
@property(nonatomic, retain) CC3OpenGLESCapabilities* serverCapabilities;

/** @deprecated Renamed to capabilities.  */
@property(nonatomic, retain) CC3OpenGLESCapabilities* clientCapabilities;

/** The state tracking manager that tracks GL materials state.  */
@property(nonatomic, retain) CC3OpenGLESMaterials* materials;

/** The state tracking manager that tracks GL textures state.  */
@property(nonatomic, retain) CC3OpenGLESTextures* textures;

/** The state tracking manager that tracks GL lighting state.  */
@property(nonatomic, retain) CC3OpenGLESLighting* lighting;

/** The state tracking manager that tracks GL vertex array state.  */
@property(nonatomic, retain) CC3OpenGLESVertexArrays* vertices;

/** The state tracking manager that tracks GL matrix state.  */
@property(nonatomic, retain) CC3OpenGLESMatrices* matrices;

/** The state tracking manager that tracks general GL state.  */
@property(nonatomic, retain) CC3OpenGLESState* state;

/** The state tracking manager that tracks GL fog state.  */
@property(nonatomic, retain) CC3OpenGLESFog* fog;

/** The state tracking manager that tracks GL engine hints.  */
@property(nonatomic, retain) CC3OpenGLESHints* hints;

/** The state tracking manager that tracks GLSL engine shaders for OpenGL ES 2.  */
@property(nonatomic, retain) CC3OpenGLESShaders* shaders;

/**
 * Most, but not all GL functionality and state is managed by the trackers attached
 * to this CC3OpenGLESEngine instance. In the case where your application wishes
 * to track GL state that is not already included in the trackers managed by this
 * instance, you can create a subclass of CC3OpenGLESStateTrackerManager and set
 * it in this property.
 *
 * The value of this property is nil, unless an application adds an extension tracker.
 */
@property(nonatomic, retain) CC3OpenGLESStateTrackerManager* appExtensions;

/** Returns the CC3OpenGLESEngine engine singleton. */
+(CC3OpenGLESEngine*) engine;

/**
 * Template method that initializes the tracker managers.
 *
 * Customized subclasses that add additional tracker managers
 * can override this method if necessary.
 *
 * Automatically invoked during instance initialization.
 * The application should not invoke this method.
 */
-(void) initializeTrackers;

@end

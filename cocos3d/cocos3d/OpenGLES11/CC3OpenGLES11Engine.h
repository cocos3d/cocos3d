/*
 * CC3OpenGLES11Engine.h
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
 */

/** @file */	// Doxygen marker

#import "CC3OpenGLES11Platform.h"
#import "CC3OpenGLES11Capabilities.h"
#import "CC3OpenGLES11Materials.h"
#import "CC3OpenGLES11Textures.h"
#import "CC3OpenGLES11Lighting.h"
#import "CC3OpenGLES11Matrices.h"
#import "CC3OpenGLES11VertexArrays.h"
#import "CC3OpenGLES11State.h"
#import "CC3OpenGLES11Fog.h"
#import "CC3OpenGLES11Hints.h"


/**
 * CC3OpenGLES11Engine manages the state of the OpenGL ES 1.1. engine.
 *
 * OpenGL ES 1.1 is designed to be a state machine that operates
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
 * By routing all GL requests through CC3OpenGLES11Engine, this class
 * can keep track of the GL state change requests made to the GL engine,
 * and will only forward such requests to the GL engine if the state
 * really is changing.
 *
 * OpenGL defines many functions and state change options. The overall GL
 * functionality covered by CC3OpenGLES11Engine is broken down into the
 * major areas of interest, and each of these areas is managed by a
 * separate tracking manager. Each of these tracking managers is available
 * through a specific property on this CC3OpenGLES11Engine class.
 *
 * To allow this state tracking to be available and consistently tracked 
 * across the complete application, CC3OpenGLES11Engine is implemented as
 * a singleton design pattern. You can access the singleton instance by
 * invoking [CC3OpenGLES11Engine engine] anywhere in your application code.
 *
 * The two methods open and close define a scope context under which
 * tracking will occur. Once the open method is called, for state tracking
 * to work, ALL OpenGL ES calls that are tracked by the engine MUST be
 * directed through it, until the matching close method is invoked.
 *
 * The open method is invoked by the CC3World instance when 3D drawing
 * begins, and the close method is invoked by the CC3World instance when
 * 3D drawing ends.
 *
 * If your application requires access to OpenGL ES 1.1 state or functionality
 * that is not covered by the trackers attached to this engine, you can add
 * that functionality in one of two ways:
 *   -# Create a subclass of one of the attached tracker managers, add the
 *      additional state trackers to that subclass, and replace the existing
 *      tracker manager with your enhanced subclass in the appropriate property
 *      of the CC3OpenGLES11Engine singleton.
 *   -# Create a new subclass of CC3OpenGLES11StateTrackerManager, add the 
 *      additional state trackers to that subclass, and set your enhanced
 *      CC3OpenGLES11StateTrackerManager into the appExtensions property,
 *      which is nil, unless your application sets a tracker manager there.
 */
@interface CC3OpenGLES11Engine : NSObject {
	CC3OpenGLES11Platform* platform;
	CC3OpenGLES11ServerCapabilities* serverCapabilities;
	CC3OpenGLES11ClientCapabilities* clientCapabilities;
	CC3OpenGLES11Materials* materials;
	CC3OpenGLES11Textures* textures;
	CC3OpenGLES11Lighting* lighting;
	CC3OpenGLES11Matrices* matrices;
	CC3OpenGLES11VertexArrays* vertices;
	CC3OpenGLES11State* state;
	CC3OpenGLES11Fog* fog;
	CC3OpenGLES11Hints* hints;
	CC3OpenGLES11StateTrackerManager* appExtensions;
}

/** The state tracking manager that tracks GL platform functionality state.  */
@property(nonatomic, retain) CC3OpenGLES11Platform* platform;

/** The state tracking manager that tracks GL server capabilities state.  */
@property(nonatomic, retain) CC3OpenGLES11ServerCapabilities* serverCapabilities;

/** The state tracking manager that tracks GL client capabilities state.  */
@property(nonatomic, retain) CC3OpenGLES11ClientCapabilities* clientCapabilities;

/** The state tracking manager that tracks GL materials state.  */
@property(nonatomic, retain) CC3OpenGLES11Materials* materials;

/** The state tracking manager that tracks GL textures state.  */
@property(nonatomic, retain) CC3OpenGLES11Textures* textures;

/** The state tracking manager that tracks GL lighting state.  */
@property(nonatomic, retain) CC3OpenGLES11Lighting* lighting;

/** The state tracking manager that tracks GL vertex array state.  */
@property(nonatomic, retain) CC3OpenGLES11VertexArrays* vertices;

/** The state tracking manager that tracks GL matrix state.  */
@property(nonatomic, retain) CC3OpenGLES11Matrices* matrices;

/** The state tracking manager that tracks general GL state.  */
@property(nonatomic, retain) CC3OpenGLES11State* state;

/** The state tracking manager that tracks GL fog state.  */
@property(nonatomic, retain) CC3OpenGLES11Fog* fog;

/** The state tracking manager that tracks GL engine hints.  */
@property(nonatomic, retain) CC3OpenGLES11Hints* hints;

/**
 * Most, but not all GL functionality and state is managed by the trackers attached
 * to this CC3OpenGLES11Engine instance. In the case where your application wishes
 * to track GL state that is not already included in the trackers managed by this
 * instance, you can create a subclass of CC3OpenGLES11StateTrackerManager and set
 * it in this property.
 *
 * The value of this property is nil, unless an application adds an extension tracker.
 */
@property(nonatomic, retain) CC3OpenGLES11StateTrackerManager* appExtensions;

/** Returns the CC3OpenGLES11Engine engine singleton. */
+(CC3OpenGLES11Engine*) engine;

/**
 * Opens tracking of GL state.
 * 
 * All gl* function calls that make changes to GL engine state made between
 * the invocation of this open method and the corresponding close method
 * MUST be routed through this CC3OpenGLES11Engine singleton.
 */
-(void) open;

/**
 * Closes tracking of GL state.
 * 
 * All gl* function calls that make changes to GL engine state made between
 * the invocation of the open method and this close method MUST be routed
 * through this CC3OpenGLES11Engine singleton.
 */
-(void) close;

@end

/*
 * CC3Backgrounder.h
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

#import "CC3Foundation.h"
#import "CC3OSExtensions.h"


#pragma mark CC3Backgrounder

/**
 * An instance of CC3Backgrounder performs activity on a background thread via an
 * internal operation queue.
 */
@interface CC3Backgrounder : NSObject {
	NSOperationQueue* _operationQueue;
}

/** 
 * The queue on which background operations are run.
 *
 * You should not add operations directly to this queue. Instead, use one of the queuing
 * method provided by this instance, such as runBlock:, because subclasses may expect to
 * be able to perform additional activities around the queuing of the operation.
 *
 * The initial value is a new instance of NSOperationQueue, but this property can be set
 * to some other queue if required.
 */
@property(nonatomic, retain) NSOperationQueue* operationQueue;


#pragma mark Backgrounding tasks

/** 
 * Runs the specified block of code by adding it to the contained operation queue.
 *
 * This method simply adds the block to the queue in the operationQueue property. You should use
 * this method instead of adding the block directly to the operationQueue, because subclasses
 * may override this method to perform additional activities around the queuing of the block.
 */
-(void) runBlock: (void (^)(void))block;


#pragma mark Allocation and initialization

/** Allocates and initializes an autoreleased instance. */
+(id) backgrounder;

@end


#pragma mark CC3GLBackgrounder

/**
 * CC3GLBackgrounder is a type of CC3Backgrounder specialized to perform OpenGL 
 * operations on a background thread.
 *
 * An instance of CC3GLBackgrounder manages a GL context that is distinct from the GL context
 * that is used for rendering, but shares content with the rendering context.
 *
 * No explicit synchronization is provided between the GL context managed by this instance
 * and the GL context used for rendering. For operations such as loading new content on a
 * background thread, this should not cause a problem, as the rendering context will not
 * encounter the new content until it is added to the scene.
 *
 * When using the CC3Node addChild: method to add new nodes (including the corresponding
 * meshes, textures and shaders), to an active scene, the addChild: method will automatically
 * ensure the actual addition to the scene will occur on the rendering thread, to ensure that
 * content is not added during the middle of actual rendering.
 *
 * However, if you use an instance of this class to modify existing GL content that is
 * actively being used by the rendering GL context, you must provide explicit sychronization.
 */
@interface CC3GLBackgrounder : CC3Backgrounder {
	CC3GLContext* _glContext;
}

/** 
 * The GL context used during GL operations on the thread used by this instance.
 *
 * The initial value is set during instance initialization.
 */
@property(nonatomic, retain) CC3GLContext* glContext;


#pragma mark Allocation and initialization

/**
 * Initializes this instance, and sets the value of the glContext property
 * to the specified GL context.
 *
 * In most cases, the specified GL context should share GL content with the
 * GL context used for rendering.
 */
-(id) initWithGLContext: (CC3GLContext*) glContext;

/**
 * Allocates and initializes an autoreleased instance, and sets the value of
 * the glContext property to the specified GL context.
 *
 * In most cases, the specified GL context should share GL content with the
 * GL context used for rendering.
 */
+(id) backgrounderWithGLContext: (CC3GLContext*) glContext;

@end





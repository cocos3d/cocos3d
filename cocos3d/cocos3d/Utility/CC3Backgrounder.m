/*
 * CC3Backgrounder.m
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
 * 
 * See header file CC3Backgrounder.h for full API documentation.
 */

#import "CC3Backgrounder.h"
#import "CC3OpenGL.h"


#pragma mark CC3Backgrounder

@implementation CC3Backgrounder

@synthesize operationQueue=_operationQueue;

-(void) dealloc {
	[_operationQueue release];
	[super dealloc];
}

#pragma mark Backgrounding tasks

-(void) runBlock: (void (^)(void))block { [_operationQueue addOperationWithBlock: block]; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_operationQueue = [NSOperationQueue new];		// retained
	}
	return self;
}

+(id) backgrounder { return [[[self alloc] init] autorelease]; }

@end


#pragma mark CC3GLBackgrounder

@implementation CC3GLBackgrounder : CC3Backgrounder

@synthesize glContext=_glContext;

-(void) dealloc {
	[_glContext release];
	[super dealloc];
}


#pragma mark Backgrounding tasks

/** 
 * Overridden to ensure that the contained GL context is active on the current thread,
 * and to ensure all changes in GL state are flushed to the GL hardware.
 */
-(void) runBlock: (void (^)(void))block {
	[super runBlock: ^{
		[_glContext ensureCurrentContext];
		block();
	}];
}


#pragma mark Allocation and initialization

-(id) initWithGLContext: (CC3GLContext*) glContext {
	if ( (self = [super init]) ) {
		_glContext = [glContext retain];
	}
	return self;
}

+(id) backgrounderWithGLContext: (CC3GLContext*) glContext {
	return [[[self alloc] initWithGLContext: glContext] autorelease];
}

@end

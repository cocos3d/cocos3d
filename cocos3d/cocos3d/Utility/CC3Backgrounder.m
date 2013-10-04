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
#import "CC3CC2Extensions.h"


#pragma mark CC3Backgrounder

@implementation CC3Backgrounder

@synthesize queuePriority=_queuePriority;

-(void) dealloc {
	[super dealloc];
}

#pragma mark Backgrounding tasks

-(void) runBlock: (void (^)(void))block {
	dispatch_async(dispatch_get_global_queue(_queuePriority, 0), block);
}

#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		[self initQueuePriority];
	}
	return self;
}

+(id) backgrounder { return [[[self alloc] init] autorelease]; }

/** Set the appropriate initial queue priority based on the OS version. */
-(void) initQueuePriority {

#if CC3_IOS
	if( CCConfiguration.sharedConfiguration.OSVersion >= kCCiOSVersion_5_0 )
		_queuePriority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
	else
		_queuePriority = DISPATCH_QUEUE_PRIORITY_LOW;
#endif	// CC3_IOS

#if CC3_OSX
	_queuePriority = DISPATCH_QUEUE_PRIORITY_BACKGROUND;
#endif	// CC3_OSX

}

@end


#pragma mark CC3GLBackgrounder

@implementation CC3GLBackgrounder : CC3Backgrounder

@synthesize glContext=_glContext;

-(void) dealloc {
	[_glContext release];
	[super dealloc];
}


#pragma mark Backgrounding tasks

/** Overridden to ensure that the contained GL context is active on the current thread. */
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

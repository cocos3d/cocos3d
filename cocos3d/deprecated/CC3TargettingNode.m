/*
 * CC3TargettingNode.m
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
 * See header file CC3TargettingNode.h for full API documentation.
 */

#import "CC3TargettingNode.h"
#import "CC3Billboard.h"


#pragma mark -
#pragma mark Deprecated CC3TargettingNode

@implementation CC3TargettingNode

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.rotator = [CC3DirectionalRotator rotator];
	}
	return self;
}

@end


#pragma mark -
#pragma mark Deprecated CC3LightTracker

@implementation CC3LightTracker

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		self.isTrackingForBumpMapping = YES;
	}
	return self;
}

@end


#pragma mark -
#pragma mark Deprecated CC3Node extension methods


@interface CC3Rotator (TemplateMethods)
-(void) applyRotation;
@end

@implementation CC3Node (CC3TargettingNode)

-(CC3TargettingNode*) asTargettingNode {
	CC3TargettingNode* tn = [CC3TargettingNode nodeWithName: [NSString stringWithFormat: @"%@-TW", self.name]];
	tn.shouldAutoremoveWhenEmpty = YES;
	[tn addChild: self];
	return tn;
}

-(CC3TargettingNode*) asTracker {
	CC3TargettingNode* tn = [self asTargettingNode];
	tn.shouldTrackTarget = YES;
	return tn;
}

-(CC3TargettingNode*) asCameraTracker {
	CC3TargettingNode* tn = [self asTracker];
	tn.shouldAutotargetCamera = YES;
	return tn;
}

-(CC3TargettingNode*) asLightTracker {
	CC3TargettingNode* tn = [CC3LightTracker nodeWithName: [NSString stringWithFormat: @"%@-LightTrackerWrapper", self.name]];
	tn.shouldAutoremoveWhenEmpty = YES;
	tn.shouldTrackTarget = YES;
	[tn addChild: self];
	return tn;
}

@end

#pragma mark -
#pragma mark CC3Billboard extension

@implementation CC3Billboard (CC3TargettingNode)

-(CC3TargettingNode*) asTargettingNode {
	self.rotation = cc3v(0.0, 180.0, 0.0);
	return [super asTargettingNode];
}

-(CC3TargettingNode*) asLightTracker {
	self.rotation = cc3v(0.0, 180.0, 0.0);
	return [super asLightTracker];
}

@end

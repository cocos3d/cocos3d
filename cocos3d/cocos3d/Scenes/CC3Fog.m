/*
 * CC3Fog.m
 *
 * cocos3d 2.0.0
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
 * See header file CC3Fog.h for full API documentation.
 */

#import "CC3Fog.h"
#import "CC3OpenGLESEngine.h"
#import "CC3CC2Extensions.h"


@implementation CC3Fog

@synthesize isRunning, visible, floatColor, attenuationMode, performanceHint;
@synthesize density, startDistance, endDistance;

-(void) setIsRunning: (BOOL) shouldRun {
	if (!isRunning && shouldRun) [self resumeAllActions];
	if (isRunning && !shouldRun) [self pauseAllActions];
	isRunning = shouldRun;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		isRunning = YES;
		visible = YES;
		floatColor = kCCC4FBlack;
		attenuationMode = GL_EXP2;
		performanceHint = GL_DONT_CARE;
		density = 1.0;
		startDistance = 0.0;
		endDistance = 1.0;
	}
	return self;
}

+(id) fog { return [[[self alloc] init] autorelease]; }

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
-(void) populateFrom: (CC3Fog*) another {
	isRunning = another.isRunning;
	visible = another.visible;
	floatColor = another.floatColor;
	attenuationMode = another.attenuationMode;
	performanceHint = another.performanceHint;
	density = another.density;
	startDistance = another.startDistance;
	endDistance = another.endDistance;
}

-(id) copyWithZone: (NSZone*) zone {
	CC3Fog* aCopy = [[[self class] allocWithZone: zone] init];
	[aCopy populateFrom: self];
	return aCopy;
}


#pragma mark Updating

-(void) update: (ccTime)dt {}


#pragma mark Drawing

-(void) draw {
	if (visible) {
		LogTrace(@"Drawing %@", self);
		CC3OpenGLESEngine* glesEngine = [CC3OpenGLESEngine engine];
		CC3OpenGLESFog* glesFog = glesEngine.fog;

		[glesEngine.capabilities.fog enable];
		glesEngine.hints.fog.value = performanceHint;
		glesFog.mode.value = attenuationMode;
		glesFog.color.value = floatColor;

		switch (attenuationMode) {
			case GL_LINEAR:
				glesFog.start.value = startDistance;
				glesFog.end.value = endDistance;
				break;
			case GL_EXP:
			case GL_EXP2:
				glesFog.density.value = density;
				break;
			default:
				NSAssert2(NO, @"%@ encountered bad attenuation mode (%x)", self, attenuationMode);
				break;
		}
	} else {
		[self unbind];
	}
}

-(void) unbind {
	[[self class] unbind];
}

+(void) unbind {
	LogTrace(@"Disabling fog");
	[[CC3OpenGLESEngine engine].capabilities.fog disable];
}


#pragma mark CCRGBAProtocol support

/** Returns the value of the color property converted from float to integer components. */
-(ccColor3B) color {
	return ccc3(CCColorByteFromFloat(floatColor.r),
				CCColorByteFromFloat(floatColor.g),
				CCColorByteFromFloat(floatColor.b));
}

/** Sets the color property by converting the specified integer color components to floats. */
-(void) setColor: (ccColor3B) aColor {
	floatColor.r = CCColorFloatFromByte(aColor.r);
	floatColor.g = CCColorFloatFromByte(aColor.g);
	floatColor.b = CCColorFloatFromByte(aColor.b);
}

/** Returns the alpha component from the color property converted from a float to an integer. */
-(GLubyte) opacity {
	return CCColorByteFromFloat(floatColor.a);
}

/** Sets the alpha component of the color property by converting the specified integer opacity to a float. */
-(void) setOpacity: (GLubyte) opacity { floatColor.a = CCColorFloatFromByte(opacity); }

-(NSString*) description { return [NSString stringWithFormat: @"%@", [self class]]; }


#pragma mark Actions

-(CCAction*) runAction:(CCAction*) action {
	NSAssert( action != nil, @"Argument must be non-nil");
	[CCDirector.sharedDirector.actionManager addAction: action target: self paused: !isRunning];
	return action;
}

-(CCAction*) runAction: (CCAction*) action withTag: (NSInteger) aTag {
	[self stopActionByTag: aTag];
	action.tag = aTag;
	return [self runAction: action];
}

-(void) stopAllActions { [CCDirector.sharedDirector.actionManager removeAllActionsFromTarget: self]; }

-(void) stopAction: (CCAction*) action { [CCDirector.sharedDirector.actionManager removeAction: action]; }

-(void) stopActionByTag: (NSInteger) aTag {
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	[CCDirector.sharedDirector.actionManager removeActionByTag: aTag target: self];
}

-(CCAction*) getActionByTag: (NSInteger) aTag {
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	return [CCDirector.sharedDirector.actionManager getActionByTag: aTag target: self];
}

-(NSInteger) numberOfRunningActions {
	return [CCDirector.sharedDirector.actionManager numberOfRunningActionsInTarget: self];
}

-(void) resumeAllActions { [CCDirector.sharedDirector.actionManager resumeTarget: self]; }

-(void) pauseAllActions { [CCDirector.sharedDirector.actionManager pauseTarget: self]; }

@end

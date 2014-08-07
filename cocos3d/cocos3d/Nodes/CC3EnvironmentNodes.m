/*
 * CC3EnvironmentNodes.m
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
 * See header file CC3EnvironmentNodes.h for full API documentation.
 */

#import "CC3EnvironmentNodes.h"


#pragma mark -
#pragma mark CC3EnvironmentNode

@implementation CC3EnvironmentNode

@synthesize texture=_texture;

-(void) dealloc {
	[_texture release];
	[super dealloc];
}

-(BOOL) isLightProbe { return YES; }


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_texture = nil;
	}
	return self;
}

-(id) initWithName: (NSString*) name withTexture: (CC3Texture*) texture {
	if ( (self = [super initWithName: name]) ) {
		self.texture = texture;
	}
	return self;
}

+(id) nodeWithName: (NSString*) name withTexture: (CC3Texture*) texture {
	return [[[self alloc] initWithName: name withTexture: texture] autorelease];
}

-(id) initWithTexture: (CC3Texture*) texture {
	return [self initWithName: texture.name withTexture: texture];
}

+(id) nodeWithTexture: (CC3Texture*) texture {
	return [[((CC3EnvironmentNode*)[self alloc]) initWithTexture: texture] autorelease];
}

@end


#pragma mark -
#pragma mark CC3LightProbe

@implementation CC3LightProbe

-(BOOL) isLightProbe { return YES; }

-(ccColor4F) diffuseColor { return _diffuseColor; }

-(void) setDiffuseColor:(ccColor4F) aColor {
	_diffuseColor = aColor;
	[super setDiffuseColor: aColor];	// pass along to any descendant
}


#pragma mark Allocation and initialization

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		_diffuseColor = kCCC4FWhite;
	}
	return self;
}

@end


#pragma mark -
#pragma mark CC3Node extension for environment nodes


@implementation CC3Node (EnvironmentNodes)

-(BOOL) isLightProbe { return NO; }

@end

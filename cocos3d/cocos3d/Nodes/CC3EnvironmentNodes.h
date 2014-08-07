/*
 * CC3EnvironmentNodes.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Node.h"
#import "CC3Texture.h"


#pragma mark -
#pragma mark CC3EnvironmentNode

/**
 * CC3EnvironmentNode is an abstract superclass of a family of node classes that hold a 
 * texture that can be used as an environment map by other nodes.
 *
 * Different subclasses provide specialized types of environment maps, such as light probes
 * and reflection surfaces.
 *
 * Environment maps require shaders to interpret the contents of the texture, and are 
 * therefore not compatible with OpenGL ES 1.1, and instances of CC3EnvironmentNode will
 * have no effect if included in a scene while running under OpenGL ES 1.1.
 */
@interface CC3EnvironmentNode : CC3Node {
	CC3Texture* _texture;
}

/** 
 * The texture that provides the environment map.
 *
 * Typically, this texture is a cube-map, to provide a map in all six directions.
 */
@property(nonatomic, retain) CC3Texture* texture;


#pragma mark Allocation and initialization

/** Initializes this instance with the specified name and environment texture. */
-(id) initWithName: (NSString*) name withTexture: (CC3Texture*) texture;

/** Allocates and initializes an autoreleased instance with the specified name and environment texture. */
+(id) nodeWithName: (NSString*) name withTexture: (CC3Texture*) texture;

/**
 * Initializes this instance with the specified texture.
 *
 * The name of this instance will be set to that of the specified texture.
 */
-(id) initWithTexture: (CC3Texture*) texture;

/**
 * Allocates and initializes an autoreleased instance with the specified texture.
 *
 * The name of the returned instance will be set to that of the specified texture.
 */
+(id) nodeWithTexture: (CC3Texture*) texture;

@end


#pragma mark -
#pragma mark CC3LightProbe

/**
 * CC3LightProbe is a type of light that uses a texture to define the
 * light intensity in any direction at the light's location.
 */
@interface CC3LightProbe : CC3EnvironmentNode {
	ccColor4F _diffuseColor;
}

/**
 * The diffuse color of this light.
 *
 * The initial value of this propery is kCCC4FWhite.
 */
@property(nonatomic, assign) ccColor4F diffuseColor;

@end


#pragma mark -
#pragma mark CC3Node extension for environment nodes


@interface CC3Node (EnvironmentNodes)

/**
 * Returns whether this node is a light probe.
 *
 * This implementation returns NO. Subclasses that are light probes will override to return YES.
 */
@property(nonatomic, readonly) BOOL isLightProbe;

@end

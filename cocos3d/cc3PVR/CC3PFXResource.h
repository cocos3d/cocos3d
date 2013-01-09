/*
 * CC3PFXResource.h
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


#import "CC3Resource.h"
#import "CC3PVRFoundation.h"
#import "CC3Material.h"
#import "CC3GLProgram.h"


/**
 * CC3PFXResource is a CC3Resource that wraps a PVR PFX data structure loaded from a file.
 * It handles loading object data from PFX files, and creating content from that data.
 * This class is the cornerstone of PFX file management.
 */
@interface CC3PFXResource : CC3Resource {
	NSMutableDictionary* _texturesByName;
	NSMutableDictionary* _effectsByName;
}

/** Populates the specfied material from the PFX effect with the specified name. */
-(void) populateMaterial: (CC3Material*) material fromEffectNamed: (NSString*) effectName;

/**
 * Populates the specfied material from the PFX effect with the specified name, found in the
 * cached CC3PFXResource with the specifed name. Raises an assertion error if a PFX resource
 * with the specified name cannot be found in the cache.
 */
+(void) populateMaterial: (CC3Material*) material
		 fromEffectNamed: (NSString*) effectName
	  inPFXResourceNamed: (NSString*) rezName;

/**
 * Populates the specfied material from the PFX effect with the specified name, found in the
 * CC3PFXResource loaded from the specfied file. Raises an assertion error if the PFX resource
 * file is not already in the resource cache and could not be loaded.
 */
+(void) populateMaterial: (CC3Material*) material
		 fromEffectNamed: (NSString*) effectName
	   inPFXResourceFile: (NSString*) aFilePath;

@end


#pragma mark -
#pragma mark CC3PFXEffect

/**
 * CC3PFXEffect represents a single effect within a PFX resource file. It combines the shader
 * code referenced by the effect into a CC3GLProgram, and the textures used by that program.
 */
@interface CC3PFXEffect : NSObject {
	NSString* _name;
	CC3GLProgram* _glProgram;
	CCArray* _textures;
}

/** Returns the name of this effect. */
@property(nonatomic, retain, readonly) NSString* name;

/** The GL program used to render this effect. */
@property(nonatomic, retain, readonly) CC3GLProgram* glProgram;

/** The textures used in this effect. */
@property(nonatomic, retain, readonly) CCArray* textures;

/**
 * Initializes this instance from the specified SPVRTPFXParserEffect C++ class, retrieved
 * from the specified CPVRTPFXParser C++ class as loaded from the specfied PFX resource.
 */
-(id) initFromSPVRTPFXParserEffect: (PFXClassPtr) pSPVRTPFXParserEffect
					 fromPFXParser: (PFXClassPtr) pCPVRTPFXParser
					 inPFXResource: (CC3PFXResource*) pfxRez;

/** Populates the specfied material with the GL program and textures. */
-(void) populateMaterial: (CC3Material*) material;

@end


#pragma mark -
#pragma mark CC3PFXEffectTexture

/** CC3PFXEffectTexture is a simple object that links a texture with a particular texture unit. */
@interface CC3PFXEffectTexture : NSObject {
	CC3Texture* _texture;
	NSUInteger _textureUnitIndex;
}

/** The texture */
@property(nonatomic, retain) CC3Texture* texture;

/** The index of the texture unit to which the texture should be applied. */
@property(nonatomic, assign) NSUInteger textureUnitIndex;

@end


/*
 * CC3Texture.m
 *
 * cocos3d 0.5.4
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3Texture.h for full API documentation.
 */

#import "CC3Texture.h"
#import "CCTextureCache.h"
#import "CC3OpenGLES11Engine.h"

@interface CC3Identifiable (TemplateMethods)
-(void) populateFrom: (CC3Identifiable*) another;
@end

@interface CC3Texture (TemplateMethods)
-(void) updateTexture2DWithParameters;
-(void) bindGL;
@end


@implementation CC3Texture

@synthesize texture, textureParameters, textureChannel;

-(void) dealloc {
	[texture release];
	[super dealloc];
}

-(void) setTexture:(CCTexture2D *) tex {
	id oldTex = texture;
	texture = [tex retain];
	[oldTex release];
	[self updateTexture2DWithParameters];
}

-(void) setTextureParameters:(ccTexParams) texParams {
	textureParameters = texParams;
	[self updateTexture2DWithParameters];
}

-(ccTex2F) mapSize {
	ccTex2F st;
	if (texture) {
		st.u = texture.maxS;
		st.v = texture.maxT;
	} else {
		st.u = 0.0f;
		st.v = 0.0f;
	}
	return st;
}

-(BOOL) hasPremultipliedAlpha {
	return (texture && texture.hasPremultipliedAlpha);
}

/** Updates the contained CCTexture2D instance with the specified parameters. */
-(void) updateTexture2DWithParameters {
	[texture setTexParameters: &textureParameters];
}

#pragma mark Allocation and Initialization

-(id) initFromFile: (NSString*) aFileName {
	return [self initWithName: aFileName fromFile: aFileName];
}

+(id) textureFromFile: (NSString*) aFileName {
	return [[[self alloc] initFromFile: aFileName] autorelease];
}

-(id) initWithTag: (GLuint) aTag fromFile: (NSString*) aFileName {
	return [self initWithTag: aTag withName: aFileName fromFile: aFileName];
}

+(id) textureWithTag: (GLuint) aTag fromFile: (NSString*) aFileName {
	return [[[self alloc] initWithTag: aTag fromFile: aFileName] autorelease];
}

-(id) initWithName: (NSString*) aName fromFile: (NSString*) aFileName {
	return [self initWithTag: [self nextTag] withName: aName fromFile: aFileName];
}

+(id) textureWithName: (NSString*) aName fromFile: (NSString*) aFileName {
	return [[[self alloc] initWithName: aName fromFile: aFileName] autorelease];
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFileName {
	if ( (self = [self initWithTag: aTag withName: aName]) ) {
		if ( ![self loadTextureFile: aFileName] ) {
			[self release];
			return nil;
		}
	}
	return self;
}

+(id) textureWithTag: (GLuint) aTag withName: (NSString*) aName fromFile: (NSString*) aFileName {
	return [[[self alloc] initWithTag: aTag withName: aName fromFile: aFileName] autorelease];
}

-(id) initWithTag: (GLuint) aTag withName: (NSString*) aName {
	if ( (self = [super initWithTag: aTag withName: aName]) ) {
		textureChannel = 0;
		textureParameters = kCC3DefaultTextureParameters;
	}
	return self;
}

-(BOOL) loadTextureFile: (NSString*) aFileName {
	self.texture = [[CCTextureCache sharedTextureCache] addImage: aFileName];
	if (texture) {
		LogTrace(@"%@ loaded texture from file %@", self, aFileName);
		return YES;
	} else {
		LogError(@"%@ could not load texture from file %@", self, aFileName);
		return NO;
	}
}

// Template method that populates this instance from the specified other instance.
// This method is invoked automatically during object copying via the copyWithZone: method.
// The 2D texture is not copied, but instead retained by reference, and shared between instances.
-(void) populateFrom: (CC3Texture*) another {
	[super populateFrom: another];
	
	[texture release];
	texture = [another.texture retain];				// retained

	textureParameters = another.textureParameters;
	textureChannel = another.textureChannel;
}


#pragma mark Tag allocation

// Class variable tracking the most recent tag value assigned for CC3Textures.
// This class variable is automatically incremented whenever the method nextTag is called.
static GLuint lastAssignedTextureTag;

-(GLuint) nextTag {
	return ++lastAssignedTextureTag;
}

+(void) resetTagAllocation {
	lastAssignedTextureTag = 0;
}


#pragma mark Drawing

-(void) draw {
	[self bindGL];
}

/**
 * If the texture property is not nil, binds this texture to the  GL engine, in the
 * texture channel indicated by the textureChannel property. If the texture property
 * is nil, invokes the unbind method to disable texture handling in the GL engine.
 */
-(void) bindGL {
	if (texture) {
		[[CC3OpenGLES11Engine engine].serverCapabilities.texture2D enable];
		CC3OpenGLES11Textures* gles11Textures = [CC3OpenGLES11Engine engine].textures;
		gles11Textures.activeTexture.value = textureChannel;
		gles11Textures.clientActiveTexture.value = textureChannel;
		gles11Textures.textureBinding.value = texture.name;
	} else {
		[self unbind];
	}
}

-(void) unbind {
	[[self class] unbind];
}

+(void) unbind {
	[[CC3OpenGLES11Engine engine].serverCapabilities.texture2D disable];
}

@end

/*
 * CC3Texture.m
 *
 * cocos3d 0.6.0-sp
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
-(void) drawMainWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) drawOverlaysWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor;
-(void) bindToGLTextureUnit: (CC3OpenGLES11TextureUnit*) gles11TexUnit
				withVisitor: (CC3NodeDrawingVisitor*) visitor;
@end


@implementation CC3Texture

@synthesize texture, textureUnit, textureParameters;

-(void) dealloc {
	[texture release];
	[textureUnit release];
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

-(CC3Vector) lightDirection {
	return textureUnit ? textureUnit.lightDirection : kCC3VectorZero;
}

-(void) setLightDirection: (CC3Vector) aDirection {
	textureUnit.lightDirection = aDirection;
}

-(BOOL) isBumpMap {
	return textureUnit && textureUnit.isBumpMap;
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
		textureParameters = kCC3DefaultTextureParameters;
		texture = nil;
		textureUnit = nil;
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
-(void) populateFrom: (CC3Texture*) another {
	[super populateFrom: another];
	
	// The 2D texture is not copied, but instead retained by reference, and shared between instances.
	[texture release];
	texture = [another.texture retain];				// retained

	[textureUnit release];
	textureUnit = [another.textureUnit copy];	// retained

	textureParameters = another.textureParameters;
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

-(void) drawWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (texture) {
		[self bindGLWithVisitor: visitor];
		visitor.textureUnit += 1;
	}
}

-(void) bindGLWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	CC3OpenGLES11TextureUnit* gles11TexUnit = [[CC3OpenGLES11Engine engine].textures textureUnitAt: visitor.textureUnit];
	[gles11TexUnit.texture2D enable];
	gles11TexUnit.textureBinding.value = texture.name;
	[self bindToGLTextureUnit: gles11TexUnit withVisitor: visitor];
	
	LogTrace(@"%@ bound to %@", self, gles11TexUnit);
}

/**
 * If the texture property is not nil, binds this texture to the  GL engine, in the
 * specified texture unit. If the texture property is nil, invokes the bindDefaultTo:
 * method to disable texture handling in the GL engine.
 */
-(void) bindToGLTextureUnit: (CC3OpenGLES11TextureUnit*) gles11TexUnit
				withVisitor: (CC3NodeDrawingVisitor*) visitor {
	if (textureUnit) {
		[textureUnit bindTo: gles11TexUnit withVisitor: visitor];
	} else {
		[CC3TextureUnit bindDefaultTo: gles11TexUnit];
	}
}

+(void) unbind: (GLuint) texUnit {
	[[[CC3OpenGLES11Engine engine].textures textureUnitAt: texUnit].texture2D disable];
}

+(void) unbindRemainingFrom: (GLuint)texUnit {
	GLuint maxTexUnits = [CC3OpenGLES11Engine engine].textures.textureUnitCount;
	for (int tu = texUnit; tu < maxTexUnits; tu++) {
		[self unbind: tu];
	}
}

+(void) unbind {
	[self unbindRemainingFrom: 0];
}

@end

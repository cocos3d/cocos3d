/*
 * CC3PFXResource.mm
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
 * See header file CC3PFXResource.h for full API documentation.
 */

extern "C" {
	#import "CC3Foundation.h"	// extern must be first, since foundation also imported via other imports
}
#import "CC3PFXResource.h"
#import "CC3PVRTPFXParser.h"


@interface CC3PFXResource (TemplateMethods)

/** The underlying pvrtPFXParser property, cast to the correct CPVRTModelPOD C++ class. */
@property(nonatomic, readonly)  CPVRTPFXParser* pvrtPFXParserImpl;
@end

@implementation CC3PFXResource

-(void) dealloc {
	if (_pvrtPFXParser) delete self.pvrtPFXParserImpl;
	_pvrtPFXParser = NULL;
	[super dealloc];
}

-(CPVRTPFXParser*) pvrtPFXParserImpl { return (CPVRTPFXParser*)_pvrtPFXParser; }

-(NSUInteger) effectCount { return _pvrtPFXParser ? self.pvrtPFXParserImpl->GetNumberEffects() : 0; }

-(NSUInteger) vertexShaderCount { return _pvrtPFXParser ? self.pvrtPFXParserImpl->GetNumberVertexShaders() : 0; }

-(NSUInteger) fragmentShaderCount { return _pvrtPFXParser ? self.pvrtPFXParserImpl->GetNumberFragmentShaders() : 0; }

-(NSUInteger) textureCount { return _pvrtPFXParser ? self.pvrtPFXParserImpl->GetNumberTextures() : 0; }

-(NSUInteger) renderPassCount { return _pvrtPFXParser ? self.pvrtPFXParserImpl->GetNumberRenderPasses() : 0; }


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {
		_pvrtPFXParser = new CPVRTPFXParser();
	}
	return self;
}

-(BOOL) processFile: (NSString*) anAbsoluteFilePath {
	CPVRTString	error;
	_wasLoaded = (self.pvrtPFXParserImpl->ParseFromFile([anAbsoluteFilePath cStringUsingEncoding: NSUTF8StringEncoding], &error) == PVR_SUCCESS);
	NSAssert3(_wasLoaded, @"%@ could not load PFX file %@ because %@",
			  self, anAbsoluteFilePath, [NSString stringWithUTF8String: error.c_str()]);
	if (_wasLoaded) [self logContents];
	return _wasLoaded;
}

-(void) logContents {
#if LOGGING_REZLOAD
	NSUInteger count;
	CPVRTPFXParser* parser = self.pvrtPFXParserImpl;
	
	count = self.effectCount;
	for (NSUInteger i = 0; i < count; i++) {
		const SPVRTPFXParserEffect& effect = parser->GetEffect(i);
		LogRez(@"Describing effect %@", NSStringFromSPVRTPFXParserEffect((SPVRTPFXParserEffect*)&effect));
	}

	count = self.vertexShaderCount;
	for (NSUInteger i = 0; i < count; i++) {
		const SPVRTPFXParserShader& shader = parser->GetVertexShader(i);
		LogRez(@"Describing vertex shader %@", NSStringFromSPVRTPFXParserShader((SPVRTPFXParserShader*)&shader));
	}
	
	count = self.fragmentShaderCount;
	for (NSUInteger i = 0; i < count; i++) {
		const SPVRTPFXParserShader& shader = parser->GetFragmentShader(i);
		LogRez(@"Describing fragment shader %@", NSStringFromSPVRTPFXParserShader((SPVRTPFXParserShader*)&shader));
	}
	
	count = self.textureCount;
	for (NSUInteger i = 0; i < count; i++) {
		const SPVRTPFXParserTexture* tex = parser->GetTexture(i);
		LogRez(@"Describing texture %@", NSStringFromSPVRTPFXParserTexture((SPVRTPFXParserTexture*)tex));
	}
	
	count = self.renderPassCount;
	for (NSUInteger i = 0; i < count; i++) {
		const SPVRTPFXRenderPass rendPass = parser->GetRenderPass(i);
		LogRez(@"Describing render pass %@", NSStringFromSPVRTPFXRenderPass((SPVRTPFXRenderPass*)&rendPass));
	}

#endif
}

-(NSString*) fullDescription {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 200];
	[desc appendFormat: @"%@", self];
	[desc appendFormat: @" containing %u effects", self.effectCount];
	[desc appendFormat: @", %u vertex shaders", self.vertexShaderCount];
	[desc appendFormat: @", %u fragment shaders", self.fragmentShaderCount];
	[desc appendFormat: @", %u textures", self.textureCount];
	[desc appendFormat: @", %u render passes", self.renderPassCount];
	return desc;
}


@end

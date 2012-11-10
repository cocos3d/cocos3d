/*
 * CC3OpenGLES11Capabilities.m
 *
 * cocos3d 0.7.2
 * Author: Bill Hollings
 * Copyright (c) 2010-2012 The Brenwill Workshop Ltd. All rights reserved.
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
 * See header file CC3OpenGLES11Capabilities.h for full API documentation.
 */

#import "CC3OpenGLES11Capabilities.h"
#import "CC3OpenGLES11Engine.h"


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerServerCapability

@implementation CC3OpenGLES11StateTrackerServerCapability

-(void) setGLValue {
	if (value) {
		glEnable(name);
	} else {
		glDisable(name);
	}
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerClientCapability

@implementation CC3OpenGLES11StateTrackerClientCapability

-(void) setGLValue {
	if (value) {
		glEnableClientState(name);
	} else {
		glDisableClientState(name);
	}
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11ServerCapabilities

@implementation CC3OpenGLES11ServerCapabilities

@synthesize alphaTest;
@synthesize blend;
@synthesize clipPlanes;
@synthesize colorLogicOp;
@synthesize colorMaterial;
@synthesize cullFace;
@synthesize depthTest;
@synthesize dither;
@synthesize fog;
@synthesize lighting;
@synthesize lineSmooth;
@synthesize matrixPalette;
@synthesize multisample;
@synthesize normalize;
@synthesize pointSmooth;
@synthesize pointSprites;
@synthesize polygonOffsetFill;
@synthesize rescaleNormal;
@synthesize sampleAlphaToCoverage;
@synthesize sampleAlphaToOne;
@synthesize sampleCoverage;
@synthesize scissorTest;
@synthesize stencilTest;

-(void) dealloc {
	[alphaTest release];
	[blend release];
	[clipPlanes release];
	[colorLogicOp release];
	[colorMaterial release];
	[cullFace release];
	[depthTest release];
	[dither release];
	[fog release];
	[lighting release];
	[lineSmooth release];
	[matrixPalette release];
	[multisample release];
	[normalize release];
	[pointSmooth release];
	[pointSprites release];
	[polygonOffsetFill release];
	[rescaleNormal release];
	[sampleAlphaToCoverage release];
	[sampleAlphaToOne release];
	[sampleCoverage release];
	[scissorTest release];
	[stencilTest release];
	[super dealloc];
}

-(CC3OpenGLES11StateTrackerServerCapability*) clipPlaneAt: (GLint) cpIndx {
	return [clipPlanes objectAtIndex: cpIndx];
}

-(void) initializeTrackers {
	self.alphaTest = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		 forState: GL_ALPHA_TEST];
	self.blend = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																	 forState: GL_BLEND];
	self.clipPlanes = [CCArray array];
	
	GLint platformMaxClipPlanes = self.engine.platform.maxClipPlanes.value;
	for (int i = 0; i < platformMaxClipPlanes; i++) {
		[clipPlanes addObject: [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																				   forState: GL_CLIP_PLANE0 + i]];
	}

	self.colorLogicOp = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																			forState: GL_COLOR_LOGIC_OP];
	self.colorMaterial = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																			 forState: GL_COLOR_MATERIAL];
	self.cullFace = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		forState: GL_CULL_FACE];
	self.depthTest = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		 forState: GL_DEPTH_TEST];
	self.dither = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																	  forState: GL_DITHER];
	self.fog = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																   forState: GL_FOG];
	self.lighting = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		forState: GL_LIGHTING];
	self.lineSmooth = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		  forState: GL_LINE_SMOOTH];

	// Crashes when attempting to read the GL value.
	self.matrixPalette = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																			 forState: GL_MATRIX_PALETTE_OES
															 andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.matrixPalette.originalValue = NO;		// Assume starts out disabled

	self.multisample = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		   forState: GL_MULTISAMPLE];
	self.normalize = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		 forState: GL_NORMALIZE];
	self.pointSmooth = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		   forState: GL_POINT_SMOOTH];

	// Illegal GL enum when trying to read GL value.
	self.pointSprites = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																			forState: GL_POINT_SPRITE_OES
															andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.pointSprites.originalValue = NO;		// Assume starts out disabled

	self.polygonOffsetFill = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																				 forState: GL_POLYGON_OFFSET_FILL];
	self.rescaleNormal = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																			 forState: GL_RESCALE_NORMAL];
	self.sampleAlphaToCoverage = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																					 forState: GL_SAMPLE_ALPHA_TO_COVERAGE];
	self.sampleAlphaToOne = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																				forState: GL_SAMPLE_ALPHA_TO_ONE];
	self.sampleCoverage = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																			  forState: GL_SAMPLE_COVERAGE];
	self.scissorTest = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		   forState: GL_SCISSOR_TEST];
	self.stencilTest = [CC3OpenGLES11StateTrackerServerCapability trackerWithParent: self
																		   forState: GL_STENCIL_TEST];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 1000];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", alphaTest];
	[desc appendFormat: @"\n    %@ ", blend];
	for (id t in clipPlanes) {
		[desc appendFormat: @"\n    %@ ", t];
	}
	[desc appendFormat: @"\n    %@ ", colorLogicOp];
	[desc appendFormat: @"\n    %@ ", colorMaterial];
	[desc appendFormat: @"\n    %@ ", cullFace];
	[desc appendFormat: @"\n    %@ ", depthTest];
	[desc appendFormat: @"\n    %@ ", dither];
	[desc appendFormat: @"\n    %@ ", fog];
	[desc appendFormat: @"\n    %@ ", lighting];
	[desc appendFormat: @"\n    %@ ", lineSmooth];
	[desc appendFormat: @"\n    %@ ", matrixPalette];
	[desc appendFormat: @"\n    %@ ", multisample];
	[desc appendFormat: @"\n    %@ ", normalize];
	[desc appendFormat: @"\n    %@ ", pointSmooth];
	[desc appendFormat: @"\n    %@ ", pointSprites];
	[desc appendFormat: @"\n    %@ ", polygonOffsetFill];
	[desc appendFormat: @"\n    %@ ", rescaleNormal];
	[desc appendFormat: @"\n    %@ ", sampleAlphaToCoverage];
	[desc appendFormat: @"\n    %@ ", sampleAlphaToOne];
	[desc appendFormat: @"\n    %@ ", sampleCoverage];
	[desc appendFormat: @"\n    %@ ", scissorTest];
	[desc appendFormat: @"\n    %@ ", stencilTest];
	return desc;
}

@end


#pragma mark -
#pragma mark CC3OpenGLES11ClientCapabilities

@implementation CC3OpenGLES11ClientCapabilities

@synthesize colorArray;
@synthesize matrixIndexArray;
@synthesize normalArray;
@synthesize pointSizeArray;
@synthesize vertexArray;
@synthesize weightArray;

-(void) dealloc {
	[colorArray release];
	[matrixIndexArray release];
	[normalArray release];
	[pointSizeArray release];
	[vertexArray release];
	[weightArray release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.colorArray = [CC3OpenGLES11StateTrackerClientCapability trackerWithParent: self
																		  forState: GL_COLOR_ARRAY];

	// Illegal GL enum when trying to read value of GL_MATRIX_INDEX_ARRAY_OES.
	self.matrixIndexArray = [CC3OpenGLES11StateTrackerClientCapability trackerWithParent: self
																				forState: GL_MATRIX_INDEX_ARRAY_OES
																andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.matrixIndexArray.originalValue = NO;		// Assume starts out disabled

	self.normalArray = [CC3OpenGLES11StateTrackerClientCapability trackerWithParent: self
																		   forState: GL_NORMAL_ARRAY];
	self.pointSizeArray = [CC3OpenGLES11StateTrackerClientCapability trackerWithParent: self
																			  forState: GL_POINT_SIZE_ARRAY_OES];
	self.vertexArray = [CC3OpenGLES11StateTrackerClientCapability trackerWithParent: self
																		   forState: GL_VERTEX_ARRAY];

	// Crashes OpenGL Analyzer when attempting to read the GL value of GL_WEIGHT_ARRAY_OES
	self.weightArray = [CC3OpenGLES11StateTrackerClientCapability trackerWithParent: self
																		   forState: GL_WEIGHT_ARRAY_OES
														   andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 300];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", colorArray];
	[desc appendFormat: @"\n    %@ ", matrixIndexArray];
	[desc appendFormat: @"\n    %@ ", normalArray];
	[desc appendFormat: @"\n    %@ ", pointSizeArray];
	[desc appendFormat: @"\n    %@ ", vertexArray];
	[desc appendFormat: @"\n    %@ ", weightArray];
	return desc;
}

@end

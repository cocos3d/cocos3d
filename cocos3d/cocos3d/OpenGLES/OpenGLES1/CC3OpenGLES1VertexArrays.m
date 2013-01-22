/*
 * CC3OpenGLES1VertexArrays.m
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
 * See header file CC3OpenGLESVertexArrays.h for full API documentation.
 */

#import "CC3OpenGLES1VertexArrays.h"
#import "CC3OpenGLESEngine.h"
#import "CC3OpenGLESTextures.h"

#if CC3_OGLES_1

#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexLocationsPointer

@implementation CC3OpenGLES1StateTrackerVertexLocationsPointer

-(void) initializeTrackers {
	self.capability = [CC3OpenGLES1StateTrackerClientCapability trackerWithParent: self
																		 forState: GL_VERTEX_ARRAY];
	self.elementSize = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																forState: GL_VERTEX_ARRAY_SIZE];
	self.elementType = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_VERTEX_ARRAY_TYPE];
	self.vertexStride = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																 forState: GL_VERTEX_ARRAY_STRIDE];
	self.vertices = [CC3OpenGLESStateTrackerPointer trackerWithParent: self];

	self.shouldNormalize = [CC3OpenGLESStateTrackerBoolean trackerWithParent: self];	// no-op tracker
}

-(void) setGLValues { glVertexPointer(_elementSize.value, _elementType.value, _vertexStride.value, _vertices.value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexNormalsPointer

@implementation CC3OpenGLES1StateTrackerVertexNormalsPointer

-(void) initializeTrackers {
	self.capability = [CC3OpenGLES1StateTrackerClientCapability trackerWithParent: self
																		 forState: GL_NORMAL_ARRAY];
	self.elementType = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_NORMAL_ARRAY_TYPE];
	self.vertexStride = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																 forState: GL_NORMAL_ARRAY_STRIDE];
	self.vertices = [CC3OpenGLESStateTrackerPointer trackerWithParent: self];

	self.elementSize = [CC3OpenGLESStateTrackerInteger trackerWithParent: self];		// no-op tracker
	self.shouldNormalize = [CC3OpenGLESStateTrackerBoolean trackerWithParent: self];	// no-op tracker
}

-(void) setGLValues { glNormalPointer(_elementType.value, _vertexStride.value, _vertices.value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexColorsPointer

@implementation CC3OpenGLES1StateTrackerVertexColorsPointer

-(void) initializeTrackers {
	self.capability = [CC3OpenGLES1StateTrackerClientCapability trackerWithParent: self
																		 forState: GL_COLOR_ARRAY];
	self.elementSize = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																forState: GL_COLOR_ARRAY_SIZE];
	self.elementType = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_COLOR_ARRAY_TYPE];
	self.vertexStride = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																 forState: GL_COLOR_ARRAY_STRIDE];
	self.vertices = [CC3OpenGLESStateTrackerPointer trackerWithParent: self];
	
	self.shouldNormalize = [CC3OpenGLESStateTrackerBoolean trackerWithParent: self];	// no-op tracker
}

-(void) setGLValues { glColorPointer(_elementSize.value, _elementType.value, _vertexStride.value, _vertices.value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexPointSizesPointer

@implementation CC3OpenGLES1StateTrackerVertexPointSizesPointer

-(void) initializeTrackers {
	self.capability = [CC3OpenGLES1StateTrackerClientCapability trackerWithParent: self
																		 forState: GL_POINT_SIZE_ARRAY_OES];
	self.elementType = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_POINT_SIZE_ARRAY_TYPE_OES];
	self.vertexStride = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																 forState: GL_POINT_SIZE_ARRAY_STRIDE_OES];
	self.vertices = [CC3OpenGLESStateTrackerPointer trackerWithParent: self];
	
	self.elementSize = [CC3OpenGLESStateTrackerInteger trackerWithParent: self];		// no-op tracker
	self.shouldNormalize = [CC3OpenGLESStateTrackerBoolean trackerWithParent: self];	// no-op tracker
}

-(void) setGLValues { glPointSizePointerOES(_elementType.value, _vertexStride.value, _vertices.value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexWeightsPointer

@implementation CC3OpenGLES1StateTrackerVertexWeightsPointer

-(void) initializeTrackers {
	// Crashes OpenGL Analyzer when attempting to read the GL value of GL_WEIGHT_ARRAY_OES
	self.capability = [CC3OpenGLES1StateTrackerClientCapability trackerWithParent: self
																		 forState: GL_WEIGHT_ARRAY_OES
														 andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.capability.originalValue = NO;		// Assume starts out disabled

	self.elementSize = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																forState: GL_WEIGHT_ARRAY_SIZE_OES];
	self.elementType = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_WEIGHT_ARRAY_TYPE_OES];
	self.vertexStride = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																 forState: GL_WEIGHT_ARRAY_STRIDE_OES];
	self.vertices = [CC3OpenGLESStateTrackerPointer trackerWithParent: self];
	
	self.shouldNormalize = [CC3OpenGLESStateTrackerBoolean trackerWithParent: self];	// no-op tracker
}

-(void) setGLValues { glWeightPointerOES(_elementSize.value, _elementType.value, _vertexStride.value, _vertices.value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1StateTrackerVertexMatrixIndicesPointer

@implementation CC3OpenGLES1StateTrackerVertexMatrixIndicesPointer

-(void) initializeTrackers {
	// Illegal GL enum when trying to read value of GL_MATRIX_INDEX_ARRAY_OES.
	self.capability = [CC3OpenGLES1StateTrackerClientCapability trackerWithParent: self
																		 forState: GL_MATRIX_INDEX_ARRAY_OES
														 andOriginalValueHandling: kCC3GLESStateOriginalValueRestore];
	self.capability.originalValue = NO;		// Assume starts out disabled
	
	self.elementSize = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																forState: GL_MATRIX_INDEX_ARRAY_SIZE_OES];
	self.elementType = [CC3OpenGLESStateTrackerEnumeration trackerWithParent: self
																	forState: GL_MATRIX_INDEX_ARRAY_TYPE_OES];
	self.vertexStride = [CC3OpenGLESStateTrackerInteger trackerWithParent: self
																 forState: GL_MATRIX_INDEX_ARRAY_STRIDE_OES];
	self.vertices = [CC3OpenGLESStateTrackerPointer trackerWithParent: self];
	
	self.shouldNormalize = [CC3OpenGLESStateTrackerBoolean trackerWithParent: self];	// no-op tracker
}

-(void) setGLValues { glMatrixIndexPointerOES(_elementSize.value, _elementType.value, _vertexStride.value, _vertices.value); }

@end


#pragma mark -
#pragma mark CC3OpenGLES1VertexArrays

@implementation CC3OpenGLES1VertexArrays

@synthesize locations=_locations;
@synthesize matrixIndices=_matrixIndices;
@synthesize normals=_normals;
@synthesize colors=_colors;
@synthesize pointSizes=_pointSizes;
@synthesize weights=_weights;

-(void) dealloc {
	[_locations release];
	[_matrixIndices release];
	[_normals release];
	[_colors release];
	[_pointSizes release];
	[_weights release];
	[super dealloc];
}

-(void) initializeTrackers {
	self.arrayBuffer = [CC3OpenGLESStateTrackerArrayBufferBinding trackerWithParent: self];
	self.indexBuffer = [CC3OpenGLESStateTrackerElementArrayBufferBinding trackerWithParent: self];
	self.locations = [CC3OpenGLES1StateTrackerVertexLocationsPointer trackerWithParent: self];
	self.matrixIndices = [CC3OpenGLES1StateTrackerVertexMatrixIndicesPointer trackerWithParent: self];
	self.normals = [CC3OpenGLES1StateTrackerVertexNormalsPointer trackerWithParent: self];
	self.colors = [CC3OpenGLES1StateTrackerVertexColorsPointer trackerWithParent: self];
	self.pointSizes = [CC3OpenGLES1StateTrackerVertexPointSizesPointer trackerWithParent: self];
	self.weights = [CC3OpenGLES1StateTrackerVertexWeightsPointer trackerWithParent: self];
}

-(CC3OpenGLESStateTrackerVertexPointer*) vertexPointerForSemantic: (GLenum) semantic
															   at: (GLuint) semanticIndex {
	switch (semantic) {
		case kCC3SemanticVertexLocation: return _locations;
		case kCC3SemanticVertexNormal: return _normals;
		case kCC3SemanticVertexColor: return _colors;
		case kCC3SemanticVertexPointSize: return _pointSizes;
		case kCC3SemanticVertexWeights: return _weights;
		case kCC3SemanticVertexMatrixIndices: return _matrixIndices;
		case kCC3SemanticVertexTexture:
			return [self.engine.textures textureUnitAt: semanticIndex].textureCoordinates;
			
		default: return nil;
	}
}

-(void) clearUnboundVertexPointers {
	_locations.wasBound = NO;
	_normals.wasBound = NO;
	_colors.wasBound = NO;
	_pointSizes.wasBound = NO;
	_weights.wasBound = NO;
	_matrixIndices.wasBound = NO;
	
	[self.engine.textures clearUnboundVertexPointers];
}

-(void) disableUnboundVertexPointers {
	[_locations disableIfUnbound];
	[_normals disableIfUnbound];
	[_colors disableIfUnbound];
	[_pointSizes disableIfUnbound];
	[_weights disableIfUnbound];
	[_matrixIndices disableIfUnbound];
	[self.engine.textures disableUnboundVertexPointers];
}

-(void) enable2DVertexPointers {
	[_locations enable];
	[_colors enable];
	[_normals disable];
	[_pointSizes disable];
	[_weights disable];
	[_matrixIndices disable];
}

-(NSString*) description {
	NSMutableString* desc = [NSMutableString stringWithCapacity: 600];
	[desc appendFormat: @"%@:", [self class]];
	[desc appendFormat: @"\n    %@ ", self.arrayBuffer];
	[desc appendFormat: @"\n    %@ ", self.indexBuffer];
	[desc appendFormat: @"\n    %@ ", self.locations];
	[desc appendFormat: @"\n    %@ ", self.matrixIndices];
	[desc appendFormat: @"\n    %@ ", self.normals];
	[desc appendFormat: @"\n    %@ ", self.colors];
	[desc appendFormat: @"\n    %@ ", self.pointSizes];
	[desc appendFormat: @"\n    %@ ", self.weights];
	return desc;
}

@end

#endif

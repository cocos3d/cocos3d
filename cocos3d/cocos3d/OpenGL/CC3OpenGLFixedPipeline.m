/*
 * CC3OpenGLFixedPipeline.m
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
 * See header file CC3OpenGLFixedPipeline.h for full API documentation.
 */

#import "CC3OpenGLFixedPipeline.h"
#import "CC3ShaderSemantics.h"
#import "CC3UtilityMeshNodes.h"

#if !CC3_GLSL

@interface CC3OpenGL (TemplateMethods)
-(void) initPlatformLimits;
-(void) initVertexAttributes;
-(void) initTextureUnits;
-(void) align3DStateCache;
-(void) align3DVertexAttributeState;
@end

@implementation CC3OpenGLFixedPipeline

-(void) dealloc {
	free(values_GL_TEXTURE_ENV_MODE);
	free(values_GL_TEXTURE_ENV_COLOR);
	[super dealloc];
}


#pragma mark Capabilities

-(void) enableAlphaTesting: (BOOL) onOff { cc3_SetGLCap(GL_ALPHA_TEST, onOff, valueCap_GL_ALPHA_TEST, isKnownCap_GL_ALPHA_TEST); }

-(void) enableClipPlane: (BOOL) onOff at: (GLuint) clipIdx { CC3SetGLCapAt(GL_CLIP_PLANE0, clipIdx, onOff, &value_GL_CLIP_PLANE, &isKnownCap_GL_CLIP_PLANE); }

-(void) enableColorLogicOp: (BOOL) onOff { cc3_SetGLCap(GL_COLOR_LOGIC_OP, onOff, valueCap_GL_COLOR_LOGIC_OP, isKnownCap_GL_COLOR_LOGIC_OP); }

-(void) enableColorMaterial: (BOOL) onOff { cc3_SetGLCap(GL_COLOR_MATERIAL, onOff, valueCap_GL_COLOR_MATERIAL, isKnownCap_GL_COLOR_MATERIAL); }

-(void) enableFog: (BOOL) onOff { cc3_SetGLCap(GL_FOG, onOff, valueCap_GL_FOG, isKnownCap_GL_FOG); }

-(void) enableLineSmoothing: (BOOL) onOff { cc3_SetGLCap(GL_LINE_SMOOTH, onOff, valueCap_GL_LINE_SMOOTH, isKnownCap_GL_LINE_SMOOTH); }

-(void) enableMultisampling: (BOOL) onOff { cc3_SetGLCap(GL_MULTISAMPLE, onOff, valueCap_GL_MULTISAMPLE, isKnownCap_GL_MULTISAMPLE); }

-(void) enableNormalize: (BOOL) onOff { cc3_SetGLCap(GL_NORMALIZE, onOff, valueCap_GL_NORMALIZE, isKnownCap_GL_NORMALIZE); }

-(void) enablePointSmoothing: (BOOL) onOff { cc3_SetGLCap(GL_POINT_SMOOTH, onOff, valueCap_GL_POINT_SMOOTH, isKnownCap_GL_POINT_SMOOTH); }

-(void) enableRescaleNormal: (BOOL) onOff { cc3_SetGLCap(GL_RESCALE_NORMAL, onOff, valueCap_GL_RESCALE_NORMAL, isKnownCap_GL_RESCALE_NORMAL); }

-(void) enableSampleAlphaToOne: (BOOL) onOff { cc3_SetGLCap(GL_SAMPLE_ALPHA_TO_ONE, onOff, valueCap_GL_SAMPLE_ALPHA_TO_ONE, isKnownCap_GL_SAMPLE_ALPHA_TO_ONE); }


#pragma mark Vertex attribute arrays

-(void) bindMesh: (CC3Mesh*) mesh withVisitor: (CC3NodeDrawingVisitor*) visitor {
	[self clearUnboundVertexAttributes];
	
	[self bindVertexArray: mesh.vertexLocations withVisitor: visitor];
	[self bindVertexArray: mesh.vertexBoneIndices withVisitor: visitor];
	[self bindVertexArray: mesh.vertexBoneWeights withVisitor: visitor];
	[self bindVertexArray: mesh.vertexPointSizes withVisitor: visitor];
	[self bindVertexArray: mesh.vertexIndices withVisitor: visitor];
	
	if (visitor.shouldDecorateNode) {
		[self bindVertexArray: mesh.vertexNormals withVisitor: visitor];
		[self bindVertexArray: mesh.vertexTangents withVisitor: visitor];
		[self bindVertexArray: mesh.vertexBitangents withVisitor: visitor];
		[self bindVertexArray: mesh.vertexColors withVisitor: visitor];
		
		GLuint tuCnt = visitor.textureCount;
		for (GLuint tuIdx = 0; tuIdx < tuCnt; tuIdx++) {
			visitor.current2DTextureUnit = tuIdx;
			[self bindVertexArray: [mesh textureCoordinatesForTextureUnit: tuIdx]
					  withVisitor: visitor];
		}
	}
	
	[self enableBoundVertexAttributes];
}

-(void) bindVertexArray: (CC3VertexArray*) vtxArray withVisitor: (CC3NodeDrawingVisitor*) visitor {
	GLint vaIdx = [self vertexAttributeIndexForSemantic: vtxArray.semantic withVisitor: visitor];
	[vtxArray bindContentToAttributeAt: vaIdx withVisitor: visitor];
}

-(GLint) vertexAttributeIndexForSemantic: (GLenum) semantic
							 withVisitor: (CC3NodeDrawingVisitor*) visitor {

	// If no semantic (eg- vertex indices), short circuit to no index available.
	if (semantic == kCC3SemanticNone) return kCC3VertexAttributeIndexUnavailable;
	
	// Texture coordinate attribute arrays come after the others and are indexed by texture unit
	if (semantic == kCC3SemanticVertexTexture)
		return [self attributeIndexForTextureUnit: visitor.current2DTextureUnit];
	
	// Other vertex attributes are compared by semantic
	for (GLuint vaIdx = 0; vaIdx < value_NumNonTexVertexAttribs; vaIdx++)
		if (semantic == vertexAttributes[vaIdx].semantic) return vaIdx;
	
	// The semantic is not supported by fixed pipeline (eg- tangents & bitangents).
	return kCC3VertexAttributeIndexUnavailable;
}

-(void) bindVertexContentToAttributeAt: (GLint) vaIdx {
	if (vaIdx < 0) return;
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	switch (vaPtr->semantic) {
		case kCC3SemanticVertexLocation:
			glVertexPointer(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"glVertexPointer(%i, %@, %i, %p)", vaPtr->elementSize, NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexNormal:
			glNormalPointer(vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"glNormalPointer(%@, %i, %p)", NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexColor:
			glColorPointer(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"glColorPointer(%i, %@, %i, %p)", vaPtr->elementSize, NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexTexture:
			[self activateClientTextureUnit: [self textureUnitFromAttributeIndex: vaIdx]];
			glTexCoordPointer(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"glTexCoordPointer(%i, %@, %i, %p)", vaPtr->elementSize, NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
			break;
		default:
			CC3Assert(NO, @"Semantic %@ of vertex attribute index %i is not a vertex attribute semantic.", NSStringFromCC3Semantic(vaPtr->semantic), vaIdx);
			break;
	}
}

-(void) setVertexAttributeEnablementAt: (GLint) vaIdx {
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	
	// If enabling texture coordinates, activate the appropriate texture unit first
	if (vaPtr->semantic == kCC3SemanticVertexTexture)
		[self activateClientTextureUnit: [self textureUnitFromAttributeIndex: vaIdx]];
	
	if (vaPtr->isEnabled)
		glEnableClientState(vaPtr->glName);
	else
		glDisableClientState(vaPtr->glName);
	LogGLErrorTrace(@"gl%@ableClientState(%@)", (vaPtr->isEnabled ? @"En" : @"Dis"), NSStringFromGLEnum(vaPtr->glName));
}

/** Texture unit attributes come after the others and are indexed by texture unit. */
-(GLuint) textureUnitFromAttributeIndex: (GLint) vaIdx { return vaIdx - value_NumNonTexVertexAttribs; }

/** Texture unit attributes come after the others and are indexed by texture unit. */
-(GLint) attributeIndexForTextureUnit: (GLuint) tuIdx { return tuIdx + value_NumNonTexVertexAttribs; }

-(void) enable2DVertexAttributes {
	for (GLuint vaIdx = 0; vaIdx < value_MaxVertexAttribsUsed; vaIdx++) {
		switch (vertexAttributes[vaIdx].semantic) {
			case kCC3SemanticVertexLocation:
			case kCC3SemanticVertexColor:
				[self enableVertexAttribute: YES at: vaIdx];
				break;
			case kCC3SemanticVertexTexture:
				// Only enable texture unit zero
				[self enableVertexAttribute: ([self textureUnitFromAttributeIndex: vaIdx] == 0) at: vaIdx];
				break;
			default:
				[self enableVertexAttribute: NO at: vaIdx];
				break;
		}
	}
}

// Mark position, color & first tex coords as unknown
-(void) align3DVertexAttributeState {
	[super align3DVertexAttributeState];

	for (GLuint vaIdx = 0; vaIdx < value_MaxVertexAttribsUsed; vaIdx++) {
		CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
		switch (vaPtr->semantic) {
			case kCC3SemanticVertexLocation:
			case kCC3SemanticVertexColor:
				vertexAttributes[vaIdx].isEnabledKnown = NO;
				vertexAttributes[vaIdx].isKnown = NO;
				break;
			case kCC3SemanticVertexTexture:
				// First  texture unit only.
				if ([self textureUnitFromAttributeIndex: vaIdx] == 0) {
					vertexAttributes[vaIdx].isEnabledKnown = NO;
					vertexAttributes[vaIdx].isKnown = NO;
				}
				break;
			default:
				break;
		}
	}
}


#pragma mark State

-(void) setColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, value_GL_CURRENT_COLOR),
					 value_GL_CURRENT_COLOR, isKnown_GL_CURRENT_COLOR);
	if ( !needsUpdate ) return;
	glColor4f(color.r, color.g, color.b, color.a);
	LogGLErrorTrace(@"glColor4f%@", NSStringFromCCC4F(color));
}

-(void) setPointSize: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_POINT_SIZE, isKnown_GL_POINT_SIZE);
	if ( !needsUpdate ) return;
	glPointSize(val);
	LogGLErrorTrace(@"glPointSize(%.3f)", val);
}

-(void) setPointSizeAttenuation: (CC3AttenuationCoefficients) ac {
	cc3_CheckGLValue(ac, CC3AttenuationCoefficientsAreEqual(ac, value_GL_POINT_DISTANCE_ATTENUATION),
					 value_GL_POINT_DISTANCE_ATTENUATION, isKnown_GL_POINT_DISTANCE_ATTENUATION);
	if ( !needsUpdate ) return;
	glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION, (GLfloat*)&ac);
	LogGLErrorTrace(@"glPointParameterfv(%@, %@)", NSStringFromGLEnum(GL_POINT_DISTANCE_ATTENUATION), NSStringFromCC3AttenuationCoefficients(ac));
}

-(void) setPointSizeFadeThreshold: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_POINT_FADE_THRESHOLD_SIZE, isKnown_GL_POINT_FADE_THRESHOLD_SIZE);
	if ( !needsUpdate ) return;
	glPointParameterf(GL_POINT_FADE_THRESHOLD_SIZE, val);
	LogGLErrorTrace(@"glPointParameterfv(%@, %.3f)", NSStringFromGLEnum(GL_POINT_FADE_THRESHOLD_SIZE), val);
}

-(void) setPointSizeMinimum: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_POINT_SIZE_MIN, isKnown_GL_POINT_SIZE_MIN);
	if ( !needsUpdate ) return;
	glPointParameterf(GL_POINT_SIZE_MIN, val);
	LogGLErrorTrace(@"glPointParameterfv(%@, %.3f)", NSStringFromGLEnum(GL_POINT_SIZE_MIN), val);
}

-(void) setPointSizeMaximum: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_POINT_SIZE_MAX, isKnown_GL_POINT_SIZE_MAX);
	if ( !needsUpdate ) return;
	glPointParameterf(GL_POINT_SIZE_MAX, val);
	LogGLErrorTrace(@"glPointParameterfv(%@, %.3f)", NSStringFromGLEnum(GL_POINT_SIZE_MAX), val);
}

-(void) setShadeModel: (GLenum) val {
	cc3_CheckGLPrim(val, value_GL_SHADE_MODEL, isKnown_GL_SHADE_MODEL);
	if ( !needsUpdate ) return;
	glShadeModel(val);
	LogGLErrorTrace(@"glShadeModel(%@)", NSStringFromGLEnum(val));
}


#pragma mark Lighting

-(void) enableLighting: (BOOL) onOff { cc3_SetGLCap(GL_LIGHTING, onOff, valueCap_GL_LIGHTING, isKnownCap_GL_LIGHTING); }

-(void) enableTwoSidedLighting: (BOOL) onOff {
	if ( CC3BooleansAreEqual(onOff, value_GL_LIGHT_MODEL_TWO_SIDE) && isKnown_GL_LIGHT_MODEL_TWO_SIDE) return;

	isKnown_GL_LIGHT_MODEL_TWO_SIDE = YES;
	value_GL_LIGHT_MODEL_TWO_SIDE = onOff;
	glLightModelx(GL_LIGHT_MODEL_TWO_SIDE, (onOff ? GL_TRUE : GL_FALSE));
	LogGLErrorTrace(@"glLightModelx(%@, %@)", NSStringFromGLEnum(GL_LIGHT_MODEL_TWO_SIDE), NSStringFromBoolean(onOff));
}

-(void) setSceneAmbientLightColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, value_GL_LIGHT_MODEL_AMBIENT),
					 value_GL_LIGHT_MODEL_AMBIENT, isKnown_GL_LIGHT_MODEL_AMBIENT);
	if ( !needsUpdate ) return;
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, (GLfloat*)&color);
	LogGLErrorTrace(@"glLightModelfv(%@, %@)", NSStringFromGLEnum(GL_LIGHT_MODEL_AMBIENT), NSStringFromCCC4F(color));
}

-(void) enableLight: (BOOL) onOff at: (GLuint) ltIdx {
	CC3SetGLCapAt(GL_LIGHT0, ltIdx, onOff, &value_GL_LIGHT, &isKnownCap_GL_LIGHT);
}

-(void) setLightAmbientColor: (ccColor4F) color at: (GLuint) ltIdx {
	if (CC3CheckGLColorAt(ltIdx, color, valueLight_GL_AMBIENT, &isKnownLight_GL_AMBIENT)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_AMBIENT, (GLfloat*)&color);
		LogGLErrorTrace(@"glLightfv(%@, %@, %@)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_AMBIENT), NSStringFromCCC4F(color));
	}
}

-(void) setLightDiffuseColor: (ccColor4F) color at: (GLuint) ltIdx {
	if (CC3CheckGLColorAt(ltIdx, color, valueLight_GL_DIFFUSE, &isKnownLight_GL_DIFFUSE)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_DIFFUSE, (GLfloat*)&color);
		LogGLErrorTrace(@"glLightfv(%@, %@, %@)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_DIFFUSE), NSStringFromCCC4F(color));
	}
}

-(void) setLightSpecularColor: (ccColor4F) color at: (GLuint) ltIdx {
	if (CC3CheckGLColorAt(ltIdx, color, valueLight_GL_SPECULAR, &isKnownLight_GL_SPECULAR)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_SPECULAR, (GLfloat*)&color);
		LogGLErrorTrace(@"glLightfv(%@, %@, %@)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_SPECULAR), NSStringFromCCC4F(color));
	}
}

/** 
 * For fixed pipeline, need to update light position/direction after modelview matrix
 * is updated, even if light position/direction does not change.
 * See http://www.opengl.org/archives/resources/faq/technical/lights.htm#ligh0050
 */
-(void) setLightPosition: (CC3Vector4) pos at: (GLuint) ltIdx {
	glLightfv((GL_LIGHT0 + ltIdx), GL_POSITION, (GLfloat*)&pos);
	LogGLErrorTrace(@"glLightfv(%@, %@, %@)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_POSITION), NSStringFromCC3Vector4(pos));
}

-(void) setLightAttenuation: (CC3AttenuationCoefficients) ac at: (GLuint) ltIdx {
	if (CC3CheckGLfloatAt(ltIdx, ac.a, valueLight_GL_CONSTANT_ATTENUATION, &isKnownLight_GL_CONSTANT_ATTENUATION)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_CONSTANT_ATTENUATION, ac.a);
		LogGLErrorTrace(@"glLightf(%@, %@, %.3f)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_CONSTANT_ATTENUATION), ac.a);
	}
	if (CC3CheckGLfloatAt(ltIdx, ac.b, valueLight_GL_LINEAR_ATTENUATION, &isKnownLight_GL_LINEAR_ATTENUATION)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_LINEAR_ATTENUATION, ac.b);
		LogGLErrorTrace(@"glLightf(%@, %@, %.4f)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_LINEAR_ATTENUATION), ac.b);
	}
	if (CC3CheckGLfloatAt(ltIdx, ac.c, valueLight_GL_QUADRATIC_ATTENUATION, &isKnownLight_GL_QUADRATIC_ATTENUATION)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_QUADRATIC_ATTENUATION, ac.c);
		LogGLErrorTrace(@"glLightf(%@, %@, %.6f)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_QUADRATIC_ATTENUATION), ac.c);
	}
}

/**
 * For fixed pipeline, need to update light  spot direction after modelview matrix
 * is updated, even if light spot direction does not change.
 * See http://www.opengl.org/archives/resources/faq/technical/lights.htm#ligh0050
 */
-(void) setSpotlightDirection: (CC3Vector) dir at: (GLuint) ltIdx {
	glLightfv((GL_LIGHT0 + ltIdx), GL_SPOT_DIRECTION, (GLfloat*)&dir);
	LogGLErrorTrace(@"glLightfv(%@, %@, %@)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_SPOT_DIRECTION), NSStringFromCC3Vector(dir));
}

-(void) setSpotlightFadeExponent: (GLfloat) val at: (GLuint) ltIdx {
	if (CC3CheckGLfloatAt(ltIdx, val, valueLight_GL_SPOT_EXPONENT, &isKnownLight_GL_SPOT_EXPONENT)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_SPOT_EXPONENT, val);
		LogGLErrorTrace(@"glLightf(%@, %@, %.3f)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_SPOT_EXPONENT), val);
	}
}

-(void) setSpotlightCutoffAngle: (GLfloat) val at: (GLuint) ltIdx {
	if (CC3CheckGLfloatAt(ltIdx, val, valueLight_GL_SPOT_CUTOFF, &isKnownLight_GL_SPOT_CUTOFF)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_SPOT_CUTOFF, val);
		LogGLErrorTrace(@"glLightf(%@, %@, %.3f)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_SPOT_CUTOFF), val);
	}
}

-(void) bindFog: (CC3Fog*) fog withVisitor: (CC3NodeDrawingVisitor*) visitor {
	BOOL isFoggy = fog && fog.visible && visitor.shouldDecorateNode;
	
	[self enableFog: isFoggy];
	
	if ( !isFoggy ) return;

	self.fogColor = fog.diffuseColor;
	self.fogHint = fog.performanceHint;
	
	GLenum attnMode = fog.attenuationMode;
	self.fogMode = attnMode;
	switch (attnMode) {
		case GL_LINEAR:
			self.fogStart = fog.startDistance;
			self.fogEnd = fog.endDistance;
			break;
		case GL_EXP:
		case GL_EXP2:
			self.fogDensity = fog.density;
			break;
		default:
			CC3Assert(NO, @"%@ encountered bad attenuation mode (%04X)", fog, fog.attenuationMode);
			break;
	}
}

-(void) setFogColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, value_GL_FOG_COLOR),
					 value_GL_FOG_COLOR, isKnown_GL_FOG_COLOR);
	if ( !needsUpdate ) return;
	glFogfv(GL_FOG_COLOR, (GLfloat*)&color);
	LogGLErrorTrace(@"glFogfv(%@, %@)", NSStringFromGLEnum(GL_FOG_COLOR), NSStringFromCCC4F(color));
}

-(void) setFogDensity: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_FOG_DENSITY, isKnown_GL_FOG_DENSITY);
	if ( !needsUpdate ) return;
	glFogf(GL_FOG_DENSITY, val);
	LogGLErrorTrace(@"glFogfv(%@, %.3f)", NSStringFromGLEnum(GL_FOG_DENSITY), val);
}

-(void) setFogStart: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_FOG_START, isKnown_GL_FOG_START);
	if ( !needsUpdate ) return;
	glFogf(GL_FOG_START, val);
	LogGLErrorTrace(@"glFogfv(%@, %.3f)", NSStringFromGLEnum(GL_FOG_START), val);
}

-(void) setFogEnd: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_FOG_END, isKnown_GL_FOG_END);
	if ( !needsUpdate ) return;
	glFogf(GL_FOG_END, val);
	LogGLErrorTrace(@"glFogfv(%@, %.3f)", NSStringFromGLEnum(GL_FOG_END), val);
}


#pragma mark Materials

-(void) setMaterialAmbientColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, valueMat_GL_AMBIENT),
					 valueMat_GL_AMBIENT, isKnownMat_GL_AMBIENT);
	if ( !needsUpdate ) return;
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, (GLfloat*)&color);
	LogGLErrorTrace(@"glMaterialfv(%@, %@, %@)", NSStringFromGLEnum(GL_FRONT_AND_BACK), NSStringFromGLEnum(GL_AMBIENT), NSStringFromCCC4F(color));
}

-(void) setMaterialDiffuseColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, valueMat_GL_DIFFUSE),
					 valueMat_GL_DIFFUSE, isKnownMat_GL_DIFFUSE);
	if ( !needsUpdate ) return;
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, (GLfloat*)&color);
	LogGLErrorTrace(@"glMaterialfv(%@, %@, %@)", NSStringFromGLEnum(GL_FRONT_AND_BACK), NSStringFromGLEnum(GL_DIFFUSE), NSStringFromCCC4F(color));
}

-(void) setMaterialSpecularColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, valueMat_GL_SPECULAR),
					 valueMat_GL_SPECULAR, isKnownMat_GL_SPECULAR);
	if ( !needsUpdate ) return;
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, (GLfloat*)&color);
	LogGLErrorTrace(@"glMaterialfv(%@, %@, %@)", NSStringFromGLEnum(GL_FRONT_AND_BACK), NSStringFromGLEnum(GL_SPECULAR), NSStringFromCCC4F(color));
}

-(void) setMaterialEmissionColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, valueMat_GL_EMISSION),
					 valueMat_GL_EMISSION, isKnownMat_GL_EMISSION);
	if ( !needsUpdate ) return;
	glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, (GLfloat*)&color);
	LogGLErrorTrace(@"glMaterialfv(%@, %@, %@)", NSStringFromGLEnum(GL_FRONT_AND_BACK), NSStringFromGLEnum(GL_EMISSION), NSStringFromCCC4F(color));
}

-(void) setMaterialShininess: (GLfloat) val {
	cc3_CheckGLPrim(val, valueMat_GL_SHININESS, isKnownMat_GL_SHININESS);
	if ( !needsUpdate ) return;
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, val);
	LogGLErrorTrace(@"glMaterialf(%@, %@, %.3f)", NSStringFromGLEnum(GL_FRONT_AND_BACK), NSStringFromGLEnum(GL_SHININESS), val);
}

-(void) setAlphaFunc: (GLenum) func reference: (GLfloat) ref {
	if ((func != value_GL_ALPHA_TEST_FUNC) || (ref != value_GL_ALPHA_TEST_REF) || !isKnownAlphaFunc) {
		value_GL_ALPHA_TEST_FUNC = func;
		value_GL_ALPHA_TEST_REF = ref;
		isKnownAlphaFunc = YES;
		glAlphaFunc(func, ref);
		LogGLErrorTrace(@"glAlphaFunc(%@, %.3f)", NSStringFromGLEnum(func), ref);
	}
}


#pragma mark Textures

-(void) activateClientTextureUnit: (GLuint) tuIdx {
	cc3_CheckGLPrim(tuIdx, value_GL_CLIENT_ACTIVE_TEXTURE, isKnown_GL_CLIENT_ACTIVE_TEXTURE);
	if ( !needsUpdate ) return;
	glClientActiveTexture(GL_TEXTURE0 + tuIdx);
	LogGLErrorTrace(@"glClientActiveTexture(%@)", NSStringFromGLEnum(GL_TEXTURE0 + tuIdx));
}

-(void) enableTexturing: (BOOL) onOff inTarget: (GLenum) target at: (GLuint) tuIdx {
	if (target == GL_TEXTURE_2D) {
		if (CC3CheckGLBooleanAt(tuIdx, onOff, &value_GL_TEXTURE_2D, &isKnownCap_GL_TEXTURE_2D)) {
			[self activateTextureUnit: tuIdx];
			if (onOff)
				glEnable(target);
			else
				glDisable(target);
			LogGLErrorTrace(@"gl%@able(%@)", (onOff ? @"En" : @"Dis"), NSStringFromGLEnum(target));
		}
	}
}

-(void) setTextureEnvMode: (GLenum) mode at: (GLuint) tuIdx {
	if (CC3CheckGLuintAt(tuIdx, mode, values_GL_TEXTURE_ENV_MODE, &isKnown_GL_TEXTURE_ENV_MODE)) {
		[self activateTextureUnit: tuIdx];
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, mode);
		LogGLErrorTrace(@"glTexEnvi(%@, %@, %@)", NSStringFromGLEnum(GL_TEXTURE_ENV), NSStringFromGLEnum(GL_TEXTURE_ENV_MODE), NSStringFromGLEnum(mode));
	}
}

-(void) setTextureEnvColor: (ccColor4F) color at: (GLuint) tuIdx {
	if (CC3CheckGLColorAt(tuIdx, color, values_GL_TEXTURE_ENV_COLOR, &isKnown_GL_TEXTURE_ENV_COLOR)) {
		[self activateTextureUnit: tuIdx];
		glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, (GLfloat*)&color);
		LogGLErrorTrace(@"glTexEnvfv(%@, %@, %@)", NSStringFromGLEnum(GL_TEXTURE_ENV), NSStringFromGLEnum(GL_TEXTURE_ENV_COLOR), NSStringFromCCC4F(color));
	}
}


#pragma mark Matrices
	
// Don't change matrix state on background thread (which only occurs during shader prewarming, and so should
// not occur here), because it messes with the concurrent rendering of cocos2d components on the rendering thread.

-(void) activateMatrixStack: (GLenum) mode {
	if ( !self.isRenderingContext ) return;

	cc3_CheckGLPrim(mode, value_GL_MATRIX_MODE, isKnown_GL_MATRIX_MODE);
	if ( !needsUpdate ) return;
	glMatrixMode(mode);
	LogGLErrorTrace(@"glMatrixMode(%@)", NSStringFromGLEnum(mode));
}

-(void) loadModelviewMatrix: (CC3Matrix4x3*) mtx {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_MODELVIEW];
	CC3Matrix4x4 glMtx;
	CC3Matrix4x4PopulateFrom4x3(&glMtx, mtx);
	glLoadMatrixf(glMtx.elements);
	LogGLErrorTrace(@"glLoadMatrixf(%@)", NSStringFromCC3Matrix4x4(&glMtx));
}

-(void) loadProjectionMatrix: (CC3Matrix4x4*) mtx {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_PROJECTION];
	glLoadMatrixf(mtx->elements);
	LogGLErrorTrace(@"glLoadMatrixf(%@)", NSStringFromCC3Matrix4x4(mtx));
}

-(void) loadPaletteMatrix: (CC3Matrix4x3*) mtx at: (GLuint) pmIdx {
	if ( !self.isRenderingContext ) return;
	
	[self activatePaletteMatrixStack: pmIdx];
	CC3Matrix4x4 glMtx;
	CC3Matrix4x4PopulateFrom4x3(&glMtx, mtx);
	glLoadMatrixf(glMtx.elements);
	LogGLErrorTrace(@"glLoadMatrixf(%@)", NSStringFromCC3Matrix4x4(&glMtx));
}

-(void) pushModelviewMatrixStack {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_MODELVIEW];
	glPushMatrix();
	LogGLErrorTrace(@"glPushMatrix()");
}

-(void) popModelviewMatrixStack {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_MODELVIEW];
	glPopMatrix();
	LogGLErrorTrace(@"glPopMatrix()");
}

-(void) pushProjectionMatrixStack {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_PROJECTION];
	glPushMatrix();
	LogGLErrorTrace(@"glPushMatrix()");
}

-(void) popProjectionMatrixStack {
	if ( !self.isRenderingContext ) return;
	
	[self activateMatrixStack: GL_PROJECTION];
	glPopMatrix();
	LogGLErrorTrace(@"glPopMatrix()");
}


#pragma mark Hints

-(void) setFogHint: (GLenum) hint {
	cc3_CheckGLPrim(hint, value_GL_FOG_HINT, isKnown_GL_FOG_HINT);
	if ( !needsUpdate ) return;
	glHint(GL_FOG_HINT, hint);
	LogGLErrorTrace(@"glHint(%@, %@)", NSStringFromGLEnum(GL_FOG_HINT), NSStringFromGLEnum(hint));
}

-(void) setLineSmoothingHint: (GLenum) hint {
	cc3_CheckGLPrim(hint, value_GL_LINE_SMOOTH_HINT, isKnown_GL_LINE_SMOOTH_HINT);
	if ( !needsUpdate ) return;
	glHint(GL_LINE_SMOOTH_HINT, hint);
	LogGLErrorTrace(@"glHint(%@, %@)", NSStringFromGLEnum(GL_LINE_SMOOTH_HINT), NSStringFromGLEnum(hint));
}

-(void) setPerspectiveCorrectionHint: (GLenum) hint {
	cc3_CheckGLPrim(hint, value_GL_PERSPECTIVE_CORRECTION_HINT, isKnown_GL_PERSPECTIVE_CORRECTION_HINT);
	if ( !needsUpdate ) return;
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, hint);
	LogGLErrorTrace(@"glHint(%@, %@)", NSStringFromGLEnum(GL_PERSPECTIVE_CORRECTION_HINT), NSStringFromGLEnum(hint));
}

-(void) setPointSmoothingHint: (GLenum) hint {
	cc3_CheckGLPrim(hint, value_GL_POINT_SMOOTH_HINT, isKnown_GL_POINT_SMOOTH_HINT);
	if ( !needsUpdate ) return;
	glHint(GL_POINT_SMOOTH_HINT, hint);
	LogGLErrorTrace(@"glHint(%@, %@)", NSStringFromGLEnum(GL_POINT_SMOOTH_HINT), NSStringFromGLEnum(hint));
}


#pragma mark Aligning 2D & 3D state

-(void) align3DStateCache {
	[super align3DStateCache];
	
	isKnownCap_GL_LIGHT = NO;
	isKnown_GL_CURRENT_COLOR = NO;
}


#pragma mark Allocation and initialization

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	value_GL_MAX_TEXTURE_UNITS = [self getInteger: GL_MAX_TEXTURE_UNITS];
	LogInfoIfPrimary(@"Maximum texture units: %u", value_GL_MAX_TEXTURE_UNITS);
	
	// Initial estimate for allocating space. The actual value is set by the initVertexAttributes method.
	value_GL_MAX_VERTEX_ATTRIBS = value_GL_MAX_TEXTURE_UNITS + kMAX_VTX_ATTRS_EX_TEXCOORD;

	value_GL_MAX_CLIP_PLANES = [self getInteger: GL_MAX_CLIP_PLANES];
	LogInfoIfPrimary(@"Maximum clip planes: %u", value_GL_MAX_CLIP_PLANES);

	value_GL_MAX_LIGHTS = [self getInteger: GL_MAX_LIGHTS];
	LogInfoIfPrimary(@"Maximum lights: %u", value_GL_MAX_LIGHTS);

	value_GL_MAX_PALETTE_MATRICES = 0;
	
	valueMaxBoneInfluencesPerVertex = 0;
	
	value_GL_MAX_SAMPLES = 1;
}

/**
 * Under the fixed pipeline, the vertex attribute arrays each have a fixed purpose. Invokes
 * super to allocate the trackers, and then initializes the semantic and GL name of each. 
 * Texture coordinate arrays come first, followed by the other vertex attribute arrays.
 *
 * This method updates the value_NumNonTexVertexAttribs, value_MaxVertexAttribsUsed,
 * and value_GL_MAX_VERTEX_ATTRIBS properties.
 */
-(void) initVertexAttributes {
	[super initVertexAttributes];

	value_GL_MAX_VERTEX_ATTRIBS = 0;
	
	[self initNonTextureVertexAttributes];

	value_NumNonTexVertexAttribs = value_GL_MAX_VERTEX_ATTRIBS;

	[self initTextureVertexAttributes];
	
	// Assume that only the single texture unit used by cocos2d will be used by cocos3d.
	// This will be increased automatically as needed.
	value_MaxVertexAttribsUsed = value_NumNonTexVertexAttribs + 1;
}

/** Initialize the vertex attributes that are not texture coordinates. */
-(void) initNonTextureVertexAttributes {
	
	GLuint vaIdx = value_GL_MAX_VERTEX_ATTRIBS;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexLocation;
	vertexAttributes[vaIdx].glName = GL_VERTEX_ARRAY;
	vaIdx++;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexNormal;
	vertexAttributes[vaIdx].glName = GL_NORMAL_ARRAY;
	vaIdx++;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexColor;
	vertexAttributes[vaIdx].glName = GL_COLOR_ARRAY;
	vaIdx++;
	
	value_GL_MAX_VERTEX_ATTRIBS = vaIdx;
}

/** Initialize the vertex attributes that are texture coordinates. */
-(void) initTextureVertexAttributes {

	GLuint vaIdx = value_GL_MAX_VERTEX_ATTRIBS;

	for (GLuint tuIdx = 0; tuIdx < value_GL_MAX_TEXTURE_UNITS; tuIdx++) {
		vertexAttributes[vaIdx].semantic = kCC3SemanticVertexTexture;
		vertexAttributes[vaIdx].glName = GL_TEXTURE_COORD_ARRAY;
		vaIdx++;
	}
	
	value_GL_MAX_VERTEX_ATTRIBS = vaIdx;
}

/** Allocates and initializes the texture units. This must be invoked after the initPlatformLimits. */
-(void) initTextureUnits {
	[super initTextureUnits];
	values_GL_TEXTURE_ENV_MODE = calloc(value_GL_MAX_TEXTURE_UNITS, sizeof(GLenum));
	values_GL_TEXTURE_ENV_COLOR = calloc(value_GL_MAX_TEXTURE_UNITS, sizeof(ccColor4F));
}

@end

#endif	// !CC3_GLSL
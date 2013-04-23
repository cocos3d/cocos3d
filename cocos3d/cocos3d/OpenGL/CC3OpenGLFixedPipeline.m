/*
 * CC3OpenGLFixedPipeline.m
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
 * See header file CC3OpenGLFixedPipeline.h for full API documentation.
 */

#import "CC3OpenGLFixedPipeline.h"
#import "CC3GLProgramSemantics.h"
#import "CC3NodeVisitor.h"
#import "CC3Mesh.h"

#if !CC3_GLSL

@interface CC3OpenGL (TemplateMethods)
-(void) initPlatformLimits;
-(void) initVertexAttributes;
-(void) initTextureUnits;
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
	[self bindVertexArray: mesh.vertexMatrixIndices withVisitor: visitor];
	[self bindVertexArray: mesh.vertexWeights withVisitor: visitor];
	[self bindVertexArray: mesh.vertexPointSizes withVisitor: visitor];
	[self bindVertexArray: mesh.vertexIndices withVisitor: visitor];
	
	if (visitor.shouldDecorateNode) {
		[self bindVertexArray: mesh.vertexNormals withVisitor: visitor];
		[self bindVertexArray: mesh.vertexTangents withVisitor: visitor];
		[self bindVertexArray: mesh.vertexBitangents withVisitor: visitor];
		[self bindVertexArray: mesh.vertexColors withVisitor: visitor];
		
		GLuint tuCnt = visitor.textureUnitCount;
		for (GLuint tuIdx = 0; tuIdx < tuCnt; tuIdx++) {
			visitor.currentTextureUnitIndex = tuIdx;
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

	// Texture coordinate attribute arrays come first and are indexed by texture unit
	if (semantic == kCC3SemanticVertexTexture) return visitor.currentTextureUnitIndex;
	
	// Other vertex attributes come after and are compared by semantic
	for (GLuint vaIdx = value_GL_MAX_TEXTURE_UNITS; vaIdx < value_GL_MAX_VERTEX_ATTRIBS; vaIdx++)
		if (semantic == vertexAttributes[vaIdx].semantic) return vaIdx;

	// The semantic is not supported by OGLES 1.1 (eg- tangents & bitangents).
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
			[self activateClientTextureUnit: vaIdx];
			glTexCoordPointer(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"glTexCoordPointer(%i, %@, %i, %p)", vaPtr->elementSize, NSStringFromGLEnum(vaPtr->elementType), vaPtr->vertexStride, vaPtr->vertices);
			break;
		default:
			CC3Assert(NO, @"Semantic %@ is not a vertex attribute semantic.", NSStringFromCC3Semantic(vaPtr->semantic));
			break;
	}
}

-(void) setVertexAttributeEnablementAt: (GLint) vaIdx {
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	
	// If enabling texture coordinates, activate the appropriate texture unit first
	if (vaPtr->semantic == kCC3SemanticVertexTexture) [self activateClientTextureUnit: vaIdx];
	
	if (vaPtr->isEnabled)
		glEnableClientState(vaPtr->glName);
	else
		glDisableClientState(vaPtr->glName);
	LogGLErrorTrace(@"gl%@ableClientState(%@)", (vaPtr->isEnabled ? @"En" : @"Dis"), NSStringFromGLEnum(vaPtr->glName));
}

-(void) enable2DVertexAttributes {
	for (GLuint vaIdx = 0; vaIdx < value_GL_MAX_VERTEX_ATTRIBS; vaIdx++) {
		switch (vertexAttributes[vaIdx].semantic) {
			case kCC3SemanticVertexLocation:
			case kCC3SemanticVertexColor:
				[self enableVertexAttribute: YES at: vaIdx];
				break;
			case kCC3SemanticVertexTexture:
				[self enableVertexAttribute: (vaIdx == 0) at: vaIdx];	// Only enable the first VU
				break;
			default:
				[self enableVertexAttribute: NO at: vaIdx];
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

-(void) setLightPosition: (CC3Vector4) pos at: (GLuint) ltIdx {
	if (CC3CheckGLVector4At(ltIdx, pos, valueLight_GL_POSITION, &isKnownLight_GL_POSITION)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_POSITION, (GLfloat*)&pos);
		LogGLErrorTrace(@"glLightfv(%@, %@, %@)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_POSITION), NSStringFromCC3Vector4(pos));
	}
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

-(void) setSpotlightDirection: (CC3Vector) dir at: (GLuint) ltIdx {
	if (CC3CheckGLVectorAt(ltIdx, dir, valueLight_GL_SPOT_DIRECTION, &isKnownLight_GL_SPOT_DIRECTION)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_SPOT_DIRECTION, (GLfloat*)&dir);
		LogGLErrorTrace(@"glLightfv(%@, %@, %@)", NSStringFromGLEnum(GL_LIGHT0 + ltIdx), NSStringFromGLEnum(GL_SPOT_DIRECTION), NSStringFromCC3Vector(dir));
	}
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
			LogGLErrorTrace(@"gl%@sable(%@)", (onOff ? @"En" : @"Dis"), NSStringFromGLEnum(target));
		}
	}
}

-(void) disableTexturingFrom: (GLuint) startTexUnitIdx {
	GLuint maxTexUnits = self.maxNumberOfTextureUnits;
	for (GLuint tuIdx = startTexUnitIdx; tuIdx < maxTexUnits; tuIdx++)
		[self enableTexturing: NO inTarget: GL_TEXTURE_2D at: tuIdx];
}

-(void) enableTextureCoordinates: (BOOL) onOff at: (GLuint) tuIdx {
	if (CC3CheckGLBooleanAt(tuIdx, onOff, &value_GL_TEXTURE_COORD_ARRAY, &isKnownCap_GL_TEXTURE_COORD_ARRAY)) {
		[self activateClientTextureUnit: tuIdx];
		if (onOff)
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		else
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		LogGLErrorTrace(@"gl%@sableClientState(%@)", (onOff ? @"En" : @"Dis"), NSStringFromGLEnum(GL_TEXTURE_COORD_ARRAY));
	}
}

-(void) setTextureEnvMode: (GLenum) mode at: (GLuint) tuIdx {
	if (CC3CheckGLuintAt(tuIdx, mode, values_GL_TEXTURE_ENV_MODE, &isKnown_GL_TEXTURE_ENV_MODE)) {
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, mode);
		LogGLErrorTrace(@"glTexEnvi(%@, %@, %@)", NSStringFromGLEnum(GL_TEXTURE_ENV), NSStringFromGLEnum(GL_TEXTURE_ENV_MODE), NSStringFromGLEnum(mode));
	}
}

-(void) setTextureEnvColor: (ccColor4F) color at: (GLuint) tuIdx {
	if (CC3CheckGLColorAt(tuIdx, color, values_GL_TEXTURE_ENV_COLOR, &isKnown_GL_TEXTURE_ENV_COLOR)) {
		glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, (GLfloat*)&color);
		LogGLErrorTrace(@"glTexEnvfv(%@, %@, %@)", NSStringFromGLEnum(GL_TEXTURE_ENV), NSStringFromGLEnum(GL_TEXTURE_ENV_COLOR), NSStringFromCCC4F(color));
	}
}


#pragma mark Matrices

-(void) activateMatrixStack: (GLenum) mode {
	cc3_CheckGLPrim(mode, value_GL_MATRIX_MODE, isKnown_GL_MATRIX_MODE);
	if ( !needsUpdate ) return;
	glMatrixMode(mode);
	LogGLErrorTrace(@"glMatrixMode(%@)", NSStringFromGLEnum(mode));
}

-(void) loadModelviewMatrix: (CC3Matrix4x3*) mtx {
	[self activateMatrixStack: GL_MODELVIEW];
	CC3Matrix4x4 glMtx;
	CC3Matrix4x4PopulateFrom4x3(&glMtx, mtx);
	glLoadMatrixf(glMtx.elements);
	LogGLErrorTrace(@"glLoadMatrixf(%@)", NSStringFromCC3Matrix4x4(&glMtx));
}

-(void) loadProjectionMatrix: (CC3Matrix4x4*) mtx {
	[self activateMatrixStack: GL_PROJECTION];
	glLoadMatrixf(mtx->elements);
	LogGLErrorTrace(@"glLoadMatrixf(%@)", NSStringFromCC3Matrix4x4(mtx));
}

-(void) loadPaletteMatrix: (CC3Matrix4x3*) mtx at: (GLuint) pmIdx {
	[self activatePaletteMatrixStack: pmIdx];
	CC3Matrix4x4 glMtx;
	CC3Matrix4x4PopulateFrom4x3(&glMtx, mtx);
	glLoadMatrixf(glMtx.elements);
	LogGLErrorTrace(@"glLoadMatrixf(%@)", NSStringFromCC3Matrix4x4(&glMtx));
}

-(void) pushModelviewMatrixStack {
	[self activateMatrixStack: GL_MODELVIEW];
	glPushMatrix();
	LogGLErrorTrace(@"glPushMatrix()");
}

-(void) popModelviewMatrixStack {
	[self activateMatrixStack: GL_MODELVIEW];
	glPopMatrix();
	LogGLErrorTrace(@"glPopMatrix()");
}

-(void) pushProjectionMatrixStack {
	[self activateMatrixStack: GL_PROJECTION];
	glPushMatrix();
	LogGLErrorTrace(@"glPushMatrix()");
}

-(void) popProjectionMatrixStack {
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


#pragma mark Aligning 2D & 3D caches

-(void) align3DStateCache {
	[super align3DStateCache];
	
	isKnownCap_GL_LIGHT = NO;
	isKnown_GL_CURRENT_COLOR = NO;
}


#pragma mark Allocation and initialization

-(void) initPlatformLimits {
	[super initPlatformLimits];

	glGetIntegerv(GL_MAX_CLIP_PLANES, &value_GL_MAX_CLIP_PLANES);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_CLIP_PLANES), value_GL_MAX_CLIP_PLANES);
	LogInfo(@"Maximum clip planes: %u", value_GL_MAX_CLIP_PLANES);

	glGetIntegerv(GL_MAX_LIGHTS, &value_GL_MAX_LIGHTS);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_LIGHTS), value_GL_MAX_LIGHTS);
	LogInfo(@"Maximum lights: %u", value_GL_MAX_LIGHTS);

	value_GL_MAX_PALETTE_MATRICES = 0;		// Assume no bone skinning support
	
	value_GL_MAX_SAMPLES = 1;				// Assume no multi-sampling support
	
	glGetIntegerv(GL_MAX_TEXTURE_UNITS, &value_GL_MAX_TEXTURE_UNITS);
	LogGLErrorTrace(@"glGetIntegerv(%@, %i)", NSStringFromGLEnum(GL_MAX_TEXTURE_UNITS), value_GL_MAX_TEXTURE_UNITS);
	LogInfo(@"Maximum texture units: %u", value_GL_MAX_TEXTURE_UNITS);

	// Initial estimate for allocating space. The actual value is set by the initVertexAttributes method.
	value_GL_MAX_VERTEX_ATTRIBS = value_GL_MAX_TEXTURE_UNITS + kMAX_VTX_ATTRS_EX_TEXCOORD;

	value_GL_MAX_VERTEX_UNITS = 0;			// Assume no bone skinning support
}

/**
 * Under the fixed pipeline, the vertex attribute arrays each have a fixed purpose. Invokes
 * super to allocate the trackers, and then initializes the semantic and GL name of each. 
 * Texture coordinate arrays come first, followed by the other vertex attribute arrays.
 *
 * This method updates the value_GL_MAX_VERTEX_ATTRIBS property.
 */
-(void) initVertexAttributes {
	[super initVertexAttributes];
	
	GLuint vaIdx = 0;
	while (vaIdx < value_GL_MAX_TEXTURE_UNITS) {
		vertexAttributes[vaIdx].semantic = kCC3SemanticVertexTexture;
		vertexAttributes[vaIdx].glName = GL_TEXTURE_COORD_ARRAY;
		vaIdx++;
	}
	
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

/** Allocates and initializes the texture units. This must be invoked after the initPlatformLimits. */
-(void) initTextureUnits {
	[super initTextureUnits];
	values_GL_TEXTURE_ENV_MODE = calloc(value_GL_MAX_TEXTURE_UNITS, sizeof(GLenum));
	values_GL_TEXTURE_ENV_COLOR = calloc(value_GL_MAX_TEXTURE_UNITS, sizeof(ccColor4F));
}

@end

#endif	// !CC3_GLSL
/*
 * CC3OpenGLES1.m
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
 * See header file CC3OpenGLES1.h for full API documentation.
 */

#import "CC3OpenGLES1.h"
#import "CC3GLProgramSemantics.h"
#import "CC3NodeVisitor.h"

#if CC3_OGLES_1

@interface CC3OpenGL (TemplateMethods)
-(void) initVertexAttributes;
-(void) initTextureUnits;
@end

@implementation CC3OpenGLES1

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

-(void) enableMatrixPalette: (BOOL) onOff { cc3_SetGLCap(GL_MATRIX_PALETTE_OES, onOff, valueCap_GL_MATRIX_PALETTE_OES, isKnownCap_GL_MATRIX_PALETTE_OES); }

-(void) enableMultisampling: (BOOL) onOff { cc3_SetGLCap(GL_MULTISAMPLE, onOff, valueCap_GL_MULTISAMPLE, isKnownCap_GL_MULTISAMPLE); }

-(void) enableNormalize: (BOOL) onOff { cc3_SetGLCap(GL_NORMALIZE, onOff, valueCap_GL_NORMALIZE, isKnownCap_GL_NORMALIZE); }

-(void) enablePointSmoothing: (BOOL) onOff { cc3_SetGLCap(GL_POINT_SMOOTH, onOff, valueCap_GL_POINT_SMOOTH, isKnownCap_GL_POINT_SMOOTH); }

-(void) enablePointSprites: (BOOL) onOff { cc3_SetGLCap(GL_POINT_SPRITE_OES, onOff, value_GL_POINT_SPRITE_OES, isKnownCap_GL_POINT_SPRITE_OES); }

-(void) enableRescaleNormal: (BOOL) onOff { cc3_SetGLCap(GL_RESCALE_NORMAL, onOff, valueCap_GL_RESCALE_NORMAL, isKnownCap_GL_RESCALE_NORMAL); }

-(void) enableSampleAlphaToOne: (BOOL) onOff { cc3_SetGLCap(GL_SAMPLE_ALPHA_TO_ONE, onOff, valueCap_GL_SAMPLE_ALPHA_TO_ONE, isKnownCap_GL_SAMPLE_ALPHA_TO_ONE); }


#pragma mark Vertex attribute arrays

-(GLint) vertexAttributeIndexForSemantic: (GLenum) semantic
							  withVisitor: (CC3NodeDrawingVisitor*) visitor {

	// Texture coordinate attribute arrays come first and are indexed by texture unit
	if (semantic == kCC3SemanticVertexTexture) return visitor.textureUnit;
	
	// Other vertex attributes come after and are compared by semantic
	for (GLuint vaIdx = value_GL_MAX_TEXTURE_UNITS; vaIdx < value_GL_MAX_VERTEX_ATTRIBS; vaIdx++)
		if (semantic == vertexAttributes[vaIdx].semantic) return vaIdx;

	// The semantic is not supported by OGLES 1.1 (eg- tangents & bitangents)
	return kCC3VertexAttributeIndexUnavailable;
}

-(void) setVertexAttributeEnablementAt: (GLint) vaIdx {
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	
	// If enabling texture coordinates, activate the appropriate texture unit first
	if (vaPtr->semantic == kCC3SemanticVertexTexture) [self activateClientTextureUnit: vaIdx];
	
	if (vaPtr->isEnabled)
		glEnableClientState(vaPtr->glName);
	else
		glDisableClientState(vaPtr->glName);
	LogGLErrorTrace(@"while enabling vertex attribute %@ at %i", NSStringFromGLEnum(vaPtr->glName), vaIdx);
}

-(void) bindVertexAttributesAt: (GLint) vaIdx {
	if (vaIdx < 0) return;
	CC3VertexAttr* vaPtr = &vertexAttributes[vaIdx];
	switch (vaPtr->semantic) {
		case kCC3SemanticVertexLocation:
			glVertexPointer(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"while binding vertex locations to size: %i, type: %@, stride: %i, content: %p",
							vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexNormal:
			glNormalPointer(vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"while binding vertex normals to type: %@, stride: %i, content: %p",
							vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexColor:
			glColorPointer(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"while binding vertex colors to size: %i, type: %@, stride: %i, content: %p",
							vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexWeights:
			glWeightPointerOES(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"while binding vertex weights to size: %i, type: %@, stride: %i, content: %p",
							vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexMatrixIndices:
			glMatrixIndexPointerOES(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"while binding vertex matrix indices to size: %i, type: %@, stride: %i, content: %p",
							vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexPointSize:
			glPointSizePointerOES(vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"while binding vertex point sizes to type: %@, stride: %i, content: %p",
							vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			break;
		case kCC3SemanticVertexTexture:
			[self activateClientTextureUnit: vaIdx];
			glTexCoordPointer(vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			LogGLErrorTrace(@"while binding vertex texture coordinates for texture unit %u to size: %i, type: %@, stride: %i, content: %p",
							vaIdx, vaPtr->elementSize, vaPtr->elementType, vaPtr->vertexStride, vaPtr->vertices);
			break;
		default:
			CC3Assert(NO, @"Semantic %@ is not a vertex attribute semantic.", NSStringFromCC3Semantic(vaPtr->semantic));
			break;
	}
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
	LogGLErrorTrace(@"while setting color to %@", NSStringFromCCC4F(color));
}

-(void) setPointSize: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_POINT_SIZE, isKnown_GL_POINT_SIZE);
	if ( !needsUpdate ) return;
	glPointSize(val);
	LogGLErrorTrace(@"while setting point size to %.3f", val);
}

-(void) setPointSizeAttenuation: (CC3AttenuationCoefficients) ac {
	cc3_CheckGLValue(ac, CC3AttenuationCoefficientsAreEqual(ac, value_GL_POINT_DISTANCE_ATTENUATION),
					 value_GL_POINT_DISTANCE_ATTENUATION, isKnown_GL_POINT_DISTANCE_ATTENUATION);
	if ( !needsUpdate ) return;
	glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION, (GLfloat*)&ac);
	LogGLErrorTrace(@"while setting point distance attenuation to %@", NSStringFromCC3AttenuationCoefficients(ac));
}

-(void) setPointSizeFadeThreshold: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_POINT_FADE_THRESHOLD_SIZE, isKnown_GL_POINT_FADE_THRESHOLD_SIZE);
	if ( !needsUpdate ) return;
	glPointParameterf(GL_POINT_FADE_THRESHOLD_SIZE, val);
	LogGLErrorTrace(@"while setting point fade threshold to %.3f", val);
}

-(void) setPointSizeMinimum: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_POINT_SIZE_MIN, isKnown_GL_POINT_SIZE_MIN);
	if ( !needsUpdate ) return;
	glPointParameterf(GL_POINT_SIZE_MIN, val);
	LogGLErrorTrace(@"while setting minimum point size to %.3f", val);
}

-(void) setPointSizeMaximum: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_POINT_SIZE_MAX, isKnown_GL_POINT_SIZE_MAX);
	if ( !needsUpdate ) return;
	glPointParameterf(GL_POINT_SIZE_MAX, val);
	LogGLErrorTrace(@"while setting maximum point size to %.3f", val);
}

-(void) setShadeModel: (GLenum) val {
	cc3_CheckGLPrim(val, value_GL_SHADE_MODEL, isKnown_GL_SHADE_MODEL);
	if ( !needsUpdate ) return;
	glShadeModel(val);
	LogGLErrorTrace(@"while setting shading model to %@", NSStringFromGLEnum(val));
}


#pragma mark Lighting

-(void) enableLighting: (BOOL) onOff { cc3_SetGLCap(GL_LIGHTING, onOff, valueCap_GL_LIGHTING, isKnownCap_GL_LIGHTING); }

-(void) setSceneAmbientLightColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, value_GL_LIGHT_MODEL_AMBIENT),
					 value_GL_LIGHT_MODEL_AMBIENT, isKnown_GL_LIGHT_MODEL_AMBIENT);
	if ( !needsUpdate ) return;
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, (GLfloat*)&color);
	LogGLErrorTrace(@"while setting scene ambient light color to %@", NSStringFromCCC4F(color));
}

-(void) enableLight: (BOOL) onOff at: (GLuint) ltIdx {
	CC3SetGLCapAt(GL_LIGHT0, ltIdx, onOff, &value_GL_LIGHT, &isKnownCap_GL_LIGHT);
}

-(void) setLightAmbientColor: (ccColor4F) color at: (GLuint) ltIdx {
	if (CC3CheckGLColorAt(ltIdx, color, valueLight_GL_AMBIENT, &isKnownLight_GL_AMBIENT)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_AMBIENT, (GLfloat*)&color);
		LogGLErrorTrace(@"while setting ambient color of light at %u to %@", ltIdx, NSStringFromCCC4F(color));
	}
}

-(void) setLightDiffuseColor: (ccColor4F) color at: (GLuint) ltIdx {
	if (CC3CheckGLColorAt(ltIdx, color, valueLight_GL_DIFFUSE, &isKnownLight_GL_DIFFUSE)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_DIFFUSE, (GLfloat*)&color);
		LogGLErrorTrace(@"while setting diffuse color of light at %u to %@", ltIdx, NSStringFromCCC4F(color));
	}
}

-(void) setLightSpecularColor: (ccColor4F) color at: (GLuint) ltIdx {
	if (CC3CheckGLColorAt(ltIdx, color, valueLight_GL_SPECULAR, &isKnownLight_GL_SPECULAR)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_SPECULAR, (GLfloat*)&color);
		LogGLErrorTrace(@"while setting specular color of light at %u to %@", ltIdx, NSStringFromCCC4F(color));
	}
}

-(void) setLightPosition: (CC3Vector4) pos at: (GLuint) ltIdx {
	if (CC3CheckGLVector4At(ltIdx, pos, valueLight_GL_POSITION, &isKnownLight_GL_POSITION)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_POSITION, (GLfloat*)&pos);
		LogGLErrorTrace(@"while setting position of light at %u to %@", ltIdx, NSStringFromCC3Vector4(pos));
	}
}

-(void) setLightAttenuation: (CC3AttenuationCoefficients) ac at: (GLuint) ltIdx {
	if (CC3CheckGLfloatAt(ltIdx, ac.a, valueLight_GL_CONSTANT_ATTENUATION, &isKnownLight_GL_CONSTANT_ATTENUATION)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_CONSTANT_ATTENUATION, ac.a);
		LogGLErrorTrace(@"while setting constant attenuation of light at %u to %.3f", ltIdx, ac.a);
	}
	if (CC3CheckGLfloatAt(ltIdx, ac.b, valueLight_GL_LINEAR_ATTENUATION, &isKnownLight_GL_LINEAR_ATTENUATION)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_LINEAR_ATTENUATION, ac.b);
		LogGLErrorTrace(@"while setting linear attenuation of light at %u to %.3f", ltIdx, ac.c);
	}
	if (CC3CheckGLfloatAt(ltIdx, ac.c, valueLight_GL_QUADRATIC_ATTENUATION, &isKnownLight_GL_QUADRATIC_ATTENUATION)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_QUADRATIC_ATTENUATION, ac.c);
		LogGLErrorTrace(@"while setting quadratic attenuation of light at %u to %.3f", ltIdx, ac.c);
	}
}

-(void) setSpotlightDirection: (CC3Vector) dir at: (GLuint) ltIdx {
	if (CC3CheckGLVectorAt(ltIdx, dir, valueLight_GL_SPOT_DIRECTION, &isKnownLight_GL_SPOT_DIRECTION)) {
		glLightfv((GL_LIGHT0 + ltIdx), GL_SPOT_DIRECTION, (GLfloat*)&dir);
		LogGLErrorTrace(@"while setting direction of spotlight at %u to %@", ltIdx, NSStringFromCC3Vector(dir));
	}
}

-(void) setSpotlightFadeExponent: (GLfloat) val at: (GLuint) ltIdx {
	if (CC3CheckGLfloatAt(ltIdx, val, valueLight_GL_SPOT_EXPONENT, &isKnownLight_GL_SPOT_EXPONENT)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_SPOT_EXPONENT, val);
		LogGLErrorTrace(@"while setting fade exponent of spotlight at %u to %.3f", ltIdx, val);
	}
}

-(void) setSpotlightCutoffAngle: (GLfloat) val at: (GLuint) ltIdx {
	if (CC3CheckGLfloatAt(ltIdx, val, valueLight_GL_SPOT_CUTOFF, &isKnownLight_GL_SPOT_CUTOFF)) {
		glLightf((GL_LIGHT0 + ltIdx), GL_SPOT_CUTOFF, val);
		LogGLErrorTrace(@"while setting cutoff angle of spotlight at %u to %.3f", ltIdx, val);
	}
}

-(void) setFogColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, value_GL_FOG_COLOR),
					 value_GL_FOG_COLOR, isKnown_GL_FOG_COLOR);
	if ( !needsUpdate ) return;
	glFogfv(GL_FOG_COLOR, (GLfloat*)&color);
	LogGLErrorTrace(@"while setting fog color to %@", NSStringFromCCC4F(color));
}

-(void) setFogMode: (GLenum) mode {
	cc3_CheckGLPrim(mode, value_GL_FOG_MODE, isKnown_GL_FOG_MODE);
	if ( !needsUpdate ) return;
	glFogx(GL_FOG_MODE, mode);
	LogGLErrorTrace(@"while setting fog density mode to %@", NSStringFromGLEnum(mode));
}

-(void) setFogDensity: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_FOG_DENSITY, isKnown_GL_FOG_DENSITY);
	if ( !needsUpdate ) return;
	glFogf(GL_FOG_DENSITY, val);
	LogGLErrorTrace(@"while setting fog density to %.3f", val);
}

-(void) setFogStart: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_FOG_START, isKnown_GL_FOG_START);
	if ( !needsUpdate ) return;
	glFogf(GL_FOG_START, val);
	LogGLErrorTrace(@"while setting fog start to %.3f", val);
}

-(void) setFogEnd: (GLfloat) val {
	cc3_CheckGLPrim(val, value_GL_FOG_END, isKnown_GL_FOG_END);
	if ( !needsUpdate ) return;
	glFogf(GL_FOG_END, val);
	LogGLErrorTrace(@"while setting fog end to %.3f", val);
}


#pragma mark Materials

-(void) setMaterialAmbientColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, valueMat_GL_AMBIENT),
					 valueMat_GL_AMBIENT, isKnownMat_GL_AMBIENT);
	if ( !needsUpdate ) return;
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, (GLfloat*)&color);
	LogGLErrorTrace(@"while setting ambient color of material to %@", NSStringFromCCC4F(color));
}

-(void) setMaterialDiffuseColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, valueMat_GL_DIFFUSE),
					 valueMat_GL_DIFFUSE, isKnownMat_GL_DIFFUSE);
	if ( !needsUpdate ) return;
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, (GLfloat*)&color);
	LogGLErrorTrace(@"while setting diffuse color of material to %@", NSStringFromCCC4F(color));
}

-(void) setMaterialSpecularColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, valueMat_GL_SPECULAR),
					 valueMat_GL_SPECULAR, isKnownMat_GL_SPECULAR);
	if ( !needsUpdate ) return;
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, (GLfloat*)&color);
	LogGLErrorTrace(@"while setting specular color of material to %@", NSStringFromCCC4F(color));
}

-(void) setMaterialEmissionColor: (ccColor4F) color {
	cc3_CheckGLValue(color, CCC4FAreEqual(color, valueMat_GL_EMISSION),
					 valueMat_GL_EMISSION, isKnownMat_GL_EMISSION);
	if ( !needsUpdate ) return;
	glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, (GLfloat*)&color);
	LogGLErrorTrace(@"while setting emission color of material to %@", NSStringFromCCC4F(color));
}

-(void) setMaterialShininess: (GLfloat) val {
	cc3_CheckGLPrim(val, valueMat_GL_SHININESS, isKnownMat_GL_SHININESS);
	if ( !needsUpdate ) return;
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, val);
	LogGLErrorTrace(@"while setting shininess of material to %.3f", val);
}

-(void) setAlphaFunc: (GLenum) func reference: (GLfloat) ref {
	if ((func != value_GL_ALPHA_TEST_FUNC) || (ref != value_GL_ALPHA_TEST_REF) || !isKnownAlphaFunc) {
		value_GL_ALPHA_TEST_FUNC = func;
		value_GL_ALPHA_TEST_REF = ref;
		isKnownAlphaFunc = YES;
		glAlphaFunc(func, ref);
		LogGLErrorTrace(@"while setting alpha function to %@ and reference to %.3f", NSStringFromGLEnum(func), ref);
	}
}


#pragma mark Textures

-(void) activateClientTextureUnit: (GLuint) tuIdx {
	cc3_CheckGLPrim(tuIdx, value_GL_CLIENT_ACTIVE_TEXTURE, isKnown_GL_CLIENT_ACTIVE_TEXTURE);
	if ( !needsUpdate ) return;
	glClientActiveTexture(GL_TEXTURE0 + tuIdx);
	LogGLErrorTrace(@"while setting active client texture unit to %u", tuIdx);
}

-(void) enableTexture2D: (BOOL) onOff at: (GLuint) tuIdx {
	if (CC3CheckGLBooleanAt(tuIdx, onOff, &value_GL_TEXTURE_2D, &isKnownCap_GL_TEXTURE_2D)) {
		[self activateTextureUnit: tuIdx];
		if (onOff)
			glEnable(GL_TEXTURE_2D);
		else
			glDisable(GL_TEXTURE_2D);
		LogGLErrorTrace(@"while %@abling capability %@ of texture unit %u", (onOff ? @"en" : @"dis"), NSStringFromGLEnum(GL_TEXTURE_2D), tuIdx);
	}
}

-(void) enableTextureCoordinates: (BOOL) onOff at: (GLuint) tuIdx {
	if (CC3CheckGLBooleanAt(tuIdx, onOff, &value_GL_TEXTURE_COORD_ARRAY, &isKnownCap_GL_TEXTURE_COORD_ARRAY)) {
		[self activateClientTextureUnit: tuIdx];
		if (onOff)
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		else
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		LogGLErrorTrace(@"while %@abling texture coordinates in texture unit %u", (onOff ? @"en" : @"dis"), tuIdx);
	}
}

-(void) enablePointSpriteCoordReplace: (BOOL) onOff at: (GLuint) tuIdx {
	if (CC3CheckGLBooleanAt(tuIdx, onOff, &value_GL_COORD_REPLACE_OES, &isKnownCap_GL_COORD_REPLACE_OES)) {
		[self activateTextureUnit: tuIdx];
		glTexEnvi(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, (onOff ? GL_TRUE : GL_FALSE));
		LogGLErrorTrace(@"while %@abling point sprite coordinate replace in texture unit %u", (onOff ? @"en" : @"dis"), tuIdx);
	}
}

-(void) setTextureEnvMode: (GLenum) mode at: (GLuint) tuIdx {
	if (CC3CheckGLuintAt(tuIdx, mode, values_GL_TEXTURE_ENV_MODE, &isKnown_GL_TEXTURE_ENV_MODE)) {
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, mode);
		LogGLErrorTrace(@"while setting environment mode of texture unit %u to %@", tuIdx, NSStringFromGLEnum(mode));
	}
}

-(void) setTextureEnvColor: (ccColor4F) color at: (GLuint) tuIdx {
	if (CC3CheckGLColorAt(tuIdx, color, values_GL_TEXTURE_ENV_COLOR, &isKnown_GL_TEXTURE_ENV_COLOR)) {
		glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, (GLfloat*)&color);
		LogGLErrorTrace(@"while setting constant color of texture unit %u to %@", tuIdx, NSStringFromCCC4F(color));
	}
}


#pragma mark Matrices

-(void) activateMatrixStack: (GLenum) mode {
	cc3_CheckGLPrim(mode, value_GL_MATRIX_MODE, isKnown_GL_MATRIX_MODE);
	if ( !needsUpdate ) return;
	glMatrixMode(mode);
	LogGLErrorTrace(@"while setting active matrix stack to %@", NSStringFromGLEnum(mode));
}

-(void) activatePaletteMatrixStack: (GLuint) pmIdx {
	CC3Assert(pmIdx < value_GL_MAX_PALETTE_MATRICES, @"The palette index %u exceeds the maximum number of"
			  @" %u palette matrices available on this platform", pmIdx, value_GL_MAX_PALETTE_MATRICES);
	[self activateMatrixStack: GL_MATRIX_PALETTE_OES];
	cc3_CheckGLPrim(pmIdx, value_GL_MATRIX_PALETTE_OES, isKnown_GL_MATRIX_PALETTE_OES);
	if ( !needsUpdate ) return;
	glCurrentPaletteMatrixOES(pmIdx);
	LogGLErrorTrace(@"while setting active palette matrix to %u", pmIdx);
}

-(void) loadModelviewMatrix: (CC3Matrix4x3*) mtx {
	[self activateMatrixStack: GL_MODELVIEW];
	CC3Matrix4x4 glMtx;
	CC3Matrix4x4PopulateFrom4x3(&glMtx, mtx);
	glLoadMatrixf(glMtx.elements);
	LogGLErrorTrace(@"while loading modelview matrix from %@", NSStringFromCC3Matrix4x4(&glMtx));
}

-(void) loadProjectionMatrix: (CC3Matrix4x4*) mtx {
	[self activateMatrixStack: GL_PROJECTION];
	glLoadMatrixf(mtx->elements);
	LogGLErrorTrace(@"while loading projection matrix from %@", NSStringFromCC3Matrix4x4(mtx));
}

-(void) loadPaletteMatrix: (CC3Matrix4x3*) mtx at: (GLuint) pmIdx {
	[self activatePaletteMatrixStack: pmIdx];
	CC3Matrix4x4 glMtx;
	CC3Matrix4x4PopulateFrom4x3(&glMtx, mtx);
	glLoadMatrixf(glMtx.elements);
	LogGLErrorTrace(@"while loading palette matrix %u from %@", pmIdx, NSStringFromCC3Matrix4x4(&glMtx));
}

-(void) pushModelviewMatrixStack {
	[self activateMatrixStack: GL_MODELVIEW];
	glPushMatrix();
	LogGLErrorTrace(@"while pushing modelview matrix stack");
}

-(void) popModelviewMatrixStack {
	[self activateMatrixStack: GL_MODELVIEW];
	glPopMatrix();
	LogGLErrorTrace(@"while popping modelview matrix stack");
}

-(void) pushProjectionMatrixStack {
	[self activateMatrixStack: GL_PROJECTION];
	glPushMatrix();
	LogGLErrorTrace(@"while pushing projection matrix stack");
}

-(void) popProjectionMatrixStack {
	[self activateMatrixStack: GL_PROJECTION];
	glPopMatrix();
	LogGLErrorTrace(@"while popping projection matrix stack");
}


#pragma mark Hints

-(void) setFogHint: (GLenum) hint {
	cc3_CheckGLPrim(hint, value_GL_FOG_HINT, isKnown_GL_FOG_HINT);
	if ( !needsUpdate ) return;
	glHint(GL_FOG_HINT, hint);
	LogGLErrorTrace(@"while setting fog hint to %@", NSStringFromGLEnum(hint));
}

-(void) setLineSmoothingHint: (GLenum) hint {
	cc3_CheckGLPrim(hint, value_GL_LINE_SMOOTH_HINT, isKnown_GL_LINE_SMOOTH_HINT);
	if ( !needsUpdate ) return;
	glHint(GL_LINE_SMOOTH_HINT, hint);
	LogGLErrorTrace(@"while setting line smoothing hint to %@", NSStringFromGLEnum(hint));
}

-(void) setPerspectiveCorrectionHint: (GLenum) hint {
	cc3_CheckGLPrim(hint, value_GL_PERSPECTIVE_CORRECTION_HINT, isKnown_GL_PERSPECTIVE_CORRECTION_HINT);
	if ( !needsUpdate ) return;
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, hint);
	LogGLErrorTrace(@"while setting perspective correction hint to %@", NSStringFromGLEnum(hint));
}

-(void) setPointSmoothingHint: (GLenum) hint {
	cc3_CheckGLPrim(hint, value_GL_POINT_SMOOTH_HINT, isKnown_GL_POINT_SMOOTH_HINT);
	if ( !needsUpdate ) return;
	glHint(GL_POINT_SMOOTH_HINT, hint);
	LogGLErrorTrace(@"while setting point smoothing hint to %@", NSStringFromGLEnum(hint));
}


#pragma mark Aligning 2D & 3D caches

-(void) align3DStateCache {
	[super align3DStateCache];
	
	isKnownCap_GL_LIGHT = NO;
	isKnown_GL_CURRENT_COLOR = NO;
}


#pragma mark Allocation and initialization

-(id) init {
	if ( (self = [super init]) ) {

	}
	return self;
}

/** */
-(void) initPlatformLimits {
	glGetIntegerv(GL_MAX_CLIP_PLANES, &value_GL_MAX_CLIP_PLANES);
	LogGLErrorTrace(@"while getting platform limit for %@", NSStringFromGLEnum(GL_MAX_CLIP_PLANES));
	LogInfo(@"Maximum clip planes: %u", value_GL_MAX_CLIP_PLANES);

	glGetIntegerv(GL_MAX_LIGHTS, &value_GL_MAX_LIGHTS);
	LogGLErrorTrace(@"while getting platform limit for %@", NSStringFromGLEnum(GL_MAX_LIGHTS));
	LogInfo(@"Maximum lights: %u", value_GL_MAX_LIGHTS);

	glGetIntegerv(GL_MAX_PALETTE_MATRICES_OES, &value_GL_MAX_PALETTE_MATRICES);
	LogGLErrorTrace(@"while getting platform limit for %@", NSStringFromGLEnum(GL_MAX_PALETTE_MATRICES_OES));
	LogInfo(@"Maximum palette matrices (max bones per mesh): %u", value_GL_MAX_PALETTE_MATRICES);
	
	glGetIntegerv(GL_MAX_SAMPLES_APPLE, &value_GL_MAX_SAMPLES);
	LogGLErrorTrace(@"while getting platform limit for %@", NSStringFromGLEnum(GL_MAX_SAMPLES_APPLE));
	LogInfo(@"Maximum anti-aliasing samples: %u", value_GL_MAX_SAMPLES);
	
	glGetIntegerv(GL_MAX_TEXTURE_UNITS, &value_GL_MAX_TEXTURE_UNITS);
	LogGLErrorTrace(@"while getting platform limit for %@", NSStringFromGLEnum(GL_MAX_TEXTURE_UNITS));
	LogInfo(@"Maximum texture units: %u", value_GL_MAX_TEXTURE_UNITS);

	// Initial estimate for allocating space. The actual value is set by the initVertexAttributes method.
	value_GL_MAX_VERTEX_ATTRIBS = value_GL_MAX_TEXTURE_UNITS + kMAX_VTX_ATTRS_EX_TEXCOORD;

	glGetIntegerv(GL_MAX_VERTEX_UNITS_OES, &value_GL_MAX_VERTEX_UNITS);
	LogGLErrorTrace(@"while getting platform limit for %@", NSStringFromGLEnum(GL_MAX_VERTEX_UNITS_OES));
	LogInfo(@"Available anti-aliasing samples: %u", value_GL_MAX_VERTEX_UNITS);
}

/**
 * Under OGLES 1.1, the vertex attribute arrays each have a fixed purpose. Invokes super
 * to allocate the trackers, and then initializes the semantic and GL name of each. Texture
 * coordinate arrays come first, followed by the other vertex attribute arrays.
 *
 * This method also updates the value_GL_MAX_VERTEX_ATTRIBS property.
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
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexWeights;
	vertexAttributes[vaIdx].glName = GL_WEIGHT_ARRAY_OES;
	vaIdx++;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexMatrixIndices;
	vertexAttributes[vaIdx].glName = GL_MATRIX_INDEX_ARRAY_OES;
	vaIdx++;
	
	vertexAttributes[vaIdx].semantic = kCC3SemanticVertexPointSize;
	vertexAttributes[vaIdx].glName = GL_POINT_SIZE_ARRAY_OES;
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

#endif
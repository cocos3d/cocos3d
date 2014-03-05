/*
 * CC3OpenGLES2.m
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
 * See header file CC3OpenGLES2.h for full API documentation.
 */

#import "CC3OpenGLES2.h"

#if CC3_OGLES_2

@interface CC3OpenGL (TemplateMethods)
-(void) initPlatformLimits;
-(void) initSurfaces;
-(void) bindFramebuffer: (GLuint) fbID toTarget: (GLenum) fbTarget;
@end


#pragma mark CC3OpenGLES2

@implementation CC3OpenGLES2


#pragma mark Textures

-(void) disableTexturingAt: (GLuint) tuIdx {
	[self enableTexturing: NO inTarget: GL_TEXTURE_2D at: tuIdx];
	[self bindTexture: 0 toTarget: GL_TEXTURE_2D at: tuIdx];
	[self enableTexturing: NO inTarget: GL_TEXTURE_CUBE_MAP at: tuIdx];
	[self bindTexture: 0 toTarget: GL_TEXTURE_CUBE_MAP at: tuIdx];
}


#pragma mark Framebuffers

-(void) resolveMultisampleFramebuffer: (GLuint) fbSrcID intoFramebuffer: (GLuint) fbDstID {
	[self bindFramebuffer: fbSrcID toTarget: GL_READ_FRAMEBUFFER_APPLE];
	[self bindFramebuffer: fbDstID toTarget: GL_DRAW_FRAMEBUFFER_APPLE];
	glResolveMultisampleFramebufferAPPLE();
	LogGLErrorTrace(@"glResolveMultisampleFramebufferAPPLE()");
	[self bindFramebuffer: fbSrcID toTarget: GL_FRAMEBUFFER];
}

-(void) discard: (GLsizei) count attachments: (const GLenum*) attachments fromFramebuffer: (GLuint) fbID {
	[self bindFramebuffer: fbID];
	glDiscardFramebufferEXT(GL_FRAMEBUFFER, count, attachments);
	LogGLErrorTrace(@"glDiscardFramebufferEXT(%@. %i, %@, %@, %@)",
					NSStringFromGLEnum(GL_FRAMEBUFFER), count,
					NSStringFromGLEnum(count > 0 ? attachments[0] : 0),
					NSStringFromGLEnum(count > 1 ? attachments[1] : 0),
					NSStringFromGLEnum(count > 2 ? attachments[2] : 0));
}

-(void) allocateStorageForRenderbuffer: (GLuint) rbID
							  withSize: (CC3IntSize) size
							 andFormat: (GLenum) format
							andSamples: (GLuint) pixelSamples {
	[self bindRenderbuffer: rbID];
	if (pixelSamples > 1) {
		glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, pixelSamples, format, size.width, size.height);
		LogGLErrorTrace(@"glRenderbufferStorageMultisampleAPPLE(%@, %i, %@, %i, %i)",
						NSStringFromGLEnum(GL_RENDERBUFFER), pixelSamples,
						NSStringFromGLEnum(format), size.width, size.height);
	} else {
		glRenderbufferStorage(GL_RENDERBUFFER, format, size.width, size.height);
		LogGLErrorTrace(@"glRenderbufferStorage(%@, %@, %i, %i)", NSStringFromGLEnum(GL_RENDERBUFFER),
						NSStringFromGLEnum(format), size.width, size.height);
	}
}


#pragma mark Shaders

-(NSString*) defaultShaderPreamble {
#if APPORTABLE
	return
		@"#define CC3_PLATFORM_IOS 0\n"
		@"#define CC3_PLATFORM_OSX 0\n"
		@"#define CC3_PLATFORM_ANDROID 1\n";
#else
	return
		@"#define CC3_PLATFORM_IOS 1\n"
		@"#define CC3_PLATFORM_OSX 0\n"
		@"#define CC3_PLATFORM_ANDROID 0\n";
#endif	// APPORTABLE
}

-(void) releaseShaderCompiler {
	glReleaseShaderCompiler();
	LogGLErrorTrace(@"glReleaseShaderCompiler()");
}

#pragma mark Platform limits & info


-(GLfloat) vertexShaderVarRangeMin: (GLenum) precisionType {
	return value_Vertex_Shader_Precision[precisionType - GL_LOW_FLOAT].x;
}

-(GLfloat) vertexShaderVarRangeMax: (GLenum) precisionType {
	return value_Vertex_Shader_Precision[precisionType - GL_LOW_FLOAT].y;
}

-(GLfloat) vertexShaderVarPrecision: (GLenum) precisionType {
	return value_Vertex_Shader_Precision[precisionType - GL_LOW_FLOAT].z;
}

-(GLfloat) fragmentShaderVarRangeMin: (GLenum) precisionType {
	return value_Fragment_Shader_Precision[precisionType - GL_LOW_FLOAT].x;
}

-(GLfloat) fragmentShaderVarRangeMax: (GLenum) precisionType {
	return value_Fragment_Shader_Precision[precisionType - GL_LOW_FLOAT].y;
}

-(GLfloat) fragmentShaderVarPrecision: (GLenum) precisionType {
	return value_Fragment_Shader_Precision[precisionType - GL_LOW_FLOAT].z;
}


#pragma mark Allocation and initialization

-(CC3GLContext*) makeRenderingGLContext {
	CC3GLContext* context = [[CC3GLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2 sharegroup: nil];
	CC3Assert(context, @"Could not create CC3GLContext. OpenGL ES 2.0 is required.");
	return [context autorelease];
}

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	value_GL_MAX_VERTEX_UNIFORM_VECTORS = [self getInteger: GL_MAX_VERTEX_UNIFORM_VECTORS];
	LogInfoIfPrimary(@"Maximum GLSL uniform vectors per vertex shader: %u", value_GL_MAX_VERTEX_UNIFORM_VECTORS);
	
	value_GL_MAX_FRAGMENT_UNIFORM_VECTORS = [self getInteger: GL_MAX_FRAGMENT_UNIFORM_VECTORS];
	LogInfoIfPrimary(@"Maximum GLSL uniform vectors per fragment shader: %u", value_GL_MAX_FRAGMENT_UNIFORM_VECTORS);
	
	value_GL_MAX_VARYING_VECTORS = [self getInteger: GL_MAX_VARYING_VECTORS];
	LogInfoIfPrimary(@"Maximum GLSL varying vectors per shader program: %u", value_GL_MAX_VARYING_VECTORS);

	[self initShaderPrecisions];
	
	value_GL_MAX_CUBE_MAP_TEXTURE_SIZE = [self getInteger: GL_MAX_CUBE_MAP_TEXTURE_SIZE];
	LogInfoIfPrimary(@"Maximum cube map texture size: %u", value_GL_MAX_CUBE_MAP_TEXTURE_SIZE);
}

-(void) initShaderPrecisions {
	value_Vertex_Shader_Precision[0] = [self getShaderPrecision: GL_LOW_FLOAT forShader:GL_VERTEX_SHADER];
	value_Vertex_Shader_Precision[1] = [self getShaderPrecision: GL_MEDIUM_FLOAT forShader:GL_VERTEX_SHADER];
	value_Vertex_Shader_Precision[2] = [self getShaderPrecision: GL_HIGH_FLOAT forShader:GL_VERTEX_SHADER];
	value_Vertex_Shader_Precision[3] = [self getShaderPrecision: GL_LOW_INT forShader:GL_VERTEX_SHADER];
	value_Vertex_Shader_Precision[4] = [self getShaderPrecision: GL_MEDIUM_INT forShader:GL_VERTEX_SHADER];
	value_Vertex_Shader_Precision[5] = [self getShaderPrecision: GL_HIGH_INT forShader:GL_VERTEX_SHADER];
	
	value_Fragment_Shader_Precision[0] = [self getShaderPrecision: GL_LOW_FLOAT forShader:GL_FRAGMENT_SHADER];
	value_Fragment_Shader_Precision[1] = [self getShaderPrecision: GL_MEDIUM_FLOAT forShader:GL_FRAGMENT_SHADER];
	value_Fragment_Shader_Precision[2] = [self getShaderPrecision: GL_HIGH_FLOAT forShader:GL_FRAGMENT_SHADER];
	value_Fragment_Shader_Precision[3] = [self getShaderPrecision: GL_LOW_INT forShader:GL_FRAGMENT_SHADER];
	value_Fragment_Shader_Precision[4] = [self getShaderPrecision: GL_MEDIUM_INT forShader:GL_FRAGMENT_SHADER];
	value_Fragment_Shader_Precision[5] = [self getShaderPrecision: GL_HIGH_INT forShader:GL_FRAGMENT_SHADER];
}

-(CC3Vector) getShaderPrecision: (GLenum) precisionType forShader: (GLenum) shaderType {
	CC3Vector precision;
	CC3IntVector logPrecision;
	
	glGetShaderPrecisionFormat(shaderType, precisionType, &logPrecision.x, &logPrecision.z);
	LogGLErrorTrace(@"glGetShaderPrecisionFormat(%@, %@, %i, %i, %i)",
					NSStringFromGLEnum(shaderType), NSStringFromGLEnum(precisionType),
					logPrecision.x, logPrecision.y, logPrecision.z);
	
	switch (precisionType) {
		case GL_LOW_FLOAT:
			logPrecision.x = logPrecision.z;	// Returns 0 - but seems to be +/- 0-1 range, so use precision instead
			precision.x = powf(2.0, -logPrecision.x);
			precision.y = powf(2.0, logPrecision.y);
			precision.z = powf(2.0, -logPrecision.z);
			[self logShader: shaderType  forQualifier: @"lowp" floatPrecision: precision logPrecision: logPrecision];
			break;
		case GL_MEDIUM_FLOAT:
			precision.x = powf(2.0, -logPrecision.x);
			precision.y = powf(2.0, logPrecision.y);
			precision.z = powf(2.0, -logPrecision.z);
			[self logShader: shaderType  forQualifier: @"mediump" floatPrecision: precision logPrecision: logPrecision];
			break;
		case GL_HIGH_FLOAT:
			precision.x = powf(2.0, -logPrecision.x);
			precision.y = powf(2.0, logPrecision.y);
			precision.z = powf(2.0, -logPrecision.z);
			[self logShader: shaderType  forQualifier: @"highp" floatPrecision: precision logPrecision: logPrecision];
			break;
		case GL_LOW_INT:
			precision.x = -1 << logPrecision.x;
			precision.y =  1 << logPrecision.y;
			precision.z = 1.0;
			[self logShader: shaderType  forQualifier: @"lowp" intPrecision: precision logPrecision: logPrecision];
			break;
		case GL_MEDIUM_INT:
			precision.x = -1 << logPrecision.x;
			precision.y =  1 << logPrecision.y;
			precision.z = 1.0;
			[self logShader: shaderType  forQualifier: @"mediump" intPrecision: precision logPrecision: logPrecision];
			break;
		case GL_HIGH_INT:
			precision.x = -1 << logPrecision.x;
			precision.y =  1 << logPrecision.y;
			precision.z = 1.0;
			[self logShader: shaderType  forQualifier: @"highp" intPrecision: precision logPrecision: logPrecision];
			break;
		default:
			LogError(@"Unexpected shader precision: %@", NSStringFromGLEnum(precisionType));
			break;
	}
	
	return precision;
}

-(void) logShader: (GLenum) shaderType
	 forQualifier: (NSString*) qualifier
   floatPrecision: (CC3Vector) precision
	 logPrecision: (CC3IntVector) logPrecision {
	LogInfoIfPrimary(@"Range of %@ shader %@ float: (min: (+/-)%g, max: (+/-)%g, precision: %g) log2: %@",
					 ((shaderType == GL_VERTEX_SHADER) ? @"vertex" : @"fragment"),
					 qualifier, precision.x, precision.y, precision.z,
					 NSStringFromCC3IntVector(logPrecision));
}

-(void) logShader: (GLenum) shaderType
	 forQualifier: (NSString*) qualifier
	 intPrecision: (CC3Vector) precision
	 logPrecision: (CC3IntVector) logPrecision {
	LogInfoIfPrimary(@"Range of %@ shader %@ int: (min: %i, max: %i, precision: %i) log2: %@",
					 ((shaderType == GL_VERTEX_SHADER) ? @"vertex" : @"fragment"),
					 qualifier, (GLint)precision.x, (GLint)precision.y, (GLint)precision.z,
					 NSStringFromCC3IntVector(logPrecision));
}

@end


#pragma mark CC3OpenGLES2IOS

@implementation CC3OpenGLES2IOS

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	value_GL_MAX_SAMPLES = [self getInteger: GL_MAX_SAMPLES_APPLE];
	LogInfoIfPrimary(@"Maximum anti-aliasing samples: %u", value_GL_MAX_SAMPLES);
}

@end


#pragma mark CC3OpenGLES2Android

@implementation CC3OpenGLES2Android

-(void) initPlatformLimits {
	[super initPlatformLimits];
	
	value_GL_MAX_SAMPLES = 1;
	LogInfoIfPrimary(@"Maximum anti-aliasing samples: %u", value_GL_MAX_SAMPLES);
}

-(void) initSurfaces {
	[super initSurfaces];
	
	// Under Android, the on-screen surface is hardwired to framebuffer 0 and renderbuffer 0.
	// Apportable assumes that the first allocation of each is for the on-screen surface, and
	// therefore ignores that first allocation. We force that ignored allocation here, so that
	// off-screen surfaces can be allocated before the primary on-screen surface.
	[self generateRenderbuffer];
	[self generateFramebuffer];
}

@end

#endif	// CC3_OGLES_2
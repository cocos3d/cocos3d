/*
 * CC3TexturableBones.vsh
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
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

/**
 * This vertex shader provides a general shader for covering a mesh with a material.
 *
 * This shader supports the following features:
 *   - Up to two textures
 *   - Realistic interaction with up to four lights
 *   - Positional, directional, or spot lighting with attenuation.
 *   - Vertex skinning (bone rigged characters) using bone matrices to handle both rigid
 *     and non-rigid skeletons.
 *   - Tangent-space or object-space bump-mapping.
 *   - Environmental reflection mapping using a cube-mapped texture (in addition to the 2 visible textures).
 *
 * This vertex shader can be paired with the following fragment shaders:
 *   - CC3NoTexture.fsh
 *   - CC3NoTextureAlphaTest.fsh
 *   - CC3NoTextureReflect.fsh
 *   - CC3NoTextureReflectAlphaTest.fsh
 *   - CC3SingleTexture.fsh
 *   - CC3SingleTextureAlphaTest.fsh
 *   - CC3SingleTextureReflect.fsh
 *   - CC3SingleTextureReflectAlphaTest.fsh
 *   - CC3BumpMapObjectSpace.fsh
 *   - CC3BumpMapObjectSpaceAlphaTest.fsh
 *   - CC3BumpMapTangentSpace.fsh
 *   - CC3BumpMapTangentSpaceAlphaTest.fsh
 *   - CC3PureColor.fsh (for node picking from touches)
 *
 * The semantics of the variables in this shader can be mapped using a
 * CC3ShaderSemanticsByVarName instance.
 */

#import "CC3LibDefaultPrecision.vsh"
#import "CC3LibVertexPositionBones.vsh"				// Vertex positioning
#import "CC3LibIlluminatedMaterial.vsh"				// Materials and lighting
#import "CC3LibBumpMapTangentSpaceLighting.vsh"		// Tangent-space bump-mapping
#import "CC3LibEnvironmentReflection.vsh"			// Environmental reflections
#import "CC3LibDoubleTexture.vsh"					// Textures

void main() {
	positionVertex();
	paintVertex();
	setBumpMapTangentSpaceLightDirection();
	textureVertex();
	reflectVertex();
}


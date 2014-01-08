/*
 * CC3LibTexturableBumpMapObjectSpace.fsh
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
 * This fragment shader library performs tangent-space bump-mapping.
 *
 * The texture in texture unit 0 contains a map of tangent-space normals, encoded in the
 * texel RGB colors.
 *
 * An optional second texture in texture unit 1 contains the visible texture to be applied on
 * top of the bump-mapped texture. If this texture is not available, the fragment color is used.
 *
 * This library requires the following varying variables be declared and populated in the vertex shader:
 *   - varying vec2			v_texCoord0;			// Fragment texture coordinates for texture unit 0.
 *   - varying vec2			v_texCoord1;			// Fragment texture coordinates for texture unit 1.
 *   - varying vec3			v_bumpMapLightDir;		// Direction to the first light in tangent space.
 *
 * This library requires the following local variables be declared and populated outside this library:
 *   - lowp vec4			fragColor;				// The fragment color
 *
 * This library declares and uses the following attribute and uniform variables:
 *   - uniform lowp int		u_cc3TextureCount;		// Number of textures.
 *   - uniform sampler2D	s_cc3Textures[];		// Texture samplers.
 */


// Increase this if more textures are desired.
#define MAX_TEXTURES			2

uniform lowp int	u_cc3TextureCount;				/**< Number of textures. */
uniform sampler2D	s_cc3Textures[MAX_TEXTURES];	/**< Texture samplers. */

varying vec2		v_texCoord0;					/**< Fragment texture coordinates for texture unit 0. */
varying vec2		v_texCoord1;					/**< Fragment texture coordinates for texture unit 1. */
varying vec3		v_bumpMapLightDir;				/**< Direction to the first light in tangent space. */

/**
 * Returns the texel modulation from the normal retrieved from the bump map texture. Transforms
 * the normal from range [0, 1] to [-1, 1], takes dot product with light direction for interaction
 * between normal and light vector, and returns the result.
 */
float bumpMapModulation(vec4 texNormal) {
	return 2.0 * dot((texNormal.xyz - 0.5), v_bumpMapLightDir);
}

/** 
 * Applies the bump-map in the first texture to the fragment, then, 
 * if there is a second texture, it is also applied to the fragment.
 */
void applyBumpMap() {
	fragColor.rgb *= bumpMapModulation(texture2D(s_cc3Textures[0], v_texCoord0));
	if (u_cc3TextureCount > 1) fragColor *= texture2D(s_cc3Textures[1], v_texCoord1);
}

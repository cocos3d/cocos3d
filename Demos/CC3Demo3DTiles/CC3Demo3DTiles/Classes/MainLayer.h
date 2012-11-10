/*
 * MainLayer.h
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
 */


#import "cocos2d.h"
#import "CC3Layer.h"
#import "CCNodeAdornments.h"

/**
 * MainLayer covers the whole screen. Within this layer, the user can add
 * or remove a square grid of CC3Layers, by clicking buttons to increase
 * or decrease the number of CC3Layers.
 *
 * Each CC3Layer contains a separate 3D scene. Each 3D scene contains a separate
 * camera and light, and so can be controlled independently. The light is
 * positioned differently in each little scene.
 *
 * Each scene contains a single main object. The object is chosen randomly, from
 * a collection of templates, so each 3D scene contains a different object. The
 * overall effect is a grid of tiles, with each tile displaying a single 3D object.
 *
 * Within each little 3D scene, the user can touch the main object and then move
 * a finger to rotate the object. When the user raises the finger, the 3D object
 * briefly glows, demonstrating touch selection and control when multiple separate
 * 3D scenes are displayed.
 *
 * As demonstrated by the touch control, the object in each tile scene is a separate
 * CC3MeshNode, and can be controlled independently of similar objects in other
 * tiles. But since each of these objects is created from a template copy, there
 * is only one copy of the underlying mesh data, thereby preserving memory.
 *
 * When drawing this main layer, each 3D layer and scene must be visited to be
 * drawn. There are several techniques that can be used to optimize performance
 * under these conditions.
 *
 * Of prime importance is reducing the number of times the color and depth buffers
 * are cleared by each 3D scene. By default, the depth buffer is cleared on every
 * transition between the 2D and 3D scenes, to ensure that the 2D and 3D artifacts
 * draw in the order expected.
 *
 * For many app configurations, this is not really needed. Here, we turn off depth
 * testing in the 2D scene, so that any 2D nodes will be drawn over the 3D scene.
 * We also tell the 3D scene not to clear the depth buffer between each transition
 * between 2D and 3D. Except in the most complicated situations, this should be
 * suitable for most apps.
 */
@interface MainLayer : CCLayer {
	CCMenuItem* increaseNodesMI;
	CCMenuItem* decreaseNodesMI;
	CCLabelTTF *label;
	NSMutableArray* tiles;
	NSMutableArray* templates;
	uint tilesPerSide;
}

@end

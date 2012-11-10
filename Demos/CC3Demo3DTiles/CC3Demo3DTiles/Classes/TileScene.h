/*
 * TileScene.h
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

#import "CC3Scene.h"

/**
 * A CC3Scene that is specialized to display only a single main node, and is
 * optimized so that many TileScenes can be displayed on the screen simultaneouly.
 *
 * Each tile scene contains its own camera and lamp, so that different perspectives
 * and lighting conditions can be applied to each TileScene.
 * 
 * To simplify using this scene with different main objects, the camera automatically
 * focuses on and frames the main object when the scene first opens up.
 *
 * Each TileScene supports touch events. The main node can be rotated by dragging
 * a finger across the tile. In addition, when the finger is lifted, if it is
 * touching the main node when released, the main node will briefly glow. This
 * demonstrates the ability to select nodes from touches across multiple 3D scenes.
 *
 * In addition, some nodes should be colored and others not. This is enabled by
 * adding a new property to CC3Node through an extention category. This extension
 * property makes use of the userData property available to all subclasses of
 * CC3Identifiable. This demonstrates the use of the userData property to avoid
 * having to create customized subclasses of CC3Node to add state data to 3D
 * artifacts.
 */
@interface TileScene : CC3Scene {
    CC3Node* mainNode;
	CGPoint lastTouchEventPoint;
}

/** Each TileScene displays a single, main node. */
@property(nonatomic, assign) CC3Node* mainNode;

@end


/**
 * Adds an extension category to CC3Node to add a property that indicates whether
 * this node should be colored. The value of this property is held in memory
 * pointed to by the userData property.
 */
@interface CC3Node (TilesUserData)

/** Indicates whether this node should be colored when it is added to the tile. */
@property(nonatomic, assign) BOOL shouldColorTile;

@end
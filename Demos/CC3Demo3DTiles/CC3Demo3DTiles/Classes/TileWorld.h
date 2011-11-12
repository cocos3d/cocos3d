/*
 * TileWorld.h
 *
 * cocos3d 0.6.3
 * Author: Bill Hollings
 * Copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
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

#import "CC3World.h"

/**
 * A CC3World that is specialized to display only a single main node, and is
 * optimized so that many TileWorlds can be displayed on the screen simultaneouly.
 *
 * Each tile world contains its own camera and lamp, so that different perspectives
 * and lighting conditions can be applied to each TileWorld.
 * 
 * To simplify using this world with different main objects, the camera can be
 * instructed to automatically focus on and frame the main object using the
 * frameMainNode method.
 *
 * Each TileWorld supports touch events. The main node can be rotated by dragging
 * a finger across the tile. In addition, when the finger is lifted, if it is
 * touching the main node when released, the main node will briefly glow. This
 * demonstrates the ability to select nodes from touches across multiple 3D worlds.
 *
 * In addition, some nodes should be colored and others not. This is enabled by
 * adding a new property to CC3Node through an extention category. This extension
 * property makes use of the userData property available to all subclasses of
 * CC3Identifiable. This demonstrates the use of the userData property to avoid
 * having to create customized subclasses of CC3Node to add state data to 3D
 * artifacts.
 */
@interface TileWorld : CC3World {
    CC3Node* mainNode;
	CGPoint lastTouchEventPoint;
}

/** Each TileWorld displays a single, main node. */
@property(nonatomic, assign) CC3Node* mainNode;

/**
 * Force the camera to orient itself so that it faces directly at the main node, and
 * positions itself so that the main node is framed within the camera's field of view.
 *
 * This implementation invokes the play method as well, to ensure that the world is
 * in an updated state before attempting to move the camera.
 *
 * This method should only be invoked AFTER this world has been added set in its CC3Layer.
 */
-(void) frameMainNode;

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
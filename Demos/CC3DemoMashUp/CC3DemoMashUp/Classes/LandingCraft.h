/*
 * LandingCraft.h
 *
 * cocos3d 0.6.3
 * Author: Bill Hollings
 * Copyright (c) 2011 The Brenwill Workshop Ltd. All rights reserved.
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


#import "CC3Node.h"
#import "CCActionManager.h"


/**
 * LandingCraft is a specialized node that creates and holds an army of other nodes, based on
 * a template node that is repeatedly copied, and the copies are distributed around the scene.
 */
@interface LandingCraft : CC3Node

/**
 * Creates many copies of the specified template node, and places them around the world.
 * Each of the copies is independently animated at different speeds using CCActionIntervals,
 * to demonstrate the individuality of nodes, even though they share the same mesh data.
 *
 * The landing motion rains the invading nodes down from the sky, again using CCActionIntervals.
 * These actions are also independently timed so that the invading nodes drop randomly like rain.
 */
-(void) populateArmyWith: (CC3Node*) templateNode;

/** Removes the invasion army by fading them away and then removing them from the world. */
-(void) evaporate;
	
@end


/**
 * Category extention to the CCActionManager class to extract the total number of CCActions
 * that are currently running. This is just used to log that number, to demonstrate that
 * the multitude of CCActions are being cleaned up properly when the invading army is removed.
 */
@interface CCActionManager (LandingCraft)

/** The total number of currently running actions. */
-(uint) numberOfRunningActions;

@end

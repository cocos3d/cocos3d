/*
 * CC3Cache.h
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
 */

/** @file */	// Doxygen marker

#import "CC3Foundation.h"
#import "CC3OSExtensions.h"
#import <pthread.h>


#pragma mark CC3Cacheable

/**
 * Defines the behaviour required for an object that can be held in a cache.
 *
 * Within a cache, objects are stored and retrieved by name. A cache uses the cacheable
 * object's name property to extract the name under which the object will be identified
 * within the cache. Each object must have a unique name.
 */
@protocol CC3Cacheable <CC3Object>

/** A unique name to be used by the cache to store and retrieve this object. */
@property(nonatomic, retain, readonly) NSString* name;

@end


#pragma mark CC3Cache

/**
 * Instances of CC3Cache hold cachable objects, which are stored and retrieved by name.
 *
 * Objects must implement the CC3Cacheable protocol to be stored in the cache. Objects in
 * the cache must have a unique name. An assertion error will be raised if an object with
 * the same name exists in the cache already. To replace an object in the cache, you must
 * first remove the existing object from the cache.
 *
 * CC3Cache implements the NSLocking protocol, and all access to the cache contents is thread-safe.
 *
 * Each object may be held either strongly or weakly by this cache, depending on the value
 * of the isWeak property at the time the object was added to the cache.
 */
@interface CC3Cache : NSObject <NSLocking> {
	NSMutableDictionary* _objectsByName;
	NSString* _typeName;
	pthread_mutex_t _mutex;
	BOOL _isWeak : 1;
}

/**
 * Adds the specified object to the cache.
 *
 * Objects in the cache must have a unique name. An assertion error will be raised if an
 * object with the same name exists in the cache already. To replace an object in the cache,
 * you must first remove the existing object from the cache.
 *
 * If the value of the isWeak property is YES at the time this method is invoked, this cache
 * will hold a weak reference to the specified object. In this case, the specified object 
 * should automatically remove itself from this cache during deallocation, once all external 
 * strong references to it have been released, to avoid bad accesses to the cached object 
 * after it has been deallocated.
 *
 * If the value of the isWeak property is NO at the time this method is invoked, this cache
 * will hold a strong reference to the specified object, and it cannot be deallocated
 * until it is specifically removed from this cache.
 */
-(void) addObject: (id<CC3Cacheable>) obj;

/**
 * Returns the cached object with the specified name,
 * or nil if an object with that name has not been cached.
 */
-(id<CC3Cacheable>) getObjectNamed: (NSString*) name;

/** Removes the specified object from the cache. */
-(void) removeObject: (id<CC3Cacheable>) obj;

/** Removes the object with the specified name from the cache. */
-(void) removeObjectNamed: (NSString*) name;

/** 
 * Removes all objects from the cache.
 *
 * This is typically invoked when 3D capabilities are no longer required, or will not be needed
 * for a significant time, and the app wishes to release 3D resources. This method checks each
 * cache entry, and logs an info message for any object that is weakly cached, as the existence
 * of a weakly-cached entry is an indication that the cached object is being retained somewhere
 * else within the app, and is therefore a potential source of a memory leak.
 */
-(void) removeAllObjects;

/** 
 * Removes all objects that are instances of the specified class, or a subclass. 
 *
 * This is typically invoked when strongly cached objects are no longer required, or will not
 * be needed for a significant time, and the app wishes to release 3D resources. This method
 * checks each cache entry, and logs an info message for any object that is weakly cached, as
 * the existence of a weakly-cached entry is an indication that the cached object is being 
 * retained somewhere else within the app, and is therefore a potential source of a memory leak.
 */
-(void) removeAllObjectsOfType: (Class) type;

/**
 * Enumerates all of the objects in the cache with the specified block.
 *
 * The block takes as arguments an object from the cache, and a pointer to a boolean that
 * can be set to YES to stop enumeration.
 */
-(void) enumerateObjectsUsingBlock: (void (^) (id<CC3Cacheable> obj, BOOL* stop)) block;

/** 
 * Returns an array of all objects in this cache, sorted by name.
 *
 * This is a convenience method for use when listing items in the array during logging and development. 
 *
 * Since the objects are retained within the returned array, be careful not to hold on to the array,
 * if you want weakly cached objects to be automatically removed from this cache.
 */
-(NSArray*) objectsSortedByName;

/** A descriptive name of the type of object being cached. */
@property(nonatomic, retain, readonly) NSString* typeName;

/** 
 * Indicates whether this cache holds weak references to the objects within.
 *
 * If the value of this property is YES, this cache will hold a weak reference to each object
 * within the cache, and the presence of the object in the cache will not stop the object from
 * being deallocated. In this case, each object should automatically remove itself from this
 * cache during deallocation, once all external strong references to the object have been released.
 *
 * This property is set during cache instantiation and initialization, and can be changed
 * at any time, allowing the cache to hold a mix of weakly and strongly cached objects.
 * Whether an object is weakly or strongly cached is determined at the time the object is
 * added to the cached.
 */
@property(nonatomic, assign) BOOL isWeak;


#pragma mark Allocation and initialization

/** 
 * Initializes this instance as either a weak or strong cache, for holding objects of
 * the specified content type.
 *
 * The specified type name is used for logging and reporting informational purposes only.
 * It should be a lower-case descriptive name, such as "resource", "texture", "shader", etc.
 *
 * If the value of the specified flag is YES, this cache will hold weak references to the
 * objects within the cache, and the presence of the object in the cache will not stop the
 * object from being deallocated. If the value of the specified flag is NO, this cache will
 * hold strong references to the objects within the cache, and the presence of the object
 * in the cache will stop the object from being deallocated.
 */
-(id) initAsWeakCache: (BOOL) isWeak forType: (NSString*) typeName;

/** 
 * Allocates and initializes an empty autoreleased instance holding weak references to the
 * objects within the cache. The presence of an object in this cache will not stop the object
 * from being deallocated.
 */
+(id) weakCacheForType: (NSString*) typeName;

/**
 * Allocates and initializes an empty autoreleased instance holding strong references to 
 * the objects within the cache. The presence of an object in this cache will stop the 
 * object from being deallocated.
 */
+(id) strongCacheForType: (NSString*) typeName;

@end

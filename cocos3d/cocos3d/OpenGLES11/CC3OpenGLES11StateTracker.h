/*
 * CC3OpenGLES11StateTracker.h
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

/** @file */	// Doxygen marker


#import "ccTypes.h"
#import "CC3Foundation.h"
#import "CC3OpenGLES11Foundation.h"

@class CC3OpenGLES11Engine;

/**
 * An enumeration of the techniques for handling the existing value of a GL state
 * at the time the CC3OpenGLES11Engine singleton instance open method is invoked,
 * combined with techniques for how to leave that GL state when the singleton
 * close method is invoked, prior to the resumption of normal cocos2d 2D drawing.
 * The following types of original value handling are available:
 *
 *   - kCC3GLESStateOriginalValueIgnore: The original value of the GL state when the 
 *     CC3OpenGLES11Engine open method is invoked is ignored. The first subsequent
 *     state change will always set the GL state. The GL state is left as-is when the
 *     CC3OpenGLES11Engine close method is invoked.
 *
 *   - kCC3GLESStateOriginalValueReadOnce: The original GL state value is read once,
 *     on the fist invocation of the CC3OpenGLES11Engine open method, and is remembered.
 *     The value is assumed to always have this value at the time of any subsequent
 *     invocations of the CC3OpenGLES11Engine open method. The first subsequent attempt
 *     to change this GL state value will only be forwarded to the GL function if it is
 *     different than this value. The GL state is left as-is when the CC3OpenGLES11Engine
 *     close method is invoked.
 *
 *   - kCC3GLESStateOriginalValueReadAlways: The original GL state value is read on
 *     every invocation of the CC3OpenGLES11Engine open method. The first subsequent
 *     attempt to change this GL state value will only be forwarded to the GL function
 *     if it is different than this value. The GL state is left as-is when the
 *     CC3OpenGLES11Engine close method is invoked.
 *
 *   - kCC3GLESStateOriginalValueReadOnceAndRestore: The original GL state value is read
 *     as described for kCC3GLESStateOriginalValueReadOnce. On every invocation of the
 *     CC3OpenGLES11Engine close method, the GL state is ensured to be set back to this
 *     value before 2D drawing resumes.
 *
 *   - kCC3GLESStateOriginalValueReadAlwaysAndRestore: The original GL state value is read
 *     as described for kCC3GLESStateOriginalValueReadAlways. On every invocation of the
 *     CC3OpenGLES11Engine close method, the GL state is ensured to be set back to this value
 *     before 2D drawing resumes.
 *
 *   - kCC3GLESStateOriginalValueRestore: The original GL state value is set manually
 *     during initialization. On every invocation of the CC3OpenGLES11Engine close method,
 *     the GL state is ensured to be set back to this value before 2D drawing resumes.
 *
 * For maximum throughput in the GL engine, reading of GL state from the GL engine should
 * be minimized. Therefore, the enumerations kCC3GLESStateOriginalValueReadAlways and
 * kCC3GLESStateOriginalValueReadAlwaysAndRestore should be avoided whenever possible and
 * only used as a last resort.
 * 
 * The enumeration kCC3GLESStateOriginalValueIgnore is best for GL state that has an
 * unpredictable value when the CC3OpenGLES11Engine method is invoked, and where cocos2d
 * does not expect the state to be in any particular value when 2D drawing resumes after
 * 3D drawing is complete.
 * 
 * The enumeration kCC3GLESStateOriginalValueReadOnceAndRestore is best for GL state that
 * must be left with a predictable value when the CC3OpenGLES11Engine close method is 
 * invoked. This is typical for state that cocos2d expects to have a particular value 
 * when 2D drawing resumes after 3D drawing is complete.
 * 
 * The enumeration kCC3GLESStateOriginalValueReadAlwaysAndRestore should only be used
 * for GL state that is unpredictable when 3D drawing begins, but must be left in that
 * same state when 2D drawing ends. This is rare, and should only be used as a last resort.
 * 
 * The enumeration kCC3GLESStateOriginalValueRestore should only be used when it is not
 * possible to read the GL value from the GL engine. This is the case for a few OES state values.
 * 
 * The enumerations kCC3GLESStateOriginalValueReadOnce and kCC3GLESStateOriginalValueReadAlways
 * have limited value, since they perform a GL read, but do not restore that value once 3D
 * drawing is complete. It is generally better to simply use the enumeration
 * kCC3GLESStateOriginalValueIgnore instead. However, kCC3GLESStateOriginalValueReadOnce can
 * be useful for reading platform characteristics and limits.
 */
typedef enum {
	kCC3GLESStateOriginalValueIgnore = 1,
	kCC3GLESStateOriginalValueReadOnce,
	kCC3GLESStateOriginalValueReadAlways,
	kCC3GLESStateOriginalValueReadOnceAndRestore,
	kCC3GLESStateOriginalValueReadAlwaysAndRestore,
	kCC3GLESStateOriginalValueRestore
} CC3GLESStateOriginalValueHandling;


#pragma mark -
#pragma mark CC3OpenGLES11StateTracker

/**
 * This is the base class of all OpenGL ES 1.1 state trackers.
 *
 * All trackers can be opened and closed, and define a default technique
 * for handling the original GL state value (see the notes for the
 * CC3GLESStateOriginalValueHandling enumeration).
 */
@interface CC3OpenGLES11StateTracker : NSObject {
	CC3OpenGLES11StateTracker* parent;
	BOOL isScheduledForClose : 1;
}

/** The parent of this tracker. */
@property(nonatomic, readonly) CC3OpenGLES11StateTracker* parent;

/** The CC3OpenGLES11Engine at the root of the tracker assembly. */
@property(nonatomic, readonly) CC3OpenGLES11Engine* engine;

/** Initializes this instance, attached to the specified parent tracker. */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker;

/**
 * Allocates and initializes an autoreleased instance,
 * attached to the specified parent tracker.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker;

/**
 * Opens this tracker. This will be automatically invoked
 * each time the CC3OpenGLES11Engine open method is invoked.
 *
 * This abstract implementation does nothing. Subclasses will override.
 */
-(void) open;

/**
 * Closes this tracker. This will be automatically invoked
 * each time the CC3OpenGLES11Engine close method is invoked.
 *
 * This abstract implementation clears an internal marker. Subclasses will override.
 * Subclasses that override must invoke this superclass method.
 */
-(void) close;

/**
 * Invoked automatically when a tracker is added to its parent.
 *
 * This implementation adds this tracker to the collection of trackers
 * to be opened by the CC3OpenGLES11Engine.
 */
-(void) notifyTrackerAdded;

/**
 * Invoked automatically when the value of the specified tracker was set in the GL engine.
 *
 * This implementation adds this tracker to the collection of trackers to be closed
 * by the CC3OpenGLES11Engine.
 */
-(void) notifyGLChanged;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPrimitive

/**
 * A type of CC3OpenGLES11StateTracker that tracks the state of a single primitive GL state value.
 *
 * This is an abstract class. Subclasses will define tracking each type of primitive GL state data.
 */
@interface CC3OpenGLES11StateTrackerPrimitive : CC3OpenGLES11StateTracker {
	GLenum name;
	GLubyte originalValueHandling;
	BOOL valueIsKnown : 1;
	BOOL shouldAlwaysSetGL : 1;
}

/** The enumerated name under which the GL engine identifies this state. */
@property(nonatomic, assign) GLenum name;

/**
 * The type of handling to apply to the value of the GL state at the time the open
 * and close method are invoked.
 *
 * See the notes for the CC3GLESStateOriginalValueHandling enumeration for more on handling
 * original GL state.
 *
 * The initial value is set to the value returned by the defaultOriginalValueHandling method.
 * Different subclasses may return different values from the defaultOriginalValueHandling method.
 */
@property(nonatomic, assign) CC3GLESStateOriginalValueHandling originalValueHandling;

/**
 * The default technique for handling the GL state value as it was before tracking is opened.
 *
 * See the notes for the CC3GLESStateOriginalValueHandling enumeration for more on handling
 * original GL state.
 *
 * The default value of this abstract implementation is kCC3GLESStateOriginalValueIgnore.
 * Subclasses will override to establish different defaults.
 */
+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling;

/** Indicates whether the current state in the GL engine is known. */
@property(nonatomic, assign) BOOL valueIsKnown;

/**
 * Returns the value to set the valueIsKnown property to when closing this tracker.
 *
 * Returns NO if the value of the originalValueHandling property is
 * kCC3GLESStateOriginalValueIgnore, otherwise returns YES.
 */
@property(nonatomic, readonly) BOOL valueIsKnownOnClose;

/**
 * Indicates whether the tracker should always call the GL function to set the GL values,
 * even if the value has not changed. If this value is NO, if the value has not changed,
 * the GL function is not called.
 *
 * The initial value of this property is set to the value returned by the
 * defaultShouldAlwaysSetGL method.
 */
@property(nonatomic, assign) BOOL shouldAlwaysSetGL;

/**
 * Default initial value for the shouldAlwaysSetGL property.
 *
 * This implementation returns NO, indicating that, by default, the tracker
 * should only call the GL function if the value has changed.
 */
+(BOOL) defaultShouldAlwaysSetGL;

/**
 * Returns whether the tracker should read the original value from the GL engine
 * on every frame.
 *
 * Returns YES if the name property is not nil, and the value of the
 * originalValueHandling property is either kCC3GLESStateOriginalValueReadAlways
 * or kCC3GLESStateOriginalValueReadAlwaysAndRestore, otherwise returns NO.
 */
@property(nonatomic, readonly) BOOL shouldAlwaysReadOriginal;

/**
 * Returns whether this tracker should restore the original value back to the GL engine
 * when this tracker is closed.
 *
 * This property takes into consideration the value of the valueNeedsRestoration property.
 *
 * Returns YES if the value of the originalValueHandling property is one of kCC3GLESStateOriginalValueRestore,
 * kCC3GLESStateOriginalValueReadOnceAndRestore or kCC3GLESStateOriginalValueReadAlwaysAndRestore, and the
 * value of the valueNeedsRestoration property is YES, otherwise returns NO.
 */
@property(nonatomic, readonly) BOOL shouldRestoreOriginalOnClose;

/** Returns whether the GL state of this tracker has changed and needs to be restored to its original value.  */
@property(nonatomic, readonly) BOOL valueNeedsRestoration;

/** Initializes this instance with the specified enumerated GL name. */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker forState: (GLenum) qName;

/** Allocates and initializes an autoreleased instance with the specified enumerated GL name. */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker forState: (GLenum) qName;

/**
 * Initializes this instance with the specified enumerated GL name,
 * and to handle original values as specified.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
			andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * and to handle original values as specified..
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
			andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Depending on the value of the originalValueHandling property, this implementation may
 * call the OpenGL ES 1.1 engine to read the GL value being tracked.
 */
-(void) open;

/**
 * Depending on the value of the originalValueHandling property, this implementation may
 * attempt to restore the GL value back to the value read when the open method was invoked.
 */
-(void) close;

/** Sets both the originalValue and value properties to the current value as read from the GL engine. */
-(void) readOriginalValue;

/**
 * Template method that sets the current value of the GL state back to the original value.
 * 
 * The value will only be propagated to the GL engine if the original value is different
 * than the current GL value, or if the current value in the GL engine is unknown.
 * 
 * This abstract implementation does nothing. Subclasses will override to set the value
 * using the appropriate variable type.
 *
 * This method is invoked automatically when the close method is invoked, and the
 * original value is to be restored. The application should not invoke this method directly.
 */
-(void) restoreOriginalValue;

/**
 * Template method to get the value from the GL engine and store it as the original value.
 *
 * This abstract implementation does nothing. Subclasses will override to get the value
 * and store it in an original value instance variable of the appropriate type.
 *
 * The application should not invoke this method directly.
 */
-(void) getGLValue;

/**
 * Template method to set the value into the GL engine.
 *
 * This abstract implementation does nothing. Subclasses will override to set a value
 * of the appropriate type into the GL engine.
 *
 * The application should not invoke this method directly.
 */
-(void) setGLValue;

/**
 * Set the GL value, notify the CC3OpenGLES11Engine, mark the value as known,
 * and log the activity.
 *
 * This method is invoked automatically by the value property setter method,
 * and, in turn, invokes the setGLValue template method.
 * The application should not invoke this method directly.
 */
-(void) setGLValueAndNotify;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerBoolean

/** Declaration of a generic GL function that takes a boolean value. */
typedef void( CC3SetGLBooleanFunction( GLboolean ) );

/** A CC3OpenGLES11StateTrackerPrimitive that tracks a boolean GL state value. */
@interface CC3OpenGLES11StateTrackerBoolean : CC3OpenGLES11StateTrackerPrimitive {
	BOOL value;
	BOOL originalValue;
	CC3SetGLBooleanFunction* setGLFunction;
}

/** The current value of the GL state. */
@property(nonatomic, assign) BOOL value;

/** The value of the GL state when the open method was invoked. */
@property(nonatomic, assign) BOOL originalValue;

/** A pointer to the GL function (gl*) used to set this value in the GL engine. */
@property(nonatomic, assign) CC3SetGLBooleanFunction* setGLFunction;

/**
 * Initializes this instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc;

/**
 * Initializes this instance with the specified enumerated GL name, to use the specified
 * gl* function to set the state in the GL engine, and to handle original values as specified.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc
  andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * to use the specified gl* function to set the state in the GL engine,
 * and to handle original values as specified..
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLBooleanFunction*) setGLFunc
	 andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerCapability

/**
 * CC3OpenGLES11StateTrackerCapability tracks a boolean GL capability, indicating whether
 * the capability is enabled or disabled.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerCapability : CC3OpenGLES11StateTrackerBoolean {}

/** Enables the capability. This is the same as setting the value property to YES. */
-(void) enable;

/** Disables the capability. This is the same as setting the value property to NO. */
-(void) disable;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerFloat

/** Declaration of a generic GL function that takes a float value. */
typedef void( CC3SetGLFloatFunction( GLfloat ) );

/** A CC3OpenGLES11StateTrackerPrimitive that tracks a float GL state value. */
@interface CC3OpenGLES11StateTrackerFloat : CC3OpenGLES11StateTrackerPrimitive {
	GLfloat value;
	GLfloat originalValue;
	CC3SetGLFloatFunction* setGLFunction;
}

/** The current value of the GL state. */
@property(nonatomic, assign) GLfloat value;

/** The value of the GL state when the open method was invoked. */
@property(nonatomic, assign) GLfloat originalValue;

/** A pointer to the GL function (gl*) used to set this value in the GL engine. */
@property(nonatomic, assign) CC3SetGLFloatFunction* setGLFunction;

/**
 * Initializes this instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc;

/**
 * Initializes this instance with the specified enumerated GL name, to use the specified
 * gl* function to set the state in the GL engine, and to handle original values as specified.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc
  andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * to use the specified gl* function to set the state in the GL engine,
 * and to handle original values as specified..
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLFloatFunction*) setGLFunc
	 andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerInteger

/** Declaration of a generic GL function that takes an integer value. */
typedef void( CC3SetGLIntegerFunction( GLint ) );

/** A CC3OpenGLES11StateTrackerPrimitive that tracks an integer GL state value. */
@interface CC3OpenGLES11StateTrackerInteger : CC3OpenGLES11StateTrackerPrimitive {
	GLint value;
	GLint originalValue;
	CC3SetGLIntegerFunction* setGLFunction;
}

/** The current value of the GL state. */
@property(nonatomic, assign) GLint value;

/** The value of the GL state when the open method was invoked. */
@property(nonatomic, assign) GLint originalValue;

/** A pointer to the GL function (gl*) used to set this value in the GL engine. */
@property(nonatomic, assign) CC3SetGLIntegerFunction* setGLFunction;

/**
 * Initializes this instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc;

/**
 * Initializes this instance with the specified enumerated GL name, to use the specified
 * gl* function to set the state in the GL engine, and to handle original values as specified.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc
  andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * to use the specified gl* function to set the state in the GL engine,
 * and to handle original values as specified..
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLIntegerFunction*) setGLFunc
	 andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

@end

#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerEnumeration

/** Declaration of a generic GL function that takes an enumerated value. */
typedef void( CC3SetGLEnumerationFunction( GLenum ) );

/** A CC3OpenGLES11StateTrackerPrimitive that tracks an enumerated GL state value. */
@interface CC3OpenGLES11StateTrackerEnumeration : CC3OpenGLES11StateTrackerPrimitive {
	GLenum value;
	GLenum originalValue;
	CC3SetGLEnumerationFunction* setGLFunction;
}

/** The current value of the GL state. */
@property(nonatomic, assign) GLenum value;

/** The value of the GL state when the open method was invoked. */
@property(nonatomic, assign) GLenum originalValue;

/** A pointer to the GL function (gl*) used to set this value in the GL engine. */
@property(nonatomic, assign) CC3SetGLEnumerationFunction* setGLFunction;

/**
 * Initializes this instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc;

/**
 * Initializes this instance with the specified enumerated GL name, to use the specified
 * gl* function to set the state in the GL engine, and to handle original values as specified.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * to use the specified gl* function to set the state in the GL engine,
 * and to handle original values as specified..
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLEnumerationFunction*) setGLFunc
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerColor

/** Declaration of a generic GL function that takes color component values. */
typedef void( CC3SetGLColorFunction( GLfloat, GLfloat, GLfloat, GLfloat ) );

/** A CC3OpenGLES11StateTrackerPrimitive that tracks a color GL state value. */
@interface CC3OpenGLES11StateTrackerColor : CC3OpenGLES11StateTrackerPrimitive {
	ccColor4F value;
	ccColor4F originalValue;
	CC3SetGLColorFunction* setGLFunction;
}

/** The current value of the GL state. */
@property(nonatomic, assign) ccColor4F value;

/** The value of the GL state when the open method was invoked. */
@property(nonatomic, assign) ccColor4F originalValue;

/** A pointer to the GL function (gl*) used to set this value in the GL engine. */
@property(nonatomic, assign) CC3SetGLColorFunction* setGLFunction;

/**
 * Initializes this instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc;

/**
 * Initializes this instance with the specified enumerated GL name, to use the specified
 * gl* function to set the state in the GL engine, and to handle original values as specified.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
  andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * to use the specified gl* function to set the state in the GL engine,
 * and to handle original values as specified..
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
	 andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerColorFixedAndFloat

/** Declaration of a generic GL function that takes color component values. */
typedef void( CC3SetGLColorFunctionFixed( GLubyte, GLubyte, GLubyte, GLubyte ) );

/**
 * A CC3OpenGLES11StateTrackerPrimitive that tracks a color GL state value,
 * as either a float or fixed value.
 */
@interface CC3OpenGLES11StateTrackerColorFixedAndFloat : CC3OpenGLES11StateTrackerColor {
	ccColor4B fixedValue;
	CC3SetGLColorFunctionFixed* setGLFunctionFixed;
	BOOL fixedValueIsKnown;
}

/** The current value of the GL state, in fixed bits. */
@property(nonatomic, assign) ccColor4B fixedValue;

/** A pointer to the GL function (gl*) used to set this value in the GL engine. */
@property(nonatomic, assign) CC3SetGLColorFunctionFixed* setGLFunctionFixed;

/**
 * Initializes this instance with the specified enumerated GL name,
 * and to use the specified gl* functions to set the state in the GL engine.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * and to use the specified gl* functions to set the state in the GL engine.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed;

/**
 * Initializes this instance with the specified enumerated GL name, to use the specified
 * gl* functions to set the state in the GL engine, and to handle original values as specified.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * to use the specified gl* functions to set the state in the GL engine,
 * and to handle original values as specified..
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLColorFunction*) setGLFunc
  andGLSetFunctionFixed:  (CC3SetGLColorFunctionFixed*) setGLFuncFixed
andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Template method to set the fixedValue into the GL engine..
 *
 * The application should not invoke this method directly.
 */
-(void) setGLFixedValue;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerViewport

/** Declaration of a generic GL function that takes viewport component values. */
typedef void( CC3SetGLViewportFunction( GLint, GLint, GLsizei, GLsizei ) );

/**
 * CC3OpenGLES11StateTrackerViewport tracks the viewport GL state.
 *
 * The originalValueHandling property is set to kCC3GLESStateOriginalValueReadOnceAndRestore,
 * which will cause the state to be automatically read once, on the first invocation of the
 * open method, and to be automatically restored on each invocation of the close method.
 */
@interface CC3OpenGLES11StateTrackerViewport : CC3OpenGLES11StateTrackerPrimitive {
	CC3Viewport value;
	CC3Viewport originalValue;
	CC3SetGLViewportFunction* setGLFunction;
}

/** The current value of the GL state. */
@property(nonatomic, assign) CC3Viewport value;

/** The value of the GL state when the open method was invoked. */
@property(nonatomic, assign) CC3Viewport originalValue;

/** A pointer to the GL function (gl*) used to set this value in the GL engine. */
@property(nonatomic, assign) CC3SetGLViewportFunction* setGLFunction;

/**
 * Initializes this instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * and to use the specified gl* function to set the state in the GL engine.
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc;

/**
 * Initializes this instance with the specified enumerated GL name, to use the specified
 * gl* function to set the state in the GL engine, and to handle original values as specified.
 */
-(id) initWithParent: (CC3OpenGLES11StateTracker*) aTracker
			forState: (GLenum) aName
	andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc
  andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

/**
 * Allocates and initializes an autoreleased instance with the specified enumerated GL name,
 * to use the specified gl* function to set the state in the GL engine,
 * and to handle original values as specified..
 */
+(id) trackerWithParent: (CC3OpenGLES11StateTracker*) aTracker
			   forState: (GLenum) aName
	   andGLSetFunction: (CC3SetGLViewportFunction*) setGLFunc
	 andOriginalValueHandling: (CC3GLESStateOriginalValueHandling) origValueHandling;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerPointer

/** A CC3OpenGLES11StateTrackerPrimitive that tracks a pointer GL state value. */
@interface CC3OpenGLES11StateTrackerPointer : CC3OpenGLES11StateTrackerPrimitive {
	GLvoid* value;
	GLvoid* originalValue;
}

/** The current value of the GL state. */
@property(nonatomic, assign) GLvoid* value;

/** The value of the GL state when the open method was invoked. */
@property(nonatomic, assign) GLvoid* originalValue;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVector

/** A CC3OpenGLES11StateTrackerPrimitive that tracks a 3D vector GL state value. */
@interface CC3OpenGLES11StateTrackerVector : CC3OpenGLES11StateTrackerPrimitive {
	CC3Vector value;
	CC3Vector originalValue;
}

/** The current value of the GL state. */
@property(nonatomic, assign) CC3Vector value;

/** The value of the GL state when the open method was invoked. */
@property(nonatomic, assign) CC3Vector originalValue;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerVector4

/** A CC3OpenGLES11StateTrackerPrimitive that tracks a 4D vector GL state value. */
@interface CC3OpenGLES11StateTrackerVector4 : CC3OpenGLES11StateTrackerPrimitive {
	CC3Vector4 value;
	CC3Vector4 originalValue;
}

/** The current value of the GL state. */
@property(nonatomic, assign) CC3Vector4 value;

/** The value of the GL state when the open method was invoked. */
@property(nonatomic, assign) CC3Vector4 originalValue;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerComposite

/**
 * A CC3OpenGLES11StateTracker that tracks a composite value. Composite values track
 * more than one state value, but the values are set in the GL engine with a single GL call.
 *
 * CC3OpenGLES11StateTrackerComposite is an abstract class. Subclasses will define the
 * values to be tracked. Each individual value will have its own primitive tracker
 * contained within the composite tracker.
 *
 * Subclasses will also define the method used to set the values.
 *
 * In general, the composite tracker sets the values in the GL engine (in a single gl* call)
 * only if at least one of the values have changed. This behaviour can be modified by setting
 * the shouldAlwaysSetGL property to YES, in which case, the gl* function will be invoked
 * anytime the values are set, even if none of them have changed.
 */
@interface CC3OpenGLES11StateTrackerComposite : CC3OpenGLES11StateTracker {
	GLubyte originalValueHandling;
	BOOL shouldAlwaysSetGL;
}

/**
 * The type of handling to apply to the value of the GL state at the time the open
 * and close method are invoked.
 *
 * See the notes for the CC3GLESStateOriginalValueHandling enumeration for more on handling
 * original GL state.
 *
 * The initial value is set to the value returned by the defaultOriginalValueHandling method.
 * Different subclasses may return different values from the defaultOriginalValueHandling method.
 */
@property(nonatomic, assign) CC3GLESStateOriginalValueHandling originalValueHandling;

/**
 * The default technique for handling the GL state value as it was before tracking is opened.
 *
 * See the notes for the CC3GLESStateOriginalValueHandling enumeration for more on handling
 * original GL state.
 *
 * The default value of this abstract implementation is kCC3GLESStateOriginalValueIgnore.
 * Subclasses will override to establish different defaults.
 */
+(CC3GLESStateOriginalValueHandling) defaultOriginalValueHandling;

/** Indicates whether the current state in the GL engine is known. */
@property(nonatomic, assign) BOOL valueIsKnown;

/**
 * Indicates whether the tracker should always call the GL function to set the GL values,
 * even if none of the component values have changed. If this value is NO, if none of the
 * component values has changed, the GL function is not called.
 *
 * The initial value of this property is set to the value returned by the
 * defaultShouldAlwaysSetGL method.
 */
@property(nonatomic, assign) BOOL shouldAlwaysSetGL;

/**
 * Default initial value for the shouldAlwaysSetGL property.
 *
 * This implementation returns NO, indicating that, by default, the composite tracker
 * should only call the GL function if at least one of the component values has changed.
 */
+(BOOL) defaultShouldAlwaysSetGL;

/**
 * Template method to set the enclosed values into the GL engine.
 *
 * This abstract implementation does nothing. Subclasses will override to set the values using
 * a specific GL function.
 *
 * The application should not invoke this method directly.
 */
-(void) setGLValues;

/**
 * Returns the value to set the valueIsKnown property to when closing this tracker.
 *
 * Returns NO if the value of the originalValueHandling property is
 * kCC3GLESStateOriginalValueIgnore, otherwise returns YES.
 */
@property(nonatomic, readonly) BOOL valueIsKnownOnClose;

/**
 * Returns whether this tracker should restore the original value back to the GL engine
 * when this tracker is closed.
 *
 * This property takes into consideration the value of the valueNeedsRestoration property.
 *
 * Returns YES if the value of the originalValueHandling property is one of kCC3GLESStateOriginalValueRestore,
 * kCC3GLESStateOriginalValueReadOnceAndRestore or kCC3GLESStateOriginalValueReadAlwaysAndRestore, and the
 * value of the valueNeedsRestoration property is YES, otherwise returns NO.
 */
@property(nonatomic, readonly) BOOL shouldRestoreOriginalOnClose;

/** Returns whether the GL state of this tracker has changed and needs to be restored to its original value.  */
@property(nonatomic, readonly) BOOL valueNeedsRestoration;

/**
 * Template method that sets the current values of the GL state back to their original values.
 *
 * The values of the contained primitive trackers will only be propagated to the GL engine if
 * the original values are different than the current GL value, or if the current values in the
 * GL engine are unknown.
 *
 * This abstract implementation does nothing. Subclasses will override to set the contained primitive values.
 *
 * This method is invoked automatically when the close method is invoked, and the
 * original values  are to be restored. The application should not invoke this method directly.
 */
-(void) restoreOriginalValues;

/**
 * Initializes the component primitive trackers.
 *
 * Automatically invoked during instance initialization.
 * The application should not invoke this method.
 */
-(void) initializeTrackers;

@end


#pragma mark -
#pragma mark CC3OpenGLES11StateTrackerManager

/**
 * An CC3OpenGLES11StateTracker that manages a number of other trackers.
 *
 * This is an abstract class. Subclasses will define the specific managed trackers.
 *
 * The open and close methods invoke the open and close methods of each of the managed trackers.
 */
@interface CC3OpenGLES11StateTrackerManager : CC3OpenGLES11StateTracker {}

/**
 * Initializes the instance without invoking the initializeTrackers method.
 *
 * Automatically invoked when needed during subclass initialization.
 * The application should not invoke this method.
 */
-(id) initMinimalWithParent: (CC3OpenGLES11StateTracker*) aTracker;

/**
 * Initializes the managed trackers.
 *
 * Automatically invoked during instance initialization.
 * The application should not invoke this method.
 */
-(void) initializeTrackers;

@end





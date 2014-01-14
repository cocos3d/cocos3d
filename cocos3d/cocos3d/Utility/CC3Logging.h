/*
 * CC3Logging.h
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
 * Thanks to Nick Dalton for providing the underlying ideas for using variadic macros as
 * well as for outputting the code location as part of the log entry. For his ideas, see:
 *   http://iphoneincubator.com/blog/debugging/the-evolution-of-a-replacement-for-nslog
 */

/** @file */	// Doxygen marker

/**
 * For Objective-C code, this library adds flexible, non-intrusive assertion and logging
 * capabilities that can be efficiently enabled or disabled via compiler switches.
 *
 * The CC3Assert() function can be used in place of the standard NSAssert() family of functions.
 * CC3Assert() improves the NSAssert() family of functions in two ways:
 *    - CC3Assert ensures that the assertion message is logged to the console.
 *    - CC3Assert can be used with a variable number of arguments without the need for
 *      NSAssert1(), NSAssert2(), etc.
 *
 * Like the NSAssert() functions, you can turn assertions off in production code by either setting
 * NS_BLOCK_ASSERTIONS to 1 in your compiler build settings, or setting the ENABLE_NS_ASSERTIONS
 * compiler setting to NO. Doing so completely removes the corresponding assertion invocations
 * from the compiled code, thus eliminating both the memory and CPU overhead that the assertion
 * calls would add
 *
 * A special CC3AssertUnimplemented(name) assertion function is provided to conveniently raise
 * an assertion exception when some expected functionality is unimplemented. This might be used
 * in a method body by a superclass that requires each subclass to implement that method, or it
 * might be used as a temporary placeholder for functionalty that will be added at a later time.
 *
 * This library also adds a sophisticated logging capability.
 *
 * There are four levels of logging: Trace, Info, Error and Debug, and each can be enabled
 * independently via the LOGGING_LEVEL_TRACE, LOGGING_LEVEL_INFO, LOGGING_LEVEL_ERROR and
 * LOGGING_LEVEL_DEBUG switches, respectively.
 *
 * In addition, there are the following specialized logging switches that can be turned on
 * to assist with diagnostics and troubleshooting:
 *
 *		LOGGING_REZLOAD		- output log messages during 3D model resource loading
 *
 * ALL logging can be enabled or disabled via the LOGGING_ENABLED switch.
 *
 * Each logging level also has a conditional logging variation, which outputs a log entry
 * only if the specified conditional expression evaluates to YES.
 *
 * Logging functions are implemented here via macros. Disabling logging, either entirely, or
 * at a specific level, completely removes the corresponding log invocations from the compiled
 * code, thus eliminating both the memory and CPU overhead that the logging calls would add.
 * You might choose, for example, to completely remove all logging from production release code,
 * by setting LOGGING_ENABLED off in your production builds settings. Or, as another example,
 * you might choose to include Error logging in your production builds by turning only
 * LOGGING_ENABLED and LOGGING_LEVEL_ERROR on, and turning the others off.
 *
 * To perform logging, use any of the following function calls in your code:
 *
 *		LogCleanTrace(fmt, ...)		- recommended for detailed tracing of program flow
 *									- will print if LOGGING_LEVEL_TRACE is set on.
 *		LogTimedTrace(fmt, ...)		- as above but prints a standard timestamp and app context preamble
 *		LogTrace(fmt, ...)			- convenience alias for LogCleanTrace. Can be changed to LogTimedTrace below.
 *		LogTraceIf(cond, fmt, ...)	- same as LogTrace if boolean "cond" condition expression evaluates to YES, 
 *									  otherwise logs nothing.
 *
 *		LogCleanInfo(fmt, ...)		- recommended for general, infrequent, information messages
 *									- will print if LOGGING_LEVEL_INFO is set on.
 *		LogTimedInfo(fmt, ...)		- as above but prints a standard timestamp and app context preamble
 *		LogInfo(fmt, ...)			- convenience alias for LogCleanInfo. Can be changed to LogTimedInfo below.
 *		LogInfoIf(cond, fmt, ...)	- same as LogInfo if boolean "cond" condition expression evaluates to YES,
 *									  otherwise logs nothing.
 *
 *		LogCleanError(fmt, ...)		- recommended for use only when there is an error to be logged
 *									- will print if LOGGING_LEVEL_ERROR is set on.
 *		LogTimedError(fmt, ...)		- as above but prints a standard timestamp and app context preamble
 *		LogError(fmt, ...)			- convenience alias for LogCleanError. Can be changed to LogTimedError below.
 *		LogErrorIf(cond, fmt, ...)	- same as LogError if boolean "cond" condition expression evaluates to YES,
 *									  otherwise logs nothing.
 *
 *		LogCleanDebug(fmt, ...)		- recommended for temporary use during debugging
 *									- will print if LOGGING_LEVEL_DEBUG is set on.
 *		LogTimedDebug(fmt, ...)		- as above but prints a standard timestamp and app context preamble
 *		LogDebug(fmt, ...)			- convenience alias for LogCleanDebug. Can be changed to LogTimedDebug below.
 *		LogDebugIf(cond, fmt, ...)	- same as LogDebug if boolean "cond" condition expression evaluates to YES,
 *									  otherwise logs nothing.
 *
 *		LogCleanRez(fmt, ...)		- recommended for use during development
 *									- will print if LOGGING_REZLOAD is set on.
 *		LogTimedRez(fmt, ...)		- as above but prints a standard timestamp and app context preamble
 *		LogRez(fmt, ...)			- convenience alias for LogCleanRez. Can be changed to LogTimedRez below.
 *		LogRezIf(cond, fmt, ...)	- same as LogRez if boolean "cond" condition expression evaluates to YES,
 *									  otherwise logs nothing.
 *
 * In each case, the functions follow the general NSLog/printf template, where the first argument
 * "fmt" is an NSString that optionally includes embedded Format Specifiers, and subsequent optional
 * arguments indicate data to be formatted and inserted into the string. As with NSLog/printf, the number
 * of optional arguments must match the number of embedded Format Specifiers. For more info, see the
 * core documentation for NSLog and String Format Specifiers.
 *
 * You can choose to have each logging entry automatically include class, method and line information
 * by enabling the LOGGING_INCLUDE_CODE_LOCATION switch.
 *
 * You can determine and log the timing of resource loading operations by using the function pair
 * MarkRezActivityStart() and GetRezActivityDuration(). Together, these two fuctions work to mark
 * the beginning and end of a resource loading activity (or any activity actually).
 *
 * Call MarkRezActivityStart() before a resource operation to indicate that timing should begin,
 * and call GetRezActivityDuration() after the operation to retrieve the elapsed time, often
 * calling it as an argument in a LogRez call. Both macros should appear at the same nesting level
 * in your function or method, since they define and share a local variable to track the time.
 * These two macro functions are only defined if LOGGING_REZLOAD is set on, otherwise they are
 * completely removed from the compiled code.
 *
 * Although you can directly edit this file to turn on or off the switches below, the preferred
 * technique is to set these switches via the compiler build setting GCC_PREPROCESSOR_DEFINITIONS
 * in your build configuration.
 */

/**
 * Set this switch to  enable or disable logging capabilities.
 * This can be set either here or via the compiler build setting GCC_PREPROCESSOR_DEFINITIONS
 * in your build configuration. Using the compiler build setting is preferred for this to
 * ensure that logging is not accidentally left enabled by accident in release builds.
 */
#ifndef LOGGING_ENABLED
#	define LOGGING_ENABLED		0
#endif

/**
 * Set any or all of these switches to enable or disable logging at specific levels.
 * These can be set either here or as a compiler build settings.
 */
#ifndef LOGGING_LEVEL_TRACE
#	define LOGGING_LEVEL_TRACE		0
#endif
#ifndef LOGGING_LEVEL_INFO
#	define LOGGING_LEVEL_INFO		LOGGING_ENABLED
#endif
#ifndef LOGGING_LEVEL_ERROR
#	define LOGGING_LEVEL_ERROR		LOGGING_ENABLED
#endif
#ifndef LOGGING_LEVEL_DEBUG
#	define LOGGING_LEVEL_DEBUG		LOGGING_ENABLED
#endif
#ifndef LOGGING_REZLOAD
#	define LOGGING_REZLOAD			LOGGING_ENABLED
#endif

/**
 * Set this switch to indicate whether or not to include class, method and line information
 * in the log entries. This can be set either here or as a compiler build setting.
 */
#ifndef LOGGING_INCLUDE_CODE_LOCATION
#	define LOGGING_INCLUDE_CODE_LOCATION	0
#endif


// *********** END OF USER SETTINGS  - Do not change anything below this line ***********


/** Use this macro to open a break-point programmatically. */
#ifndef DEBUGGER
#	define DEBUGGER() { kill( getpid(), SIGINT ) ; }
#endif

// Logging formats
#define LOG_FORMAT_NO_LOCATION(fmt, lvl, ...) NSLog((@"[%@] " fmt), lvl, ##__VA_ARGS__)
#define LOG_FORMAT_WITH_LOCATION(fmt, lvl, ...) NSLog((@"%s[Line %d] [%@] " fmt), __PRETTY_FUNCTION__, __LINE__, lvl, ##__VA_ARGS__)
#define LOG_FORMAT_CLEAN(fmt, lvl, ...) printf("[%s] %s\n", [lvl UTF8String], [[NSString stringWithFormat: fmt, ##__VA_ARGS__] UTF8String])
#define LOG_FORMAT_CLEAN_IF(cond, fmt, lvl, ...) if(cond) { LOG_FORMAT_CLEAN(fmt, lvl, ##__VA_ARGS__); }

#if LOGGING_INCLUDE_CODE_LOCATION
#	define LOG_FORMAT(fmt, lvl, ...) LOG_FORMAT_WITH_LOCATION(fmt, lvl, ##__VA_ARGS__)
#else
#	define LOG_FORMAT(fmt, lvl, ...) LOG_FORMAT_NO_LOCATION(fmt, lvl, ##__VA_ARGS__)
#endif

// Trace logging - for detailed tracing
#if LOGGING_LEVEL_TRACE
#	define LogTimedTrace(fmt, ...) LOG_FORMAT(fmt, @"trace", ##__VA_ARGS__)
#	define LogCleanTrace(fmt, ...) LOG_FORMAT_CLEAN(fmt, @"trace", ##__VA_ARGS__)
#	define LogTraceIf(cond, fmt, ...) LOG_FORMAT_CLEAN_IF((cond), fmt, @"trace", ##__VA_ARGS__)
#else
#	define LogTimedTrace(...)
#	define LogCleanTrace(...)
#	define LogTraceIf(cond, fmt, ...)
#endif
#define LogTrace(fmt, ...) LogCleanTrace(fmt, ##__VA_ARGS__)

// Info logging - for general, non-performance affecting information messages
#if LOGGING_LEVEL_INFO
#	define LogTimedInfo(fmt, ...) LOG_FORMAT(fmt, @"info", ##__VA_ARGS__)
#	define LogCleanInfo(fmt, ...) LOG_FORMAT_CLEAN(fmt, @"info", ##__VA_ARGS__)
#	define LogInfoIf(cond, fmt, ...) LOG_FORMAT_CLEAN_IF((cond), fmt, @"info", ##__VA_ARGS__)
#else
#	define LogTimedInfo(...)
#	define LogCleanInfo(...)
#	define LogInfoIf(cond, fmt, ...)
#endif
#define LogInfo(fmt, ...) LogCleanInfo(fmt, ##__VA_ARGS__)

// Error logging - only when there is an error to be logged
#if LOGGING_LEVEL_ERROR
#	define LogTimedError(fmt, ...) LOG_FORMAT(fmt, @"***ERROR***", ##__VA_ARGS__)
#	define LogCleanError(fmt, ...) LOG_FORMAT_CLEAN(fmt, @"***ERROR***", ##__VA_ARGS__)
#	define LogErrorIf(cond, fmt, ...) LOG_FORMAT_CLEAN_IF((cond), fmt, @"***ERROR***", ##__VA_ARGS__)
#else
#	define LogTimedError(...)
#	define LogCleanError(...)
#	define LogErrorIf(cond, fmt, ...)
#endif
#define LogError(fmt, ...) LogCleanError(fmt, ##__VA_ARGS__)

// Debug logging - use only temporarily for highlighting and tracking down problems
#if LOGGING_LEVEL_DEBUG
#	define LogTimedDebug(fmt, ...) LOG_FORMAT(fmt, @"debug", ##__VA_ARGS__)
#	define LogCleanDebug(fmt, ...) LOG_FORMAT_CLEAN(fmt, @"debug", ##__VA_ARGS__)
#	define LogDebugIf(cond, fmt, ...) LOG_FORMAT_CLEAN_IF((cond), fmt, @"debug", ##__VA_ARGS__)
#	define MarkDebugActivityStart() NSTimeInterval _DEBUG_START_TIME_ = [NSDate timeIntervalSinceReferenceDate]
#	define GetDebugActivityDuration() ([NSDate timeIntervalSinceReferenceDate] - _DEBUG_START_TIME_)
#else
#	define LogTimedDebug(...)
#	define LogCleanDebug(...)
#	define LogDebugIf(cond, fmt, ...)
#	define MarkDebugActivityStart()
#	define GetDebugActivityDuration() 0.0
#endif
#define LogDebug(fmt, ...) LogCleanDebug(fmt, ##__VA_ARGS__)

// Resource loading - use only temporarily for information and troubleshooting
#if LOGGING_REZLOAD
#	define LogTimedRez(fmt, ...) LOG_FORMAT(fmt, @"rez", ##__VA_ARGS__)
#	define LogCleanRez(fmt, ...) LOG_FORMAT_CLEAN(fmt, @"rez", ##__VA_ARGS__)
#	define LogRezIf(cond, fmt, ...) LOG_FORMAT_CLEAN_IF((cond), fmt, @"rez", ##__VA_ARGS__)
#	define MarkRezActivityStart() NSTimeInterval _REZ_START_TIME_ = [NSDate timeIntervalSinceReferenceDate]
#	define GetRezActivityDuration() ([NSDate timeIntervalSinceReferenceDate] - _REZ_START_TIME_)
#else
#	define LogTimedRez(...)
#	define LogCleanRez(...)
#	define LogRezIf(cond, fmt, ...)
#	define MarkRezActivityStart()
#	define GetRezActivityDuration() 0.0
#endif
#define LogRez(fmt, ...) LogCleanRez(fmt, ##__VA_ARGS__)

// Assertions
#if NS_BLOCK_ASSERTIONS
#	define CC3Assert(test, fmt, ...)
#	define CC3AssertC(test, fmt, ...)
#else
#	define CC3Assert(test, fmt, ...)					\
	if (!(test)) {										\
		LogError(fmt, ##__VA_ARGS__);					\
		NSAssert(NO, @"See previous logged error.");	\
	}
#	define CC3AssertC(test, fmt, ...)					\
	if (!(test)) {										\
		LogError(fmt, ##__VA_ARGS__);					\
		NSCAssert(NO, @"See previous logged error.");	\
	}
#endif

#define CC3AssertUnimplemented(name) CC3Assert(NO, @"%@ is not implemented!", name)

/*
 * CC3Math.h
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

/** @file */	// Doxygen marker

/* Base library of definitions and functions for operating in a 3D world. */

#import <math.h>


#pragma mark Basic math support

#define M_SQRT3  1.732050807568877f							/* sqrt(3) */
#define kCircleDegrees  360.0f
#define kSemiCircleDegrees  180.0f

/** Conversion between degrees and radians. */
#define DegreesToRadiansFactor  0.017453292519943f			// PI / 180
#define RadiansToDegreesFactor  57.29577951308232f			// 180 / PI
#define DegreesToRadians(D) ((D) * DegreesToRadiansFactor)
#define RadiansToDegrees(R) ((R) * RadiansToDegreesFactor)

/** Returns -1, 0 or +1 if the arguement is negative, zero or positive respectively. */
#define SIGN(A)	((A) < 0 ? -1 :((A) > 0 ? 1 : 0))

/** Returns the value clamped to be between the min and max values */
#define CLAMP(val, min, max) (MIN(MAX((val), (min)), (max)))

/** Returns a weighted average of the two values, where weight is between zero and one, inclusive. */
#define WAVG(val1, val2, weight) ((val1) + (((val2) - (val1)) * CLAMP(weight, 0.0, 1.0)))

/** Returns the positive or negative modulo remainder of value divided by period. */
#define CC3Cyclic(value, period) (fmodf((value), (period)))

/**
 * Returns the positive modulo remainder of value divided by period.
 *
 * This function is similar to CC3Cyclic(), but converts a negative result into a positive
 * value that is the same distance away from the end of the cycle as the result was
 * below zero. In this sense, this function behaves like the numbers on a clock, and
 * CC3Cyclic(-2.0, 12.0) will return 10.0 rather than -2.0. 
 */
static inline float CC3PositiveCyclic(float value, float period) {
	float modVal = CC3Cyclic(value, period);
	return (modVal < 0.0) ? (modVal + period) : modVal;
}

/**
 * Returns the difference between the specified minuend and subtrahend, in terms of the
 * minimum difference within the specified periodic cycle. Therefore, the result may be
 * positive or negative, but will always be between (+period/2) and (-period/2).
 *
 * For example, for the numbers on a compass, the period is 360, and
 * CC3CyclicDifference(350, 10, 360) will yield -20 (ie- the smallest change from 10 degrees
 * to 350 degrees is -20 degrees) rather than +340 (from simple subtraction). Similarly,
 * CC3CyclicDifference(10, 350, 360) will yield +20 (ie- the smallest change from 350 degrees
 * to 10 degrees is +20 degrees) rather than -340 (from simple subtraction).
 *
 * For angles in degrees, consider using CC3SemiCyclicAngle instead.
 */
static inline float CC3CyclicDifference(float minuend, float subtrahend, float period) {
	float semiPeriod = period * 0.5f;
	float diff = CC3Cyclic(minuend - subtrahend, period);
	// If the difference is outside the range (period/2 >= diff >= -period/2),
	// adjust it so that it takes the difference in the other direction to
	// arrive at a smaller change.
	if(diff > semiPeriod) {
		diff -= period;
	} else if(diff < -semiPeriod) {
		diff += period;
	}
	return diff;
}

/**
 * Converts the specified angle, to an equivalent angle between +/-360 degrees.
 * The result may be positive or negative, but will always be between -360 and +360 degrees.
 *
 * For example:
 *   - CC3CyclicAngle(350) will return -350
 *   - CC3CyclicAngle(750) will return +30
 *   - CC3CyclicAngle(-185) will return -185
 *   - CC3CyclicAngle(-535) will return -175
 */
static inline float CC3CyclicAngle(float angle) {
	return CC3Cyclic(angle, kCircleDegrees);
}

/**
 * Converts the specified angle, to an equivalent angle between +/-180 degrees.
 * The result may be positive or negative, but will always be between -180 and +180 degrees.
 *
 * For example:
 *   - CC3SemiCyclicAngle(350) will return -10
 *   - CC3SemiCyclicAngle(750) will return +30
 *   - CC3SemiCyclicAngle(-185) will return +175
 *   - CC3SemiCyclicAngle(-535) will return -175
 */
static inline float CC3SemiCyclicAngle(float angle) {
	// Convert the angle to +/- 360 degrees
	float modAngle = CC3CyclicAngle(angle);

	// Adjust to +/- 180 degrees
	if(modAngle > kSemiCircleDegrees) {
		return modAngle - kCircleDegrees;
	}
	if(modAngle < -kSemiCircleDegrees) {
		return modAngle + kCircleDegrees;
	}
	return modAngle;
}

/**
 * Returns whether the specified value is as close or closer to the specified benchmark
 * value than the specified tolerance.
 *
 * If tolerance is zero, returns YES only if the two values are identical.
 */
static inline bool CC3IsWithinTolerance(float value, float benchmarkValue, float aTolerance) {
	// If no tolerance, short-circuit the test.
	return (aTolerance)
				? (fabsf(value - benchmarkValue) <= fabsf(aTolerance))
				: (value == benchmarkValue);
}


#pragma mark Random number generation

#define kRandomUIntMax 0x100000000LL

/** Returns a random unsigned integer over the full unsigned interger range (between 0 and 0xFFFFFFFF). */
static inline unsigned int CC3RandomUInt() {
	return arc4random();
}

/** Returns a random unsigned integer between 0 inclusive and the specified max exclusive. */
static inline unsigned int CC3RandomUIntBelow(unsigned int max) {
	return CC3RandomUInt() % max;
}

/** Returns a random double between 0.0 inclusive and 1.0 exclusive. */
static inline double CC3RandomDouble() {
	return (double)CC3RandomUInt() / (double)kRandomUIntMax;
}

/** Returns a random double between the specified min inclusive and the specified max exclusive. */
static inline double CC3RandomDoubleBetween(double min, double max) {
	return min + (CC3RandomDouble() * (max - min));
}

/** Returns a random float between 0.0 inclusive and 1.0 exclusive. */
static inline float CC3RandomFloat() {
	return (float)CC3RandomDouble();
}

/** Returns a random float between the specified min inclusive and the specified max exclusive. */
static inline float CC3RandomFloatBetween(float min, float max) {
	return (float)CC3RandomDoubleBetween(min, max);
}

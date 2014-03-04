/*
 * CC3BitmapLabelNode.h
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

#import "CC3MeshNode.h"
#import "CC3Mesh.h"
#import "uthash.h"

/** Bitmap information for a single character. */
typedef struct {
	unichar charCode;	/**< The character unicode value. */
	CGRect rect;		/**< The rectangle within the texture in which the character appears. */
	short xOffset;		/**< The number of pixels the image should be offset horizontally when drawing the image. */
	short yOffset;		/**< The number of pixels the image should be offset vertically when drawing the image. */
	short xAdvance;		/**< The number of pixels to move horizontally to position for the next character. */
} CC3BitmapCharDef;

/** Padding info for a font. */
typedef struct {
	int	left;
	int top;
	int right;
	int bottom;
} CC3BitmapFontPadding;

/** Dictionary hash of the character definitions. */
typedef struct {
	NSUInteger key;					/**< The character unicode value as a hash key. */
	CC3BitmapCharDef charDef;		/**< The character definition. */
	UT_hash_handle hh;				/**< The lookup hash. */
} CC3BitmapCharDefHashElement;

/** Dictionary hash of the kerning info between two characters. */
typedef struct {
	NSUInteger key;					/**< The hash key. 16-bit for 1st char, 16-bit for 2nd char. */
	NSInteger amount;				/**< The amount in pixels to kern between the two characters. */
	UT_hash_handle hh;				/**< The lookup hash. */
} CC3KerningHashElement;


#pragma mark -
#pragma mark CC3BitmapFontConfiguration

/** Extends CC3BitmapFontConfiguration to support cocos3d functionality. */
@interface CC3BitmapFontConfiguration : NSObject {
	CC3BitmapCharDefHashElement* _charDefDictionary;
	CC3KerningHashElement* _kerningDictionary;
	NSCharacterSet* _characterSet;
	NSString* _atlasName;
	NSInteger _commonHeight;
	CC3BitmapFontPadding _padding;
	CGSize _textureSize;
	GLfloat _fontSize;
	NSUInteger _baseline;
}

/** The name of the font atlas texture. */
@property (nonatomic, retain, readonly) NSString* atlasName;

/** Returns the nominal font size. */
@property (nonatomic, readonly) GLfloat fontSize;

/** Returns the character baseline. */
@property (nonatomic, readonly) NSUInteger baseline;

/** Returns the height of the characters in pixels in the texture atlas. */
@property (nonatomic, readonly) NSInteger commonHeight;

/** Returns the padding for the font. */
@property (nonatomic, readonly) CC3BitmapFontPadding padding;

/** Returns the size of the texture in pixels. */
@property (nonatomic, readonly) CGSize textureSize;

/** Returns a pointer to the specification of the specified character. */
-(CC3BitmapCharDef*) characterSpecFor: (unichar) c;

/**
 * Returns the amount of kerning required when the specified second character follows the
 * first character in a line of text.
 */
-(NSInteger) kerningBetween: (unichar) firstChar and: (unichar) secondChar;


#pragma mark Allocation and initialization

/** Initializes this instance from the specified bitmap font definition file. */
-(id) initFromFontFile: (NSString*) fontFile;

/**
 * Allocates and initializes an autoreleased instance from the specified bitmap font definition file.
 *
 * This implementation maintains a cache so that each file is only loaded once.
 */
+(id) configurationFromFontFile: (NSString*) fontFile;

/** Clears all cached font configurations to conserve memory. */
+(void) clearFontConfigurations;

@end


#pragma mark -
#pragma mark CC3MeshNode bitmapped label extension

/** CC3MeshNode extension to support bitmapped labels. */
@interface CC3MeshNode (BitmapLabel)


#pragma mark Populating for bitmapped label

/**
 * Populates this instance as a rectangular mesh displaying the text of the specified string,
 * built from bitmap character images taken from a texture atlas as defined by the bitmpped font
 * configuration loaded from the specified font configuration file.
 *
 * A compatible bitmap font configuration file, and associated texture, can be created using any
 * of these editors:
 *    http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *    http://www.bmglyph.com/ (Commercial, Mac OS X - also available through AppStore)
 *    http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *    http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *    http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 *
 * The texture that matches the specified font configuration (and identified in the font configuration),
 * is automatically loaded and assigned to the texture property of this mesh node.
 *
 * The text may be multi-line, and can be left-, center- or right-aligned, as specified.
 *
 * The specified lineHeight define the height of a line of text in the coordinate system of this
 * mesh node. This parameter can be set to zero to use the natural line height of the font.
 *
 * For example, a font with font size of 16 might have a natural line height of 19. Setting the
 * lineHeight parameter to zero would result in a mesh where a line of text would be 19 units high.
 * On the other hand, setting this property to 0.2 will result in a mesh where the same line of text
 * has a height of 0.2 units. Depending on the size of other models in your scene, you may want to
 * set this lineHeight to something compatible. In addition, the visual size of the text will also
 * be affected by the value of the scale or uniformScale properties of this node. Both the lineHeight
 * and scale properties work to establish the visual size of the label text.
 *
 * For a more granular mesh, each character rectangle can be divided into many smaller divisions.
 * Building a rectanglular surface from more than one division can dramatically improve realism
 * when the surface is illuminated with specular lighting or a tightly focused spotlight, or if
 * the mesh is to be deformed in some way by a later process (such as wrapping the text texture
 * around some other shape).
 *
 * The divsPerChar argument indicates how to break each character rectangle into multiple faces.
 * The X & Y elements of the divsPerChar argument indicate how each axis if the rectangle for each
 * character should be divided into faces. The number of faces in the rectangle for each character
 * will therefore be the multiplicative product of the X & Y elements of the divsPerChar argument.
 *
 * For example, a value of {3,2} for the divsPerChar argument will result in each character being
 * divided into 6 smaller rectangular faces, arranged into a 3x2 grid.
 *
 * The relative origin defines the location of the origin for texture alignment, and is specified
 * as a fraction of the size of the overall label layout, starting from the bottom-left corner.
 *
 * For example, origin values of (0, 0), (0.5, 0.5), and (1, 1) indicate that the label mesh should
 * be aligned so that the bottom-left corner, center, or top-right corner, respectively, should be
 * located at the local origin of the corresponding mesh.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * This method may be invoked repeatedly to change the label string. The mesh will automomatically
 * be rebuilt to the correct number of vertices required to display the currently specified string.
 */
-(void) populateAsBitmapFontLabelFromString: (NSString*) lblString
							   fromFontFile: (NSString*) fontFileName
							  andLineHeight: (GLfloat) lineHeight
						   andTextAlignment: (NSTextAlignment) textAlignment
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (CC3Tessellation) divsPerChar;

@end


#pragma mark -
#pragma mark CC3BitmapLabelNode

/**
 * CC3BitmapLabelNode displays a rectangular mesh displaying the text of a specified string,
 * built from bitmap character images taken from a texture atlas as defined by a bitmpped font
 * configuration loaded from a font configuration file.
 *
 * The labelString property specifies the string that is to be displayed in the bitmap font described
 * in the bitmpa font file identified by the fontFileName property.
 *
 * A compatible bitmap font configuration file, and associated texture, can be created using any
 * of these editors:
 *    http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
 *    http://www.bmglyph.com/ (Commercial, Mac OS X - also available through AppStore)
 *    http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
 *    http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
 *    http://www.angelcode.com/products/bmfont/ (Free, Windows only)
 *
 * The texture that matches the specified font configuration (and identified in the font configuration),
 * is automatically loaded and assigned to the texture property of this mesh node.
 *
 * The text may be multi-line, and can be left-, center- or right-aligned, as specified by the
 * textAlignment property. The resulting mesh can be positioned with its origin anywhere within
 * the text rectangle using the relativeOrigin property.
 *
 * For a more granular mesh, each character rectangle can be divided into many smaller divisions as
 * defined by the tessellation property.
 *
 * The properties of this class can be changed at any time to display a different text string, or to
 * change the visual aspects of the label. Changing any of the properties in this class causes the
 * underlying mesh to be automatically rebuilt.
 *
 * The vertexContentType property of this mesh may be set to define the content type for each vertex.
 * Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and kCC3VertexContentTextureCoordinate
 * are populated by this method.
 *
 * If the vertexContentType property is not explicitly set, that property is automatically set to a value
 * of (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and the
 * mesh will be populated with location, normal and texture coordinates for each vertex.
 */
@interface CC3BitmapLabelNode : CC3MeshNode {
	NSString* _labelString;
	NSString* _fontFileName;
	CC3BitmapFontConfiguration* _fontConfig;
	NSTextAlignment _textAlignment;
	CGPoint _relativeOrigin;
	CC3Tessellation _tessellation;
	GLfloat _lineHeight;
}

/**
 * Indicates the string to be displayed. This string may include newline characters (\n) to
 * create a multi-line label.
 *
 * This property can be changed at any time to display a different text string.
 */
@property(nonatomic, retain) NSString* labelString;

/**
 * Indicates the name of the bitmap font file that contains the specifications of the font used
 * to display the text.
 *
 * This property can be changed at any time.
 */
@property(nonatomic, retain) NSString* fontFileName;

/**
 * The line height in the local coordinate system of this node.
 *
 * This property can be changed at any time to change the size of the label layout.
 *
 * The initial value of this property is zero. If the value of this property is not explicitly set
 * to another value, it will return the value from the font configuration, once the fontFileName
 * property is set, resulting in this label taking on the unscaled line height of the bitmapped font.
 */
@property(nonatomic, assign) GLfloat lineHeight;

/**
 * For multi-line labels, indicates how the lines should be aligned.
 *
 * The initial value of this property is NSTextAlignmentLeft, indicating that multi-line
 * text will be left-aligned.
 *
 * This property can be changed at any time.
 */
@property(nonatomic, assign) NSTextAlignment textAlignment;

/**
 * Indicates the location of the origin of the mesh, and is specified as a fraction of the size of
 * the overall label layout, starting from the bottom-left corner. The origin determines how the
 * mesh will be positioned by the location property of this node, and is the point around which
 * any rotational transformations take place.
 *
 * For example, origins of (0,0), (0.5,0.5), and (1,1) indicate that the label mesh should be aligned
 * so that the bottom-left corner, center, or top-right corner of the label text, respectively,
 * should be located at the local origin of the corresponding mesh.
 *
 * After the fontFileName property has been set, you can make use of the value of the baseline property
 * to locate the local origin on the baseline of the font, by setting this property to (X, self.baseline),
 * where X is a fraction indicating where the origin should be positioned horizontally.
 *
 * The initial value of this property is {0,0}, indicating that this label node will have its origin
 * at the bottom-left corner of the label text.
 *
 * This property can be changed at any time.
 */
@property(nonatomic, assign) CGPoint relativeOrigin;

/**
 * Indicates the granularity of the mesh for each character. 
 *
 * For a more granular mesh, each character rectangle can be divided into many smaller divisions within the
 * mesh. This essentially defines how many rectangular faces (quads) should be used to create each character.
 *
 * Building a rectangular surface from multiple faces can dramatically improve realism when the surface
 * is illuminated with specular lighting or a tightly focused spotlight, or if the mesh is to be deformed
 * in some way by a later process (such as wrapping the text texture around some other shape).
 *
 * The X & Y elements of this property indicate how each axis if the rectangle for each character should
 * be divided into faces. The number of rectangular faces (quads) in the rectangle for each character will
 * therefore be the multiplicative product of the X & Y elements of this property.
 *
 * For example, if this property has a value of {3,2}, each character will be constructed from six smaller
 * rectangular faces, arranged into a 3x2 grid.
 *
 * The initial value of this property is {1,1}, indicating that, within the underlying mesh, each character
 * will be constructed from a single rectangular face.
 *
 * This property can be changed at any time.
 */
@property(nonatomic, assign) CC3Tessellation tessellation;

/**
 * Returns the nominal size of the font, in points or pixels.
 *
 * This property returns zero if the fontFileName property has not been set.
 */
@property(nonatomic, readonly) GLfloat fontSize;

/**
 * Returns the position of the baseline of the font, as a fraction of the lineHeight property,
 * as measured from the bottom of the label.
 * 
 * After setting the fontFileName property, you can use this property to set the relativeOrigin
 * property if you want to position the local origin of this label on the baseline of the font.
 * See the relativeOrigin property for more info.
 *
 * This property returns zero if the fontFileName property has not been set.
 */
@property(nonatomic, readonly) GLfloat baseline;

@end


#pragma mark -
#pragma mark CC3Mesh bitmapped label extension

/** CC3MeshNode extension to support bitmapped labels. */
@interface CC3Mesh (BitmapLabel)

/**
 * Populates this instance as a rectangular mesh displaying the text of the specified string,
 * built from bitmap character images taken from a texture atlas as defined by the specified
 * bitmapped font configuration.
 *
 * The texture that matches the specified font configuration (and identified in the font configuration),
 * should be loaded and assigned to the texture property of the mesh node that uses this mesh.
 *
 * The text may be multi-line, and can be left-, center- or right-aligned, as specified.
 *
 * The specified lineHeight define the height of a line of text in the coordinate system of this
 * mesh. This parameter can be set to zero to use the natural line height of the font.
 *
 * For example, a font with font size of 16 might have a natural line height of 19. Setting the
 * lineHeight parameter to zero would result in a mesh where a line of text would be 19 units high.
 * On the other hand, setting this property to 0.2 will result in a mesh where the same line of text
 * has a height of 0.2 units. Depending on the size of other models in your scene, you may want to
 * set this lineHeight to something compatible. In addition, the visual size of the text will also
 * be affected by the value of the scale or uniformScale properties of any mesh node using this mesh.
 * Both the lineHeight and the node scale work to establish the visual size of the label text.
 *
 * For a more granular mesh, each character rectangle can be divided into many smaller divisions.
 * Building a rectanglular surface from more than one division can dramatically improve realism
 * when the surface is illuminated with specular lighting or a tightly focused spotlight, or if
 * the mesh is to be deformed in some way by a later process (such as wrapping the text texture
 * around some other shape).
 *
 * The divsPerChar argument indicates how to break each character rectangle into multiple faces.
 * The X & Y elements of the divsPerChar argument indicate how each axis if the rectangle for each
 * character should be divided into faces. The number of faces in the rectangle for each character
 * will therefore be the multiplicative product of the X & Y elements of the divsPerChar argument.
 *
 * For example, a value of {3,2} for the divsPerChar argument will result in each character being
 * divided into 6 smaller rectangular faces, arranged into a 3x2 grid.
 *
 * The relative origin defines the location of the origin for texture alignment, and is specified
 * as a fraction of the size of the overall label layout, starting from the bottom-left corner.
 *
 * For example, origin values of (0, 0), (0.5, 0.5), and (1, 1) indicate that the label mesh should
 * be aligned so that the bottom-left corner, center, or top-right corner, respectively, should be
 * located at the local origin of the corresponding mesh.
 *
 * The vertexContentType property of this mesh may be set prior to invoking this method, to define the
 * content type for each vertex. Content types kCC3VertexContentLocation, kCC3VertexContentNormal, and
 * kCC3VertexContentTextureCoordinate are populated by this method.
 *
 * If the vertexContentType property has not already been set, that property is set to a value of
 * (kCC3VertexContentLocation | kCC3VertexContentNormal | kCC3VertexContentTextureCoordinate), and
 * the mesh will be populated with location, normal and texture coordinates for each vertex.
 *
 * This method may be invoked repeatedly to change the label string. The mesh will automomatically
 * be rebuilt to the correct number of vertices required to display the currently specified string.
 */
-(void) populateAsBitmapFontLabelFromString: (NSString*) lblString
									andFont: (CC3BitmapFontConfiguration*) fontConfig
							  andLineHeight: (GLfloat) lineHeight
						   andTextAlignment: (NSTextAlignment) textAlignment
						  andRelativeOrigin: (CGPoint) origin
							andTessellation: (CC3Tessellation) divsPerChar;

@end


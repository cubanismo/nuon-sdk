/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/


// OpenGL Context structure definitions

#ifndef CONTEXT_H
#define CONTEXT_H

#include <nuon/video.h>
#include "gl.h"
#include "mpedefs.h"

// API Constants
#define TEXTUREOBJECTGROWTHFACTOR 32

// OpenGL constants
#define GL_MVMATRIXSTACK_DEPTH 32
#define GL_TXMATRIXSTACK_DEPTH 4
#define GL_PRMATRIXSTACK_DEPTH 4

// Validation constants
#define VAL_PIPELINE			(1 <<  0)
#define VAL_TOTAL_MATRIX		(1 <<  1)
#define VAL_LIGHTING			(1 <<  2)
#define VAL_MATERIAL_SHININESS	(1 <<  3)
#define VAL_FOG					(1 <<  4)
#define VAL_TEXTURE				(1 <<  5)
#define VAL_VIEWPORT			(1 <<  6)
#define VAL_RENDER_BUFFER		(1 <<  7)
#define VAL_MPE_INVALIDATED		(1 <<  8)

typedef struct {
	GLuint				ID;								// Numerical ID
	GLuint				boundFlag;						// Bound state
	GLuint				levels;							// Number of levels (1-5)
	GLuint				target;							// Display or app PixMap
	GLuint				priority;						// Texture residence priority
	GLuint				textureMode;					// Type of texture
	GLuint				minFilter;						// Minification filter
	GLuint				magFilter;						// Magnification filter
	GLTexture			*texture[5];					// Actual textures
} GLTextureObject;

typedef struct {
	GLint				r;
	GLint				g;
	GLint				b;
	GLint				a;
} Color;

typedef struct {
	GLint				x;
	GLint				y;
	GLint				z;
	GLint				w;
} Point;

typedef struct {
	GLfloat				x;
	GLfloat				y;
	GLfloat				z;
	GLfloat				w;
} Pointf;

typedef struct {
	GLint				m11, m12, m13, m14;
	GLint				m21, m22, m23, m24;
	GLint				m31, m32, m33, m34;
	GLint				m41, m42, m43, m44;
} Matrix4;

typedef struct {
	Point				pos;							// Position
	Color				c_amb;							// Ambient color
	Color				c_dif;							// Diffuse color
	Color				c_spec;							// Specular color
	GLfloat				kc;								// Constant attenuation factor
	GLfloat				kl;								// Linear attenuation factor
	GLfloat				kq;								// Quadratic attenuation factor
	Pointf				dir;							// Spot direction
	GLfloat				cutoff;							// Spot cutoff angle
	GLfloat				exponent;						// Spot exponent
	GLboolean			enable;							// Light enabled/disabled flag
} GLLight;

typedef struct {
	Color				c_amb;							// Ambient color
	Color				c_dif;							// Diffuse color
	Color				c_spec;							// Specular color
	Color				c_emis;							// Emissive color
	GLfloat				shininess;						// Specular exponent
} GLMaterial;

typedef struct {

	GLint				commBusId;						// MPE comm bus id
	GLint				minibios;						// if nonzero, MPE runs minibios
	GLuint				validationFlags;				// validation flags
	volatile GLint		taskCounter;					// number of tasks currently assigned to MPE
	long				initData[2];					// DMAed to MPE before MPE startup

	const void			*loader;
	const void			*lighter;
	const void			*transformer;
	const void			*trivia;
	const void			*clipper;
	const void			*rasterizer;

} GLMPE;

typedef struct {

	// Enables

	GLboolean			depthTestEnable;
	GLboolean			fogEnable;
	GLboolean			lightingEnable;
	GLboolean			texture1DEnable;
	GLboolean			texture2DEnable;
	GLboolean			chromakeyEnable;
	GLboolean			blendEnable;

	// Lighting

	Color				lightModelAmbient;
	GLLight				light[MAX_LIGHTS];
	GLMaterial			frontMaterial;
	GLMaterial			backMaterial;

	// Fog

	Color				fogColor;
	GLint				fogStart;
	GLint				fogEnd;
	GLint				fogDensity;
	GLenum				fogMode;

	// Blending

	GLenum				blendSrcFactor;
	GLenum				blendDstFactor;

	// Matrices

	GLint				currentMatrix;

	Matrix4				modelviewMatrix;
	Matrix4				mvMatrixStack[GL_MVMATRIXSTACK_DEPTH];
	GLint				mvMatrixStackDepth;

	Matrix4				projectionMatrix;
	Matrix4				prMatrixStack[GL_PRMATRIXSTACK_DEPTH];
	GLint				prMatrixStackDepth;

	Matrix4				textureMatrix;
	Matrix4				txMatrixStack[GL_TXMATRIXSTACK_DEPTH];
	GLint				txMatrixStackDepth;

	// Viewport

	GLint				viewportWidth;
	GLint				viewportHeight;
	GLint				viewportX;
	GLint				viewportY;
	GLfloat				zFar;
	GLfloat				zNear;

	// Primitive rendering

	GLboolean			beginEndFlag;					// Within Begin/End block flag
	GLint				currentVertex;					// Current vertex counter
	GLuint				currentVertexNormal;			// 11 11 10 packed vertex normal
	GLuint				currentVertexColor;				// Current vertex color
	GLint				currentVertexS;					// Current vertex u
	GLint				currentVertexT;					// Current vertex v
	GLint				vertexBuffer[MAX_VERTS * 8];	// Vertex buffer for rendering
	GLuint				vertexCount;					// Numeric position in vertex buffer
	GLuint				vertexCounter;					// Number of vertices since last buffer flush
	GLuint				vertexStartCounter;				// Starting point for vertices since past flush
	GLuint				vertexEntryCounter;				// Number of vertices since last buffer flush
	GLuint				vertexEntryStartCounter;		// Starting point for vertices since past flush
	GLenum				vertexFormat;					// Vertex format for begin/end blocks
	GLenum				primitive;						// Current primitive type (GL_TRIANGLES, GL_QUADS, etc)

	// Test Functions

	GLboolean			depthMask;						// Not fully supported
	GLenum				depthFunction;

	// Clear values

	Color				clearColor;						// RGB
	GLuint				clearColorYCrCb;				// YCrCb
	GLuint				clearDepth;

	// Current vertex values

	Color				currentColor;					// RGB
	Point				currentNormal;
	Point				currentTexCoord;

	// Nuon-specific
	GLint				commBusId;						// Comm bus ID of controlling MPE
	GLint				numMPEs;						// Number of MPEs for rendering pipeline
	GLMPE				mpe[MAX_RENDERING_MPES];		// MPE data structures
	void				*oldCommRecvInterrupt;			// Saved comm bus receive interrupt vector
	GLint				numBuffers;						// Number of buffers
	GLint				pixelType;						// DMA Pixel type
	mmlDisplayPixmap	*screenBuffer[8];				// Screen buffer array
	GLint				frontBuffer;					// Current front buffer
	GLint				backBuffer;						// Current back buffer
	GLint				renderBuffer;					// Current rendering buffer
	GLint				drawBuffer;						// Current drawing buffer
	GLint				fieldcount;						// video field count
    VidChannel			vidMainChannel;

	// Texture
	GLTextureObject		*texObj;						// Texture object list
	GLuint				textureObjects;					// Number of allocated texture objects
	GLTextureObject		*current2DObject;				// Current 2D texture object
	GLTextureObject		*current1DObject;				// Current 1D texture object
	GLuint				current2DObjectID;				// Current 2D texture object ID
	GLuint				current1DObjectID;				// Current 1D texture object ID
	GLTexture			*defaultTexture;				// Default texture
	GLenum				textureEnvMode;					// Texturing mode

	// OpenGL error handling

	GLuint				errorCode;						// Current OpenGL error

	// Validation

	GLuint				validationFlags;

	long				dmaData[4];
	long				fogData[2];
	long				lightData[LIGHT_DATA_SIZE];
	long				specularLUTData[SPECULAR_LUT_SIZE];
	long				totalMatrixData[16];
	long				viewportData[4];

	const void			*loader;
	long				loader_size;					// bytes
	const void			*lighter;
	long				lighter_size;					// bytes
	const void			*transformer;
	long				transformer_size;				// bytes
	const void			*trivia;
	long				trivia_size;					// bytes
	const void			*clipper;
	long				clipper_size;					// bytes
	const void			*rasterizer;
	long				rasterizer_size;				// bytes

} GLContext;

#endif // CONTEXT_H

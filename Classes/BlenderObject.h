//
//  BlenderObject.h
//  OpenGLES15
//
//  Created by Simon Maurice on 18/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


typedef struct __GLVertexElement {
	GLfloat coordiante[3];
	GLfloat normal[3];
	GLfloat texCoord[2];
} GLVertexElement;

@interface BlenderObject : NSObject {

	int noTextureVertexCount;				// 1
    unsigned short noTextureTriangleCount;	// 1
	
    int vertexCount;
    unsigned short triangleCount;           // Equivalent to len(mesh.faces)
    
	GLfloat *vertexArray;			// 1
    unsigned short *indexArray;		// 1
	
	GLVertexElement *data;   // 2
	GLuint otexture;          // DEPRICATED for some reason this doesn't work but an array does.
	
	GLuint textures[10];
}

- (NSError *)loadBlenderObject:(NSString *)fileName;
- (void)draw;
- (void)drawNoTexture;
- (NSError *)loadObjectTexture:(NSString *)fileName;

@end

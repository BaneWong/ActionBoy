//
//  BlenderObject.m
//  OpenGLES15
//
//  Created by Simon Maurice on 18/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import "BlenderObject.h"


@implementation BlenderObject



- (NSError *)loadBlenderObject:(NSString *)fileName {
    
    if(fileName == nil || [fileName isEqualToString:@"null"] ){
        
        NSLog(@" Can't  object because it failed to load. %@", fileName);
        
        //return nil;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"gldata"];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handle == nil) {
        NSLog(@"Error on: %@ ", fileName);
		
		NSString *msg = @"loadBlenderObject Something went really, really wrong...";
		
        return [NSError errorWithDomain:@"BlenderObject"
							code:0
                               userInfo:[NSDictionary dictionaryWithObject:msg
							   forKey:NSLocalizedDescriptionKey]];
    }
    
	[[handle readDataOfLength:sizeof(int)] getBytes:&vertexCount];
	[[handle readDataOfLength:sizeof(unsigned short)] getBytes:&triangleCount];

	// For testing
//	NSLog(@"Vertex Count: %d", vertexCount);
//	NSLog(@"Triangle Count: %d", triangleCount);
	
	
	// No texture
	vertexArray = malloc(sizeof(GLfloat) * 6 * vertexCount);
	indexArray = malloc(sizeof(unsigned short) * triangleCount * 3);
	//[[handle readDataOfLength:sizeof(GLfloat)*6*vertexCount] getBytes:vertexArray];
	//[[handle readDataOfLength:sizeof(unsigned short) * triangleCount * 3] getBytes:indexArray];
	
	
	// texture
	data = malloc(sizeof(GLVertexElement) * triangleCount * 3);
	[[handle readDataOfLength:sizeof(GLVertexElement) * triangleCount * 3] getBytes:data];
	
	NSError *error = [self loadObjectTexture:fileName];
	if (error) {
		NSLog(@"Error loading texture");
	}
	
	return nil;
}


- (void)drawNoTexture {
	glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, sizeof(GLfloat)*6, vertexArray);
	glNormalPointer(GL_FLOAT, sizeof(GLfloat)*6, &vertexArray[3]);
    glDrawElements(GL_TRIANGLES, noTextureTriangleCount*3, GL_UNSIGNED_SHORT, indexArray);
    glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
}


- (void)draw {
    
    if(data == nil){
        //NSLog(@" Can't draw Blender object because it failed to load.");
        //return;
    }
    
	glBindTexture(GL_TEXTURE_2D, textures[0]); //  otexture
	glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glVertexPointer(3, GL_FLOAT, sizeof(GLVertexElement), data);
	glNormalPointer(GL_FLOAT, sizeof(GLVertexElement), data->normal);
	glTexCoordPointer(2, GL_FLOAT, sizeof(GLVertexElement), data->texCoord);
	glDrawArrays(GL_TRIANGLES, 0, triangleCount*3);
	
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
}


- (NSError *)loadObjectTexture:(NSString *)fileName {
	
	NSLog(@"fileName   %@ ", fileName);
	
	glGenTextures(10, textures);
	
	
	NSString *name = [NSString stringWithFormat:@"%@.%@", fileName, @"png"];
	CGImageRef textureImage = [UIImage imageNamed:name].CGImage;
	if (textureImage == nil) {
		NSLog(@"fileName   %@ ", fileName);
		
		return [NSError errorWithDomain:nil
								   code:0
							   userInfo:[NSDictionary dictionaryWithObject:@"Error loading file"
									forKey:NSLocalizedDescriptionKey]];
	}
	
	NSInteger texWidth = CGImageGetWidth(textureImage);
	NSInteger texHeight = CGImageGetHeight(textureImage);
	
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	
	CGContextRef textureContext = CGBitmapContextCreate(textureData,
														texWidth, texHeight,
														8, texWidth * 4,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);
	
	CGContextTranslateCTM(textureContext, 0, texHeight);
	CGContextScaleCTM(textureContext, 1.0, -1.0);
	
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, textures[0] ); //  otexture
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	return nil;
}


- (void)dealloc {
	if (data != nil) {
		free(data);
	}
	glDeleteTextures(1, &otexture);			// No need to check if texture is in use.
	[super dealloc];
}


/*
 - (NSError *)loadBlenderObject:(NSString *)fileName {
 
 NSLog(@" loadBlenderObject ");
 
 NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"gldata"];
 NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
 if (handle == nil) {
 NSString *msg = @"Something went really, really wrong...";
 return [NSError errorWithDomain:@"BlenderObject"
 code:0
 userInfo:[NSDictionary dictionaryWithObject:msg
 forKey:NSLocalizedDescriptionKey]];
 }
 
 [[handle readDataOfLength:sizeof(int)] getBytes:&vertexCount];
 [[handle readDataOfLength:sizeof(unsigned short)] getBytes:&triangleCount]; // error
 
 data = malloc(sizeof(GLVertexElement) * triangleCount * 3);
 [[handle readDataOfLength:sizeof(GLVertexElement) * triangleCount * 3] getBytes:data];
 
 NSError *error = [self loadObjectTexture:fileName];
 if (error) {
 NSLog(@"Error loading texture");
 }
 
 return nil;
 }
 */

@end

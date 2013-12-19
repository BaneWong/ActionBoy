//
//  Piece.h
//  ___PROJECTNAME___
//
//  Created by Jon taylor on 10-12-31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface Piece : NSObject {
	
	int index;
	int inPlace;
	int highlight;
	
	GLfloat locationX;
	GLfloat locationY;
	GLfloat locationZ;
	
	GLfloat homeX;
	GLfloat homeY;
	GLfloat homeZ;
	
	GLfloat textureLeft;
	GLfloat textureRight;
	GLfloat textureTop;
	GLfloat textureBottom;
	
	
}


//(void)setLocationX:(NSNumber*);
//(NSNumber*)getLocationX;

@end

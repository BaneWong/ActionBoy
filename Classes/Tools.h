//
//  Tools.h
//  RayPicking Sample
//
//  Created by Nova-Box on 5/24/10.
//
//  This document contains programming examples.
//  
//  Nova-box grants you a nonexclusive copyright license to use all programming code examples 
//  from which you can generate similar function tailored to your own specific needs.
//  
//  All sample code is provided by Nova-box for illustrative purposes only. 
//  These examples have not been thoroughly tested under all conditions. 
//  Nova-box, therefore, cannot guarantee or imply reliability, serviceability, or function of these programs.
//  
//  All programs contained herein are provided to you "AS IS" without any warranties of any kind. 
//  The implied warranties of non-infringement, merchantability and fitness for a particular purpose are expressly disclaimed.

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define CLAMP(value, min, max) if(value < min) value = min; if(value > max) value = max;
#define POW2(x) ((x)*(x))

typedef struct SPoint3D
{
	GLfloat x;
	GLfloat y;
	GLfloat z;
} Point3D;

@interface Tools : NSObject {
	
}



+(void) loadTexture:(NSString*)_path id:(GLuint*) _id;
+(void) loadTextureWithImage:(UIImage*)_image id:(GLuint*) _id;

+(Boolean) poinSphereCollision:(Point3D) _point center:(Point3D) _center radius:(GLfloat)_radius;

@end

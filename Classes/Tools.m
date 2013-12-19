//
//  Tools.m
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

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "Tools.h"

@implementation Tools

+(void) loadTexture:(NSString*)_path id:(GLuint*) _id
{
    [self loadTextureWithImage:[UIImage imageNamed:_path] id:_id];
}

+(void) loadTextureWithImage:(UIImage*)_image id:(GLuint*) _id
{
    CGImageRef textureImage = _image.CGImage;
    if (textureImage == nil) {
        NSLog(@"Image could not be loaded.");
        return;   
    }
	
    NSInteger textureWidth = CGImageGetWidth(textureImage);
    NSInteger textureHeight = CGImageGetHeight(textureImage);
	
  	GLubyte *textureData = (GLubyte *)malloc(textureWidth * textureHeight * 4); // 4 car RVBA
	
	CGContextRef textureContext = CGBitmapContextCreate(
														textureData,
														textureWidth,
														textureHeight,
														8, textureWidth * 4,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);
	
	CGContextDrawImage(textureContext,
					   CGRectMake(0.0, 0.0, (float)textureWidth, (float)textureHeight),
					   textureImage);
	
	CGContextRelease(textureContext);
	
	glGenTextures(1, _id);
	glBindTexture(GL_TEXTURE_2D, *_id);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureWidth, textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T
					, GL_CLAMP_TO_EDGE);
	glEnable(GL_TEXTURE_2D);	
}


+(Boolean) poinSphereCollision:(Point3D) _point center:(Point3D) _center radius:(GLfloat)_radius
{
	return (POW2(_point.x - _center.x) + POW2(_point.y - _center.y) + POW2(_point.z - _center.z) < POW2(_radius)); 
}

@end

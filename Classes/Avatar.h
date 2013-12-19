//
//  Avatar.h
//  Vampires
//
//  Created by Jon Taylor on 12-03-13.
//  Copyright (c) 2012 Subject Reality Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "OpenGLWaveFrontObject.h"
#import "Sound.h"

@interface Avatar : NSObject {
    
    OpenGLWaveFrontObject* boyObject;
    OpenGLWaveFrontObject* boyLeftObject;
    OpenGLWaveFrontObject* boyRightObject;
    
    int stage;
    int stages;
    float stageDuration;
    float durationIndex;
    
    Sound * sound;
}

- (id)init;
-(void)draw:(float)frs isWalking:(float)walkingSpeed;
-(OpenGLWaveFrontObject*) loadBoyObject:(NSString*)n;    
-(void)setSound:(Sound *)s;

@end

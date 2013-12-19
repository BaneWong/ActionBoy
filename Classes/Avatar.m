//
//  Avatar.m
//  Vampires
//
//  Created by Jon Taylor on 12-03-13.
//  Copyright (c) 2012 Subject Reality Software. All rights reserved.
//

#import "Avatar.h"

@implementation Avatar



- (id)init {
	self = [super init];
    if (self) {
        boyObject = [self loadBoyObject:@"boy"]; // boy
        boyLeftObject = [self loadBoyObject:@"boy_left"];
        boyRightObject = [self loadBoyObject:@"boy_right"];
        
        stage = 0;
        stages = 4;
        stageDuration = 6;
        durationIndex = 0;
	}
	return self;
}


/**
 * draw
 *
 * Description: paint bullet
 */
-(void)draw:(float)frs isWalking:(float)walkingSpeed;
{
    //glPushMatrix();
    
	//float dotSize = 5;
	//glEnableClientState(GL_VERTEX_ARRAY);
	
    //boyObject
    if(boyObject != nil){
        glScalef(1.2, 1.2, 1.2);
        
        
        //glTranslatef(0 ,1, 0); // raise  moves forward by accident
        
        glRotatef(90, 1.0, 0.0, 0.0); // orient
        
        //[boyObject setRotX:(float)(M_PI/2)];
        
        //glEnable ( GL_COLOR_MATERIAL );
        glEnable(GL_LIGHTING);
        
        
        if(walkingSpeed > -0.08 && walkingSpeed < 0.08){ // not moving
            stage = 0;
        }
        
        if(stage == 0){                         // stand
            if(boyObject != nil){    
                [boyObject drawSelf];
            }
        }
        if(stage == 1){                         // Left
            if(boyLeftObject != nil){
                [boyLeftObject drawSelf];
                
                if(sound != nil){
                    [sound playerWalking];
                }
            }
        }
        if(stage == 2){                         // stand
            if(boyObject != nil){    
                [boyObject drawSelf];
            }
        }
        if(stage == 3){                         // right
            if(boyRightObject != nil){
                [boyRightObject drawSelf];
                
                if(sound != nil){
                    [sound playerWalking];
                }
            }
        }
        
            
        glDisable(GL_LIGHTING);
    }
    
    // stage
    
    if(walkingSpeed < 0){
        walkingSpeed = -walkingSpeed;
    }
    //NSLog(@"frs: %f   %f ", frs, walkingSpeed);
    
    durationIndex += ( frs * walkingSpeed);
    if(durationIndex > stageDuration){
        durationIndex = 0;
        stage++;
        if(stage >= stages){
            stage = 0;
        }
    }
    
	//glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    //glPopMatrix();	// Return matrix to origional state
}
 

-(OpenGLWaveFrontObject*) loadBoyObject:(NSString*)n {
    OpenGLWaveFrontObject * obj;
    NSString *path = [[NSBundle mainBundle] pathForResource:n ofType:@"obj"];
    if(path != nil){
        obj = [[OpenGLWaveFrontObject alloc] initWithPath:path];
        
        Vertex3D position = Vertex3DMake(0.0, 3.0, 0.0);
        obj.currentPosition = position;
    }
    return obj;
}


-(void)setSound:(Sound *)s {
    sound = s;
}

@end

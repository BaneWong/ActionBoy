//
//  Character.m
//  OpenGLES13
//
//  Created by Jon taylor on 10-01-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Character.h"


@implementation Character


- (void)update {

	//rotY = [[NSNumber alloc] initWithFloat: [y floatValue] +  0.1 ]; 
	
	y += 0.5f;
	
	glRotatef( y , 0.0, 1.0, 0.0);

	//NSLog(@" Update ");
}






@end

//
//  Sprites.m
//  PuzzleCities
//
//  Created by Jon taylor on 11-01-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Sprites.h"


@implementation Sprites

-(void)init;
{
	//sprites = [[NSMutableArray alloc] init ]; 
	//sprites = Vertex3D[100];
	
	
	for(int i = 0; i < 100; i++){
		Vertex3D v = Vertex3DMake((float)((i/20)-4) , ((i/20)-4), (float)(i/50) );
		sprites[i] = v;
		//[sprites addObject: v];
	}
}

-(void)drawSprites:(GLView*)view;
{
	//NSLog(@" draw sprites ");
	//int numSteps = 10;
	//float spacing = 1.0/numSteps;
	int dotSize = 3;
	
	//int numItems =10;
	
	glPointSize(dotSize);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	//glDisable(GL_TEXTURE_2D);
	//glPointSize(3);
	
	glLoadIdentity();
	glTranslatef( 0.2, 0, -5); 
	
	glColor4f(1.0f, 1.0f, 1.0f, 0.2f); // opaque red
	
	
	CGPoint vertices2[100];
	for(int i = 0; i < 100; i++){
		float x = (float)i / (float)10;
		x = x - 10;
		//NSLog(@"  %f", x);
		vertices2[i] = CGPointMake(x, x);
		
		
		Vertex3D v = sprites[i];
		
		if(v.x < -3){
			v.x = 3;
		}
		v.x -= 0.01;
		if(v.y < -3){
			v.y = 3;
		}
		v.y -= 0.01;
		
		sprites[i] = v;
	}
	
	glVertexPointer(3, GL_FLOAT, 0, sprites);
	glDrawArrays(GL_POINTS, 0, 100);
	
	
	
	
	
	glLineWidth(2);
	GLfloat vertcies[4];
	vertcies[0] = 0;
	vertcies[1] = 0;
	vertcies[2] = 1;
	vertcies[3] = -1;
	//glEnableClientState(GL_VERTEX_ARRAY);
	//glVertexPointer(2, GL_FLOAT, 0, vertcies);
	//glDrawArrays(GL_LINE_STRIP, 0, 2);
	
	//glDisableClientState(GL_VERTEX_ARRAY);
	
}


- (void)dealloc 
{
	//[sprites release];
	
    [super dealloc];
}

@end

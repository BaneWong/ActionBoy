//
//  Enimy.m
//  Vampires
//
//  Created by Jon taylor on 11-02-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"



@implementation Enemy


-(void) drawHealth:(int)level {
    
    
    glPushMatrix();
    
    
    glTranslatef(0, 3, 0);
    
    glColor4f(0.8f,0.8f,1.0f,1.0f);
    
    // Top Line
    {
        GLfloat vVertices[] = {1, 1.4, 0,  -1, 1.4, 0};
        //glColor4f(1.0f,1.0f,1.0f,1.0f); 
        glLineWidth(1.0f);
        glVertexPointer(3, GL_FLOAT, 0, vVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINES, 0, 2);
    }
    
    // Bottom Line
    {
        GLfloat vVertices[] = {1, 1, 0,  -1, 1, 0};
        //glColor4f(1.0f,1.0f,1.0f,1.0f);  
        glLineWidth(1.0f);
        glVertexPointer(3, GL_FLOAT, 0, vVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINES, 0, 2);
    }
    
    // Left Line
    {
        GLfloat vVertices[] = {-1, 1.4, 0,  -1, 1, 0};
        //glColor4f(1.0f,1.0f,1.0f,1.0f); 
        glLineWidth(1.0f);
        glVertexPointer(3, GL_FLOAT, 0, vVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINES, 0, 2);
    }
    
    // Right Line
    {
        GLfloat vVertices[] = {1, 1.4, 0,  1, 1, 0};
        //glColor4f(1.0f,1.0f,1.0f,1.0f); 
        glLineWidth(1.0f);
        glVertexPointer(3, GL_FLOAT, 0, vVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINES, 0, 2);
    }
    
    // Bar
    {
        float pos = ((float)level / (float)100) * 0.9;
        
        GLfloat vVertices[] = {pos, 1.2, 0,  -pos, 1.2, 0};
        glColor4f(0.3f,0.3f,1.0f,1.0f); 
        glLineWidth(5.0f);
        glVertexPointer(3, GL_FLOAT, 0, vVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_LINES, 0, 2);
    }
    
    
    glPopMatrix();	// Return matrix to origional state
}
    
@end

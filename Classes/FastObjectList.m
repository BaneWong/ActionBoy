//
//  FastObjectList.m
//  Vampires
//
//  Created by Jon Taylor on 12-02-10.
//  Copyright (c) 2012 Subject Reality Software. All rights reserved.
//

#import "FastObjectList.h"

@implementation FastObjectList


-(void) createList:(NSMutableArray*)inputArray
{
    m_iCount = [inputArray count];
    
    //struct object_struct * 
    str_list = malloc(sizeof(struct object_struct) * m_iCount);
    
    NSEnumerator* objIterator = [inputArray objectEnumerator];
	ObjectContainer* objectContainer;
    int index = 0;
	while((objectContainer = [objIterator nextObject]))
	{
        struct object_struct str;
        str.x = [objectContainer locX];
        str.z = [objectContainer locZ];
        str.oc = objectContainer;
        str_list[index++] = str;
    }
    
}

- (NSMutableArray*) test :(NSMutableArray*)en x:(float)locX  z:(float)locZ d:(float)distance
{
    
    
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    
    for(int i = 0; i < m_iCount; i++){
        struct object_struct os = str_list[i];
        ObjectContainer * oc = os.oc;
        
        //NSLog(@"  os x: %f    obj: %f   " , os.x,   oc.locX);
        
        float tX = [oc locX];
        float tZ = [oc locZ];
        
        // box 
        if(tX < locX + distance && tX > locX - distance && tZ < locZ + distance && tZ > locZ - distance){
            //[result addObject: enimyObject];
            float dx = tX-locX;
            float dz = tZ-locZ;
            float currDistance = sqrt(dx*dx + dz*dz); // by radius (more accurate but expensive than box)
            if(currDistance < distance){
                //[result addObject: oc];
            }
        }
        
    }
    
    
    NSTimeInterval finish = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"   fast time: %f   size: %d", (finish - start), m_iCount );
    
    return result;
}

-(void) removeAllObjects
{

}

-(void) addObject:(ObjectContainer*)object
{

}



@end

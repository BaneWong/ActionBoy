//
//  FastObjectList.h
//  Vampires
//
//  Created by Jon Taylor on 12-02-10.
//  Copyright (c) 2012 Subject Reality Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectContainer.h"

@interface FastObjectList : NSObject {

    struct object_struct {
        float x;
        float z;
        ObjectContainer * oc;
    };

    int m_iCount;
    struct object_struct * str_list;
    
}

-(void) createList:(NSMutableArray*)list;

-(void) removeAllObjects;

-(void) addObject:(ObjectContainer*)object;

- (NSMutableArray*) test :(NSMutableArray*)en x:(float)locX  z:(float)locZ d:(float)distance;

@end

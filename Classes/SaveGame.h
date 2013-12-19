//
//  SaveGame.h
//  Vampires
//
//  Created by Jon Taylor on 11-04-26.
//  Copyright 2011 Subject Reality Software. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "LevelLoader.h"

@interface SaveGame : NSObject {
    
    NSString* completedLevel;
    
    NSTimeInterval lastSaved;
    
    
    NSMutableDictionary* gameProperties;
    NSMutableDictionary* delayedProperties;
}

//- (void) saveGame:(LevelLoader * ) l;
-(void) save;
-(void) loadGame;

-(bool) isTimeToGetUpdate;

-(void) setLevel:(NSString*)v;
-(NSString*) level;

-(void) setAvatarLocation:(float)x y:(float)y z:(float)z;

-(void) setHealth:(int)h;
-(int) health;

-(void) setCoins:(int)c;

@end

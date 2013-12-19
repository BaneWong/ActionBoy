//
//  SaveGame.m
//  Vampires
//
//  Created by Jon Taylor on 11-04-26.
//  Copyright 2011 Subject Reality Software. All rights reserved.
//

#import "SaveGame.h"


@implementation SaveGame

- (id)init {
    self = [super init];
    if (self) {
        lastSaved = 0;
        
        
        gameProperties = [[NSMutableDictionary alloc] init];
        delayedProperties = [[NSMutableDictionary alloc] init];
    }
    return  self;
}


-(bool) isTimeToGetUpdate {
    bool update = false;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if(lastSaved < now - 10){
        update = true;
        lastSaved = now;
	}
    return update;
}

-(void) setLevel:(NSString*)v {
    NSNumber* level = [gameProperties objectForKey:@"level"];
    if(level != nil){
        [level release];
    }
    [v retain];
    [gameProperties setValue:v forKey:@"level"];
}
-(NSString*) level {
    NSString* level = [gameProperties objectForKey:@"level"];
    return level; 
}

-(void) setAvatarLocation:(float)x y:(float)y z:(float)z {
    NSNumber* avatarLocX = [gameProperties objectForKey:@"avatarLocX"];
    if(avatarLocX != nil){
        [avatarLocX release];
    }
    avatarLocX = [[NSNumber alloc] initWithFloat:x];
    [gameProperties setValue:avatarLocX forKey:@"avatarLocX"];
    
    
}

-(void) setEnemies {
    
}



-(void) setHealth:(int)h {
    NSNumber* health = [gameProperties objectForKey:@"health"];
    if(health != nil){
        [health release];
    }
    health = [[NSNumber alloc] initWithInt:h];
    [gameProperties setValue:health forKey:@"health"];
}

-(int) health {
    int health = 100;
    NSNumber* h = [gameProperties objectForKey:@"health"];
    if(h != nil){
        health = [h intValue];
    }
    return health; 
}

-(void) setCoins:(int)c {
    NSNumber* coins = [gameProperties objectForKey:@"coins"];
    if(coins != nil){
        [coins release];
    }
    coins = [[NSNumber alloc] initWithInt:c];
    [gameProperties setValue:coins forKey:@"coins"];
}


-(void) save { // LevelLoader* :()l
    //NSLog(@" Save Game ....");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:gameProperties forKey:@"SaveGameData"];
      
}

-(void) loadGame {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [gameProperties release];
    gameProperties = [prefs objectForKey:@"SaveGameData"];
}


- (void) dealloc {
    [gameProperties release];
    [delayedProperties release];
    [super dealloc];
}

@end

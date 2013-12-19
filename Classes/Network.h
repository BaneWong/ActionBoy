//
//  Network.h
//  Vampires
//
//  Created by Jon taylor on 11-02-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomURLConnection.h"

@interface Network : NSObject {
	NSMutableData * data;
	
	float prevAvatarX;
	float prevAvatarY;
	float prevAvatarZ;
	
	float avatarX;
	float avatarY;
	float avatarZ;
    float avatarAngle;

	Network * delegateObject;
	NSMutableDictionary *receivedData;
	int requestID;
	
	NSTimeInterval lastSent;
	
	
	NSObject* callback;
    NSString* deviceIDx;
    
    NSString* level;
}

- (void)send;
- (void) setAvatarLocationX:(float)x y:(float)y z:(float)z level:(NSString*)l angle:(float)a;
- (void) setCallback:(NSObject*)c;

@end

//
//  CustomURLConnection.h
//  Vampires
//
//  Created by Jon taylor on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomURLConnection : NSURLConnection {
	NSString *tag;
}

@property (nonatomic, retain) NSString *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag;

@end
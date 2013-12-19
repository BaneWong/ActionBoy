//
//  Network.m
//  Vampires
//
//  Created by Jon taylor on 11-02-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Network.h"


@implementation Network

- (id)init {
    self = [super init];
    if (self) {
        avatarX = 0;
        avatarY = 0;
        avatarZ = 0;
        avatarAngle = 0;
        
        prevAvatarX = 0;
        prevAvatarY = 0;
        prevAvatarZ = 0;
        
        delegateObject = self;
        
        data = [ [ NSMutableData data ] retain ];
        receivedData = [[NSMutableDictionary alloc] init];
        requestID = 0;
        lastSent = 0;
        
        //[self startMyThread];
        
        
        //NSLog(@" 1 %@", self);
        
        //[super init];
        
        
        //NSString *urlString = [NSString stringWithFormat:@"http://subjectreality.appspot.com/updatePlayer.jsp?x=%@&y=%@&z=%@", avatarX, avatarY, avatarZ];
        //NSURL *url1 = [NSURL URLWithString:urlString];
        //[self startAsyncLoad:url1 tag:@"boa" ];
        
        
        //NSLog(@"device name: %@", [[UIDevice currentDevice] name]);
        //deviceIDx = [[NSString alloc] initWithFormat:@" x " ]; // ,  [[UIDevice currentDevice] name]
        
        
        //[self send];
    }
	return self;
}

- (void) setCallback:(NSObject*)c 
{
	callback = c;
}

- (void) setAvatarLocationX:(float)x y:(float)y z:(float)z level:(NSString*)l angle:(float)a
{
	//[prevAvatarX release];
	//[prevAvatarY release];
	//[prevAvatarZ release];
	prevAvatarX = avatarX;
	prevAvatarY = avatarY;
	prevAvatarZ = avatarZ;
	avatarX = x;
	avatarY = y;
	avatarZ = z;
	avatarAngle = a;
    
    [level release];
    [l retain];
    level = l;
	
    //NSLog(@"setAvatarLocation  %f  %f  %f " , x, y, z);
	
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	
	if(
	   ( prevAvatarX  != avatarX )  ){
		if(lastSent < now - 1){
			//NSLog(@" time: %f ", now);
			
			
			[self send];
			lastSent = now;
		}
	}
}

- (void)startAsyncLoad:(NSURL*)url tag:(NSString*)tag {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	CustomURLConnection *connection = [[CustomURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES tag:tag];
	
	if (connection) {
		[receivedData setObject:[[NSMutableData data] retain] forKey:connection.tag];
	}
}

//- (NSMutableData*)dataForConnection:(CustomURLConnection*)connection {
//	NSMutableData *data = [receivedData objectForKey:connection.tag];
//	return data;
//}

- (void)send 
{
    
   
    NSString *uid = [[[UIDevice currentDevice] name] stringByReplacingOccurrencesOfString: @" " withString: @"+"];
    
	NSString *urlString = [NSString 
                           stringWithFormat:@"http://subjectreality.appspot.com/updatePlayer.jsp?x=%f&y=%f&z=%f&uid=%@&level=%@&angle=%f", 
                           avatarX, avatarY, avatarZ, uid, level, avatarAngle];
	//NSLog(urlString);
	
	NSURL *url = [ NSURL URLWithString:urlString];
	NSURLRequest *request = [ [ NSURLRequest alloc ] initWithURL: url
								cachePolicy: NSURLRequestReloadIgnoringLocalCacheData  
								timeoutInterval: 10.0
							 ];
	//NSURLRequestReturnCacheDataElseLoad
	
	NSURLConnection * connection = [ [ NSURLConnection alloc ]
									initWithRequest: request 
									delegate: self ];
	
    //NSLog(@" send done");
	lastSent = [NSDate timeIntervalSinceReferenceDate];
	
	[request release];
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//NSLog(@"didReceiveResponse");
    [ data setLength: 0 ];
	//NSMutableData *dataForConnection = [self dataForConnection:(CustomURLConnection*)connection];
	//[dataForConnection setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incomingData
{
	[ data appendData: incomingData ];
	//NSMutableData *dataForConnection = [self dataForConnection:(CustomURLConnection*)connection];
	//[dataForConnection appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"w00t! my image is finished loading ! ");
	
	///NSMutableData *dataForConnection = [self dataForConnection:(CustomURLConnection*)connection];
	//[connection release];
	
	NSString * dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	if( [data length] != 45315 ){
		//NSLog(@" data %@ ", dataString);
	}
	
	
	  
	NSRange range = [dataString rangeOfString : @"</xml>"];
	NSRange range2 = [dataString rangeOfString:@"</xml>" options:NSBackwardsSearch  ];
	//NSRange duplicate = [self rangeOfString:@"</xml>" inString:dataString atOccurence:2];

	
	//NSLog(@" data %d  %d %d", [data length], range.location, range2.location );
	
	if(callback != nil && range.location != NSNotFound && range.location == range2.location){
		
		[callback reloadLevel:data];
		//NSLog(@"found");
		
	} else {
		
		[ data setLength: 0 ];
	}
	
	//[ data release ];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:
(NSError *)error
{
    NSLog(@"Uh oh. My query failed with error: %@", [ error localizedDescription ]);
    [ data release ];
}

- (void) startMyThread {
	[NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
}

- (void) run { // :(Network*)delegateObject
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/* Do your threaded code here */
	while(true){
		//NSLog(@" Thread %@   ", self);
		
		if(
			( prevAvatarX != avatarX )  ){
			//NSLog(@" Send");
			
			//[self send];
			
			
			NSString *urlString = [NSString stringWithFormat:@"http://subjectreality.appspot.com/updatePlayer.jsp?x=%@&y=%@&z=%@", avatarX, avatarY, avatarZ];
			NSURL *url1 = [NSURL URLWithString:urlString];
			
			NSString * tag = [[NSString alloc] initWithFormat:@"%d", requestID ];
			NSLog(@" -------- tag %@", tag);
			[self startAsyncLoad:url1 tag:tag ];
			requestID++;
			
			//Network* n = [[Network alloc] init];
			//[n send];
		}
		
		[NSThread sleepForTimeInterval:1.0];
	}
	
	[pool release];
} 


- (NSRange)rangeOfString:(NSString *)substring
                inString:(NSString *)string
             atOccurence:(int)occurence
{
	int currentOccurence = 0;
	NSRange rangeToSearchWithin = NSMakeRange(0, string.length);
	
	while (YES)
	{
		currentOccurence++;
		NSRange searchResult = [string rangeOfString: substring
											 options: NULL
											   range: rangeToSearchWithin];
		
		if (searchResult.location == NSNotFound)
		{
			return searchResult;
		}
		if (currentOccurence == occurence)
		{
			return searchResult;
		}
		
		int newLocationToStartAt = searchResult.location + searchResult.length;
		rangeToSearchWithin = NSMakeRange(newLocationToStartAt, string.length - newLocationToStartAt);
	}
}

@end

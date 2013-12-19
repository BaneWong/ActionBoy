//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "VampiresAppDelegate.h"
#import "GLView.h"

#import "SoundPlayer.h" 
#import <AVFoundation/AVFoundation.h>
//#import "GANTracker.h"

static const NSInteger kGANDispatchPeriodSec = 10;
static NSString* const kAnalyticsAccountId = @"UA-31863097-1";

@implementation ___PROJECTNAMEASIDENTIFIER___AppDelegate

@synthesize window;
@synthesize glView;
@synthesize sound;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // analytics
    /*
    [[GANTracker sharedTracker] startTrackerWithAccountID:kAnalyticsAccountId
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    NSError *error;
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                         name:@"iOS Action Boy"
                                                        value:@"iv1"
                                                    withError:&error]) {
        NSLog(@"error in setCustomVariableAtIndex");
    }
    if (![[GANTracker sharedTracker] trackEvent:@"Application iOS Action Boy"
                                         action:@"Launch iOS Action Boy"
                                          label:@"Action Boy iOS"
                                          value:99
                                      withError:&error]) {
        NSLog(@"error in trackEvent");
    }
    if (![[GANTracker sharedTracker] trackPageview:@"/app_entry_point"
                                         withError:&error]) {
        NSLog(@"error in trackPageview");
    }
     */
    // end analytics
    
    
	glView.animationInterval = 1.0 / kRenderingFrequency;
	[glView startAnimation];
	
	//NSLog(@" app launched ");
	//SoundPlayer * s2;
	//s2 = [[[sound alloc] init] autorelease];
	//[s2 playMusic];
	//NSLog(@" app launched 2 %d ", [self test ] );
	
	//double n = [sound test];
	//NSLog(@" app n %d", n  );
	
/*	
	AVAudioPlayer * audioPlayer;
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"diatonis_traj_one-to-be_sur" ofType:@"mp3"]]; 
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	audioPlayer.volume = 0.4;
	audioPlayer.numberOfLoops = -1;
	//[audioPlayer play];
*/	
	
	// Flip the simulator to the right
	[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated: NO];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:( 1.0f / 30.0f )];
//    [[UIAccelerometer sharedAccelerometer] setDelegate:self];	
	
}


- (void)applicationWillResignActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / kInactiveRenderingFrequency;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 60.0;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //NSLog(@" Background ");
}

- (void)dealloc {
    //[[GANTracker sharedTracker] stopTracker];
    //NSLog(@" Shutdown ");
    
	[window release];
	[glView release];
	[super dealloc];
}

@end

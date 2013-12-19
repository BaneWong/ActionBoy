//
//  RateApp.m
//  Vampires
//
//  Created by Jon Taylor on 12-06-02.
//  Copyright (c) 2012 Subject Reality Software. All rights reserved.
//

#import "RateApp.h"

@implementation RateApp

// http://itunes.apple.com/ca/app/action-boy/id500888326?mt=8
// https://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?id=500888326&type=Purple+Software
//[[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];


/**
 * rateApp
 *
 * Description: Launch itunes rate this app page
 */
- (void) rateApp {
    NSString * url = [NSString stringWithFormat:@"https://userpub.itunes.apple.com/WebObjects/MZUserPublishing.woa/wa/addUserReview?id=500888326&type=Purple+Software"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
}


/**
 * shareWithFriends
 *
 * Description: launch share app with friends web page.
 */
- (void) shareWithFriends {
    NSString * url = [NSString stringWithFormat:@"http://www.subjectreality.com/actionboy/share.html"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
}

@end

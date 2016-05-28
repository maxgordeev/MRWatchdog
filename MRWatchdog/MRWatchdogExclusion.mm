//
//  MRWatchdogExclusion.mm
//  ICQ
//
//  Created by Max Gordeev on 18/02/15.
//  Copyright © 2016 Mail.Ru. All rights reserved.
//

#import "MRWatchdog.h"
#import "MRWatchdogExclusion.h"
#import <UIKit/UIKit.h>

@implementation MRWatchdogExclusion

- (void)start
{
    [self registerApplicationObservers];
    [self registerKeyboardObservers];
}

- (void)stop
{
    [self unregisterApplicationObservers];
    [self unregisterKeyboardObservers];
}

#pragma mark Keyboard

- (void)registerKeyboardObservers
{
    auto manager = NSNotificationCenter.defaultCenter;
    [manager addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [manager addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)unregisterKeyboardObservers
{
    auto manager = NSNotificationCenter.defaultCenter;
    [manager removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [manager removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *__unused)notification
{
    [MRWatchdog stop];
}

- (void)keyboardDidShow:(NSNotification *__unused)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MRWatchdog start];
    });
}

#pragma mark UIApplication

- (void)registerApplicationObservers
{
    auto manager = NSNotificationCenter.defaultCenter;

    [manager addObserver:self
                selector:@selector(applicationWillEnterForeground:)
                    name:UIApplicationDidBecomeActiveNotification
                  object:nil];

    [manager addObserver:self
                selector:@selector(applicationWillResignActive:)
                    name:UIApplicationWillResignActiveNotification
                  object:nil];

    [manager addObserver:self
                selector:@selector(applicationWillTerminate:)
                    name:UIApplicationWillTerminateNotification
                  object:nil];
}

- (void)unregisterApplicationObservers
{
    auto manager = NSNotificationCenter.defaultCenter;
    [manager removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [manager removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [manager removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *__unused)application
{
    [MRWatchdog start];
}

- (void)applicationWillResignActive:(UIApplication *__unused)application
{
    [MRWatchdog stop];
}

- (void)applicationWillTerminate:(UIApplication *__unused)application
{
    [MRWatchdog stop];
}

@end

//
//  MRWatchdog.h
//  ICQ
//
//  Created by Max Gordeev on 18/02/15.
//  Copyright © 2016 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRWatchdog : NSObject

/**
 @param aDelay Delay in milliseconds
 @param aHandler Invokes after catching UI freeze
 */
+ (void)setupWithDelay:(const NSTimeInterval)aDelay handler:(dispatch_block_t)aHandler;

/**
 Stop observing UI events.
 */
+ (void)start;

/**
 Stop observing UI events.
 */
+ (void)stop;

/**
 Stops watchdog for (2 * delay) ms.
 */
+ (void)skip;

@end

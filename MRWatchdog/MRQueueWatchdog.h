//
//  MRQueueWatchdog.h
//  ICQ
//
//  Created by Max Gordeev on 18/02/15.
//  Copyright © 2016 Mail.Ru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRQueueWatchdog : NSObject

/**
 @param aObservingQueue Observing GCD queue.
 @param aDelay Delay in milliseconds.
 @param aHandler Invokes after catching queue freeze.
 */
- (nonnull instancetype)initWithObservingQueue:(nonnull dispatch_queue_t)aObservingQueue
                                         delay:(const int64_t)aDelay
                                       handler:(nonnull dispatch_block_t)aHandler NS_DESIGNATED_INITIALIZER;

- (void)start;

- (void)stop;

- (void)skip;

@end

//
//  MRWatchdog.mm
//  ICQ
//
//  Created by Max Gordeev on 18/02/15.
//  Copyright © 2016 Mail.Ru. All rights reserved.
//

#import "MRQueueWatchdog.h"
#import "MRWatchdog.h"
#import "MRWatchdogExclusion.h"
#include <stdexcept>

@interface MRWatchdog ()
{
	MRQueueWatchdog *_watchdog;
	MRWatchdogExclusion *_exclusions;
}

@end

@implementation MRWatchdog

#pragma mark - API

+ (void)setupWithDelay:(const NSTimeInterval)aDelay handler:(dispatch_block_t)aHandler
{
	[self.class.privateInstance _setupWithDelay:aDelay handler:aHandler];
}

+ (void)start
{
	[self.class.privateInstance _start];
}

+ (void)stop
{
	[self.class.privateInstance _stop];
}

+ (void)skip
{
	[self.class.privateInstance _skip];
}

#pragma mark - Implementation

- (void)_setupWithDelay:(const NSTimeInterval)aDelay handler:(dispatch_block_t)aHandler
{
	NSAssert(aDelay > 0, @"Watchdog delay should be greater 0");
	NSAssert(aHandler != nil, @"Watchdog handler shouldn't be empty.");

	if (_watchdog != nil)
	{
		[_watchdog stop];
	}

	_watchdog = [[MRQueueWatchdog alloc] initWithObservingQueue:dispatch_get_main_queue() delay:aDelay handler:aHandler];
}

- (void)_start
{
	NSAssert(_watchdog != nil, @"Please setup watchdog with delay and handler");
	[_exclusions start];
	[_watchdog start];
}

- (void)_stop
{
	NSAssert(_watchdog != nil, @"Please setup watchdog with delay and handler");
	[_watchdog stop];
	[_exclusions stop];
}

- (void)_skip
{
	NSAssert(_watchdog != nil, @"Please setup watchdog with delay and handler");
	[_watchdog skip];
}

#pragma mark - Lifecyrcle

+ (instancetype)privateInstance
{
	static MRWatchdog *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [MRWatchdog new];
	});
	return instance;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_exclusions = [MRWatchdogExclusion new];
		_watchdog = nil;
	}
	return self;
}

@end

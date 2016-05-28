//
//  MRQueueWatchdog.mm
//  ICQ
//
//  Created by Max Gordeev on 18/02/15.
//  Copyright © 2016 Mail.Ru. All rights reserved.
//

#import "MRQueueWatchdog.h"
#include <atomic>
#include <stdexcept>

@interface MRQueueWatchdog ()
{
	uint64_t _delay;
	uint64_t _skipDelay;
	dispatch_source_t _pingTimer;
	std::atomic_bool _pingInvoked;
	std::atomic_bool _exit;
	int _skipID;
	dispatch_queue_t _observingQueue;
	dispatch_queue_t _queue;
	dispatch_block_t _handler;
}

@end

@implementation MRQueueWatchdog

- (nonnull instancetype)init
{
	return [self initWithObservingQueue:dispatch_get_main_queue()
	                              delay:0
	                            handler:^{
	                            }];
}

- (nonnull instancetype)initWithObservingQueue:(nonnull dispatch_queue_t)aObservingQueue
                                         delay:(const int64_t)aDelay
                                       handler:(nonnull dispatch_block_t)aHandler
{
	NSParameterAssert(aObservingQueue != nil);
	NSParameterAssert(aDelay > 0);
	NSParameterAssert(aHandler != nil);

	self = [super init];
	if (self)
	{
		_observingQueue = aObservingQueue;
		_delay = aDelay * NSEC_PER_MSEC;
		_handler = [aHandler copy];
		_skipDelay = aDelay * 2 * NSEC_PER_MSEC;
		_queue = dispatch_queue_create("watchdog", DISPATCH_QUEUE_SERIAL);
		_pingTimer = nil;
		_pingInvoked = true; // To pass initial ping check.
		_exit = false;
		_skipID = 0;
	}
	return self;
}

#pragma mark - API

- (void)start
{
	dispatch_async(_queue, ^{
		[self _start];
	});
}

- (void)_start
{
	if (_pingTimer != nil && (!_exit || _skipID > 0))
	{
		return;
	}

	if (_pingTimer == nil)
	{
		[self setupTimer];
	}

	[self resume];
}

- (void)stop
{
	dispatch_async(_queue, ^{
		[self _stop];
	});
}

- (void)_stop
{
	if (_exit)
	{
		return;
	}

	_exit = true;
	_skipID = 0;
	_pingInvoked = true;
	dispatch_suspend(_pingTimer);
}

- (void)skip
{
	dispatch_async(_queue, ^{
		[self _skip];
	});
}

- (void)_skip
{
	if (_pingTimer == nil)
	{
		return;
	}

	const auto skipID = [self prepareForSkip];

	__weak auto weakSelf = self;
	dispatch_after(_skipDelay, _queue, ^{
		__strong auto strongSelf = weakSelf;
		if (strongSelf != nil)
		{
			[strongSelf handleSkipCompletion:skipID];
		}
	});
}

#pragma mark - Implementation

- (int)prepareForSkip
{
	_exit = true;
	_pingInvoked = true;
	dispatch_suspend(_pingTimer);
	_skipID = rand();
	return _skipID;
}

- (void)handleSkipCompletion:(const int)skipID
{
	if (skipID == _skipID)
	{
		[self resume];
	}
}

- (void)setupTimer
{
	auto timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
	if (timer)
	{
		constexpr uint64_t leeway = (1ull * NSEC_PER_SEC) / 10ull;
		dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0), _delay, leeway);
		dispatch_source_set_event_handler(timer, ^{
			[self ping];
		});
		_pingTimer = timer;
	}
}

- (void)resume
{
	_pingInvoked = true;
	_exit = false;
	_skipID = 0;
    
    if (_pingTimer != nil)
    {
        dispatch_resume(_pingTimer);
        _pingTimer = nil;
    }
}

- (void)ping
{
	if (_exit)
	{
		return;
	}

	// Check previous ping.
	if (!_pingInvoked)
	{
		_handler();
	}

	_pingInvoked = false;

	// Send ping to observing queue.
	__weak auto weakSelf = self;
	dispatch_async(_observingQueue, ^{
		__strong auto strongSelf = weakSelf;
		if (strongSelf != nil)
		{
			strongSelf->_pingInvoked = true;
		}
	});
}

@end

# MRWatchdog

## Usage

Setup with delay and handler:
```objective-c
NSTimeInterval const delayInMSec = 300; // ms
[MRWatchdog setupWithDelay:delayInMSec handler:^{
   std::runtime_error("Possible UI freeze!");
}];
```

Start to catch use-cases that are freezes UI for more than 300 ms:
```objective-c
[MGWatchdog start];
```

After catching an exception you can simply analyze Main thread call stack and find the problem in your code.


Stop the watchdog:
```objective-c
[MGWatchdog stop];
```


If you have an unfixable UI freeze (ex. using of thirdparty UI libraries) you can simply tell watchdog to skip observing freezes for (2 * delay) ms:
```objective-c
[MGWatchdog skip];
```

## Installation

MGWatchdog is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
platform :ios, '7.0'
pod "MRWatchdog"
```
# MRWatchdog

## Usage

Setup with delay and handler:
```objective-c
NSTimeInterval const delayInMSec = 300; // ms
[MRWatchdog setupWithDelay:delayInMSec handler:^{
   throw std::runtime_error("Possible UI freeze!");
}];
```

Start to catch use-cases that are freezes UI for more than 300 ms:
```objective-c
[MRWatchdog start];
```

After catching an exception you can simply analyze Main thread call stack and find the problem in your code.


Stop the watchdog:
```objective-c
[MRWatchdog stop];
```


If you have an unfixable UI freeze (ex. using of thirdparty UI libraries) you can simply tell watchdog to skip observing freezes for (2 * delay) ms:
```objective-c
[MRWatchdog skip];
```
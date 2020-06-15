# BestLogger

**THE REASON ITS CALLED BEST LOGGER IS BECAUSE EASYLOGGER WAS TAKEN AND SUBDEPENDECIES MIGHT HAVE LOGGER ALREADY DECLARED**

This is a very simple, one file, swift logger which supports multiple arguments. 

We support 6 logging levels
* .trace = 0 // should be used for application flow. e.g., viewdidload executed
* .debug // used for debugging
* .info // used for informative messages. e.g., application started from app delegate
* .warning // e.g., this method could lead to memory leaks
* .error // e.g., JSONDecoder() failed to while casting
* .none // Abosolutely no logs. logger.none() doesn't exist.

## Usage

```swift
import BestLogger
let logger = BestLogger(label: "TestLogger", level: .debug) // .trace = 0, .debug, .info, .warning, .error, .none

logger.debug("this is the best swift logger :P") // will print 
logger.warning("Fix me:") // will print
logger.trace("application started") // will not print
```

## Development

* Add static method to be used across different classes
* Make a PR for any improvements
* Contact - Shubham Rathi (twitter @metallicalfa)

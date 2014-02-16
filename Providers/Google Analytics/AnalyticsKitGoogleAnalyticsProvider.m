//
//  AnalyticsKitGoogleAnalyticsProvider.m
//  S2M
//
//  Created by François Benaiteau on 02/14//13.
//

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "AnalyticsKitGoogleAnalyticsProvider.h"

static NSMutableDictionary *timedEvents;
static dispatch_queue_t timingQueue;

// Constants used to parsed dictionnary to match Google Analytics tracker properties
static NSString* const kCategory = @"Category";
static NSString* const kLabel = @"Label";
static NSString* const kAction = @"Action";
static NSString* const kValue = @"Value";

// Constants for timedEvents structure
static NSString* const kTime = @"time";
static NSString* const kProperties = @"properties";


@interface AnalyticsKitGoogleAnalyticsProvider ()

-(id)valueFromDictionnary:(NSDictionary*)dictionnary forKey:(NSString*)key;
@end


@implementation AnalyticsKitGoogleAnalyticsProvider

#if !__has_feature(objc_arc)
-(void)dealloc
{
    dispatch_release(timingQueue);
    [timedEvents release];
    [super dealloc];
}
#endif

-(id<AnalyticsKitProvider>)initWithTrackingID:(NSString *)trackingID
{
    self = [super init];
    if (self) {
        [[GAI sharedInstance] trackerWithTrackingId:trackingID];
        timedEvents = [[NSMutableDictionary alloc] init];
        timingQueue = dispatch_queue_create("analyticsKit.goolgeAnalytics.provider", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

// Lifecycle
-(void)applicationWillEnterForeground{}

-(void)applicationDidEnterBackground{}

-(void)applicationWillTerminate{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker close];
}

-(void)uncaughtException:(NSException *)exception
{
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	NSString * model = [[UIDevice currentDevice] model];
	NSString * version = [[UIDevice currentDevice] systemVersion];
	NSArray * backtrace = [exception callStackSymbols];
	NSString * description = [NSString stringWithFormat:@"%@.%@.%@.Backtrace:%@",
							  model,
							  version,
							  exception.description,
							  backtrace];
	
	[tracker send:[[GAIDictionaryBuilder
					createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
					withFatal:NO] build]];
}


//Logging events
-(void)logScreen:(NSString *)screenName
{
//    id tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker sendView:screenName];

	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	
	// Set the screen name on the tracker so that it is used in all hits sent from this screen.
	[tracker set:kGAIScreenName value:screenName];
	
	// Send a screenview.
	[tracker send:[[GAIDictionaryBuilder createAppView]  build]];
}

-(void)logEvent:(NSString *)event
{
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	
	// Create a dictionary using the builder to describe the custom event
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:nil action:event label:nil value:nil] build]];
}

-(void)logEvent:(NSString *)event withProperty:(NSString *)key andValue:(NSString *)value
{
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	
	// Create a dictionary using the builder to describe the custom event
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:key action:event label:value value:nil] build]];
}

-(void)logEvent:(NSString *)event withProperties:(NSDictionary *)dict
{
    NSString* category = [self valueFromDictionnary:dict forKey:kCategory];
    NSString* label = [self valueFromDictionnary:dict forKey:kLabel];
    NSNumber* value = [self valueFromDictionnary:dict forKey:kValue];
    
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	
	// Create a dictionary using the builder to describe the custom event
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:event label:label value:value] build]];
}

-(void)logEvent:(NSString *)event timed:(BOOL)timed
{
    if (!timed) {
        [self logEvent:event];
    }else{
        dispatch_sync(timingQueue, ^{
                          timedEvents[event] = [NSDate date];
                      });
    }    
}

-(void)logEvent:(NSString *)event withProperties:(NSDictionary *)dict timed:(BOOL)timed
{
    if (!timed) {
        [self logEvent:event withProperties:dict];
    }else{
        __block NSDictionary* properties = dict;
        dispatch_sync(timingQueue, ^{
            if (properties == nil) {
                properties = @{};
            }
            timedEvents[event] = @{kTime : [NSDate date],
                                   kProperties: properties};
        });
    }
    
}

-(void)endTimedEvent:(NSString *)event withProperties:(NSDictionary *)dict
{
    NSMutableDictionary* properties =  [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSDate* startDate;
    id timeEvent = timedEvents[event];

    // merging properties from started event with given properties if necessary
    if ([timeEvent isKindOfClass:[NSDictionary class]]) {
        [properties addEntriesFromDictionary:timeEvent[kProperties]];
        startDate = timeEvent[kTime];
    }else{
        startDate = timeEvent;
    }
    
    NSString* category = [self valueFromDictionnary:properties forKey:kCategory];
    NSString* label = [self valueFromDictionnary:properties forKey:kLabel];

    __block NSTimeInterval time;
    dispatch_sync(timingQueue, ^{
        // calculating the elapsed time
        NSDate* endDate = [NSDate date];
        time = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970;
        // removed time which will be logged
        [timedEvents removeObjectForKey:event];
    });

    id tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createTimingWithCategory:category   // Timing category (required)
														interval:@(time)        // Timing interval (required)
															name:event  // Timing name
														   label:label] build]];    // Timing label

	
#if !__has_feature(objc_arc)
    [properties release];
#endif

}

-(void)logError:(NSString *)name message:(NSString *)message exception:(NSException *)exception
{
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	NSString * model = [[UIDevice currentDevice] model];
	NSString * version = [[UIDevice currentDevice] systemVersion];
	NSArray * backtrace = [exception callStackSymbols];
	NSString * description = [NSString stringWithFormat:@"%@.%@.%@.Backtrace:%@",
							  model,
							  version,
							  exception.description,
							  backtrace];
	
	[tracker send:[[GAIDictionaryBuilder
					createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
					withFatal:NO] build]];
}

-(void)logError:(NSString *)name message:(NSString *)message error:(NSError *)error
{
	id tracker = [[GAI sharedInstance] defaultTracker];
	
	NSString * model = [[UIDevice currentDevice] model];
	NSString * version = [[UIDevice currentDevice] systemVersion];
	NSString * description = [NSString stringWithFormat:@"%@.%@:%@:%@:%@",
							  model,
							  version,
							  name,
							  message,
							  error];
	
	[tracker send:[[GAIDictionaryBuilder
					createExceptionWithDescription:description  // Exception description. May be truncated to 100 chars.
					withFatal:NO] build]];
}

#pragma mark - Extra methods

-(void)enableDebug:(BOOL)enabled
{
	[[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
}

-(void)enableHandleUncaughtExceptions:(BOOL)enabled
{
    [GAI sharedInstance].trackUncaughtExceptions = enabled;
}

#pragma mark - Private methods

-(id)valueFromDictionnary:(NSDictionary*)dictionnary forKey:(NSString*)key
{
    if (dictionnary[key.lowercaseString]) {
        return dictionnary[key.lowercaseString];
    }

    if (dictionnary[key]) {
        return dictionnary[key];
    }
    return nil;
}
@end

//
//  AnalyticsKit.m
//  AnalyticsKit
//
//  Created by Christopher Pickslay on 9/8/11.
//  Copyright (c) 2011 Two Bit Labs. All rights reserved.
//

#import "AnalyticsKit.h"

@implementation AnalyticsKit

NSString* const AnalyticsKitEventTimeSeconds = @"AnalyticsKitEventTimeSeconds";

static NSArray *_loggers = nil;

+(void)initialize {
    _loggers = [[NSArray alloc] init];
}

+(void)initializeLoggers:(NSArray *)loggers {
    #if !__has_feature(objc_arc)
    [loggers retain];
    [_loggers release];
    #endif
    _loggers = loggers;
}

+(NSArray *)loggers {
    return _loggers;
}

+(void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
	AKINFO(@"");
	for (id<AnalyticsKitProvider> logger in _loggers) {
		if ([logger respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)])	{
			[logger application:application didFinishLaunchingWithOptions:launchOptions];
		}
	}
}

+(void)applicationWillEnterForeground {
    AKINFO(@"");
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger applicationWillEnterForeground];
    }    
}

+(void)applicationDidEnterBackground {
    AKINFO(@"");
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger applicationDidEnterBackground];
    }        
}

+(void) applicationDidBecomeActive:(UIApplication *) application {
	AKINFO(@"");
	for (id<AnalyticsKitProvider> logger in _loggers) {
		if ([logger respondsToSelector:@selector(applicationDidBecomeActive:)])	{
			[logger applicationDidBecomeActive:application];
		}
	}
}

+(void)applicationWillTerminate {
    AKINFO(@"");
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger applicationWillTerminate];
    }    
}

+(void)uncaughtException:(NSException *)exception {
    AKINFO(@"");
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger uncaughtException:exception];
    }    
    
}

+(BOOL) application:(UIApplication *) application handleOpenURL:(NSURL *) url {
	AKINFO(@"");
	BOOL result = false;

	for (id<AnalyticsKitProvider> logger in _loggers) {
		if ([logger respondsToSelector:@selector(application:handleOpenURL:)]) {
			result = result || [logger application:application handleOpenURL:url];
		}
	}

	return result;
}

+(BOOL) application:(UIApplication *) application openURL:(NSURL *) url
        sourceApplication:(NSString *) sourceApplication annotation:(id) annotation {
	AKINFO(@"");
	BOOL result = false;

	for (id<AnalyticsKitProvider> logger in _loggers) {
		if ([logger respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
			result = result || [logger application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
		}
	}

	return result;
}

+(void)logScreen:(NSString *)screenName {
    AKINFO(@"%@", screenName);
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger logScreen:screenName];
    }
    
}

+(void)logEvent:(NSString *)event {
    AKINFO(@"%@", event);
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger logEvent:event];
    }
}

+(void)logEvent:(NSString *)event withProperties:(NSDictionary *)dict {
    AKINFO(@"%@ withProperties: %@", event, dict);
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger logEvent:event withProperties:dict];
    }    
}

+(void)logEvent:(NSString *)event withProperty:(NSString *)property andValue:(NSString *)value {
    if (property == nil) property = @"nil";
    if (value == nil) value = @"nil";
    AKINFO(@"%@ withProperty: %@ andValue: %@", event, property, value);
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger logEvent:event withProperty:property andValue:value];
    }
}

+(void)logEvent:(NSString *)eventName timed:(BOOL)timed{
    AKINFO(@"%@ timed: %@", eventName, timed ? @"YES" : @"NO");
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger logEvent:eventName timed:timed];
    }
}

+(void)logEvent:(NSString *)eventName withProperties:(NSDictionary *)dict timed:(BOOL)timed{
    AKINFO(@"%@ withProperties: %@ timed: %@", eventName, dict, timed ? @"YES" : @"NO");
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger logEvent:eventName withProperties:dict timed:timed];
    }
}

+(void)endTimedEvent:(NSString *)eventName withProperties:(NSDictionary *)dict{
    AKINFO(@"%@ withProperties: %@ ended", eventName, dict);
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger endTimedEvent:eventName withProperties:dict];
    }
}

+(void)logError:(NSString *)name message:(NSString *)message exception:(NSException *)exception {
    AKERROR(@"%@: %@", name, message);
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger logError:name message:message exception:exception];
    }    
}

+(void)logError:(NSString *)name message:(NSString *)message error:(NSError *)error {
    AKERROR(@"%@: %@", name, message);
    for (id<AnalyticsKitProvider> logger in _loggers) {
        [logger logError:name message:message error:error];
    }
}


@end

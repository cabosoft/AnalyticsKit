//
//  AnalyticsKitTests.m
//  AnalyticsKitTests
//
//  Created by Christopher Pickslay on 10/23/13.
//  Copyright (c) 2013 Two Bit Labs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "AnalyticsKit.h"
#import "AnalyticsKitAdjustIOProvider.h"
#import "AnalyticsKitApsalarProvider.h"
#import "AnalyticsKitCrashlyticsProvider.h"
#import "AnalyticsKitDebugProvider.h"
#import "AnalyticsKitFlurryProvider.h"
#import "AnalyticsKitGoogleAnalyticsProvider.h"
#import "AnalyticsKitLocalyticsProvider.h"
#import "AnalyticsKitMixpanelProvider.h"
#import "AnalyticsKitParseProvider.h"
#import "AnalyticsKitUnitTestProvider.h"

@interface AnalyticsKitTests : XCTestCase

@end

@implementation AnalyticsKitTests

-(void)testExample {
    NSArray *providers = @[
                           [[AnalyticsKitAdjustIOProvider alloc] initWithAppToken:nil productionEnvironmentEnabled:NO],
                           [[AnalyticsKitApsalarProvider alloc] initWithAPIKey:nil andSecret:nil andLaunchOptions:nil],
                           [AnalyticsKitCrashlyticsProvider new],
                           [AnalyticsKitDebugProvider new],
                           [[AnalyticsKitFlurryProvider alloc] initWithAPIKey:nil],
                           // testing multiple google tracker instances
                           [[AnalyticsKitGoogleAnalyticsProvider alloc] initWithTrackingID:@"trackerId1"],
                           [[AnalyticsKitGoogleAnalyticsProvider alloc] initWithTrackingID:@"trackerId2"],
                           // Localytics validates the key when you initialize it, so it can't be empty or fake
                           // This key is for the "AnalyticsKit iOS app"
                           [[AnalyticsKitLocalyticsProvider alloc] initWithAPIKey:@"03a5f224fe2408887ac32dd-68937c2c-fd90-11e4-b9d0-00eba64cb0ec"],
                           [[AnalyticsKitMixpanelProvider alloc] initWithAPIKey:nil],
                           [[AnalyticsKitParseProvider alloc] initWithApplicationId:@"x" clientKey:@"y"],
                           [AnalyticsKitUnitTestProvider new]
                           ];
    [AnalyticsKit initializeLoggers:providers];
    
    NSMutableArray *mocks = [NSMutableArray array];
    for (id provider in providers) {
        id mock = [OCMockObject partialMockForObject:provider];
        [mocks addObject:mock];
        [[mock expect] logEvent:@"foo"];
    }
    
    [AnalyticsKit logEvent:@"foo"];
    
    for (id mock in mocks) {
        [mock verify];
    }
}

@end

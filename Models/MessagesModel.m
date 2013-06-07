//
//  Messages.m
//  LiveMobile
//
//  Created by Soroush Pour on 5/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "MessagesModel.h"

@interface MessagesModel () {
    
}

@end

@implementation MessagesModel

- (NSMutableArray*) getMessages
{
    
    NSMutableArray *tempMessages;

    NSArray* keys = [[NSArray alloc] initWithObjects:@"dataWithText", @"date", @"type", nil];
    NSArray* vals1 = [[NSArray alloc] initWithObjects:@"My first received message!",
                      [NSDate dateWithTimeIntervalSinceNow:0-3000],
                      @"agent", nil];
    NSArray* vals2 = [[NSArray alloc] initWithObjects:@"My second sent message!",
                      [NSDate dateWithTimeIntervalSinceNow:0-2000],
                      @"customer", nil];
    NSArray* vals3 = [[NSArray alloc] initWithObjects:@"My third received message!",
                      [NSDate dateWithTimeIntervalSinceNow:0-1000],
                      @"customer", nil];
    NSArray* vals4 = [[NSArray alloc] initWithObjects:@"My fourth received message!",
                      [NSDate dateWithTimeIntervalSinceNow:0],
                      @"agent", nil];
    
    
    NSDictionary* msg1 = [[NSDictionary alloc] initWithObjects:vals1 forKeys:keys];
    NSDictionary* msg2 = [[NSDictionary alloc] initWithObjects:vals2 forKeys:keys];
    NSDictionary* msg3 = [[NSDictionary alloc] initWithObjects:vals3 forKeys:keys];
    NSDictionary* msg4 = [[NSDictionary alloc] initWithObjects:vals4 forKeys:keys];
    
    tempMessages = [[NSMutableArray alloc] initWithObjects:msg1,msg2,msg3,msg4, nil];
    
    return tempMessages;
}

@end

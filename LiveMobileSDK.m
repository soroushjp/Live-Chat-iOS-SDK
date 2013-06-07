//
//  LiveMobile.m
//  LiveMobile
//
//  Created by Soroush Pour on 2/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "LiveMobileSDK.h"
#import "LMView.h"
#import "MessagesModel.h"

@interface LiveMobileSDK () {

    UIViewController *parentViewController;
    LMView *chatView;
    MessagesModel *msgModel;
    NSMutableArray* messages;

}

@end

@implementation LiveMobileSDK

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem
{
    
    self = [super init];
    if(!self) return self;
    
    //Get stored initial messages
    msgModel = [[MessagesModel alloc] init];
    messages = [msgModel getMessages];
    
    //generate view with loaded messages
    chatView = [[LMView alloc] initWithParentViewController:passedViewController NavigationItem:navItem];
    
    return self;

}

@end

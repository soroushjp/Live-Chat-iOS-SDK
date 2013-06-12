//
//  LiveMobile.m
//  LiveMobile
//
//  Created by Soroush Pour on 2/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "LiveMobileSDK.h"
#import "ChatController.h"
#import "ChatView.h"
#import "MessagesModel.h"
#import "LMSockets.h"   

@interface LiveMobileSDK () {

    ChatController *chatController;

}

@end

@implementation LiveMobileSDK

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem
{
    
    self = [super init];
    if(!self) return self;
    
    chatController = [[ChatController alloc] initWithParentViewController:passedViewController NavigationItem:navItem];
    
    return self;

}

@end

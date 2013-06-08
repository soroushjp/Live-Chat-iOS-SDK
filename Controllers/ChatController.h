//
//  ChatController.h
//  LiveMobile
//
//  Created by Soroush Pour on 7/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatView.h"
#import "MessagesModel.h"
#import "LMSockets.h"

@interface ChatController : NSObject  <ChatViewDelegate, SRWebSocketDelegate>

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem;

@end

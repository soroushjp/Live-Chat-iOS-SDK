//
//  ChatController.m
//  LiveMobile
//
//  Created by Soroush Pour on 7/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "ChatController.h"

@interface ChatController ()  {

    UIViewController *parentViewController;
    ChatView *chatView;
    MessagesModel *msgModel;
    ChatController *chatController;
    NSMutableArray* messages;
    LMSockets *socket;
}

@end

@implementation ChatController

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem {

    self = [super init];
    if(!self) return nil;
    
    //Get stored local messages
    msgModel = [[MessagesModel alloc] init];
    messages = [msgModel getMessages];
    
    //generate view with loaded messages
    chatView = [[ChatView alloc] initWithParentViewController:passedViewController NavigationItem:navItem initialMessages:messages];
    
    //Connect to chat server
    socket = [[LMSockets alloc] initWithHost:@"ws://localhost:5000/" delegate:self];
    [socket _reconnect];
    
    return self;
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Connection successfully made");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Failed to connect or error in socket.");
    webSocket.delegate = nil;
    webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    webSocket.delegate = nil;
    webSocket = nil;
}


@end

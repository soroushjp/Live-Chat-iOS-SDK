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
    
    int statusConnected;
}

@end

@implementation ChatController

#pragma mark - Initializers

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem {

    self = [super init];
    if(!self) return nil;
    
    statusConnected = 0;
    
    //Get stored local messages
    msgModel = [[MessagesModel alloc] init];
    messages = [msgModel getMessages];
    
    //generate view with loaded messages
    chatView = [[ChatView alloc] initWithParentViewController:passedViewController NavigationItem:navItem initialMessages:messages delegate:self];
    
    //Connect to chat server via WebSockets. Delegate methods will listen for messages and connection issues.
    socket = [[LMSockets alloc] initWithHost:@"ws://localhost:5000/" delegate:self];
    [socket reconnect];
    
    return self;
}

#pragma mark - ChatViewDelegate

- (void) userDidTypeMessage:(NSString *)message date:(NSDate*)date {
    
    //Currently if disconnected at first, nothing will get stored or sent anywhere. This needs to be fixed.
    if(statusConnected == 0) return;
    
    int timestamp = [date timeIntervalSince1970];
 
    NSString* msgJSON = [NSString stringWithFormat:@"{\"messageType\":2,\"message\":{\"content\":\"%@\", \"timestamp\":%d, \"author\":\"customer\"}}", message, timestamp];
    
    [socket send:msgJSON];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Connection successfully made");
    statusConnected = 1;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Failed to connect or error in socket.");
    webSocket.delegate = nil;
    webSocket = nil;
    statusConnected = 0;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    //Need to do more validation here in the future, since this is exposed to data external to iOS app.
    
    NSError *e = nil;
    
    NSDictionary* messageObject = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options:0
                                                                    error:&e];
    if (e != nil) {
        NSLog(@"Invalid message received from chat server");
        return;
    }
    
    int msgType = [[messageObject objectForKey:@"messageType"] intValue];
    
    if (msgType == 2) {
        //For this message type, we expect a chat message
    
        NSString* msgText = [NSString stringWithString:[[messageObject objectForKey:@"message"] objectForKey:@"content"]];
        
        //We divide timestamp by 1000 since Node.JS server gives all timestamps in milliseconds.
        double msgTimestamp = [[[messageObject objectForKey:@"message"] objectForKey:@"timestamp"] doubleValue] / 1000;
        NSDate* msgDate = [NSDate dateWithTimeIntervalSince1970: msgTimestamp];
        
        NSString* msgAuthor = [NSString stringWithString:[[messageObject objectForKey:@"message"] objectForKey:@"author"]];
            
        [chatView addMsgToViewWithText:msgText date:msgDate author:msgAuthor];
        
    }
     
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    webSocket.delegate = nil;
    webSocket = nil;
    statusConnected = 0;
    NSLog(@"Connection closed cleanly? %d \nReason: %d - %@", wasClean, code, reason);
}


@end

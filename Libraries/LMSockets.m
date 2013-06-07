//
//  LMSockets.m
//  LiveMobile
//
//  Created by Soroush Pour on 6/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "LMSockets.h"

@interface LMSockets () {

    SRWebSocket *_webSocket;
    
    NSString *HOST;
    int connectCount;
    
    NSMutableDictionary *_messagesSending;
}

@end

@implementation LMSockets

- (id) initWithHost:(NSString*) host {
    
    self = [super init];
    if(!self) return nil;
    
    HOST = host;
    connectCount = 0;

    return self;
    
}

- (BOOL)_reconnect {
    
    //(Re)connect method. Returns NO for invalid hostname. Otherwise YES, use webSocketDidOpen delegate method to confirm that the connection was actually made
    
    if([HOST isEqualToString:@""]) return NO;
    
    if(connectCount <= 0 ) {
        NSLog(@"Connecting to %@ ...", HOST);
        connectCount++;
    }    else {
        NSLog(@"Reconnecting to %@ ...", HOST);
        _webSocket.delegate = nil;
        [_webSocket close];
        //We still reallocate _webSocket because SocketRocket sockets are made for one use only.
    }    
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HOST]]];
    _webSocket.delegate = self;
    [_webSocket open];
    
    return YES;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Connection successfully made");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Failed to connect or error in socket.");
    _webSocket.delegate = nil;
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    _webSocket.delegate = nil;
    _webSocket = nil;
    _messagesSending = nil;
}
@end

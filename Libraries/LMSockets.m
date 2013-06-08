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

    id <SRWebSocketDelegate> delegate;
}

@end

@implementation LMSockets

- (id) initWithHost:(NSString*)host delegate:(id <SRWebSocketDelegate>)socketDelegate {
    
    self = [super init];
    if(!self) return nil;
    
    HOST = host;
    delegate = socketDelegate;
    connectCount = 0;

    return self;
    
}

- (BOOL)reconnect {
    
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
    _webSocket.delegate = delegate;
    [_webSocket open];
    
    return YES;
}

- (void)send:(id)message {

    [_webSocket send:message];

}
@end

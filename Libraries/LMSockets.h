//
//  LMSockets.h
//  LiveMobile
//
//  Created by Soroush Pour on 6/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@interface LMSockets : NSObject

//Host must be given in exact format ws://hostname:5000/
- (id) initWithHost:(NSString*)host delegate:(id <SRWebSocketDelegate>)socketDelegate;

- (BOOL)reconnect;
- (void)send:(id)message;


@end

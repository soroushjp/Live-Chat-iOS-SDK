//
//  PortraitBubbleSource.h
//  LiveMobile
//
//  Created by Soroush Pour on 11/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"

@interface BubbleDelegate : NSObject <UIBubbleTableViewDataSource>

@property (strong, nonatomic) NSMutableArray* bubbleMessages;

@end

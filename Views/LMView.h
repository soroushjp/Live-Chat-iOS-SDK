//
//  LMView.h
//  LiveMobile
//
//  Created by Soroush Pour on 5/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveMobileSDK.h"
#import "ChatUIController.h"
#import "FPPopoverController.h"
#import "ARCMacros.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"

@interface LMView : NSObject  <UIBubbleTableViewDataSource, UITextFieldDelegate> {
    
}

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem;

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem initialMessages:(NSMutableArray*)passedMessages;



@end
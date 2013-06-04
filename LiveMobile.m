//
//  LiveMobile.m
//  LiveMobile
//
//  Created by Soroush Pour on 2/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "LiveMobile.h"
#import "FPPopoverController.h"
#import "ARCMacros.h"

@interface LiveMobile () {

    UIBarButtonItem *button;
    UIViewController *parentViewController;
    FPPopoverController *fpp;
    NSInteger viewHeight;
    NSInteger viewWidth;
    NSInteger  windowWidth;
    NSInteger  windowHeight;
    
}

@end

@implementation LiveMobile

- (void) initWithParentViewController:(UIViewController*)passedViewController NavigationBar:(UINavigationBar*)navBar
{
    
    parentViewController = passedViewController;
    viewWidth = parentViewController.view.frame.size.width;
    viewHeight = parentViewController.view.frame.size.height;
    windowWidth = [[UIScreen mainScreen ] bounds].size.width;
    windowHeight = [[UIScreen mainScreen ] bounds].size.height - 20;
        
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Fashionista"];
    [navBar pushNavigationItem:navItem animated:NO];
    UIBarButtonItem *feedbackButton = [[UIBarButtonItem alloc] initWithTitle:@"Live Help"
                                                            style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(clickFeedbackBtn:)];
    navItem.rightBarButtonItem = feedbackButton;
    
    [parentViewController.view addSubview:navBar];
    
}

- (IBAction)clickFeedbackBtn:(id)sender {

    [self showChat];
    
}

- (BOOL) showChat {
    
    UIViewController *myChatController = [[UIViewController alloc]init];
    UITableView *myChat = [[UITableView alloc] initWithFrame:CGRectMake(10,10,viewWidth-40,viewHeight-100) style:UITableViewStylePlain];
    [myChatController.view addSubview:myChat];
    [myChat.layer setCornerRadius:8];
    
    fpp = [[FPPopoverController alloc] initWithViewController:myChatController];
    
    [fpp setContentSize:CGSizeMake(viewWidth,viewHeight-10)];
    [fpp setBorder:NO];
    [fpp setTint:FPPopoverLightGrayTint];
    [fpp setAlpha:0.85];
    [fpp presentPopoverFromPoint:CGPointMake(320, 40)];
    
    return YES;
}


@end

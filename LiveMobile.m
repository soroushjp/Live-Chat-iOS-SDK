//
//  LiveMobile.m
//  LiveMobile
//
//  Created by Soroush Pour on 2/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "LiveMobile.h"
#import "ChatController.h"
#import "FPPopoverController.h"
#import "ARCMacros.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"

@interface LiveMobile () <UIBubbleTableViewDataSource, UITextFieldDelegate> {

    UIBarButtonItem *button;
    UIViewController *parentViewController;
    FPPopoverController *fpp;
    NSInteger viewHeight;
    NSInteger viewWidth;
    NSInteger  windowWidth;
    NSInteger  windowHeight;
    
    ChatController *myChatController;
    UIBubbleTableView *myChat;
    NSMutableArray* messages;
    
    UITextField *msgBox;
    UIButton *sendMsgBtn;
    CALayer *lowerBG;
    CALayer *topBorder;
    
}

- (IBAction)startChatBtnPressed:(id)sender;
- (BOOL) showChat;
- (BOOL) createPopupoverWithController:(UIViewController*)controller;

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
    UIBarButtonItem *startChatBtn = [[UIBarButtonItem alloc] initWithTitle:@"Live Help"
                                                            style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(startChatBtnPressed:)];
    navItem.rightBarButtonItem = startChatBtn;
    
    [parentViewController.view addSubview:navBar];
    
    //Attach observers to keyboard opening/closing so we can adjust chat window based on whether keyboard is open
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [parentViewController.view addGestureRecognizer:tap];
}

- (IBAction)startChatBtnPressed:(id)sender {

    [self showChat];
    
}

- (BOOL) showChat {
    
    //Call functions to create controller, insert chat UI into controller as subview and call up Popover containing chat.
    
    myChatController = [[ChatController alloc]init];
    [self createChatView];
    [self createPopupoverWithController:myChatController];
    
    return YES;
}

- (BOOL) createPopupoverWithController:(UIViewController*)controller {

    //Initialize our popup
    
    fpp = [[FPPopoverController alloc] initWithViewController:controller];
    
    [fpp setContentSize:CGSizeMake(viewWidth,viewHeight-40)];
    [fpp setBorder:NO];
    [fpp setTint:FPPopoverLightGrayTint];
    [fpp setAlpha:0.85];
    [fpp presentPopoverFromPoint:CGPointMake(320, 40)];
    
    return YES;
    
}

- (BOOL) createChatView {
    
    //Create some fake chat data
    NSBubbleData *msg1 = [NSBubbleData dataWithText:@"My first received message!" date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
    NSBubbleData *msg2 = [NSBubbleData dataWithText:@"My second received message!" date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeSomeoneElse];
    NSBubbleData *msg3 = [NSBubbleData dataWithText:@"My first sent message! Everyone remembers their first :)" date:[NSDate dateWithTimeIntervalSinceNow:-600] type:BubbleTypeMine];
    NSBubbleData *msg4 = [NSBubbleData dataWithText:@"My second sent message! Second time's the best?" date:[NSDate dateWithTimeIntervalSinceNow:-600] type:BubbleTypeMine];
    NSBubbleData *msg5 = [NSBubbleData dataWithText:@"My second sent message! Second time's the best?" date:[NSDate dateWithTimeIntervalSinceNow:-1200] type:BubbleTypeMine];
    NSBubbleData *msg6= [NSBubbleData dataWithText:@"My second sent message! Second time's the best?" date:[NSDate dateWithTimeIntervalSinceNow:-1500] type:BubbleTypeSomeoneElse];
    NSBubbleData *msg7 = [NSBubbleData dataWithText:@"My second sent message! Second time's the best?" date:[NSDate dateWithTimeIntervalSinceNow:-1500] type:BubbleTypeSomeoneElse];
    NSBubbleData *msg8 = [NSBubbleData dataWithText:@"My second sent message! Second time's the best?" date:[NSDate dateWithTimeIntervalSinceNow:-1500] type:BubbleTypeMine];
    NSBubbleData *msg9 = [NSBubbleData dataWithText:@"My second sent message! Second time's the best?" date:[NSDate dateWithTimeIntervalSinceNow:-2400] type:BubbleTypeMine];
    NSBubbleData *msg10 = [NSBubbleData dataWithText:@"My second sent message! Second time's the best?" date:[NSDate dateWithTimeIntervalSinceNow:-2400] type:BubbleTypeSomeoneElse];
    NSBubbleData *msg11 = [NSBubbleData dataWithText:@"My second sent message! Second time's the best?" date:[NSDate dateWithTimeIntervalSinceNow:-3000] type:BubbleTypeMine];
    
    messages = [[NSMutableArray alloc] initWithObjects:msg1,msg2,msg3,msg4,msg5,msg6,msg7,msg8,msg9,msg10,msg11, nil];


    // Create our chat UIBubbleTableView UI
    myChat = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(10,0,viewWidth-40,viewHeight-140)];
    [myChat setBubbleDataSource:self];
    [myChat setBounces:NO];
    [myChatController.view addSubview:myChat];
    
    //Create lower message area top border and background
    topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, viewHeight-143, viewWidth, 3.0f);
    topBorder.backgroundColor = [[UIColor colorWithWhite:0.3 alpha:1] CGColor];
    [myChatController.view.layer addSublayer:topBorder];    
    
    lowerBG = [CALayer layer];
    lowerBG.frame = CGRectMake(0, viewHeight-140, viewWidth, 60);
    lowerBG.backgroundColor = [[UIColor colorWithWhite:0.85 alpha:1] CGColor];
    [myChatController.view.layer addSublayer:lowerBG];
    
    //Create msgBox
    msgBox = [[UITextField alloc] initWithFrame:CGRectMake(10, viewHeight-130, viewWidth-90, 40)];
    [msgBox setBorderStyle: UITextBorderStyleRoundedRect];
    [msgBox setFont:[UIFont systemFontOfSize:15]];
    [msgBox setAutocorrectionType: UITextAutocorrectionTypeNo];
    [msgBox setKeyboardType: UIKeyboardTypeDefault];
    [msgBox setReturnKeyType: UIReturnKeySend];
    [msgBox setClearButtonMode: UITextFieldViewModeWhileEditing];
    [msgBox setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
    [msgBox setDelegate: self];
    [myChatController.view addSubview:msgBox];
    
    //Create send button
    sendMsgBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendMsgBtn setFrame:CGRectMake(viewWidth-75, viewHeight-130, 50, 40)];
    [sendMsgBtn setTitle:@"Send" forState:UIControlStateNormal];
    [sendMsgBtn addTarget:self action:@selector(sendMsgBtnReturn:) forControlEvents:UIControlEventTouchUpInside];
    [myChatController.view addSubview:sendMsgBtn];

    return YES;
}

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [messages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [messages objectAtIndex:row];
}

//Used to route return from Send button to common textfield return function textFieldShouldReturn
- (IBAction)sendMsgBtnReturn:(id)sender {
    
    [self textFieldShouldReturn:msgBox];
}

//Dismiss keyboard on Done
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    NSBubbleData *newMsg = [NSBubbleData dataWithText:[textField text] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    
    [messages addObject:newMsg];
    [myChat reloadData];
    
    [textField setText:@""];
    
    return YES;
}

//Adjust the chat window height when keyboard appears
- (void)keyboardShow:(NSNotification *)notification
{
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGRect myChatFrame = [myChat frame];
    myChatFrame.size.height -= keyboardSize.height;
    [myChat setFrame:myChatFrame];
    
    //Disable CALayer implicit animations
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    
        CGRect lowerBGFrame = [lowerBG frame];
        lowerBGFrame.origin.y -= keyboardSize.height;
        [lowerBG setFrame:lowerBGFrame];
        
        CGRect topBorderFrame = [topBorder frame];
        topBorderFrame.origin.y -= keyboardSize.height;
        [topBorder setFrame:topBorderFrame];
    
    [CATransaction commit];
    
    CGRect msgBoxFrame = [msgBox frame];
    msgBoxFrame.origin.y -= keyboardSize.height;
    [msgBox setFrame:msgBoxFrame];
    
    CGRect sendMsgBtnFrame = [sendMsgBtn frame];
    sendMsgBtnFrame.origin.y -= keyboardSize.height;
    [sendMsgBtn setFrame:sendMsgBtnFrame];
    
    CGSize fppSize = [fpp contentSize];
    fppSize.height -= keyboardSize.height;
    [fpp setContentSize:fppSize];
    [fpp setupView];
    
    [myChat scrollToBottomWithAnimation:NO];
    
}

//Adjust the chat window height when keyboard disappears
- (void)keyboardHide:(NSNotification *)notification
{
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect myChatFrame = [myChat frame];
    myChatFrame.size.height += keyboardSize.height;
    [myChat setFrame:myChatFrame];
    
    //Disable CALayer implicit animations
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    
        CGRect lowerBGFrame = [lowerBG frame];
        lowerBGFrame.origin.y += keyboardSize.height;
        [lowerBG setFrame:lowerBGFrame];
        
        CGRect topBorderFrame = [topBorder frame];
        topBorderFrame.origin.y += keyboardSize.height;
        [topBorder setFrame:topBorderFrame];
    
    [CATransaction commit];
    
    CGRect msgBoxFrame = [msgBox frame];
    msgBoxFrame.origin.y += keyboardSize.height;
    [msgBox setFrame:msgBoxFrame];
    
    CGRect sendMsgBtnFrame = [sendMsgBtn frame];
    sendMsgBtnFrame.origin.y += keyboardSize.height;
    [sendMsgBtn setFrame:sendMsgBtnFrame];
    
    CGSize fppSize = [fpp contentSize];
    fppSize.height += keyboardSize.height;
    [fpp setContentSize:fppSize];
    [fpp setupView];
}

//Dismiss keyboard from message box if a user taps anywhere but keyboard on screen
-(void)dismissKeyboard {
    [msgBox resignFirstResponder];
}

@end

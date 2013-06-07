//
//  LMView.m
//  LiveMobile
//
//  Created by Soroush Pour on 5/06/13.
//  Copyright (c) 2013 Soroush Pour. All rights reserved.
//

#import "LMView.h"

@interface LMView () {
    
    UIBarButtonItem *button;
    UIViewController *parentViewController;
    FPPopoverController *fpp;
    NSInteger viewHeight;
    NSInteger viewWidth;
    NSInteger  windowWidth;
    NSInteger  windowHeight;
    
    ChatUIController *myChatUIController;
    UIBubbleTableView *myChat;
    NSMutableArray* bubbleMessages;
    
    UITextField *msgBox;
    UIButton *sendMsgBtn;
    CALayer *lowerBG;
    CALayer *topBorder;

}

- (NSMutableArray*) createBubbleArrayFromMessageArray:(NSMutableArray*) array;
- (void) addLiveChatBtnOnNavItem:(UINavigationItem*)navItem;
- (void) addListeners;
- (IBAction)startChatBtnPressed:(id)sender;
- (BOOL) showChat;
- (BOOL) createPopupoverWithController:(UIViewController*)controller;
- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView;
- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void)keyboardShow:(NSNotification *)notification;
- (void)keyboardHide:(NSNotification *)notification;
-(void)dismissKeyboard;
    
@end

@implementation LMView

- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem initialMessages:passedMessages {
    
    self = [super init];
    if(!self) return nil;

    parentViewController = passedViewController;
    viewWidth = parentViewController.view.frame.size.width;
    viewHeight = parentViewController.view.frame.size.height;
    windowWidth = [[UIScreen mainScreen ] bounds].size.width;
    windowHeight = [[UIScreen mainScreen ] bounds].size.height - 20;
    
    bubbleMessages = [[NSMutableArray alloc] init];
    
    
    bubbleMessages = [self createBubbleArrayFromMessageArray: passedMessages];
    [self addLiveChatBtnOnNavItem:navItem];
    [self addListeners];

    return self;
}


- (id) initWithParentViewController:(UIViewController*)passedViewController NavigationItem:(UINavigationItem*)navItem {
    
    return [self initWithParentViewController:passedViewController NavigationItem:navItem initialMessages:[NSMutableArray array]];
    
}
- (NSMutableArray*) createBubbleArrayFromMessageArray:(NSMutableArray*) array {
    
    NSBubbleData* tempMsg;
    NSString* tempText;
    NSDate* tempDate;
    NSString* tempType;
    NSBubbleType tempBubbleType;
    NSMutableArray* tempBubbleMessages = [[NSMutableArray alloc] init];

    for(int i=0;i<[array count];i++) {
        
        tempText = [array[i] objectForKey:@"dataWithText"];
        tempDate = [array[i] objectForKey:@"date"];
        tempType = [array[i] objectForKey:@"type"];
        
        if([tempType isEqualToString:@"customer"]) tempBubbleType = BubbleTypeMine;
        else tempBubbleType = BubbleTypeSomeoneElse;
        
        tempMsg = [NSBubbleData dataWithText:tempText date:tempDate type:tempBubbleType];
        
        
        [tempBubbleMessages insertObject:tempMsg atIndex:i];
    }
    
    return tempBubbleMessages;
    
}

- (void) addLiveChatBtnOnNavItem:(UINavigationItem*)navItem {

    UIBarButtonItem *startChatBtn = [[UIBarButtonItem alloc] initWithTitle:@"Live Help"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(startChatBtnPressed:)];
    navItem.rightBarButtonItem = startChatBtn;
    
    
}

- (void) addListeners {

    //Attach observers to keyboard opening/closing so we can adjust chat window based on whether keyboard is open
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //Attach tap gesture listener so we can dismiss keyboard when user clicks outside its area
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
    
    myChatUIController = [[ChatUIController alloc]init];
    [self createChatView];
    [self createPopupoverWithController:myChatUIController];
    
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
    
    // Create our chat UIBubbleTableView UI
    myChat = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(10,0,viewWidth-40,viewHeight-140)];
    [myChat setBubbleDataSource:self];
    [myChat setBounces:NO];
    [myChatUIController.view addSubview:myChat];
    
    //Create lower message area top border and background
    topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, viewHeight-143, viewWidth, 3.0f);
    topBorder.backgroundColor = [[UIColor colorWithWhite:0.3 alpha:1] CGColor];
    [myChatUIController.view.layer addSublayer:topBorder];
    
    lowerBG = [CALayer layer];
    lowerBG.frame = CGRectMake(0, viewHeight-140, viewWidth, 60);
    lowerBG.backgroundColor = [[UIColor colorWithWhite:0.85 alpha:1] CGColor];
    [myChatUIController.view.layer addSublayer:lowerBG];
    
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
    [myChatUIController.view addSubview:msgBox];
    
    //Create send button
    sendMsgBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendMsgBtn setFrame:CGRectMake(viewWidth-75, viewHeight-130, 50, 40)];
    [sendMsgBtn setTitle:@"Send" forState:UIControlStateNormal];
    [sendMsgBtn addTarget:self action:@selector(sendMsgBtnReturn:) forControlEvents:UIControlEventTouchUpInside];
    [myChatUIController.view addSubview:sendMsgBtn];
    
    return YES;
}

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleMessages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleMessages objectAtIndex:row];
}

//Used to route return from Send button to common textfield return function textFieldShouldReturn
- (IBAction)sendMsgBtnReturn:(id)sender {
    
    [self textFieldShouldReturn:msgBox];
}

//Dismiss keyboard on Done
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if([[textField text] isEqualToString:@""]) return YES;
    
    NSBubbleData *newMsg = [NSBubbleData dataWithText:[textField text] date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    
    [bubbleMessages addObject:newMsg];
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

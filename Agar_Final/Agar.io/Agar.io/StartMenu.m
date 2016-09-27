/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/
/********************************************************************
 FileName: StartMenu.m
 Date: 13 Oct 2015
 Description: this is view to present the start menu
 Functions: 1. set basic label for start menu
            2. transmit inform betweent the view
            3. let user to choose game type
            4. proximity sensor
 *******************************************************************/

#import "StartMenu.h"
#import "GameScene.h"
#import "LeaderBoard.h"

@interface StartMenu()

@end

@implementation StartMenu
{
    SKLabelNode *singleGame;
    SKLabelNode *onlineGame;
    SKLabelNode *leadBoard;
    SKLabelNode *practiceModel;
    UITextField *textField;
}


-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    self.anchorPoint = CGPointMake(0.5, 0.5);
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"AGAR.IO";
    myLabel.fontSize = 38;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame) + 100);
    
    [self addChild:myLabel];
    
    singleGame = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    singleGame.text = @"Single Game";
    singleGame.fontSize = 16;
    singleGame.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame));
    [self addChild:singleGame];
    
    onlineGame = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    onlineGame.text = @"Online Game";
    onlineGame.fontSize = 16;
    onlineGame.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame)-30);
    [self addChild:onlineGame];
    
    leadBoard = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    leadBoard.text = @"Leader Board";
    leadBoard.fontSize = 16;
    leadBoard.position = CGPointMake(CGRectGetMidX(self.frame),
                                      CGRectGetMidY(self.frame)-60);
    [self addChild:leadBoard];
    
    practiceModel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    practiceModel.text = @"Practice";
    practiceModel.fontSize = 16;
    practiceModel.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame)-90);
    [self addChild:practiceModel];
    
    [self addInputText];
    
//    self.LeaderBoardInfo = [NSMutableArray array];
    
    /*restart game here*/
    self.view.paused = NO;
    
    /*if device is portait then it works*/
    [self activateProximitySensor];

    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch * touch = [touches anyObject];
    
    //touch in scene:
    CGPoint location = [touch locationInNode:self];
    
    if ([singleGame containsPoint:location]) {
        
        
        GameScene *scene = [GameScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        scene.playerName = textField.text;
        scene.gameType = @"singleGame";
        
        scene.startMenu = self;
        
        scene.goalsSoFar = [NSMutableArray array];
        
        [textField removeFromSuperview];
        
        [self.view presentScene:scene];
    }
    
    if ([onlineGame containsPoint:location]) {
        
        
        GameScene *scene = [GameScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        scene.playerName = textField.text;
        scene.gameType = @"onlineGame";
        
        scene.startMenu = self;
        
        [textField removeFromSuperview];
        
        [self.view presentScene:scene];
    }
    
    if ([leadBoard containsPoint:location]) {
        
    
        LeaderBoard *scene = [LeaderBoard sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        scene.goalsArray = [NSMutableArray array];
        scene.goalsArray = self.LeaderBoardInfo;
        scene.startMenu = self;
        
        [textField removeFromSuperview];
        
        [self.view presentScene:scene];
    }
    
    if ([practiceModel containsPoint:location]) {
        
        GameScene *scene = [GameScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        scene.playerName = textField.text;
        scene.gameType = @"practice";
        
        scene.startMenu = self;
        
//        scene.goalsSoFar = [NSMutableArray array];
        
        [textField removeFromSuperview];
        
        [self.view presentScene:scene];
    }

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    

//    NSLog(@"the screen brightness is %f",[UIScreen mainScreen].brightness);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self processReturn];
    return YES;
}


-(void)processReturn
{
    [textField resignFirstResponder];//hide keyboard
    NSLog(@"%@",textField.text);
}

-(void)addInputText
{
    textField = [[UITextField alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 90, self.frame.size.height/2 - 70, 180, 30)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:17.0];
    textField.placeholder = @"Enter your name here";
    textField.backgroundColor = [SKColor whiteColor];
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.delegate = self;
    
    [self.view addSubview:textField];
}


/*below two method is to use proximity sensor*/
- (void) activateProximitySensor {
    
    UIDevice *device = [UIDevice currentDevice];
    
    
    device.proximityMonitoringEnabled = YES;
    
    if (device.proximityMonitoringEnabled == YES) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityChanged:) name:@"UIDeviceProximityStateDidChangeNotification" object:device];
        
    }
    
}

- (void) proximityChanged:(NSNotification *)notification {
    
    UIDevice *device = [notification object];
    
    NSLog(@"Detectat!");
    
  
    [[UIScreen mainScreen] setBrightness: 0.2]; // value between 0.0-1.0
    
    
    
}
@end

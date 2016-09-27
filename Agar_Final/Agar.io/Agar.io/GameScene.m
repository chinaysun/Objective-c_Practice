/********************************************************************
Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
*********************************************************************/
/********************************************************************
FileName: GameScene.m
Date: 13 Oct 2015
Description: this is the view which presents the game.
Functions: 1. network connection, message exchange with server
           2. basic information setting.such as size of worlds, number of foods
           3. invoke player, AIcell,WorldGenerator to generator the game
           4. create basic control buttons in this view
           5. deal with the collision/contact in game
           6. invoke acceletormeter sensor, proximity sensor
           7. judge the game status
           8. deal with the meger method
           9. set the camera
 *******************************************************************/


#import "GameScene.h"
#import "StartMenu.h"
#import "PlayerCell.h"
#import "WorldGenerator.h"
#import "Player.h"
#import "AICell.h"
#import "MessageConstructor.h"
#import "MessageReader.h"
#import "MessageWriter.h"
#import "LeaderBoard.h"

@interface GameScene()
@property NSTimeInterval lasteUpdateTimeInterval;
@property NSMutableArray  *megerArray; //used to check the meger status
@end

/*state the basic info of game*/
static CGFloat GRID = 800;
static int FOOD = 100;
static int OBSTACLES = 5;
static int VIRUS = 3;
static NSString *GAME_FONT = @"AmericanTypewriter-Bold";
static const uint32_t megerCategory = 0x1 << 3;
static float buttonZposition = 0.5;



typedef enum {
    MessagePlayerInfo = 0,
    MessageEatenFoodPositions = 1,
    MessageWaitingForEnemy = 7,
    MessageGameBegin = 8,
    MessageSingleGameGoal = 9,
    
} MessageType;


/*set global variables*/
@implementation GameScene
{
    /*game nodes*/
    SKSpriteNode *world;
    WorldGenerator *generator;
    Player *player;
    
    /*basic buttons*/
    SKShapeNode *ejectButton;
    SKShapeNode *splitButton;
    SKSpriteNode *homeButton;
    SKSpriteNode *acceletorAddButton;
    SKSpriteNode *acceletorDelButton;
    
    /*acceleter control*/
    SKSpriteNode *controlButton;
    CMMotionManager *motionManager;
    BOOL startAcceletor;
    
    /*label text*/
    SKLabelNode *pointLabel;
    SKLabelNode *liveTimeLabel;
    SKLabelNode *attactLabel;
    SKLabelNode *foodLabel;
    
    /*variable for ai*/
    AICell *AI1;
    BOOL AIAlive;
    CFTimeInterval AIcoldTime;
    
    /*game status*/
    BOOL isOver;
    int restOfFood;
    BOOL onlineGameOver;
    
    //my parameters
    NSMutableArray *foodIEatPositions;
    NSString *myPositionX;
    NSString *myPositionY;
    
    //enemy parameters
    NSMutableArray *foodEnemyEatPositions;
    NSString *enemyPositionX;
    NSString *enemyPositionY;
    
    AICell *enemyCell;
    
    /*online Game Button*/
    SKLabelNode *firstPlayer;
    SKLabelNode *secondPlayer;
    
}

/*synthesize the property defined in .h file*/
@synthesize playerName;
@synthesize enemyName;
@synthesize myColorString;
@synthesize enemyColorString;

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize inputBuffer = _inputBuffer;
@synthesize outputBuffer = _outputBuffer;
@synthesize okToWrite = _okToWrite;

@synthesize enemyMass;

@synthesize goalOfThisTurn;
@synthesize goalsSoFar;

-(void)didMoveToView:(SKView *)view {
    
    

    /*set view basic info*/
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    self.physicsWorld.contactDelegate = self;
    
    self.backgroundColor = [UIColor grayColor];
    
    [self createWorld];
    
    /*initial the meger Array*/
    self.megerArray = [NSMutableArray array];
    
    
    /*initial the acceletermeter as false, user can control*/
    startAcceletor = false;
    
    /*add accelerometer*/
    motionManager = [[CMMotionManager alloc] init];
    
    if (motionManager.deviceMotionAvailable) {
        motionManager.accelerometerUpdateInterval = 0.1;
        
    }
    
    if ([self.gameType isEqualToString:@"onlineGame"]) {
        /*initial the animy*/
        enemyPositionX = NULL;
        enemyPositionY = NULL;
        enemyCell = NULL;
        enemyColorString = NULL;
        enemyMass = NULL;
        enemyName = NULL;
    }
 
    
    
    /*just connect when singelGame or onlineGame*/
    if (![self.gameType isEqualToString:@"practice"]) {
        
        NSLog(@"IN here！！！！！！！");
        [self connect];
        
    }
   
    
    
}


- (CGPoint)getCGpointFromStringX:(NSString *)X StringY:(NSString *)Y {
    CGPoint tempPoint = CGPointMake([X floatValue], [Y floatValue]);
    return tempPoint;
}

- (UIColor *)getUIColorFromString:(NSString *)colorStr {
    SEL colorSel = NSSelectorFromString(colorStr);
    UIColor* tColor = nil;
    if ([UIColor respondsToSelector: colorSel])
        tColor  = [UIColor performSelector:colorSel];
    return tColor;
}


/*Below block dealing with the network connect things*/



//Message sending / receiving

- (void)sendData:(NSData *)data {
    
    if (_outputBuffer == nil) return;
    
    int dataLength = (int)data.length;
    dataLength = htonl(dataLength);
    [_outputBuffer appendBytes:&dataLength length:sizeof(dataLength)];
    [_outputBuffer appendData:data];
    if (_okToWrite) {
        [self writeChunk];
        NSLog(@"Wrote message");
    } else {
        NSLog(@"Queued message");
    }
}

//send the goal of this turn to server when the game over
-(void)sendGoalOfThisTurn {
    MessageConstructor *messageMaker = [[MessageConstructor alloc] init];
    MessageWriter *writer = [[MessageWriter alloc] init];
    [writer writeByte:MessageSingleGameGoal];
    [writer writeString:playerName];
    NSString *tempStr = [messageMaker JSONStringConstructFromDictionary:goalOfThisTurn];
    [writer writeString:tempStr];
    NSLog(@"send goal of this turn");
    [self sendData:writer.data];
}

//send player infomation to server
- (void)sendWaitingEnemy {
    MessageWriter *writer = [[MessageWriter alloc] init];
    [writer writeByte:MessageWaitingForEnemy];
    [writer writeString:playerName];
    [writer writeString:myPositionX];
    [writer writeString:myPositionY];
    [writer writeString:myColorString];
    [writer writeString:[NSString stringWithFormat:@"%f",((PlayerCell *)player.playerCellArray[0]).getNumberofMass]];
    NSLog(@"send waiting message");
    [self sendData:writer.data];
}


//send player infomation to server
- (void)sendPlayerInfo {
    MessageWriter *writer = [[MessageWriter alloc] init];
    [writer writeByte:MessagePlayerInfo];
    [writer writeString:playerName];
    [writer writeString:myPositionX];
    [writer writeString:myPositionY];
    [writer writeString:myColorString];
    [writer writeString:[NSString stringWithFormat:@"%f",((PlayerCell *)player.playerCellArray[0]).getNumberofMass]];
    NSLog(@"send my information");
    [self sendData:writer.data];
}

//send food eaten to server
-(void)sendEatenFoodPosition {
    MessageConstructor *messageMaker = [[MessageConstructor alloc] init];
    MessageWriter *writer = [[MessageWriter alloc] init];
    [writer writeByte:MessageEatenFoodPositions];
    [writer writeString:playerName];
    
    NSMutableDictionary *tempDic = [messageMaker DicConstructFromArray:foodIEatPositions WithKey:@"foodEatenPosition"];
    NSString *tempStr = [messageMaker JSONStringConstructFromDictionary:tempDic];
    
    //    [writer writeString:tempStr];
    NSLog(@"send the eaten food position");
    [self sendData:writer.data];
}


- (void)processMessage:(NSData *)data {
    MessageConstructor *messageMaker = [[MessageConstructor alloc] init];
    MessageReader * reader = [[MessageReader alloc] initWithData:data];
    
    unsigned char msgType = [reader readByte];
    if (msgType == MessagePlayerInfo) {
        NSString *name = [reader readString];
        NSLog(@"%@",name);
        if ([name isEqualToString:playerName]) {
            return;
        }
        //read and save enemy positon
        else {
            NSLog(@"Receive enemy information");
            enemyName = name;
            enemyPositionX = [reader readString];
            enemyPositionY = [reader readString];
            enemyColorString = [reader readString];
            enemyMass = [reader readString];
            //TODO:change the enemy position according to the received position
        }
    } else if (msgType == MessageSingleGameGoal) {
        NSString *name = [reader readString];
        NSString *jsonStr = [reader readString];
        NSDictionary *goalDic = [messageMaker DictoryConstructFromJSONString:jsonStr];
        //        NSLog(@"Message from %@ goal is %@",name, goalDic);
        [goalsSoFar insertObject:goalDic atIndex:0];
        //        NSLog(@"goalsSoFar is %@", goalsSoFar);
        
    } else if (msgType == MessageEatenFoodPositions) {
        NSString *name = [reader readString];
        if ([name isEqualToString:playerName]) {
            return;
        }
        //read and save enemy eaten food position
        else {
            NSString *foodJsonStr = [reader readString];
            NSDictionary *foodDic = [messageMaker DictoryConstructFromJSONString:foodJsonStr];
            NSArray *foodArray = foodDic[@"foodEatenPosition"];
            for (NSArray *p in foodArray) {
                //TODO:each element in foodArray is a nsarray which represents a eaten food position
                //according to the position array to remove food eaten by enemy
                //                x = [p objectAtIndex:0];
                //                y = [p objectAtIndex:1];
            }
            
        }
        
    } else if (msgType == MessageWaitingForEnemy) {
        NSString *name = [reader readString];
        if ([name isEqualToString:playerName]) {
            return;
        }
        else {
            NSLog(@"receive enemy waiting message");
            enemyName = name;
            enemyPositionX = [reader readString];
            enemyPositionY = [reader readString];
            enemyColorString = [reader readString];
            enemyMass = [reader readString];

        }
        
    } else if (msgType == MessageGameBegin) {
        NSLog(@"receive game begin message");
        //TODO: cancel the block and continue the game
        //create an enemy according the position and start the online game
        
    }
}




//connect to the server
- (void)connect {
    

    
    self.inputBuffer = [NSMutableData data];
    self.outputBuffer = [NSMutableData data];
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"10.9.144.184", 910, &readStream, &writeStream);
    _inputStream = (__bridge NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)writeStream;
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    
    //    if close the stream, it closes the socket too
    [_inputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [_outputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
    
    
}


//disconnect with the server
- (void)disconnect {
    
    if (_inputStream !=nil) {
        self.inputStream.delegate = nil;
        
        [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream close];
        self.inputStream = nil;
        self.inputBuffer =nil;
    }
    if (_outputStream !=nil) {
        self.outputStream.delegate = nil;
        
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream close];
        self.outputStream = nil;
        self.outputBuffer = nil;
    }
}


//disconnect, and then schedules the connect to be called in 5 seconds
- (void)reconnect {
    [self disconnect];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self connect];
    });
}



- (void)checkForMessages {
    while (true) {
        if (_inputBuffer.length < sizeof(int)) {
            return;
        }
        
        int msgLength = *((int *) _inputBuffer.bytes);
        msgLength = ntohl(msgLength);
        if (_inputBuffer.length < msgLength) {
            return;
        }
        
        NSData * message = [_inputBuffer subdataWithRange:NSMakeRange(4, msgLength)];
        [self processMessage:message];
        
        int amtRemaining = (int)(_inputBuffer.length - msgLength - sizeof(int));
        if (amtRemaining == 0) {
            self.inputBuffer = [[NSMutableData alloc] init];
        } else {
            NSLog(@"Creating input buffer of length %d", amtRemaining);
            self.inputBuffer = [[NSMutableData alloc] initWithBytes:_inputBuffer.bytes+4+msgLength length:amtRemaining];
        }
        
    }
}



- (void)inputStreamHandleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:{
            NSLog(@"Opened input stream");

        } break;
            
        case NSStreamEventHasBytesAvailable: {
            if ([_inputStream hasBytesAvailable]) {
                NSLog(@"Input stream has bytes...");
                // TODO: Read bytes
                
//                single game ignor all received message
                
                NSInteger       bytesRead;
                uint8_t         buffer[32768];
                
                bytesRead = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                if (bytesRead == -1) {
                    NSLog(@"Network read error");
                } else if (bytesRead == 0) {
                    NSLog(@"No data read, reconnecting");
                    [self reconnect];
                } else {
                    NSLog(@"Read %ld bytes", bytesRead);
                    [_inputBuffer appendData:[NSData dataWithBytes:buffer length:bytesRead]];
                    [self checkForMessages];
                }
            }
        } break;
            
        case NSStreamEventHasSpaceAvailable: {
            assert(NO); //should never happen for the input stream
        } break;
            
        case NSStreamEventErrorOccurred: {
            NSLog(@"Stream open error, reconnecting");
            [self reconnect];
        } break;
            
        case NSStreamEventEndEncountered: {
            [_inputStream close];
            [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        } break;
            
        default: {
            assert(NO);
        } break;
    }
    
}

- (BOOL)writeChunk {
    int amtToWrite = (int)MIN(_outputBuffer.length, 1024);
    if (amtToWrite == 0) return FALSE;
    
    NSLog(@"Amt to write: %d/%ld", amtToWrite, _outputBuffer.length);
    
    int amtWritten = (int)[self.outputStream write:_outputBuffer.bytes maxLength:amtToWrite];
    if (amtWritten < 0) {
        [self reconnect];
    }
    int amtRemaining = (int)(_outputBuffer.length - amtWritten);
    if (amtRemaining == 0) {
        self.outputBuffer = [NSMutableData data];
    } else {
        NSLog(@"Creating output buffer of length %d", amtRemaining);
        self.outputBuffer = [NSMutableData dataWithBytes:_outputBuffer.bytes+amtWritten length:amtRemaining];
    }
    NSLog(@"Wrote %d bytes, %d remaining.", amtWritten, amtRemaining);
    _okToWrite = FALSE;
    return TRUE;
}



- (void)outputStreamHandleEvent:(NSStreamEvent)eventCode {
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            NSLog(@"Opened output stream");
            if ([self.gameType isEqualToString:@"onlineGame"]) {
                [self sendWaitingEnemy];
            }

            //          TODO: send message to server
        } break;
            
        case NSStreamEventHasBytesAvailable: {
            assert(NO); //should never happen for the output stream
        } break;
            
        case NSStreamEventHasSpaceAvailable: {
            NSLog(@"Ok to send");
            // TODO: Write bytes
            BOOL wroteChunk = [self writeChunk];
            if (!wroteChunk) {
                _okToWrite = TRUE;
            }
        } break;
            
        case NSStreamEventErrorOccurred: {
            NSLog(@"Stream open error, reconnecting");
            [self reconnect];
        } break;
            
        case NSStreamEventEndEncountered: {
            [_outputStream close];
            [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        } break;
            
        default: {
            assert(NO);
        } break;
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (aStream == _inputStream) {
            [self inputStreamHandleEvent:eventCode];
        } else if (aStream == _outputStream){
            [self outputStreamHandleEvent:eventCode];
        }
    });
}
/* end of network connect thing block here*/


/* create the basic feature in the game */
-(void)createWorld
{
    
    //create the world of game
    world = [SKSpriteNode node];
    world.size = CGSizeMake(GRID, GRID);
    [self addChild:world];
    
    //set up basic features of world
    generator = [WorldGenerator generatorWithWorld:world getSize:GRID];
    [self addChild:generator];
    if ([self.gameType isEqualToString:@"onlineGame"]) {
         [generator importPosition];
    }
    [generator generateBoundary];
    [generator generateFood:FOOD];
    [generator generateStaticObstacles:OBSTACLES];
    [generator generateVirus:VIRUS];
    
    /* add buttons - start here */
    
    ejectButton = [SKShapeNode shapeNodeWithCircleOfRadius:25];
    ejectButton.fillColor = [UIColor greenColor];
    ejectButton.alpha = 0.8;
    ejectButton.strokeColor =[UIColor whiteColor];
    ejectButton.lineWidth = 1.0;
    ejectButton.zPosition = buttonZposition;
    ejectButton.position = CGPointMake(self.size.width/2 - 30 , -self.size.height/2 + 80);
    [self addChild:ejectButton];
    
    SKLabelNode *labelEject = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    labelEject.text = @"Eject";
    labelEject.fontColor = [UIColor whiteColor];
    labelEject.fontSize = 12;
    labelEject.position = CGPointMake(0, -4);
    [ejectButton addChild:labelEject];
    
    splitButton = [SKShapeNode shapeNodeWithCircleOfRadius:25];
    splitButton.fillColor = [UIColor blueColor];
    splitButton.alpha = 0.8;
    splitButton.strokeColor =[UIColor whiteColor];
    splitButton.lineWidth = 1.0;
    splitButton.zPosition = buttonZposition;
    splitButton.position = CGPointMake(self.size.width/2 - 80 , -self.size.height/2 + 40);
    [self addChild:splitButton];
    
    SKLabelNode *labelSplit = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    labelSplit.text = @"Split";
    labelSplit.fontColor = [UIColor whiteColor];
    labelSplit.fontSize = 12;
    labelSplit.position = CGPointMake(0, -4);
    [splitButton addChild:labelSplit];
    
    /* add buttons - end here */
    
    
    /*creating player*/
    
    UIColor *tempColor = [self getRandomColor];
    myColorString = [tempColor description];
    player = [Player Player:tempColor WorldSize:GRID PlayerName:self.playerName];
    [world addChild:player];
    [player setCentreP:CGPointMake(arc4random_uniform(GRID), arc4random_uniform(GRID))];
    if ([self.gameType isEqualToString:@"onlineGame"]) {
        myPositionX = [NSString stringWithFormat:@"%f", player.centre.x];
        myPositionY = [NSString stringWithFormat:@"%f", player.centre.y];
    }
    
    

    /*initial playerCell*/
        PlayerCell *cell = player.playerCellArray[0];
    
        /*creating aiPlayer*/
        if ([self.gameType isEqualToString:@"singleGame"]) {
            
            /*set AI*/
            AI1 =[AICell AICell:[cell getNumberofMass] PlayerSpeed:[cell getSpeed]];
            AIAlive = true;
            [world addChild:AI1];
        }
        
        
    isOver = false;
    onlineGameOver = false;
        
    restOfFood = FOOD;
    
    /*add back home button*/
    homeButton = [SKSpriteNode spriteNodeWithImageNamed:@"house"];
    homeButton.xScale = 1.5;
    homeButton.yScale = 1.5;
    homeButton.position =CGPointMake(-self.size.width/2 + 15 , - self.size.height/2 + 15);
    homeButton.zPosition = buttonZposition;
    [self addChild:homeButton];
    
    /*add acceletor control button*/
    acceletorAddButton = [SKSpriteNode spriteNodeWithImageNamed:@"controller_add"];
    acceletorAddButton.xScale = 1.5;
    acceletorAddButton.yScale = 1.5;
    acceletorAddButton.position = CGPointMake(-self.size.width/2 + 50 , - self.size.height/2 + 15);
    acceletorAddButton.zPosition = buttonZposition;
    [self addChild:acceletorAddButton];
    
    acceletorDelButton = [SKSpriteNode spriteNodeWithImageNamed:@"controller_del"];
    acceletorDelButton.xScale= 1.5;
    acceletorDelButton.yScale = 1.5;
    acceletorDelButton.position = CGPointMake(-self.size.width/2 + 75 , - self.size.height/2 + 15);
    acceletorDelButton.zPosition = buttonZposition;
    acceletorDelButton.alpha = 0.0;
    [self addChild:acceletorDelButton];
    
    
    /* Points Label*/
    SKLabelNode *labelPoint = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    labelPoint.text = @"Points:";
    labelPoint.fontColor = [UIColor whiteColor];
    labelPoint.fontSize = 10;
    labelPoint.position = CGPointMake(-self.size.width/2 + 40 , self.size.height/2 -20 );
    labelPoint.zPosition = buttonZposition;
    [self addChild:labelPoint];
    
    pointLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    pointLabel.text = @"0";
    pointLabel.fontColor = [UIColor whiteColor];
    pointLabel.position = CGPointMake(60, 0);
    pointLabel.fontSize = 14;
    [labelPoint addChild:pointLabel];
    
    /*Live Time label*/
    SKLabelNode *labelLiveTime = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    labelLiveTime.text = @"LiveTime:";
    labelLiveTime.fontColor = [UIColor whiteColor];
    labelLiveTime.fontSize = 10;
    labelLiveTime.position = CGPointMake(-self.size.width/2 + 40 , self.size.height/2 - 35 );
    labelLiveTime.zPosition = buttonZposition;
    [self addChild:labelLiveTime];
    
    liveTimeLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
    liveTimeLabel.text = @"0";
    liveTimeLabel.fontColor = [UIColor whiteColor];
    liveTimeLabel.position = CGPointMake(60, 0);
    liveTimeLabel.fontSize = 14;
    [labelLiveTime addChild:liveTimeLabel];
    
    /*add attacted lablel*/
    if ([self.gameType isEqualToString:@"singleGame"] ||[self.gameType isEqualToString:@"practice"] ) {
        
        SKLabelNode *labelAttact = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        labelAttact.text = @"Attached:";
        labelAttact.fontColor = [UIColor whiteColor];
        labelAttact.fontSize = 10;
        labelAttact.position = CGPointMake(-self.size.width/2 + 40 , self.size.height/2 - 50 );
        labelAttact.zPosition = buttonZposition;
        [self addChild:labelAttact];
        
        attactLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        attactLabel.text = @"0";
        attactLabel.fontColor = [UIColor whiteColor];
        attactLabel.position = CGPointMake(60, 0);
        attactLabel.fontSize = 14;
        [labelAttact addChild:attactLabel];
        
        
        /*rest of food label*/
        SKLabelNode *labelRestFood = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        labelRestFood.text = @"RestFood:";
        labelRestFood.fontColor = [UIColor whiteColor];
        labelRestFood.fontSize = 10;
        labelRestFood.position = CGPointMake(self.size.width/2 - 100 , self.size.height/2 - 20 );
        labelRestFood.zPosition = buttonZposition;
        [self addChild:labelRestFood];
        
        foodLabel = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        foodLabel.text = [NSString stringWithFormat:@"%i", FOOD];
        foodLabel.fontColor = [UIColor whiteColor];
        foodLabel.position = CGPointMake(60, 0);
        foodLabel.fontSize = 14;
        [labelRestFood addChild:foodLabel];
        
        
    }
    
    /*add leaderboard labels in game*/
    if ([self.gameType isEqualToString:@"onlineGame"]) {
        SKLabelNode *labelNo1 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        labelNo1.text = @"No1";
        labelNo1.fontColor = [UIColor whiteColor];
        labelNo1.fontSize = 10;
        labelNo1.zPosition = buttonZposition;
        labelNo1.position = CGPointMake(self.size.width/2 - 100, self.size.height/2 - 20);
        [self addChild:labelNo1];
        
        
        firstPlayer = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        firstPlayer.fontColor = [UIColor whiteColor];
        firstPlayer.fontSize = 10;
        firstPlayer.zPosition = buttonZposition;
        firstPlayer.position = CGPointMake(self.size.width/2 - 50, self.size.height/2 - 20);
        [self addChild:firstPlayer];
        
        SKLabelNode *labelNo2 = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        labelNo2.text = @"No2";
        labelNo2.fontColor = [UIColor whiteColor];
        labelNo2.fontSize = 10;
        labelNo2.zPosition = buttonZposition;
        labelNo2.position = CGPointMake(self.size.width/2 - 100, self.size.height/2 - 30);
        [self addChild:labelNo2];
        
        secondPlayer = [SKLabelNode labelNodeWithFontNamed:GAME_FONT];
        secondPlayer.fontColor = [UIColor whiteColor];
        secondPlayer.fontSize = 10;
        secondPlayer.zPosition = buttonZposition;
        secondPlayer.position = CGPointMake(self.size.width/2 - 50, self.size.height/2 - 30);
        [self addChild:secondPlayer];
        
    }
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    self.view.multipleTouchEnabled = YES;
    
    UITouch * touch = [touches anyObject];
    
    //touch in scene:
    CGPoint location = [touch locationInNode:self];
    
    if ([ejectButton containsPoint:location]) {
        NSLog(@"PRESS BUTTON A");
        
        [player ejectMass:generator];
        
    }else if([splitButton containsPoint:location])
    {
        NSLog(@"PRESS BUTTON B");
        
        [player splitCell];
        
        
    }else if ([homeButton containsPoint:location])
    {
        if ([self.gameType isEqualToString:@"singleGame"]) {
            
            self.startMenu.LeaderBoardInfo = self.goalsSoFar;
        }
        
        if (![self.gameType isEqualToString:@"practice"]) {
            [self disconnect];
        }

        
        [self.startMenu addInputText];
        [self.view presentScene:self.startMenu];
        
    }else if ([acceletorAddButton containsPoint:location] && !startAcceletor)
    {
        startAcceletor = true;
        acceletorAddButton.alpha = 0.0;
        acceletorDelButton.alpha = 1.0;
    }else if ([acceletorDelButton containsPoint:location] && startAcceletor)
    {
        
        startAcceletor = false;
        acceletorAddButton.alpha = 1.0;
        acceletorDelButton.alpha = 0.0;
    }
    else
    {
        
        
        /*there will set a range of distance to decide
         how many percentage of max moveMoment speed can get, if the distance lower than radius, the stop
         else, there is a max range to get 100% speedMovement
         */
        
        
        for (PlayerCell *oneOfCell in player.playerCellArray) {
            
            if (oneOfCell.stillAlive) {
                
                /*get the direction vector*/
                CGPoint positionInSense = [oneOfCell.scene convertPoint:oneOfCell.position fromNode:oneOfCell.parent];
                
                CGPoint cellDirection = CGPointMake(location.x - positionInSense.x, location.y-positionInSense.y);
                
                /*get the distance*/
                float distance = sqrtf(location.x*location.x +location.y*location.y);
                
                
                /*control the percentage of speed*/
                float percentage = 0;
                
                float rangeOfRadius = [oneOfCell getRadius];
                
                if (distance < rangeOfRadius) {
                    percentage = 0 ;
                    
                }
                else if (distance > 4*rangeOfRadius)
                {
                    percentage = 1;
                }
                else
                {
                    percentage = distance/(4*rangeOfRadius);
                    
                }
                
                /*set the cell direction*/
                oneOfCell.direction = CGPointMake(cellDirection.x*percentage/distance, cellDirection.y*percentage/distance);
                oneOfCell.lastDirection = CGPointMake(cellDirection.x/distance, cellDirection.y/distance);
            }
            
            
        }
        
        
    }
    
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.view.multipleTouchEnabled = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    
    /*there will set a range of distance to decide
     how many percentage of max moveMoment speed can get, if the distance lower than radius, the stop
     else, there is a max range to get 100% speedMovement
     */
    
    
    for (PlayerCell *oneOfCell in player.playerCellArray) {
        
        if (oneOfCell.stillAlive)
        {
            
            /*get the direction vector*/
            CGPoint positionInSense = [oneOfCell.scene convertPoint:oneOfCell.position fromNode:oneOfCell.parent];
            
            CGPoint cellDirection = CGPointMake(location.x - positionInSense.x, location.y-positionInSense.y);
            
            /*get the distance*/
            float distance = sqrtf(location.x*location.x +location.y*location.y);
            
            
            /*control the percentage of speed*/
            float percentage = 0;
            
            float rangeOfRadius = [oneOfCell getRadius];
            
            if (distance < rangeOfRadius) {
                percentage = 0 ;
                
            }
            else if (distance > 4*rangeOfRadius)
            {
                percentage = 1;
            }
            else
            {
                percentage = distance/(4*rangeOfRadius);
                
            }
            
            /*set the cell direction*/
            oneOfCell.direction = CGPointMake(cellDirection.x*percentage/distance, cellDirection.y*percentage/distance);
            oneOfCell.lastDirection = CGPointMake(cellDirection.x/distance, cellDirection.y/distance);
        }
        
        
        
        
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
//    [self changeTheBackgroundColor];
    
    if(!isOver)
    {
        /*calculate the time since last*/
        CFTimeInterval timeScinceLast = currentTime - self.lasteUpdateTimeInterval;
        self.lasteUpdateTimeInterval = currentTime;
        
        if (timeScinceLast > 1) {
            timeScinceLast = 1.0/60.0;
            self.lasteUpdateTimeInterval = currentTime;
        }
        
        /*call the player method to move*/
        [player updatePositionWithTimeInvterval:timeScinceLast];
        
        /*run the AI*/
        if ([self.gameType isEqualToString:@"singleGame"] && AIAlive) {
            CGPoint towards = ((PlayerCell *)[player.playerCellArray objectAtIndex:[player theMinCell]]).position;
            [AI1 calculateTheDirection:towards];
            [AI1 moveMethod];
            
        }
    }
    
    
    if ([self.gameType isEqualToString:@"onlineGame"]) {
        
        /*remove previou*/
        [enemyCell removeFromParent];
    
       
        
        /*create new*/
        if (enemyPositionX != NULL) {
            
            enemyCell = [AICell AIcellwithPosition:[self getCGpointFromStringX:enemyPositionX StringY:enemyPositionY]
                                            AIname:enemyName
                                           AIcolor:[self getUIColorFromString:enemyColorString]
                                            AIMass:[enemyMass floatValue]];
            [world addChild:enemyCell];
        }
    }
    
}


-(void)didBeginContact:(SKPhysicsContact *)contact
{
    
    // NSLog(@"start contact");
    
    
    
    /* this block deals with the contact with food*/
    
    if ([contact.bodyA.node.name isEqualToString:@"food"] || [contact.bodyB.node.name isEqualToString:@"food"])
    {
        NSLog(@"FOOD!!!");
        if ([contact.bodyA.node.name isEqualToString:@"food"]) {
            [contact.bodyA.node removeFromParent];
            [(PlayerCell *)contact.bodyB.node ateFunction:1];
            restOfFood = restOfFood - 1;
        }
        
        if ([contact.bodyB.node.name isEqualToString:@"food"]) {
            [contact.bodyB.node removeFromParent];
            [(PlayerCell *)contact.bodyA.node ateFunction:1];
            restOfFood = restOfFood - 1;
        }
    }
    
    
    /* this block deals with contact with player own cell*/
    if ([contact.bodyA.node.name isEqualToString:@"playerCell"]&&[contact.bodyB.node.name isEqualToString:@"playerCell"]) {
        
        PlayerCell *cellOne = (PlayerCell *)contact.bodyA.node;
        PlayerCell *cellTwo = (PlayerCell *)contact.bodyB.node;
        
        /*not necessary check here, just store the objects which contact*/
        NSMutableArray *contactObject = [NSMutableArray array];
        
        [contactObject addObject:@"ownCellMeger"];
        [contactObject addObject:cellOne];
        [contactObject addObject:cellTwo];
        
        [self.megerArray addObject:contactObject];
        
        
    }
    
    /*this block deal with contact with virus*/
    if ([contact.bodyA.node.name isEqualToString:@"virus"] || [contact.bodyB.node.name isEqualToString:@"virus"]) {
        
        PlayerCell *cell;
        SKSpriteNode *virus;
        
        NSLog(@"VIRUS!");
        /*get the contact nodes*/
        if ([contact.bodyA.node.name isEqualToString:@"virus"]) {
            
            cell = (PlayerCell *)contact.bodyB.node;
            virus = (SKSpriteNode *)contact.bodyA.node;
        }
        else
        {
            cell = (PlayerCell *)contact.bodyA.node;
            virus = (SKSpriteNode *)contact.bodyB.node;
        }
        
        /*NOT DEAL WITH HERE added to the Megerable array
         if the cell smaller then virus, not need to worry
         esle add to megerArray, due to the set 0.5 scale to texture of physical body,
         the texture width/4 will be its radius
         */
        
        if (cell.getRadius > 13) {
            
            NSLog(@"ADD TO ARRAY");
            
            NSMutableArray *contactObject = [NSMutableArray array];
            
            [contactObject addObject:@"megerVirus"];
            [contactObject addObject:cell];
            [contactObject addObject:virus];
            
            [self.megerArray addObject:contactObject];
        }
        
    }
    
    
    /*this block deal with contact with boundary Left and Right -- make bound off immediately when contact*/
    if ([contact.bodyA.node.name isEqualToString:@"edgeLeft"] || [contact.bodyA.node.name isEqualToString:@"edgeRight"] ||
        [contact.bodyB.node.name isEqualToString:@"edgeRight"] || [contact.bodyB.node.name isEqualToString:@"edgeLeft"]) {
        
        
        /*get the cell node*/
        PlayerCell *cell;
        
        if ([contact.bodyA.node.name isEqualToString:@"playerCell"])
        {
            cell = (PlayerCell *)contact.bodyA.node;
        }
        else
        {
            cell= (PlayerCell *)contact.bodyB.node;
            
        }
        
        if (cell.stillAlive) {
            
            /*
             the direction will be changed as following rule:
             1.  Y keeps the same value  2. X become the oppisite value
             */
            
            cell.direction = CGPointMake(-cell.direction.x, cell.direction.y);
            cell.lastDirection = cell.direction;
        }
        
    }
    
    
    /*this block deal with contact with boundary Bottom and Top -- make bound off immediately when contact*/
    
    if ([contact.bodyA.node.name isEqualToString:@"edgeTop"] || [contact.bodyA.node.name isEqualToString:@"edgeBottom"] ||
        [contact.bodyB.node.name isEqualToString:@"edgeTop"] || [contact.bodyB.node.name isEqualToString:@"edgeBottom"]) {
        
        /*get the cell node*/
        PlayerCell *cell;
        
        if ([contact.bodyA.node.name isEqualToString:@"playerCell"])
        {
            cell = (PlayerCell *)contact.bodyA.node;
        }
        else
        {
            cell= (PlayerCell *)contact.bodyB.node;
            
        }
        
        if (cell.stillAlive) {
            
            
            /*the direction will be changed as following rule:
             1.  X keeps the same value  2. Y become the oppisite value
             */
            
            cell.direction = CGPointMake(cell.direction.x, -cell.direction.y);
            cell.lastDirection = cell.direction;
        }
    }
    
    /*this block deal with contact with animy*/
    if (([contact.bodyA.node.name isEqualToString:@"animy"] && [contact.bodyB.node.name isEqualToString:@"playerCell"] )|| ([contact.bodyB.node.name isEqualToString:@"animy"] && [contact.bodyA.node.name isEqualToString:@"playerCell"]))
    {
        /*get the playerCell*/
        PlayerCell *cell;
        AICell *cell2;
        
        if ([contact.bodyA.node.name isEqualToString:@"playerCell"])
        {
            cell = (PlayerCell *)contact.bodyA.node;
            cell2 = (AICell *)contact.bodyB.node;
        }
        else
        {
            cell= (PlayerCell *)contact.bodyB.node;
            cell2 = (AICell *)contact.bodyA.node;
            
        }
        
        NSMutableArray *contactObject = [NSMutableArray array];
        
        [contactObject addObject:@"AIattach"];
        [contactObject addObject:cell];
        [contactObject addObject:cell2];
        
        [self.megerArray addObject:contactObject];
    }
    
}

-(void)didEndContact:(SKPhysicsContact *)contact
{
    /*This block deals with the contact with linear obstacle*/
    if ([contact.bodyA.node.name isEqualToString:@"obstacle"]||[contact.bodyB.node.name isEqualToString:@"obstacle"])
    {
        /*get the cell node and obstacle node*/
        PlayerCell *cell;
        SKSpriteNode *obstacle;
        
        
        if ([contact.bodyA.node.name isEqualToString:@"playerCell"])
        {
            cell = (PlayerCell *)contact.bodyA.node;
            obstacle = (SKSpriteNode *)contact.bodyB.node;
        }
        else
        {
            cell= (PlayerCell *)contact.bodyB.node;
            obstacle = (SKSpriteNode *)contact.bodyA.node;
        }
        
        if (cell.stillAlive) {
            /*judge the direction of obstacles -- the logical of contact is similar with contact with
             boundary edge.
             */
            if (obstacle.size.width > obstacle.size.height) {
                /*this is horizontal direction, ignore the left and right edges
                 just consider the bottom and top edge:
                 1. X remains the same value 2. Y become the oppsite value
                 */
                
                cell.direction = CGPointMake(cell.direction.x, -cell.direction.y);
                cell.lastDirection = cell.direction;
                
            }
            else
            {
                /*this is vertical direction, ignore the bottom and top edges
                 just consider the left and right edge:
                 1.  Y keeps the same value  2. X become the oppisite value
                 */
                
                cell.direction = CGPointMake(-cell.direction.x, cell.direction.y);
                cell.lastDirection = cell.direction;
            }
        }
        
    }
}

- (void)didFinishUpdate
{
    /*each frame remove the dead cell from array*/
    [player cleanArray];
    
    /*check the brightness of screen*/
    [self changeTheBackgroundColor];
    
    /*check the onlinegame over*/
    if ([self.gameType isEqualToString:@"onlineGame"] && onlineGameOver) {
        [self overMethodOnline];
        self.view.paused = YES;
    }
    
    /*check is over or not*/
    if ([player.playerCellArray count]<1 || restOfFood == 0) {
        isOver = true;
    }
    
    if (!isOver) {
        
        /*update the centre point of player each frame*/
        player.centre = ((PlayerCell *)player.playerCellArray[0]).position;
        
        /*Camera*/
        world.position = CGPointMake(-player.centre.x + CGRectGetMidX(self.frame), -player.centre.y + CGRectGetMidY(self.frame));
        
        /*meger method*/
        [self checkMegarable];
        
        
        /*check is it need to add new ai*/
        if (!AIAlive && [self.gameType isEqualToString:@"singleGame"] ) {
            
            CFTimeInterval currentTime = CACurrentMediaTime();
            
            /*AI COLD JUST 5s*/
            if (currentTime - AIcoldTime > 5) {
                PlayerCell *maxCell = (PlayerCell *)[player.playerCellArray objectAtIndex:[player theMaxCell]];
                PlayerCell *minCell = (PlayerCell *)[player.playerCellArray objectAtIndex:[player theMinCell]];
                
                AI1 =[AICell AICell:maxCell.getNumberofMass PlayerSpeed:minCell.getSpeed];
                AIAlive = true;
                [world addChild:AI1];
            }
        }
        
        /*update the point*/
        if ([pointLabel.text integerValue] < player.totalNumberOfMass) {
            pointLabel.text = [NSString stringWithFormat:@"%i", player.totalNumberOfMass];
            
        }
        
        /*update the live time*/
        liveTimeLabel.text = [NSString stringWithFormat:@"%i", (int)(CACurrentMediaTime()- player.bornTime)];
        
        /*udate ai attacted time*/
        if (player.numberOfAIattacted > [attactLabel.text integerValue]) {
            attactLabel.text = [NSString stringWithFormat:@"%i", player.numberOfAIattacted];
        }
        
        /*update rest of food label*/
        if (restOfFood < [foodLabel.text integerValue]) {
            foodLabel.text = [NSString stringWithFormat:@"%i", restOfFood];
        }
        
    }
    
    /*if game is over then invoke the gameOverMethod*/
    if (isOver && [self.gameType isEqualToString:@"singleGame"]) {
        NSDictionary *tempDic = [self overMethod];
        goalOfThisTurn = [NSMutableDictionary dictionaryWithDictionary:tempDic];
        [goalsSoFar addObject: tempDic];
        [self sendGoalOfThisTurn];
        self.view.paused = YES;
        
        
    }
    
    /*check if it is a onlinegame then message exchange*/
    if ([self.gameType isEqualToString:@"onlineGame"] && !onlineGameOver) {
        myPositionX = [NSString stringWithFormat:@"%f",player.getCentre.x];
        myPositionY = [NSString stringWithFormat:@"%f",player.getCentre.y];
        [self sendPlayerInfo];
        
        [self changeTheOnlineLeaderBoard];
    }
    
    
    
    /*calculate the direction from accelerometer*/
    if (startAcceletor) {
        
        [motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            
            
            
            float xDirection = accelerometerData.acceleration.x;
            float yDirection = accelerometerData.acceleration.y;
            
            float cellDirectionX = 0;
            float cellDirectionY = 0;
            
            /* LEFT TOP*/
            if (xDirection < 0 && yDirection < 0) {
                cellDirectionX = yDirection;
                cellDirectionY = -xDirection;
            }
            
            /*RIGHT TOP*/
            if (xDirection < 0 && yDirection > 0) {
                cellDirectionX = yDirection;
                cellDirectionY = -xDirection;
            }
            
            /*LEFT BOTTOM*/
            if (xDirection > 0 && yDirection < 0) {
                cellDirectionX = yDirection;
                cellDirectionY = -xDirection;
            }
            
            /*RIGHT BOTTOM*/
            if (xDirection > 0 && yDirection > 0) {
                cellDirectionX = yDirection;
                cellDirectionY = -xDirection;
            }
            
            for (PlayerCell *cell in player.playerCellArray) {
                cell.direction = CGPointMake(cellDirectionX,cellDirectionY);
                cell.lastDirection = cell.direction;
            }
        }];
    }
    
    
}

// use to make sure the player can not move out the boundry
/* NEW version using velocity to move, no necessary to checke - 14/9 */

/*get random color for player*/
- (UIColor *)getRandomColor
{
    int rand = arc4random() % 6;
    
    UIColor *color;
    switch (rand) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor blackColor];
            break;
        case 2:
            color = [UIColor blueColor];
            break;
        case 3:
            color = [UIColor orangeColor];
            break;
        case 4:
            color = [UIColor purpleColor];
            break;
        case 5:
            color = [UIColor greenColor];
            break;
        default:
            break;
    }
    return color;
}

//
///* double tap to stop the move*/
//-(void)handleTapGesture:(UITapGestureRecognizer *)sender{
//
//}

/*this method used to check the megerable contact about cell*/
-(void)checkMegarable
{
    for (int i = 0; i < [self.megerArray count]; i++) {
        
        /* get the contact array*/
        NSMutableArray *contactArray = [self.megerArray objectAtIndex:i];
        
        /*get the type of meger*/
        NSString *contactName = [contactArray objectAtIndex:0];
        
        /*deal with player own Cells meger*/
        if ([contactName isEqualToString:@"ownCellMeger"])
        {
            PlayerCell *contactOne = [contactArray objectAtIndex:1];
            PlayerCell *contactTwo = [contactArray objectAtIndex:2];
            
            CFTimeInterval currentTime = CACurrentMediaTime();
            CFTimeInterval timeOne = currentTime - contactOne.cellBornTime;
            CFTimeInterval timeTwo = currentTime - contactTwo.cellBornTime;
            
            /* IF ALIVE MORE THEN 10 s then can be megered */
            if (timeOne > 15 && timeTwo > 15) {
                
                /*keep changing the masks*/
                contactOne.physicsBody.categoryBitMask = megerCategory;
                contactTwo.physicsBody.categoryBitMask = megerCategory;
                
                /*calculate the distance between two cells*/
                CGPoint onePosition = [contactOne.scene convertPoint:contactOne.position fromNode:contactOne.parent];
                CGPoint twoPosition = [contactTwo.scene convertPoint:contactTwo.position fromNode:contactTwo.parent];
                
                float distance = sqrtf((onePosition.x - twoPosition.x)*(onePosition.x - twoPosition.x)+
                                       (onePosition.y - twoPosition.y)*(onePosition.y - twoPosition.y));
                
                /*if two cell not contact then remove,or one of them has been ate*/
                if (distance > (contactOne.getRadius + contactTwo.getRadius) || !contactOne.stillAlive || !contactTwo.stillAlive) {
                    [self.megerArray removeObjectAtIndex:i];
                    break;
                }
                
                
                /*compare the size of two cells*/
                if (contactOne.getRadius >= contactTwo.getRadius) {
                    
                    /*smaller one will be lower zPosition*/
                    contactTwo.zPosition = 0.1;
                    
                    /*if the centre point of smaller cell located in bigger one*/
                    if (distance <= contactTwo.getRadius) {
                        
                        /*bigger Cell ate smaller cell*/
                        [contactOne ateFunction:contactTwo.getNumberofMass];
                        contactTwo.stillAlive = false;
                        [contactTwo removeFromParent];
                        
                        /*delete the object from array*/
                        [self.megerArray removeObjectAtIndex:i];
                        break;
                    }
                }
                else
                {
                    contactOne.zPosition = 0.1;
                    
                    if (distance <= contactOne.getRadius) {
                        
                        /*bigger Cell ate smaller cell*/
                        [contactTwo ateFunction:contactOne.getNumberofMass];
                        contactOne.stillAlive = false;
                        [contactOne removeFromParent];
                        
                        /*delete the object from array*/
                        [self.megerArray removeObjectAtIndex:i];
                        break;
                    }
                }
                
            }
        }
        
        
        /*deal with meger with virus*/
        if ([contactName isEqualToString:@"megerVirus"]) {
            PlayerCell *cell = [contactArray objectAtIndex:1];
            SKSpriteNode *virus = [contactArray objectAtIndex:2];
            
            float distance = sqrtf((cell.position.x - virus.position.x)*(cell.position.x - virus.position.x)+
                                   (cell.position.y - virus.position.y)*(cell.position.y - virus.position.y));
            
            /*check whether the virus has been included*/
            if (distance <= 13 ) {
                /*remove the virus*/
                [virus removeFromParent];
                
                /*call the player meger virus method*/
                [player ateVirus:cell];
                
                /*remove from array*/
                [self.megerArray removeObjectAtIndex:i];
                break;
            }
            
            /*not contact or cell already dead*/
            if (distance > cell.getRadius + 13 || !cell.stillAlive) {
                /*remove from array*/
                [self.megerArray removeObjectAtIndex:i];
                break;
            }
        }
        
        /*deal with contact with ai*/
        if ([contactName isEqualToString:@"AIattach"])
        {
            PlayerCell *cell = [contactArray objectAtIndex:1];
            AICell *aicell = [contactArray objectAtIndex:2];
            
            float distance = sqrtf((cell.position.x - aicell.position.x)*(cell.position.x - aicell.position.x)+
                                   (cell.position.y - aicell.position.y)*(cell.position.y - aicell.position.y));
            
            if (distance > cell.getRadius + aicell.radius) {
                [self.megerArray removeObjectAtIndex:i];
                break;
            }
            else
            {
                if (cell.getRadius > aicell.radius) {
                    /*just get 20% of ai cell mass*/
                    [cell ateFunction:(int)(aicell.numberOfMass * 0.2)];
                    
                    /*remove ai*/
                    [aicell removeFromParent];
                    
                    AIAlive = false;
                    AIcoldTime = CACurrentMediaTime();
                    
                    player.numberOfAIattacted = player.numberOfAIattacted + 1;
                    
                    [self.megerArray removeObjectAtIndex:i];
                    
                    /*judge the status of online game*/
                    if ([self.gameType isEqualToString:@"onlineGame"]) {
                        onlineGameOver = true;
                    }
                    
                    break;
                    
                    
                }
                else
                {
                    [cell removeFromParent];
                    cell.stillAlive = false;
                    
                    [self.megerArray removeObjectAtIndex:i];
                    
                    /*judge the status of online game*/
                    if ([self.gameType isEqualToString:@"onlineGame"]) {
                        onlineGameOver = true;
                    }
                    
                    break;
                }
            }
            
        }
    }
}

/*online game over method*/
-(void)overMethodOnline
{
    /*one of players has been ated then the game is over*/
    if ([player.playerCellArray count] > 0 ) {
        SKLabelNode *gameOverW = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        gameOverW.text = @"Game Over - You Win";
        gameOverW.fontSize = 32;
        gameOverW.position = CGPointMake(0, 0);
        gameOverW.zPosition = 0.7;
        [self addChild:gameOverW];
    }else
    {
        SKLabelNode *gameOverL = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        gameOverL.text = @"Game Over - You Lose";
        gameOverL.fontSize = 32;
        gameOverL.position = CGPointMake(0, 0);
        gameOverL.zPosition = 0.7;
        [self addChild:gameOverL];
    }

}


//this method is invoked when the game is over
//it generates and returns the result dictionary for leader board
-(NSMutableDictionary *)overMethod
{
    MessageConstructor *messageMaker = [[MessageConstructor alloc] init];
    SKLabelNode *gameOver = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    gameOver.text = @"Game Over";
    gameOver.fontSize = 32;
    gameOver.position = CGPointMake(0, 0);
    gameOver.zPosition = 0.7;
    [self addChild:gameOver];
    
    int liveTime = [liveTimeLabel.text intValue];
    int foodCount = [pointLabel.text intValue];
    int attackedNum = [attactLabel.text intValue];
    int goal = liveTime + foodCount + 10*attackedNum;
    
//    NSLog(@"livetime is %d",liveTime);
//    NSLog(@"foodCount is %d",foodCount);
//    NSLog(@"attackedNum is %d",attackedNum);
//    NSLog(@"goal is %d", goal);
    
    NSMutableDictionary *goalDic = [messageMaker leaderBoardRecordDicPlayerName:playerName LiveTime:liveTime FoodCount:foodCount AIAttacked:attackedNum Goal:goal];
    
//    NSLog(@"goalDic is %@", goalDic);
    
    return goalDic;
    
}

/*change the background color based on brightness*/
-(void)changeTheBackgroundColor
{
    UIScreen *myScreen = [UIScreen mainScreen];
    NSLog(@"the brightness is %f", myScreen.brightness);
    
    if (myScreen.brightness < 0.5) {
        self.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        self.backgroundColor = [UIColor grayColor];
    }
   
}

/*change the leader board in online game*/
-(void)changeTheOnlineLeaderBoard
{
    if ([(PlayerCell *)player.playerCellArray[0] getNumberofMass] > [enemyMass floatValue]) {
        firstPlayer.text = player.playerName;
        secondPlayer.text = enemyName;
    }else
    {
        secondPlayer.text = player.playerName;
        firstPlayer.text = enemyName;
    }
}

@end

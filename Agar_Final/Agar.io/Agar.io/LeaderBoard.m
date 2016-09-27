/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/
/********************************************************************
 FileName: LeaderBoard.m
 Date: 13 Oct 2015
 Description: this is the view which presents the leaderboard
 Functions: 1. create basic labels
            2. order the info from the server
            3. calculate the final point based on info
            4. present the ordered info
 *******************************************************************/

#import "LeaderBoard.h"
#import "StartMenu.h"
#import "GameScene.h"
#import "MessageConstructor.h"
#import "MessageReader.h"
#import "MessageWriter.h"


typedef enum {
    MessagePlayerInfo = 0,
    MessageEatenFoodPositions = 1,
    MessageSingleGameGoal = 9,
    
} MessageType;

@implementation LeaderBoard
{
    SKLabelNode *back;

}

@synthesize goalsArray;
@synthesize sortedLatest5Goals;




static NSString *GAME_FONT = @"Chalkduster";


-(void)didMoveToView:(SKView *)view {
    
    
//    NSLog(@"i am leader board");
    
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    SKLabelNode *headNo = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    headNo.text = @"No.";
    headNo.fontSize = 12;
    headNo.position = CGPointMake(-220,self.frame.size.height/2 - 35);
    [self addChild:headNo];
    
    SKLabelNode *headPlayer = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    headPlayer.text = @"PlayerName";
    headPlayer.fontSize = 12;
    headPlayer.position = CGPointMake(-150,self.frame.size.height/2 - 35);
    [self addChild:headPlayer];
    
    SKLabelNode *headLive = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    headLive.text = @"LiveTime";
    headLive.fontSize = 12;
    headLive.position = CGPointMake(-60,self.frame.size.height/2 - 35);
    [self addChild:headLive];
    
    SKLabelNode *headFood = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    headFood.text = @"Food";
    headFood.fontSize = 12;
    headFood.position = CGPointMake(20,self.frame.size.height/2 - 35);
    [self addChild:headFood];
    
    SKLabelNode *headAttacted = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    headAttacted.text = @"Attacted";
    headAttacted.fontSize = 12;
    headAttacted.position = CGPointMake(100,self.frame.size.height/2 - 35);
    [self addChild:headAttacted];

    SKLabelNode *headGoal = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    headGoal.text = @"Goal";
    headGoal.fontSize = 12;
    headGoal.position = CGPointMake(180,self.frame.size.height/2 - 35);
    [self addChild:headGoal];
    
    
//    the following is the test data for the goal sort function
//    NSMutableDictionary *Goal1 = [NSMutableDictionary dictionaryWithDictionary:@{
//                            @"PlayerName": @"White",
//                            @"LiveTime": [NSNumber numberWithInt:9],
//                            @"FoodCount": [NSNumber numberWithInt:10],
//                            @"AIAttacked": [NSNumber numberWithInt:10],
//                            @"Goal": [NSNumber numberWithInt:100],
//                            }];
//
//    NSMutableDictionary *Goal2 = [NSMutableDictionary dictionaryWithDictionary:@{
//                            @"PlayerName": @"Red",
//                            @"LiveTime": [NSNumber numberWithInt:2],
//                            @"FoodCount": [NSNumber numberWithInt:66],
//                            @"AIAttacked": [NSNumber numberWithInt:10],
//                            @"Goal": [NSNumber numberWithInt:70],
//                            }];
//
//    NSMutableDictionary *Goal3 = [NSMutableDictionary dictionaryWithDictionary:@{
//                            @"PlayerName": @"Blue",
//                            @"LiveTime": [NSNumber numberWithInt:9],
//                            @"FoodCount": [NSNumber numberWithInt:10],
//                            @"AIAttacked": [NSNumber numberWithInt:10],
//                            @"Goal": [NSNumber numberWithInt:75],
//                            }];
//
//    NSMutableDictionary *Goal4 = [NSMutableDictionary dictionaryWithDictionary:@{
//                            @"PlayerName": @"Purple",
//                            @"LiveTime": [NSNumber numberWithInt:9],
//                            @"FoodCount": [NSNumber numberWithInt:10],
//                            @"AIAttacked": [NSNumber numberWithInt:10],
//                            @"Goal": [NSNumber numberWithInt:85],
//                            }];
//    NSMutableDictionary *Goal5 = [NSMutableDictionary dictionaryWithDictionary:@{
//                            @"PlayerName": @"Yellow",
//                            @"LiveTime": [NSNumber numberWithInt:9],
//                            @"FoodCount": [NSNumber numberWithInt:10],
//                            @"AIAttacked": [NSNumber numberWithInt:10],
//                            @"Goal": [NSNumber numberWithInt:93],
//                            }];
//    NSMutableDictionary *Goal6 = [NSMutableDictionary dictionaryWithDictionary:@{
//                            @"PlayerName": @"Black",
//                            @"LiveTime": [NSNumber numberWithInt:9],
//                            @"FoodCount": [NSNumber numberWithInt:10],
//                            @"AIAttacked": [NSNumber numberWithInt:10],
//                            @"Goal": [NSNumber numberWithInt:50],
//                            }];
//
//    
//    goalsArray = [NSMutableArray arrayWithObjects:Goal1, Goal2, Goal3, Goal4, Goal5, Goal6, nil];
    
    NSArray *unsortedLatest5Goals = [self getLatest5GoalsFromGameGoalArray:goalsArray];
    sortedLatest5Goals = [self sortDicInLatest5RecordsArray:unsortedLatest5Goals];
    [self wraperSortedArray:sortedLatest5Goals];
    
//    NSLog(@"latest 5 goals: %@", sortedLatest5Goals);
    
    for (NSMutableDictionary *goal in sortedLatest5Goals) {
        [self generateInfoLabelFromDic:goal];
    }

    
//    [self generateInfoLabel:1 PlayerName:@"PPT" LiveTime:10 FoodCount:10 AIAttacted:10];
//    
//    [self generateInfoLabel:2 PlayerName:@"PPA" LiveTime:20 FoodCount:20 AIAttacted:20];
    
    back = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    back.text = @"BACK";
    back.fontSize = 20;
    back.position = CGPointMake(0,- self.frame.size.height/2 +40);
    [self addChild:back];
    
}






-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    UITouch * touch = [touches anyObject];
    
    //touch in scene:
    CGPoint location = [touch locationInNode:self];

    if ([back containsPoint:location]) {
        
        
        /*back to home*/
        
        [self.startMenu addInputText];
        [self.view presentScene:self.startMenu];
        
        
    }
}

/*get info and order*/
-(void)generateInfoLabelFromDic:(NSMutableDictionary *) goalDict
{
    NSInteger No = [goalDict[@"No"] integerValue] ;
    NSString *playerName = goalDict[@"PlayerName"];
    NSInteger liveTime = [goalDict[@"LiveTime"] integerValue];
    NSInteger foodCount = [goalDict[@"FoodCount"] integerValue];
    NSInteger attacked = [goalDict[@"AIAttacked"] integerValue];
    NSInteger goal = [goalDict[@"Goal"] integerValue];
    
    SKLabelNode *noLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    noLabel.text = [NSString stringWithFormat:@"%ld", No];
    noLabel.fontSize = 12;
    noLabel.position = CGPointMake(-220,self.frame.size.height/2 - (35 + No*15));
    [self addChild:noLabel];
    
    SKLabelNode *nameLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    nameLabel.text = playerName;
    nameLabel.fontSize = 12;
    nameLabel.position = CGPointMake(-150,self.frame.size.height/2 - (35 + No*15));
    [self addChild:nameLabel];
    
    SKLabelNode *liveLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    liveLabel.text = [NSString stringWithFormat:@"%ld", liveTime];
    liveLabel.fontSize = 12;
    liveLabel.position = CGPointMake(-60,self.frame.size.height/2 - (35 + No*15));
    [self addChild:liveLabel];
    
    SKLabelNode *foodLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    foodLabel.text = [NSString stringWithFormat:@"%ld", foodCount];
    foodLabel.fontSize = 12;
    foodLabel.position = CGPointMake(20,self.frame.size.height/2 - (35 + No*15));
    [self addChild:foodLabel];
    
    SKLabelNode *attackedLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    attackedLabel.text = [NSString stringWithFormat:@"%ld", attacked];
    attackedLabel.fontSize = 12;
    attackedLabel.position = CGPointMake(100,self.frame.size.height/2 - (35 + No*15));
    [self addChild:attackedLabel];
        
    SKLabelNode *goalLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    goalLabel.text = [NSString stringWithFormat:@"%ld", goal];
    goalLabel.fontSize = 12;
    goalLabel.position = CGPointMake(180,self.frame.size.height/2 - (35 + No*15));
    [self addChild:goalLabel];
}


//this method get the latest five game goals from the singleGameGoals array defined in GameScene class
//it return a NSArray whose elements are dictionarys
-(NSArray *)getLatest5GoalsFromGameGoalArray:(NSMutableArray *) GoalsArray{
    NSArray * latest5Records;
    NSRange theRange;
    
    if ([GoalsArray count] > 4) {
        theRange.location = [GoalsArray count] - 5;
        theRange.length = 5;
    }
    else {
        theRange.location = 0;
        theRange.length = [GoalsArray count];
    }
    
    latest5Records = [GoalsArray subarrayWithRange:theRange];
    
//    NSLog(@"latest 5 goals: %@", latest5Records);
    return  latest5Records;

}


//this method sort the lastest 5 goals in descend order
-(NSArray *)sortDicInLatest5RecordsArray:(NSArray *) latest5Records{
    
    NSSortDescriptor *goalDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"Goal"
                                        ascending:NO
                                        selector:@selector(compare:)];
    
    NSArray *sortDescriptors = @[goalDescriptor];
    
    NSArray *sortedArray = [latest5Records sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

/*sort the order*/
-(void)wraperSortedArray:(NSArray *) sortedArray{
    int i = 0;
    for (NSMutableDictionary *goalDic in sortedArray) {
        i++;
        goalDic[@"No"] = [NSString stringWithFormat:@"%d",i];
    }
}



@end

/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/

#import <SpriteKit/SpriteKit.h>
#import "StartMenu.h"

@interface LeaderBoard : SKScene

//get the goals from GameScene
@property NSMutableArray *goalsArray;

//it is the sorted goals array which is ready to display in leaderboard
@property NSArray *sortedLatest5Goals;

@property StartMenu *startMenu;




-(NSArray *)getLatest5GoalsFromGameGoalArray:(NSMutableArray *) GoalArray;

@end

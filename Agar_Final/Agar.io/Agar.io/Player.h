/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/

#import <SpriteKit/SpriteKit.h>
#import "WorldGenerator.h"
#import "PlayerCell.h"

@interface Player : SKSpriteNode

@property CGPoint centre;
@property NSMutableArray *playerCellArray;
@property CFTimeInterval  bornTime;
@property int totalNumberOfMass;
@property NSString *playerName;
@property int numberOfAIattacted;

+(id)Player:(UIColor *)color WorldSize:(CGFloat)GRID PlayerName:(NSString *)playerName;
- (void) updatePositionWithTimeInvterval: (CFTimeInterval) interval;
-(void)ejectMass:(WorldGenerator *) generator;
-(void)splitCell;
-(void)cleanArray;
-(CGPoint)getCentre;
-(void)setCentreP:(CGPoint)centre;
-(void)ateVirus:(PlayerCell *)cell;
-(int)theMinCell;
-(int)theMaxCell;
//-(void)checkMegerable;

@end

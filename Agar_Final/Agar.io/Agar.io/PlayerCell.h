/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/

#import <SpriteKit/SpriteKit.h>

@interface PlayerCell : SKShapeNode

//+(id) Player:(UIColor *) color;
@property SKShapeNode *circle;
@property CGPoint direction;
@property CGPoint lastDirection;
@property CFTimeInterval cellBornTime;
@property BOOL stillAlive;
@property SKLabelNode *playerNameLabel;
@property SKSpriteNode *specificBackground;

+(id) PlayerCell:(UIColor *) color PlayerName:(NSString*)playerName;
+(id) PlayerCellSplit:(PlayerCell *)previousCell Direction:(CGPoint)direction PlayerName:(NSString*)playerName;
- (float) getRadius;
-(void)ateFunction:(int)number;
-(void)setBody;
-(int)getSpeed;
- (void) updatePositionWithTimeInvterval: (CFTimeInterval) interval;
-(void)eject;
-(float)getNumberofMass;
-(void)split;
-(void)ateVirus;

@end

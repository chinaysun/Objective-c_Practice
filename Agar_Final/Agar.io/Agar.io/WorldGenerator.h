/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/

#import <SpriteKit/SpriteKit.h>

@interface WorldGenerator : SKNode

+(id)generatorWithWorld:(SKSpriteNode *)world getSize:(CGFloat)grid;
-(void)generateBoundary;
-(void)generateFood:(int)number;
-(void)addEject:(UIColor *)color Position:(CGPoint)position Direction:(CGPoint)direction Radius:(float)playerRadius;
-(void) generateStaticObstacles:(int)number;
-(void) generateVirus:(int)number;
-(void) importPosition;

@property NSArray *foodPositionNSArray;
@property NSArray *obstaclePositionNSArray;
@property NSArray *virusPositionNSArray;

@end

/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/

#import <SpriteKit/SpriteKit.h>

@interface AICell : SKShapeNode

@property SKLabelNode *nameOfAi;
@property int aiSpeed;
@property float radius;
@property float numberOfMass;
@property CGPoint direction;
@property SKSpriteNode *specificBackground;


+(id)AICell:(float)playerSize PlayerSpeed:(int)playerSpeed;
-(void)ateFunction:(int)number;
- (void) moveMethod;
-(void)calculateTheDirection:(CGPoint)location;
+(id)AIcellwithPosition:(CGPoint)location AIname:(NSString *)aiName AIcolor:(UIColor *)aiColor AIMass:(float)aiMass;


@end

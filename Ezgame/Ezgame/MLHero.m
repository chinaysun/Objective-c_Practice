//
//  MLHero.m
//  Ezgame
//
//  Created by SUN YU on 11/08/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import "MLHero.h"
#import "MLWorldGenerator.h"

@interface MLHero()
@property BOOL isJumping;
@property (strong, nonatomic) SKAction *playJumpSound;
@end

@implementation MLHero

//used to collision, set the collision tiji?
// must notice that this is 0 x 1 not 0 * 1
static const uint32_t heroCategory = 0x1 << 0;
static const uint32_t obstacleCategory = 0x1 << 1;
static const uint32_t groundCategory = 0x1 << 2;

+ (id)hero
{
    //构造函数内不能调用自己的方法
    MLHero *hero = [MLHero spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(20, 20)];
    
    //add two eyes
    // the posi
    SKSpriteNode *leftEye =[SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(3, 3)];
    leftEye.name = @"leftEye";
    leftEye.position = CGPointMake(-1, 5);
    [hero addChild:leftEye];

    
    SKSpriteNode *rightEye =[SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(3, 3)];
    // why set x == 10 will be out of the hero? 10+3 < 20? where is the centre?
    rightEye.position = CGPointMake(6, 5);
    [hero addChild:rightEye];
// set the name of hero, which is used to call in the touch function,easily
    hero.name = @"hero";
// can not understand, why did this, then the hero falling down? it down due to the gravity?
    hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hero.size];
    
    //COLLSION SET, ORIGINIAL AND CONTACT ITEM
    hero.physicsBody.categoryBitMask = heroCategory;
    // ignore contact with groundCategory
    hero.physicsBody.contactTestBitMask = obstacleCategory | groundCategory;
    
    return hero;
}

//- (void)walkRight
//{
//    SKAction  *incrementRight = [SKAction moveByX:10 y:0 duration:0];
//    [self runAction:incrementRight];
//}

- (void)jump
{
    // a method used to run physica body
    if (!self.isJumping) {
        [self.physicsBody applyImpulse:CGVectorMake(0, 8)];
        //wait for Conmpletion makes the sounds sequences
      [self runAction:[SKAction playSoundFileNamed:@"onjump.wav" waitForCompletion:NO]];
        
//        self.playJumpSound = [SKAction playSoundFileNamed:@"onjump.wav" waitForCompletion:NO];
        self.isJumping = YES;
    

    }
//    [self.physicsBody applyImpulse:CGVectorMake(0, 8)];
//    [self enumerateChildNodesWithName:@"her" usingBlock:^(SKNode *node, BOOL *stop) {
//        if ([node.name  isEqual: @"leftEye"]) {
//            NSLog(@"NMB");
//            SKSpriteNode *leftEye2 =[SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(3, 3)];
//            leftEye2.position = CGPointMake(-1, 5);
//            [self addChild:leftEye2];
//        }
//    }];

    
//   attemp to change the color of eye when jumping , but this is adding a new node, is any method to call the origanal one
//   directly?????
//    SKSpriteNode *leftEye =[SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(3, 3)];
//    leftEye.position = CGPointMake(-1, 5);
//    [self addChild:leftEye];
    
}

-(void)land
{
    self.isJumping = NO;
}
-(void)start
{
    //duration controls the speed of moving
    SKAction *incrementRight =  [SKAction moveByX:1.0 y:0 duration:0.005];
    //keep move right forever
    SKAction *moveRight = [SKAction repeatActionForever:incrementRight];
    [self runAction:moveRight];
}

-(void)stop
{
    [self removeAllActions];
}


@end

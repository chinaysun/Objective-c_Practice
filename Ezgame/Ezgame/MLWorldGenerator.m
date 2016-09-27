//
//  MLWorldGenerator.m
//  Ezgame
//
//  Created by SUN YU on 11/08/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import "MLWorldGenerator.h"

//set up some feartures about the world
@interface MLWorldGenerator ()
@property double currentGroudX;
@property double currentObastacleX;
@property SKNode *world;
@end

@implementation MLWorldGenerator

static const uint32_t obstacleCategory = 0x1 << 1;
static const uint32_t groundCategory = 0x1 << 2;


//get a node to generate the world
+(id)generatorWithWorld:(SKNode *)world
{
    MLWorldGenerator *generator = [MLWorldGenerator node];
    generator.currentGroudX = 0;
    generator.currentObastacleX = 400;
    generator.world = world;
    return generator;
}

-(void)populate
{
    for (int i=0; i<3; i++) {
        [self generate];
    }
}

-(void)generate
{
    //self.scene.frame is used to call the frame width
//    SKSpriteNode *ground = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(self.scene.frame.size.width, 100)];
    SKSpriteNode *ground = [SKSpriteNode spriteNodeWithImageNamed:@"ground"];
    ground.name = @"ground";
    ground.position = CGPointMake(self.currentGroudX, -self.scene.frame.size.height/2 + ground.frame.size.height/2);
    //ground.position = CGPointMake(self.currentGroudX, -200);
    ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground.size];
    ground.physicsBody.categoryBitMask = groundCategory;
    ground.physicsBody.dynamic = NO;
    [self.world addChild:ground];
    
    // equals to move the ground
    self.currentGroudX += ground.frame.size.width;
    
    SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithColor:[self getRandomColor] size:CGSizeMake(30, 41)];
    obstacle.name = @"obstacle";
    obstacle.position = CGPointMake(self.currentObastacleX, ground.position.y + ground.frame.size.height/2 +obstacle.frame.size.height/2);
    obstacle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:obstacle.size];
    obstacle.physicsBody.categoryBitMask = obstacleCategory;
    obstacle.physicsBody.dynamic = NO;
    [self.world addChild:obstacle];
    
    //equals to move the obastacle 
    self.currentObastacleX += 250;
    
    
}

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
            color = [UIColor blackColor];
            break;
        default:
            break;
    }
    return color;
}

@end

//
//  MLWorldGenerator.h
//  Ezgame
//
//  Created by SUN YU on 11/08/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MLWorldGenerator : SKNode
+(id)generatorWithWorld:(SKNode *) world;
-(void)populate;
-(void)generate;

@end

//
//  MLHero.h
//  Ezgame
//
//  Created by SUN YU on 11/08/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MLHero : SKSpriteNode

+(id)hero; //add here, other method could call it
//-(void)walkRight;
-(void)jump;
-(void)start;
-(void)stop;
-(void)land;
@end

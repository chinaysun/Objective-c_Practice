//
//  MLPointsLabel.h
//  Ezgame
//
//  Created by SUN YU on 12/08/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MLPointsLabel : SKLabelNode
@property int number;

+(id)pointsLableWithFontNamed:(NSString *)fontName;
-(void)increment;
-(void)setPoints:(int)points;
-(void)reset;
@end

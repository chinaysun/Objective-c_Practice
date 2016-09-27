//
//  MLPointsLabel.m
//  Ezgame
//
//  Created by SUN YU on 12/08/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import "MLPointsLabel.h"

//this is used to add lable to the screen
@implementation MLPointsLabel

+(id)pointsLableWithFontNamed:(NSString *)fontName
{
    MLPointsLabel *pointsLabel = [MLPointsLabel labelNodeWithFontNamed:fontName];
    pointsLabel.text = @"0";
    pointsLabel.number = 0 ;
    return pointsLabel;
}

-(void)increment
{
  
    self.number ++;
    self.text = [NSString stringWithFormat:@"%i", self.number];
}

-(void)setPoints:(int)points
{
    //used to record the high points
    self.text = [NSString stringWithFormat:@"%i",points];
    self.number = points;
}

-(void)reset
{
    self.number = 0;
    self.text = @"0";
}

@end

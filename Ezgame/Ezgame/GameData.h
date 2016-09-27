//
//  GameData.h
//  Ezgame
//
//  Created by SUN YU on 13/08/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject
@property int highscore;
+(id)data;
-(void)save;
-(void)load;
@end

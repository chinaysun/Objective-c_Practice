//
//  GameData.m
//  Ezgame
//
//  Created by SUN YU on 13/08/2015.
//  Copyright (c) 2015 SUN YU. All rights reserved.
//

#import "GameData.h"

@interface GameData ()
@property NSString *filePath;

@end

@implementation GameData

+(id)data
{
    GameData *data = [GameData new];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = @"archive.data";
    data.filePath = [path stringByAppendingString:fileName];
    return data;
}

-(void)save
{
    NSNumber *highscoreObject = [NSNumber numberWithInteger:self.highscore];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:highscoreObject];
    [data writeToFile:self.filePath atomically:YES];
    
}

-(void)load
{
    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
    NSNumber *highscoreObject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    self.highscore = highscoreObject.intValue;
}
@end

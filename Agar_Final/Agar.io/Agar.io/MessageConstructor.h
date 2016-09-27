/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/


#import <Foundation/Foundation.h>

@interface MessageConstructor : NSObject

-(NSMutableDictionary *)playerInfoDicAlias:(NSString *)playerName Position:(NSArray *)playerPosition;
-(NSMutableDictionary *)eatenFoodListDicPosition:(NSArray *)positionArray;
-(NSMutableDictionary *)leaderBoardRecordDicPlayerName:(NSString *)customerName LiveTime:(int)liveTime FoodCount:(int)foodCount AIAttacked:(int)attackedNum Goal:(int)goal;
-(NSString *)JSONStringConstructFromDictionary:(NSDictionary *)dic;
-(NSDictionary *)DictoryConstructFromJSONString:(NSString *)jsonString;
-(NSMutableDictionary *) DicConstructFromArray:(NSMutableArray *)array WithKey:(NSString *)key;

@end

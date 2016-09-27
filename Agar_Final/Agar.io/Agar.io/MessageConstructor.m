/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/
/********************************************************************
 FileName: MessageContructor.m
 Date: 13 Oct 2015
 Description: this is the helper class used to wraper the message with different format.
 Functions: 1. create a dictionay according to the input parameters
 2. create a dictionary according to the input array
 3. construct a dictionary for the leader board display
 4. convert dictionary to JSON string
 5. convert JSON string to dictionay
 6. convert array to dictionay
 *******************************************************************/

#import "MessageConstructor.h"

@implementation MessageConstructor


//construct the player information dictionary
-(NSMutableDictionary *)playerInfoDicAlias:(NSString *)playerName Position:(NSArray *)playerPosition
{
    NSMutableDictionary *playerInfoDic = [NSMutableDictionary
                                          dictionaryWithDictionary:@{
                                            @"PlayerName": playerName,
                                            @"Position": playerPosition
                                          }];
    return playerInfoDic;
}

//construct the eaten food list dictionary
-(NSMutableDictionary *)eatenFoodListDicPosition:(NSArray *)positionArray
{
    NSMutableDictionary *eatenFoodListDic = [NSMutableDictionary
                                          dictionaryWithDictionary:@{
                                                                     @"Position": positionArray
                                                                     }];
    return eatenFoodListDic;
}

//construct the game results dictionary
-(NSMutableDictionary *)leaderBoardRecordDicPlayerName:(NSString *)playerName LiveTime:(int)liveTime FoodCount:(int)foodCount AIAttacked:(int)attacked Goal:(int)goal
{
    NSMutableDictionary *leaderBoardRecordDic = [NSMutableDictionary
                                          dictionaryWithDictionary:@{
                                                                     @"PlayerName": playerName,
                                                                     @"LiveTime": [NSNumber numberWithInt:liveTime],
                                                                     @"FoodCount": [NSNumber numberWithInt:foodCount],
                                                                     @"AIAttacked": [NSNumber numberWithInt:attacked],
                                                                     @"Goal": [NSNumber numberWithInt:goal]
                                                                     }];
//    NSLog(@"leader board recorde is %@", leaderBoardRecordDic);
    return leaderBoardRecordDic;

    
}

//convert dictionary to json string
-(NSString *)JSONStringConstructFromDictionary:(NSDictionary *)dic
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
//    NSLog(@"dic to jsonstring %@", jsonString);
    return jsonString;
}

//convert json string to dictionary
-(NSDictionary *)DictoryConstructFromJSONString:(NSString *)jsonString
{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error;
    NSDictionary * jsonDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
//    NSLog(@"jsonstring to dic %@",jsonDic);
    
    return jsonDic;
}

//construct dictionary from an array
-(NSMutableDictionary *) DicConstructFromArray:(NSMutableArray *)array WithKey:(NSString *)key {

    NSMutableDictionary *dic = [NSMutableDictionary
                                dictionaryWithDictionary:@{
                                                           key: array
                                                           }];
    NSLog(@"array to dic %@", dic);
    
    return dic;
}


@end

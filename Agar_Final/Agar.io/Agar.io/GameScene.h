/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>
#import "StartMenu.h"

@interface GameScene : SKScene <SKPhysicsContactDelegate, NSStreamDelegate>{
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    NSMutableData *_outputBuffer;
    NSMutableData *_inputBuffer;
    BOOL _okToWrite;
}
/*property to store exchange message*/
@property NSString *playerName;
@property NSString *enemyName;
@property NSString *myColorString;
@property NSString *enemyColorString;

@property NSString *gameType;

/*network fearture*/
@property NSInputStream *inputStream;
@property NSOutputStream *outputStream;
@property NSMutableData *outputBuffer;
@property NSMutableData *inputBuffer;
@property BOOL okToWrite;

/*features to create leaderboard*/
@property StartMenu *startMenu;


@property NSMutableDictionary *goalOfThisTurn;
@property NSMutableArray *goalsSoFar;


@property NSString *enemyMass;


@end

/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

@interface MessageWriter : NSObject {
    NSMutableData * _data;
}

@property (retain, readonly) NSMutableData * data;

- (void)writeByte:(unsigned char)value;
- (void)writeInt:(int)value;
- (void)writeString:(NSString *)value;

@end

/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/


#import <Foundation/Foundation.h>

@interface MessageReader : NSObject {
    NSData * _data;
    int _offset;
}

- (id)initWithData:(NSData *)data;
- (unsigned char)readByte;
- (int)readInt;
- (NSString *)readString;

@end

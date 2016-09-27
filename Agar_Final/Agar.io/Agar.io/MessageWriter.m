/********************************************************************
 Team-Info:
 Full Name: Meng LI      || Login: mengl1      || Student ID: 616805
 Full Name: Weijia CHEN  || Login: weijiac1    || Student ID: 616213
 Full Name: Yu SUN       || Login: sun1        || Student ID: 629341
 Full Name: Yuxiang ZHOU || Login: yuxiangz2   || Student ID: 705077
 *********************************************************************/
/********************************************************************
 FileName: MessageWriter.m
 Date: 13 Oct 2015
 Description: this is the helper class usded for writing message to the output data.
 Functions: 1. initiate the messagewriter class with the data
 2. write several bytes one time into the output data
 3. write a byte into the output data
 4. write an int into the output data
 5. write a string into the output data
 
 *******************************************************************/

#import "MessageWriter.h"

@implementation MessageWriter
@synthesize data = _data;

- (id)init {
    if ((self = [super init])) {
        _data = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)writeBytes:(void *)bytes length:(int)length {
    [_data appendBytes:bytes length:length];
}

- (void)writeByte:(unsigned char)value {
    [self writeBytes:&value length:sizeof(value)];
}

- (void)writeInt:(int)intValue {
    int value = htonl(intValue);
    [self writeBytes:&value length:sizeof(value)];
}

- (void)writeString:(NSString *)value {
    const char * utf8Value = [value UTF8String];
    int length = (int)strlen(utf8Value) + 1; // for null terminator
    [self writeInt:length];
    [self writeBytes:(void *)utf8Value length:length];
}

//- (void)dealloc {
//    [_data release];
//    [super dealloc];
//}

@end

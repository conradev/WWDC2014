//
//  NSData+FILE.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/9/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "NSData+FILE.h"

@interface CKDataStreamContext : NSObject

@property (readonly, strong, nonatomic) NSUUID *uuid;
@property (readonly, strong, nonatomic) NSData *data;
@property (nonatomic) fpos_t pos;

@end

@implementation CKDataStreamContext

+ (instancetype)contextWithData:(NSData *)data {
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data {
    NSParameterAssert(data);
    self = [super init];
    if (self) {
        _uuid = [NSUUID UUID];
        _data = data;
    }
    return self;
}

@end

static NSMutableDictionary *contexts = nil;

static int readfn(void *cookie, char *ptr, int size) {
    CKDataStreamContext *context = (__bridge CKDataStreamContext *)cookie;
    int available = (int)context.data.length - (int)context.pos;
    if (size > available) size = available;
    [context.data getBytes:ptr range:NSMakeRange((NSUInteger)context.pos, size)];
    context.pos += size;
    return size;
}

static int writefn(void *cookie, const char *ptr, int size) {
    CKDataStreamContext *context = (__bridge CKDataStreamContext *)cookie;
    NSMutableData *data = [context.data isKindOfClass:[NSMutableData class]] ? (NSMutableData *)context.data : nil;
    if (data == nil) return -1;
    int available = (int)data.length - (int)context.pos;
    if (size > available) [data increaseLengthBy:(size - available)];
    [data replaceBytesInRange:NSMakeRange((NSUInteger)context.pos, size) withBytes:ptr];
    context.pos += size;
    return size;
}

static fpos_t seekfn(void *cookie, fpos_t offset, int whence) {
    CKDataStreamContext *context = (__bridge CKDataStreamContext *)cookie;
    switch (whence) {
        case SEEK_SET: context.pos = offset; break;
        case SEEK_CUR: context.pos += offset; break;
        case SEEK_END: context.pos = (fpos_t)context.data.length + offset; break;
        default: return -1;
    }
    return context.pos;
}

static int closefn(void *cookie) {
    CKDataStreamContext *context = (__bridge CKDataStreamContext *)cookie;
    [contexts removeObjectForKey:context.uuid];
    return 0;
}

FILE * CKOpenData(NSData *data) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ contexts = [[NSMutableDictionary alloc] init]; });
    NSCParameterAssert(data);
    CKDataStreamContext *context = [CKDataStreamContext contextWithData:data];
    [contexts setObject:context forKey:context.uuid];
    return funopen((__bridge void *)context, readfn, [data isKindOfClass:[NSMutableData class]] ? writefn : NULL, seekfn, closefn);
}

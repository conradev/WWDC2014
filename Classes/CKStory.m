//
//  CKStory.m
//  ConradWWDC
//
//  Created by Conrad Kramer on 4/3/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import "CKStory.h"

@interface CKStory ()
@property (strong, nonatomic) NSNumber *colorValue;
@property (strong, nonatomic) NSNumber *textColorValue;
@end

@interface CKStory (CoreData)
- (void)addNeighborsObject:(CKStory *)story;
- (void)removeNeighborsObject:(CKStory *)story;
@end

static NSNumber *CKValueFromColor(UIColor *color) {
    if (color) {
        CGFloat rf, gf, bf, af;
        NSCAssert([color getRed:&rf green:&gf blue:&bf alpha:&af], @"Color must be in RGB color space");
        UInt8 r, g, b, a;
        r = UCHAR_MAX * rf;
        g = UCHAR_MAX * gf;
        b = UCHAR_MAX * bf;
        a = UCHAR_MAX * af;
        return @((r << 24) + (g << 16) + (b << 8) + a);
    }

    return nil;
}

static UIColor *CKColorFromValue(NSNumber *colorValue) {
    if (colorValue) {
        UInt32 value = [colorValue unsignedIntValue];
        CGFloat rf = ((CGFloat)((value & 0xFF000000) >> 24)) / UCHAR_MAX;
        CGFloat gf = ((CGFloat)((value & 0xFF0000) >> 16)) / UCHAR_MAX;
        CGFloat bf = ((CGFloat)((value & 0xFF00) >> 8)) / UCHAR_MAX;
        CGFloat af = ((CGFloat)(value & 0xFF)) / UCHAR_MAX;
        return [UIColor colorWithRed:rf green:gf blue:bf alpha:af];
    }

    return nil;
}

@implementation CKStory

@dynamic name;
@dynamic storyPath;
@dynamic colorValue;
@dynamic textColorValue;
@dynamic imagePath;
@dynamic neighbors;

+ (NSString *)entityName{
    return @"Story";
}

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext*)context {
    NSParameterAssert(context);
	return [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:context];
}

- (void)setColor:(UIColor *)color {
    self.colorValue = CKValueFromColor(color);
}

- (UIColor *)color {
    return CKColorFromValue(self.colorValue);
}

- (void)setTextColor:(UIColor *)textColor {
    self.textColorValue = CKValueFromColor(textColor);
}

- (UIColor *)textColor {
    return CKColorFromValue(self.textColorValue);
}

- (void)linkToNeighbor:(CKStory *)story {
    [self addNeighborsObject:story];
}

- (void)unlinkFromNeighbor:(CKStory *)story {
    [self removeNeighborsObject:story];
}

@end

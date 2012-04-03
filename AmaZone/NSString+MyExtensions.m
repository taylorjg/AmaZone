//
//  NSString+MyExtensions.m
//  AmaZone
//
//  Created by Jonathan Taylor on 02/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+MyExtensions.h"

@implementation NSString (ForURL)

- (NSString*)reallyEncodeURL
{
    return (NSString*)CFURLCreateStringByAddingPercentEscapes(
                                                              NULL,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8);
}

@end

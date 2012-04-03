//
//  AWSHelper.h
//  AmaZone
//
//  Created by Jonathan Taylor on 03/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWSHelper : NSObject
+ (NSURLRequest *)generateAmazonRequest:(NSMutableDictionary *)dict;
@end

//
//  NSData+MyExtensions.h
//  AmaZone
//
//  Created by Jonathan Taylor on 02/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Base64)
- (NSString *)encodeBase64;
- (NSString *)encodeBase64WithNewlines: (BOOL) encodeWithNewlines;
@end

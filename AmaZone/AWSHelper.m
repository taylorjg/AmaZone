//
//  AWSHelper.m
//  AmaZone
//
//  Created by Jonathan Taylor on 03/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AWSHelper.h"
#import "AWSKeys.h"
#import "NSString+MyExtensions.h"
#import "NSData+MyExtensions.h"

#import <CommonCrypto/CommonHMAC.h> //for kCCHmacAlgSHA256
#import <CommonCrypto/CommonDigest.h> //for CC_SHA256_DIGEST_LENGTH

@implementation AWSHelper

+ (NSURLRequest *)generateAmazonRequest:(NSMutableDictionary *)dict
{
    // Complete the dictionary.
    
    if ([dict objectForKey:@"AWSAccessKeyId"] == nil) {
        [dict setObject:AWS_ACCESS_KEY_ID forKey:@"AWSAccessKeyId"];
    }
    
    //if ([dict objectForKey:@"Responsegroup"] == nil) {
    //    [dict setObject:@"Medium" forKey:@"Responsegroup"];
    //}
    
    if ([dict objectForKey:@"Service"] == nil) {
        [dict setObject:@"AWSECommerceService" forKey:@"Service"];
    }
    
    if ([dict objectForKey:@"Version"] == nil) {
        [dict setObject:@"2009-10-01" forKey:@"Version"];
    }
    
    if ([dict objectForKey:@"AssociateTag"] == nil) {
        [dict setObject:@"JGT" forKey:@"AssociateTag"];
    }
    
    // Make timestamp
    NSTimeZone *gmtZone = [NSTimeZone timeZoneWithName:@"GMT"];
    NSString *dateString = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ" timeZone:gmtZone locale:nil];
    [dict setObject:dateString forKey:@"Timestamp"];
    
    // Sort keys by name and make the URL-string
    NSArray *myKeys = [dict allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(compare:)];
    
    NSString *value;
    NSString *urlString;
    NSString *stringToSign;
    urlString = @"";
    
    for (NSString *key in sortedKeys) {
        value = [self escapeUrl:[dict objectForKey:key]];
        urlString = [NSString stringWithFormat:@"%@%@=%@&", urlString, key, value];
    }
    
    // Strip off unnecessary trailing &
    NSRange range = NSMakeRange(0, [urlString length] - 1);
    urlString = [urlString substringWithRange:range];
    
    // Get signature and add it to the url
    stringToSign = [NSString stringWithFormat:@"GET\necs.amazonaws.com\n/onca/xml\n%@", urlString];
    NSString *signedString;
    signedString = [AWSHelper generateHMACSign:stringToSign];
    signedString = [AWSHelper escapeUrl:signedString];
    signedString = [NSString stringWithFormat:@"&Signature=%@", signedString];
    
    urlString = [urlString stringByAppendingString:signedString];
    urlString = [@"http://ecs.amazonaws.com/onca/xml?" stringByAppendingString:urlString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad 
                                            timeoutInterval:30];
    return urlRequest;
}

+ (NSString *)generateHMACSign:(NSString *)stringToSign
{
    // Declare and init secret
    const char *secret;
    secret = (const char *)[AWS_SECRET_KEY cStringUsingEncoding:NSASCIIStringEncoding];
    long secretLen;
    secretLen = strlen(secret);
    
    // Get input as NSData
    NSData *input;
    input = [stringToSign dataUsingEncoding:NSASCIIStringEncoding];
    
    // Common Crypto operations (get HMAC-SHA256 signature)
    CCHmacContext hctx;
    CCHmacInit(&hctx, kCCHmacAlgSHA256, secret, secretLen);
    CCHmacUpdate(&hctx, [input bytes], [input length]);
    
    // Declare output buffer
    unsigned char output[CC_SHA256_DIGEST_LENGTH];
    
    CCHmacFinal(&hctx, output);
    
    // Convert to base64
    NSString *baseString;
    NSData *convert = [NSData dataWithBytes:output length:CC_SHA256_DIGEST_LENGTH];
    baseString = [convert encodeBase64WithNewlines:NO];
    
    return baseString;
}

+ (NSString *)escapeUrl:(NSString *)input
{
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)input,
                                                               NULL,
                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                               kCFStringEncodingUTF8);
}

@end

//
//  AppController.m
//  AmaZone
//
//  Created by Jonathan Taylor on 23/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "AWSKeys.h"
#import "AWSHelper.h"

@implementation AppController

- (IBAction)fetchBooks:(id)sender
{
    [progress startAnimation:nil];
    
    // We need to do more stuff than in the book. See the following links.
    // http://forums.bignerdranch.com/viewtopic.php?f=34&t=115&p=220&hilit=amazone#p220
    // http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/ItemSearch.html
    // http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/CHAP_MakingRequestsandUnderstandingResponses.html
    // http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/HMACSignatures.html
    // http://www.thinketg.com/Company/Blogs/11-03-20/Xcode_4_Tips_Adding_frameworks_to_your_project.aspx
    
    // Add variable keywords to the dictionary.
    NSMutableDictionary *reqData = [NSMutableDictionary dictionary];
    
    [reqData setObject:[searchField stringValue] forKey:@"Keywords"];
    [reqData setObject:@"ItemSearch" forKey:@"Operation"];
    [reqData setObject:@"Books" forKey:@"SearchIndex"];
    
    NSURLRequest *urlRequest = [AWSHelper generateAmazonRequest:reqData];    
    
    NSData* urlData;
    NSURLResponse* response;
    NSError* error;
    
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (!urlData) {
        NSAlert* alert = [NSAlert alertWithError:error];
        [alert runModal];
        return;
    }
    
    [doc release];
    doc = [[NSXMLDocument alloc] initWithData:urlData options:0 error:&error];
    
    NSLog(@"doc = %@", doc);
    
    if (!doc) {
        NSAlert* alert = [NSAlert alertWithError:error];
        [alert runModal];
        return;
    }
    
    [itemNodes release];
    itemNodes = [[doc nodesForXPath:@"ItemSearchResponse/Items/Item" error:&error] retain];
    
    if (!itemNodes) {
        NSAlert* alert = [NSAlert alertWithError:error];
        [alert runModal];
        return;
    }
    
    NSLog(@"Number of items returned: %ld", [itemNodes count]);
    
    [tableView reloadData];
    [progress stopAnimation:nil];
}

- (int)numberOfRowsInTableView:(NSTableView*)tv
{
    return [itemNodes count];
}

- (id)tableView:(NSTableView*)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSXMLNode* node = [itemNodes objectAtIndex:row];
    NSString* xpath = [tableColumn identifier];
    return [self stringForPath:xpath ofNode:node];
}

- (NSString*)stringForPath:(NSString*)xpath ofNode:(NSXMLNode*)node {
    
    NSError* error;
    NSArray* nodes = [node nodesForXPath:xpath error:&error];
    
    if (!nodes) {
        NSAlert* alert = [NSAlert alertWithError:error];
        [alert runModal];
        return nil;
    }
    
    if ([nodes count] == 0) {
        return nil;
    }

    return [[nodes objectAtIndex:0] stringValue];
}

- (void)awakeFromNib {
    [tableView setDoubleAction:@selector(openItem:)];
    [tableView setTarget:self];
}

- (void)openItem:(id)sender {
    NSLog(@"openItem:");
}

@end

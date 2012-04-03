//
//  AppController.h
//  AmaZone
//
//  Created by Jonathan Taylor on 23/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
    IBOutlet NSProgressIndicator* progress;
    IBOutlet NSTextField* searchField;
    IBOutlet NSTableView* tableView;
    
    NSXMLDocument* doc;
    NSArray* itemNodes;
}

- (IBAction)fetchBooks:(id)sender;

@end

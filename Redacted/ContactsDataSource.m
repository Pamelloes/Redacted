//
//  ContactsDataSource.m
//  Redacted
//
//  Created by Joshua Brot on 12/6/13.
//
//

#import "ContactsDataSource.h"

#import "Contact.h"
#import "User.h"
#import "DDLog.h"

@interface ContactsDataSource () {
	NSMutableArray *data;
}

@end

@implementation ContactsDataSource

- (instancetype) initObject {
	if ((self = [super init])) {
		NSArray *alphabet = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
		data = [[NSMutableArray alloc] initWithCapacity:[alphabet count]];
		for (NSString *str in alphabet) {
			NSMutableDictionary *content = [[NSMutableDictionary alloc] initWithCapacity:2];
			[content setObject:str forKey:@"title"];
			NSMutableArray *row = [NSMutableArray arrayWithCapacity:1];
			[content setObject:row forKey:@"content"];
			[data addObject:content];
		}
		[self reloadData];
	}
	return self;
}

- (void) reloadData {
	NSError *error;
	NSArray *contacts = [Contact fetchAllWithError:&error];
	if (error) {
		DDLogError(@"Could not retrieve users: %@", error);
		return;
	}
	for (NSDictionary *dict in data) [[dict objectForKey:@"content"] removeAllObjects];
	NSComparator comparator = ^(id obj1, id obj2) {
		return [obj1 caseInsensitiveCompare:obj2];
	};
	
	for (Contact *c in contacts) {
		User *u = c.users.anyObject;
		NSString *name = [c.last length] > 0 ? c.last : ([c.first length] > 0 ? c.first : u.name);
		int index = [[name lowercaseString] characterAtIndex:0] - 97;
		if (index < 0 || index > 26) index = 26;
		NSMutableArray *content = [[data objectAtIndex:index] objectForKey:@"content"];
		NSUInteger pos = [content indexOfObject:name inSortedRange: NSMakeRange(0, [content count]) options:NSBinarySearchingInsertionIndex usingComparator:comparator];
		[content insertObject:c atIndex:pos];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Contact" forIndexPath:indexPath];
	Contact *c = [[[data objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
	cell.detailTextLabel.text = c.primary ? @"me" : @"";
	cell.textLabel.attributedText = [c attributedNameWithSize:cell.textLabel.font.pointSize];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[data objectAtIndex:section] valueForKey:@"content"] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [data count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return [data valueForKey:@"title"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[[data objectAtIndex:section] valueForKey:@"content"] count] ? [[data objectAtIndex:section] valueForKey:@"title"] : nil;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Contact *c = [[[data objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
		[c delete];
		NSError *e = [Contact commit];
		if (e) DDLogError(@"Unable to save contact deletion: %@", e);
		[[[data objectAtIndex:indexPath.section] objectForKey:@"content"] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	Contact *c = [[[data objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
	if (c.primary) return UITableViewCellEditingStyleNone;
	else return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	Contact *c = [[[data objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
	return !c.primary;
}

@end

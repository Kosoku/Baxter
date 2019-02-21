// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Row.m instead.

#import "_Row.h"

@implementation RowID
@end

@implementation _Row

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Row";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Row" inManagedObjectContext:moc_];
}

- (RowID*)objectID {
	return (RowID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic createdAt;

@dynamic identifier;

@dynamic summary;

@dynamic title;

@end

@implementation RowAttributes 
+ (NSString *)createdAt {
	return @"createdAt";
}
+ (NSString *)identifier {
	return @"identifier";
}
+ (NSString *)summary {
	return @"summary";
}
+ (NSString *)title {
	return @"title";
}
@end


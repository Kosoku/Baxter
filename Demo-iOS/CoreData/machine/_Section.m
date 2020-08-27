// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Section.m instead.

#import "_Section.h"

@implementation SectionID
@end

@implementation _Section

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Section";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Section" inManagedObjectContext:moc_];
}

- (SectionID*)objectID {
	return (SectionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic name;

@dynamic rows;

- (NSMutableSet<Row*>*)rowsSet {
	[self willAccessValueForKey:@"rows"];

	NSMutableSet<Row*> *result = (NSMutableSet<Row*>*)[self mutableSetValueForKey:@"rows"];

	[self didAccessValueForKey:@"rows"];
	return result;
}

@end

@implementation SectionAttributes 
+ (NSString *)name {
	return @"name";
}
@end

@implementation SectionRelationships 
+ (NSString *)rows {
	return @"rows";
}
@end


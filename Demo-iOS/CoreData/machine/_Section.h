// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Section.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class Row;

@interface SectionID : NSManagedObjectID {}
@end

@interface _Section : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) SectionID *objectID;

@property (nonatomic, strong, nullable) NSString* name;

@property (nonatomic, strong, nullable) NSSet<Row*> *rows;
- (nullable NSMutableSet<Row*>*)rowsSet;

@end

@interface _Section (RowsCoreDataGeneratedAccessors)
- (void)addRows:(NSSet<Row*>*)value_;
- (void)removeRows:(NSSet<Row*>*)value_;
- (void)addRowsObject:(Row*)value_;
- (void)removeRowsObject:(Row*)value_;

@end

@interface _Section (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveName;
- (void)setPrimitiveName:(nullable NSString*)value;

- (NSMutableSet<Row*>*)primitiveRows;
- (void)setPrimitiveRows:(NSMutableSet<Row*>*)value;

@end

@interface SectionAttributes: NSObject 
+ (NSString *)name;
@end

@interface SectionRelationships: NSObject
+ (NSString *)rows;
@end

NS_ASSUME_NONNULL_END

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Row.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class Section;

@interface RowID : NSManagedObjectID {}
@end

@interface _Row : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) RowID *objectID;

@property (nonatomic, strong, nullable) NSDate* createdAt;

@property (nonatomic, strong, nullable) NSString* identifier;

@property (nonatomic, strong, nullable) NSString* summary;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) Section *section;

@end

@interface _Row (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(nullable NSDate*)value;

- (nullable NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(nullable NSString*)value;

- (nullable NSString*)primitiveSummary;
- (void)setPrimitiveSummary:(nullable NSString*)value;

- (nullable NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(nullable NSString*)value;

- (nullable Section*)primitiveSection;
- (void)setPrimitiveSection:(nullable Section*)value;

@end

@interface RowAttributes: NSObject 
+ (NSString *)createdAt;
+ (NSString *)identifier;
+ (NSString *)summary;
+ (NSString *)title;
@end

@interface RowRelationships: NSObject
+ (NSString *)section;
@end

NS_ASSUME_NONNULL_END

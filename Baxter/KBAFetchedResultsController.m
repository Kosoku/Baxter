//
//  KBAFetchedResultsController.m
//  Baxter
//
//  Created by William Towe on 8/27/20.
//  Copyright © 2021 Kosoku Interactive, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "KBAFetchedResultsController.h"
#import <Stanley/Stanley.h>

@interface KBARelationshipKeyPath ()
@property (readwrite,copy,nonatomic) NSString *destinationEntityName;
@property (readwrite,copy,nonatomic) NSSet<NSString *> *destinationPropertyNames;
@property (readwrite,copy,nonatomic) NSString *inverseRelationshipKeyPath;
@end

@interface NSManagedObject (KBAFetchedResultsControllerExtensions)
- (KBARelationshipKeyPath *)changedRelationshipKeyPathFrom:(NSSet<KBARelationshipKeyPath *> *)relationshipKeyPaths;
@end

@interface NSSet (KBAFetchedResultsControllerExtensions)
- (NSSet<NSManagedObjectID *> *)updatedObjectIDsFor:(NSSet<KBARelationshipKeyPath *> *)relationshipKeyPaths;
@end

@implementation NSSet (KBAFetchedResultsControllerExtensions)

- (NSSet<NSManagedObjectID *> *)updatedObjectIDsFor:(NSSet<KBARelationshipKeyPath *> *)relationshipKeyPaths {
    NSMutableSet<NSManagedObjectID *> *retval = [[NSMutableSet alloc] init];
    
    for (NSManagedObject *object in self) {
        KBARelationshipKeyPath *keyPath = [object changedRelationshipKeyPathFrom:relationshipKeyPaths];
        
        if (keyPath == nil) {
            continue;
        }
        
        id value = [object valueForKeyPath:keyPath.inverseRelationshipKeyPath];
        
        if ([value isKindOfClass:NSSet.class]) {
            [retval unionSet:[value valueForKeyPath:@"objectID"]];
        }
        else if ([value isKindOfClass:NSManagedObject.class]) {
            [retval addObject:[value objectID]];
        }
        else {
            KSTLog(@"Invalid relationship observed for %@", keyPath);
        }
    }
    
    return retval;
}

@end

@implementation NSManagedObject (KBAFetchedResultsControllerExtensions)

- (KBARelationshipKeyPath *)changedRelationshipKeyPathFrom:(NSSet<KBARelationshipKeyPath *> *)relationshipKeyPaths {
    for (KBARelationshipKeyPath *keyPath in relationshipKeyPaths) {
        if (![keyPath.destinationEntityName isEqualToString:self.entity.name] &&
            ![keyPath.destinationEntityName isEqualToString:self.entity.superentity.name]) {
            
            continue;
        }
        
        NSSet<NSString *> *keys = [NSSet setWithArray:self.changedValues.allKeys];
        
        if (![keys intersectsSet:keyPath.destinationPropertyNames]) {
            continue;
        }
        
        return keyPath;
    }
    
    return nil;
}

@end

@implementation KBARelationshipKeyPath

- (instancetype)initWithDestinationEntityName:(NSString *)destinationEntityName destinationPropertyNames:(NSSet<NSString *> *)destinationPropertyNames inverseRelationshipKeyPath:(NSString *)inverseRelationshipKeyPath {
    if (!(self = [super init]))
        return nil;
    
    self.destinationEntityName = destinationEntityName;
    self.destinationPropertyNames = destinationPropertyNames;
    self.inverseRelationshipKeyPath = inverseRelationshipKeyPath;
    
    return self;
}

@end

@interface KBARelationshipKeyPathsObserver : NSObject
@property (weak,nonatomic) KBAFetchedResultsController *fetchedResultsController;
@property (copy,nonatomic) NSSet<KBARelationshipKeyPath *> *relationshipKeyPaths;

@property (strong,nonatomic) NSMutableSet<NSManagedObjectID *> *updatedObjectIDs;

- (instancetype)initWithRelationshipKeyPaths:(NSSet<KBARelationshipKeyPath *> *)relationshipKeyPaths fetchedResultsController:(KBAFetchedResultsController *)fetchedResultsController NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
@end

@implementation KBARelationshipKeyPathsObserver

- (void)_contextDidChangeNotification:(NSNotification *)note {
    NSSet<NSManagedObject *> *updatedObjects = note.userInfo[NSUpdatedObjectsKey];
    
    if (KSTIsEmptyObject(updatedObjects)) {
        return;
    }
    
    NSSet<NSManagedObjectID *> *updatedObjectIDs = [updatedObjects updatedObjectIDsFor:self.relationshipKeyPaths];
    
    KSTDispatchMainAsync(^{
        [self.updatedObjectIDs unionSet:updatedObjectIDs];
    });
}
- (void)_contextDidSaveNotification:(NSNotification *)note {
    KSTDispatchMainAsync(^{
        if (KSTIsEmptyObject(self.updatedObjectIDs)) {
            return;
        }
        
        NSArray<NSManagedObject *> *fetchedObjects = self.fetchedResultsController.fetchedObjects;
        
        for (NSManagedObject *object in fetchedObjects) {
            if (![self.updatedObjectIDs containsObject:object.objectID]) {
                continue;
            }
            
            [self.fetchedResultsController.managedObjectContext refreshObject:object mergeChanges:YES];
        }
        
        [self.updatedObjectIDs removeAllObjects];
    });
}

- (instancetype)initWithRelationshipKeyPaths:(NSSet<KBARelationshipKeyPath *> *)relationshipKeyPaths fetchedResultsController:(KBAFetchedResultsController *)fetchedResultsController {
    if (!(self = [super init]))
        return nil;
    
    self.relationshipKeyPaths = relationshipKeyPaths;
    self.fetchedResultsController = fetchedResultsController;
    self.updatedObjectIDs = [[NSMutableSet alloc] init];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_contextDidChangeNotification:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_contextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end

@interface KBAFetchedResultsController ()
@property (strong,nonatomic) KBARelationshipKeyPathsObserver *relationshipKeyPathsObserver;

@end

@implementation KBAFetchedResultsController

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name relationshipKeyPaths:(NSSet<KBARelationshipKeyPath *> *)relationshipKeyPaths {
    if (!(self = [super initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:name]))
        return nil;
    
    self.relationshipKeyPathsObserver = [[KBARelationshipKeyPathsObserver alloc] initWithRelationshipKeyPaths:relationshipKeyPaths fetchedResultsController:self];
    
    return self;
}

@end

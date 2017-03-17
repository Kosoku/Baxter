//
//  NSFetchRequest+KBAExtensions.h
//  Baxter
//
//  Created by William Towe on 3/17/17.
//  Copyright © 2017 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFetchRequest (KBAExtensions)

/**
 Create and return a NSFetchRequest with the provided parameters.
 
 @param entityName The name of the entity to fetch
 @param predicate The predicate to apply to the fetch request
 @param sortDescriptors The sort descriptors to apply to the fetch request
 @param limit The fetch limit to apply to the fetch request
 @param offset The fetch offset to apply to the fetch request
 @return The fetch request
 */
+ (NSFetchRequest *)KBA_fetchRequestForEntityName:(NSString *)entityName predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit offset:(NSUInteger)offset;

@end

NS_ASSUME_NONNULL_END

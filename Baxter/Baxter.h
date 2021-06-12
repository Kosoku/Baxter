//
//  Baxter.h
//  Baxter
//
//  Created by William Towe on 3/17/17.
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

#import <Foundation/Foundation.h>

//! Project version number for Baxter.
FOUNDATION_EXPORT double BaxterVersionNumber;

//! Project version string for Baxter.
FOUNDATION_EXPORT const unsigned char BaxterVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Baxter/PublicHeader.h>

#import <Baxter/NSFetchRequest+KBAExtensions.h>
#import <Baxter/NSManagedObjectContext+KBAExtensions.h>

#import <Baxter/NSManagedObjectContext+KBAImportExtensions.h>

#if (TARGET_OS_IOS || TARGET_OS_OSX)
#import <Baxter/KBAFetchedResultsController.h>
#endif
#if TARGET_OS_IOS
#import <Baxter/KBAFetchedResultsObserver.h>
#endif

//
//  ViewModel.swift
//  Demo-iOS
//
//  Created by William Towe on 3/13/19.
//  Copyright © 2020 Kosoku Interactive, LLC. All rights reserved.
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

import Baxter
import CoreData
import Stanley

class ViewModel: NSObject, KBAFetchedResultsObserverDelegate {
    @objc public private(set) var persistentContainer: NSPersistentContainer
    @objc public private(set) var fetchedResultsObserver: KBAFetchedResultsObserver<NSFetchRequestResult>
    
    func fetchedResultsObserver(_ observer: KBAFetchedResultsObserver<NSFetchRequestResult>, didObserve changes: [KBAFetchedResultsObserverChange]) {
        print(changes)
    }
    
    override init() {
        self.persistentContainer = NSPersistentContainer.init(name: "Model")
        
        let desc = NSPersistentStoreDescription.init(url: FileManager.default.kst_applicationSupportDirectoryURL().appendingPathComponent("Model"))
        
        desc.type = NSInMemoryStoreType
        desc.shouldAddStoreAsynchronously = false
        desc.shouldMigrateStoreAutomatically = true
        desc.shouldInferMappingModelAutomatically = true
        
        self.persistentContainer.persistentStoreDescriptions = [desc]
        self.persistentContainer.loadPersistentStores { _, _ in
            
        }
        
        self.fetchedResultsObserver = KBAFetchedResultsObserver.init(fetchRequest: Row.fetchRequestForRowsSortedByCreatedAt, context: self.persistentContainer.viewContext)
        
        super.init()
        
        self.fetchedResultsObserver.delegate = self
    }
}

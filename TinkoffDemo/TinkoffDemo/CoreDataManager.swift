//
//  CoreDataManager.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
	
	private var storeUrl: URL? {
		let directoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		let fileUrl = URL(string: "Store.sql", relativeTo: directoryUrl)
		
		return fileUrl
	}
	
	private var _managedObjectModel: NSManagedObjectModel?
	var managedObjectModel: NSManagedObjectModel? {
		if _managedObjectModel == nil {
			guard let modelUrl = Bundle.main.url(forResource: "TinkoffDemo", withExtension: "momd") else { return nil }
			_managedObjectModel = NSManagedObjectModel(contentsOf: modelUrl)
		}
		
		return _managedObjectModel
	}
	
	private var _persistanceStoreCoordinator: NSPersistentStoreCoordinator?
	var persistanceStoreCoordinator: NSPersistentStoreCoordinator? {
		if _persistanceStoreCoordinator == nil {
			guard let model = managedObjectModel else { return nil }
			_persistanceStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
			do {
				try _persistanceStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
			} catch {
				print("PersistanceStoreCoordinator fails")
			}
		}
		
		return _persistanceStoreCoordinator
	}
	
	private var _masterContext: NSManagedObjectContext?
	private var masterContext: NSManagedObjectContext? {
		if _masterContext == nil {
			guard let coordinator = persistanceStoreCoordinator else { return nil }
			let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			context.persistentStoreCoordinator = coordinator
			context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
			_masterContext = context
		}
		
		return _masterContext
	}
	
	private var _mainContext: NSManagedObjectContext?
	private var mainContext: NSManagedObjectContext? {
		if _mainContext == nil {
			guard let parentContext = _masterContext else { return nil }
			let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
			context.parent = parentContext
			context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
			_mainContext = context
		}
		
		return _mainContext
	}
	
	private var _saveContext: NSManagedObjectContext?
	var saveContext: NSManagedObjectContext? {
		if _saveContext == nil {
			guard let parentContext = mainContext else { return nil }
			let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			context.parent = parentContext
			context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
			_saveContext = context
		}
		
		return _saveContext
	}
	
	func performSave(in context: NSManagedObjectContext, completion: (() -> Void)? ) {
		if !context.hasChanges {
			completion?()
			return
		}
		
		context.perform {
			do {
				try context.save()
			} catch {
				print("Saving context failed: \(error)")
			}
			
			if let parentContext = context.parent {
				self.performSave(in: parentContext, completion: completion)
			} else {
				completion?()
			}
		}
	}
}

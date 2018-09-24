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
	
	private var _mainContext: NSManagedObjectContext?
	var mainContext: NSManagedObjectContext? {
		if _mainContext == nil {
			guard let coordinator = persistanceStoreCoordinator else { return nil }
			let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
			context.persistentStoreCoordinator = coordinator
			context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
			_mainContext = context
		}
		
		return _mainContext
	}
}

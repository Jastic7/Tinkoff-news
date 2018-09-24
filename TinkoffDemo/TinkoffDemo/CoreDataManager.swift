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
	
	static let shared = CoreDataManager(modelName: "TinkoffDemo")
	
	private let modelName: String
	private var storeUrl: URL = {
		guard let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Cannot resolve document directory url.")
		}
		
		return documentUrl.appendingPathComponent("Store.sqlite")
	}()
	
	private lazy var managedObjectModel: NSManagedObjectModel = {
		guard let modelUrl = Bundle.main.url(forResource: modelName, withExtension: "momd") else { fatalError("Error loading model from bundle.") }
		guard let model = NSManagedObjectModel(contentsOf: modelUrl) else { fatalError("Cannot initialize managed object model from url: \(modelUrl)") }
		
		return model
	}()
	
	private lazy var persistanceStoreCoordinator: NSPersistentStoreCoordinator = {
		return NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
	}()
	
	lazy var mainContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.persistentStoreCoordinator = persistanceStoreCoordinator
		context.undoManager = nil
		return context
	}()
	
	private init(modelName: String) {
		self.modelName = modelName
		
		do {
			try persistanceStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
															   configurationName: nil,
															   at: storeUrl,
															   options: nil)
		} catch {
			fatalError("Error migrating store.")
		}
	}
	
	func findOrCreate<T: NSManagedObject>(by fetchRequest: NSFetchRequest<T>, with predicate: NSPredicate) -> T {
		if let result = find(by: fetchRequest, with: predicate).first {
			return result
		}
		
		let result = T(context: mainContext)
		do {
			try mainContext.save()
		} catch {
			print("Saving error: \(error)")
		}
		
		return result
	}
	
	func find<T>(by fetchRequest: NSFetchRequest<T>, with predicate: NSPredicate? = nil) -> [T] {
		fetchRequest.predicate = predicate
		do {
			return try mainContext.fetch(fetchRequest)
		} catch {
			print("Fetch error: \(error)")
		}
		
		return []
	}
}

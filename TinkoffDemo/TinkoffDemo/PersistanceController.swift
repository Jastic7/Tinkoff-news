//
//  PersistanceController.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation
import CoreData

class PersistanceController {
	
	lazy var writeContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.parent = readContext
		context.undoManager = nil
		return context
	}()
	
	lazy var readContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.parent = backgroundContext
		context.undoManager = nil
		return context
	}()
	
	private lazy var backgroundContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = persistanceStoreCoordinator
		context.undoManager = nil
		return context
	}()
	
	init(modelName: String) {
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
	
	func save() {
		guard writeContext.hasChanges else {
			print("There is no changes")
			return
		}
		
		writeContext.perform {
			do {
				try self.writeContext.save()
			} catch {
				print("Cannot save write context: \(error)")
			}
			
			self.readContext.performAndWait {
				do {
					try self.readContext.save()
				} catch {
					print("Cannot save main context: \(error)")
				}
				
				self.backgroundContext.perform {
					do {
						try self.backgroundContext.save()
					} catch {
						print("Cannot save backgorund context: \(error)")
					}
				}
			}
		}
	}
	
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
	
	func findOrCreate<T: NSManagedObject>(by fetchRequest: NSFetchRequest<T>, with predicate: NSPredicate) -> T {
		if let result = find(by: fetchRequest, with: predicate).first {
			return result
		}
		
		
		return T(context: writeContext)
	}
	
	func find<T>(by fetchRequest: NSFetchRequest<T>, with predicate: NSPredicate? = nil) -> [T] {
		fetchRequest.predicate = predicate
		do {
			return try writeContext.fetch(fetchRequest)
		} catch {
			print("Fetch error: \(error)")
		}
		
		return []
	}
}

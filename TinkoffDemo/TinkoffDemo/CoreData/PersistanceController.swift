//
//  PersistanceController.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation
import CoreData


/// Responsible for CoreData stack creation and context manipulation.
class PersistanceController {
	
	/// Context with privateQueueConcurrencyType.
	/// Use it for writing.
	lazy var writeContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.parent = viewContext
		context.undoManager = nil
		return context
	}()
	
	/// Context with mainQueueConcurrencyType.
	/// Use it for reading.
	lazy var viewContext: NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.parent = backgroundContext
		context.undoManager = nil
		return context
	}()
	
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
	
	/// Save all context alternately.
	///
	/// - Parameter completion: Fires, when main context has been saved.
	func save(completion: (() -> Void)? = nil) {
		guard writeContext.hasChanges || viewContext.hasChanges else {
			print("There is no changes")
			return
		}
		
		writeContext.perform {
			do {
				try self.writeContext.save()
			} catch {
				print("Cannot save write context: \(error)")
			}
			
			self.viewContext.perform {
				do {
					try self.viewContext.save()
					completion?()
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
	
	/// Try find object in coredata. If it doesn't exist - create it.
	///
	/// - Parameters:
	///   - fetchRequest: Description of request for object.
	///   - predicate: Filter condition.
	///   - context: Context for searching and creation.
	/// - Returns: Found or created object.
	func findOrCreate<T: NSManagedObject>(by fetchRequest: NSFetchRequest<T>, with predicate: NSPredicate, in context: NSManagedObjectContext) -> T {
		if let result = find(by: fetchRequest, with: predicate, in: context).first {
			return result
		}
		
		return T(context: context)
	}
	
	/// Search object on coredata by some criteria.
	///
	/// - Parameters:
	///   - fetchRequest: Description of request for object.
	///   - predicate: Filter condition.
	///   - context: Context for searching
	/// - Returns: Array of found objects or emtpy array, if there is no one object, which satisfy search criteria.
	func find<T>(by fetchRequest: NSFetchRequest<T>, with predicate: NSPredicate? = nil, in context: NSManagedObjectContext) -> [T] {
		fetchRequest.predicate = predicate
		do {
			return try context.fetch(fetchRequest)
		} catch {
			print("Fetch error: \(error)")
		}
		
		return []
	}
}

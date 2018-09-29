//
//  NewsCoreDataDataSource.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation
import CoreData

class NewsCoreDataDataSource<OutputType: DataSourceOutput>: NSObject, DataSourceProtocol, NSFetchedResultsControllerDelegate where OutputType.Element == News {
	
	var output: OutputType?
	
	private let persistanceController: PersistanceController
	private let translator = CoreDataTranslator()
	
	private lazy var fetchedResultController: NSFetchedResultsController<MONews> = {
		let publicationDateSort = NSSortDescriptor(key: "header.publicationDate", ascending: false)
		
		let fetchRequest: NSFetchRequest = MONews.fetchRequest()
		fetchRequest.sortDescriptors = [publicationDateSort]
		fetchRequest.fetchBatchSize = 20
		
		let context = persistanceController.viewContext
		
		return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
	}()
	
	
	//MARK:- DataSourceProtocol
	
	required init(persistanceController: PersistanceController) {
		self.persistanceController = persistanceController
		
		super.init()
		
		fetchedResultController.delegate = self;
		do {
			try fetchedResultController.performFetch()
		} catch {
			print("Cannot fetch results.")
		}
	}
	
	func entity(at indexPath: IndexPath) -> News {
		let moNews = fetchedResultController.object(at: indexPath)
		let news = translator.createEntity(from: moNews)
		
		return news
	}
	
	func save(entities: [News], completion: (() -> Void)? = nil) {
		let context = persistanceController.privateContext
		context.perform {
			entities.forEach { news in
				let predicate = NSPredicate(format: "%K == %@", #keyPath(MONews.header.id), news.header.id)
				let moNews = self.persistanceController.findOrCreate(by: MONews.fetchRequest(), with: predicate, in: context)
				self.translator.fill(entry: moNews, from: news, in: context)
			}
			
			self.persistanceController.save() {
				completion?()
			}
		}
	}
	
	func numberOfEntities(in section: Int) -> Int {
		guard let sections = fetchedResultController.sections else { return 0 }
		
		return sections[section].numberOfObjects
	}
	
	
	// MARK:- NSFetchedResultsControllerDelegate
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		output?.dataSourceWillChangeEntities()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		
		switch type {
		case .insert:
			let entry = fetchedResultController.object(at: newIndexPath!)
			let entity = translator.createEntity(from: entry)
			output?.dataSource(didChange: entity, with: DataSourceChangeType.insert(in: newIndexPath!))
			
		case .update:
			let entry = fetchedResultController.object(at: newIndexPath!)
			let entity = translator.createEntity(from: entry)
			output?.dataSource(didChange: entity, with: .update(at: newIndexPath!))
		default:
			break
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		output?.dataSourceDidChangeEntities()
	}
}

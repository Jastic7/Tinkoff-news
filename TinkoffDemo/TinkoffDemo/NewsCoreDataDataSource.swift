//
//  NewsCoreDataDataSource.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation
import CoreData

class NewsCoreDataDataSource: DataSourceProtocol {
	
	private let persistanceController: PersistanceController
	private let translator = CoreDataTranslator()
	
	init(persistanceController: PersistanceController) {
		self.persistanceController = persistanceController
	}
	
	func obtainAllEntities() -> [News] {
		let fetchedNews = persistanceController.find(by: MONews.fetchRequest())
		let results = fetchedNews.map { translator.createEntity(from: $0) }
	
		return results
	}
	
	func save(entities: [News]) {
		let context = persistanceController.context
		entities.forEach { news in
			let predicate = NSPredicate(format: "%K == %@", #keyPath(MONews.header.id), news.header.id)
			let moNews = persistanceController.findOrCreate(by: MONews.fetchRequest(), with: predicate)
			
			translator.fill(entry: moNews, from: news, in: context)
		}
		
		persistanceController.save()
	}
}

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
	
	private let coreDataManager = CoreDataManager()
	private let translator = CoreDataTranslator()
	
	func obtainAllEntities() -> [News] {
		let fetchedNews = coreDataManager.find(by: MONews.fetchRequest())
		let results = fetchedNews.map { translator.createEntity(from: $0) }
	
		return results
	}
	
	func save(entities: [News]) {
		let context = coreDataManager.mainContext!
		entities.forEach { news in
			let predicate = NSPredicate(format: "%K == %@", #keyPath(MONews.header.id), news.header.id)
			let moNews = coreDataManager.findOrCreate(by: MONews.fetchRequest(), with: predicate)
			
			translator.fill(entry: moNews, from: news, in: context)
		}
		
		do {
			try context.save()
		} catch {
			print("Saving error")
		}
	}
}

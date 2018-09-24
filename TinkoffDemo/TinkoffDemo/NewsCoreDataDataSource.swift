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
	
	func obtainAllEntities() -> [News] {
		var fetchedNews = [News]()
		let newsFetch: NSFetchRequest<MONews> = MONews.fetchRequest()
		do {
			let results = try coreDataManager.mainContext!.fetch(newsFetch)
			fetchedNews = results.map { managedObjectNews in
				let moHeader = managedObjectNews.header
				let header = NewsHeader.init(id: moHeader.id, text: moHeader.text, publicationDate: moHeader.publicationDate as Date)
				let moDetails = managedObjectNews.details
				let details = moDetails == nil ? nil : NewsDetails(content: moDetails!.content,
																   creationDate: moDetails!.creationDate as Date,
																   lastModificationDate: moDetails!.lastModificationDate as Date)
				
				return News(header: header, details: details, views: UInt(managedObjectNews.views))
			}
			
		} catch {
			print("error while fetching: \(error)")
		}
		
		return fetchedNews
	}
	
	func save(entities: [News]) {
		let context = coreDataManager.mainContext!
		entities.forEach { news in
			let moHeader = MONewsHeader(context: context)
			var moDetails: MONewsDetails? = nil
			let moNews = MONews(context: context)
			
			moHeader.id = news.header.id
			moHeader.text = news.header.text
			moHeader.publicationDate = news.header.publicationDate as NSDate
			
			if let details = news.details {
				moDetails = MONewsDetails(context: context)
				moDetails?.content = details.content
				moDetails?.creationDate = details.creationDate as NSDate
				moDetails?.lastModificationDate = details.lastModificationDate as NSDate
			}
			
			
			moNews.views = Int16(news.views)
			moNews.details = moDetails
			moNews.header = moHeader
		}
		
		do {
			try coreDataManager.mainContext!.save()
		} catch {
			print("Saving error")
		}
	}
}

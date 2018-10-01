//
//  NewsAssembly.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 01.10.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

class NewsAssembly {
	
	func construct(_ newsFeedController: NewsFeedViewController, with persistanceController: PersistanceController) {
		let baseURL = "https://api.tinkoff.ru/"
		let transportLayer = TrasnportLayer(baseUrl: baseURL)
		
		let newsService = NewsService(transportLayer: transportLayer)
		newsService.output = newsFeedController
		newsFeedController.newsService = newsService
		
		let dataSource = NewsCoreDataDataSource<NewsFeedViewController>(persistanceController: persistanceController)
		dataSource.output = newsFeedController
		newsFeedController.dataSource = dataSource
	}
}

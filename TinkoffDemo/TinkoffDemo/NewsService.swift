//
//  NewsService.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

class NewsService: NewsServiceInput {
	var output: NewsServiceOutput?
	private let transportLayer: TrasnportLayer
	
	required init(transportLayer: TrasnportLayer) {
		self.transportLayer = transportLayer
	}
	
	func obtainNews(for header: NewsHeader) {
		let params = ["id": header.id]
		let path = "/v1/news_content"
		
		transportLayer.makeRequest(by: path, with: params, success: { (data) in
			
		}) { (error) in
			
		}
	}
	
	func obtainNewsHeaders(from fisrtNumber: UInt, count: UInt) {
		let endNumber = fisrtNumber + count
		let params = ["first": String(fisrtNumber),
					  "last": String(endNumber)]
		let path = "/v1/news/"
		
		transportLayer.makeRequest(by: path, with: params, success: { (data) in
			
		}) { (error) in
			
		}
	}
}

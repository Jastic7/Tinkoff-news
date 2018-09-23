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
	
	func obtainDetails(for news: News) {
		let params = ["id": news.header.id]
		let path = "/v1/news_content"
		
		transportLayer.makeRequest(by: path, with: params, success: { (data) in
			let details: NewsDetails? = self.decode(data)
			DispatchQueue.main.async {
				self.output?.newsService(self, didLoad: details!, for: news)
			}
		}) { (error) in
			
		}
	}
	
	func obtainNewsHeaders(from fisrtNumber: UInt, count: UInt) {
		let endNumber = fisrtNumber + count
		let params = ["first": String(fisrtNumber),
					  "last": String(endNumber)]
		let path = "/v1/news/"
		
		transportLayer.makeRequest(by: path, with: params, success: { (data) in
			let headers: [NewsHeader]? = self.decode(data)
			DispatchQueue.main.async {
				self.output?.newsService(self, didLoad: headers!)
			}
		}) { (error) in
			
		}
	}
	
	// MARK:- Private methods
	
	private func decode<T: Codable>(_ data: Data) -> T? {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .millisecondsSince1970
		
		var result: T?
		do {
			result = try decoder.decode(ResultContainer<T>.self, from: data).payload
		} catch {
			print("error in parsing")
		}
		
		return result
	}
}

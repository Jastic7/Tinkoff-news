//
//  NewsServiceProtocol.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

protocol NewsServiceInput {
	
	var output: NewsServiceOutput? { get set }
	
	func obtainNewsHeaders(from fisrtNumber: UInt, count: UInt)
	func obtainNews(for header: NewsHeader)
}

protocol NewsServiceOutput {
	
	func newsService(_ service: NewsServiceInput, didLoad newsHeaders: [NewsHeader])
	func newsService(_ service: NewsServiceInput, didLoad news: News)
}

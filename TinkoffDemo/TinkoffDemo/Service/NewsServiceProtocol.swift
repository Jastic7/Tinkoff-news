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
	
	init(transportLayer: TrasnportLayer)
	
	func obtainNewsHeaders(from fisrtNumber: UInt, count: UInt)
	func obtainDetails(for newsId: String)
}

protocol NewsServiceOutput {
	
	func newsService(_ service: NewsServiceInput, didLoad newsHeaders: [NewsHeader])
	func newsService(_ service: NewsServiceInput, didLoad details: NewsDetails, for newsId: String)
}

//
//  NewsServiceProtocol.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation


/// Responsible for initiating process of news retrieving from API.
protocol NewsServiceInput {
	
	var output: NewsServiceOutput? { get set }
	
	init(transportLayer: TrasnportLayer)
	
	/// Get news headers by some portion.
	///
	/// - Parameters:
	///   - fisrtNumber: Start position of requesting news header.
	///   - count: Number of requesting news headers.
	func obtainNewsHeaders(from fisrtNumber: UInt, count: UInt)
	
	/// Get detail information for some news.
	///
	/// - Parameter news: News, which should be detailed.
	func obtainDetails(for news: News)
}

/// Responsible for translation progress of news retrieving process from API.
protocol NewsServiceOutput {
	
	/// Fires, when news headers has been loaded.
	///
	/// - Parameters:
	///   - service: Initiator of loading.
	///   - newsHeaders: List of loaded headers.
	func newsService(_ service: NewsServiceInput, didLoad newsHeaders: [NewsHeader])
	
	/// Fires, when news details has been loaded.
	///
	/// - Parameters:
	///   - service: Initiator of loading.
	///   - details: Details for news.
	///   - news: News, which should be detailed.
	func newsService(_ service: NewsServiceInput, didLoad details: NewsDetails, for news: News)
	
	/// Fires, when loading was failed.
	///
	/// - Parameter service: Initiator of loading.
	func newsServiceDidFail(_ service: NewsServiceInput)
}

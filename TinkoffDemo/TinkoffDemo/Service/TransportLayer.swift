//
//  TransportLayer.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

/// Responsible for data retrieving through URLSession.
class TrasnportLayer {
	private let baseUrl: String
	
	init(baseUrl: String) {
		self.baseUrl = baseUrl
	}
	
	/// Create and start data task.
	///
	/// - Parameters:
	///   - path: Path to end point of API.
	///   - parameters: Params for request.
	///   - success: Fires, when task has been completed successfully.
	///   - failure: Fires, when task has been failed.
	func makeRequest(by path: String,
					 with parameters: [String: String],
					 success: @escaping (_ data: Data) -> Void,
					 failure: @escaping (_ error: Error) -> Void) {
		guard var queryComponents = URLComponents(string: baseUrl) else { return }
		queryComponents.path = path
		queryComponents.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
		
		guard let url = queryComponents.url else { return }
		
		let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let error = error {
				failure(error)
				return
			}
			
			success(data!)
		}
		
		dataTask.resume()
	}
}

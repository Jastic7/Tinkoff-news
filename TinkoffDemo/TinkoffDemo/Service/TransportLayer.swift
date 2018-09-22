//
//  TransportLayer.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

class TrasnportLayer {
	private let baseUrl: String
	
	init(baseUrl: String) {
		self.baseUrl = baseUrl
	}
	
	func makeRequest(by path: String,
					 with parameters: [String: String],
					 success: @escaping (_ data: Data) -> Void,
					 failure: @escaping (_ error: Error) -> Void) {
		guard var queryComponents = URLComponents(string: baseUrl) else { return }
		queryComponents.path = path
		queryComponents.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
		
		guard let url = queryComponents.url else { return }
		print("makeRequest to url: \(url)")
		
		let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let error = error {
				failure(error)
				print("request to \(url): fail")
				return
			}
			
			print("request to \(url): success")
			success(data!)
		}
		
		dataTask.resume()
	}
}

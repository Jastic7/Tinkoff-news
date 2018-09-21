//
//  TransportLayer.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

protocol TransportLayerDelegate {
	func requestDidFail(error: Error)
	func requestDidSuccess(data: Data)
}

class TrasnportLayer {
	private let baseUrl: String
	var delegate: TransportLayerDelegate?
	
	init(baseUrl: String, delegate: TransportLayerDelegate) {
		self.baseUrl = baseUrl
		self.delegate = delegate
	}
	
	func makeRequest(by path: String, with parameters: [String: String]) {
		guard var queryComponents = URLComponents(string: baseUrl) else { return }
		queryComponents.path = path
		queryComponents.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
		
		guard let url = queryComponents.url else { return }
		print("makeRequest to url: \(url)")
		
		let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let error = error {
				self.delegate?.requestDidFail(error: error)
				return
			}
			
			self.delegate?.requestDidSuccess(data: data!)
		}
		
		dataTask.resume()
	}
}

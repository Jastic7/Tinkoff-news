//
//  News.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

struct News {
	let header: NewsHeader
	var details: NewsDetails?
	var views: UInt
	
	init(header: NewsHeader, details: NewsDetails? = nil, views: UInt = 0) {
		self.header = header
		self.details = details
		self.views = views
	}
	
	mutating func addView() {
		views = views + 1
	}
}

extension News: Equatable {
	
	public static func == (lhs: News, rhs: News) -> Bool {
		return lhs.header.id == rhs.header.id
	}
}

extension News: Hashable {
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(header.id)
	}
}

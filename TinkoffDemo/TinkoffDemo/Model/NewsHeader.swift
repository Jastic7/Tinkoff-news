//
//  NewsHeader.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

struct NewsHeader: Codable {
	let id: String
	let text: String
	var numberOfViews: UInt
	let publicationDate: Date
	
	enum CodingKeys: String, CodingKey {
		case id
		case text
		case numberOfViews
		case publicationDate
	}
	
	enum PublicationDateKeys: String, CodingKey {
		case milliseconds
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		text = try container.decode(String.self, forKey: .text)
		numberOfViews = try container.decodeIfPresent(UInt.self, forKey: .numberOfViews) ?? 0
		
		let publicationDateContainer = try container.nestedContainer(keyedBy: PublicationDateKeys.self, forKey: .publicationDate)
		publicationDate = try publicationDateContainer.decode(Date.self, forKey: .milliseconds)
	}
	
	mutating func increaseCounter() {
		numberOfViews = numberOfViews + 1
	}
}

extension NewsHeader: Equatable {
	
	public static func == (lhs: NewsHeader, rhs: NewsHeader) -> Bool {
		return lhs.id == rhs.id
	}
}

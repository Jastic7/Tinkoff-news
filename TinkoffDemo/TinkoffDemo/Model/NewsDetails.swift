//
//  NewsDetails.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

struct NewsDetails {
	let content: String
	let creationDate: Date
	let lastModificationDate: Date
}

extension NewsDetails: Codable {
	
	enum CodingKeys: String, CodingKey {
		case content
		case creationDate
		case lastModificationDate
	}
	
	enum CreationDateKeys: String, CodingKey {
		case milliseconds
	}
	
	enum LastModificationDateKeys: String, CodingKey {
		case milliseconds
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		content = try container.decode(String.self, forKey: .content)
		
		let creationDateContainer = try container.nestedContainer(keyedBy: CreationDateKeys.self, forKey: .creationDate)
		creationDate = try creationDateContainer.decode(Date.self, forKey: .milliseconds)
		
		let modificationDateContainer = try container.nestedContainer(keyedBy: LastModificationDateKeys.self, forKey: .lastModificationDate)
		lastModificationDate = try modificationDateContainer.decode(Date.self, forKey: .milliseconds)
	}
}

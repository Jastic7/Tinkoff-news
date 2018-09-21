//
//  NewsHeadersContainer.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

struct NewsHeadersContainer: Codable {
	let resultCode: String
	let payload: [NewsHeader]
	let trackingId: String
}

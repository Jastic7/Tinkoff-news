//
//  ResultContainer.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 21.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

struct ResultContainer<T: Codable>: Codable {
	let resultCode: String
	let payload: T
	let trackingId: String
}

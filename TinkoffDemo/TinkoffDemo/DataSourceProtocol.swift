//
//  DataSourceProtocol.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

protocol DataSourceProtocol {
	
	associatedtype T
	
	func obtainAllEntities() -> [T]
	func save(entities: [T])
}

//
//  DataSourceProtocol.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

protocol DataSourceProtocol {
	
	associatedtype E
	associatedtype O: DataSourceOutput where O.E == E
	var output: O { get }
	
	init(persistanceController: PersistanceController, output: O)
	
	func entity(at indexPath: IndexPath) -> E
	func save(entities: [E], completion: (() -> Void)?)
	func numberOfEntities(in section: Int) -> Int
}

protocol DataSourceOutput {
	
	associatedtype E
	
	func dataSourceWillChangeEntities()
	func dataSourceDidChangeEntities()
	func dataSource(didChange entity: E, with type: DataSourceChangeType)
}

enum DataSourceChangeType {
	case insert (in: IndexPath)
	case update (at: IndexPath)
	case delete (from: IndexPath)
	case move (from: IndexPath, to: IndexPath)
}

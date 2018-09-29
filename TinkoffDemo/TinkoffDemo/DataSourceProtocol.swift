//
//  DataSourceProtocol.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

protocol DataSourceProtocol {
	
	associatedtype Element
	associatedtype OutputType: DataSourceOutput where OutputType.Element == Element
	var output: OutputType? { get set }
	
	init(persistanceController: PersistanceController)
	
	func entity(at indexPath: IndexPath) -> Element
	func save(entities: [Element], completion: (() -> Void)?)
	func numberOfEntities(in section: Int) -> Int
}

protocol DataSourceOutput {
	
	associatedtype Element
	
	func dataSourceWillChangeEntities()
	func dataSourceDidChangeEntities()
	func dataSource(didChange entity: Element, with type: DataSourceChangeType)
}

enum DataSourceChangeType {
	case insert (in: IndexPath)
	case update (at: IndexPath)
	case delete (from: IndexPath)
	case move (from: IndexPath, to: IndexPath)
}

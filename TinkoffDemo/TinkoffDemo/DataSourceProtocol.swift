//
//  DataSourceProtocol.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//

import Foundation

/// Describe some source of data.
protocol DataSourceProtocol {
	
	/// Type of elements in source.
	associatedtype Element
	
	/// Type for output of datasource.
	associatedtype OutputType: DataSourceOutput where OutputType.Element == Element
	
	var output: OutputType? { get set }
	
	init(persistanceController: PersistanceController)
	
	/// Retrieve entity from source at index path.
	///
	/// - Parameter indexPath: Position of retrieving entity.
	/// - Returns: Entity for appropriate indexpath.
	func entity(at indexPath: IndexPath) -> Element

	/// Save list of entities to source.
	///
	/// - Parameters:
	///   - entities: List of entities, which should be saved.
	///   - completion: Fires, when entities has been saved.
	func save(entities: [Element], completion: (() -> Void)?)
	
	/// Retrieve number of entities in source.
	///
	/// - Parameter section: Section of entities.
	/// - Returns: Count of entities in appropriate section.
	func numberOfEntities(in section: Int) -> Int
}

/// Responsible for translation state of dataSource.
protocol DataSourceOutput {
	
	/// Type of elements in source.
	associatedtype Element
	
	/// Fires, when entities in source will be changed.
	func dataSourceWillChangeEntities()
	
	/// Fires, when entities in source has been changed.
	func dataSourceDidChangeEntities()
	
	/// Fires, when entity in source is changing.
	///
	/// - Parameters:
	///   - entity: Changing entity from source.
	///   - type: Type of change.
	func dataSource(didChange entity: Element, with type: DataSourceChangeType)
}

enum DataSourceChangeType {
	case insert (in: IndexPath)
	case update (at: IndexPath)
	case delete (from: IndexPath)
	case move (from: IndexPath, to: IndexPath)
}

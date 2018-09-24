//
//  MONews+CoreDataProperties.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//
//

import Foundation
import CoreData


extension MONews {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MONews> {
        return NSFetchRequest<MONews>(entityName: "MONews")
    }

    @NSManaged public var views: Int16
    @NSManaged public var details: MONewsDetails?
    @NSManaged public var header: MONewsHeader

}

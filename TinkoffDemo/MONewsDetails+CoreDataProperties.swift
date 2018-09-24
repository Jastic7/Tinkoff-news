//
//  MONewsDetails+CoreDataProperties.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//
//

import Foundation
import CoreData


extension MONewsDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MONewsDetails> {
        return NSFetchRequest<MONewsDetails>(entityName: "MONewsDetails")
    }

    @NSManaged public var content: String
    @NSManaged public var creationDate: NSDate
    @NSManaged public var lastModificationDate: NSDate
    @NSManaged public var news: MONews?

}

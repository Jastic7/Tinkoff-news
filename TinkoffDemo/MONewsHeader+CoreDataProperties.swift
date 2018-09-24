//
//  MONewsHeader+CoreDataProperties.swift
//  TinkoffDemo
//
//  Created by Andrey Morozov on 23.09.2018.
//  Copyright © 2018 Jastic7. All rights reserved.
//
//

import Foundation
import CoreData


extension MONewsHeader {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MONewsHeader> {
        return NSFetchRequest<MONewsHeader>(entityName: "MONewsHeader")
    }

    @NSManaged public var id: String
    @NSManaged public var publicationDate: NSDate
    @NSManaged public var text: String
    @NSManaged public var news: MONews?

}

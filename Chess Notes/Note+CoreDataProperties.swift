//
//  Note+CoreDataProperties.swift
//  Chess Notes
//
//  Created by Joshua Lin on 1/1/20.
//  Copyright © 2020 Joshua Lin. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var board_state: String?
    @NSManaged public var note: String?

}

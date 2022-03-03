//
//  Message+CoreDataProperties.swift
//  ChatScreen
//
//  Created by Zain Sidhu on 01/03/2022.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var content: String?
    @NSManaged public var type: String?

}

extension Message : Identifiable {

}

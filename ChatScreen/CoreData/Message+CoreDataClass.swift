//
//  Message+CoreDataClass.swift
//  ChatScreen
//
//  Created by Zain Sidhu on 01/03/2022.
//
//

import Foundation
import CoreData
import UIKit

@objc(Message)
public class Message: NSManagedObject {
    static func create() -> Message {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let messageEntity = NSEntityDescription.insertNewObject(forEntityName: "Message", into: appDelegate.managedObjectContext) as! Message
        return messageEntity
        
    }
    
    private static func setContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
    
    func save() {
        AppDelegate.saveManagedContext()
    }
    
    class func getMessages(page: Int)->[Message]? {
        
        let predicate = NSSortDescriptor(key: "timestamp", ascending: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let fetchRequest : NSFetchRequest<Message> = self.fetchRequest()
        
        fetchRequest.fetchOffset = (page - 1) * Paging.perPage
        fetchRequest.fetchLimit = Paging.perPage
        
        fetchRequest.sortDescriptors = [predicate]
        
        do {
            let messages = try appDelegate.managedObjectContext.fetch(fetchRequest)
            return messages.reversed()
        }
        catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
}

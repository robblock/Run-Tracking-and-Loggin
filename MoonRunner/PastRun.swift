//
//  PastRun.swift
//  MoonRunner
//
//  Created by Rob Block on 8/29/15.
//  Copyright (c) 2015 Zedenem. All rights reserved.
//

import Foundation
import CoreData
import Parse

class PastRun: PFObject, PFSubclassing {
    
    @NSManaged var pace: String
    @NSManaged var timeStamp: String
    @NSManaged var distance: String
    @NSManaged var date: String
    
    @NSManaged var image: PFFile
    @NSManaged var run: NSManagedObject
    
    @NSManaged var runImage:NSData
    
    @NSManaged var pastRun: NSManagedObject
    
    
    
    //1
    class func parseClassName() -> String {
        return "pastRun"
    }
    
    //2
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: PastRun.parseClassName())
        query.includeKey("user")
        query.orderByDescending("createdAt")
        return query
    }
    
    init(image: PFFile, pace: String, timeStamp: String, date: String, distance: String) {
        super.init()
        
        self.image = image
        self.pace = pace
        self.timeStamp = timeStamp
        self.date = date
        self.distance = distance
        
    }
    
    override init() {
        super.init()
    }
    
}





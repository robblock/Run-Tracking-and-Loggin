//
//  Run.swift
//  RWM - Track & Save Run
//
//  Created by Rob Block on 9/2/15.
//  Copyright (c) 2015 RWM. All rights reserved.
//
import Foundation
import CoreData

class Run: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var distance: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var locations: NSOrderedSet
    @NSManaged var runMapImage: NSData

}


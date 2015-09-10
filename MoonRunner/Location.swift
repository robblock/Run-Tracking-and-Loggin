//
//  Location.swift
//  RWM - Track & Save Run
//
//  Created by Rob Block on 9/2/15.
//  Copyright (c) 2015 RWM. All rights reserved.
//
import Foundation
import CoreData


class Location: NSManagedObject {

    @NSManaged var timestamp: NSDate
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var run: NSManagedObject

}

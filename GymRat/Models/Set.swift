//
//  Set.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/23/19.
//  Final Project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This class is used to create a Set object, which stores
//  details about one specific set of an exercise done by a
// user. Basically, it stores the details of the details
//

import Foundation

class Set: NSObject, Codable
{
    // Set number of the set being done
    var number = 0
    
    // Amount of weight lifted
    var weight = 0

    // Number of repetitions performed
    var repetitions = 0

    // Effort level put into the set
    var effort = 0.0
    
    init(number: Int)
    {
        self.number = number
    }
}

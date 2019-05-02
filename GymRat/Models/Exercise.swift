//
//  Exercise.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/7/19.
//  Final project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This class is used to create an exercise object,
//  which is then used to store details about an
//  exercise performed during a user's workout
//

import Foundation

class Exercise: NSObject, Codable
{
    // Name of the exercise performed
    var name = ""
    
    // Array of sets of the exercise performed
    var sets = [Set]()
    
    init(name: String)
    {
        self.name = name
    }
}

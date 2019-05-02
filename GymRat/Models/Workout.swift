//
//  Workout.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/7/19.
//  Final project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This class is used to create a workout object, which
//  is then used to store data about a user's workout
//

import UIKit

class Workout: NSObject, Codable
{
    // Name of the workout
    var name = ""
    
    // Stores when the workout was performed
    var date = Date()
    
    // Array of exercises performed during the workout
    var exercises = [Exercise]()
    
    // Stores the location where the workout was performed
    var location = ""
    
    var photoID: Int?
    
    var hasPhoto: Bool
    {
        return photoID != nil
    }
    
    var photoURL: URL
    {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!).jpg"
        return appDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var photoImage: UIImage?
    {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    // Gets path to the app's documents directory
    let appDocumentsDirectory: URL =
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }()
    
    init(name: String, date: Date)
    {
        self.name = name
        self.date = date
    }
    
    func nextPhotoID() -> Int
    {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile()
    {
        if hasPhoto
        {
            do
            {
                try FileManager.default.removeItem(at: photoURL)
            }
                
            catch
            {
                print("Error removing file: \(error)")
            }
        }
    }
}

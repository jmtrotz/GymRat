//
//  DataModel.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/7/19.
//  Final project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This class is used to load/save data to/from
//  AllWorkoutsViewController
//

import Foundation

class DataModel
{
    // Workout object array
    var workouts = [Workout]()
    
    // Index of the workout the user selected
    var indexOfSelectedWorkout: Int
    {
        get
        {
            return UserDefaults.standard.integer(forKey: "WorkoutIndex")
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: "WorkoutIndex")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Loads workouts from storage and calls functions to handle the
    // first time the app is being launched (if it is the first time)
    init()
    {
        loadWorkouts()
        setDefaults()
        firstTime()
    }
    
    // Checks if the app is being run for the first
    func firstTime()
    {
        // Get defaults
        let defaults = UserDefaults.standard
        
        // Get boolean value for "FirstTime"
        let firstTime = defaults.bool(forKey: "FirstTime")
        
        // If it is the first time, add a default workout the user can add to
        if firstTime
        {          
            // Set first time to false so this code won't be executed again
            defaults.set(false, forKey: "FirstTime")
            defaults.synchronize()
        }
    }
    
    // Creates a new Dictionary instance
    func setDefaults()
    {
        let dictionary: [String: Any] = ["WorkoutIndex": -1, "FirstTime": true]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    // Gets the full path to the documents directory
    func getDocumentsDirectoryPath() -> URL
    {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    // Appends path to the directory where the data for the app is stored
    // that was returned by the function above
    func getFilePath() -> URL
    {
        return getDocumentsDirectoryPath().appendingPathComponent("Workouts.plist")
    }
    
    // Saves the recorded workouts
    func saveWorkouts()
    {
        // Create instance of data encoder
        let dataEncoder = PropertyListEncoder()
        
        // Try to write data to disk
        do
        {
            let dataToSave = try dataEncoder.encode(workouts)
            
            try dataToSave.write(to: getFilePath(), options: Data.WritingOptions.atomic)
        }
        
        // Catch any errors that were thrown
        catch
        {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Loads the recorded workouts when the app launches
    func loadWorkouts()
    {
        // Get the path to the directory where the data is stored
        let filePath = getFilePath()
        
        if let data = try? Data(contentsOf: filePath)
        {
            // Create instance of data decoder
            let dataDecoder = PropertyListDecoder()
            
            // Try to load the saved data
            do
            {
                workouts = try dataDecoder.decode([Workout].self, from: data)
            }
            
            // Catch any errors that were thrown
            catch
            {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    // Sorts the workouts by date
    func sortWorkouts()
    {
        workouts.sort(by:
        {
            workout1, workout2 in
            return workout1.date.compare(workout2.date) == .orderedDescending
        })
    }
}

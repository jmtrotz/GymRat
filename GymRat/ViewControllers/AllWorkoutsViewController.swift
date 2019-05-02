//
//  AllWorkoutsViewController.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/7/19.
//  Final project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This is the view controller for the scene that shows
//  a list of all saved workouts
//

import UIKit

class AllWorkoutsViewController: UITableViewController, UINavigationControllerDelegate, AddWorkoutViewControllerDelegate
{
    // Data model object for accessing saved workouts
    var dataModel: DataModel!
    
    // Disposes of any resources that can be recreated
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // Sets properties for the view controller before it becomes visible
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ViewExercises"
        {
            // Set destination view controller and sender
            let controller = segue.destination as! AllExercisesViewController
            controller.workout = (sender as! Workout)
        }
            
        else if segue.identifier == "AddWorkout"
        {
            // Set destination view controller and delegate
            let controller = segue.destination as! AddWorkoutViewController
            controller.delegate = self
        }
    }
    
    // Calls this method after the view loads successfully
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Make the nav bar title large
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // Calls this method before the view becomes visible
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Reload the table view
        tableView.reloadData()
    }
    
    // Calls this method after the view becomes visible
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Set itself as the delegate for the navigation controller
        navigationController?.delegate = self
    }
    
    // Fills in cells for the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell
    {
        // Create table view cell and workout object
        let cell = makeCell(for: tableView)
        let workout = dataModel.workouts[indexPath.row]
        
        // Get the number of exercises done and the date
        let count = workout.exercises.count
        let date = self.formatDate(workoutDate: workout.date)
        
        // Set cell text and accessory
        cell.textLabel!.text = workout.name
        cell.accessoryType = .detailDisclosureButton
        
        // If the workout is empty, display "No Exercises"
        if count == 0
        {
            cell.detailTextLabel!.text = "No Exercises"
        }
            
            // If the workout is not empty, display the number of exercises performed
        else
        {
            cell.detailTextLabel!.text = "\(count) Exercises Done on \(date)"
        }
        
        return cell
    }
    
    // Returns the number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataModel.workouts.count
    }
    
    // Transfers user to the edit workout screen when the accessory button is selected
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        // Create controller object
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddWorkoutViewController") as! AddWorkoutViewController
        controller.delegate = self
        
        // Get workout and set it to be edited
        let workout = dataModel.workouts[indexPath.row]
        controller.workoutToEdit = workout
        
        // "Pushes" navigation controller onto the navigation stack
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // Transfers user to the list of exercises when a workout is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        dataModel.indexOfSelectedWorkout = indexPath.row
        
        let workout = dataModel.workouts[indexPath.row]
        performSegue(withIdentifier: "ViewExercises", sender: workout)
    }
    
    // Deletes a workout from the table
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        dataModel.workouts.remove(at: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    // Creates a new cell in the table
    func makeCell(for tableView: UITableView) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        {
            return cell
        }
            
        else
        {
            return UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
    }
    
    // Formats the date shown in the cell detail label
    func formatDate(workoutDate: Date) -> String
    {
        // Create formatter object to convert the date to text
        let formatter = DateFormatter()
        
        // Set date/time styles
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter.string(from: workoutDate)
    }
    
    // Called when the navigation controller shows a new screen. If the back
    // button is pressed, the new view controller is AddWorkoutViewController itself
    // and "WorkoutIndex" value in UserDefaults is -1, meaning nothing is selected
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)
    {
        // Was the back button tapped?
        // 3 equal sings means checking if 2 variables refer to the same object
        if viewController === self
        {
            dataModel.indexOfSelectedWorkout = -1
        }
    }
    
    // Cancels adding a new workout
    func addWorkoutViewControllerDidCancel(_ controller: AddWorkoutViewController)
    {
        // "Pops" the view controller off the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Returns to the main screen when the user finishes editing a workout
    func addWorkoutViewController(_ controller: AddWorkoutViewController, didFinishEditing workout: Workout)
    {
        // Sort workouts and reload data shown in the table view
        dataModel.sortWorkouts()
        tableView.reloadData()
        
        // "Pops" the view controller off or the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Returns to the main screen when the user finishes adding a workout
    func addWorkoutViewController(_ controller: AddWorkoutViewController, didFinishAdding workout: Workout)
    {
        // Add new workout to the array, sort workouts, and reload table data
        dataModel.workouts.append(workout)
        dataModel.sortWorkouts()
        tableView.reloadData()
        
        // "Pops" the view controller off tor he navigation stack
        navigationController?.popViewController(animated: true)
    }
}

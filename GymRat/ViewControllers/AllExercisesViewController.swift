//
//  AllExercisesViewConteroller.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/7/19.
//  Final project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This class is the view controller for the scene that
//  shows the list of exercises from one workout
//

import UIKit

class AllExercisesViewController: UITableViewController, UINavigationControllerDelegate, AddExerciseViewControllerDelegate
{
    // Workout object for accessing saved exercises
    var workout: Workout!
    
    // Disposes of any resources that can be recreated
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // Sets properties for the new view controller before it becomes visible
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ViewSets"
        {
            // Set destination view controller and sender
            let controller = segue.destination as! AllSetsViewController
            controller.exercise = (sender as! Exercise)
        }
            
        else if segue.identifier == "AddExercise"
        {
            // Set destination view controller and delegate
            let controller = segue.destination as! AddExerciseViewController
            controller.delegate = self
        }
    }
    
    // Calls this method after the view loads successfully
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Make the nav bar title small
        navigationItem.largeTitleDisplayMode = .never
        
        // Set the title for the screen
        title = workout.name
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
        // Create table view cell and exercise object
        let cell = makeCell(for: tableView)
        let exercise = workout.exercises[indexPath.row]
        let count = exercise.sets.count
        
        // Set cell text and accessory
        cell.textLabel!.text = exercise.name
        cell.accessoryType = .detailDisclosureButton
        
        // If the exercise is empty, display "No Exercises"
        if count == 0
        {
            cell.detailTextLabel!.text = "No Sets"
        }
            
        // If the workout is not empty, display details
        else
        {
            cell.detailTextLabel!.text = "\(count) Sets Done"
        }
        
        return cell
    }
    
    // Returns the number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return workout.exercises.count
    }
    
    // Transfers user to the edit workout screen when the accessory button is selected
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        // Create controller object
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddExerciseViewController") as! AddExerciseViewController
        controller.delegate = self
        
        // Get exercise and set it to be edited
        let exercise = workout.exercises[indexPath.row]
        controller.exerciseToEdit = exercise
        
        // "Pushes" navigation controller onto the navigation stack
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // Transfers user to the list of sets done for the exercise when an exercise is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let exercise = workout.exercises[indexPath.row]
        performSegue(withIdentifier: "ViewSets", sender: exercise)
    }
    
    // Deletes an exercise from the table
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        // Remove exercise from the array
        workout.exercises.remove(at: indexPath.row)
        
        // Delete corresponding row from the table
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
    
    // Cancels adding a new exercise
    func addExerciseViewControllerDidCancel(_ controller: AddExerciseViewController)
    {
        // "Pops" the view controller off the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Returns to the main screen when the user finishes editing an exercise
    func addExerciseViewController(_ controller: AddExerciseViewController, didFinishEditing exercise: Exercise)
    {
        // Reload data shown in the table view
        tableView.reloadData()
        
        // "Pops" the view controller off or the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Returns to the main screen when the user finishes adding an exercise
    func addExerciseViewController(_ controller: AddExerciseViewController, didFinishAdding exercise: Exercise)
    {
        // Add the exercise to the array and reload table data
        workout.exercises.append(exercise)
        tableView.reloadData()
        
        // "Pops" the view controller off tor he navigation stack
        navigationController?.popViewController(animated: true)
    }
}


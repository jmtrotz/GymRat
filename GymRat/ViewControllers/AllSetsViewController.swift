//
//  AllSetsViewController.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/23/19.
//  Final project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This is the view controller for the scene that shows
//  a list sets for one exercise
//

import UIKit

class AllSetsViewController: UITableViewController, UINavigationControllerDelegate, AddSetViewControllerDelegate
{
    // Exercise object for accessing saved sets
    var exercise: Exercise!
    
    // Disposes of any resources that can be recreated
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // Sets properties for the view controller before it becomes visible
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "AddSet"
        {
            // Set destination view controller and delegate
            let controller = segue.destination as! AddSetViewController
            controller.numberOfExistingSets = exercise.sets.count
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
        title = exercise.name
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
        // Create table view cell and set object
        let cell = makeCell(for: tableView)
        let set = exercise.sets[indexPath.row]
        
        // Set cell text and accessory
        cell.textLabel!.text = "Set \(set.number)"
        cell.accessoryType = .disclosureIndicator
        
        // If any sets exist, display data for the set
        if exercise.sets.count > 0
        {
            cell.detailTextLabel!.text = "\(set.weight) lbs lifted \(set.repetitions) times"
        }
        
        return cell
    }
    
    // Returns the number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return exercise.sets.count
    }    
    
    // Transfers user to the add/edit set screen when a table row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Create controller object
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddSetViewController") as! AddSetViewController
        controller.delegate = self
        
        // Get set the set to be edited
        let set = exercise.sets[indexPath.row]
        controller.setToEdit = set
        
        //"Pushes" the view controller onto the navigation stack
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // Deletes a set from the table
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        // Remove set from the array
        exercise.sets.remove(at: indexPath.row)
        
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
    
    // Cancels adding a new set
    func addSetViewControllerDidCancel(_ controller: AddSetViewController)
    {
        // "Pops" the view controller off the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Returns to the main screen when the user finishes editing a set
    func addSetViewController(_ controller: AddSetViewController, didFinishEditing set: Set)
    {
        // Reload data shown in the table view
        tableView.reloadData()
        
        // "Pops" the view controller off or the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Returns to the main screen when the user finishes adding a set
    func addSetViewController(_ controller: AddSetViewController, didFinishAdding set: Set)
    {
        // Add new set to the array and reload table data
        exercise.sets.append(set)
        tableView.reloadData()
        
        // "Pops" the view controller off tor he navigation stack
        navigationController?.popViewController(animated: true)
    }
}

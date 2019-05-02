//
//  AddExerciseViewController.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/7/19.
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This is the view controller for the scene that is
//  used to add or exit exercises performed during a workout
//

import UIKit

protocol AddExerciseViewControllerDelegate: class
{
    func addExerciseViewControllerDidCancel(_ controller: AddExerciseViewController)
    func addExerciseViewController(_ controller: AddExerciseViewController, didFinishEditing exercise: Exercise)
    func addExerciseViewController(_ controller: AddExerciseViewController, didFinishAdding exercise: Exercise)
}

class AddExerciseViewController: UITableViewController, UITextFieldDelegate
{
    // Outlet for the text entry box for a new exercise
    @IBOutlet weak var exerciseName: UITextField!
    
    // Outlet for the done button in the nav bar
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    // Property to access functions in the protocol above
    weak var delegate: AddExerciseViewControllerDelegate?
    
    // Exercise being edited
    var exerciseToEdit: Exercise?
    
    // Exercise object
    var exercise: Exercise!
    
    // Cancels adding a new exercise
    @IBAction func cancel()
    {
        delegate?.addExerciseViewControllerDidCancel(self)
    }
    
    // Adds a new exercise or updates one being edited
    @IBAction func done()
    {
        // Create HUD view object
        let hudView = HUDView.hud(inView: view, animated: true)
        
        // If they're editing an exercise, update it
        if let exercise = exerciseToEdit
        {
            // Set properties for the exercise and HUD objects
            exercise.name = exerciseName.text!
            hudView.text = "Updated"
            
            // Wait 1 second, then go back to the last screen
            afterDelay(1.0)
            {
                hudView.hide()
                self.delegate?.addExerciseViewController(self, didFinishEditing: exercise)
            }
        }
            
        // If they're adding an exercise, save it
        else
        {
            // Set properties for the exercise and HUB objects
            let exercise = Exercise(name: exerciseName.text!)
            hudView.text = "Saved"
            
            // Wait 1 second, then go back to the last screen
            afterDelay(1.0)
            {
                hudView.hide()
                self.delegate?.addExerciseViewController(self, didFinishAdding: exercise)
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Disable large titles
        navigationItem.largeTitleDisplayMode = .never
        
        // If they select to edit an exercise rather than add,
        // change the title at the top of the screen
        if let exercise = exerciseToEdit
        {
            title = "Edit \(exercise.name)"
            exerciseName.text = exercise.name
            doneBarButton.isEnabled = true
        }
    }
    
    // Sets focus on the exercise name text box when the view loads
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        exerciseName.becomeFirstResponder()
    }
    
    // Called when the user enters or changes the text in the text field. If the text
    // field is not empty, then it enables the done button so the exercise can be saved
    func textField(_ exerciseName: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // Figure out what the new text will be after the user enters or changes the text in the text box
        let oldExerciseNameText = exerciseName.text!
        let exerciseNameRange = Range(range, in: oldExerciseNameText)!
        let newExerciseNameText = oldExerciseNameText.replacingCharacters(in: exerciseNameRange, with: string)
        
        // If newExerciseNameText is not empty then the done button is enabled, else it is disabled
        doneBarButton.isEnabled = !newExerciseNameText.isEmpty
        return true
    }
}

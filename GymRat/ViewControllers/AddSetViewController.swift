//
//  AddSetViewController.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/23/19.
//  Final project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This class is the view controller for the scene that
//  is used to add a new set to an exercise
//

import UIKit

protocol AddSetViewControllerDelegate: class
{
    func addSetViewControllerDidCancel(_ controller: AddSetViewController)
    func addSetViewController(_ controller: AddSetViewController, didFinishEditing set: Set)
    func addSetViewController(_ controller: AddSetViewController, didFinishAdding set: Set)
}

class AddSetViewController: UITableViewController, UITextFieldDelegate
{
    // Outlet for the text entry box for the amount of weight used for the set
    @IBOutlet weak var weightUsed: UITextField!
    
    // Outlet for the text entry box for the number of repetitions done for the set
    @IBOutlet weak var repetitionsDone: UITextField!
    
    // Outlet for the slider where the user chooses how hard they tried for this set
    @IBOutlet weak var effortSlider: UISlider!
    
    // Outlet for the done button in the nav bar
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    // Property to access functions in the protocol above
    weak var delegate: AddSetViewControllerDelegate?
    
    // Set being edited
    var setToEdit: Set?
    
    // Set object
    var set: Set!
    
    // Number of currently existing sets in the array
    var numberOfExistingSets: Int?
    
    // Cancels adding a new Set
    @IBAction func cancel()
    {
        delegate?.addSetViewControllerDidCancel(self)
    }
    
    // Adds a new set or updates one being edited
    @IBAction func done()
    {
        // Create HUD view object
        let hudView = HUDView.hud(inView: view, animated: true)
        
        // If they're editing an set, update it
        if let set = setToEdit
        {
            // Set properties for the set and HUD objects
            set.weight = Int(weightUsed.text!) ?? 0
            set.repetitions = Int(repetitionsDone.text!) ?? 0
            set.effort = Double(effortSlider.value)
            
            hudView.text = "Updated"
            
            // Wait 1 second, then go back to the last screen
            afterDelay(1.0)
            {
                hudView.hide()
                self.delegate?.addSetViewController(self, didFinishEditing: set)
            }
        }
            
        // If they're adding an set, save it
        else
        {
            // Set properties for the set and HUD objects
            let set = Set(number: (numberOfExistingSets ?? 0) + 1)
            set.weight = Int(weightUsed.text!) ?? 0
            set.repetitions = Int(repetitionsDone.text!) ?? 0
            set.effort = Double(effortSlider.value)
            hudView.text = "Saved"
            
            // Wait 1 second, then go back to the last screen
            afterDelay(1.0)
            {
                hudView.hide()
                self.delegate?.addSetViewController(self, didFinishAdding: set)
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Disable large titles
        navigationItem.largeTitleDisplayMode = .never
        
        // Make the keyboard only show numbers when the user enters the amount of weight
        // or number of reps so they don't try to store a String instead of an Int
        weightUsed.keyboardType = UIKeyboardType.numberPad
        repetitionsDone.keyboardType = UIKeyboardType.numberPad
        
        // If they select to edit an set rather than add,
        // change the title at the top of the screen
        if let set = setToEdit
        {
            title = "Edit Set \(set.number)"
            weightUsed.text = String(set.weight)
            repetitionsDone.text = String(set.repetitions)
            effortSlider.value = Float(set.effort)
            doneBarButton.isEnabled = true
        }
    }
    
    // Sets focus on the set name text box when the view loads
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        weightUsed.becomeFirstResponder()
    }
    
    // Called when the user enters or changes the text in the weightUsed text field
    func textField(_ weightUsed: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // Figure out what the new text will be after the user enters or changes the text in the text box
        let oldWeightUsedText = weightUsed.text!
        let weightUsedRange = Range(range, in: oldWeightUsedText)!
        let newWeightUsedText = oldWeightUsedText.replacingCharacters(in: weightUsedRange, with: string)
        
        // If newWeightUsedText is not empty then the done button is enabled, else it stays disabled
        doneBarButton.isEnabled = !newWeightUsedText.isEmpty
        return true
    }
}

//
//  AddWorkoutViewController.swift
//  GymRat
//
//  Created by Jeffery Trotz on 3/7/19.
//  Final project for CS 330
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
//  This is the view controller for the scene that is
//  used to add or edit a workout
//

import UIKit
import CoreLocation

protocol AddWorkoutViewControllerDelegate: class
{
    func addWorkoutViewControllerDidCancel(_ controller: AddWorkoutViewController)    
    func addWorkoutViewController(_ controller: AddWorkoutViewController, didFinishEditing workout: Workout)
    func addWorkoutViewController(_ controller: AddWorkoutViewController, didFinishAdding workout: Workout)
}

class AddWorkoutViewController: UITableViewController, UITextFieldDelegate, CLLocationManagerDelegate
{
    // Outlet for the text entry box where the name of a new workout is entered
    @IBOutlet weak var workoutName: UITextField!
    
    // Outlet for the workout date chosen by the user to be displayed
    @IBOutlet weak var workoutDateLabel: UILabel!
    
    // Outlet for the date picker
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // Outlet for the table cell that contains the date picker to be inserted
    @IBOutlet weak var datePickerCell: UITableViewCell!
    
    // Outlet for the done button in the nav bar
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    // Outlet for the "Save Location" switch
    @IBOutlet weak var saveLocationSwitch: UISwitch!
    
    // Outlet for the label that shows the address where the workout is/was being done
    @IBOutlet weak var addressLabel: UILabel!
    
    // Image view where the user's progress photo is shown
    @IBOutlet weak var imageView: UIImageView!
    
    // Label next to the image view defined above
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    // Height constraint for the image view defined above
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    // Property to access functions in the protocol above
    weak var delegate: AddWorkoutViewControllerDelegate?
    
    // Workout being edited
    var workoutToEdit: Workout?
    
    // Stores the workout date
    var workoutDate = Date()
    
    // Keeps track if the date picker is visible or not
    var datePickerVisible = false
    
    // Location manager for getting GPS coordinates
    let locationManager = CLLocationManager()
    
    // Stores the user's current location
    var location: CLLocation?
    
    // Keeps track if location is currently being updated or not
    var updatingLocation = false
    
    // Stores any location errors
    var lastLocationError: Error?
    
    // Geocoder to turn location coordinates into an address
    var geocoder = CLGeocoder()
    
    // Placemark data for a geographic location
    var placemark: CLPlacemark?
    
    // Keeps track if any geocoding is currently underway or not
    var performingReverseGeocoding = false
    
    // Stores any geocoding errors
    var lastGeocodingError: Error?
    
    // Timer to time how long the location manager takes
    // to find the user's location
    var timer: Timer?
    
    // Keeps track if the "save location" switch is on or off
    var switchIsOn = false
    
    // Progess photo taken/chosen by the user
    var image: UIImage?
    
    // Cancels adding a new workout
    @IBAction func cancel()
    {
        delegate?.addWorkoutViewControllerDidCancel(self)
    }
    
    // Adds a new workout
    @IBAction func done()
    {
        // Create HUD view object
        let hudView = HUDView.hud(inView: view, animated: true)
        
        // If they're editing a workout, update it
        if let workout = workoutToEdit
        {
            workout.name = workoutName.text!
            workout.date = datePicker.date
            	
            if switchIsOn
            {
                workout.location = addressLabel.text!
            }
            
            // Save progress photo taken/chosen and show a notification
            saveWorkoutPhoto(workout: workout)
            hudView.text = "Updated"
            
            // Wait 1 second, then go back to the last screen
            afterDelay(1.0)
            {
                hudView.hide()
                self.delegate?.addWorkoutViewController(self, didFinishEditing: workout)
            }
        }
            
        // If they're adding a workout, save it
        else
        {
            let workout = Workout(name: workoutName.text!, date: datePicker.date)
            
            if switchIsOn
            {
                workout.location = addressLabel.text!
            }
            
            // Save progress photo taken/chosen and show a notification
            saveWorkoutPhoto(workout: workout)
            hudView.text = "Saved"
            
            // Wait 1 second, then go back to the last screen
            afterDelay(1.0)
            {
                hudView.hide()
                self.delegate?.addWorkoutViewController(self, didFinishAdding: workout)
            }
        }
    }
    
    // Listens for date picker events
    @IBAction func dateChanged(_ datePicker: UIDatePicker)
    {
        // Get the chosen date and call the function to update the label
        workoutDate = datePicker.date
        updateWorkoutDateLabel()
    }
    
    // Called when the "save location" switch is flipped
    @IBAction func getLocation()
    {
        // Store switchIsOn in the oposite state of what it was in
        // (starts out with the switch off when the app first runs)
        switchIsOn = !switchIsOn
        
        // If the switch is on, find the user's location
        if switchIsOn
        {
            // Check if location permission has been granted
            let authStatus = CLLocationManager.authorizationStatus()
            
            // Request permission
            if authStatus == .notDetermined
            {
                locationManager.requestWhenInUseAuthorization()
                return
            }
            
            // Show alert if permission is denied
            if authStatus == .denied || authStatus == .restricted
            {
                showLocationServicesDeniedAlert()
                return
            }
            
            // If location is being updated, then stop location manager
            if updatingLocation
            {
                stopLocationManager()
            }
                
            // Else reset properties and call the function to start the location manager
            else
            {
                location = nil
                lastLocationError = nil
                placemark = nil
                lastGeocodingError = nil
                startLocaionManager()
            }
            
            updateAddressLabel()
        }
    }
    
    // Function called by the timer after 60 seconds to stop the location manager
    @objc func didTimeOut()
    {
        // If no location has been found, stop
        // the location manager and log an error
        if location == nil
        {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
        }
    }
    
    // Executed after the view loads
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Disable large titles
        navigationItem.largeTitleDisplayMode = .never
        
        // If they select to edit a workout rather than add,
        // change the title at the top of the screen
        if let workout = workoutToEdit
        {
            title = "Edit \(workout.name)"
            workoutName.text = workout.name
            workoutDate = workout.date
            doneBarButton.isEnabled = true
            
            // If the workout has a photo, show it
            if workout.hasPhoto
            {
                if let theImage = workout.photoImage
                {
                    showPhoto(image: theImage)
                }
            }
            
            // If no location was saved with the saved workout
            // being loaded, display a blank and disable the switch
            if workout.location == ""
            {
                addressLabel.text = workout.location
                saveLocationSwitch.isOn = false
                switchIsOn = false
            }
            
            // If a location exists with the saved workout,
            // set the label to the location and turn the switch on
            else
            {
                addressLabel.text = workout.location
                saveLocationSwitch.isOn = true
                switchIsOn = true
            }
        }
        
        // Check if location permission has been granted
        let authStatus = CLLocationManager.authorizationStatus()
        
        // Request location permission
        if authStatus == .notDetermined
        {
            locationManager.requestWhenInUseAuthorization()
        }
        
        updateWorkoutDateLabel()
        updateAddressLabel()
    }
    
    // Sets focus on the text field when the view loads
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        workoutName.becomeFirstResponder()
    }
    
    // Calls ShowDatePicker() when the date table cell was tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Hide keyboard
        tableView.deselectRow(at: indexPath, animated: true)
        workoutName.resignFirstResponder()
        
        // Show/hide date picker if the proper cell was selected
        if indexPath.section == 1 && indexPath.row == 0
        {
            if !datePickerVisible
            {
                showDatePicker()
            }
                
            else
            {
                hideDatePicker()
            }
        }
        
        // Show photo chooser if the proper cell was selected
        else if indexPath.section == 2 && indexPath.row == 0
        {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
    
    // Makes the table cells that launch the date picker or photo chooser tappable
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        if indexPath.section == 1 && indexPath.row == 0
        {
            return indexPath
        }
            
        else if indexPath.section == 2 && indexPath.row == 0
        {
            return indexPath
        }
            
        else
        {
            return nil
        }
    }
    
    // Inserts the date picker cell into the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Checks if cellForRowAt is being called with the index path
        // for the date picker row If so, returns a new datePickerCell
        if indexPath.section == 1 && indexPath.row == 1
        {
            return datePickerCell
        }
            
        // For any index paths that are not the date picker cell, call
        // super to make sure other static cells still work as expected
        else
        {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    // Gives the cells their own unique height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        // If the cell is the date picker, set the height to 217
        if indexPath.section == 1 && indexPath.row == 1
        {
            return 217
        }
            
        // If not, pass it through to the super class to set the height
        else
        {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    // Returns the number of rows in second section of the table view (the one with the date picker)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // If the date picker is visible, then it thas 2 rows
        if section == 1 && datePickerVisible
        {
            return 2
        }
            
        // If not, then pass through to the original data source
        else
        {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    // Required to inform the data source for the a static table view of the cell at row 1 section 1
    // (the one with the date picker) because that cell isn't part of the table view's design in the storyboard
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int
    {
        var newIndexPath = indexPath
        
        if indexPath.section == 1 && indexPath.row == 1
        {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    // Called when the user enters or changes the text in the text field. If the text
    // field is not empty, then it enables the done button so the workout can be saved
    func textField(_ workoutName: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // Figure out what the new text will be after the user enters or changes the text in the text box
        let oldWorkoutNameText = workoutName.text!
        let workoutNameRange = Range(range, in: oldWorkoutNameText)!
        let newWorkoutNameText = oldWorkoutNameText.replacingCharacters(in: workoutNameRange, with: string)
        
        // If newWorkoutNameText is not empty then the done button is enabled, else it is disabled
        doneBarButton.isEnabled = !newWorkoutNameText.isEmpty
        return true
    }
    
    // Formats the date shown in the detail label
    func updateWorkoutDateLabel()
    {
        // Create formatter object to convert the date to text
        let formatter = DateFormatter()
        
        // Set date/time styles
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        
        // Set the label text
        workoutDateLabel.text = formatter.string(from: workoutDate)
    }
    
    // Shows the date picker
    func showDatePicker()
    {
        // Update visibility status
        datePickerVisible = true
        
        // Insert new row below the due date cell
        let indexPathDatePicker = IndexPath(row: 1, section: 1)
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        
        // Pass proper date to UIDatePicker component and set the label to
        // the tint color when the date picker is active
        datePicker.setDate(workoutDate, animated: false)
        workoutDateLabel.textColor = workoutDateLabel.tintColor
    }
    
    // Hides the date picker
    func hideDatePicker()
    {
        // If the date picker is visible, remove it and
        // set the label color back to the origional color
        if datePickerVisible
        {
            datePickerVisible = false
            let indexPathDatePicker = IndexPath(row: 1, section: 1)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            workoutDateLabel.textColor = UIColor.black
        }
    }
    
    // Converts a placemark into a nice and easy to read String
    func getAddress(from placemark: CLPlacemark) -> String
    {
        // Stores the address lines from the placemark
        var line1 = ""
        var line2 = ""
        
        // Append house number
        if let house = placemark.subThoroughfare
        {
            line1 += house + " "
        }
        
        // Append street name
        if let street = placemark.thoroughfare
        {
            line1 += street
        }
        
        // Append city name
        if let city = placemark.locality
        {
            line2 += city + ", "
        }
        
        // Append state
        if let state = placemark.administrativeArea
        {
            line2 += state + " "
        }
        
        // Append zip code
        if let zip = placemark.postalCode
        {
            line2 += zip
        }
        
        // Combine the 2 lines together and return them
        return line1 + "\n" + line2
    }
    
    // Prints an error message if there's an issue getting location data
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        if (error as NSError).code == CLError.locationUnknown.rawValue
        {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
        updateAddressLabel()
    }
    
    // Udates location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // Get the user's location
        let newLocation = locations.last!
        
        // Stores distance between the new and old locaton readings
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        
        // If the location value is too old (i.e. older than 5 seconds),
        // then it is a cached value, so we don't want it
        if newLocation.timestamp.timeIntervalSinceNow < -5
        {
            return
        }
        
        // If accuracy is less than 0, then the results are invalid
        if newLocation.horizontalAccuracy < 0
        {
            return
        }
        
        // Calculate the distance between new and old location readings
        if let location = location
        {
            distance = newLocation.distance(from: location)
        }
        
        // If location is null or the accuracy of the new location data is better
        // than the accuracy of the old location data, then we're happy
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy
        {
            // Store the new location data and remove any stored errors
            location = newLocation
            lastLocationError = nil
            
            // If the accuracy of the new location is equal to or better than
            // the desired accuracy, then we're done with the location manager
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy
            {
                stopLocationManager()
                
                // Force reverse geocoding for the final location reading, even
                // if it's already performing another geocoding request
                if distance > 0
                {
                    performingReverseGeocoding = false
                }
            }
            
            // Update the UI
            updateAddressLabel()
            
            // Make sure reverse geocoding isn't being done
            if !performingReverseGeocoding
            {
                // If not, set the property to true
                performingReverseGeocoding = true
                
                // Start reverse geocoding
                geocoder.reverseGeocodeLocation(newLocation, completionHandler:
                {
                    placemarks, error in
                    
                    self.lastGeocodingError = error
                        
                    // If there's mo errors and the unwrapped placemarks array
                    // is not empty, store the placemark
                    if error == nil, let place = placemarks, !place.isEmpty
                    {
                       self.placemark = place.last
                    }
                            
                    // If not, set placemark to null
                    else
                    {
                        self.placemark = nil
                    }
                        
                    // Set the property back to false and update UI labels
                    self.performingReverseGeocoding = false
                    self.updateAddressLabel()
                })
            }
                
            // If the coordinates are not significantly different from the previous
            // ones and it's been more than 10 seconds, then it's time to give up
            else if distance < 1
            {
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
                
                if timeInterval > 10
                {
                    stopLocationManager()
                    updateAddressLabel()
                }
            }
        }
    }
    
    // Starts the location manager
    func startLocaionManager()
    {
        // Check if location is enabled
        if CLLocationManager.locationServicesEnabled()
        {
            // If so, start the location manager and get the user's locaton
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            // Start timer and have it call didTimeOut() after 60 seconds
            timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                         selector: #selector(didTimeOut),
                                         userInfo: nil, repeats: false)
        }
    }
    
    // Stops the location manager in the event of an error
    func stopLocationManager()
    {
        if updatingLocation
        {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            // Cancel timer in the event stopLocationManager()
            // is called before the timer stops
            if let timer = timer
            {
                timer.invalidate()
            }
        }
    }
    
    // Shows an alert if location is off or permission is denied
    func showLocationServicesDeniedAlert()
    {
        // Create the alert and action, then add the action to the alert
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        // Show the alert
        present(alert, animated: true, completion: nil)
    }
    
    // Updates the address label next to the location switch
    func updateAddressLabel()
    {
        // If location has been successfully received, update the label
        if !updatingLocation
        {
            addressLabel.text = ""
            
            // Show the address if one was found for the placemark
            if let placemark = placemark
            {
                addressLabel.text = getAddress(from: placemark)
            }
                
            // Shown if reverse geocoding is still underway
            else if performingReverseGeocoding
            {
                addressLabel.text = "Searching for Address..."
            }
                
            // Shown if there was an error while reverse geocoding
            else if lastGeocodingError != nil
            {
                addressLabel.text = "Error Finding Address"
            }
                
            // Shown if no address was found for the location
            else
            {
                if let workout = workoutToEdit
                {
                    addressLabel.text = workout.location
                }
                
                else
                {
                    addressLabel.text = "No Address Found"
                }
            }
        }
            
        // If not, show them a message stating what's wrong
        else
        {
            addressLabel.text = ""
            
            // Stores the message to be shown
            let statusMessage: String
            
            // Decide what message to show the user
            if let error = lastLocationError as NSError?
            {
                // Error shown if location is disabled
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue
                {
                    statusMessage = "Location Services Disabled"
                }
                    
                    // Error shown if getting location fails for
                    // one of many possible reasons
                else
                {
                    statusMessage = "Error Getting Location"
                }
            }
                
            // Error to be shown if location services are disabled
            else if !CLLocationManager.locationServicesEnabled()
            {
                statusMessage = "Location Services Disabled"
            }
                
            // Message shown when the location is beting updated
            else if updatingLocation
            {
                statusMessage = "Searching..."
            }
            
            else
            {
                statusMessage = "Tap the switch to begin"
            }
            
            // Display the message
            addressLabel.text = statusMessage
        }
    }
    
    // Saves the progress photo taken/chosen by the user
    func saveWorkoutPhoto(workout: Workout)
    {
        if let image = image
        {
            // Get a new photo ID and assign it to the workout object's photoID property,
            // but only if it didn't already have one. If a photo existed, keep the same ID
            // and overwrite the existing photo
            if !workout.hasPhoto
            {
                workout.photoID = workout.nextPhotoID()
            }
            
            // Convert the image to JPEG format
            if let data = image.jpegData(compressionQuality: 0.5)
            {
                // Try to save the image
                do
                {
                    try data.write(to: workout.photoURL, options: .atomic)
                }
                    
                // Catch any errors
                catch
                {
                    print("Error writing file: \(error)")
                }
            }
        }
    }
    
    // Shows the image after it has been taken/chosen
    func showPhoto(image: UIImage)
    {
        imageView.image = image
        imageView.isHidden = false
        addPhotoLabel.text = ""
        imageHeight.constant = 260
        tableView.reloadData()
    }
}

extension AddWorkoutViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    // Chooses an existing photo from the gallery
    func choosePhotoFromLibrary()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Takes a new photo with the camera
    func takePhotoWithCamera()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Loads the chosen image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if let theImage = image
        {
            showPhoto(image: theImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // Cancels choosing an image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    // If the camera doesen't exist (like on a simulator), the photo gallery is automatically launched instead
    func pickPhoto()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            showPhotoMenu()
        }
            
        else
        {
            choosePhotoFromLibrary()
        }
    }
    
    // Shows options to take a pic with the camera or choose an existing image from the gallery
    func showPhotoMenu()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler:
        {
            _ in
            self.takePhotoWithCamera()
        })
        
        alert.addAction(actPhoto)
        
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler:
        {
            _ in
            self.choosePhotoFromLibrary()
        })
        
        alert.addAction(actLibrary)
        
        present(alert, animated: true, completion: nil)
    }
}

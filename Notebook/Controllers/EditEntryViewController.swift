//
//  EntryViewController.swift
//  Notebook
//
//  Created by Garrett Votaw on 4/26/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class EditEntryViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewHeightContstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintForTextView: NSLayoutConstraint!
    
    var location: String?
    var image: UIImage?
    var context: NSManagedObjectContext!
    var entry: Entry?
    let locationManager = LocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try locationManager.requestAuthorization()
        } catch {
            
        }
        locationManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        creationDateLabel.text = ""
        updateContstraints()
        guard let entry = entry else {
            locationManager.requestLocation()
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy — h:mma"
        let dateString = formatter.string(from: entry.creationDate)
        creationDateLabel.text = "Created: \(dateString)"
        titleTextField.text = entry.title
        textView.text = entry.text
        imageView.image = entry.image
        locationLabel.text = entry.location
        updateContstraints()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let info = notification.userInfo, let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let frame = keyboardFrame.cgRectValue
            bottomConstraintForTextView.constant = frame.size.height
            
            UIView.animate(withDuration: 0.8) { [unowned self] in
                self.view.layoutIfNeeded()
                self.imageView.isHidden = true
                self.imageViewHeightContstraint.constant = 0
            }
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        let photoController = UIImagePickerController()
        self.present(photoController, animated: true, completion: nil)
        photoController.delegate = self
    }
    
    @IBAction func donePushed(_ sender: UIBarButtonItem) {
        if entry?.title == titleTextField.text && entry?.text == textView.text && entry?.image == image {
            //no changes were made dismiss the view
            navigationController?.popViewController(animated: true)
        }
        guard let title = titleTextField.text, !title.isEmpty,
              let text = textView.text else {return}
        saveEntry(entry, title: title, text: text)
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func cancelPushed(_ sender: UIBarButtonItem) {
        guard let entry = entry else {
            if !titleTextField.text!.isEmpty || !textView.text.isEmpty{
                let alert = UIAlertController(title: "Delete Entry", message: "Would you like to delete this entry and go back?", preferredStyle: .actionSheet)
                let destructiveAction = UIAlertAction(title: "Delete Entry", style: .destructive) { [unowned self] action in
                    self.navigationController?.popViewController(animated: true)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(destructiveAction)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            } else {
                navigationController?.popViewController(animated: true)
            }
            return
        }
        if entry.title == titleTextField.text && entry.text == textView.text {
            //no changes were made dismiss the view
            navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Delete Changes", message: "Would you like to delete all changes and go back?", preferredStyle: .actionSheet)
            let destructiveAction = UIAlertAction(title: "Delete Changes", style: .destructive) { [unowned self] action in
                self.navigationController?.popViewController(animated: true)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(destructiveAction)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func saveEntry(_ entry: Entry?, title: String, text: String) {
        if let entry = entry {
            entry.title = title
            entry.text = text
            guard let image = image else {return}
            entry.photo = UIImageJPEGRepresentation(image, 1.0)
        } else {
            let _ = Entry.with(title: title, text: text, photo: image, location: location, in: context)
        }
        do {
            try context.saveChanges()
        } catch {
            Alert.presentAlert(with: self, title: "Changes Not Saved", text: "An error occured while trying to save changes.", type: .alert)
        }
    }
    
    func updateContstraints() {
        if imageView.image == nil {
            imageView.isHidden = true
            imageViewHeightContstraint.constant = 0
        } else if let _ = imageView.image {
            imageView.isHidden = false
            imageViewHeightContstraint.constant = 160
        }
    }
    
    
    
}

extension EditEntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.image = image
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
        updateContstraints()
    }
}


extension EditEntryViewController: LocationDelegate {
    
    
    func obtainedLocation(_ coordinate: CLLocation) {
        let decoder = CLGeocoder()
        decoder.reverseGeocodeLocation(coordinate) { [unowned self] placemarks, error in
            if let error = error as? CLError {
                switch error.code {
                case .network, .locationUnknown: Alert.presentAlert(with: self, title: "Error Obtaining Location", text: "We were unable to determine your location for this entry", type: .actionSheet)
                default: return
                }
                print(error)
            } else if let placemark = placemarks?.first {
                guard let city = placemark.locality, let state = placemark.administrativeArea, let address = placemark.name, let zip = placemark.postalCode else {return}
                let formattedLocation = "\(address) \(city), \(state) \(zip)"
                self.location = formattedLocation
                self.locationLabel.text = "Location: \(formattedLocation)"
            }
        }
    }
    
    func failedWithError(_ error: LocationError) {
        switch error {
        case .disallowedByUser: locationLabel.text = "Location Disallowed by User"
        case .locationUnavailable: Alert.presentAlert(with: self, title: "Error Obtaining Location", text: "We were unable to determine your location for this entry", type: .actionSheet)
        case .networkFailure: Alert.presentAlert(with: self, title: "Location Not Found", text: "We were unable to find your location due to poor connection", type: .actionSheet)
        }
    }
}











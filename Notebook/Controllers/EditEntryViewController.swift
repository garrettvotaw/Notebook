//
//  EntryViewController.swift
//  Notebook
//
//  Created by Garrett Votaw on 4/26/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit
import CoreData

class EditEntryViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    var image: UIImage?
    var context: NSManagedObjectContext!
    var entry: Entry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        titleTextField.text = entry?.title
        textView.text = entry?.text
    }
    @IBOutlet weak var bottomConstraintForTextView: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let info = notification.userInfo, let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let frame = keyboardFrame.cgRectValue
            bottomConstraintForTextView.constant = frame.size.height + 10
            
            UIView.animate(withDuration: 0.8) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        let photoController = UIImagePickerController()
        self.present(photoController, animated: true, completion: nil)
        photoController.delegate = self
    }
    
    @IBAction func donePushed(_ sender: UIBarButtonItem) {
        
        guard let title = titleTextField.text, !title.isEmpty,
              let text = textView.text else {return}
        if let entry = entry {
            entry.title = title
            entry.text = text
            entry.creationDate = Date() as NSDate
        } else {
            let entry = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: context) as! Entry
            entry.title = title
            entry.text = text
            entry.creationDate = Date() as NSDate
        }

        do {
            try context.saveChanges()
        } catch {
            print("Error occured while attempting to save changes!")
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func cancelPushed(_ sender: UIBarButtonItem) {
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

extension EditEntryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}

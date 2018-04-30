//
//  EntryTableView.swift
//  Notebook
//
//  Created by Garrett Votaw on 4/26/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit

class EntryTableView: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    var headerHeight: CGFloat = CGFloat.leastNormalMagnitude
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }

    @IBAction func cameraTapped(_ sender: Any) {
        let photoController = UIImagePickerController()
        self.present(photoController, animated: true, completion: nil)
        photoController.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = image
        
        return imageView
    }
    
    
    
    
}



extension EntryTableView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.image = image
        headerHeight = 190
        tableView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}

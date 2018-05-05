//
//  EntriesTableViewController.swift
//  Notebook
//
//  Created by Garrett Votaw on 4/26/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit
import CoreData

class EntriesTableViewController: UITableViewController {
    
    let context = CoreDataStack().managedObjectContext
    var indexOfSelectedItem: IndexPath?
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var fetchedResultsController : NSFetchedResultsController<Entry> = {
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("There was an error fetching the Entries!")
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else {return 0}
        return section.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as! EntryTableViewCell
        return configureCell(cell, at: indexPath)
    }
    
    private func configureCell(_ cell: EntryTableViewCell, at indexPath: IndexPath) -> EntryTableViewCell {
        let entry = fetchedResultsController.object(at: indexPath)
        cell.journalTextLabel.text = entry.text
        cell.titleLabel.text = entry.title
        guard let photoData = entry.photo else {return cell}
        cell.journalImageView.image = UIImage(data: photoData)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let entry = fetchedResultsController.object(at: indexPath)
            context.delete(entry)
            do {
                try context.saveChanges()
            } catch {
                print("Error occured while deleting entry!")
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    
    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexOfSelectedItem = indexPath
        performSegue(withIdentifier: "ShowDetail", sender: nil)
        searchController.dismiss(animated: true, completion: nil)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? EditEntryViewController else {return}
        nextVC.context = self.context
        if segue.identifier == "ShowDetail" {
            guard let indexPath = indexOfSelectedItem else {return}
            let entry = fetchedResultsController.object(at: indexPath)
            nextVC.entry = entry
        } else if segue.identifier == "NewEntry" {
            
        }
        
    }

}


extension EntriesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .move, .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension EntriesTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!
        
        if !text.isEmpty {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "text contains[cd] %@", text)
        } else {
            fetchedResultsController.fetchRequest.predicate = nil
            do {
                try fetchedResultsController.performFetch()
            } catch {
                Alert.presentAlert(with: self, title: "Error Fetching", text: "We were unable to retrieve your entries.", type: .alert)
            }
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            Alert.presentAlert(with: self, title: "Error Fetching", text: "We were unable to retrieve your entries.", type: .alert)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            Alert.presentAlert(with: self, title: "Error Fetching", text: "We were unable to retrieve your entries.", type: .alert)
        }
    }
}
















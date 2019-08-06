//
//  BrownLineTableViewController.swift
//  CTA Train Tracker
//
//  Created by Thomas Bart on 8/5/19.
//  Copyright © 2019 Thomas Bart. All rights reserved.
//

import UIKit

class BrownLineTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var stationsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let brownStations = ["Fullerton", "Clark/Lake", "Kimball", "Southport", "Diversey"]
    var filteredStations = [String]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredStations.count
        }
        return brownStations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "brown", for: indexPath)
        let station : String
        if searching {
            station = filteredStations[indexPath.row]
        } else {
            station = brownStations[indexPath.row]
        }
        cell.textLabel?.text = station
        return cell
    }
    
    func searchBar (_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            searching = false
            view.endEditing(true)
            stationsTableView.reloadData()
        } else {
            searching = true
            filteredStations = brownStations.filter({$0.lowercased().contains(searchText.lowercased())})
            stationsTableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let trainViewController = segue.destination as? TrainTableViewController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let requestedStation : String
                if searching {
                    requestedStation = filteredStations[indexPath.row]
                } else {
                    requestedStation = brownStations[indexPath.row]
                }
                trainViewController.requestedStation = requestedStation
            }
        }
    }
}

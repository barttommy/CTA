//
//  BrownLineTableViewController.swift
//  CTA Train Tracker
//
//  Created by Thomas Bart on 8/5/19.
//  Copyright © 2019 Thomas Bart. All rights reserved.
//

import UIKit

let brownStations = ["Fullerton", "Clark/Lake", "Kimball"]

class BrownLineTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brownStations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let station = brownStations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "brown", for: indexPath)
        cell.textLabel?.text = station
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let trainViewController = segue.destination as? TrainTableViewController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                trainViewController.requestedStation = brownStations[indexPath.row]
            }
        }
    }
}

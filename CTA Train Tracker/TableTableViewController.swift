/*
 CTA Train Tracker App
 Author: Thomas Bart (Created 5/4/19)
 Personal Exercise
     I used the following tutorials on JSON Parsing in Swift:
        1. https://www.youtube.com/watch?v=XZS-eeO9YoU
        2. https://benscheirman.com/2017/06/swift-json/
     CTA API:
        https://www.transitchicago.com/developers/traintracker/
     TODO:
        0. Develop prototype for Diversy (In progress)
            0.1. Fix minutes issue for < 1 minute
            0.2. Refresh button "loading" indicator?
            0.3. Incorporate stop / direction into table cell
                - Will have to rework train_data
            0.4. Fix cell ordering - has to do with the way data is stored and the indexing when cell is created
        1. Location services instead of hardcoded map id
        2. Work for all train services, not just brown and purple
 */

import UIKit

class TableTableViewController: UITableViewController {
    
    @IBOutlet var trainTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getTrainArrivalData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    struct Root : Decodable {
        struct StationData : Decodable {
            let eta : [Arrivals]
        }
        let ctatt : StationData
    }
    
    struct Arrivals : Decodable {
        let staNm  : String
        let rt     : String
        let destNm : String
        let arrT   : String
    }
    
    func getTrainArrivalData () {
        let apiKey = "73436616b5af4465bc65790aa9d4886c"
        // Pick station through another table view? List of stations and it will go with selected one?
        //let mapId = "40530" //diversy
        //let mapId = "40380" //Clark & Lake, blue, brown, green, orange, purple, pink
        let mapId = "41220" //fullerton
        let jsonURLString = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key="+apiKey+"&mapid="+mapId+"&=40530&outputType=JSON"
        guard let url = URL(string: jsonURLString) else { return }
        URLSession.shared.dataTask(with: url) {(data, response, err) in
            guard let data = data else { return }
            do {
                let arrivals = try JSONDecoder().decode(Root.self, from: data)
                for train in arrivals.ctatt.eta {
                    let type = self.getTrainType(line: train.rt, destination: train.destNm)
                    let eta = self.formatArrivalTime(time: train.arrT)
                    if type != .unknown {
                        let route = Route(type: type, direction: train.destNm, station: train.staNm, etas: [eta])
                        let index = self.routeCellIndex(for: route)
                        if index > -1 {
                            train_data[index].etas.append(eta)
                        } else {
                            train_data.append(route)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let jsonErr {
                print ("Error parsing JSON: ", jsonErr)
            }
        }.resume()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return train_data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        train_data.sort(by: {$0.type.rawValue < $1.type.rawValue})
        let route = train_data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: route.type.rawValue, for: indexPath)
        cell.textLabel?.text = route.station
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text? = "To: \(route.direction)\n"
        let length = route.etas.count - 1
        for i in 0..<length {
            cell.detailTextLabel?.text?.append("\(route.etas[i])\n")
        }
        cell.detailTextLabel?.text?.append(route.etas[length])
        return cell
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        train_data.removeAll()
        getTrainArrivalData()
        self.tableView.reloadData()
    }
    
    func routeCellIndex(for route: Route) -> Int {
        for i in 0..<train_data.count {
            if train_data[i].sharesRoute(with: route) {
                return i
            }
        }
        return -1
    }
    
    func getTrainType (line: String, destination: String) -> Type {
        var type : Type
        if line == "Brn" && destination == "Loop" {
            type = .brownLoop
        } else if line == "Brn" && destination == "Kimball" {
            type = .brownKimbal
        } else if line == "P" && destination == "Loop" {
            type = .purpleLoop
        } else if line == "P" && destination == "Linden" {
            type = .purpleLinden
        } else if line == "Red" && destination == "Howard" {
            type = .redHoward
        } else if line == "Red" && destination == "95th/Dan Ryan" {
            type = .red95th
        } else {
            type = .unknown
        }
        return type
    }
    
    // Might be worth writing this as an extension? For time difference part
    func formatArrivalTime (time: String) -> String {
        var eta = time
        if let index = time.firstIndex(of: "T") {
            let startIndex = time.index(after: index)
            let endIndex = time.index(startIndex, offsetBy: 4)
            let arrivalTime = String(time[startIndex...endIndex])
            let militaryFormat = DateFormatter()
            militaryFormat.dateFormat = "HH:mm"
            if let date = militaryFormat.date(from: arrivalTime) {
                let timeDifference = date.timeIntervalSinceNow
                let hours = floor(timeDifference / 60 / 60)
                let minutes = Int(floor((timeDifference - (hours * 60 * 60)) / 60))
                let standardFormat = DateFormatter()
                standardFormat.dateFormat = "h:mm"
                let expectedArrival = standardFormat.string(from: date)
                let timeRemaining : String
                if minutes == 59 || minutes == 0 {
                    timeRemaining = "Now"
                } else {
                    timeRemaining = "in \(minutes+1)m"
                }
                eta = "Arriving \(timeRemaining) (\(expectedArrival))"
            }
        }
        return eta
    }
    
    // MARK: - Navigation
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

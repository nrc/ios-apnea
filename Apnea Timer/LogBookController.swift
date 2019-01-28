//
//  LogBookController.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 8/05/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import UIKit

class LogBookController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var logTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logTable.delegate = self
        logTable.dataSource = self
        logTable.rowHeight = UITableView.automaticDimension
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.getDataManager().records.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogEntry", for: indexPath) as? LogTableCell else {
            fatalError("The dequeued cell is not an instance of LogTableCell.")
        }

        let datum = DataManager.getDataManager().records[indexPath.row]
        print(datum)
        cell.planName.text = datum.planName
        if let reps = datum.completedReps {
            cell.repsCount.text = String(reps)
        } else {
            cell.repsCount.text = "🏁"
        }
        
        let argsString = datum.args.map { "\($0.name): \($0.value)" }.joined(separator: ",\n")
        cell.args.text = argsString

        if datum.details.count == 0 {
            cell.details.isHidden = true
        } else {
            let detailsString = datum.details.map { "\($0.name): \($0.value)" }.joined(separator: ",\n")
            cell.detailsArgs.text = detailsString
        }
        cell.logTable = logTable

        return cell
    }
}

class LogTableCell: UITableViewCell {
    @IBOutlet weak var planName: UILabel!
    @IBOutlet weak var repsCount: UILabel!
    @IBOutlet weak var args: UILabel!
    @IBOutlet weak var details: UIButton!
    @IBOutlet weak var detailsArgs: UILabel!
    weak var logTable: UITableView?
    
    @IBAction func tapDetails(_ sender: UIButton) {
        detailsArgs.isHidden = !detailsArgs.isHidden
        logTable?.beginUpdates()
        logTable?.endUpdates()
    }
}

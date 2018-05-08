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
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogEntry", for: indexPath) as? LogTableCell else {
            fatalError("The dequeued cell is not an instance of LogTableCell.")
        }
        
        return cell
    }
}

class LogTableCell: UITableViewCell {
    
}

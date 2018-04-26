//
//  ConfigureController.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 22/04/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import UIKit

class ConfigureController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var planPicker: UIPickerView!
    @IBOutlet weak var argTable: UITableView!

    internal var descs: [PlanDesc] = []
    internal var curDesc = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        descs = planDescs()
        
        planPicker.delegate = self
        planPicker.dataSource = self
        argTable.delegate = self
        argTable.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem else {
            return
        }
        
        if (button === saveButton) {
            // TODO save plan
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return descs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: descs[row].name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        curDesc = row
        argTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return descs[curDesc].args.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigArg", for: indexPath) as? ConfigArgTableCell else {
            fatalError("The dequeued cell is not an instance of ConfigArgTableCell.")
        }
        cell.label.text = descs[curDesc].args[indexPath.row]
        // TODO should preserve the value if set, and use value from current time
        cell.input.text = String(descs[curDesc].defaults[indexPath.row])
        return cell
    }
}

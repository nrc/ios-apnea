//
//  ConfigureController.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 22/04/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import UIKit

class ConfigureController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var planPicker: UIPickerView!
    @IBOutlet weak var argTable: UITableView!

    internal var descs: [(PlanDesc, ConfigMemo)] = []
    internal var curDesc = 0
    
    internal var savedPlan: (Plan, ConfigMemo)? = nil
    var curMemo: ConfigMemo? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        descs = planDescs().map {  ($0, memo(fromDescDefaults: $0)) }
        
        planPicker.delegate = self
        planPicker.dataSource = self
        argTable.delegate = self
        argTable.dataSource = self
        
        if let memo = curMemo {
            // Look for the memo's id in the descs
            for i in 0..<descs.count {
                if descs[i].0.id == memo.plan {
                    curDesc = i
                    descs[i].1.args = memo.args
                    assert(memo.args.count == descs[i].0.args.count, "Saved args do not match args for description")
                    planPicker.selectRow(i, inComponent: 0, animated: false)
                    break;
                }
            }

            curMemo = nil
        }
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
        
        self.view.endEditing(false)

        if (button === saveButton) {
            let memo = descs[curDesc].1
            savedPlan = (descs[curDesc].0.make(args: memo.args), memo)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return descs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: descs[row].0.name, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
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
        return descs[curDesc].0.args.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigArg", for: indexPath) as? ConfigArgTableCell else {
            fatalError("The dequeued cell is not an instance of ConfigArgTableCell.")
        }
        cell.label.text = descs[curDesc].0.args[indexPath.row]

        cell.input.text = String(descs[curDesc].1.args[indexPath.row])
        let tag = curDesc * 10 + indexPath.row
        cell.input.tag = tag
        cell.incrButton.tag = tag
        cell.decrButton.tag = tag
        cell.input.delegate = self

        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let desc = textField.tag / 10
        let row = textField.tag % 10
        descs[desc].1.args[row] = Int(textField.text!)!
    }

    // The `-` `+` buttons
    @IBAction func decr(_ sender: UIButton) {
        incrOrDecr(sender, diff: -1)
    }
    @IBAction func incr(_ sender: UIButton) {
        incrOrDecr(sender, diff: 1)
    }
    func incrOrDecr(_ sender: UIButton, diff: Int) {
        let desc = sender.tag / 10
        let row = sender.tag % 10
        descs[desc].1.args[row] += diff
        if let cell = argTable.cellForRow(at: IndexPath(row: row, section: 0)) as? ConfigArgTableCell {
            var value = Int(cell.input.text!)!
            value += diff
            cell.input.text = String(value)
        }

    }
}

// 'Serialisation' of a configured plan
struct ConfigMemo {
    var plan: PlanId
    var args: [Int]
}

func memo(fromDescDefaults desc: PlanDesc) -> ConfigMemo {
    return ConfigMemo.init(plan: desc.id, args: desc.defaults)
}

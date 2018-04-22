//
//  ConfigureController.swift
//  Apnea Timer
//
//  Created by Nick Cameron on 22/04/18.
//  Copyright © 2018 Nick Cameron. All rights reserved.
//

import UIKit

class ConfigureController: UIViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
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
}

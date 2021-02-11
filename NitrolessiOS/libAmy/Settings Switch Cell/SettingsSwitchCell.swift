//
//  SettingsSwitchCell.swift
//  SignalReborn
//
//  Created by Amy While on 23/09/2020.
//  Copyright © 2020 Amy While. All rights reserved.
//

import UIKit

class SettingsSwitchCell: AmyCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var prefsSwitch: UISwitch!

    var data: SettingsSwitchData! {
        didSet {
            if UserDefaults.standard.object(forKey: data.defaultName) != nil {
                prefsSwitch.isOn = UserDefaults.standard.bool(forKey: data.defaultName)
            } else {
                prefsSwitch.isOn = data.defaultState
            }
            self.label.text = data.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func prefsSwitched(_ sender: Any) {
        UserDefaults.standard.setValue(prefsSwitch.isOn, forKey: data.defaultName)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: data.defaultName), object: nil)
    }
}

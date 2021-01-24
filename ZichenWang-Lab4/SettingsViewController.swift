//
//  SettingsViewController.swift
//  ZichenWang-Lab4
//
//  Created by 王梓辰 on 7/16/20.
//  Copyright © 2020 Zichen Wang. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var adultSwitch: UISwitch!
    @IBOutlet weak var language: UISegmentedControl!
    
    //Creative Portion of Settinngs View

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if UserDefaults.standard.object(forKey: "adult") == nil {
            UserDefaults.standard.set(false, forKey: "adult")
        }
        if UserDefaults.standard.object(forKey: "lang") == nil {
            UserDefaults.standard.setValue("en", forKey: "lang")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "adult"){
            adultSwitch.isOn = true
        }else{
            adultSwitch.isOn = false
        }
        switch UserDefaults.standard.string(forKey: "lang") {
        case "en":
            language.selectedSegmentIndex = 0
            break
        case "zh":
            language.selectedSegmentIndex = 1
            break
        case "ja":
            language.selectedSegmentIndex = 2
            break
        case "es":
            language.selectedSegmentIndex = 3
            break
        default:
            language.selectedSegmentIndex = 0
            break
        }
    }
    
    @IBAction func adultChanged(_ sender: Any) {
        let adult = UserDefaults.standard.bool(forKey: "adult")
        if adult == true{
            UserDefaults.standard.set(false, forKey: "adult")
        }
        else{
            UserDefaults.standard.set(true, forKey: "adult")
        }
    }
    
    @IBAction func languageChanged(_ sender: Any) {
        switch language.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set("en", forKey: "lang")
            break
        case 1:
            UserDefaults.standard.set("zh", forKey: "lang")
            break
        case 2:
            UserDefaults.standard.set("ja", forKey: "lang")
            break
        case 3:
            UserDefaults.standard.set("es", forKey: "lang")
            break
        default:
            break
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  PlayerNumberSelectorViewController.swift
//  LocoMotive
//
//  Created by Tolga Caner on 04/05/2017.
//  Copyright © 2017 Tolga Caner. All rights reserved.
//

import UIKit

class PlayerNumberSelectorViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    let pickerDataSource = [1, 2, 3, 4]
    weak var playerCountDelegate : PlayerCountSelectedDelegate!
    var selectedRow : Int!
    //MARK: Picker Data Source
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = String(pickerDataSource[row])
        return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        playerCountDelegate.playerCountSelected(count: pickerDataSource[row])
    }
    
    @IBAction func btnSelectAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

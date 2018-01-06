//
//  RepetitionsPickerComponent.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 06/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import ViewPresenter

class RepetitionsPickerComponent: VPComponent {

    @IBOutlet weak var day1: HexagonLabelView!
    @IBOutlet weak var day2: HexagonLabelView!
    @IBOutlet weak var day3: HexagonLabelView!
    @IBOutlet weak var day4: HexagonLabelView!
    @IBOutlet weak var day5: HexagonLabelView!
    @IBOutlet weak var day6: HexagonLabelView!
    @IBOutlet weak var day7: HexagonLabelView!
    
    override func desiredheight() -> CGFloat {
        return 80
    }
    
    convenience init(repetitions: String) {
        self.init(frame: CGRect.zero)
        commonInit()
        
        setRepetitions(rep: repetitions)
    }
    
    override open func commonInit() {
        xibSetup()

        day1.textType = .bigger
        day2.textType = .bigger
        day3.textType = .bigger
        day4.textType = .bigger
        day5.textType = .bigger
        day6.textType = .bigger
        day7.textType = .bigger
        
    }
    
    
    func setRepetitions(rep: String) {
        let a = Array(rep)
        day1.isSelected = a[0] == "1" ? true : false
        day2.isSelected = a[1] == "1" ? true : false
        day3.isSelected = a[2] == "1" ? true : false
        day4.isSelected = a[3] == "1" ? true : false
        day5.isSelected = a[4] == "1" ? true : false
        day6.isSelected = a[5] == "1" ? true : false
        day7.isSelected = a[6] == "1" ? true : false
    }
    
    func setRepetitions(rep: Int8) {
        day1.isSelected = rep & 0b01000000 == 0b01000000 ? true : false
        day2.isSelected = rep & 0b00100000 == 0b00100000 ? true : false
        day3.isSelected = rep & 0b00010000 == 0b00010000 ? true : false
        day4.isSelected = rep & 0b00001000 == 0b00001000 ? true : false
        day5.isSelected = rep & 0b00000100 == 0b00000100 ? true : false
        day6.isSelected = rep & 0b00000010 == 0b00000010 ? true : false
        day7.isSelected = rep & 0b00000001 == 0b00000001 ? true : false
    }
    
    func getRepetitions() -> String {
        var repetitions = ""
        repetitions += day1.isSelected ? "1" : "0"
        repetitions += day2.isSelected ? "1" : "0"
        repetitions += day3.isSelected ? "1" : "0"
        repetitions += day4.isSelected ? "1" : "0"
        repetitions += day5.isSelected ? "1" : "0"
        repetitions += day6.isSelected ? "1" : "0"
        repetitions += day7.isSelected ? "1" : "0"
        return repetitions
    }
    
    
}

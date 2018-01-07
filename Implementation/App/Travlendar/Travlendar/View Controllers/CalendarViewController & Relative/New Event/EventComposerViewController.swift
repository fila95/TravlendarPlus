//
//  EventComposerViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit
import RealmSwift

class EventComposerViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var saveCell = SaveCloseTableViewCell()
    var nameCell = TextViewTableViewCell()
    var addressCell = TextViewTableViewCell()
    var flexibleTimingCell = SwitchTableViewCell()
    
    var startDateCell = DateTableViewCell()
    var endDateCell = DateTableViewCell()
    var durationCell = DateTableViewCell()
    
    var calendarCell = SelectedCalendarTableViewCell()
    var repetitionsCell = RepetitionsTableViewCell()
    var allowedVehiclesCell = AllowedVehiclesTableViewCell()
    
    var creatingNew: Bool = true
    var currentEvent: Event = Event()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "EventComposerViewController", bundle: Bundle.main)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: "EventComposerViewController", bundle: Bundle.main)
        commonInit()
    }
    
    init() {
        super.init(nibName: "EventComposerViewController", bundle: Bundle.main)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func commonInit() {
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
        
        let realm = try! Realm()
        let cal = realm.objects(Calendars.self).sorted(byKeyPath: "name")
        //        print(cal)
        self.currentEvent.calendar_id = cal.first?.id ?? -1
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Tap to Dismiss
        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleTapToClose(tap:)))
        tgr.delegate = self
        self.view.addGestureRecognizer(tgr)
        
        self.contentView.alpha = 0.0
        self.contentView.transform = CGAffineTransform(translationX: 0, y: 300)
        self.contentView.layer.cornerRadius = 20
        self.contentView.layer.shadowColor = UIColor.init(hex: "B0B0B0").withAlphaComponent(0.5).cgColor
        self.contentView.layer.shadowRadius = 10
        self.contentView.layer.shadowOpacity = 1.0
        
        self.tableView.separatorStyle = .none
        
        self.registerCells()
        self.configureCells()
        self.refresh()
    }
    
    
    
    func configureCells() {
        saveCell = self.tableView.dequeueReusableCell(withIdentifier: SaveCloseTableViewCell.reuseId) as! SaveCloseTableViewCell
        nameCell = self.tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseId) as! TextViewTableViewCell
        addressCell = self.tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseId) as! TextViewTableViewCell
        
        flexibleTimingCell = self.tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseId) as! SwitchTableViewCell
        startDateCell = self.tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.reuseId) as! DateTableViewCell
        endDateCell = self.tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.reuseId) as! DateTableViewCell
        durationCell = self.tableView.dequeueReusableCell(withIdentifier: DateTableViewCell.reuseId) as! DateTableViewCell
        
        calendarCell = self.tableView.dequeueReusableCell(withIdentifier: SelectedCalendarTableViewCell.reuseId) as! SelectedCalendarTableViewCell
        repetitionsCell = self.tableView.dequeueReusableCell(withIdentifier: RepetitionsTableViewCell.reuseId) as! RepetitionsTableViewCell
        allowedVehiclesCell = self.tableView.dequeueReusableCell(withIdentifier: AllowedVehiclesTableViewCell.reuseId) as! AllowedVehiclesTableViewCell
        
        
        
        self.prepareSaveCloseHandlers(cell: self.saveCell)
        
        self.refreshNameCell()
        self.refreshAddressCell()
        self.refreshSwitchCell()
        self.refreshDateCells()
        
        self.refreshCalendarCell()
        self.refreshRepetitionsCell()
        
        self.refreshVehiclesCells()
    }
    
    func refreshNameCell() {
        self.nameCell.setImage(image: #imageLiteral(resourceName: "address_image"))
        self.nameCell.setText(text: self.currentEvent.title)
        self.nameCell.setPlaceholder(text: "Event Name")
    }
    
    func refreshAddressCell() {
        self.addressCell.setImage(image: #imageLiteral(resourceName: "position_image"))
        self.addressCell.setText(text: self.currentEvent.address)
        self.addressCell.setPlaceholder(text: "Address")
    }
    
    func refreshSwitchCell() {
        self.flexibleTimingCell.setTitle(text: "Flexible Timing:")
        self.flexibleTimingCell.setSwitchOn(on: currentEvent.duration > 0)
        self.flexibleTimingCell.accessoryType = .none
        self.prepareDurationSwitchHandler(cell: self.flexibleTimingCell)
    }
    
    func refreshDateCells() {
        self.startDateCell.setDate(date: currentEvent.start_time)
        self.startDateCell.setTitle(title: "Start:")
        
        self.endDateCell.setDate(date: currentEvent.end_time)
        self.endDateCell.setTitle(title: "End:")
        
        self.durationCell.setTitle(title: "Duration:")
        self.durationCell.setDuration(duration: currentEvent.duration)
    }
    
    func refreshCalendarCell() {
        self.currentEvent.relativeCalendar(completion: { (cal) in
            self.calendarCell.setCalendar(cal: cal)
        })
    }
    
    func refreshRepetitionsCell() {
        self.repetitionsCell.setTitle(text: "Repetitions:")
        self.repetitionsCell.setRepetitions(rep: self.currentEvent.repetitions)
    }
    
    func refreshVehiclesCells() {
        self.allowedVehiclesCell.setAllowedVehicles(rep: self.currentEvent.transports)
    }
    
    func setEvent(e: Event) {
        self.creatingNew = false
        self.currentEvent = e
        self.refresh()
    }
    
    
    func refresh() {
        if self.tableView != nil {
            self.tableView.reloadData()
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.08, options: .curveEaseInOut, animations: {
            self.contentView.transform = CGAffineTransform.identity
            self.contentView.alpha = 1.0
        }) { (complete) in
            
        }
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        if self.presentedViewController == nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.contentView.alpha = 0.0
                self.contentView.transform = CGAffineTransform(translationX: 0, y: 300)
            }) { (complete) in
                super.dismiss(animated: true, completion: completion)
            }
        }
        else {
            super.dismiss(animated: flag, completion: completion)
        }
        
    }
    
    
    
    // MARK: Cells
    
    private func registerCells() {
        self.tableView.register(HeaderCell.self, forCellReuseIdentifier: HeaderCell.reuseIdentifier)
        self.tableView.register(UINib.init(nibName: "HeaderCell", bundle: Bundle.main), forCellReuseIdentifier: HeaderCell.reuseIdentifier)
        
        self.tableView.register(SaveCloseTableViewCell.self, forCellReuseIdentifier: SaveCloseTableViewCell.reuseId)
        self.tableView.register(SaveCloseTableViewCell.nib!, forCellReuseIdentifier: SaveCloseTableViewCell.reuseId)
        
        self.tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.reuseId)
        self.tableView.register(TextViewTableViewCell.nib!, forCellReuseIdentifier: TextViewTableViewCell.reuseId)
        
        self.tableView.register(DateTableViewCell.self, forCellReuseIdentifier: DateTableViewCell.reuseId)
        self.tableView.register(DateTableViewCell.nib!, forCellReuseIdentifier: DateTableViewCell.reuseId)
        
        self.tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseId)
        self.tableView.register(SwitchTableViewCell.nib!, forCellReuseIdentifier: SwitchTableViewCell.reuseId)
        
        self.tableView.register(SelectedCalendarTableViewCell.self, forCellReuseIdentifier: SelectedCalendarTableViewCell.reuseId)
        self.tableView.register(SelectedCalendarTableViewCell.nib!, forCellReuseIdentifier: SelectedCalendarTableViewCell.reuseId)
        
        self.tableView.register(RepetitionsTableViewCell.self, forCellReuseIdentifier: RepetitionsTableViewCell.reuseId)
        self.tableView.register(RepetitionsTableViewCell.nib!, forCellReuseIdentifier: RepetitionsTableViewCell.reuseId)
        
        self.tableView.register(AllowedVehiclesTableViewCell.self, forCellReuseIdentifier: AllowedVehiclesTableViewCell.reuseId)
        self.tableView.register(AllowedVehiclesTableViewCell.nib!, forCellReuseIdentifier: AllowedVehiclesTableViewCell.reuseId)
    }
    

}

extension EventComposerViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let v = touch.view else {
            return true
        }
        
        if v == self.view {
            return true
        }
        
        return false
    }
    
}



extension EventComposerViewController {
    
    @objc func handleTapToClose(tap: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

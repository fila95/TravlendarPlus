//
//  EventComposerViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 04/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//

import UIKit

class EventComposerViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var creatingNew: Bool = true
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
    }
    
    func setEvent(e: Event) {
        self.creatingNew = false
        self.currentEvent = e
        self.refresh()
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
    }
    
    func refresh() {
        self.tableView.reloadData()
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
        
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.alpha = 0.0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: 300)
        }) { (complete) in
            super.dismiss(animated: true, completion: completion)
        }
    }
    
    
    
    // MARK: Cells
    private func register<T: Reusable>(reuseCell: T) {
        self.tableView.register(T.self, forCellReuseIdentifier: T.reuseId)
        self.tableView.register(T.nib!, forCellReuseIdentifier: T.reuseId)
    }
    
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

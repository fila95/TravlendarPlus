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

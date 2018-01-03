//
//  CalendarViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 09/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit
import DatePicker
import ViewPresenter


class CalendarViewController: UIViewController {
    
    let picker = CalendarPickerView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var verticalMargin: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(AddNewCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: AddNewCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib.init(nibName: "AddNewCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: AddNewCollectionViewCell.reuseIdentifier)

        
        // Date Picker View
        self.view.addSubview(picker)
        picker.setDateChangeHandler { (newDate) in
            print(newDate)
        }
        
        // Make sure picker does not overlap CollectionView
        picker.setResizeHandler { (animated) in
            self.refreshScrollInsets(animated: animated)
        }
        
        
        
    }
    
    private func refreshScrollInsets(animated: Bool) {
        let newHeight = self.picker.dragging ? self.picker.frame.size.height : self.picker.type.height() + self.view.safeAreaInsets.top
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.08, options: .curveEaseInOut, animations: {
                self.verticalMargin.constant = newHeight
            }, completion: { (complete) in
                
            })
        }
        else {
            self.verticalMargin.constant = newHeight
        }
    }
    
    private func refresh() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Make sure picker does not overlap CollectionView
        self.refreshScrollInsets(animated: false)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.picker.setPickerType(type: .closed)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        print("Add new Event")
    }
}


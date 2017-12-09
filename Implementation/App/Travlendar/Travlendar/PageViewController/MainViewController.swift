//
//  MainViewController.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 09/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pagingContainerView: GFPageControl!
    
    
    var mainPageViewController: MainPageViewController? {
        didSet {
            mainPageViewController?.mainDelegate = self
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //        pagingContainerView.backgroundColor = UIColor.whiteColor()
        pagingContainerView.components = [
            GFPageComponentView(component: GFPageComponent(image: UIImage(named: "calendar_icon_little")!, color: UIColor(red:1.00, green:0.22, blue:0.28, alpha:1.00))),
            GFPageComponentView(component: GFPageComponent(image: UIImage(named: "map_icon_little")!, color: UIColor(red:0.00, green:0.53, blue:0.81, alpha:1.00))),
            GFPageComponentView(component: GFPageComponent(image: UIImage(named: "settings_icon_little")!, color: UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.00)))
        ]
        pagingContainerView.currentPage = 0
        pagingContainerView.backgroundColor = UIColor.white
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        
        
    }
    
    
    @IBAction func didTapOnPager(_ sender: GFPageControl) {
        //        scrollToPage(sender.currentPage)
        mainPageViewController?.scrollToViewController(index: sender.currentPage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mainPage = segue.destination as? MainPageViewController {
            self.mainPageViewController = mainPage
        }
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}

extension MainViewController: MainPageViewControllerDelegate {
    
    func mainPageViewController(_ mainPageViewController: MainPageViewController, didUpdatePageCount count: Int) {
        
    }
    func mainPageViewController(_ mainPageViewController: MainPageViewController, didUpdatePageIndex index: Int) {
        pagingContainerView.currentPage = index
    }
    
}


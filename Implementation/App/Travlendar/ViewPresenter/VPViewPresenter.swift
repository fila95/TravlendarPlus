//
//  VpViewPresenter.swift
//  ViewPresenter
//
//  Created by Giovanni Filaferro on 28/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

public class VPViewPresenter: UIViewController {
    
    public var views: [VPView] = [VPView]() {
        didSet {
            resetViews()
        }
    }
    
    private var scrollView: UIScrollView = UIScrollView()
    private var dimmingView: UIView = UIView()
    
    convenience public init(views: [VPView]) {
        self.init(nibName: nil, bundle: nil)
        self.views = views
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        self.view.addSubview(self.dimmingView)
        
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = true
        self.scrollView.backgroundColor = UIColor.clear
        self.view.addSubview(self.scrollView)
        
        resetViews()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.dimmingView.frame = self.view.bounds
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentSize = CGSize.init(width: self.view.bounds.width * CGFloat(views.count), height: self.view.bounds.height)
        self.scrollView.contentInset = self.additionalSafeAreaInsets
        
        var sum: CGFloat = 0
        let padding: CGFloat = 20
        for v in views {
            v.frame = CGRect.init(x: padding + sum, y: self.scrollView.frame.size.height - padding - v.intrinsicContentSize.height, width: self.scrollView.frame.size.width - padding*2, height: v.intrinsicContentSize.height)
            sum += self.scrollView.frame.size.width
        }
    }
    
    
    public func addView(view: VPView) {
        self.views.append(view)
        resetViews()
    }
    
    private func resetViews() {
        
        for v in self.scrollView.subviews {
            v.removeFromSuperview()
        }
        
        
        for v in views {
            v.presenter = self
            self.scrollView.addSubview(v)
        }
        
        self.view.setNeedsLayout()
    }
    
}

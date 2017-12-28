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
    
    public var scrollEnabled: Bool = false {
        didSet {
            self.scrollView.isScrollEnabled = scrollEnabled
        }
    }
    
    private var scrollView: UIScrollView = UIScrollView()
    private var dimmingView: UIView = UIView()
    private var dragging: Bool = false
    
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
        self.scrollView.isScrollEnabled = self.scrollEnabled
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        
        resetViews()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.dimmingView.frame = self.view.bounds
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentSize = CGSize.init(width: self.view.bounds.width * CGFloat(views.count), height: self.view.bounds.height)
        
        var sum: CGFloat = 0
        let paddingX: CGFloat = self.scrollView.frame.size.width < 400 ? 20 : (self.scrollView.frame.size.width - 320) / 2
        let paddingY: CGFloat = 20
//        let w = self.scrollView.frame.size.width > 400 ? 300 : self.scrollView.frame.size.width - padding*2
        for v in views {
            v.frame = CGRect.init(x: paddingX + sum, y: self.scrollView.frame.size.height - paddingY - v.intrinsicContentSize.height - self.view.safeAreaInsets.bottom, width: self.scrollView.frame.size.width - paddingX*2, height: v.intrinsicContentSize.height)
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

extension VPViewPresenter: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if dragging {
            
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragging = true
    }
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        dragging = false
    }
    
}

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
    private var currentPage: Int = 0
    private var keyboardHeight: CGFloat = 0.0
    private let paddingY: CGFloat = 20
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit()
    }
    
    convenience public init(views: [VPView]) {
        self.init(nibName: nil, bundle: nil)
        self.views = views
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overCurrentContext
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.dimmingView.isUserInteractionEnabled = true
        self.view.addSubview(self.dimmingView)
        
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = true
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.isScrollEnabled = self.scrollEnabled
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.delegate = self
        self.scrollView.transform = CGAffineTransform.init(translationX: 0, y: 400)
        self.view.addSubview(self.scrollView)
        
        let tg = UITapGestureRecognizer(target: self, action: #selector(VPViewPresenter.dismissEntirely))
        tg.delegate = self
        tg.cancelsTouchesInView = false
        self.scrollView.addGestureRecognizer(tg)
        
        resetViews()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.08, options: .curveEaseInOut, animations: {
            self.scrollView.transform = CGAffineTransform.identity
            self.scrollView.alpha = 1.0
        }) { (complete) in
            
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
        
        self.dimmingView.frame = self.view.bounds
        
        self.scrollView.frame = self.view.bounds
        self.scrollView.contentSize = CGSize.init(width: self.view.bounds.width * CGFloat(views.count), height: self.view.bounds.height)
        
        refreshViewFrames()
    }
    
    private func refreshViewFrames() {
        var sum: CGFloat = 0
        let paddingX: CGFloat = self.scrollView.frame.size.width < 400 ? 20 : (self.scrollView.frame.size.width - 320) / 2
        
        //        let w = self.scrollView.frame.size.width > 400 ? 300 : self.scrollView.frame.size.width - padding*2
        for v in views {
            v.frame = CGRect.init(x: paddingX + sum, y: self.scrollView.frame.size.height - paddingY - v.intrinsicContentSize.height - self.view.safeAreaInsets.bottom, width: self.scrollView.frame.size.width - paddingX*2, height: v.intrinsicContentSize.height)
            if v == views[currentPage] {
                v.frame.origin.y -= self.keyboardHeight / 2
            }
            sum += self.scrollView.frame.size.width
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let visiblePage: Int = Int(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width)
        coordinator.animate(alongsideTransition: { (context) in
            self.scrollView.contentOffset = CGPoint.init(x: CGFloat(visiblePage) * self.scrollView.bounds.size.width, y: self.scrollView.contentOffset.y)
        }) { (completion) in
            
        }
    }
    
    
    public func addView(view: VPView) {
        self.views.append(view)
        self.resetViews()
    }
    
    @discardableResult
    public func showPage(page: Int) -> Bool {
        self.view.endEditing(true)
        
        guard page < self.views.count else {
            return false
        }
        
        self.scrollView.setContentOffset(CGPoint.init(x: self.scrollView.frame.size.width * CGFloat(page), y: self.scrollView.contentOffset.y), animated: true)
        return true
    }
    
    public func nextPage(dismissIfLast: Bool = false) {
        if !showPage(page: currentPage+1) {
            if dismissIfLast {
                self.dismissEntirely()
            }
        }
    }
    
    public func previousPage() {
        showPage(page: currentPage-1)
    }
    
    @objc private func dismissEntirely() {
        self.dismiss(animated: true, completion: {
            
        })
    }
    
    // MARK: Private
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
        self.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragging = true
    }
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        dragging = false
    }
    
}

extension VPViewPresenter: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let v = touch.view else {
            return true
        }
        
        if v == self.scrollView {
            return true
        }
        
        return false
    }
    
}

extension VPViewPresenter {
    
    @objc func keyboardWillAppear(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardSize.height
            
            UIView.animate(withDuration: 0.3, animations: {
                self.refreshViewFrames()
            })
            
            
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
        
        
    }
    
    @objc func keyboardWillDisappear() {
        self.keyboardHeight = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.refreshViewFrames()
        })
    }
    
}

//
//  VPLoadingButtonComponent.swift
//  ViewPresenter
//
//  Created by Giovanni Filaferro on 02/01/2018.
//  Copyright © 2018 Giovanni Filaferro. All rights reserved.
//


public class VPLoadingButtonComponent: VPButtonComponent {
    
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    open var isLoading: Bool = false {
        didSet {
            refreshLoading()
        }
    }
    
    override public func commonInit() {
        super.commonInit()
        
        activityIndicator.activityIndicatorViewStyle = .white
        self.addSubview(activityIndicator)
        
        refreshLoading()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.activityIndicator.center = self.center
    }
    
    private func refreshLoading() {
        if !isLoading {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            self.titleLabel.isHidden = false
        }
        else {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
            self.titleLabel.isHidden = true
        }
    }
    
    
    
    
}


//
//  VPComponent.swift
//  ViewPresenter
//
//  Created by Giovanni Filaferro on 28/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//


public class VPComponent: UIView {
    
    weak public var presenter: VPViewPresenter?
    
    public func desiredheight() -> CGFloat  {
        return 20
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public func commonInit() {
        
    }
    
}

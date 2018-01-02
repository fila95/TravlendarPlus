//
//  VPComponent.swift
//  ViewPresenter
//
//  Created by Giovanni Filaferro on 28/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//


open class VPComponent: UIView {
    
    weak open var presenter: VPViewPresenter?
    
    open func desiredheight() -> CGFloat  {
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
    
    open func commonInit() {
        
    }
    
}

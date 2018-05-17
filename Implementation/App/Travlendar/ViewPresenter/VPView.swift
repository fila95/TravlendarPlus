//
//  VPView.swift
//  ViewPresenter
//
//  Created by Giovanni Filaferro on 28/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

public class VPView: UIView {
    
    override public var intrinsicContentSize: CGSize {
        get {
            return CGSize.init(width: UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale - 20, height: calculatedHeight())
        }
    }
    
    public var padding: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var titleText: String = "Label" {
        didSet {
            self.titleLabel.text = titleText
        }
    }
    
    public var components: [VPComponent] = [VPComponent]() {
        didSet {
            refreshComponents()
        }
    }
    
    weak public var presenter: VPViewPresenter? {
        didSet {
            for c in components {
                c.presenter = self.presenter
            }
        }
    }
    
    private var titleLabel: UILabel = UILabel()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience public init(title: String, components: [VPComponent]? = nil) {
        self.init(frame: CGRect.zero)
        
        defer {
            self.titleText = title
            
            if components != nil {
                self.components = components!
            }
            
        }
        
    }
    
    private func calculatedHeight() -> CGFloat {
        if components.count > 0 {
            var h: CGFloat = 70
            for c in components {
                h += padding
                h += c.desiredheight()
            }
            h += padding
            return h
        }
        return 100
    }
    
    private func commonInit() {
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 20
        
        self.titleLabel.font = UIFont.init(name: "AvenirNext-Bold", size: 30)
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.textAlignment = .center
        self.titleLabel.text = self.titleText
        self.addSubview(titleLabel)
        
        self.frame = CGRect.init(origin: CGPoint.zero, size: intrinsicContentSize)
    }
    
    override public func layoutSubviews() {
//        super.layoutSubviews()
        
        var prev: CGFloat = 0
        self.titleLabel.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 70)
        prev = 70 + padding
        
        for c in components {
            c.frame = CGRect.init(x: 20, y: prev, width: self.frame.size.width - 40, height: c.desiredheight())
            prev += c.desiredheight() + padding
        }
        
    }
    
    
    // MARK: Layout
    public func addComponent(component: VPComponent) {
        components.append(component)
        refreshComponents()
    }
    
    private func refreshComponents() {
        for v in self.subviews {
            v.removeFromSuperview()
        }
        
        self.addSubview(titleLabel)
        for c in components {
            c.presenter = self.presenter
            self.addSubview(c)
        }
        self.setNeedsLayout()
    }
    
    
    
}

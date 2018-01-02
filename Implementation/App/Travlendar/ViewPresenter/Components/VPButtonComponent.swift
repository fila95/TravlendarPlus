//
//  VPButtonComponent.swift
//  ViewPresenter
//
//  Created by Giovanni Filaferro on 28/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//


public class VPButtonComponent: VPComponent {
    
    
    public enum ButtonType {
        case strong
        case light
    }
    
    public var type: ButtonType = ButtonType.strong {
        didSet {
            resetAppearance()
        }
    }
    
    var text: String = "Label" {
        didSet {
            self.titleLabel.text = text
        }
    }
    
    private var tapHandler: ((_ sender: VPButtonComponent) -> Void)?
    internal var titleLabel: UILabel = UILabel()
    
    override public func desiredheight() -> CGFloat {
        return 50
    }
    
    convenience public init(type: ButtonType, text: String? = nil, tapHandler: ((_ sender: VPButtonComponent) -> Void)? = nil) {
        self.init(frame: CGRect.zero)
        self.type = type
        self.tapHandler = tapHandler
        
        if text != nil {
            self.text = text!
        }
        
        commonInit()
    }
    
    override public func commonInit() {
        self.titleLabel.text = text
        self.titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        
        let gr = UILongPressGestureRecognizer.init(target: self, action: #selector(VPButtonComponent.tap(tap:)))
        gr.minimumPressDuration = 0.0
        self.addGestureRecognizer(gr)
        resetAppearance()
    }
    
    private func resetAppearance() {
        self.layer.cornerRadius = 18
        
        self.titleLabel.text = self.text
        
        
        switch type {
        case .strong:
            self.backgroundColor = UIColor.application
            self.titleLabel.textColor = UIColor.white
            self.titleLabel.font = UIFont.fonts.AvenirNext(type: .Medium, size: 18)
        default:
            self.backgroundColor = UIColor.clear
            self.titleLabel.textColor = UIColor.gray
            self.titleLabel.font = UIFont.fonts.AvenirNext(type: .Medium, size: 14)
        }
        
    }
    
    override public func layoutSubviews() {
        self.titleLabel.frame = self.bounds
    }
    
    
    @objc private func tap(tap: UILongPressGestureRecognizer) {
        switch tap.state {
        case .began:
            switch type {
                
                case .strong:
                    self.backgroundColor = self.backgroundColor?.lighter(by: 30)
                    break
                case .light:
                    self.titleLabel.textColor = self.titleLabel.textColor?.lighter(by: 30)
                break
                

            }
            
        
            
            
            break
        case .changed:
            break
        case.ended:
            resetAppearance()
            tapHandler?(self)
            break
        default:
            resetAppearance()
            
        }
    }
    
}

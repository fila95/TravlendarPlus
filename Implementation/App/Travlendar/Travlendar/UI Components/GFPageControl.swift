//
//  GFPageControl.swift
//  Travlendar
//
//  Created by Giovanni Filaferro on 06/12/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import UIKit

class GFPageControl: UIControl {
    
    // MARK: Public Variables
    var components: [GFPageComponentView] = [GFPageComponentView]() {
        didSet {
            self.configure()
        }
    }
    
    var currentPage: Int = 0 {
        willSet {
            if newValue != currentPage {
                self.components[currentPage].selected = false
            }
            
        }
        didSet {
            if self.components.count > currentPage {
                if self.components[currentPage].selected == false {
                    self.components[currentPage].selected = true
                }
            }
        }
    }
    
    // MARK: Private
    private var componentSize: CGFloat = 20
    private var componentsPadding: CGFloat = 12
    
    private var componentsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.clear
        self.addSubview(componentsContainerView)
        self.configure()
    }
    
    func configure() {
        for v in self.componentsContainerView.subviews {
            v.removeFromSuperview()
        }
        
        let count: CGFloat = CGFloat(components.count)
        if count != 0 {
            
            var i: CGFloat = 0.0
            
            for component in components {
                component.frame = CGRect(x: i*componentSize + i*componentsPadding, y: 0, width: componentSize, height:componentSize)
                component.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.itemTapped(sender:))))
                componentsContainerView.addSubview(component)
                i += 1
            }
            
            updateContainerFrame()
        }
    }
    
    @objc
    func itemTapped(sender: UIGestureRecognizer) {
        if let view = sender.view as? GFPageComponentView {
            if let index = components.index(of: view) {
                self.currentPage = index
                sendActions(for: .valueChanged)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateContainerFrame()
    }
    
    func updateContainerFrame() {
        let count: CGFloat = CGFloat(components.count)
        if count != 0 {
            let totalW = count * componentSize + (count-1)*componentsPadding
            componentsContainerView.frame = CGRect(x: (self.frame.size.width-totalW)/2, y: (self.frame.size.height - componentSize)/2, width: totalW, height: componentSize)
        }
    }
    
}

class GFPageComponentView: UIView {
    
    var component: GFPageComponent! {
        didSet {
            self.selectedImageView.image = self.autofillsImage ? self.filledImageFromSource(source: self.component.image, withColor: self.component.color) : self.component.image
            self.unselectedImageView.image = self.circularImage(color: self.component.color, size: 12)
        }
    }
    var autofillsImage: Bool = false
    
    private var selectedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .center
        iv.backgroundColor = UIColor.clear
        iv.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        iv.alpha = 0.0
        return iv
    }()
    
    private var unselectedImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .center
        iv.backgroundColor = UIColor.clear
        iv.alpha = 1.0
        return iv
    }()
    
    var selected: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.35) {
                if self.selected {
                    self.selectedImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.selectedImageView.alpha = 1.0
                    
                    self.unselectedImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    self.unselectedImageView.alpha = 0.0
                }
                else {
                    self.selectedImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.selectedImageView.alpha = 0.0
                    
                    self.unselectedImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self.unselectedImageView.alpha = 1.0
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.component = GFPageComponent(image: UIImage(), color: UIColor.white)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.component = GFPageComponent(image: UIImage(), color: UIColor.white)
        commonInit()
    }
    
    convenience init(component: GFPageComponent) {
        self.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.component = component
        commonInit()
    }
    
    func commonInit() {
        self.unselectedImageView.frame = self.bounds
        self.unselectedImageView.image = circularImage(color: self.component.color, size: 12)
        self.addSubview(self.unselectedImageView)
        
        
        self.selectedImageView.frame = self.bounds
        self.selectedImageView.image = self.autofillsImage ? self.filledImageFromSource(source: self.component.image, withColor: self.component.color) : self.component.image
        self.addSubview(self.selectedImageView)
    }
    
    
    // HELPERS
    private func circularImage(color: UIColor, size: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: size, height: size)
        view.layer.cornerRadius = size/2
        view.layer.borderWidth = 1.5
        view.layer.borderColor = color.cgColor
        view.layer.render(in: ctx!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    private func filledImageFromSource(source: UIImage, withColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(source.size, false, UIScreen.main.scale)
        
        // get a reference to that context we created
        let context = UIGraphicsGetCurrentContext()!
        
        // set the fill color
        color.setFill()
        
        // translate/flip the graphics context (for transforming from CG* coords to UI* coords
        context.translateBy(x: 0, y: source.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.setBlendMode(CGBlendMode.colorBurn)
        let rect: CGRect = CGRect(x: 0, y: 0, width: source.size.width, height: source.size.height)
        context.draw(source.cgImage!, in: rect)
        
        context.setBlendMode(.sourceIn)
        context.addRect(rect)
        context.drawPath(using: .fill)
        
        // generate a new UIImage from the graphics context we drew onto
        let coloredImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //return the color-burned image
        return coloredImg
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

struct GFPageComponent {
    var image: UIImage!
    var color: UIColor!
    
    init(image: UIImage, color: UIColor) {
        self.image = image
        self.color = color
    }
    
}

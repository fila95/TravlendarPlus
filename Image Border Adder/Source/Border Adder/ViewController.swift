//
//  ViewController.swift
//  Border Adder
//
//  Created by Giovanni Filaferro on 25/10/2017.
//  Copyright © 2017 Giovanni Filaferro. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    
    let w: CGFloat = 20
    let h: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.showsResizeIndicator    = true
        panel.showsHiddenFiles        = false
        panel.canChooseDirectories    = true
        panel.canCreateDirectories    = true
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = ["png"]
        
        if panel.runModal() == NSApplication.ModalResponse.OK {
            let result = panel.urls
            print(result)
            
            for url in result {
                if url.isFileURL {
                    let img = NSImage.init(contentsOf: url)!
                    if img.isValid {
                        
                        let fullRect = NSRect.init(x: 0, y: 0, width: img.size.width + w, height: img.size.height + h)
                        let imageRect = NSRect.init(x: w/2, y: h/2, width: img.size.width, height: img.size.height)
                        //                    let intermediate = NSRect.init(x: w/4, y: h/4, width: img.size.width + w/4, height: img.size.height + h/4)
                        
                        var rect: CGRect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
                        let imageRef = img.cgImage(forProposedRect: &rect, context: nil, hints: nil)
                        
                        guard let context = CGContext(data: nil,
                                                      width: Int(fullRect.size.width),
                                                      height: Int(fullRect.size.height),
                                                      bitsPerComponent: 8,
                                                      bytesPerRow: 4 * Int(fullRect.size.width),
                                                      space: CGColorSpaceCreateDeviceRGB(),
                                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else {
                                                        print("ctx....")
                                                        continue
                                                        
                        }
                        
                        context.setFillColor(NSColor(hue:0.00, saturation:0.00, brightness:0.84, alpha:1.00).cgColor)
                        context.setStrokeColor(NSColor.black.cgColor)
                        
                        let path = CGPath.init(roundedRect: fullRect, cornerWidth: 10, cornerHeight: 10, transform: nil)
                        
                        context.addPath(path)
                        context.fillPath()
                        
                        //                    context.setFillColor(NSColor.white.cgColor)
                        //                    context.fill(intermediate)
                        
                        context.draw(imageRef!, in: imageRect)
                        
                        guard let imageNew = context.makeImage() else {continue}
                        context.flush()
                        
                        let imagerep = NSBitmapImageRep.init(cgImage: imageNew)
                        let data = imagerep.representation(using: .png, properties: [:])
                        
                        let paths = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
                        var string = paths[0] + "/Wireframe/"
                        try? FileManager.default.createDirectory(atPath: string, withIntermediateDirectories: true, attributes: nil)
                        string += url.lastPathComponent.dropLast(7).replacingOccurrences(of: " ", with: "") + "_wired@3x.png"
                        print(string)
                        do {
                            try data?.write(to: URL(fileURLWithPath: string))
                        }
                        catch let error {
                            print(error)
                        }
                        
                    }
                    
                }
                
            }
        }
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        
    }


}


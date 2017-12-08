//
//  TestController.swift
//  Blur
//
//  Created by xiandong wang on 9/21/17.
//  Copyright © 2017 xiandong wang. All rights reserved.
//

import FontAwesome_swift
import Firebase

class TestController: UIViewController {
    
    let sendButton : UIButton = {
        let img = UIImage.fontAwesomeIcon(name: .telegram, textColor: PRIMARY_COLOR, size: CGSize(width: 60, height: 60))
        let bt = UIButton(type: .system)
//        bt.backgroundColor = .green
        bt.setImage(img.withRenderingMode(.alwaysOriginal), for: UIControlState())
        bt.addTarget(self, action: #selector(handleMove), for: .touchUpInside)
        return bt
    }()
    
    let badgeView : UIView = {
        let bv = UIView()
        bv.backgroundColor = .red
        return bv
    }()
    
    func handleMove() {
        UIView.animate(withDuration: 1.0) {
            self.view.bounds.origin.x += 10
            self.view.bounds.origin.y += 10
        }
        
        print(view.frame)
        print(view.bounds)
        
        print(badgeView.frame)
        print(badgeView.bounds)
    }
    
    override func viewDidLoad() {
        let m = mosaicImage(image: #imageLiteral(resourceName: "jjj"))
        
        //let mView = KKMosaicView(frame: self.view.bounds)
//        mView.surfaceImage = #imageLiteral(resourceName: "jjj")
//        
//        mView.image = m
//        
//        view.addSubview(mView)

    }
    
    func mosaicImage(image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(10, forKey: kCIInputScaleKey)
        let outImage = filter?.value(forKey: kCIOutputImageKey) as! CIImage
        let ctx = CIContext(options: nil)
        let cgImage = ctx.createCGImage(outImage, from: outImage.extent)
        let showImage = UIImage(cgImage: cgImage!)
        return showImage
    }

    
    
}

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
    
    var originalScrollView: UIScrollView = UIScrollView()
    let originalImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        let img = UIImage.fontAwesomeIcon(name: .exclamationCircle, textColor: YELLOW_COLOR, size: CGSize(width: 1000, height: 1000))
        iv.image = img
        return iv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalScrollView = UIScrollView(frame: view.bounds)
        originalScrollView.backgroundColor = .white
        originalScrollView.contentSize = originalImageView.bounds.size
        originalScrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        originalScrollView.addSubview(originalImageView)
        view.addSubview(originalScrollView)
        originalScrollView.delegate = self
        originalScrollView.clipsToBounds = false
        
        refreshImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshImageView()
    }
    
    func resetImageViewFrame() {
        var size: CGSize = originalImageView.frame.size
        if let imageSize = originalImageView.image?.size  {
            size = imageSize
        }
        if size.width > 0 && size.height > 0 {
            let ratio: CGFloat = min(originalScrollView.frame.size.width / size.width, originalScrollView.frame.size.height / size.height)
            let W = ratio * size.width * originalScrollView.zoomScale
            let H = ratio * size.height * originalScrollView.zoomScale
            originalImageView.frame = CGRect(x: max(0, (originalScrollView.width - W) / 2), y: max(0, (originalScrollView.height - H) / 2), width: W, height: H)
        }
    }

    func resetZoomScaleWithAnimated(animated:Bool) {
        var wR = originalScrollView.frame.size.width / originalImageView.frame.size.width
        var hR = originalScrollView.frame.size.height / originalImageView.frame.size.height
        
        let scale: CGFloat = 1
        if let img = originalImageView.image {
            wR = max(wR, img.size.width / (scale * originalScrollView.frame.size.width))
            hR = max(hR, img.size.height / (scale * originalScrollView.frame.size.height))
        }
        
        originalScrollView.contentSize = originalImageView.frame.size
        originalScrollView.minimumZoomScale = 1
        originalScrollView.maximumZoomScale = max(max(wR, hR), 1)
        
        originalScrollView.setZoomScale(originalScrollView.minimumZoomScale, animated: animated)
    }
    
    func refreshImageView() {
        
        
        self.resetImageViewFrame()
        self.resetZoomScaleWithAnimated(animated: false)
    }
}

extension TestController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.originalImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let Ws = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right
        let Hs = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let W = originalImageView.frame.size.width
        let H = originalImageView.frame.size.height
        
        var rct = originalImageView.frame
        rct.origin.x = max((Ws - W) / 2, 0)
        rct.origin.y = max((Hs - H) / 2, 0)
        originalImageView.frame = rct
    }
}

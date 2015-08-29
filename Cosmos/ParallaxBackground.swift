//
//  ParallaxBackground.swift
//  Cosmos
//
//  Created by travis on 2015-08-26.
//  Copyright © 2015 C4. All rights reserved.
//

import C4

class ParallaxBackground : C4CanvasController {
    var speeds : [CGFloat] = [0.08,0.0,0.10,0.12,0.15,1.0,0.8,1.0]
    lazy var scrollviews = [InfiniteScrollView]()
    let signCount : CGFloat = 12.0
    lazy var gapBetweenSigns : CGFloat = 10.0
    var scrollviewOffsetContext = 0
    
    override func setup() {
        canvas.backgroundColor = cosmosbkgd
        
        scrollviews.append(createBackgroundStars(0, imageName: "0Star", starCount: 20))
        scrollviews.append(createBackgroundStars(1, imageName: "1Vignette", starCount: 0))
        scrollviews.append(createBackgroundStars(2, imageName: "2Star", starCount: 20))
        scrollviews.append(createBackgroundStars(3, imageName: "3Star", starCount: 20))
        scrollviews.append(createBackgroundStars(4, imageName: "4Star", starCount: 20))
        
        for sv in scrollviews {
            canvas.add(sv)
        }
        
        if let topLayer = scrollviews.last {
            topLayer.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &scrollviewOffsetContext)
        }
    }
    
    func createBackgroundStars(index: Int, imageName: String, starCount: Int) -> InfiniteScrollView {
        let sv = InfiniteScrollView(frame: view.frame)
        let frameSize = sv.frame.width * speeds[index]
        let singleSignContentSize = frameSize * gapBetweenSigns
        sv.contentSize = CGSizeMake(singleSignContentSize * signCount + CGFloat(canvas.width), 1.0)

        for currentFrame in 0..<Int(signCount) {
            let dx = Double(singleSignContentSize) * Double(currentFrame)
            for _ in 0..<starCount {
                let x = dx + random01() * Double(singleSignContentSize)
                let y = random01() * canvas.height
                var pt = C4Point(x, y)
                let img = C4Image(imageName)
                img.center = pt
                sv.add(img)
                if currentFrame == 0 {
                    pt.x += Double(signCount * singleSignContentSize)
                    let img = C4Image(imageName)
                    img.center = pt
                    sv.add(img)
                }
            }
        }
        return sv
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &scrollviewOffsetContext {
            let sv = object as! InfiniteScrollView
            let offset = sv.contentOffset
            
            for i in 0..<scrollviews.count-1 {
                let layer = scrollviews[i]
                layer.contentOffset = CGPointMake(offset.x * speeds[i], 0.0)
            }
        }
    }
}
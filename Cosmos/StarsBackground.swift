//
//  StarsBackground.swift
//  Cosmos
//
//  Created by travis on 2015-10-19.
//  Copyright © 2015 C4. All rights reserved.
//

import C4
import UIKit

public class StarsBackground : InfiniteScrollView {
    
    convenience public init(frame: CGRect, imageName: String, starCount: Int, speed: CGFloat) {
        self.init(frame: frame)
        //Calculates the frame size for the view
        let frameSize = frame.width * speed
        //Creates empty scrollview to return
        clipsToBounds = false
        //Calculates size of single sign and its content (including gap to next sign)
        let singleSignContentSize = frameSize * gapBetweenSigns
        let width = frame.size.width
        let count = CGFloat(AstrologicalSignProvider.sharedInstance.order.count)
        
        //sets the contents size to signCount * single size, adds canvas.width to account for overlap to hide snap
        contentSize = CGSizeMake(singleSignContentSize * count + width, 1.0)
        
        //for every frame
        for currentFrame in 0..<Int(count) {
            //calculate the current offset
            let dx = Double(singleSignContentSize) * Double(currentFrame)
            //then for the number of specified stars we need
            for _ in 0..<starCount {
                //create an x position based on current offset
                let x = dx + random01() * Double(singleSignContentSize)
                //create a random y position
                let y = random01() * Double(frame.size.height)
                //create a point
                var pt = C4Point(x, y)
                //create an image using the specified name
                let img = C4Image(imageName)!
                //center the image to the random point
                img.center = pt
                //add the image to the canvas
                add(img)
                //if the image falls within the first view's frame (e.g. 0 < x < 320)
                if pt.x < Double(width) {
                    //shift x by the entire content size
                    pt.x += Double(count * singleSignContentSize)
                    //create a new image
                    let img = C4Image(imageName)!
                    //center it
                    img.center = pt
                    //add it
                    add(img)
                }
            }
        }
    }
}

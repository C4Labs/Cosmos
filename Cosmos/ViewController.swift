//
//  ViewController.swift
//  Cosmos
//
//  Created by travis on 2015-08-06.
//  Copyright © 2015 C4. All rights reserved.
//

import UIKit
import C4

class ViewController: C4CanvasController {
    //creates an empty variable array to which we'll add layers
    var layers = [InfiniteScrollView]()

    override func setup() {
        //loops the code while the number of layers in our array is less than 10
        repeat {
            //creates a layer whose frame is the same as the canvas
            let layer = InfiniteScrollView(frame: view.frame)
            //sets the content size for each layer, keeping 0 for height to prevent vertical scrolling
            layer.contentSize = CGSizeMake(layer.frame.size.width * 10, 0)
            //add the layer to the canvas and to the array
            canvas.add(layer)
            layers.append(layer)

            //instead of center position, I simply add 10 * 15 stars per layer
            let starCount = layers.count * 15
            //loop until there starCount stars in the layer
            for _ in 0..<starCount {
                //create an image for the star
                let img = C4Image("sampleStar")
                //allow it to scale proportionately
                img.constrainsProportions = true
                //scale the width of the image
                img.width *= 0.1 * Double(layers.count+1)
                //center it at a random point in the layer
                img.center = C4Point(Double(layer.contentSize.width)*random01(),canvas.height*random01())
                //add it to the layer
                layer.add(img)
            }
        } while layers.count < 10

        //grabs the topmost layer
        if let top = layers.last {
            //creates a variable context
            var c = 0
            //adds the WorkSpace as an observer of the top layer's contentOffset
            top.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: &c)
        }
    }

    //overrides the default observe value method
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        //iterates through all the layers, stopping 1 before the top layer
        for i in 0..<layers.count-1 {
            //grabs the current layer
            let layer = self.layers[i]
            //creates a mod value based on the layer's position (layer 0 = 0.1, layer 1 = 0.2, ...)
            let mod = 0.1 * CGFloat(i+1)
            //grabs the x value of the top layer's content offset
            if let x = layers.last?.contentOffset.x {
                //sets the content offset of the current layer by multiplying x by mod
                layer.contentOffset = CGPointMake(x*mod,0)
            }
        }
    }
}
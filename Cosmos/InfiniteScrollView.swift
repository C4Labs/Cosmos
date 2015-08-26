// Copyright © 2015 C4
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import UIKit
import Foundation

class InfiniteScrollView: UIScrollView {
    override func layoutSubviews() {
        super.layoutSubviews()

        //grab the current content offset (top-left corner)
        var curr = contentOffset
        //if the x value is less than zero
        if curr.x < 0 {
            //update x to the end of the scrollview
            curr.x = contentSize.width - frame.width
        }
        //if the x value is greater than the width - frame width
        //(i.e. when the top-right point goes beyond contentSize.width)
        else if curr.x >= contentSize.width - frame.width {
            //update x to the beginning of the scrollview
            curr.x = 0
        }

        //if the value of y is less than zero
        if curr.y < 0 {
            //update x to the end of the scrollview
            curr.y = contentSize.height - frame.height
        }
        //if the y value is greater than the height - frame height
        //(i.e. when the top-right point goes beyond contentSize.width)
        else if curr.y >= contentSize.height - frame.height {
            //update x to the beginning of the scrollview
            curr.y = 0
        }
        contentOffset = curr
    }
}
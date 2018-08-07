/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import UIKit

public typealias PhotoVideoMessageCollectionViewCellStyleProtocol = PhotoVideoBubbleViewStyleProtocol

public final class PhotoVideoMessageCollectionViewCell: BaseMessageCollectionViewCell<PhotoVideoBubbleView> {

    static func sizingCell() -> PhotoVideoMessageCollectionViewCell {
        let cell = PhotoVideoMessageCollectionViewCell(frame: CGRect.zero)
        cell.viewContext = .sizing
        return cell
    }

    public override func createBubbleView() -> PhotoVideoBubbleView {
        return PhotoVideoBubbleView()
    }

    override public var viewContext: ViewContext {
        didSet {
            self.bubbleView.viewContext = self.viewContext
        }
    }

    public var photoVideoMessageViewModel: PhotoVideoMessageViewModelProtocol! {
        didSet {
            self.messageViewModel = self.photoVideoMessageViewModel
            self.bubbleView.photoVideoMessageViewModel = self.photoVideoMessageViewModel
        }
    }

    public var photoVideoMessageStyle: PhotoVideoMessageCollectionViewCellStyleProtocol! {
        didSet {
            self.bubbleView.photoVideoMessageStyle = self.photoVideoMessageStyle
        }
    }

    public override func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> Void)?) {
        super.performBatchUpdates({ () -> Void in
            self.bubbleView.performBatchUpdates(updateClosure, animated: false, completion: nil)
        }, animated: animated, completion: completion)
    }
}

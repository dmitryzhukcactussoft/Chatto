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

public protocol PhotoVideoBubbleViewStyleProtocol {
    func maskingImage(viewModel: PhotoVideoMessageViewModelProtocol) -> UIImage
    func borderImage(viewModel: PhotoVideoMessageViewModelProtocol) -> UIImage?
    func placeholderBackgroundImage(viewModel: PhotoVideoMessageViewModelProtocol) -> UIImage
    func placeholderIconImage(viewModel: PhotoVideoMessageViewModelProtocol) -> UIImage
    func placeholderIconTintColor(viewModel: PhotoVideoMessageViewModelProtocol) -> UIColor
    func tailWidth(viewModel: PhotoVideoMessageViewModelProtocol) -> CGFloat
    func bubbleSize(viewModel: PhotoVideoMessageViewModelProtocol) -> CGSize
    func progressIndicatorColor(viewModel: PhotoVideoMessageViewModelProtocol) -> UIColor
    func overlayColor(viewModel: PhotoVideoMessageViewModelProtocol) -> UIColor?
}

open class PhotoVideoBubbleView: UIView, MaximumLayoutWidthSpecificable, BackgroundSizingQueryable {

    public var viewContext: ViewContext = .normal
    public var animationDuration: CFTimeInterval = 0.33
    public var preferredMaxLayoutWidth: CGFloat = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.autoresizesSubviews = false
        self.addSubview(self.imageView)
        self.addSubview(self.placeholderIconView)
        self.addSubview(self.progressIndicatorView)
    }

    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoresizingMask = UIViewAutoresizing()
        imageView.clipsToBounds = true
        imageView.autoresizesSubviews = false
        imageView.autoresizingMask = UIViewAutoresizing()
        imageView.contentMode = .scaleAspectFill
        imageView.addSubview(self.borderView)
        return imageView
    }()

    private lazy var borderView = UIImageView()

    private lazy var overlayView: UIView = {
        let view = UIView()
        return view
    }()

    public private(set) var progressIndicatorView: CircleProgressIndicatorView = {
        return CircleProgressIndicatorView(size: CGSize(width: 33, height: 33))
    }()

    private var placeholderIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoresizingMask = UIViewAutoresizing()
        return imageView
    }()

    public var photoVideoMessageViewModel: PhotoVideoMessageViewModelProtocol! {
        didSet {
            self.updateViews()
        }
    }

    public var photoVideoMessageStyle: PhotoVideoBubbleViewStyleProtocol! {
        didSet {
            self.updateViews()
        }
    }

    public private(set) var isUpdating: Bool = false
    public func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> Void)?) {
        self.isUpdating = true
        let updateAndRefreshViews = {
            updateClosure()
            self.isUpdating = false
            self.updateViews()
            if animated {
                self.layoutIfNeeded()
            }
        }
        if animated {
            UIView.animate(withDuration: self.animationDuration, animations: updateAndRefreshViews, completion: { (_) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }

    open func updateViews() {
        if self.viewContext == .sizing { return }
        if isUpdating { return }
        guard self.photoVideoMessageViewModel != nil, self.photoVideoMessageStyle != nil else { return }

        self.updateProgressIndicator()
        self.updateImages()
        self.setNeedsLayout()
    }

    private func updateProgressIndicator() {
        let transferStatus = self.photoVideoMessageViewModel.transferStatus.value
        let transferProgress = self.photoVideoMessageViewModel.transferProgress.value
        self.progressIndicatorView.isHidden = [TransferStatus.idle, TransferStatus.success, TransferStatus.failed].contains(self.photoVideoMessageViewModel.transferStatus.value)
        self.progressIndicatorView.progressLineColor = self.photoVideoMessageStyle.progressIndicatorColor(viewModel: self.photoVideoMessageViewModel)
        self.progressIndicatorView.progressLineWidth = 1
        self.progressIndicatorView.setProgress(CGFloat(transferProgress))

        switch transferStatus {
        case .idle, .success, .failed:

            break
        case .transfering:
            switch transferProgress {
            case 0:
                if self.progressIndicatorView.progressStatus != .starting { self.progressIndicatorView.progressStatus = .starting }
            case 1:
                if self.progressIndicatorView.progressStatus != .completed { self.progressIndicatorView.progressStatus = .completed }
            default:
                if self.progressIndicatorView.progressStatus != .inProgress { self.progressIndicatorView.progressStatus = .inProgress }
            }
        }
    }

    private func updateImages() {
        self.placeholderIconView.image = self.photoVideoMessageStyle.placeholderIconImage(viewModel: self.photoVideoMessageViewModel)
        self.placeholderIconView.tintColor = self.photoVideoMessageStyle.placeholderIconTintColor(viewModel: self.photoVideoMessageViewModel)

        if let image = self.photoVideoMessageViewModel.image.value {
            self.imageView.image = image
            self.placeholderIconView.isHidden = true
        } else {
            self.imageView.image = self.photoVideoMessageStyle.placeholderBackgroundImage(viewModel: self.photoVideoMessageViewModel)
            self.placeholderIconView.isHidden = self.photoVideoMessageViewModel.transferStatus.value != .failed
        }

        if let overlayColor = self.photoVideoMessageStyle.overlayColor(viewModel: self.photoVideoMessageViewModel) {
            self.overlayView.backgroundColor = overlayColor
            self.overlayView.alpha = 1
            if self.overlayView.superview == nil {
                self.imageView.addSubview(self.overlayView)
            }
        } else {
            self.overlayView.alpha = 0
        }
        self.borderView.image = self.photoVideoMessageStyle.borderImage(viewModel: photoVideoMessageViewModel)
        self.imageView.layer.mask = UIImageView(image: self.photoVideoMessageStyle.maskingImage(viewModel: self.photoVideoMessageViewModel)).layer
    }

    // MARK: Layout

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.calculateTextBubbleLayout(maximumWidth: size.width).size
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let layout = self.calculateTextBubbleLayout(maximumWidth: self.preferredMaxLayoutWidth)
        self.progressIndicatorView.center = layout.visualCenter
        self.placeholderIconView.center = layout.visualCenter
        self.placeholderIconView.bounds = CGRect(origin: .zero, size: layout.placeholderFrame.size)
        self.imageView.bma_rect = layout.photoVideoFrame
        self.imageView.layer.mask?.frame = self.imageView.layer.bounds
        self.overlayView.bma_rect = self.imageView.bounds
        self.borderView.bma_rect = self.imageView.bounds
    }

    private func calculateTextBubbleLayout(maximumWidth: CGFloat) -> PhotoVideoBubbleLayoutModel {
        let layoutContext = PhotoVideoBubbleLayoutModel.LayoutContext(photoVideoMessageViewModel: self.photoVideoMessageViewModel, style: self.photoVideoMessageStyle, containerWidth: maximumWidth)
        let layoutModel = PhotoVideoBubbleLayoutModel(layoutContext: layoutContext)
        layoutModel.calculateLayout()
        return layoutModel
    }

    open var canCalculateSizeInBackground: Bool {
        return true
    }

}

private class PhotoVideoBubbleLayoutModel {
    var photoVideoFrame: CGRect = .zero
    var placeholderFrame: CGRect = .zero
    var visualCenter: CGPoint = .zero // Because image is cropped a few points on the side of the tail, the apparent center will be a bit shifted
    var size: CGSize = .zero

    struct LayoutContext {
        let photoVideoSize: CGSize
        let placeholderSize: CGSize
        let preferredMaxLayoutWidth: CGFloat
        let isIncoming: Bool
        let tailWidth: CGFloat

        init(photoVideoSize: CGSize,
             placeholderSize: CGSize,
             tailWidth: CGFloat,
             isIncoming: Bool,
             preferredMaxLayoutWidth width: CGFloat) {
            self.photoVideoSize = photoVideoSize
            self.placeholderSize = placeholderSize
            self.tailWidth = tailWidth
            self.isIncoming = isIncoming
            self.preferredMaxLayoutWidth = width
        }

        init(photoVideoMessageViewModel model: PhotoVideoMessageViewModelProtocol,
             style: PhotoVideoBubbleViewStyleProtocol,
             containerWidth width: CGFloat) {
            self.init(photoVideoSize: style.bubbleSize(viewModel: model),
                      placeholderSize: style.placeholderIconImage(viewModel: model).size,
                      tailWidth: style.tailWidth(viewModel: model),
                      isIncoming: model.isIncoming,
                      preferredMaxLayoutWidth: width)
        }
    }

    let layoutContext: LayoutContext
    init(layoutContext: LayoutContext) {
        self.layoutContext = layoutContext
    }

    func calculateLayout() {
        let photoVideoSize = self.layoutContext.photoVideoSize
        self.photoVideoFrame = CGRect(origin: .zero, size: photoVideoSize)
        self.placeholderFrame = CGRect(origin: .zero, size: self.layoutContext.placeholderSize)
        let offsetX: CGFloat = 0.5 * self.layoutContext.tailWidth * (self.layoutContext.isIncoming ? 1.0 : -1.0)
        self.visualCenter = self.photoVideoFrame.bma_center.bma_offsetBy(dx: offsetX, dy: 0)
        self.size = photoVideoSize
    }
}

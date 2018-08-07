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

import XCTest
@testable import ChattoAdditions

class PhotoVideoMessagePresenterTests: XCTestCase, UICollectionViewDataSource {

    var presenter: PhotoVideoMessagePresenter<PhotoVideoMessageViewModelDefaultBuilder<PhotoVideoMessageModel<MessageModel>>, PhotoVideoMessageTestHandler>!
    let decorationAttributes = ChatItemDecorationAttributes(bottomMargin: 0, canShowTail: false, canShowAvatar: false, canShowFailedIcon: true)
    let testImage = UIImage()
    override func setUp() {
        super.setUp()
        let viewModelBuilder = PhotoVideoMessageViewModelDefaultBuilder<PhotoVideoMessageModel<MessageModel>>()
        let sizingCell = PhotoVIDEOMessageCollectionViewCell.sizingCell()
        let photoVideoStyle = PhotoVideoMessageCollectionViewCellDefaultStyle()
        let baseStyle = BaseMessageCollectionViewCellDefaultStyle()
        let messageModel = MessageModel(uid: "uid", senderId: "senderId", type: "photo-message", isIncoming: true, date: NSDate() as Date, status: .success)
        let photoVideoMessageModel = PhotoVideoMessageModel(messageModel: messageModel, imageSize: CGSize(width: 30, height: 30), image: self.testImage)
        self.presenter = PhotoVideoMessagePresenter(messageModel: photoVideoMessageModel, viewModelBuilder: viewModelBuilder, interactionHandler: PhotoVideoMessageTestHandler(), sizingCell: sizingCell, baseCellStyle: baseStyle, photoVideoCellStyle: photoVideoStyle)
    }

    func testThat_heightForCelReturnsPositiveHeight() {
        let height = self.presenter.heightForCell(maximumWidth: 320, decorationAttributes: self.decorationAttributes)
        XCTAssertTrue(height > 0)
    }

    func testThat_CellIsConfigured() {
        let cell = PhotoMessageCollectionViewCell(frame: CGRect.zero)
        self.presenter.configureCell(cell, decorationAttributes: self.decorationAttributes)
        XCTAssertEqual(self.testImage, cell.bubbleView.photoMessageViewModel.image.value)
    }

    func testThat_CanCalculateHeightInBackground() {
        XCTAssertTrue(self.presenter.canCalculateHeightInBackground)
    }

    func testThat_RegistersAndDequeuesCells() {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        PhotoVideoMessagePresenter<PhotoVideoMessageViewModelDefaultBuilder<PhotoVideoMessageModel<MessageModel>>, PhotoVideoMessageTestHandler>.registerCells(collectionView)
        collectionView.dataSource = self
        collectionView.reloadData()
        XCTAssertNotNil(self.presenter.dequeueCell(collectionView: collectionView, indexPath: IndexPath(item: 0, section: 0)))
        collectionView.dataSource = nil
    }

    // MARK: Helpers

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.presenter.dequeueCell(collectionView: collectionView, indexPath: indexPath as IndexPath)
    }
}

class PhotoVideoMessageTestHandler: BaseMessageInteractionHandlerProtocol {
    typealias ViewModelT = PhotoMessageViewModel<PhotoMessageModel<MessageModel>>

    var didHandleTapOnFailIcon = false
    func userDidTapOnFailIcon(viewModel: ViewModelT, failIconView: UIView) {
        self.didHandleTapOnFailIcon = true
    }

    var didHandleTapOnAvatar = false
    func userDidTapOnAvatar(viewModel: ViewModelT) {
        self.didHandleTapOnAvatar = true
    }

    var didHandleTapOnBubble = false
    func userDidTapOnBubble(viewModel: ViewModelT) {
        self.didHandleTapOnBubble = true
    }

    var didHandleBeginLongPressOnBubble = false
    func userDidBeginLongPressOnBubble(viewModel: ViewModelT) {
        self.didHandleBeginLongPressOnBubble = true
    }

    var didHandleEndLongPressOnBubble = false
    func userDidEndLongPressOnBubble(viewModel: ViewModelT) {
        self.didHandleEndLongPressOnBubble = true
    }

    func userDidSelectMessage(viewModel: ViewModelT) {
    }

    func userDidDeselectMessage(viewModel: ViewModelT) {
    }
}

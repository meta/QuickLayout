/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import FBServerSnapshotTestCase
import QuickLayoutBridge
import QuickLayoutBridgeTestUsage

@MainActor
final class QuickLayoutMacroServerSnapshotTests: FBServerSnapshotTestCase {

  private let width: CGFloat = 320

  private let shortContent = MacroSnapshotFeedContent(
    actionText: "Action",
    posterName: "Poster Name",
    posterHeadline: "Poster Headline",
    posterComment: "Poster Comment",
    contentTitle: "Content Title",
    actorComment: "Actor Comment"
  )

  private func snapshotFeedItem(contentSizeCategory: UIContentSizeCategory) {
    let view = MacroSnapshotFeedItemView()
    view.setContent(shortContent)
    view.setFont(UIFont.preferredFont(forTextStyle: .body, compatibleWith: UITraitCollection(preferredContentSizeCategory: contentSizeCategory)))
    takeSnapshot(of: view, in: .proposed(CGSize(width: width, height: .infinity)))
  }

  func testFeedItemShortText() {
    let view = MacroSnapshotFeedItemView()
    view.setContent(shortContent)
    takeSnapshot(of: view, in: .proposed(CGSize(width: width, height: .infinity)))
  }

  func testFeedItemRightToLeft() {
    let view = MacroSnapshotFeedItemView()
    view.semanticContentAttribute = .forceRightToLeft
    view.setContent(shortContent)
    takeSnapshot(of: view, in: .proposed(CGSize(width: width, height: .infinity)))
  }

  func testFeedItemDynamicTypeExtraSmall() {
    snapshotFeedItem(contentSizeCategory: .extraSmall)
  }

  func testFeedItemDynamicTypeExtraExtraExtraLarge() {
    snapshotFeedItem(contentSizeCategory: .extraExtraExtraLarge)
  }

  func testFeedItemDynamicTypeAccessibilityLarge() {
    snapshotFeedItem(contentSizeCategory: .accessibilityLarge)
  }

  func testFeedItemLongText() {
    let view = MacroSnapshotFeedItemView()
    view.setContent(
      MacroSnapshotFeedContent(
        actionText: "Action Nulla non sem et tortor euismod ornare. Duis blandit porta. End!!!",
        posterName: "Poster Name Aenean nec consectetur massa. Pellentesque id rhoncus metus. End!!!",
        posterHeadline: "Poster Headline Integer pulvinar mollis ipsum, vel condimentum velit efficitur id. End!!!",
        posterComment: "Poster Comment Cras vulputate justo arcu, ac varius nunc tempus suscipit. End!!!",
        contentTitle: "Content Title Nulla sed iaculis libero. End!!!",
        actorComment: "Actor Comment Suspendisse eget posuere tortor. Pellentesque et mi mauris. Orci varius. End!!!"
      )
    )
    takeSnapshot(of: view, in: .proposed(CGSize(width: width, height: .infinity)))
  }

  func testFeedItemExactSize() {
    let view = MacroSnapshotFeedItemView()
    view.setContent(shortContent)
    takeSnapshot(of: view, in: .exact(CGSize(width: 400, height: 500)))
  }

  func testConditionalBodyCollapsed() {
    let view = MacroSnapshotConditionalView()
    takeSnapshot(of: view, in: .proposed(CGSize(width: width, height: .infinity)))
  }

  func testConditionalBodyExpanded() {
    let view = MacroSnapshotConditionalView()
    view.showsDetails = true
    takeSnapshot(of: view, in: .proposed(CGSize(width: width, height: .infinity)))
  }

  func testConditionalBodyExpandedAfterInitialLayout() {
    let view = MacroSnapshotConditionalView()
    view.frame.size = view.sizeThatFits(CGSize(width: width, height: .infinity))
    view.layoutIfNeeded()
    view.showsDetails = true
    takeSnapshot(of: view, in: .proposed(CGSize(width: width, height: .infinity)))
  }

  func testNestedViews() {
    let view = MacroSnapshotNestedView()
    takeSnapshot(of: view, in: .proposed(CGSize(width: width, height: .infinity)))
  }

  func testCustomLayoutSubviews() {
    let view = MacroSnapshotCustomLayoutView()
    takeSnapshot(of: view, in: .proposed(CGSize(width: width, height: .infinity)))
  }

  func testCollectionViewCell() {
    let cell = MacroSnapshotCell()
    takeSnapshot(of: cell, in: .proposed(CGSize(width: width, height: .infinity)))
  }
}

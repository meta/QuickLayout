/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import QuickLayoutBridge

@QuickLayout
final class SubviewSyncTestView: UIView {

  let first = UIView()
  let second = UIView()
  let third = UIView()

  var showsSecond = true {
    didSet { setNeedsLayout() }
  }

  var isReversed = false {
    didSet { setNeedsLayout() }
  }

  var body: Layout {
    VStack {
      if isReversed {
        third.frame(width: 10, height: 10)
        if showsSecond {
          second.frame(width: 10, height: 10)
        }
        first.frame(width: 10, height: 10)
      } else {
        first.frame(width: 10, height: 10)
        if showsSecond {
          second.frame(width: 10, height: 10)
        }
        third.frame(width: 10, height: 10)
      }
    }
  }
}

@QuickLayout
final class TogglableBodyTestView: UIView {

  let content = UIView()

  var bodyEnabled = true {
    didSet { setNeedsLayout() }
  }

  override var isBodyEnabled: Bool {
    bodyEnabled
  }

  var body: Layout {
    content
      .frame(width: 50, height: 20)
      .padding(10)
  }
}

@QuickLayout
final class CountingChildTestView: UIView {

  var bodyCounter = 0
  let leaf = UIView()

  var body: Layout {
    countedLayout()
  }

  private func countedLayout() -> Layout {
    bodyCounter += 1
    return leaf.frame(width: 40, height: 20)
  }
}

@QuickLayout
final class CachingParentTestView: UIView {

  let firstChild = CountingChildTestView()
  let secondChild = CountingChildTestView()
  var cachingEnabled = false

  override var isCachingEnabled: Bool {
    cachingEnabled
  }

  var body: Layout {
    VStack(spacing: 8) {
      firstChild
      secondChild
    }
  }
}

@QuickLayout
final class MacroTestCell: UICollectionViewCell {

  static let bodySize = CGSize(width: 120, height: 44)

  let content = UIView()

  var body: Layout {
    content
      .frame(width: Self.bodySize.width, height: Self.bodySize.height)
  }
}

@QuickLayout
final class CustomWillMoveTestView: UIView {

  let content = UIView()
  var willMoveToWindowCount = 0

  var body: Layout {
    content.frame(width: 30, height: 30)
  }

  override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    willMoveToWindowCount += 1
  }
}

@QuickLayout
class BaseBodyTestView: UIView {

  let title = UIView()

  var body: Layout {
    title.frame(width: 40, height: 10)
  }
}

final class SubclassBodyTestView: BaseBodyTestView {

  let detail = UIView()

  override var body: Layout {
    VStack(spacing: 5) {
      title.frame(width: 40, height: 10)
      detail.frame(width: 60, height: 15)
    }
  }
}

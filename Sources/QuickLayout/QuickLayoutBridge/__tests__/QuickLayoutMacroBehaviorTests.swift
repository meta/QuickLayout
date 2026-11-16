/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

@testable import QuickLayoutBridge
@testable import QuickLayoutBridgeTestUsage
import Testing
import UIKit

@MainActor
struct QuickLayoutMacroSubviewTests {

  private func makeView() -> SubviewSyncTestView {
    let view = SubviewSyncTestView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    view.layoutIfNeeded()
    return view
  }

  @Test func bodyViews_areAddedInBodyOrder() {
    let view = makeView()
    #expect(view.subviews == [view.first, view.second, view.third])
  }

  @Test func sizeThatFits_addsBodyViewsBeforeLayout() {
    let view = SubviewSyncTestView()
    _ = view.sizeThatFits(CGSize(width: 100, height: 100))
    #expect(view.subviews == [view.first, view.second, view.third])
  }

  @Test func viewRemovedFromBody_isRemovedFromSuperview() {
    let view = makeView()
    view.showsSecond = false
    view.layoutIfNeeded()
    #expect(view.second.superview == nil)
    #expect(view.subviews == [view.first, view.third])
  }

  @Test func viewReturningToBody_isInsertedAtItsBodyPosition() {
    let view = makeView()
    view.showsSecond = false
    view.layoutIfNeeded()
    view.showsSecond = true
    view.layoutIfNeeded()
    #expect(view.subviews == [view.first, view.second, view.third])
  }

  @Test func reorderedBody_reordersSubviews() {
    let view = makeView()
    view.isReversed = true
    view.layoutIfNeeded()
    #expect(view.subviews == [view.third, view.second, view.first])
    #expect(view.third.frame.minY < view.first.frame.minY)
  }

  @Test func subviewsAddedOutsideBody_arePreserved() {
    let view = makeView()
    let manual = UIView()
    view.addSubview(manual)
    view.showsSecond = false
    view.layoutIfNeeded()
    #expect(manual.superview === view)
  }
}

@MainActor
struct QuickLayoutMacroBodyEnabledTests {

  @Test func enabledBody_sizesAndHostsBodyViews() {
    let view = TogglableBodyTestView()
    #expect(view.sizeThatFits(CGSize(width: 200, height: 200)) == CGSize(width: 70, height: 40))
    #expect(view.content.superview === view)
  }

  @Test func disabledBody_doesNotAddBodyViews() {
    let view = TogglableBodyTestView(frame: CGRect(x: 0, y: 0, width: 33, height: 44))
    view.bodyEnabled = false
    #expect(view.sizeThatFits(CGSize(width: 200, height: 200)) == CGSize(width: 33, height: 44))
    view.layoutIfNeeded()
    #expect(view.content.superview == nil)
  }

  @Test func disablingBody_removesBodyViews() {
    let view = TogglableBodyTestView(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
    view.layoutIfNeeded()
    #expect(view.content.superview === view)

    view.bodyEnabled = false
    view.layoutIfNeeded()
    #expect(view.content.superview == nil)
  }

  @Test func reenablingBody_restoresBodyViews() {
    let view = TogglableBodyTestView(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
    view.bodyEnabled = false
    view.layoutIfNeeded()
    view.bodyEnabled = true
    view.layoutIfNeeded()
    #expect(view.content.superview === view)
    #expect(view.content.frame == CGRect(x: 10, y: 10, width: 50, height: 20))
  }
}

@MainActor
struct QuickLayoutMacroCachingTests {

  private func layOut(cachingEnabled: Bool) -> CachingParentTestView {
    let view = CachingParentTestView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    view.cachingEnabled = cachingEnabled
    view.layoutIfNeeded()
    return view
  }

  @Test func caching_producesSameFramesAsUncachedLayout() {
    let cached = layOut(cachingEnabled: true)
    let uncached = layOut(cachingEnabled: false)
    #expect(cached.firstChild.frame == uncached.firstChild.frame)
    #expect(cached.secondChild.frame == uncached.secondChild.frame)
    #expect(cached.firstChild.leaf.frame == uncached.firstChild.leaf.frame)
    #expect(cached.secondChild.leaf.frame == uncached.secondChild.leaf.frame)
  }

  @Test func caching_laysOutNestedViewsWithinTheParentPass() {
    let view = layOut(cachingEnabled: true)
    #expect(view.firstChild.leaf.frame == CGRect(x: 0, y: 0, width: 40, height: 20))
    #expect(!view.firstChild.layer.needsLayout())
    #expect(!view.secondChild.layer.needsLayout())
  }

  @Test func caching_evaluatesNestedBodiesOncePerPass() {
    let cached = layOut(cachingEnabled: true)
    let uncached = layOut(cachingEnabled: false)
    #expect(cached.firstChild.bodyCounter == 1)
    #expect(cached.secondChild.bodyCounter == 1)
    #expect(uncached.firstChild.bodyCounter > cached.firstChild.bodyCounter)
  }
}

@MainActor
struct QuickLayoutMacroCellTests {

  private final class LayoutWithoutPreferredAttributes: UICollectionViewLayout {}

  private final class LayoutWithPreferredAttributes: UICollectionViewLayout {
    override func shouldInvalidateLayout(
      forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
      withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> Bool {
      true
    }
  }

  private final class DataSource: NSObject, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
  }

  // A deallocated window invalidates its scene, which crashes test processes without a host app.
  private static let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 300, height: 300))

  @Test func bodyViews_areHostedInContentView() {
    let cell = MacroTestCell(frame: CGRect(origin: .zero, size: MacroTestCell.bodySize))
    cell.layoutIfNeeded()
    #expect(cell.content.superview === cell.contentView)
  }

  @Test func standaloneCell_sizesToBody() {
    let cell = MacroTestCell()
    #expect(cell.sizeThatFits(CGSize(width: 300, height: 300)) == MacroTestCell.bodySize)
  }

  @Test func cellInLayoutWithoutSelfSizing_skipsBodySizing() {
    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 300), collectionViewLayout: LayoutWithoutPreferredAttributes())
    let cell = MacroTestCell(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    collectionView.addSubview(cell)
    #expect(cell.sizeThatFits(CGSize(width: 300, height: 300)) != MacroTestCell.bodySize)
  }

  @Test func cellInLayoutWithSelfSizing_sizesToBody() {
    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 300), collectionViewLayout: LayoutWithPreferredAttributes())
    let cell = MacroTestCell(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    collectionView.addSubview(cell)
    #expect(cell.sizeThatFits(CGSize(width: 300, height: 300)) == MacroTestCell.bodySize)
  }

  @Test func selfSizingCollectionView_usesBodyHeight() {
    let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(10)))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
    let layout = UICollectionViewCompositionalLayout(section: NSCollectionLayoutSection(group: group))
    let collectionView = UICollectionView(frame: Self.window.bounds, collectionViewLayout: layout)
    let dataSource = DataSource()
    collectionView.register(MacroTestCell.self, forCellWithReuseIdentifier: "cell")
    collectionView.dataSource = dataSource
    Self.window.addSubview(collectionView)
    defer { collectionView.removeFromSuperview() }

    collectionView.layoutIfNeeded()

    let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
    #expect(cell?.frame.height == MacroTestCell.bodySize.height)
    withExtendedLifetime(dataSource) {}
  }
}

@MainActor
struct QuickLayoutMacroOverrideTests {

  // A deallocated window invalidates its scene, which crashes test processes without a host app.
  private static let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

  @Test func customWillMoveToWindow_runsAndBodyStillLaysOut() {
    let view = CustomWillMoveTestView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    Self.window.addSubview(view)
    defer { view.removeFromSuperview() }
    view.layoutIfNeeded()
    #expect(view.willMoveToWindowCount == 1)
    #expect(view.content.superview === view)
    #expect(view.content.frame == CGRect(x: 0, y: 0, width: 30, height: 30))
  }

  @Test func unannotatedSubclass_usesOverriddenBody() {
    let view = SubclassBodyTestView()
    #expect(view.sizeThatFits(CGSize(width: 200, height: 200)) == CGSize(width: 60, height: 30))
    view.frame.size = CGSize(width: 60, height: 30)
    view.layoutIfNeeded()
    #expect(view.subviews == [view.title, view.detail])
    #expect(view.detail.frame == CGRect(x: 0, y: 15, width: 60, height: 15))
  }

  @Test func baseClass_usesItsOwnBody() {
    let view = BaseBodyTestView()
    #expect(view.sizeThatFits(CGSize(width: 200, height: 200)) == CGSize(width: 40, height: 10))
  }
}

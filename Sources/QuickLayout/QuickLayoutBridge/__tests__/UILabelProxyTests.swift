/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import QuickLayoutBridge
import QuickLayoutCore
import Testing
import UIKit

@MainActor
@Suite
struct UILabelProxyTests {

  private let proposedSize = CGSize(width: 200, height: CGFloat.greatestFiniteMagnitude)
  private let text = "The quick brown fox jumps over the lazy dog and keeps running across the field"

  // MARK: - Attributed text

  @Test
  func testAttributedProxyIgnoresPreviouslyMeasuredParagraphStyleKernAndFont() {
    let fontOnly = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15)])

    _ = proxySize(for: styledText())

    #expect(proxySize(for: fontOnly) == freshLabelSize(for: fontOnly))
  }

  @Test
  func testAttributedProxyIgnoresPreviouslyMeasuredKern() {
    let font = UIFont.systemFont(ofSize: 15)
    let kerned = NSAttributedString(string: text, attributes: [.font: font, .kern: 6])
    let fontOnly = NSAttributedString(string: text, attributes: [.font: font])

    _ = proxySize(for: kerned)

    #expect(proxySize(for: fontOnly) == freshLabelSize(for: fontOnly))
  }

  @Test
  func testAttributedProxyIgnoresPreviouslyMeasuredLineHeight() {
    let font = UIFont.systemFont(ofSize: 15)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = 40
    let tall = NSAttributedString(string: text, attributes: [.font: font, .paragraphStyle: paragraphStyle])
    let fontOnly = NSAttributedString(string: text, attributes: [.font: font])

    _ = proxySize(for: tall)

    #expect(proxySize(for: fontOnly) == freshLabelSize(for: fontOnly))
  }

  @Test
  func testAttributedProxyIgnoresPreviouslyMeasuredLineBreakMode() {
    let font = UIFont.systemFont(ofSize: 15)
    let longWords = "aaaaaaaaaaaaaaaa bbbbbbbbbbbbbbbb cccccccccccccccc dddddddddddddddd eeeeeeeeeeeeeeee ffffffffffffffff"
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byCharWrapping
    let charWrapped = NSAttributedString(string: longWords, attributes: [.font: font, .paragraphStyle: paragraphStyle])
    let fontOnly = NSAttributedString(string: longWords, attributes: [.font: font])

    _ = proxySize(for: charWrapped)

    #expect(proxySize(for: fontOnly) == freshLabelSize(for: fontOnly))
  }

  @Test
  func testAttributedProxyIgnoresPreviouslyMeasuredFont() {
    let bare = NSAttributedString(string: text)

    _ = proxySize(for: styledText())

    #expect(proxySize(for: bare) == freshLabelSize(for: bare))
  }

  // MARK: - Plain text

  @Test
  func testTextProxyIgnoresPreviouslyMeasuredText() {
    _ = textProxySize(for: text, font: UIFont.boldSystemFont(ofSize: 24))

    #expect(textProxySize(for: text, font: nil) == freshLabelSize(for: text, font: nil))
  }

  @Test
  func testTextProxyIgnoresPreviouslyMeasuredAttributedText() {
    let font = UIFont.systemFont(ofSize: 15)

    _ = proxySize(for: styledText())

    #expect(textProxySize(for: text, font: font) == freshLabelSize(for: text, font: font))
  }

  // MARK: - Helpers

  private func styledText() -> NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = 1.6
    paragraphStyle.minimumLineHeight = 40
    paragraphStyle.alignment = .center
    paragraphStyle.lineBreakMode = .byCharWrapping
    return NSAttributedString(
      string: text,
      attributes: [
        .font: UIFont.boldSystemFont(ofSize: 24),
        .kern: 4,
        .paragraphStyle: paragraphStyle,
      ]
    )
  }

  private func proxySize(for attributedText: NSAttributedString) -> CGSize {
    UILabel.proxy(for: attributedText, numberOfLines: 0).quick_layoutThatFits(proposedSize).size
  }

  private func textProxySize(for text: String, font: UIFont?) -> CGSize {
    UILabel.proxy(for: text, numberOfLines: 0, with: font).quick_layoutThatFits(proposedSize).size
  }

  private func freshLabelSize(for attributedText: NSAttributedString) -> CGSize {
    let label = UILabel()
    label.attributedText = attributedText
    label.numberOfLines = 0
    return label.quick_layoutThatFits(proposedSize).size
  }

  private func freshLabelSize(for text: String, font: UIFont?) -> CGSize {
    let label = UILabel()
    label.text = text
    label.font = font
    label.numberOfLines = 0
    return label.quick_layoutThatFits(proposedSize).size
  }
}

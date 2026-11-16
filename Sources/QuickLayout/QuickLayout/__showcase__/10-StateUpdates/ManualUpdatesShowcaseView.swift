/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import QuickLayout
import UIKit

@available(iOS 17.0, tvOS 17.0, *)
@MainActor
private final class ManualProfileModel {
  var name = "Ada Lovelace"
  var title = "Mathematician and writer"
  var isVerified = false
  var unusedCounter = 0
}

@available(iOS 17.0, tvOS 17.0, *)
@QuickLayout
// patternlint-disable-next-line meta-subclass-view
private class ManualProfileView: UIView {
  var model: ManualProfileModel
  var showsTitle = true

  private let nameLabel = UILabel()
  private let titleLabel = UILabel()
  private let badge = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))

  init(model: ManualProfileModel) {
    self.model = model
    super.init(frame: .zero)
    nameLabel.font = .preferredFont(forTextStyle: .headline)
    nameLabel.numberOfLines = 0
    titleLabel.font = .preferredFont(forTextStyle: .subheadline)
    titleLabel.textColor = .secondaryLabel
    titleLabel.numberOfLines = 0
  }

  func updateContent() {
    nameLabel.text = model.name
    titleLabel.text = model.title
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is unavailable")
  }

  var body: QuickLayout.Layout {
    VStack(alignment: .leading, spacing: 4) {
      HStack(alignment: .top, spacing: 4) {
        nameLabel
        if model.isVerified {
          badge.resizable().frame(width: 24, height: 24)
        }
        Spacer()
      }
      if showsTitle {
        titleLabel
      }
    }
  }
}

@available(iOS 17.0, tvOS 17.0, *)
private final class ManualDetailedProfileView: ManualProfileView {
  var showsDetails = false

  private let detailsLabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .footnote)
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    return label
  }()

  override func updateContent() {
    super.updateContent()
    detailsLabel.text = "About \(model.name)"
  }

  @LayoutBuilder
  override var body: QuickLayout.Layout {
    VStack(alignment: .leading, spacing: 8) {
      super.body
      if showsDetails {
        detailsLabel
      }
    }
  }
}

@available(iOS 17.0, tvOS 17.0, *)
@QuickLayout
// patternlint-disable-next-line meta-subclass-view
final class ManualUpdatesShowcaseView: UIView {
  private var model = ManualProfileModel()
  private lazy var row = {
    let view = ManualDetailedProfileView(model: model)
    view.updateContent()
    return view
  }()
  private lazy var renameButton = makeButton("Rename", action: #selector(toggleName))
  private lazy var verifiedButton = makeButton("Toggle verified", action: #selector(toggleVerified))
  private lazy var titleButton = makeButton("Toggle title", action: #selector(toggleTitle))
  private lazy var detailsButton = makeButton("Toggle details", action: #selector(toggleDetails))
  private lazy var replaceButton = makeButton("Replace model", action: #selector(replaceModel))
  private lazy var unusedPropertyButton = makeButton("Change unused property", action: #selector(changeUnusedProperty))

  var body: QuickLayout.Layout {
    VStack(alignment: .leading, spacing: 24) {
      row
      VStack(spacing: 12) {
        renameButton.resizable().frame(height: 36)
        verifiedButton.resizable().frame(height: 36)
        titleButton.resizable().frame(height: 36)
        detailsButton.resizable().frame(height: 36)
        replaceButton.resizable().frame(height: 36)
        unusedPropertyButton.resizable().frame(height: 36)
      }
      Spacer()
    }.padding(16)
  }

  private func makeButton(_ title: String, action: Selector) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.addTarget(self, action: action, for: .touchUpInside)
    return button
  }

  @objc private func toggleName() {
    model.name = model.name == "Ada Lovelace" ? "Augusta Ada King, Countess of Lovelace" : "Ada Lovelace"
    row.updateContent()
    row.setNeedsLayout()
  }

  @objc private func toggleVerified() {
    model.isVerified.toggle()
    row.setNeedsLayout()
  }

  @objc private func toggleTitle() {
    row.showsTitle.toggle()
    row.setNeedsLayout()
  }

  @objc private func toggleDetails() {
    row.showsDetails.toggle()
    row.setNeedsLayout()
  }

  @objc private func changeUnusedProperty() {
    model.unusedCounter += 1
  }

  @objc private func replaceModel() {
    model = ManualProfileModel()
    model.name = "Grace Hopper"
    // @nolint ASTGREP(common/swift/i18n-hardcoded-ui-property) sample data in an internal-only showcase
    model.title = "Computer scientist"
    row.model = model
    row.updateContent()
    row.setNeedsLayout()
  }
}

import SwiftUI

@available(iOS 17.0, tvOS 17.0, *)
#Preview {
  ManualUpdatesShowcaseView()
}

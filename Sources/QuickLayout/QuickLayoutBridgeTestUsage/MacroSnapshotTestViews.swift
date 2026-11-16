/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import QuickLayoutBridge

public final class MacroSnapshotPlaceholderView: UIView {

  private let intrinsicSize: CGSize?

  public init(intrinsicSize: CGSize? = nil) {
    self.intrinsicSize = intrinsicSize
    super.init(frame: .zero)
    backgroundColor = .black
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    intrinsicSize ?? size
  }
}

public struct MacroSnapshotFeedContent {
  public let actionText: String
  public let posterName: String
  public let posterHeadline: String
  public let posterComment: String
  public let contentTitle: String
  public let actorComment: String

  public init(actionText: String, posterName: String, posterHeadline: String, posterComment: String, contentTitle: String, actorComment: String) {
    self.actionText = actionText
    self.posterName = posterName
    self.posterHeadline = posterHeadline
    self.posterComment = posterComment
    self.contentTitle = contentTitle
    self.actorComment = actorComment
  }
}

/// A feed item laid out by the `@QuickLayout` macro, without manual subview management.
@QuickLayout
public final class MacroSnapshotFeedItemView: UIView {

  private let actionLabel = UILabel()
  private let optionsLabel = UILabel()
  private let posterImageView = MacroSnapshotPlaceholderView()
  private let posterNameLabel = UILabel()
  private let posterHeadlineLabel = UILabel()
  private let posterCommentLabel = UILabel()
  private let contentImageView = MacroSnapshotPlaceholderView()
  private let contentTitleLabel = UILabel()
  private let likeLabel = UILabel()
  private let commentLabel = UILabel()
  private let shareLabel = UILabel()
  private let actorImageView = MacroSnapshotPlaceholderView()
  private let actorCommentLabel = UILabel()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    optionsLabel.text = "..."
    likeLabel.text = "Like"
    commentLabel.text = "Comment"
    shareLabel.text = "Share"
    for label in [actionLabel, posterNameLabel, posterHeadlineLabel, posterCommentLabel, contentTitleLabel, actorCommentLabel] {
      label.numberOfLines = 0
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func setContent(_ content: MacroSnapshotFeedContent) {
    actionLabel.text = content.actionText
    posterNameLabel.text = content.posterName
    posterHeadlineLabel.text = content.posterHeadline
    posterCommentLabel.text = content.posterComment
    contentTitleLabel.text = content.contentTitle
    actorCommentLabel.text = content.actorComment
    setNeedsLayout()
  }

  public func setFont(_ font: UIFont) {
    for label in [actionLabel, optionsLabel, posterNameLabel, posterHeadlineLabel, posterCommentLabel, contentTitleLabel, likeLabel, commentLabel, shareLabel, actorCommentLabel] {
      label.font = font
    }
    setNeedsLayout()
  }

  public var body: Layout {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        actionLabel
        Spacer(8)
        optionsLabel
      }
      HStack(alignment: .top, spacing: 8) {
        posterImageView
          .resizable()
          .frame(width: 50, height: 50)
        VStack(alignment: .leading, spacing: 4) {
          posterNameLabel
          posterHeadlineLabel
        }
      }
      posterCommentLabel
      contentImageView
        .resizable()
        .aspectRatio(CGSize(width: 350, height: 200))
      contentTitleLabel
      HStack {
        likeLabel
        Spacer()
        commentLabel
        Spacer()
        shareLabel
      }
      HStack(alignment: .top, spacing: 8) {
        actorImageView
          .resizable()
          .frame(width: 30, height: 30)
        actorCommentLabel
      }
    }
    .padding(8)
  }
}

/// A `@QuickLayout` view whose body adds or removes a subview depending on a property.
@QuickLayout
public final class MacroSnapshotConditionalView: UIView {

  public var showsDetails = false {
    didSet { setNeedsLayout() }
  }

  private let titleLabel = UILabel()
  private let detailsLabel = UILabel()
  private let badge = MacroSnapshotPlaceholderView(intrinsicSize: CGSize(width: 20, height: 20))

  public override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    titleLabel.text = "Title"
    detailsLabel.text = "Details are visible only when expanded. They wrap to multiple lines when needed."
    detailsLabel.numberOfLines = 0
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var body: Layout {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 8) {
        titleLabel
        Spacer()
        if showsDetails {
          badge
        }
      }
      if showsDetails {
        detailsLabel
      }
    }
    .padding(8)
  }
}

/// A `@QuickLayout` view that contains another `@QuickLayout` view.
@QuickLayout
public final class MacroSnapshotNestedView: UIView {

  private let header = UILabel()
  private let first = MacroSnapshotConditionalView()
  private let second = MacroSnapshotConditionalView()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .lightGray
    header.text = "Nested @QuickLayout views"
    second.showsDetails = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var body: Layout {
    VStack(alignment: .leading, spacing: 8) {
      header
      first
      second
    }
    .padding(8)
  }
}

/// A `@QuickLayout` view with a custom `layoutSubviews`, into which the macro injects its implementation.
@QuickLayout
public final class MacroSnapshotCustomLayoutView: UIView {

  private let label = UILabel()
  private let marker = UIView()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    label.text = "Body layout with a manually placed marker"
    label.numberOfLines = 0
    marker.backgroundColor = .red
    addSubview(marker)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var body: Layout {
    label
      .padding(16)
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    marker.frame = CGRect(x: bounds.maxX - 12, y: 0, width: 12, height: 12)
  }
}

/// A `@QuickLayout` collection view cell, whose body is hosted in `contentView`.
@QuickLayout
public final class MacroSnapshotCell: UICollectionViewCell {

  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let thumbnail = MacroSnapshotPlaceholderView()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = .white
    titleLabel.text = "Cell title"
    subtitleLabel.text = "The body is hosted in the cell's content view and sized by the macro."
    subtitleLabel.numberOfLines = 0
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var body: Layout {
    HStack(alignment: .top, spacing: 12) {
      thumbnail
        .resizable()
        .frame(width: 60, height: 60)
      VStack(alignment: .leading, spacing: 4) {
        titleLabel
        subtitleLabel
      }
    }
    .padding(12)
  }
}

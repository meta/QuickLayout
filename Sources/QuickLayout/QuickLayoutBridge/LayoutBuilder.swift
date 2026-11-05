/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import UIKit

// A custom parameter attribute that constructs layout from closures.
@resultBuilder
public struct LayoutBuilder {

  public static func buildBlock(_ layout: Layout) -> Layout {
    layout
  }

  public static func buildExpression(_ layout: Layout) -> Layout {
    layout
  }

  public static func buildExpression(_ layout: Layout?) -> Layout {
    layout ?? EmptyLayout()
  }

  public static func buildExpression(_ view: UIView) -> Layout {
    SingleElement(child: view)
  }

  public static func buildExpression(_ view: UIView?) -> Layout {
    view.map { SingleElement(child: $0) } ?? EmptyLayout()
  }

  public static func buildExpression(_ view: Element) -> Layout {
    SingleElement(child: view)
  }

  public static func buildExpression(_ view: Element?) -> Layout {
    view.map { SingleElement(child: $0) } ?? EmptyLayout()
  }

  public static func buildLimitedAvailability(_ layout: Layout) -> Layout {
    layout
  }

  public static func buildEither(first: Layout) -> Layout {
    first
  }

  public static func buildEither(second: Layout) -> Layout {
    second
  }

  public static func buildOptional(_ layout: Layout?) -> Layout {
    layout ?? EmptyLayout()
  }
}

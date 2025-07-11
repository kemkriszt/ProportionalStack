import SwiftUI

extension ContainerValues {
    @Entry var proportion: Double = 1
}

public extension View {
    /// Set the proportion of the container view that the view should occupy.
    /// Width or height depending on the container view
    ///
    /// Can be any value, the final size will be calculated taking in consideration the sum of all
    /// proportion values of the sibling views
    ///
    /// - Parameter value: Proportion value
    func proportion(_ value: Double) -> some View {
        self.containerValue(\.proportion, value)
    }
}

/// A stack that places its subviews proportionally to its proposed size
public struct ProportionalStack: Layout {
    var direction: Axis = .horizontal
    
    public init(direction: Axis) {
        self.direction = direction
    }
    
    public func sizeThatFits(proposal: ProposedViewSize,
                             subviews: Subviews,
                             cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    public func placeSubviews(in bounds: CGRect,
                              proposal: ProposedViewSize,
                              subviews: Subviews,
                              cache: inout ()) {
        let totalFixedSize = subviews
            .map { extractSize($0.sizeThatFits(proposal)) }
            .filter { isCustom(size: $0, proposal: proposal) }
            .reduce(0, +)
        let totalContainerSpace = extractSize(bounds.size)
        let totalRemainingContainerSpace = totalContainerSpace - totalFixedSize
        let usableContainerSize = constructRect(
            modifiedDimension: totalRemainingContainerSpace,
            original: bounds
        )
        
        let totalSizeFactor = subviews
            .filter {
                !isCustom(size: extractSize($0.sizeThatFits(proposal)),
                          proposal: proposal)
            }
            .map(\.containerValues.proportion)
            .reduce(0, +)
        var origin = bounds.origin
        
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            let viewDimension = extractSize(view.sizeThatFits(proposal))
            let isCustom = isCustom(size: viewDimension, proposal: proposal)
            
            let size = if isCustom {
                viewSize
            } else {
                getSize(containerSize: usableContainerSize.size,
                        proportion: view.containerValues.proportion / totalSizeFactor)
            }
            
            view.place(at: origin, proposal: .init(size))
            origin = moveOrigin(origin, placedViewSize: size)
        }
    }
    
    /// Get the size along the managed axis
    private func extractSize(_ size: CGSize) -> CGFloat {
        if direction == .vertical {
            size.height
        } else {
            size.width
        }
    }
    
    private func constructRect(modifiedDimension: CGFloat,
                               original bounds: CGRect) -> CGRect {
        if direction == .vertical {
            CGRect(origin: bounds.origin,
                   size: CGSize(width: bounds.width,
                                height: modifiedDimension))
        } else {
            CGRect(origin: bounds.origin,
                   size: CGSize(width: modifiedDimension,
                                height: bounds.height))
        }
    }
    
    /// Verify if the view has a custom size.
    ///
    /// Currently the condition for this is that it's size along the managed axis is smaller than
    /// the containers size. This decision was made based on the assumption that if a view is smaller,
    /// it has a fixed size and can't be freely modified, if it is larger, it wouldn't fix the container anyways
    /// so we decide not to honor it's demands for space
    private func isCustom(size viewSize: CGFloat, proposal: ProposedViewSize) -> Bool {
        let containerDimension = if direction == .horizontal {
            proposal.width ?? 0
        } else {
            proposal.height ?? 0
        }
        
        return viewSize < containerDimension
    }
    
    private func moveOrigin(_ origin: CGPoint,
                            placedViewSize size: CGSize) -> CGPoint {
        return if direction == .horizontal {
            CGPoint(x: origin.x + size.width, y: origin.y)
        } else {
            CGPoint(x: origin.x, y: origin.y + size.height)
        }
    }
    
    /// Construct a size based on the managed axis
    private func getSize(containerSize: CGSize,
                         proportion: Double) -> CGSize {
        return if direction == .horizontal {
            CGSize(width: containerSize.width * proportion,
                   height: containerSize.height)
        } else {
            CGSize(width: containerSize.width,
                   height: containerSize.height * proportion)
        }
    }
}

#Preview(traits: .fixedLayout(width: 500, height: 500)) {
    VStack {
        ProportionalStack(direction: .horizontal) {
            Color.red.proportion(3)
            Color.green.frame(width: 150)
            Color.blue.proportion(2)
        }
        .frame(width: 300, height: 300)
    }
    .padding()
}

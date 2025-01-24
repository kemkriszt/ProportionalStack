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
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let totalSizeFactor = subviews.map(\.containerValues.proportion).reduce(0, +)
        var origin = bounds.origin
        
        for view in subviews {
            let proportion = view.containerValues.proportion / totalSizeFactor
            
            let size = self.getSize(containerSize: bounds.size,
                                    proportion: proportion)
            view.place(at: origin, proposal: .init(size))
            origin = moveOrigin(origin, placedViewSize: size)
        }
    }
    
    private func moveOrigin(_ origin: CGPoint, placedViewSize size: CGSize) -> CGPoint {
        return if direction == .horizontal {
            CGPoint(x: origin.x + size.width, y: origin.y)
        } else {
            CGPoint(x: origin.x, y: origin.y + size.height)
        }
    }
    
    private func getSize(containerSize: CGSize, proportion: Double) -> CGSize {
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
            Color.green
            Color.blue.proportion(2)
        }
        .frame(width: 300, height: 300)
    }
    .padding()
}

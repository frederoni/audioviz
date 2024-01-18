import Foundation

extension FloatingPoint where Self: Comparable {
    func scaled(from inputRange: ClosedRange<Self>, to outputRange: ClosedRange<Self>) -> Self {
        return (self - inputRange.lowerBound) * (outputRange.upperBound - outputRange.lowerBound) /
            (inputRange.upperBound - inputRange.lowerBound) + outputRange.lowerBound
    }
    
    func zeroIfNaN() -> Self {
        return isNaN ? 0 : self
    }
}

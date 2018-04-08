import Foundation

/// Walkthrough Item encapsulating:
/// 1. description text to show during step
/// 2. absolute screen CGRect to center focus on during step
public struct AZWalkthroughItem {
    public var descriptionText: String;
    public var objectRect: CGRect;
}

/// Data used to layout and draw walkthrough controller
public struct AZWalkthroughDataset {
    public var items: [AZWalkthroughItem] = [];
    public var overlayOpacity: Float = 0.8;
    public var textColor: UIColor = .white;
    public var nextButtonColor: UIColor = .white;
    public var textFont: UIFont = UIFont.systemFont(ofSize: 16);
    public var spotlightBorderWidth: CGFloat = 4;
    public var spotlightBorderColor: UIColor = .white;
    public var spotlightRadius: CGFloat = 60;
    public var nextButtonText: String = "Next";
}

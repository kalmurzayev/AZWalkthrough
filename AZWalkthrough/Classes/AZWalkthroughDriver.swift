//
//  AZWalkthroughStateMachine.swift
//  SkyBank
//
//  Created by Azamat Kalmurzayev on 3/7/18.
//  Copyright © 2018 Onsolut LLC. All rights reserved.
//

import Foundation

/// Protocol for Walkthrough state machine administering walkthrough steps
public protocol AZWalkthroughStateMachineProtocol: class {
    /// View reference
    weak var view: AZWalkthroughView? { get set };
    /// Dataset for administering walkthrough steps
    var dataset: AZWalkthroughDataset? { get set };
    /// Draws view with next walkthrough item
    func toggleState();
}

public class AZWalkthroughStateMachine: AZWalkthroughStateMachineProtocol {
    fileprivate static let arrowOffset: CGFloat = 10;
    fileprivate static let labelCircleMargin: CGFloat = 70;
    open var dataset: AZWalkthroughDataset? {
        didSet {
            _labelStack = AZDataQueue<AZWalkthroughItem>();
            dataset?.items.forEach { _labelStack.push(item: $0) }
        }
    }
    weak open var view: AZWalkthroughView?;
    fileprivate var _labelStack = AZDataQueue<AZWalkthroughItem>();
    fileprivate var _labelPosOption: AZLabelPositionOption = .aboveSpotlight;
    
    open func toggleState() {
        guard let nextItem = _labelStack.pop() else {
            view?.disappearSmoothly();
            return;
        }
        self.updateVisuals(for: nextItem);
    }
    
    fileprivate func updateVisuals(for item: AZWalkthroughItem) {
        UIView.animate(withDuration: AZWalkthroughController.animDuration, animations: { 
            self.view?.descrLabel.alpha = 0;
        }, completion: { [weak self] _ in
            self?.updateCircleMask(for: item);
            self?.updateLabelState(for: item);
            self?.updateArrow(for: item);
        });
    }
    
    private func updateLabelState(for item: AZWalkthroughItem) {
        guard let view = self.view else { return }
        view.descrLabel.alpha = 0;
        let circleRect = self.circleMaskRect(for: item);
        _labelPosOption = circleRect.maxY > view.bounds.midY
            ? .aboveSpotlight : .belowSpotlight;
        view.descrLabel.text = item.descriptionText;
        view.descrLabel.frame = self.labelRect(for: item);
        UIView.animate(withDuration: AZWalkthroughController.animDuration, animations: { 
            view.descrLabel.alpha = 1;
        });
    }
    
    private func updateCircleMask(for item: AZWalkthroughItem) {
        guard let view = self.view else { return }
        let path = UIBezierPath(
            roundedRect: CGRect(
                x: 0, y: 0,
                width: view.bounds.size.width,
                height: view.bounds.size.height),
            cornerRadius: 0);
        let circleRect = self.circleMaskRect(for: item);
        let circlePath = UIBezierPath(
            roundedRect: circleRect,
            cornerRadius: circleRect.width / 2.0);
        path.append(circlePath);
        path.usesEvenOddFillRule = true;
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = dataset?.overlayOpacity ?? 1.0;
        view.darkOverlay.layer.sublayers?.removeAll();
        view.darkOverlay.layer.addSublayer(fillLayer);
        view.circle.frame.origin = circleRect.origin;
        view.circle.alpha = 1;
    }
    
    private func updateArrow(for item: AZWalkthroughItem) {
        guard let view = self.view, let ds = dataset else { return }
        var startYPos: CGFloat;
        if _labelPosOption == .aboveSpotlight {
            startYPos = view.descrLabel.frame.maxY + AZWalkthroughStateMachine.arrowOffset;
        } else {
            startYPos = view.descrLabel.frame.minY - AZWalkthroughStateMachine.arrowOffset;
        }
        let arrowStart = CGPoint(
            x: view.descrLabel.frame.midX, y: startYPos);
        let hypoth = hypot(
            view.circle.center.x - arrowStart.x,
            view.circle.center.y - arrowStart.y);
        let distanceRatio = (hypoth - view.circle.frame.width / 2 - 2 * AZWalkthroughStateMachine.arrowOffset) / hypoth;
        let xDiff = view.circle.center.x - arrowStart.x;
        let yDiff = view.circle.center.y - arrowStart.y;
        let arrowEnd = CGPoint(
            x: arrowStart.x + xDiff * distanceRatio,
            y: arrowStart.y + yDiff * distanceRatio);
        
        let path = arrowBezier(
            from: arrowStart, to: arrowEnd,
            tailWidth: ds.spotlightBorderWidth / 2,
            headWidth: ds.spotlightBorderWidth * 2,
            headLength: ds.spotlightBorderWidth * 2);
        let arrowLayer = CAShapeLayer();
        arrowLayer.path = path.cgPath;
        arrowLayer.opacity = 1;
        if let ds = dataset {
            arrowLayer.fillColor = ds.spotlightBorderColor.cgColor;
            arrowLayer.strokeColor = ds.spotlightBorderColor.cgColor;
        }
        view.darkOverlay.layer.addSublayer(arrowLayer);
    }
    
    private func arrowBezier(from start: CGPoint,
                             to end: CGPoint,
                             tailWidth: CGFloat,
                             headWidth: CGFloat,
                             headLength: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y);
        let tailLength = length - headLength;
        
        let points: [CGPoint] = [
            CGPoint(x: 0, y: tailWidth / 2),
            CGPoint(x: tailLength, y: tailWidth / 2),
            CGPoint(x: tailLength, y: headWidth / 2),
            CGPoint(x: length, y: 0),
            CGPoint(x: tailLength, y: -headWidth / 2),
            CGPoint(x: tailLength, y: -tailWidth / 2),
            CGPoint(x: 0, y: -tailWidth / 2)
        ]
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(
            a: cosine, b: sine, c: -sine, d: cosine,
            tx: start.x, ty: start.y)
        
        let path = CGMutablePath()
        path.addLines(between: points, transform: transform);
        path.closeSubpath();
        
        return UIBezierPath(cgPath: path);
    }
    
    private func labelRect(for item: AZWalkthroughItem) -> CGRect {
        guard let view = self.view else { return CGRect.zero }
        let circleRect = self.circleMaskRect(for: item);
        let maxSize = AZConstants.SCREEN_SIZE.increase(
            by: -2 * AZWalkthroughController.paddingDefault,
            dy: -AZConstants.SCREEN_SIZE.height / 2);
        let labelSize = item.descriptionText.labelSize(
            maxSize: maxSize, font: view.descrLabel.font);
        
        var newPos: CGPoint = CGPoint(x: AZWalkthroughController.paddingDefault, y: 0);
        let margin = AZWalkthroughStateMachine.labelCircleMargin;
        if _labelPosOption == .aboveSpotlight {
            newPos.y = circleRect.minY - margin - labelSize.height;
        } else {
            newPos.y = circleRect.maxY + margin;
        }
        let newSize = CGSize(
            width: maxSize.width,
            height: labelSize.height);
        return CGRect(origin: newPos, size: newSize);
    }
    
    private func circleMaskRect(for item: AZWalkthroughItem) -> CGRect {
        guard let ds = self.dataset else { return CGRect.zero }
        let radius: CGFloat = ds.spotlightRadius;
        let circleRect = CGRect(
            x: item.objectRect.midX - radius,
            y: item.objectRect.midY - radius,
            width: 2 * radius, height: 2 * radius);
        return circleRect;
    }
}

//
//  AZWalkthroughController.swift
//  SkyBank
//
//  Created by Azamat Kalmurzayev on 3/3/18.
//  Copyright © 2018 Onsolut LLC. All rights reserved.
//

import Foundation
import SnapKit
import CoreGraphics

enum AZLabelPositionOption {
    case aboveSpotlight;
    case belowSpotlight;
}

public protocol AZWalkthroughView: class {
    var darkOverlay: UIView { get };
    var circle: UIView { get };
    var descrLabel: UILabel { get };
    var bounds: CGRect { get };
    func disappearSmoothly();
}

public class AZWalkthroughController: UIViewController, AZWalkthroughView {
    open var stateMachine: AZWalkthroughStateMachineProtocol = AZWalkthroughStateMachine();
    fileprivate static let buttonSize = CGSize(width: 60, height: 24);
    static let paddingDefault: CGFloat = 32;
    static let animDuration: TimeInterval = 0.2;
    open var dataset: AZWalkthroughDataset = AZWalkthroughDataset() {
        didSet { stateMachine.dataset = dataset }
    }
    open var completion: (() -> Void)?;
    fileprivate var _snapshotImg: UIImage?;
    fileprivate var _backgroundImgView: UIImageView?;
    open var bounds: CGRect {
        return self.view.bounds;
    }
    open var darkOverlay: UIView = UIView();
    open var circleFramer: UIView = {
        let view = UIView();
        view.backgroundColor = .clear;
        return view;
    }()
    open var circle: UIView {
        return circleFramer;
    }
    open var descrLabel: UILabel = {
        let label = UILabel();
        label.numberOfLines = 0;
        label.textAlignment = .center;
        return label;
    }()
    var nextButtonLabel: UILabel = {
        let label = UILabel();
        label.numberOfLines = 1;
        label.textAlignment = .right;
        return label;
    }()
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
//    required public init() {
//        super.init(nibName: nil, bundle: nil);
//    }
    
    required public init(with viewToWalkthrough: UIView) {
        super.init(nibName: nil, bundle: nil);
        initiateSnapshot(view: viewToWalkthrough);
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad();
        self.resolveBackground()
            .resolveOverlay()
            .resolveNextButtonLabel()
            .resolveLabel()
            .resolveCircleFramer()
            .finalizeView()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.appearSmoothly();
    }
    
    /// Animated revealing of subviews
    private func appearSmoothly() {
        let opacity = dataset.overlayOpacity;
        UIView.animate(
            withDuration: AZWalkthroughController.animDuration,
            animations: { [weak self] in
                self?.darkOverlay.layer.opacity = opacity;
                self?.activate()
        });
    }
    
    /// Animated revealing of subviews
    open func disappearSmoothly() {
        UIView.animate(
            withDuration: AZWalkthroughController.animDuration,
            animations: { [weak self] in
                self?.deactivate();
                self?.darkOverlay.layer.opacity = 0
                self?.circleFramer.alpha = 0;
            }, completion: { [weak self] _ in
                self?.dismiss(animated: false) { self?.completion?() }
            }
        );
    }
    
    /// Reveals labels and controls
    open func activate() {
        nextButtonLabel.alpha = 1;
        descrLabel.alpha = 1;
    }
    
    /// Hides all labels and controls, leaving only overlay
    open func deactivate() {
        nextButtonLabel.alpha = 0;
        descrLabel.alpha = 0;
    }
    
    /// Creates an initial window snapshot from passed view
    fileprivate func initiateSnapshot(view: UIView) {
        _snapshotImg = view.snapshot();
    }
    
    fileprivate func resolveBackground() -> Self {
        if _backgroundImgView?.superview != nil { return self }
        let view = UIImageView(image: _snapshotImg);
        view.frame.size = AZConstants.SCREEN_SIZE;
        self.view.addSubview(view);
        _backgroundImgView = view;
        return self;
    }
    
    fileprivate func resolveOverlay() -> Self {
        if darkOverlay.superview != nil { return self }
        darkOverlay.frame.size = AZConstants.SCREEN_SIZE;
        darkOverlay.layer.opacity = 0;
        self.view.addSubview(darkOverlay);
        return self;
    }
    
    fileprivate func resolveNextButtonLabel() -> Self {
        if nextButtonLabel.superview != nil { return self }
        nextButtonLabel.text = dataset.nextButtonText;
        nextButtonLabel.font = dataset.textFont;
        nextButtonLabel.textColor = dataset.nextButtonColor;
        self.view.addSubview(nextButtonLabel);
        nextButtonLabel.snp.makeConstraints {
            $0.size.equalTo(AZWalkthroughController.buttonSize);
            $0.trailing.equalTo(self.view)
                .offset(-AZWalkthroughController.paddingDefault);
            $0.bottom.equalTo(self.view)
                .offset(-AZWalkthroughController.paddingDefault);
        }
        return self;
    }
    
    fileprivate func resolveLabel() -> Self {
        if descrLabel.superview != nil || dataset.items.isEmpty { return self }
        descrLabel.textColor = dataset.textColor;
        descrLabel.font = dataset.textFont;
        descrLabel.alpha = 0;
        self.view.addSubview(descrLabel);
        return self;
    }
    
    fileprivate func resolveCircleFramer() -> Self {
        if circleFramer.superview != nil { return self }
        circleFramer.frame.size = CGSize(
            width: dataset.spotlightRadius * 2,
            height: dataset.spotlightRadius * 2);
        self.view.addSubview(circleFramer);
        circleFramer.alpha = 0;
        circleFramer.layer.cornerRadius = dataset.spotlightRadius;
        circleFramer.layer.borderColor = dataset.spotlightBorderColor.cgColor;
        circleFramer.layer.borderWidth = dataset.spotlightBorderWidth;
        return self;
    }
    
    fileprivate func finalizeView() {
        self.stateMachine.view = self;
        self.stateMachine.dataset = dataset;
        darkOverlay.isUserInteractionEnabled = true;
        let recognizer = UITapGestureRecognizer(
            target: self, action: #selector(windowTapped));
        darkOverlay.addGestureRecognizer(recognizer);
        stateMachine.toggleState();
    }
    
    /// Event triggered when any point is tapped
    @objc func windowTapped() {
        stateMachine.toggleState();
    }
}

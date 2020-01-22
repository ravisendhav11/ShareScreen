//
//  ScreenShare.swift
//  ShareScreen
//
//  Created by Ravi's MacBook Pro on 21/01/20.
//  Copyright © 2020 Ravi's MacBook. All rights reserved.
//

import Foundation
import ReplayKit

public class ScreenShare: UIView {
    
    let nibName = "ScreenShare"
    var contentView: UIView!
    var bundleIdentifire = ""

    // Set Up View
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.nibName, bundle: bundle)
        self.contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        addSubview(contentView)
        
        if #available(iOS 12.0, *) {
            let broadcastPicker = RPSystemBroadcastPickerView(frame: CGRect(x: 200, y: 200, width: 50, height: 50))
            broadcastPicker.preferredExtension = bundleIdentifire
            // broadcastPicker.preferredExtension = "com.innoeye.ScreenShareReplayKitExtension"
            self.contentView.addSubview(broadcastPicker)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func btnCancel_Action(_ sender: UIButton) {
        removeSelf()
    }

    // Allow view to control itself
    public override func layoutSubviews() {
        // Rounded corners
        self.layoutIfNeeded()
    }
    
    public override func didMoveToSuperview() {
        // Fade in when added to superview
        // Then add a timer to remove the view
        self.contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.15, animations: {
            self.contentView.alpha = 1.0
            self.contentView.transform = CGAffineTransform.identity
        }) { _ in

        }
    }
    
    @objc private func removeSelf() {
        UIView.animate(withDuration: 0.15, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.contentView.alpha = 0.0
        }) { _ in
            self.removeFromSuperview()
        }
    }

}

//
//  ViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 9/16/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import UIKit
import GoogleCast


class ViewController: UIViewController
{

    @IBOutlet var chromecastButton: GCKUICastButton!

    @IBOutlet var chromecastButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var chromecastButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet var errorLabel: UILabel!

    let kMinimumButtonSize = CGSize(width: 44, height: 44)

    override func viewDidLoad()
    {
        NotificationCenter.default.addObserver(self, selector: #selector( didGetChromecastSessionError ), name: NSNotification.Name.init("SessionDidFailtoStartNotification"), object: nil)

        self.errorLabel.text = nil

        // Do a size based on an autolayout pass. This may not have happened yet when viewDidLoad is first called.
        let buttonSize = self.chromecastButton.systemLayoutSizeFitting(self.view.frame.size)

        // Eenforce a minimum size for the Chromecast button, which Apple says should
        // be at least 44px X 44px.
        let newButtonSize = CGSize( width:  max(buttonSize.width,  kMinimumButtonSize.width),
                                    height: max(buttonSize.height, kMinimumButtonSize.height))

        self.chromecastButtonWidthConstraint.constant = newButtonSize.width
        self.chromecastButtonHeightConstraint.constant = newButtonSize.height
    }

    @objc func didGetChromecastSessionError(notification: NSNotification)
    {
        NSLog("Got notification:\n%@\n", notification)

        let notifError: Error = notification.object as! Error

        self.errorLabel.text = notifError.localizedDescription
    }
}


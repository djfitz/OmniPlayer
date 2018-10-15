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


    let kMinimumButtonSize = CGSize(width: 44, height: 44)

    override func viewDidLoad()
    {
        // Do a size based on an autolayout pass. This may not have happened yet when viewDidLoad is first called.
        let buttonSize = self.chromecastButton.systemLayoutSizeFitting(self.view.frame.size)

        // Eenforce a minimum size for the Chromecast button, which Apple says should
        // be at least 44px X 44px.
        let newButtonSize = CGSize( width:  max(buttonSize.width,  kMinimumButtonSize.width),
                                    height: max(buttonSize.height, kMinimumButtonSize.height))

        self.chromecastButtonWidthConstraint.constant = newButtonSize.width
        self.chromecastButtonHeightConstraint.constant = newButtonSize.height
    }
}


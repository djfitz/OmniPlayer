//
//  ViewController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 9/16/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import UIKit
import GoogleCast
import AVFoundation
import MediaPlayer


class ViewController: UIViewController
{
    let airplayButton = MPVolumeView.init()

//    @IBOutlet var chromecastButton: GCKUICastButton!
//
//    @IBOutlet var chromecastButtonWidthConstraint: NSLayoutConstraint!
//    @IBOutlet var chromecastButtonHeightConstraint: NSLayoutConstraint!
//
//    @IBOutlet var errorLabel: UILabel!

    let kMinimumButtonSize = CGSize(width: 44, height: 44)

    @objc func airplayRoutesAvailableNotification( notif: Notification)
    {
        if self.airplayButton.areWirelessRoutesAvailable
        {
            airplayButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        }
        else
        {
            airplayButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()


        NotificationCenter.default.addObserver(self, selector: #selector( airplayRoutesAvailableNotification ), name: Notification.Name.MPVolumeViewWirelessRoutesAvailableDidChange, object: nil)

        let customLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20))
        customLabel.textColor = UIColor.white
        customLabel.font = UIFont.systemFont(ofSize: 19)
        customLabel.text = "Very Long Ago S3:E5 ‟For the top to show the world〞"
        customLabel.textAlignment = .left
        self.navigationItem.titleView = customLabel

        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white

        let chromecastButton = GCKUICastButton.init(frame: CGRect(x: 0, y: 0, width: 40, height: 34))
        chromecastButton.tintColor = UIColor.white
        let chromecastBarButton = UIBarButtonItem.init(customView: chromecastButton)
        chromecastBarButton.tintColor = UIColor.white

        self.airplayButton.showsVolumeSlider = false
        self.airplayButton.showsRouteButton = true
        self.airplayButton.tintColor = UIColor.white

        if self.airplayButton.areWirelessRoutesAvailable
        {
            self.airplayButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        }

        let airplayButtonBar = UIBarButtonItem.init(customView: self.airplayButton)
        airplayButtonBar.tintColor = UIColor.white

        // Slider
        let volumeSlider = UISlider.init()
        volumeSlider.setThumbImage(UIImage.init(named: "VolumeIcon"), for: .normal)
        volumeSlider.setThumbImage(UIImage.init(named: "VolumeIcon"), for: .highlighted)
        volumeSlider.maximumTrackTintColor = UIColor.init(white: 0.25, alpha: 1)
        volumeSlider.widthAnchor.constraint(equalToConstant: 150).isActive = true

        let volumeBarButton = UIBarButtonItem.init(customView: volumeSlider)

        self.navigationItem.rightBarButtonItems =
            [
                volumeBarButton,
                chromecastBarButton,
                airplayButtonBar
            ]
    }

//    override func viewDidLoad()
//    {
//        NotificationCenter.default.addObserver(self, selector: #selector( didGetChromecastSessionError ), name: NSNotification.Name.init("SessionDidFailtoStartNotification"), object: nil)
//
//        self.errorLabel.text = nil
//
//        // Do a size based on an autolayout pass. This may not have happened yet when viewDidLoad is first called.
//        let buttonSize = self.chromecastButton.systemLayoutSizeFitting(self.view.frame.size)
//
//        // Eenforce a minimum size for the Chromecast button, which Apple says should
//        // be at least 44px X 44px.
//        let newButtonSize = CGSize( width:  max(buttonSize.width,  kMinimumButtonSize.width),
//                                    height: max(buttonSize.height, kMinimumButtonSize.height))
//
//        self.chromecastButtonWidthConstraint.constant = newButtonSize.width
//        self.chromecastButtonHeightConstraint.constant = newButtonSize.height
//    }

    @objc func didGetChromecastSessionError(notification: NSNotification)
    {
        NSLog("Got notification:\n%@\n", notification)

        let notifError: Error = notification.object as! Error

//        self.errorLabel.text = notifError.localizedDescription
    }
}


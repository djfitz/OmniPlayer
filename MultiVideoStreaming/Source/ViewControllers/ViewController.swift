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
//    let airplayButton =

    var player: AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil

    var childPlayerViewController: RealUIViewController? = nil

    let kMinimumButtonSize = CGSize(width: 44, height: 44)

    // * prepare(for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("\(segue.destination)")
        
        if segue.destination is RealUIViewController
        {
            self.childPlayerViewController = segue.destination as? RealUIViewController
        }
    }


    // * startPlayback
    func startPlayback()
    {

    }

    deinit
    {
        self.childPlayerViewController = nil
    }
 
    // * updateAirplayButtonVisibility
    func updateAirplayButtonVisibility()
    {

    }

    // * sessionInterrupted
    @objc func sessionInterrupted( notif: Notification)
    {
        print("\(notif)")
    }


    // * viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()

//        NotificationCenter.default.addObserver(self, selector: #selector( sessionInterrupted ), name: AVAudioSession.interruptionNotification, object: nil)

        let customLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20))
        customLabel.textColor = UIColor.white
        customLabel.font = UIFont.systemFont(ofSize: 19)
        customLabel.text = "Very Long Ago S3:E5 ‟For the top to show the world〞"
        customLabel.textAlignment = .center
        self.navigationItem.titleView = customLabel

        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white

        self.updateAirplayButtonVisibility()

        // Slider
        let volumeSlider = UISlider.init()
        volumeSlider.setThumbImage(UIImage.init(named: "VolumeIcon"), for: .normal)
        volumeSlider.setThumbImage(UIImage.init(named: "VolumeIcon"), for: .highlighted)
        volumeSlider.maximumTrackTintColor = UIColor.init(white: 0.25, alpha: 1)
        volumeSlider.widthAnchor.constraint(equalToConstant: 150).isActive = true

        let chromecastButton = ChromecastManager.mgr.remoteDevicePickerButton
        let airplayButton = AVFoundationMediaPlayerManager.mgr.remoteDevicePickerButton
        let sv = UIStackView.init(arrangedSubviews: [chromecastButton, airplayButton, volumeSlider])
        sv.axis = .horizontal
        sv.spacing = 30

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sv)

//        let chromecastBarButton = UIBarButtonItem.init(customView: ChromecastManager.mgr.remoteDevicePickerButton)
//        chromecastBarButton.tintColor = UIColor.white
//
//        let airplayButtonBar = UIBarButtonItem.init(customView: AVFoundationMediaPlayerManager.mgr.remoteDevicePickerButton)
//        airplayButtonBar.tintColor = UIColor.white
//
//        let volumeBarButton = UIBarButtonItem.init(customView: volumeSlider)
//
//        self.navigationItem.rightBarButtonItems =
//            [
//                volumeBarButton,
//                chromecastBarButton,
//                airplayButtonBar
//            ]

        self.startPlayback()
    }

//    override func viewDidLoad()
//    {
//        NotificationCenter.default.addObserver(self, selector: #selector( didGetChromecastSessionError ), name: NSNotification.Name.init("SessionDidFailtoStartNotification"), object: nil)
//
//        self.errorLabel.text = nil
//
//        // Do a size based on an autolayout pass. This may not have happened yet for these subviews when viewDidLoad is
//        // first called.
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

    // * didGetChromecastSessionError
    @objc func didGetChromecastSessionError(notification: NSNotification)
    {
        NSLog("Got notification:\n%@\n", notification)

        // let notifError: Error = notification.object as! Error

        // self.errorLabel.text = notifError.localizedDescription
    }
}



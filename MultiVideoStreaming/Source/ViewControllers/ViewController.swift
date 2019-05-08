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

    var player: AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil

//    @IBOutlet var chromecastButton: GCKUICastButton!
//
//    @IBOutlet var chromecastButtonWidthConstraint: NSLayoutConstraint!
//    @IBOutlet var chromecastButtonHeightConstraint: NSLayoutConstraint!
//
//    @IBOutlet var errorLabel: UILabel!

    let kMinimumButtonSize = CGSize(width: 44, height: 44)

    @objc func airplayRoutesAvailableNotification( notif: Notification)
    {
        self.updateAirplayButtonVisibility()
    }

    @objc func airplayRouteChangedNotification( notif: Notification)
    {
        self.updateAirplayButtonVisibility()

        if self.airplayButton.isWirelessRouteActive
        {
            self.startPlayback()
        }
    }

    func startPlayback()
    {
        let url = URL.init(string: "http://10.0.0.245:8080/camera/livestream.m3u8")!
//        let url = URL.init(fileURLWithPath: "http://breaqz.com/movies/Lego911gt3.mov")
        self.playerItem = AVPlayerItem.init(url: url)
        self.player = AVPlayer.init(playerItem: self.playerItem)
        self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main, using:
        { (time:CMTime) in
            print("\(time)")
        })

        self.playerItem?.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        self.player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
    }

    @objc override func observeValue(forKeyPath keyPath: String?,
                                     of object: Any?,
                                     change: [NSKeyValueChangeKey : Any]?,
                                     context: UnsafeMutableRawPointer?)
    {
        let changeKey = change?.keys.first
        let vals = change?.values
//        let z = change.keys[0]
        
        print("Update to Observed Value\nObject:\n\(String(describing: vals))\nChange:\n\(String(describing: change))\n\n")

        let statusDesc = MultiVideoStreaming.description(for: self.player?.status ?? .unknown)
        let timeControlDesc = MultiVideoStreaming.description(for: self.player?.timeControlStatus ?? .waitingToPlayAtSpecifiedRate)

        print("Duration:\(String(describing: self.playerItem?.duration))\nRate:\(String(describing: self.player?.rate))\nStatus:\(statusDesc)\nTime Control Status: \(timeControlDesc)\n\n")

        if self.player?.status == .readyToPlay && self.player?.rate == 0
        {
            self.player?.play()
        }
    }

    func updateAirplayButtonVisibility()
    {
        if self.airplayButton.areWirelessRoutesAvailable
        {
//            airplayButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        }
        else
        {
//            airplayButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }

    @objc func sessionInterrupted( notif: Notification)
    {
        print("\(notif)")
    }


    override func viewDidLoad()
    {
        super.viewDidLoad()


        NotificationCenter.default.addObserver(self, selector: #selector( airplayRoutesAvailableNotification ), name: Notification.Name.MPVolumeViewWirelessRoutesAvailableDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( airplayRouteChangedNotification ), name: Notification.Name.MPVolumeViewWirelessRouteActiveDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( sessionInterrupted ), name: AVAudioSession.interruptionNotification, object: nil)

        let customLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20))
        customLabel.textColor = UIColor.white
        customLabel.font = UIFont.systemFont(ofSize: 19)
        customLabel.text = "Very Long Ago S3:E5 ‟For the top to show the world〞"
        customLabel.textAlignment = .left
        self.navigationItem.titleView = customLabel

        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white

        let chromecastButton = GCKUICastButton.init(frame: CGRect(x: 0, y: 0, width: 40, height: 34))
        chromecastButton.tintColor = UIColor.white

        self.airplayButton.showsVolumeSlider = false
        self.airplayButton.showsRouteButton = true
        self.airplayButton.tintColor = UIColor.white

        self.updateAirplayButtonVisibility()

        // Slider
        let volumeSlider = UISlider.init()
        volumeSlider.setThumbImage(UIImage.init(named: "VolumeIcon"), for: .normal)
        volumeSlider.setThumbImage(UIImage.init(named: "VolumeIcon"), for: .highlighted)
        volumeSlider.maximumTrackTintColor = UIColor.init(white: 0.25, alpha: 1)
        volumeSlider.widthAnchor.constraint(equalToConstant: 150).isActive = true


        let sv = UIStackView.init(arrangedSubviews: [chromecastButton, airplayButton, volumeSlider])
        sv.axis = .horizontal
        sv.spacing = 30

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sv)

        self.startPlayback()

//        let chromecastBarButton = UIBarButtonItem.init(customView: chromecastButton)
//        chromecastBarButton.tintColor = UIColor.white
//        let airplayButtonBar = UIBarButtonItem.init(customView: self.airplayButton)
//        airplayButtonBar.tintColor = UIColor.white
//        let volumeBarButton = UIBarButtonItem.init(customView: volumeSlider)

//        self.navigationItem.rightBarButtonItems =
//            [
//                volumeBarButton,
//                chromecastBarButton,
//                airplayButtonBar
//            ]
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

    @objc func didGetChromecastSessionError(notification: NSNotification)
    {
        NSLog("Got notification:\n%@\n", notification)

        // let notifError: Error = notification.object as! Error

        // self.errorLabel.text = notifError.localizedDescription
    }
}


//// ========

func description( for playerStatus: AVPlayer.Status ) -> String
{
    switch playerStatus
    {
        case .unknown:
            return "Unknown"

        case .failed:
            return "Unknown"

        case .readyToPlay:
            return "Ready to Play"
    }
}

func description( for timeControlStatus: AVPlayer.TimeControlStatus ) -> String
{
    switch timeControlStatus
    {
        case .paused:
            return "Paused"

        case .playing:
            return "Playing"

        case .waitingToPlayAtSpecifiedRate:
            return "Waiting for Rate"
    }
}


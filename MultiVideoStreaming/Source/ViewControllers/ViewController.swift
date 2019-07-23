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
    var childPlayerViewController: MediaControlsViewController? = nil

    // * prepare(for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("\(segue.destination)")
        
        if segue.destination is MediaControlsViewController
        {
            self.childPlayerViewController = segue.destination as? MediaControlsViewController
        }
    }


    // * startPlayback
    func startPlayback()
    {
        let url = URL.init(string: "http://breaqz.com/movies/Lego911gt3.mov")!
//        let url = URL.init(string: "http://10.0.0.245:8080/camera/livestream.m3u8")!

//        let url = URL.init(string: "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8")!
        let item = MediaItem.init(title: "Zelo - Boss Video Productions", url: url)
        AVFoundationMediaPlayerManager.mgr.load(mediaItem: item)
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



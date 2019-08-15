//
//  ViewController.swift
//  DemoAppFrameworked
//
//  Created by Doug Hill on 8/15/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

import MultiVideoPlayer
//import GoogleCast


class ViewController: UIViewController
{
    var mediaURL:URL? = nil

    override var prefersHomeIndicatorAutoHidden:Bool
    {
        get
        {
            return true
        }
    }

    deinit
    {
        MediaPlayerManager.mgr.stop()
    }

    // * viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.edgesForExtendedLayout = .all

        self.startPlayback()
    }


    // * startPlayback
    func startPlayback()
    {
        if let url = self.mediaURL
        {
            let item = MediaItem.init(title: "Zelo - Boss Video Productions", url: url)
   
            MediaPlayerManager.mgr.load(mediaItem: item)
        }
    }
}

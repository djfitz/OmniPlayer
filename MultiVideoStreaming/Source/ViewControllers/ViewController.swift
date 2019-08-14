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
import MultiVideoPlayer

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

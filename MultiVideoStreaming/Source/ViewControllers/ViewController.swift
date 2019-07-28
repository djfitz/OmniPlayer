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
    var mediaURL:URL? = nil

    // * viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()

         self.startPlayback()
    }


    // * startPlayback
    func startPlayback()
    {
//        let url = URL.init(string: "http://breaqz.com/movies/Lego911gt3.mov")!
//        let url = URL.init(string: "http://10.0.0.245:8080/camera/livestream.m3u8")!
//        let url = URL.init(string: "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8")!

//        let url = URL.init(string: "http://csm-e.cds1.yospace.com/csm/live/74246610.m3u8")!

        if let url = self.mediaURL
        {
            let item = MediaItem.init(title: "Zelo - Boss Video Productions", url: url)
            
            AVFoundationMediaPlayerManager.mgr.load(mediaItem: item)
        }
    }
}



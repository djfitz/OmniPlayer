//
//  AVPlayerView.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 5/9/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit
import AVFoundation

@objc public class AVPlayerView: UIView
{
    override public class var layerClass: AnyClass {
      return AVPlayerLayer.self
    }

    public var playerLayer: AVPlayerLayer
    {
        return layer as! AVPlayerLayer
    }

    public var player: AVPlayer?
    {
        get
        {
            return playerLayer.player
        }

        set
        {
            playerLayer.player = newValue
        }
    }
}

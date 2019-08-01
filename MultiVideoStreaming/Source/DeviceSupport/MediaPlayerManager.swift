//
//  MediaPlayerManager.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 7/28/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import AVFoundation
import CoreFoundation

class MediaPlayerManager: NSObject, MediaPlayerGeneric
{
    // MARK: - Static Manager

    static let mgr = MediaPlayerManager()

    // MARK: - Media Playback Engines
    
    let avFoundationPlayer = AVFoundationMediaPlayerManager()
    let chromecastPlayer = ChromecastManager()

    var currentPlayer:MediaPlayerGeneric = AVFoundationMediaPlayerManager()

    // * init
    override init()
    {
        super.init()

        self.avFoundationPlayer.beginSearchForRemoteDevices()
        self.chromecastPlayer.beginSearchForRemoteDevices()

        self.switchPlayback(to: self.avFoundationPlayer)
    }

    // * switchPlayback
    //
    // When switching between players, try to resume in
    // the last watched place.
    // However, always try to start playback on the new
    // player, even if the other player
    func switchPlayback( to player: MediaPlayerGeneric )
    {
        let loadingItem = self.loadingMediaItem
        let currentlyLoadedMediaItem = self.currentMediaItem
        let currentTime = self.currentOffset

        self.stopObserving(player: self.currentPlayer)
        
        self.beginObserving(player: player)

        self.currentPlayer = player

        if let litem = loadingItem
        {
            player.load(mediaItem: litem, startingAt: CMTime.zero)
        }
        else if let currentItem = currentlyLoadedMediaItem
        {
            player.load(mediaItem: currentItem, startingAt: currentTime)
        }
    }

    // * beginObserving
    func beginObserving( player: MediaPlayerGeneric )
    {
        if let daPlayer = player as? AVFoundationMediaPlayerManager
        {
            if daPlayer == self.avFoundationPlayer
            {
                self.beginObservingAVFoundation()
            }
        }
        else if let daPlayer = player as? ChromecastManager
        {
            if daPlayer == self.chromecastPlayer
            {
                self.beginObservingChromecast()
            }
        }
    }

    // * beginObservingAVFoundation
    func beginObservingAVFoundation()
    {
        self.avFoundationPlayer.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.avFoundationPlayer.addObserver(self, forKeyPath: "loadingMediaItem", options: .new, context: nil)
        self.avFoundationPlayer.addObserver(self, forKeyPath: "currentMediaItem", options: .new, context: nil)
        self.avFoundationPlayer.addObserver(self, forKeyPath: "currentOffset", options: .new, context: nil)
        self.avFoundationPlayer.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        self.avFoundationPlayer.addObserver(self, forKeyPath: "playbackRate", options: .new, context: nil)
        self.avFoundationPlayer.addObserver(self, forKeyPath: "isSeeking", options: .new, context: nil)
    }

    // * beginObservingChromecast
    func beginObservingChromecast()
    {
        self.chromecastPlayer.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.chromecastPlayer.addObserver(self, forKeyPath: "loadingMediaItem", options: .new, context: nil)
        self.chromecastPlayer.addObserver(self, forKeyPath: "currentMediaItem", options: .new, context: nil)
        self.chromecastPlayer.addObserver(self, forKeyPath: "currentOffset", options: .new, context: nil)
        self.chromecastPlayer.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        self.chromecastPlayer.addObserver(self, forKeyPath: "playbackRate", options: .new, context: nil)
        self.chromecastPlayer.addObserver(self, forKeyPath: "isSeeking", options: .new, context: nil)
    }

    // * stopObserving
    func stopObserving( player: MediaPlayerGeneric )
    {
        if let oldPlayer = player as? AVFoundationMediaPlayerManager
        {
            if oldPlayer == self.avFoundationPlayer
            {
                self.stopObservingAVFoundation()
            }
        }
        else if let oldPlayer = player as? ChromecastManager
        {
            if oldPlayer == self.chromecastPlayer
            {
                self.stopObservingChromecast()
            }
        }
    }

    // * stopObservingAVFoundation
    func stopObservingAVFoundation()
    {
        self.avFoundationPlayer.removeObserver(self, forKeyPath: "status")
        self.avFoundationPlayer.removeObserver(self, forKeyPath: "loadingMediaItem")
        self.avFoundationPlayer.removeObserver(self, forKeyPath: "currentMediaItem")
        self.avFoundationPlayer.removeObserver(self, forKeyPath: "currentOffset")
        self.avFoundationPlayer.removeObserver(self, forKeyPath: "duration")
        self.avFoundationPlayer.removeObserver(self, forKeyPath: "playbackRate")
        self.avFoundationPlayer.removeObserver(self, forKeyPath: "isSeeking")
    }

    // * stopObservingChromecast
    func stopObservingChromecast()
    {
        self.chromecastPlayer.removeObserver(self, forKeyPath: "status")
        self.chromecastPlayer.removeObserver(self, forKeyPath: "loadingMediaItem")
        self.chromecastPlayer.removeObserver(self, forKeyPath: "currentMediaItem")
        self.chromecastPlayer.removeObserver(self, forKeyPath: "currentOffset")
        self.chromecastPlayer.removeObserver(self, forKeyPath: "duration")
        self.chromecastPlayer.removeObserver(self, forKeyPath: "playbackRate")
        self.chromecastPlayer.removeObserver(self, forKeyPath: "isSeeking")
    }

    // ============================
    // Generic Player Interface
    // ============================


    // MARK: - Generic Player Properties

    @objc dynamic var status: PlaybackStatus = .unknown

    @objc dynamic var loadingMediaItem: MediaItem? = nil
    
    @objc dynamic var currentMediaItem: MediaItem? = nil
    
    @objc dynamic var currentOffset: CMTime = CMTime.invalid

    @objc dynamic var duration: CMTime = CMTime.invalid
    
    @objc dynamic var playbackRate: Double = Double.nan

    @objc dynamic var isSeeking: Bool = false
    
    
    // MARK: - Generic Player Methods


    func load(mediaItem: MediaItem)
    {
        self.load(mediaItem: mediaItem, startingAt: CMTime.zero)
    }

    func load(mediaItem: MediaItem, startingAt time: CMTime)
    {
        self.currentPlayer.load(mediaItem: mediaItem, startingAt: time)
    }

    func play()
    {
        self.currentPlayer.play()
    }
    
    func pause()
    {
        self.currentPlayer.pause()
    }
    
    func stop()
    {
        self.currentPlayer.stop()
    }
    
    func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void)
    {
        self.currentPlayer.seek(to: time, completionHandler: completionHandler)
    }
    
    func skip(forward seconds: CMTime)
    {
        self.currentPlayer.skip(forward: seconds)
    }
    
    func skip(back seconds: CMTime)
    {
        self.currentPlayer.skip(back: seconds)
    }


    // ==============================================================
    // MARK: - Property Observers
    // ==============================================================


    // * observeValue(forKeyPath…)
    @objc override func observeValue(forKeyPath keyPath: String?,
                                     of object: Any?,
                                     change: [NSKeyValueChangeKey : Any]?,
                                     context: UnsafeMutableRawPointer?)
    {
        print("\n**************************************")
        print("Observed Value change: \(keyPath!)")
        print("Object: \(object!)")
        print("Kind: \(change![NSKeyValueChangeKey.kindKey]!)")
        print("New Value: \(change![NSKeyValueChangeKey.newKey]!)")

        if keyPath == "status"
        {
            if let newStatusInt = change?[NSKeyValueChangeKey.newKey] as? Int
            {
                self.status = PlaybackStatus(rawValue: newStatusInt) ?? .unknown

                print("New Status: \(self.status.rawValue)")
            }
        }
        else if keyPath == "currentOffset"
        {
            if let newCurrentTime = change?[NSKeyValueChangeKey.newKey] as? CMTime
            {
                print("New Current Offset: \(newCurrentTime.seconds)")

                self.currentOffset = newCurrentTime
            }
        }
        else if keyPath == "loadingMediaItem"
        {
            if let newLoadingItem = change?[NSKeyValueChangeKey.newKey] as? MediaItem
            {
                print("New Media Item is being loaded: \(newLoadingItem)")

                self.loadingMediaItem = newLoadingItem
            }
        }
        else if keyPath == "currentMediaItem"
        {
            if let newCurrentItem = change?[NSKeyValueChangeKey.newKey] as? MediaItem
            {
                print("Current Media Item Changed: \(newCurrentItem)")

                self.currentMediaItem = newCurrentItem
            }
        }
        else if keyPath == "duration"
        {
            if let newDuration = change?[NSKeyValueChangeKey.newKey] as? CMTime
            {
                print("New Duration: \(newDuration)")

                self.duration = newDuration
            }
        }
        else if keyPath == "playbackRate"
        {
            if let newRate = change?[NSKeyValueChangeKey.newKey] as? Double
            {
                print("New Playback Rate: \(newRate)")

                self.playbackRate = newRate
            }
        }
        else if keyPath == "isSeeking"
        {
            if let newIsSeeking = change?[NSKeyValueChangeKey.newKey] as? Bool
            {
                print("Player is Seeking: \(newIsSeeking)")

                self.isSeeking = newIsSeeking
            }
        }

        print("**************************************")
    }
}

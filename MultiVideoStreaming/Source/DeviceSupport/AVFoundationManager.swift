//
//  AVFoundationManager.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 9/18/18.
//  Copyright © 2018 doughill. All rights reserved.
//


import AVFoundation
import MediaPlayer



class AVFoundationMediaPlayerManager : NSObject,
                                       MediaPlayerGeneric,
                                       RemoteMediaPlayback,
                                       MediaPlaybackQueue
{
    static var showLogMessages = false

    func log(msg: String)
    {
        if AVFoundationMediaPlayerManager.showLogMessages
        {
            print("\(msg)")
        }
    }

    // MARK: ** Generic Media Player

    /// Setting the offset will perform a seek operation.
    @objc dynamic var status: PlaybackStatus = .unknown

    @objc dynamic var currentOffset:CMTime = CMTime.invalid

    @objc dynamic var duration:CMTime = CMTime.invalid

    /// The rate of the playback as a fractional amount. Also known as the playback speed.
    /// Can be observed for when rate changes.
    /// 0 = stopped, 1 = Default playback rate, 2 = Double speed playback
    /// NOTE: Not all media players can support non-whole fractional amounts.
    @objc dynamic var playbackRate: Double = 0

    // Whether there is a seek in progress.
    @objc dynamic var isSeeking = false

    // MARK: Playback Queue

    func addItem(at index: Int)
    {
//        #warning("fill me in")
    }

    func addToEnd(mediaItems: [MediaItem])
    {
//        #warning("fill me in")
    }

    @objc dynamic var currentMediaItem: MediaItem?

    @objc dynamic var loadingMediaItem: MediaItem?

    var currentPlaybackQueueIndex: Int?
    {
        didSet
        {
            if let newIdx = self.currentPlaybackQueueIndex, newIdx > 0, newIdx < self.playlist.count
            {
                self.load(mediaItem: playlist[newIdx])
            }
        }
    }

    var playlist: [MediaItem] = []
    {
        didSet
        {
            self.stop()

            self.playlistUpdated()
        }
    }

    func playlistUpdated()
    {
        // Start playback from the first item.
//        if self.playlist.count > 0
//        {
//            self.skipToMediaItem(at: 0)
//        }
    }

    func removeLast() {
//        #warning("fill me in")
    }

    func removeFirst() {
//        #warning("fill me in")
    }

    func removeItem(at index: Int) {
//        #warning("fill me in")
    }

    func next()
    {
        if let currentIdx = self.currentPlaybackQueueIndex, currentIdx < (self.playlist.count - 1)
        {
            self.skipToMediaItem(at: currentIdx + 1)
        }
        // If no current queue item, do nothing.
        // If already at beginning of the queue, do nothing.
    }

    func previous()
    {
        if let currentIdx = self.currentPlaybackQueueIndex, currentIdx > 0
        {
            self.skipToMediaItem(at: currentIdx - 1)
        }
        // If no current queue item, do nothing.
        // If already at beginning of the queue, do nothing.
    }

    func skipToMediaItem(at index: Int)
    {
        self.currentPlaybackQueueIndex = index
        self.load(mediaItem: playlist[index])
    }

    // MARK: Remote Media Playback
    var remoteDevicesList: [PlaybackDevice] = []

    var currentlySelectedDevice: PlaybackDevice? = nil

    var remoteDevicePickerButton: UIView? = MPVolumeView()

    func beginSearchForRemoteDevices()
    {
        NotificationCenter.default.addObserver(self, selector: #selector( airplayRoutesAvailableNotification ), name: Notification.Name.MPVolumeViewWirelessRoutesAvailableDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( airplayRouteChangedNotification ), name: Notification.Name.MPVolumeViewWirelessRouteActiveDidChange, object: nil)
    }

    @objc func airplayRoutesAvailableNotification( notif: Notification)
    {
        self.log(msg: "Airplay Route Changed:\n\(notif)")
//        self.updateAirplayButtonVisibility()
    }

    // * airplayRouteChangedNotification
    @objc func airplayRouteChangedNotification( notif: Notification)
    {
        self.log(msg: "Airplay Route Changed:\n\(notif)")

//        if let isWirelessRouteActive = self.remoteDevicePickerButton.isWirelessRouteActive
//        {
//            if self.
//        }
    }

    // MARK: AVFoundation Objects
    let player: AVPlayer = AVPlayer()
    private var playerItem: AVPlayerItem? = nil

    // MARK: ** Methods

    override init()
    {
        super.init()

        AVFoundationMediaPlayerManager.showLogMessages = true

        self.setupAVFoundationPlayer()
    }

    deinit
    {
        self.player.pause()

        self.player.removeObserver(self, forKeyPath: "rate")
        self.player.removeObserver(self, forKeyPath: "timeControlStatus")

        self.player.removeTimeObserver(self)

        NotificationCenter.default.removeObserver(self)
    }

    func setupAVFoundationPlayer()
    {
        if let airplayButton = self.remoteDevicePickerButton as? MPVolumeView
        {
            airplayButton.showsVolumeSlider = false
        }

        self.player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        self.player.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)

        self.player
            .addPeriodicTimeObserver(
                forInterval: CMTime.init(seconds: 1, preferredTimescale: CMTimeScale(1 * 100)),
                queue: DispatchQueue.main,
                using:
                { (time:CMTime) in
                    self.currentOffset = time
                }
            )

        NotificationCenter.default.addObserver(self, selector: #selector( sessionInterrupted ), name: AVAudioSession.interruptionNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector( mediaDidToPlayToEndTime ), name: .AVPlayerItemDidPlayToEndTime , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( mediaFailedToPlayToEndTime ), name: .AVPlayerItemFailedToPlayToEndTime , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( mediaPlaybackTimeJumped ), name: .AVPlayerItemTimeJumped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( mediaPlaybackStalled ), name: .AVPlayerItemPlaybackStalled , object: nil)

        self.beginSearchForRemoteDevices()
    }

    // MARK: ** Generic Media Player

    /**
        Prepare the media item for playback.

        - Parameters:
            - mediaItem: A URL to the media item. This could be a local or remote URL.
                         NOTE: Not all media players support both local and remote URLs.
                         Check the documentation for the media player to determine which
                         it supports.
                         NOTE2: Media players have a supported set of media types that they
                         can play. Check with the media player documentaiton to determine
                         which it supports.
    */
    func load( mediaItem: MediaItem )
    {
        self.load(mediaItem: mediaItem, startingAt: CMTime.zero)
    }

    func load(mediaItem: MediaItem, startingAt time: CMTime)
    {
        if let airplayButton = self.remoteDevicePickerButton as? MPVolumeView
        {
            airplayButton.showsVolumeSlider = false
        }

        let url = mediaItem.url
        self.loadingMediaItem = mediaItem
        self.currentMediaItem = nil
        self.status = .loading

        // Create the new player item for this media.

        // * First some paraoia cleanup.
        self.playerItem?.removeObserver(self, forKeyPath: "duration")
        self.playerItem?.removeObserver(self, forKeyPath: "status")

        // * Create the new player item
        self.playerItem = AVPlayerItem.init(url: url)
        self.playerItem?.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)

        // Start playing the new media
        self.player.replaceCurrentItem(with: self.playerItem)

        self.seek(to: time, playAfterSeek: true) { (a) in }
    }

    /// Starts playback at the current offset.
    // NOTE: Playback must have already started for Play message to be
    // effective.

    func play()
    {
        self.status = .buffering
        self.player.play()
    }

    /// Pause playback at the current offset.

    func pause()
    {
        self.player.pause()
    }

    /// Stop playback at the current offset.
    /// NOTE: This is potentially different from Pause functionality, depending
    /// on the media player. For example, stop may remove the current media item,
    /// requiring it to be loaded again.

    func stop()
    {
        self.player.replaceCurrentItem(with: nil)
    }


    func seek(to time: CMTime, playAfterSeek: Bool, completionHandler: @escaping (Bool) -> Void)
    {
        self.log( msg:"\n$$$$ >> Starting Seek to time: \(time.seconds) ")
        self.log( msg:"Duration: \(self.player.currentItem!.duration.seconds)")

        self.player.currentItem?.cancelPendingSeeks()

        self.isSeeking = true

//        self.pause()

        self.status = .buffering

        self.player.seek(to: time)
        { (finished) in
            completionHandler(!finished)
            if finished && playAfterSeek
            {
                self.log( msg:"Completed Seek to time: \(time.seconds). Start playback.\n")
                // self.play()
//                self.pause()
            }
            else if !finished
            {
                self.log( msg:"Cancelled Seek to time: \(time.seconds)\n")
//                self.pause()
            }

            self.isSeeking = false
        }
    }

    func skip(forward seconds: CMTime)
    {
        guard let playerItem = self.playerItem else { return }
        if playerItem.duration > playerItem.currentTime() + seconds
        {
            let skipTime = playerItem.currentTime() + seconds

            self.seek(to: skipTime, playAfterSeek: true) { (finished) in }
        }
    }

    func skip(back seconds: CMTime)
    {
        guard let playerItem = self.playerItem else { return }
        if (playerItem.currentTime() - seconds) >= CMTime.zero
        {
            let skipTime = playerItem.currentTime() - seconds

            self.seek(to: skipTime, playAfterSeek: true) { (finished) in }
        }
    }

    // * observeValue(forKeyPath…)
    @objc override func observeValue(forKeyPath keyPath: String?,
                                     of object: Any?,
                                     change: [NSKeyValueChangeKey : Any]?,
                                     context: UnsafeMutableRawPointer?)
    {
        self.log( msg:"\n========================================\n")

        if let objVal = object
        {
            self.log( msg:"Object: \(objVal)")
        }


        if let kindVal = change?[NSKeyValueChangeKey.kindKey]
        {
            self.log( msg:"Kind: \(kindVal)")
        }

        if let newVal = change?[NSKeyValueChangeKey.newKey]
        {
            self.log( msg:"New: \(newVal)")
        }

        if keyPath == "status"
        {
            let playerStatus = self.player.status
            let playerStatusDesc = playerStatus.description()
            let itemStatus = self.player.currentItem?.status
            let itemStatusDesc = itemStatus.debugDescription

            self.log( msg:"Status:\(playerStatusDesc)\n")
            self.log( msg:"Item Status:\(itemStatusDesc)\n")

            switch playerStatus
            {
                case .failed:
                    self.log( msg:"Player Status is Failed")
                    self.status = .failed

                case .readyToPlay:
                    self.log( msg:"Player Status is Ready to Play")
                    if self.currentMediaItem == nil
                    {
                        self.currentMediaItem = self.loadingMediaItem
                    }

                    self.loadingMediaItem = nil
                    self.status = .readyToPlay

                case .unknown:
                    self.log( msg:"Player Status is Unknown")
                    self.status = .unknown

                @unknown default:
                    self.log( msg:"Unknown")
                    self.status = .unknown
            }

            if let validItemStatus = itemStatus
            {
                switch validItemStatus
                {
                    case .failed:
                        self.log( msg:"Player Status is Failed")
                        self.status = .failed

                    case .readyToPlay:
                        self.log( msg:"Player Status is Ready to Play")
                        self.status = .readyToPlay

                    case .unknown:
                        self.log( msg:"Unknown")
                        self.status = .unknown

                    @unknown default:
                        self.log( msg:"Unknown")
                        self.status = .unknown
                }
            }

            // When media is ready to play, send the player a 'play' message.
            if self.player.status == .readyToPlay && self.player.rate == 0
            {
                self.player.playImmediately(atRate: 1)
            }
        }
        else if keyPath == "rate"
        {
            let rt = self.player.rate
            self.log( msg:"New rate is \(rt)")
        }
        else if keyPath == "timeControlStatus"
        {
            let status = self.player.timeControlStatus
            let timeControlDesc = status.description()
            self.log( msg:"Time Control Status: \(timeControlDesc)")

            switch status
            {
                case .paused:
                    if self.status != .playedToEnd
                    {
                        self.status = .paused
                    }
                case .playing:
                    self.status = .playing

                case .waitingToPlayAtSpecifiedRate:
                    self.status = .buffering

                @unknown default:
                    self.log( msg:"Unknown Time Control Status.")
            }
        }
        else if keyPath == "duration"
        {
            self.log( msg:"Duration: \(self.playerItem!.duration.seconds)")

            if let newVal = self.playerItem?.duration
            {
                self.duration = newVal
            }
        }

        self.log( msg:"\n========================================\n\n")
    }

    // * sessionInterrupted
    @objc func sessionInterrupted( notif: Notification)
    {
        self.log( msg:"sessionInterrupted:\n\(notif)")
    }

    @objc func mediaDidToPlayToEndTime( notif: Notification )
    {
        self.status = .playedToEnd
        self.log( msg:"mediaDidToPlayToEndTime")
    }

    @objc func mediaFailedToPlayToEndTime( notif: Notification )
    {
        self.status = .failed
        self.log( msg:"mediaFailedToPlayToEndTime")
    }

    @objc func mediaPlaybackStalled( notif: Notification )
    {
        self.status = .failed
        self.log( msg:"mediaFailedToPlayToEndTime")
    }

    @objc func mediaPlaybackTimeJumped( notif: Notification )
    {
    
    }
}


//// ==============================
// Custom Description methods
//// ==============================


// * description for player status
extension AVPlayer.Status
{
    func description() -> String
    {
        switch self
        {
            case .unknown:
                return "Unknown"

            case .failed:
                return "Failed"

            case .readyToPlay:
                return "Ready to Play"

            @unknown default:
                return "Unknown"
        }
    }
}

// * description for time control status
extension AVPlayer.TimeControlStatus
{
    func description() -> String
    {
        switch self
        {
            case .paused:
                return "Paused"

            case .playing:
                return "Playing"

            case .waitingToPlayAtSpecifiedRate:
                return "Waiting for Rate"

            @unknown default:
                return "Unknown"
        }
    }
}


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
    var isSeeking = false

    @objc public enum Status:Int
    {
        case unknown
        
        case loading

        case readyToPlay

        case playing

        case paused
        
        case buffering

        case playedToEnd

        case failed
    }
    
    @objc dynamic var status:Status = .unknown

    // MARK: Playback Queue

    func addItem(at index: Int)
    {
        #warning("fill me in")
    }
    
    func addToEnd(mediaItems: [MediaItem])
    {
        #warning("fill me in")
    }

    var currentMediaItem: MediaItem?

    var loadingMediaItem: MediaItem?

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
        #warning("fill me in")
    }
    
    func removeFirst() {
        #warning("fill me in")
    }
    
    func removeItem(at index: Int) {
        #warning("fill me in")
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
    
    static let mgr: AVFoundationMediaPlayerManager = AVFoundationMediaPlayerManager.init()

    // MARK: Remote Media Playback
    var remoteDevicesList: [PlaybackDevice] = []
    
    var currentlySelectedDevice: PlaybackDevice? = nil
    
    var remoteDevicePickerButton: UIView = MPVolumeView.init()

    func beginSearchForRemoteDevices()
    {
        NotificationCenter.default.addObserver(self, selector: #selector( airplayRoutesAvailableNotification ), name: Notification.Name.MPVolumeViewWirelessRoutesAvailableDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( airplayRouteChangedNotification ), name: Notification.Name.MPVolumeViewWirelessRouteActiveDidChange, object: nil)
    }

    @objc func airplayRoutesAvailableNotification( notif: Notification)
    {
//        self.updateAirplayButtonVisibility()
    }

    // * airplayRouteChangedNotification
    @objc func airplayRouteChangedNotification( notif: Notification)
    {
//        self.updateAirplayButtonVisibility()

//        if self.airplayButton.isWirelessRouteActive
////        && self.player?.timeControlStatus != .
//        {
//            self.startPlayback()
//        }
    }

    // MARK: AVFoundation Objects
    let player: AVPlayer = AVPlayer()
    var playerItem: AVPlayerItem? = nil

    // MARK: ** Methods

    override init()
    {
        super.init()

        self.setupAVFoundationPlayer()
    }

    deinit
    {
        self.player.pause()

        self.player.removeObserver(self, forKeyPath: "status")
        self.player.removeObserver(self, forKeyPath: "rate")
        self.player.removeObserver(self, forKeyPath: "duration")
        self.player.removeObserver(self, forKeyPath: "timeControlStatus")

        self.player.removeTimeObserver(self)

        NotificationCenter.default.removeObserver(self)
    }

    func setupAVFoundationPlayer()
    {
        self.player.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        self.player.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        self.player.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)

        self.player
            .addPeriodicTimeObserver(
                forInterval: CMTime.init(seconds: 1, preferredTimescale: 1),
                queue: DispatchQueue.main,
                using:
                { (time:CMTime) in
                    NotificationCenter.default.post(name: NSNotification.Name.init("PlaybackTimeObserver"), object: time)
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

    /// Setting the offset will perform a seek operation.
    var currentOffsetSeconds: CMTime = CMTime.invalid

    /// The rate of the playback as a fractional amount. Also known as the playback speed.
    /// Can be observed for when rate changes.
    /// 0 = stopped, 1 = Default playback rate, 2 = Double speed playback
    /// NOTE: Not all media players can support non-whole fractional amounts.
    var playbackRate: Double = 0

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
        let url = mediaItem.url
        self.loadingMediaItem = mediaItem
        self.status = .loading

        // Create the new player item for this media.

        // * First some paraoia cleanup.
        self.playerItem?.removeObserver(self, forKeyPath: "duration")

        // * Create the new player item
        self.playerItem = AVPlayerItem.init(url: url)
        self.playerItem?.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)

        // Start playing the new media
        self.player.replaceCurrentItem(with: self.playerItem)
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
        self.pause()
    }


    func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void)
    {
        self.player.currentItem?.cancelPendingSeeks()

        self.isSeeking = true

        self.pause()
        self.status = .buffering

        self.player.seek(to: time)
        { (cancelled) in
            completionHandler(cancelled)
            self.isSeeking = false
            self.play()
        }
    }

    func skip(forward seconds: CMTime)
    {
        guard let playerItem = self.playerItem else { return }
        if playerItem.duration > playerItem.currentTime() + seconds
        {
            let skipTime = playerItem.currentTime() + seconds

            self.seek(to: skipTime) { (cancelled) in }
        }
    }
    
    func skip(back seconds: CMTime)
    {
        guard let playerItem = self.playerItem else { return }
        if (playerItem.currentTime() - seconds) >= CMTime.zero
        {
            let skipTime = playerItem.currentTime() - seconds

            self.seek(to: skipTime) { (cancelled) in }
        }
    }
    
    // * startPlayback
    func startPlayback()
    {
//        let url = URL.init(string: "http://breaqz.com/movies/Lego911gt3.mov")!
//        let url = URL.init(string: "http://10.0.0.245:8080/camera/livestream.m3u8")!

        let url = URL.init(string: "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8")!
        let item = MediaItem.init(title: "Zelo - Boss Video Productions", url: url)
        self.load(mediaItem: item)
    }

    // * observeValue(forKeyPath…)
    @objc override func observeValue(forKeyPath keyPath: String?,
                                     of object: Any?,
                                     change: [NSKeyValueChangeKey : Any]?,
                                     context: UnsafeMutableRawPointer?)
    {
        print("Observed Value change:\n\(String.init(describing: keyPath))\n")
        print("Object:\n\(String(describing: object))\n")
        print("Change:\n\(String(describing: change))\n")

        if keyPath == "status"
        {
            let playerStatus = self.player.status
            let playerStatusDesc = playerStatus.description()
            let itemStatus = self.player.currentItem?.status
            let itemStatusDesc = itemStatus.debugDescription

            print("Status:\(playerStatusDesc)\n\n")
            print("Item Status:\(itemStatusDesc)\n\n")

            switch playerStatus
            {
                case .failed:
                    print("Player Status is Failed")
                    self.status = .failed

                case .readyToPlay:
                    print("Player Status is Ready to Play")
                    self.currentMediaItem = self.loadingMediaItem
                    self.status = .readyToPlay

                case .unknown:
                    print("Player Status is Unknown")
                    self.status = .unknown

                @unknown default:
                    print("Unknown")
                    self.status = .unknown
            }
            
            if let validItemStatus = itemStatus
            {
                switch validItemStatus
                {
                    case .failed:
                        print("Player Status is Failed")
                        self.status = .failed

                    case .readyToPlay:
                        print("Player Status is Ready to Play")
                        self.status = .readyToPlay

                    case .unknown:
                        print("Unknown")
                        self.status = .unknown

                    @unknown default:
                        print("Unknown")
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
            print("New rate is \(rt)")
        }
        else if keyPath == "timeControlStatus"
        {
            let status = self.player.timeControlStatus
            let timeControlDesc = status.description()
            print("Time Control Status: \(timeControlDesc)\n\n")

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
                    print("Unknown Time Control Status.")
            }
        }
        else if keyPath == "duration"
        {
            print("Duration:\(String(describing: self.playerItem?.duration))\n\n")
        }
    }

    // * sessionInterrupted
    @objc func sessionInterrupted( notif: Notification)
    {
        print("\(notif)")
    }

    @objc func mediaDidToPlayToEndTime( notif: Notification )
    {
        self.status = .playedToEnd
        print("mediaDidToPlayToEndTime")
    }

    @objc func mediaFailedToPlayToEndTime( notif: Notification )
    {
        self.status = .failed
        print("mediaFailedToPlayToEndTime")
    }

    @objc func mediaPlaybackStalled( notif: Notification )
    {
        self.status = .failed
        print("mediaFailedToPlayToEndTime")
    }

    @objc func mediaPlaybackTimeJumped( notif: Notification )
    {
    
    }
}


//// ========

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


/*
////////////////////$$$$$$$$$$$
var gChromecastManager:ChromecastManager? = nil


//class ChromecastSessionState
//{
//    var mediaStatus: GCKMediaStatus? = nil
//
//}

/**

*/


/**
    Manages the interface between the application and the Chromecast SDK.

    Implements most of the delegate/listeners as defined by the SDK.
*/
class ChromecastManager : GCKRemoteMediaClientListener,

    /**
        There are times that we want commands to the Chromecast SDK to be
        executed serially. For example, if the SDK hasn't been initialized
        quickly enough upon app startup, calling SDK methods before it is
        initialized will cause the app to crash.
    */
    var messageQueue = DispatchQueue.init(
                        label: "ChromecastMessageQueue",
                        qos: .background )


    // Setup the Chromecast session.
    static func Setup()
    {
        gChromecastManager = ChromecastManager()
    }

    override init()
    {
        super.init()

        self.setupChromecastSDK()
    }

    func setupChromecastSDK()
    {

    }

//////////////////////

    func sessionManager(_ sessionManager: GCKSessionManager,
                        didFailToStart session: GCKSession,
                        withError error: Error)
    {
        print( "Session Manager: Session Did Fail to Start, with Session with ID: \((session.sessionID != nil) ? session.sessionID! : "no session ID")\nError:\n\(error)" )

        NotificationCenter.default.post(name: NSNotification.Name.init("SessionDidFailtoStartNotification"), object: error)
    }



    func sessionManager(_ sessionManager: GCKSessionManager,
                        didStart session: GCKCastSession)
    {
        session.remoteMediaClient?.add(self)

        NSLog("Session Manager: Cast Session Did Start.\nCast Session ID: %@", (session.sessionID != nil) ? session.sessionID! : 0)

        let md = GCKMediaMetadata.init(metadataType: .movie)
        md.setString("Dumb Title", forKey: kGCKMetadataKeyTitle)
        md.setString("Dumb Studios", forKey: kGCKMetadataKeyStudio)

        let mediaInfo = GCKMediaInformation.init(
                contentID: "http://breaqz.com/movies/Lego911gt3.mov",
                streamType: .buffered,
                contentType: "video/quicktime",
                metadata: md,
                adBreaks: nil,
                adBreakClips: nil,
                streamDuration: 10,
                mediaTracks: nil,
                textTrackStyle: nil,
                customData: nil
            )

        session.remoteMediaClient?.loadMedia(mediaInfo)
    }

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

/////////////////////////////////////////$$$$$$$$$
*/

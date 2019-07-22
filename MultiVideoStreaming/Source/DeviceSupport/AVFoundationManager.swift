//
//  AVFoundationManager.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 9/18/18.
//  Copyright © 2018 doughill. All rights reserved.
//


import AVFoundation
import MediaPlayer


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

class AVFoundationMediaPlayerManager : NSObject,
                                       MediaPlayerGeneric,
                                       RemoteMediaPlayback,
                                       MediaPlaybackQueue
{

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
    var player: AVPlayer = AVPlayer()
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
    }

    func setupAVFoundationPlayer()
    {
        self.player = AVPlayer.init()

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
                    print("\(time)")
                }
            )

        self.beginSearchForRemoteDevices()

        NotificationCenter.default.addObserver(self, selector: #selector( sessionInterrupted ), name: AVAudioSession.interruptionNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector( sessionInterrupted ), name: .AVPlayerItemDidPlayToEndTime , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( sessionInterrupted ), name: .AVPlayerItemFailedToPlayToEndTime , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( sessionInterrupted ), name: .AVPlayerItemTimeJumped, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( sessionInterrupted ), name: .AVPlayerItemPlaybackStalled , object: nil)
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

    @objc
    /// Starts playback at the current offset.
    // NOTE: Playback must have already started for Play message to be
    // effective.

    func play()
    {
        #warning("fill me in")
    }

    /// Pause playback at the current offset.

    func pause()
    {
        #warning("fill me in")
    }

    /// Stop playback at the current offset.
    /// NOTE: This is potentially different from Pause functionality, depending
    /// on the media player. For example, stop may remove the current media item,
    /// requiring it to be loaded again.

    func stop()
    {
        #warning("fill me in")
    }


    func seek( to offsetSeconds: CMTime )
    {
        self.player.currentItem?.cancelPendingSeeks()

        self.player.seek(to: offsetSeconds)
    }

    func skip(forward seconds: CMTime)
    {
        self.player.seek(
            to: seconds,
            completionHandler:
            { (finished:Bool) in

            }
        )
//        self.player?.seek(to: offsetSeconds,completionHandler:
    }
    
    func skip(back seconds: CMTime)
    {
        #warning("fill me in")
    }
    
    func skipBack( seconds: CMTime )
    {
        #warning("fill me in")
    }

    // * startPlayback
    func startPlayback()
    {
        let url = URL.init(string: "http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8")!
//        let url = URL.init(string: "http://breaqz.com/movies/Lego911gt3.mov")!
//        let url = URL.init(string: "http://10.0.0.245:8080/camera/livestream.m3u8")!

        self.playerItem = AVPlayerItem.init(url: url)
        self.playerItem?.addObserver(self, forKeyPath: "duration", options: .new, context: nil)

        self.player = AVPlayer.init(playerItem: self.playerItem)
        
        self.player.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        self.player.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        self.player.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)

        self.player.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main, using:
        { (time:CMTime) in
            print("Periodic Time Update. New Time: \(time)")
        })

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

                case .readyToPlay:
                    print("Player Status is Ready to Play")

                case .unknown:
                    print("Player Status is Unknown")

                @unknown default:
                    print("Unknown")

            }
            
            if let validItemStatus = itemStatus
            {
                switch validItemStatus
                {
                    case .failed:
                        print("Player Status is Failed")

                    case .readyToPlay:
                        print("Player Status is Ready to Play")

                    case .unknown:
                        print("Unknown")

                    @unknown default:
                        print("Unknown")
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

    @objc func mediaDidEndPlayback( notif: Notification )
    {
        
    }

    @objc func mediaFailedToPlayToEndTime( notif: Notification )
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

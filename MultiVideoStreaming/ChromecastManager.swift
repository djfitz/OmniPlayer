//
//  ChromecastManager.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 9/16/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import Foundation
import GoogleCast

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
class ChromecastManager : NSObject, GCKRemoteMediaClientListener,
                          GCKCastDeviceStatusListener, GCKSessionManagerListener,
                          GCKLoggerDelegate
{
    // ID can be found at: https://cast.google.com/publish/
    let kChromecastApplicationID = "09E504FF"

    /**
        There are times that we want commands to the Chromecast SDK to be
        executed serially. For example, if the SDK hasn't been initialized
        quickly enough upon app startup, calling SDK methods before it is
        initialized will cause the app to crash.
    */
    var messageQueue = DispatchQueue.init(
                        label: "ChromecastMessageQueue",
                        qos: .background )

    /**
        Update this property to show Chromecast SDK log messages.

        Use only for debugging; will really affect runtime performance.
    */
    var logChromecastMessages = true

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
        // Necessary initialization to start the SDK.
        let discCrit = GCKDiscoveryCriteria.init(applicationID: kChromecastApplicationID)
        let castOptions = GCKCastOptions.init(discoveryCriteria: discCrit)
        GCKCastContext.setSharedInstanceWith(castOptions)

        // Start listening for Chromecast session messages.
        GCKCastContext.sharedInstance().sessionManager.add(self)

        // Gives us a chance to log Chromecast messages to our
        // logger of choice. For us, NSLog.
        GCKLogger.sharedInstance().delegate = self
    }


    // =======================================================================================

    // MARK:- GCKRemoteMediaClientListener

    /**
     * Called when a new media session has started on the receiver.
     *
     * @param client The client.
     * @param sessionID The ID of the new session.
     */
    func remoteMediaClient(_ client: GCKRemoteMediaClient,
                           didStartMediaSessionWithID sessionID: Int)
    {
        NSLog("\nRemote Media Client: Did Start Media Session With ID = %@\n", sessionID)
    }

    /**
     * Called when updated media status has been received from the receiver.
     *
     * @param client The client.
     * @param mediaStatus The updated media status. The status can also be accessed as a property of
     * the player.
     */
    func remoteMediaClient(_ client: GCKRemoteMediaClient,
                           didUpdate mediaStatus: GCKMediaStatus?)
    {
        if let mediaStatusThatUpdated = mediaStatus
        {
            NSLog("Media Status Did Update:\n%@\n",
                  String(describing: mediaStatusThatUpdated) )
        }
        else
        {
            NSLog("Media Status Did Update:\n with no status. ???\n")
        }
    }

    /**
     * Called when updated media metadata has been received from the receiver.
     *
     * @param client The client.
     * @param mediaMetadata The updated media metadata. The metadata can also be accessed through the
     * GCKRemoteMediaClient::mediaStatus property.
     */

    func remoteMediaClient(_ client: GCKRemoteMediaClient,
                           didUpdate mediaMetadata: GCKMediaMetadata?)
    {
        if let mediaMetadataThatUpdated = mediaMetadata
        {
            NSLog("Remote Media Client: Media Metadata Did Update\n%@\n",
                  String(describing: mediaMetadataThatUpdated) )
        }
        else
        {
            NSLog("Remote Media Client: Media Metadata Did Update with no metadata. ???\n")
        }
    }

    /**
     * Called when the media preload status has been updated on the receiver.
     *
     * @param client The client.
     */
    func remoteMediaClientDidUpdatePreloadStatus(_ client: GCKRemoteMediaClient)
    {
        if let mediaStatusThatUpdated = client.mediaStatus
        {
            NSLog("Remote Media Client: Preload Status Did Update:\nPreloaded Item ID = %@\n",
                  String(describing: mediaStatusThatUpdated.preloadedItemID) )
        }
        else
        {
            NSLog("Remote Media Client: Preload Status Did Update:\n with no status. ???\n")
        }
    }

    /**
     * Called when the media playback queue has been updated on the receiver.
     *
     * @param client The client.
     */
    func remoteMediaClientDidUpdateQueue(_ client: GCKRemoteMediaClient)
    {
        NSLog("Remote Media Client: Did update Queue")
    }

    /**
     * Called when the list of media queue item IDs has been received.
     *
     * @param client The client.
     * @param queueItemIDs The list of media queue item IDs.
     */
    func remoteMediaClient(_ client: GCKRemoteMediaClient,
                           didReceiveQueueItemIDs queueItemIDs: [NSNumber])
    {
        NSLog("Remote Media Client: Did Receive Queue Items:\n\(queueItemIDs)")
    }

    /**
     * Called when a contiguous sequence of items has been inserted into the media queue.
     *
     * @param client The client.
     * @param queueItemIDs The item IDs of the inserted items.
     * @param beforeItemID The item ID of the item in front of which the new items have been inserted.
     *
     * If the value is kGCKMediaQueueInvalidItemID, it indicates that the items were appended at the
     * end of the queue.
     */
    func remoteMediaClient(_ client: GCKRemoteMediaClient,
                            didInsertQueueItemsWithIDs queueItemIDs: [NSNumber],
                            beforeItemWithID beforeItemID: UInt)
    {
        NSLog("Remote Media Client: Did Insert Queue Items:\n\(queueItemIDs)\nBefore Item: \(beforeItemID)")
    }

    /**
     * Called when existing items has been updated in the media queue.
     *
     * @param client The client.
     * @param queueItemIDs The item IDs of the updated items.
     */
    func remoteMediaClient(_ client: GCKRemoteMediaClient,
                            didUpdateQueueItemsWithIDs queueItemIDs: [NSNumber])
    {
        NSLog("Remote Media Client: Did Update Queue Items:\n\(queueItemIDs)")
    }

    /**
     * Called when a contiguous sequence of items has been removed from the media queue.
     *
     * @param client The client.
     * @param queueItemIDs The item IDs of the removed items.
     */
    func remoteMediaClient(_ client: GCKRemoteMediaClient,
                            didRemoveQueueItemsWithIDs queueItemIDs: [NSNumber])
    {
        NSLog("Remote Media Client: Did Remove Queue Items:\n\(queueItemIDs)")
    }

    /**
     * Called when detailed information has been received for one or more items in the queue.
     *
     * @param client The client.
     * @param queueItems The queue items.
     */
    func remoteMediaClient(_ client: GCKRemoteMediaClient,
                            didReceive queueItems: [GCKMediaQueueItem])
    {
        NSLog("Remote Media Client: Did Receive Queue Items:\n\(queueItems)")
    }


    // =======================================================================================

    // MARK:- GCKCastDeviceStatusListener

    /**
     * Called when the Cast device's active input status has changed.
     *
     * @param castSession The Cast session.
     * @param activeInputStatus The new active input status.
     */
    // optional public func castSession(_ castSession: Any!, didReceiveActiveInputStatus activeInputStatus: Any!)

    func castSession(_ castSession: GCKCastSession,
                        didReceive activeInputStatus: GCKActiveInputStatus)
    {
        NSLog("Cast Session: Did Receive Active Input Status:\n\(String(describing: activeInputStatus))")
    }

    /**
     * Called when the Cast device's standby status has changed.
     *
     * @param castSession The Cast session.
     * @param standbyStatus The new standby status.
     */
    func castSession(_ castSession: GCKCastSession,
                        didReceive standbyStatus: GCKStandbyStatus)
    {
        NSLog("Cast Session: Did Receive Standby Status:\n\(String(describing: standbyStatus))")
    }

    /**
     * Called when the Cast device's multizone status has changed.
     *
     * @param castSession The Cast session.
     * @param multizoneStatus The new multizone status.
     */
    func castSession(_ castSession: GCKCastSession,
                        didReceive multizoneStatus: GCKMultizoneStatus)
    {
        NSLog("Cast Session: Did Receive Multizone Input Status:\n\(String(describing: multizoneStatus))")
    }

    /**
     * Called whenever a multizone device is added.
     *
     * @param castSession The Cast session.
     * @param device The newly-added multizone device.
     */
    func castSession(_ castSession: GCKCastSession,
                    didAdd device: GCKMultizoneDevice)
    {
        NSLog("Cast Session: Did Add Multizone Device:\n\(String(describing: device.deviceID))")
    }

    /**
     * Called whenever a multizone device is updated.
     *
     * @param castSession The Cast session.
     * @param device The updated multizone device.
     */
    func castSession(_ castSession: GCKCastSession,
                    didUpdate device: GCKMultizoneDevice)
    {
            NSLog("Cast Session: Did Update Multizone Device:\n\(String(describing: device.deviceID))")
    }

    /**
     * Called whenever a multizone device is removed.
     *
     * @param castSession The Cast session.
     * @param deviceID The deviceID of the removed multizone device.
     */
    func castSession(_ castSession: GCKCastSession,
                    didRemoveMultizoneDeviceWithID deviceID: String)
    {
            NSLog("Cast Session: Did Remove Multizone Device:\n\(deviceID)")
    }


    // =======================================================================================

    // MARK:- GCKSessionManagerListener

    // MARK:•• Session

    /**
     * Called when a session is about to be started.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        willStart session: GCKSession)
    {
        NSLog("Session Manager: Will Start Session with ID: %@", (session.sessionID != nil) ? session.sessionID! : "No session")
    }

    /**
     * Called when a session has been successfully started.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didStart session: GCKSession)
    {
        NSLog("Session Manager: Did Start Session with ID: %@", (session.sessionID != nil) ? session.sessionID! : "None")
    }

    /**
     * Called when a session is about to be ended, either by request or due to an error.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        willEnd session: GCKSession)
    {
        NSLog("Session Manager: Will End Session with ID: %@", (session.sessionID != nil) ? session.sessionID! : 0)
    }

    /**
     * Called when a session has ended, either by request or due to an error.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     * @param error The error, if any; otherwise nil.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didEnd session: GCKSession,
                        withError error: Error?)
    {
        NSLog("Session Manager: Did End Session with ID: \((session.sessionID != nil) ? session.sessionID! : "no session ID")\nError:\n\(String(describing: error))" )
    }

    /**
     * Called when a Cast session is about to be ended, either by request or due to an error.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        willEnd session: GCKCastSession)
    {
        NSLog("Session Manager: Will End Casat Session with ID: %@", (session.sessionID != nil) ? session.sessionID! : 0)
    }

    /**
     * Called when a session has failed to start.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     * @param error The error.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didFailToStart session: GCKSession,
                        withError error: Error)
    {
        print( "Session Manager: Session Did Fail to Start, with Session with ID: \((session.sessionID != nil) ? session.sessionID! : "no session ID")\nError:\n\(error)" )

        NotificationCenter.default.post(name: NSNotification.Name.init("SessionDidFailtoStartNotification"), object: error)
    }

    /**
     * Called when a session has been suspended.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     * @param reason The reason for the suspension.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didSuspend session: GCKSession,
                        with reason: GCKConnectionSuspendReason)
    {
        print( "Session Manager: Session Did Suspend. Reason:\n\(String(describing: reason))\n" )
    }

    /**
     * Called when a session is about to be resumed.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        willResumeSession session: GCKSession)
    {
        NSLog("Session Manager: Will Resume Session with ID: %@", (session.sessionID != nil) ? session.sessionID! : 0)
    }

    /**
     * Called when a session has been successfully resumed.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didResumeSession session: GCKSession)
    {
        NSLog("Session Manager: Did Resume Session with ID: %@", (session.sessionID != nil) ? session.sessionID! : 0)
    }

    /**
     * Called when the device associated with this session has changed in some way (for example, the
     * friendly name has changed).
     *
     * @param sessionManager The session manager.
     * @param session The Cast session.
     * @param device The updated device object.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        session: GCKSession,
                        didUpdate device: GCKDevice)
    {
        print( "Session Manager: Did Update Device\nSession ID: \((session.sessionID != nil) ? session.sessionID! : "no ID")\nDevice ID = \(String(describing: device.deviceID))\n" )
    }

    /**
     * Called when updated device volume and mute state for a session have been received.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     * @param volume The current volume, in the range [0.0, 1.0].
     * @param muted The current mute state.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        session: GCKSession,
                        didReceiveDeviceVolume volume: Float,
                        muted: Bool)
    {
        print( "Session Manager: Did Receive Device Volume.\nSession ID: \((session.sessionID != nil) ? session.sessionID! : "no ID")\nNew Device Volume = \(String(describing: volume))\nMuted:\(String(describing: muted))" )
    }

    /**
     * Called when updated device status for a session has been received.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     * @param statusText The new device status text.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        session: GCKSession,
                        didReceiveDeviceStatus statusText: String?)
    {
        if let newStatusText = statusText
        {
            NSLog("Session Manager: New Device Status:\n%@\n", newStatusText )
        }
        else
        {
            NSLog("Session Manager: Device Status Update, with no status. ???\n")
        }
    }

    /**
     * Called when the default session options have been changed for a given device category.
     *
     * @param sessionManager The session manager.
     * @param category The device category.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didUpdateDefaultSessionOptionsForDeviceCategory category: String)
    {
        NSLog("Session Manager: Did Update Default Session Options.\nDevice Category: %@\n", category )
    }

    // MARK: •• Cast Session

    /**
     * Called when a Cast session is about to be resumed.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        willResumeCastSession session: GCKCastSession)
    {
        NSLog("Session Manager: Will Resume Cast Session with ID: %@", (session.sessionID != nil) ? session.sessionID! : 0)
    }

    /**
     * Called when a Cast session has been successfully resumed.
     *
     * @param sessionManager The session manager.
     * @param session The Cast session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didResumeCastSession session: GCKCastSession)
    {
        NSLog("Session Manager: Cast Session Did Resume. Cast Session ID: %@", (session.sessionID != nil) ? session.sessionID! : 0)
    }

    /**
     * Called when a Cast session is about to be started.
     *
     * @param sessionManager The session manager.
     * @param session The session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        willStart session: GCKCastSession)
    {
        NSLog("Session Manager: Cast Session Will Start. Cast Session ID: %@", (session.sessionID != nil) ? session.sessionID! : 0)
    }

    /**
     * Called when a Cast session has been successfully started.
     *
     * @param sessionManager The session manager.
     * @param session The Cast session.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didStart session: GCKCastSession)
    {
        NSLog("Session Manager: Cast Session Did Start. Cast Session ID: %@", (session.sessionID != nil) ? session.sessionID! : 0)

        let md = GCKMediaMetadata.init(metadataType: .movie)
        md.setString("Dumb Title", forKey: kGCKMetadataKeyTitle)
        md.setString("Dumb Studios", forKey: kGCKMetadataKeyStudio)



        let mediaInfo = GCKMediaInformation.init(
                contentID: "http://breaqz.com/movies/ContentInsetDemo1.mov",
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

    /**
     * Called when a Cast session has failed to start.
     *
     * @param sessionManager The session manager.
     * @param session The Cast session.
     * @param error The error.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didFailToStart session: GCKCastSession,
                        withError error: Error)
    {
        print( "Session Manager: Cast Session Did Fail to Start. Cast Session ID: \((session.sessionID != nil) ? session.sessionID! : "no session ID")\nError:\n\(error)" )
    }

    /**
     * Called when a Cast session has been suspended.
     *
     * @param sessionManager The session manager.
     * @param session The Cast session.
     * @param reason The reason for the suspension.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didSuspend session: GCKCastSession,
                        with reason: GCKConnectionSuspendReason)
    {
        print( "Session Manager: Cast Session Did Suspend. Reason:\n\(String(describing: reason))\n" )
    }

    /**
     * Called when a Cast session has ended, either by request or due to an error.
     *
     * @param sessionManager The session manager.
     * @param session The Cast session.
     * @param error The error, if any; otherwise nil.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        didEnd session: GCKCastSession,
                        withError error: Error?)
    {
        NSLog("Session Manager: Cast Session Did End. Cast Session ID: \((session.sessionID != nil) ? session.sessionID! : "no session ID")\nError:\n\(String(describing: error))" )
    }

    /**
     * Called when updated device status for a Cast session has been received.
     *
     * @param sessionManager The session manager.
     * @param session The Cast session.
     * @param statusText The new device status text.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        castSession session: GCKCastSession,
                        didReceiveDeviceStatus statusText: String?)
    {
        if let newStatusText = statusText
        {
            NSLog("Session Manager: Cast Session New Device Status:\n%@\n", newStatusText )
        }
        else
        {
            NSLog("Session Manager: Cast Session Device Status Update, with no status. ???\n")
        }
    }

    /**
     * Called when updated device volume and mute state for a Cast session have been received.
     *
     * @param sessionManager The session manager.
     * @param session The Cast session.
     * @param volume The current volume, in the range [0.0, 1.0].
     * @param muted The current mute state.
     */
    func sessionManager(_ sessionManager: GCKSessionManager,
                        castSession session: GCKCastSession,
                        didReceiveDeviceVolume volume: Float,
                        muted: Bool)
    {
        print( "Session Manager: Cast Session Did Receive Device Volume.\nCast Session ID: \((session.sessionID != nil) ? session.sessionID! : "no ID")\nNew Device Volume = \(String(describing: volume))\nMuted:\(String(describing: muted))" )
    }

    func logMessage(_ message: String,
                    at level: GCKLoggerLevel,
                    fromFunction function: String,
                    location: String)
    {
        let lvl = MultiVideoStreaming.description(for: level)
         print("Chromecast Message:\n\(message)\nLevel: \(lvl)\nFunction: \(function)\nLocation:\(location)\n")
    }
}

// =======================================================================================

// MARK:- Extensions and Debug Utilities

extension GCKMediaStatus
{
    func description() -> String
    {
        var retVal = "\nMedia Status:\n"

        retVal += "Media Session ID\(self.mediaSessionID)"
        retVal += "Player State: \(String(describing: self.playerState))"
        retVal += "Idle Reason: \(MultiVideoStreaming.description(for: self.idleReason))"
        retVal += "Playback Rate: \(self.playbackRate)"
        retVal += "Stream Position: \(self.streamPosition)"
        retVal += "Volume: \(self.volume)"
        retVal += "Is Muted: \(self.isMuted)"
        retVal += "Repeat Mode: \(MultiVideoStreaming.description(for: self.queueRepeatMode))"
        retVal += "Current Item ID: \(self.currentItemID)"
        retVal += "Queue has a current item: \(self.queueHasCurrentItem)"
        retVal += "Current Queue Item: \(String(describing: self.currentQueueItem?.itemID))"
        retVal += "Next Queue Item: \(String(describing: self.nextQueueItem?.itemID))"

        return retVal
    }
}

extension GCKMediaInformation
{
    func description() -> String
    {
        var retVal = "Content ID: \(self.contentID)"

        switch self.streamType
        {
            case .buffered:
                retVal += "Stream Type: Buffered\n"

            case .live:
                retVal += "Stream Type: Live\n"

            case .none:
                retVal += "Stream Type: None\n"

            case .unknown:
                retVal += "Stream Type: Unknown\n"
        }

        retVal += "Content ID: \(self.contentType)\n"

        retVal += "Media Metadata: \(self.metadata?.description() ?? "No media metadata.")\n "

        return retVal
    }
}

// GCKMediaMetadata
extension GCKMediaMetadata
{
    func description() -> String
    {
        return "Metadata Type: \(MultiVideoStreaming.description(for: self.metadataType))\n"
                + "Images:\n\(self.images())\n"
                + "Keys:\n\(self.allKeys())\n\n"
    }
}

func description( for mediaRepeatMode: GCKMediaRepeatMode) -> String
{
    switch mediaRepeatMode
    {
        case .all:
            return "All"

        case .allAndShuffle:
            return "All and Shuffle"

        case .off:
            return "Off"

        case .single:
            return "Single"

        case .unchanged:
            return "Unchanged"
    }
}

func description( for playerState: GCKMediaPlayerState) -> String
{
    switch playerState
    {
        case .unknown:
            return "Unknown"

        case .buffering:
            return "Buffering"

        case .loading:
            return "Loading"

        case .paused:
            return "Paused"

        case .playing:
            return "Playing"

        case .idle:
            return "Idle"

        default:
            return "ooooppse"
    }
}

func description( for mediaMetaDateType: GCKMediaMetadataType) -> String
{
    switch mediaMetaDateType
    {
        case .generic:
            return "Generic"

        case .movie:
            return "Movie"

        case .musicTrack:
            return "Music Track"

        case .photo:
            return "Photo"

        case .tvShow:
            return "TV Show"

        case .user:
            return "No real Value: Compiler internal limit"
    }
}


func description( for idleReason: GCKMediaPlayerIdleReason) -> String
{
    switch idleReason
    {
        case .cancelled:
            return "Cancelled"

        case .error:
            return "Error"

        case .finished:
            return "Finished"

        case .interrupted:
            return "Interrupted"

        case .none:
            return "None"
    }
}

// GCKLoggerLevel

func description( for logLevel: GCKLoggerLevel ) -> String
{
    switch logLevel
    {
        case .assert:
            return "Assert"

        case .debug:
            return "Debug"

        case .error:
            return "Error"

        case .info:
            return "Info"

        case .verbose:
            return "Verbose"

        case .warning:
            return "Warning"

        case .none:
            return "None"
    }
}

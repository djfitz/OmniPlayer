//
//  MediaPlayerGeneric.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 9/16/18.
//  Copyright © 2018 doughill. All rights reserved.
//

import Foundation
import AVFoundation


// MARK: - Media Player
class MediaItem
{
    let title: String
    let url: URL

    init( title: String, url: URL )
    {
        self.title = title
        self.url = url
    }
}


/// A generic interface for a media player.

protocol MediaPlayerGeneric
{
    /// The media item that is in the process of loading.
    /// Observable.
    ///
    /// NOTE: Media can be loading while the currently
    /// playing item is unaffected. When new media is
    /// loaded, playback switches to loaded media.
    ///
    /// When media is eventually loaded or there is
    /// a failure to load, this property will be reset to nil.
    var loadingMediaItem: MediaItem? { get }

    /// The media item that has been loaded and is now ready for playback.
    /// Can be observed when a new media item has been loaded.
    var currentMediaItem: MediaItem? { get }

    /// Setting the offset will perform a seek operation. This could take
    /// a long time depending on the media, network stream, etc.
    /// NOTE: Not all media players can support fractional seconds for the offset.
    /// NOTE2: Can be observed when the offset changes. How often observers will be called
    /// is dependent on the media player. May not be fractional seconds, even if the media
    /// player supports fractional offsets.
    var currentOffset: CMTime { get set }

    /// The rate of the playback as a fractional amount. Also known as the playback speed.
    /// Can be observed for when rate changes.
    /// 0 = stopped, 1 = Default playback rate, 2 = Double speed playback
    /// NOTE: Not all media players can support non-whole fractional amounts.
    var playbackRate: Double { get set }

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

    /// Starts playback at the current offset.
    // NOTE: Playback must have already started for Play message to be
    // effective.

    func play()

    /// Pause playback at the current offset.

    func pause()

    /// Stop playback at the current offset.
    /// NOTE: This is potentially different from Pause functionality, depending
    /// on the media player. For example, stop may remove the current media item,
    /// requiring it to be loaded again.

    func stop()

    func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void)

    func skip( forward seconds: CMTime )

    func skip( back seconds: CMTime )
}

protocol PlaybackDevice
{
    var isLocal: Int { get }
    var name: String { get }
}

protocol RemoteMediaPlayback
{
    // Updated in real-time as the device list changes.
    // Observable.
    // Observers can keep track of changes to this list
    // as they happen. For example, to know to change any
    // UI info relating to the list of devices.
    // Client can create their own device picker UI.
    
    var remoteDevicesList: [PlaybackDevice] { get }

    var currentlySelectedDevice: PlaybackDevice? { get set }

    /// A button that the client of this lib can put into their
    /// view hierarchy. This button automatically handles picking
    /// a remote device.
    /// When a new remote device is selected via this UI, the client
    /// will start receiving messages from the newly selected remote
    /// device. Playback may also automatically switch to it as well.
    var remoteDevicePickerButton: UIView { get }

}


// MARK: - Playback Queue

/// A generic interface for a playback queue
protocol MediaPlaybackQueue
{
    /// Which item in the playback queue is
    /// currently playing.
    /// When queue is empty, this property will return nil.
    var currentPlaybackQueueIndex: Int? {get set}

    /// An ordered list of media items
    var playlist: [MediaItem] { get set }

    // Updating the playback queue

    func addItem(at Index: Int)

    func addToEnd( mediaItems: [MediaItem] )

    func removeLast()

    func removeFirst()

    func removeItem(at Index: Int)

    // Moving to a new item in the playback queue

    func next()

    func previous()

    func skipToMediaItem( at index: Int )
}

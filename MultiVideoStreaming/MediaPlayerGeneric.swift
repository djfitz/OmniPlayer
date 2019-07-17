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

/// A generic interface for a media player.

protocol MediaPlayerGeneric
{
    /// Setting the offset will perform a seek operation. This could take
    /// a long time depending on the media, network stream, etc.
    /// NOTE: Not all media players can support fractional seconds for the offset.
    /// NOTE2: Can be observed when the offset changes. How often observers will be called
    /// is dependent on the media player. May not be fractional seconds, even if the media
    /// player supports fractional offsets.
    var currentOffsetSeconds: CMTime { get set }

    /// The rate of the playback as a fractional amount. Also known as the playback speed.
    /// Can be observed for when rate changes.
    /// 0 = stopped, 1 = Default playback rate, 2 = Double speed playback
    /// NOTE: Not all media players can support non-whole fractional amounts.
    var playbackRate: Double { get set }

    /// The media item that has been loaded and is now ready for playback.
    /// Can be observed when a new media item has been loaded.
    var currentMediaItem: URL { get }

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
    func load( mediaItem: URL )

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

    func seek( toOffsetSeconds: CMTime )

    func skipForward( seconds: CMTime )

    func skipBack( seconds: CMTime )

}

// MARK: - Playback Queue

/// A generic interface for a playback queue
protocol MediaPlaybackQueue
{
    /// An ordered list of media items
    var playlist : Array<URL> { get }

    // MARK: - Updating the playback queue

    func add( mediaItems: Array<URL> )

    func removeLast()

    func removeFirst()

    func removeItem( atIndex: Int )

    // MARK: - Moving to a new item in the playback queue

    func next()

    func previous()

    func skipToMediaItem( atIndex: Int )
}

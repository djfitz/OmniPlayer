//
//  MediaUIController.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 8/1/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit
import MediaPlayer

class MediaUIController: NSObject
{
    var mediaPlayerViewCollection: MediaPlayerUICollection?

    var isSliderChanging = false

    func registerMediaPlayerUICollection(uiCollection: MediaPlayerUICollection)
    {
        self.mediaPlayerViewCollection = uiCollection

        uiCollection.playPauseButton?.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)

        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderTouchUpInside(_:)), for: .touchUpInside)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderTouchUpOutside(_:)), for: .touchUpOutside)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderTouchCancelled(_:)), for: .touchCancel)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderEditingDidEnd(_:)), for: .editingDidEnd)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderEditingChanged(_:)), for: .editingChanged)
        uiCollection.seekTimeSlider?.addTarget(self, action: #selector(sliderDidEndOnExit(_:)), for: .editingDidEndOnExit)

        uiCollection.seekTimeSlider?.setThumbImage(#imageLiteral(resourceName: "TimeSeekSliderThumb"), for: .normal)

        uiCollection.infoLabel?.text = MediaPlayerManager.mgr.currentMediaItem?.title
        uiCollection.infoLabel?.isHidden = false
        uiCollection.errorLabel?.text = ""

        if let cButton = MediaPlayerManager.mgr.chromecastPlayer.remoteDevicePickerButton
        {
            uiCollection.remoteButtonsContainerStack?.insertArrangedSubview(cButton, at: uiCollection.remoteButtonsContainerStack?.arrangedSubviews.count ?? 0)
        }

        if let avButton = MediaPlayerManager.mgr.avFoundationPlayer.remoteDevicePickerButton
        {
            uiCollection.remoteButtonsContainerStack?.insertArrangedSubview(avButton, at: uiCollection.remoteButtonsContainerStack?.arrangedSubviews.count ?? 0)
//            uiCollection.remoteButtonsContainerStack?.addArrangedSubview(avButton)
        }

        uiCollection.avPlayerView?.player = MediaPlayerManager.mgr.avFoundationPlayer.player
    }

    deinit
    {
        MediaPlayerManager.mgr.stop()
        MediaPlayerManager.mgr.removeObserver(self, forKeyPath: "status")
        MediaPlayerManager.mgr.removeObserver(self, forKeyPath: "currentOffset")
    }

    override init()
    {
        super.init()

        MediaPlayerManager.mgr.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        MediaPlayerManager.mgr.addObserver(self, forKeyPath: "currentOffset", options: .new, context: nil)
    }

    @objc func playbackTimeUpdated( newTime: CMTime)
    {
        let currentTimeSeconds = newTime.seconds
        let durationSeconds = MediaPlayerManager.mgr.duration.seconds
        if durationSeconds > 0 && !self.isSliderChanging && !MediaPlayerManager.mgr.isSeeking
        {
            let fracTimeElapsed = currentTimeSeconds / durationSeconds
            self.mediaPlayerViewCollection?.seekTimeSlider?.value = Float(fracTimeElapsed)
        }
    }

    @IBAction func backButtonTapped(_ sender: Any)
    {
        print("Back button tapped")
    }

    @IBAction func playPauseButtonTapped(_ sender: Any)
    {
        switch MediaPlayerManager.mgr.status
        {
            case .readyToPlay:
                MediaPlayerManager.mgr.play()

            case .paused:
                MediaPlayerManager.mgr.play()

            case .playing:
                MediaPlayerManager.mgr.pause()

            case .failed:
                MediaPlayerManager.mgr.play()

            case .loading:
                MediaPlayerManager.mgr.play()

            case .unknown:
                MediaPlayerManager.mgr.play()

            case .playedToEnd:
                // When the player is at the end, due to playback finishing
                // normally, starting playback involves
                // - Seek to the beginning
                // - Start playback
                self.mediaPlayerViewCollection?.seekTimeSlider?.value = 0
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)

                MediaPlayerManager.mgr.seek(to: CMTime.zero)
                { (cancelled) in
                    MediaPlayerManager.mgr.play()
                }

            case .buffering:
                MediaPlayerManager.mgr.pause()

            case .idle:
                print("Player is idle.")
        }
    }

    @IBAction func forwardButtonTapped(_ sender: Any)
    {
    }

    //

    @IBAction func sliderValueChanged(_ sender: Any)
    {
        print("sliderValueChanged")
        self.isSliderChanging = true
    }

    @IBAction func sliderEditingChanged(_ sender: Any)
    {
        print("sliderEditingChanged")
        self.isSliderChanging = true
    }

    @IBAction func sliderTouchCancelled(_ sender: Any)
    {
        print("sliderTouchCancelled")
        self.isSliderChanging = false
    }

    @IBAction func sliderEditingDidEnd(_ sender: Any)
    {
        print("sliderEditingDidEnd")
        self.isSliderChanging = false
    }

    @IBAction func sliderDidEndOnExit(_ sender: Any)
    {
        print("sliderDidEndOnExit")
        self.isSliderChanging = false
    }

    @IBAction func sliderTouchUpOutside(_ sender: Any)
    {
        self.sliderTouchUpInside(sender)
    }

    @IBAction func sliderTouchUpInside(_ sender: Any)
    {
        print("***** Slider >> Touch Up Inside\nNew Value: \(self.mediaPlayerViewCollection?.seekTimeSlider?.value)")
        let currentSliderValue = Double(self.mediaPlayerViewCollection?.seekTimeSlider?.value ?? 0)
        let duration = MediaPlayerManager.mgr.duration
        let seekTimeSec = currentSliderValue * duration.seconds

        if seekTimeSec == duration.seconds
        {
            print("***** Seeking to the end.")
        }

        if MediaPlayerManager.mgr.status == .playedToEnd
        {
            if let mediaItem = MediaPlayerManager.mgr.currentMediaItem
            {
                MediaPlayerManager.mgr.load(mediaItem: mediaItem, startingAt: CMTime.init(seconds: seekTimeSec, preferredTimescale: 1))
            }
        }
        else
        {
            MediaPlayerManager.mgr.pause()

            MediaPlayerManager.mgr.seek(
                to: CMTime( seconds: seekTimeSec,
                            preferredTimescale: CMTimeScale(1) )
            )
            { (cancelled) in
                print("Seeked to \(seekTimeSec): Cancelled = \(cancelled)")

                self.isSliderChanging = false

                if seekTimeSec != duration.seconds && !cancelled
                {
                    MediaPlayerManager.mgr.play()
                }
            }
        }
    }

    //

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
            self.playerStatusUpdated(status: MediaPlayerManager.mgr.status)
        }
        else if keyPath == "currentOffset"
        {
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? CMTime
            {
                print("New Current Offset: \(newValue.seconds)")
            }

            if let newCurrentTime = change?[NSKeyValueChangeKey.newKey] as? CMTime
            {
                self.playbackTimeUpdated(newTime: newCurrentTime)
            }
        }

        print("**************************************")
    }

    func playerStatusUpdated( status: PlaybackStatus )
    {
        switch status
        {
            case .loading:
                print("Loading")
                self.mediaPlayerViewCollection?.avPlayerView?.isHidden = true

                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                self.mediaPlayerViewCollection?.infoLabel?.text = MediaPlayerManager.mgr.loadingMediaItem?.title
                self.mediaPlayerViewCollection?.infoLabel?.isHidden = false
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false
                self.mediaPlayerViewCollection?.activitySpinner?.startAnimating()

            case .readyToPlay:
                print("readyToPlay")
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false

                self.mediaPlayerViewCollection?.avPlayerView?.isHidden = false

            case .playing:
                print("playing")

                let currentTimeSec = MediaPlayerManager.mgr.currentOffset.seconds
                let durationSec = MediaPlayerManager.mgr.duration.seconds

                let currentTimeRoundedWholeSec = currentTimeSec.rounded(.down)
                let currentTimeFrac = currentTimeSec - currentTimeRoundedWholeSec
                let currentTimeFracRoundedFrac = (currentTimeFrac * 100).rounded(.down) / 100
                let currentTimeRoundedSec = currentTimeRoundedWholeSec + currentTimeFracRoundedFrac

                let durationRoundedWholeSec = durationSec.rounded(.down)
                let durationFrac = durationSec - durationRoundedWholeSec
                let durationFracRoundedFrac = (durationFrac * 100).rounded(.down) / 100
                let durationRoundedSec = durationRoundedWholeSec + durationFracRoundedFrac

                print("**** Current Time =  \(currentTimeSec) Rounded: \(currentTimeRoundedSec)")
                print("**** Duration = \(durationSec) rounded to \(durationRoundedSec)")

                if durationRoundedSec <= currentTimeRoundedSec
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                }
                else
                {
                    self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                }

                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false

            case .paused:
                print("paused")
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false

            case .failed:
                print("failed")
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()
                self.mediaPlayerViewCollection?.errorLabel?.text = "There was a playback error."
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false

            case .buffering:
                print("buffering")
                self.mediaPlayerViewCollection?.activitySpinner?.startAnimating()
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false

            case .playedToEnd:
                self.mediaPlayerViewCollection?.activitySpinner?.stopAnimating()

                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false

            case .idle:
                self.mediaPlayerViewCollection?.playPauseButton?.setImage(#imageLiteral(resourceName: "PlayButton"), for: .normal)
                self.mediaPlayerViewCollection?.errorLabel?.text = ""
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false

            case .unknown:
                print("Unknown")
                self.mediaPlayerViewCollection?.errorLabel?.isHidden = false
        }
    }
}

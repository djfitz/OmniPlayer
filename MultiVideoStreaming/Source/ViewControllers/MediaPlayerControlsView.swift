//
//  MediaPlayerControlsView.swift
//  MultiVideoStreaming
//
//  Created by Doug Hill on 8/1/19.
//  Copyright © 2019 doughill. All rights reserved.
//

import UIKit

class MediaPlayerControlsView: UIView, MediaPlayerUICollection
{
    @IBOutlet var controlsVisibilityToggleButton: UIButton?

    @IBOutlet var toggleFullscreenButton: UIButton?

    @IBOutlet var backButton: UIButton?
    @IBOutlet weak var playPauseButton: UIButton?
    @IBOutlet weak var seekTimeSlider: UISlider?
    @IBOutlet weak var forwardButton: UIButton?

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView?

    @IBOutlet weak var infoLabel: UILabel?
    @IBOutlet weak var errorLabel: UILabel?

    @IBOutlet weak var remoteButtonsContainerStack: UIStackView?

    @IBOutlet weak var avPlayerView: AVPlayerView?
}

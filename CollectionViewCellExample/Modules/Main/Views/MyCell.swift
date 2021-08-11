//
//  MyCell.swift
//  CollectionViewCellExample
//
//  Created by User on 21.07.21.
//
import AVFoundation
import UIKit

final class MyCell: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!
    
    private var url: URL?
    private var player: AVPlayer?
    
    func setImage(_ img: UIImage) {
        imageView.image = img
    }
    
    func setURL(_ url: URL?) {
        self.url = url
    }
    
    func configurePlayer() {
        guard let url = url else { return }
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        player.isMuted = true
        self.player = player
        
        let playerLayer = AVPlayerLayer(player: player)
        imageView.layer.addSublayer(playerLayer)
        playerLayer.frame = self.bounds
    }
    
    func startPlayer() {
        self.player?.play()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    func deletePlayer() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: player?.currentItem)
        imageView.layer.sublayers?.removeAll()
        self.player = nil
    }
    
    // for repeating player
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }
}

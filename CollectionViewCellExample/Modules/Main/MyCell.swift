//
//  MyCell.swift
//  CollectionViewCellExample
//
//  Created by User on 21.07.21.
//
import AVFoundation
import UIKit

class MyCell: UICollectionViewCell {
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
        self.player = player
        
        let playerLayer = AVPlayerLayer(player: player)
        imageView.layer.addSublayer(playerLayer)
        playerLayer.frame = self.bounds
    }
    
    func startPlayer() {
        self.player?.play()
    }
    
    func deletePlayer() {
        imageView.layer.sublayers?.removeAll()
        self.player = nil
    }
    
}

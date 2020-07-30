//
//  PlayerViewController.swift
//  MusicApp
//
//  Created by JillOU on 2020/7/28.
//  Copyright © 2020 Jillou. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var musictitleLabel: UILabel!
    @IBOutlet weak var musicpictureImageView: UIImageView!
    @IBOutlet weak var musiclyricsTextView: UITextView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var processSlider: UISlider!
    @IBOutlet weak var playtime: UILabel!
    @IBOutlet weak var processtime: UILabel!
    let player:AVQueuePlayer = AVQueuePlayer()
    var looper:AVPlayerLooper?
    var replayflag = 0
    var heartflag = 0
    var timeObserverToken: Any?
    var pauseflag = 0
    var song = 0//現在在第幾首歌曲
    let music = ["bestards1", "bestards2"]
    let musiclyrics = ["bestardslrc1", "bestardslrc2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicinfo()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main){ (_) in
            if self.replayflag == 0{
                    self.song+=1
                    self.musicinfo()
                    self.player.removeTimeObserver(self.playobserver!)
            }else{
                    self.musicinfo()
                    self.player.removeTimeObserver(self.playobserver!)
            }
        }
    }
        
    //執行播放或暫停按鈕
    @IBAction func pausemusic(_ sender: UIButton) {
        switch pauseflag {
        case 0:
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
            pauseflag = 1
        case 1:
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
            pauseflag = 0
        default: break
            
        }
    }
    
    //跳下一首歌按鈕
    @IBAction func playnextmusic(_ sender: UIButton) {
        //播放&重複播放按鈕回歸原狀
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        replayButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle"), for: .normal)
        replayflag = 0
        song+=1
        musicinfo()
    }
    
    //跳上一首歌按鈕
    @IBAction func playpreviousmusic(_ sender: UIButton) {
        //播放&重複播放按鈕回歸原狀
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        replayButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle"), for: .normal)
        replayflag = 0
        song-=1
        musicinfo()
    }
    
    //讓歌曲重複播放
    @IBAction func replaymusic(_ sender: UIButton) {
        switch replayflag {
        case 0:
            replayButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle.fill"), for: .normal)
            replayflag = 1
        case 1:
            replayButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle"), for: .normal)
            replayflag = 0
        default: break
        }
    }
    
    //喜歡歌曲點擊按鈕
    @IBAction func likemusic(_ sender: UIButton) {
        switch heartflag {
        case 0:
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            heartflag = 1
        case 1:
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            heartflag = 0
        default: break
        }
        print(heartflag)
    }
    
    //調整播放區段
    @IBAction func slidemusicseek(_ sender: UISlider) {
        let currenttime = Int64(processSlider.value)
        let targettime:CMTime = CMTimeMake(value: currenttime, timescale: 1)
        player.seek(to: targettime)
    }
    
    //play music!
    func musicinfo(){
        if song<music.count, song>=0{
        //播放歌曲
        if let fileurl = Bundle.main.url(forResource: music[song], withExtension: "mp4"){
            let playItem = AVPlayerItem(url: fileurl)
            player.replaceCurrentItem(with: playItem)
            looper = AVPlayerLooper(player: player, templateItem: playItem)
            player.play()
            
            //計算歌曲長度
            let time = CMTimeGetSeconds(playItem.asset.duration).rounded()
            processtime.text = String(format: "%d:%d:%d", Int(time)/3600, (Int(time)%3600)/60, (Int(time)%3600)%60)
            
            //設定processSlider
            processSlider.minimumValue = 0
            processSlider.maximumValue = Float(time)
            processSlider.isContinuous = true
            timeobserver()
            
            //其他label, 專輯照片, 歌詞等等也要改變
            musictitleLabel.text = music[song]
            musicpictureImageView.image = UIImage(named: music[song])
            musiclyricsTextView.text = musiclyrics[song]
            }}else if song<0{
            song = music.count-1
            musicinfo()
        }else{
            song = 0
            musicinfo()
        }
        

    }
   
    //監控播放的歌曲
    var playobserver:Any!
    func timeobserver() {
          playobserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
                  if self.player.currentItem?.status == .readyToPlay {
                      let currentTime = CMTimeGetSeconds(self.player.currentTime())
                    self.processSlider.value = Float(currentTime)
                    self.playtime.text = String(format: "%d:%d:%d", Int(currentTime)/3600, (Int(currentTime)%3600)/60, (Int(currentTime)%3600)%60)
                  }
              })
          }
    
}

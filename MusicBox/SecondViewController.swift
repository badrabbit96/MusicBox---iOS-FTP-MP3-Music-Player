//
//  SecondViewController.swift
//  MusicBox
//
//  Created by Tomek Niemczyk on 09.10.2018.
//  Copyright © 2018 Tomek Niemczyk. All rights reserved.
//

import UIKit
import AVFoundation
class SecondViewController: UIViewController {

    
    @IBOutlet weak var sliderBar: UISlider!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songAuthor: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var updater : CADisplayLink! = nil
    
    @IBAction func play(_ sender: Any) {
        
        if audioPlayer.isPlaying == false
        {
            audioPlayer.play()
            playButton.setTitle("Pause", for: .normal)
        }
        
        else if audioPlayer.isPlaying == true
        {
            audioPlayer.pause()
            playButton.setTitle("Play", for: .normal)
        }
    }
   
    
  
    @IBAction func sliderBarAction(_ sender: UISlider) {
        
        updater.invalidate()

        var slidertime = sliderBar.value
        audioPlayer.pause()
        
        audioPlayer.currentTime = Double(slidertime);
        audioPlayer.play()
        
        if audioPlayer.isPlaying == true {
            updater = CADisplayLink(target: self, selector: #selector(self.trackAudio))
            updater.frameInterval = 1
            updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
            
        }
        
        
    }
    
    
    @IBAction func prev(_ sender: Any) {
        
        if thisSong == 1
        {
        playThis(thisOne: songs[thisSong-1])
        thisSong += 1
        label.text = songs[thisSong]
        }
        else
        {
            
        }
    }
    
    @IBAction func next(_ sender: Any) {
        
        playThis(thisOne: songs[thisSong+1])
        thisSong += 1
        label.text = songs[thisSong]
    }
    
    
    func playThis(thisOne:String)
    {
        do
        {
            let audioPath = Bundle.main.path(forResource: thisOne, ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            thisSong += 1
            audioPlayer.play()
        }
        catch
        {
            print("ERROR")
        }
    }
    
    
    
  

    func soundBar(){
        if audioPlayer.isPlaying == true {
            updater = CADisplayLink(target: self, selector: #selector(self.trackAudio))
            updater.frameInterval = 1
            updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
            
        }

    }
    @objc func trackAudio() {
        sliderBar.value = Float(audioPlayer.currentTime)
    }
    
    
  
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        let songFullTitle = songs[thisSong]
        let author = songFullTitle.components(separatedBy: "-").first
        let songname = songFullTitle.components(separatedBy: "-").last
        songAuthor.text = author
        songName.text = songname
        
        print (songname)
        
        
        sliderBar.minimumValue = 0
        sliderBar.maximumValue = Float(audioPlayer.duration)
    
        soundBar()
        
        self.title = "second"
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    


}


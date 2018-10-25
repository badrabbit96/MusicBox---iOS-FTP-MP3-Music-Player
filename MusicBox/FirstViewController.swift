//
//  FirstViewController.swift
//  MusicBox
//
//  Created by Tomek Niemczyk on 09.10.2018.
//  Copyright © 2018 Tomek Niemczyk. All rights reserved.
//

import UIKit
import AVFoundation


var songs:[String] =  []
var audioPlayer =  AVAudioPlayer()
var thisSong = 0 

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var myTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = songs[indexPath.row]
        cell.contentView.backgroundColor = UIColor.darkGray
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
   
    @IBAction func playMusic(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let secondVC = storyboard.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        do
        {
            let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
            selectedCell.contentView.backgroundColor = UIColor.gray
            
        
         // TODO   let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           
            // let desURL = folderURL.appendingPathExtension(songs[indexPath.row])
            
            
            let audioPath = Bundle.main.path(forResource: songs[indexPath.row], ofType: ".mp3")
            //print(folderURL.path)
            
           
           //TODO let finalURL = "file:///private" + folderURL.path + "/" + songs[indexPath.row] + ".mp3"
          //  print(finalURL)
            
           //let finalFinalURL = finalURL.replacingOccurrences(of: " ", with: "%20")

           // print(finalURL)
            
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            //finalURL zamiast audioPath
            
           // let sPlayer = try AVAudioPlayer(contentsOf: desURL!)

            audioPlayer.play()
            thisSong = indexPath.row
            
            
        }
        catch
        {
            print("ERROR")
        }
    }
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "first"
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        gettingSongName()
    }
    
  
    
    func gettingSongName()
    {
     
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
       //TOTO  let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
      if let audioUrl = URL(string: "https://ftp.icm.edu.pl/packages/mp3/2221/") {
        
         
            
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        print("destinationUrl is :",destinationUrl)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
               // self.dest = destinationUrl.path
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        
                        print("file path is :",destinationUrl.path)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
            
        }
        
        do
        {
            //let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

           let songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    
            
            for song in songPath
            {
                var mySong = song.absoluteString
               //  print (mySong)
                if mySong.contains(".mp3")
                {
                    print (mySong)
                    let findString = mySong.components(separatedBy: "/")
                    //print (mySong)
                    mySong = (findString[findString.count-1])
                   // print (mySong)
                    mySong = mySong.replacingOccurrences(of: "%20", with: " ")
                    mySong = mySong.replacingOccurrences(of: "%5B", with: "")
                    mySong = mySong.replacingOccurrences(of: "%5D", with: "")
                    mySong = mySong.replacingOccurrences(of: ".mp3", with: "")
                    songs.append(mySong)
                   // print(songs)
                }
            }
            
            myTableView.reloadData()
        }
        catch
        {
            
        }
    
    }


}


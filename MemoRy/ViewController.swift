//
//  ViewController.swift
//  Recorder
//
//  Created by George Yu on 2019-05-07.
//  Copyright © 2019 George Yu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var numberOfRecords: Int = 0
    
    @IBOutlet weak var recordOutlet: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    
    @IBAction func recordAction(_ sender: Any) {
        // Check if recorder is active
        if audioRecorder == nil {
            numberOfRecords += 1
            let fileName = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            // Modify audio recording settings here
            let settings = [
                // Format ID
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                // Sample rate
                AVSampleRateKey: 12000,
                // Number of channels
                AVNumberOfChannelsKey: 1,
                // Encoder audio quality
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            // Start recording audio
            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                recordOutlet.setTitle("Stop Recording", for: .normal)
            } catch {
                displayAlert(title: "Error", message: "Recording Failed")
            }
        } else {
            // Stop recording audio
            audioRecorder.stop()
            audioRecorder = nil
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            myTableView.reloadData()
            recordOutlet.setTitle("Start Recording", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up recording session
        recordingSession = AVAudioSession.sharedInstance()
        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            numberOfRecords = number
        }
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
    }
    
    // Get path to directory
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    // Display an alert
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Set up table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = String("Recording \(indexPath.row + 1)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
            displayAlert(title: "Error", message: "Playing Failed")
        }
    }
    
}

//
//  MicSpeakerTestViewController.swift
//  DeviceDiagnostic
//
//  Created by Niraj Jha on 20/09/18.
//  Copyright © 2018 Niraj Jha. All rights reserved.
//

import UIKit
import AVFoundation

protocol MicSpeakerResultDelegate:class  {
    func micSpeakerTestResult(isMicWorking:Bool,isSpeakerWorking:Bool)
}

class MicSpeakerTestViewController: UIViewController,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    @IBOutlet weak var recordAudioBtn: UIButton!
    @IBOutlet weak var playAudioBtn: UIButton!
    
    @IBOutlet weak var submitResultBtn: UIButton!
    
    var isAudioRecordingGranted: Bool!
    var recorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    var isPlaying   = false
    var isMicWorking = false
    var isSpeakerWorking = false
    weak var delegate:MicSpeakerResultDelegate?
    
    //MARK:- self methods
    override func viewDidLoad() {
        super.viewDidLoad()
        formatUI()
        checkRecordPermissions()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK:- private methods
    
    func formatUI() {
        playAudioBtn.layer.cornerRadius = 20.0
        playAudioBtn.clipsToBounds = true
        recordAudioBtn.layer.cornerRadius = 20.0
        recordAudioBtn.clipsToBounds = true
        submitResultBtn.layer.cornerRadius = 20.0
        submitResultBtn.clipsToBounds = true
    }
    
    func checkRecordPermissions() {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        }
    }
    
    func getDocumentsDir() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL {
        let filename = "recordedAudio.m4a"
        let filePath = getDocumentsDir().appendingPathComponent(filename)
        return filePath
    }
    
    func audioRecorder()
    {
        if isAudioRecordingGranted
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                recorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                recorder.delegate = self
                recorder.isMeteringEnabled = true
                recorder.prepareToRecord()
            }
            catch let error {
                displayCustomAlert(title: "Error", msg: error.localizedDescription, actionTitle: "OK")
            }
        }
        else
        {
            displayCustomAlert(title: "Error", msg: "Don't have access to use device's microphone", actionTitle: "OK")
        }
    }
    
    func displayCustomAlert(title : String , msg : String ,actionTitle : String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style:UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true)
    }
    
    func prepareAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch {
            print("Error")
        }
    }
    
    
    func finishAudioRecording(isSuccess: Bool) {
        if isSuccess {
            isMicWorking = true
            recorder.stop()
            recorder = nil
            print("recording success")
        }
        else {
            displayCustomAlert(title: "Error", msg: "Recording failed", actionTitle: "OK")
        }
    }
    //MARK:- public methods
    class func storyboardInstance() -> MicSpeakerTestViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MicSpeakerTest") as! MicSpeakerTestViewController
        return vc
    }
    
    //MARK:- Button Action methods
    @IBAction func recordAudio(_ sender: Any) {
        
        if isRecording {
            finishAudioRecording(isSuccess: true)
            recordAudioBtn.setTitle("Record", for: .normal)
            playAudioBtn.isEnabled = true
            isRecording = false
        }
        else {
            audioRecorder()
            recorder.record()
            recordAudioBtn.setTitle("Stop", for: .normal)
            playAudioBtn.isEnabled = false
            isRecording = true
        }
    }
    
    @IBAction func playAudio(_ sender: Any) {
        if isPlaying {
            audioPlayer.stop()
            recordAudioBtn.isEnabled = true
            playAudioBtn.setTitle("Play", for: .normal)
            isPlaying = false
        }
        else {
            if FileManager.default.fileExists(atPath: getFileUrl().path) {
                recordAudioBtn.isEnabled = false
                playAudioBtn.setTitle("pause", for: .normal)
                prepareAudioPlayer()
                audioPlayer.play()
                isPlaying = true
            }
            else {
                displayCustomAlert(title: "Error", msg: "Audio file does not exist", actionTitle: "OK")
            }
        }
    }
    
    @IBAction func submitResult(_ sender: Any) {
        self.delegate?.micSpeakerTestResult(isMicWorking: isMicWorking, isSpeakerWorking: isSpeakerWorking)
        self.navigationController?.popViewController(animated:true)
    }
    
    //MARK:- Recorder and audio player delegate methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag {
            finishAudioRecording(isSuccess: false)
        }
        playAudioBtn.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordAudioBtn.isEnabled = true
        isSpeakerWorking = flag
    }
    
}

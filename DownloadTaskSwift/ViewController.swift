//
//  ViewController.swift
//  DownloadTaskSwift
//
//  Created by Poonam on 28/07/19.
//  Copyright © 2019 Poonam. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var progress_label: UILabel!
    @IBOutlet weak var progress_bar: UIProgressView!
    @IBOutlet weak var download_button: UIButton!
    @IBOutlet weak var pause_resume_button: UIButton!
    @IBOutlet weak var stop_button: UIButton!
    
    var downloadTask: URLSessionDownloadTask?
    var urlSession: URLSession?
    var is_downloading: Bool = false
    var downloaded_data: Data?
    
    
    @IBAction func handlDownloadButton(_ sender: UIButton) {
        if sender.tag == 0 {
            // Handle start download action
            downloaded_data = nil
            is_downloading = true
            resetProgressBar()
            startDownloadingFile()
        }
        else if sender.tag == 1 {
            // Handle pause and resume download action
            pauseAndResumeAction()
        }
        else if sender.tag == 2 {
            // Handle stop download action
            stopDownloadingFile()
        }
    }
    
    // Start downloading file
    
    func startDownloadingFile() {
        guard let url = URL(string: "http://techslides.com/demos/sample-videos/small.mp4") else { return }
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        self.downloadTask = urlSession?.downloadTask(with: url)
        self.downloadTask?.resume()
    }
    
    // Handle pause and resume
    
    func pauseAndResumeAction() {
        
        // Pause action
        
        if is_downloading {
            downloadTask?.cancel(byProducingResumeData: { (data) in
                self.downloaded_data = data
            })
            downloadTask = nil
            pause_resume_button.setTitle("Resume", for: .normal)
            is_downloading = false
        }
        else if !is_downloading && downloaded_data != nil {
            downloadTask = urlSession?.downloadTask(withResumeData: downloaded_data!)
            downloadTask?.resume()
            is_downloading = true
            pause_resume_button.setTitle("Pause", for: .normal)
        }
    }
    
    // Stop downloading file
    
    func stopDownloadingFile() {
        downloadTask?.cancel()
        
        is_downloading = false
        downloaded_data = nil
        downloaded_data = nil
        resetProgressBar()
    }
    
    func documentDirectoryURL() -> URL {
        let doucmentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return doucmentDirectory[0]
    }
    
    func playVideo(location: URL) {
        let destinationURL = documentDirectoryURL().appendingPathComponent("file.mp4")
        try? FileManager.default.moveItem(at: location, to: destinationURL)
        
        let avPlaterController = AVPlayerViewController()
        avPlaterController.player = AVPlayer(url: destinationURL)
        avPlaterController.player?.play()
        self.present(avPlaterController, animated: true, completion: nil)
    }
    
    func resetProgressBar() {
        progress_bar.setProgress(0.0, animated: false)
        progress_label.text = "0%"
        pause_resume_button.setTitle("Pause", for: .normal)
    }
    
}

extension ViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Downloading finish")
        playVideo(location: location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progress_bar.setProgress(progress, animated: true)
        progress_label.text = "\(progress * 100)%"
    }
    
}

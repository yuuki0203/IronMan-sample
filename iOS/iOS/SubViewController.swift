//
//  SubViewController.swift
//  AR_APP
//
//  Created by bei on 2020/07/01.
//  Copyright © 2020 bei. All rights reserved.
//
import Foundation
import AVFoundation
import UIKit

var model = "global"
var CBcheck = false

class SubViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var Button: UIButton!
    @IBOutlet weak var Button2: UIButton!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    func appOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    func convertUIOrientation2VideoOrientation(f: () -> UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
        let v = f()
        switch v {
        case UIInterfaceOrientation.unknown:
            return nil
        default:
            return ([
                UIInterfaceOrientation.portrait: AVCaptureVideoOrientation.portrait,
                UIInterfaceOrientation.portraitUpsideDown: AVCaptureVideoOrientation.portraitUpsideDown,
                UIInterfaceOrientation.landscapeLeft: AVCaptureVideoOrientation.landscapeLeft,
                UIInterfaceOrientation.landscapeRight: AVCaptureVideoOrientation.landscapeRight
            ])[v]
        }
    }
    //カメラやマイクの入出力を管理するオブジェクトを作成
    let session = AVCaptureSession()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //カメラやマイクのデバイスそのものを管理するオブジェクトを生成(ここではワイドアングルカメラ・ビデオ・背面カメラを指定)
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        //ワイドアングルカメラ・ビデオ・背面カメラに該当するデバイスを取得
        let devices = discoverySession.devices
        
        //該当するデバイスのうち最初に取得したものを利用する
        if let backCamera = devices.first {
            do{
                //QRコードの読み取りに背面カメラの映像を利用するための設定
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    
                    //背面カメラの映像からQRコードを検出するための設定
                    let metadataOutput = AVCaptureMetadataOutput()
                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)
                        
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        
                        //背面カメラの映像を画面に表示するためのレイヤーを生成
                        previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        previewLayer.frame = self.view.bounds
                        previewLayer.videoGravity = .resizeAspectFill
                        if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}){
                            previewLayer.connection?.videoOrientation = orientation
                        }
                        self.view.layer.addSublayer(previewLayer)
                        self.view.bringSubviewToFront(label1)
                        self.view.bringSubviewToFront(Button)
                        self.view.bringSubviewToFront(Button2)
                        //読み取り開始
                        self.session.startRunning()
                    }
                }
            }catch{
                print("Error occured while creating video device input: \(error)")
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let previewLayer = previewLayer{
            previewLayer.frame = view.bounds
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: {(UIViewControllerTransitionCoordinatorContext) in
            if let orientation = self .convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}){
                self.previewLayer.connection?.videoOrientation = orientation
            }
        }
        )
    }
    override func viewDidAppear(_ animated: Bool) {
        if CBcheck == true {
            //戻ってきたときに読み取り再開
            self.session.startRunning()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject]{
            //QRコードのデータかどうかの確認
            if metadata.type != .qr { continue }
            
            //QRコードの内容が空かどうかの確認
            if metadata.stringValue == nil { continue }
            
            //URLかどうかの確認
            if let url = URL(string: metadata.stringValue!) {
                //読み取り終了
                self.session.stopRunning()
                //読み取ったURLをグローバル変数に入れる
                model = url.absoluteString
                self.performSegue(withIdentifier: "toSecond", sender: nil)
            }
        }
    }
    @IBAction func ButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func GraphTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toGraph", sender: nil)
    }
}



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */



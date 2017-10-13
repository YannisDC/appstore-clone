//
//  StoryViewController.swift
//  AppStoreClone
//
//  Created by Yannis De Cleene on 12/10/17.
//  Copyright © 2017 Phill Farrugia. All rights reserved.
//

import UIKit

struct Subbrand: Decodable {
    let body: String
}

class StoryViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var headerScrollView: UIScrollView?
    var textScrollView = UIScrollView()
    var fullWidth = UIScreen.main.bounds.width
    var fullHeight = UIScreen.main.bounds.height
    var headerHeight: CGFloat = 490.0
    let buttonView = UIView()
    let blurView = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
    let closeButton = UIButton()
    
    private var yPanned: CGFloat = 0.0
    private let maxScaling = (UIScreen.main.bounds.width - 40) / UIScreen.main.bounds.width
    
    override var prefersStatusBarHidden: Bool { return true }
    var isOnTop: Bool {
        get {
            return (headerScrollView?.contentOffset.y == 0)
        }
    }
    
    var textLabel: UILabel {
        get {
            let contentLabel = UILabel()
            contentLabel.translatesAutoresizingMaskIntoConstraints = false
            contentLabel.numberOfLines = 0
            contentLabel.lineBreakMode = .byWordWrapping
            contentLabel.font = UIFont.systemFont(ofSize: 20.0)
            contentLabel.textColor = UIColor(red:0.51, green:0.51, blue:0.53, alpha:1.0)
            return contentLabel
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: fullWidth, height: fullHeight))
        headerScrollView?.contentSize = CGSize(width: fullWidth, height: 2000)
        headerScrollView?.clipsToBounds = true
        headerScrollView?.delegate = self
        headerScrollView?.isScrollEnabled = true
        headerScrollView?.bounces = false
        addPanGesture(view: headerScrollView!)
        self.view.addSubview(headerScrollView!)
        
        var headerImage = UIImageView(frame: CGRect(x: 0, y: 0, width: fullWidth, height: headerHeight))
        headerImage.image = #imageLiteral(resourceName: "monument-valley")
        headerScrollView?.addSubview(headerImage)
        
        textScrollView = UIScrollView(frame: CGRect(x: 0, y: 500, width: fullWidth, height: 2000))
        textScrollView.delegate = self
        textScrollView.isScrollEnabled = true
        headerScrollView?.addSubview(textScrollView)
        
        let jsonUrlString = "https://gist.githubusercontent.com/YannisDC/615d1eec52329e20f2cf59f02cb70479/raw/91815af3f62b13e2d74692a2401a27b9ff037325/test.json"
        
        
        var previousItemAnchor = textScrollView.topAnchor
        var margin: CGFloat = 26.0
        
        let url = URL(string: jsonUrlString)
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            do {
                let subbrands = try JSONDecoder().decode([Subbrand].self, from: data)
                
                DispatchQueue.main.async { [weak self] in
                    for subbrand in subbrands {
                        var firstText = self?.textLabel
                        self?.textScrollView.addSubview(firstText!)
                        
                        self?.layoutTextLabel(label: firstText!, text: subbrand.body, anchor: previousItemAnchor, margin: margin)
                        margin = 20.0
                        previousItemAnchor = firstText!.bottomAnchor
                    }
                }
            } catch let jsonErr {
                print(jsonErr)
            }
            }.resume()
        
        
        headerScrollView?.addSubview(buttonView)
        layoutButton(view: buttonView)
        blurView.layer.cornerRadius = 14.0
        blurView.clipsToBounds = true
        blurView.effect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        buttonView.addSubview(blurView)
        
        closeButton.frame = CGRect(x: 7, y: 7, width: 14, height: 14)
        closeButton.setImage(#imageLiteral(resourceName: "icn_cross_light"), for: .normal)
        buttonView.addSubview(closeButton)
    }
    
    
    
    // MARK: Layouting
    func layoutTextLabel(label: UILabel, text: String, anchor: NSLayoutYAxisAnchor, margin: CGFloat) {
        // K0,34 L25
        label.attributedText = NSAttributedString(string: text)
        
        label.topAnchor.constraint(equalTo: anchor, constant: margin).isActive = true
        if #available(iOS 11.0, *) {
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        } else {
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        }
    }
    
    func layoutButton(view buttonView: UIView) {
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        buttonView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        if #available(iOS 11.0, *) {
            buttonView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
            buttonView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        } else {
            buttonView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
            buttonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < (headerHeight - 34) {
            blurView.effect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
            closeButton.setImage(#imageLiteral(resourceName: "icn_cross_light"), for: .normal)
        } else {
            blurView.effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            closeButton.setImage(#imageLiteral(resourceName: "icn_cross_dark"), for: .normal)
        }
    }
    
    
    
    // MARK: Pan gesture functionality
    func addPanGesture(view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (isOnTop && gestureRecognizer is UIPanGestureRecognizer) {
            let pan = gestureRecognizer as! UIPanGestureRecognizer
            return pan.translation(in: view).y > 0 ? true : false
        }
        return false
    }
    
    @objc func handlePan(sender:UIPanGestureRecognizer) {
        let headerView = sender.view
        let translation = sender.translation(in: view)
        
        let scalingSpeed = (1 - maxScaling) / 25
        let cornerSpeed: CGFloat = 14.0 / 25.0
        
        switch sender.state {
        case .began, .changed:
            if yPanned < 25 && yPanned > 0 {
                let scalingFactor = 1 - scalingSpeed * yPanned
                headerView?.transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
                headerView?.layer.cornerRadius = cornerSpeed * yPanned
                buttonView.layer.opacity = Float(1.0 - (yPanned * 4.0) / 100.0)
            }
            sender.setTranslation(CGPoint.zero, in: view)
            yPanned += (translation.y / 4.0)
        case .ended:
            if yPanned > 50 {
                print("segueing")
            } else {
                UIView.animate(withDuration: 0.2,
                               delay: 0.0,
                               usingSpringWithDamping: 1.0,
                               initialSpringVelocity: 0.2,
                               options: .beginFromCurrentState,
                               animations: { [weak self] in
                                headerView?.transform = CGAffineTransform.identity
                                headerView?.layer.cornerRadius = 0
                                self?.buttonView.layer.opacity = 1.0
                }) { (finished) in
                    self.yPanned = 0.0
                }
            }
        default:
            break
        }
    }
}

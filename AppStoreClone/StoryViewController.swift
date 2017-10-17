//
//  StoryViewController.swift
//  AppStoreClone
//
//  Created by Yannis De Cleene on 12/10/17.
//  Copyright © 2017 Phill Farrugia. All rights reserved.
//

import UIKit
import MarkdownKit

struct TextBlock: Decodable {
    let type: String
    let text: String
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
    var callToActionView = UIView()
    
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
            return contentLabel
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerScrollView = UIScrollView()
        self.view.addSubview(headerScrollView!)
        headerScrollView?.translatesAutoresizingMaskIntoConstraints = false
        headerScrollView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerScrollView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerScrollView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerScrollView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        headerScrollView?.contentSize = CGSize(width: fullWidth, height: 2000)
        headerScrollView?.clipsToBounds = true
        headerScrollView?.delegate = self
        headerScrollView?.isScrollEnabled = true
        headerScrollView?.bounces = false
        addPanGesture(view: headerScrollView!)
        
        
        var headerImage = UIImageView(frame: CGRect(x: 0, y: 0, width: fullWidth, height: headerHeight))
        headerImage.image = #imageLiteral(resourceName: "monument-valley")
        headerScrollView?.addSubview(headerImage)
        
        textScrollView = UIScrollView(frame: CGRect(x: 0, y: 500, width: fullWidth, height: 2000))
        textScrollView.delegate = self
        textScrollView.isScrollEnabled = true
        headerScrollView?.addSubview(textScrollView)
        
        let jsonUrlString = "https://gist.githubusercontent.com/YannisDC/615d1eec52329e20f2cf59f02cb70479/raw/b08c1efd46abbd34758ceeab0ad7beed85378b75/test.json"
        
        
        var previousItemAnchor = textScrollView.topAnchor
        var margin: CGFloat = 26.0
        
        
        // This stuff is ugly
        let url = URL(string: jsonUrlString)
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            do {
                let subbrands = try JSONDecoder().decode([TextBlock].self, from: data)
                
                DispatchQueue.main.async { [weak self] in
                    for subbrand in subbrands {
                        var firstText = self?.textLabel
                        self?.textScrollView.addSubview(firstText!)
                        
                        self?.layoutTextLabel(label: firstText!, text: subbrand.text, anchor: previousItemAnchor, margin: margin)
                        margin = 25.0
                        previousItemAnchor = firstText!.bottomAnchor
                    }
                    let pictureContainerView = UIView(frame: CGRect(x: 20, y: 730, width: 335, height: 300))
                    self?.textScrollView.addSubview(pictureContainerView)
                    pictureContainerView.backgroundColor = .blue
                    pictureContainerView.clipsToBounds = true
                    pictureContainerView.layer.cornerRadius = 7.0
                    
                    let textViewContainer = UIView()
                    pictureContainerView.addSubview(textViewContainer)
                    textViewContainer.backgroundColor = UIColor(red:0.95, green:0.96, blue:0.96, alpha:1.0)
                    textViewContainer.translatesAutoresizingMaskIntoConstraints = false
                    textViewContainer.leadingAnchor.constraint(equalTo: (textViewContainer.superview?.leadingAnchor)!).isActive = true
                    textViewContainer.trailingAnchor.constraint(equalTo: (textViewContainer.superview?.trailingAnchor)!).isActive = true
                    textViewContainer.bottomAnchor.constraint(equalTo: (textViewContainer.superview?.bottomAnchor)!).isActive = true
                    
                    let textLabel = UILabel()
                    textViewContainer.addSubview(textLabel)
                    textLabel.textColor = UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)
                    textLabel.text = "Dribbble's Apple TV-app is een geweldige manier om al achteroverleunend inspiratie op te doen."
                    textLabel.numberOfLines = 0
                    textLabel.font = UIFont.systemFont(ofSize: 15)
                    textLabel.translatesAutoresizingMaskIntoConstraints = false
                    textLabel.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: 20).isActive = true
                    textLabel.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: -20).isActive = true
                    textLabel.topAnchor.constraint(equalTo: textViewContainer.topAnchor, constant: 16).isActive = true
                    textLabel.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: -16).isActive = true
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
        
        
        
        
        // Call to action pop-up
        view.addSubview(callToActionView)
        layoutCallToActionView(view: callToActionView)
        
        let blurryBackground = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.prominent))
        blurryBackground.frame.size = CGSize(width: 359, height: 68)
        blurryBackground.frame.origin = CGPoint(x: 0, y: 0)
        blurryBackground.layer.cornerRadius = 14.0
        blurryBackground.clipsToBounds = true
        callToActionView.addSubview(blurryBackground)
        
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 48, height: 48))
        imageView.image = #imageLiteral(resourceName: "app-icon")
        imageView.layer.cornerRadius = 9.0
        imageView.clipsToBounds = true
        callToActionView.addSubview(imageView)
        
        let titleView = UILabel(frame: CGRect(x: 76, y: 16, width: 200, height: 18))
        let attributedText = NSMutableAttributedString(string: "Dribbble")
        titleView.textColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.0)
        titleView.font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightSemibold)
        titleView.attributedText = attributedText
        titleView.kerning = 0.65
        callToActionView.addSubview(titleView)
        
        let categoryView = UILabel(frame: CGRect(x: 76, y: 36, width: 200, height: 18))
        let categoryAttributedText = NSMutableAttributedString(string: "Foto en video")
        categoryView.textColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.0)
        categoryView.font = UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightMedium)
        categoryView.attributedText = categoryAttributedText
        categoryView.kerning = 0.6
        callToActionView.addSubview(categoryView)
        
        let actionButton = UIButton(frame: CGRect(x: 246, y: 21, width: 103, height: 26))
        actionButton.backgroundColor = UIColor(red:0.39, green:0.39, blue:0.39, alpha:1.0)
        actionButton.layer.cornerRadius = 12.0
        actionButton.clipsToBounds = true
        callToActionView.addSubview(actionButton)
        
        
        let typeLabel = UILabel(frame: CGRect(x: 20, y: 9, width: 200, height: 32))
        let attributedTypeText = NSMutableAttributedString(string: "WORLD PREMIER")
        typeLabel.textColor = UIColor.white
        typeLabel.font = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightSemibold)
        typeLabel.attributedText = attributedTypeText
        typeLabel.kerning = 0.55
        headerImage.addSubview(typeLabel)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 335, height: 33))
        let attributedTitleText = NSMutableAttributedString(string: "The Art of\nthe Impossible")
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 28.0, weight: UIFontWeightSemibold)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.attributedText = attributedTitleText
        titleLabel.kerning = 0.75
        headerImage.addSubview(titleLabel)
        titleLabel.sizeToFit()
        
        
    }
    
    
    
    // MARK: Layouting
    func layoutTextLabel(label: UILabel, text: String, anchor: NSLayoutYAxisAnchor, margin: CGFloat) {
        // K0,34 L25
        let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 20.0))
        markdownParser.bold.font = UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightSemibold)
        markdownParser.bold.color = UIColor.black
        label.textColor = UIColor(red:0.51, green:0.51, blue:0.53, alpha:1.0)
        let parsedString = markdownParser.parse(text) as! NSMutableAttributedString
        let style = NSMutableParagraphStyle()

        style.lineSpacing = 1.2
        parsedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, parsedString.length))
        parsedString.addAttributes([NSKernAttributeName:0.0], range:NSMakeRange(0, parsedString.length))
        label.attributedText = parsedString
        
        label.topAnchor.constraint(equalTo: anchor, constant: margin).isActive = true
        if #available(iOS 11.0, *) {
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        } else {
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
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
    
    func layoutCallToActionView(view callToActionView: UIView) {
        callToActionView.translatesAutoresizingMaskIntoConstraints = false
        callToActionView.heightAnchor.constraint(equalToConstant: 68).isActive = true
        if #available(iOS 11.0, *) {
            callToActionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
            callToActionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            callToActionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        } else {
            callToActionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8).isActive = true
            callToActionView.topAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            callToActionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8).isActive = true
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
        
        if scrollView.contentOffset.y > headerHeight {
            UIView.animate(withDuration: 1.2,
                           delay: 0.0,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 0.0,
                           options: .beginFromCurrentState,
                           animations: { [weak self] in
                            self?.callToActionView.frame.origin.y = (self?.fullHeight)! - 76
            })
        } else {
            UIView.animate(withDuration: 0.4,
                           delay: 0.0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0.2,
                           options: .beginFromCurrentState,
                           animations: { [weak self] in
                            self?.callToActionView.frame.origin.y = (self?.fullHeight)!
            })
        }
        
        
    }
    
    internal func configureRoundedCorners(shouldRound: Bool) {
        headerScrollView?.layer.cornerRadius = shouldRound ? 14.0 : 0.0
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
            var scalingFactor:CGFloat = 1.0
            var opacity: Float = 1.0
            var radius: CGFloat = 0.0
            
            switch yPanned {
            case _ where yPanned < 0:
                scalingFactor = 1.0
                opacity = 1.0
                radius = 0.0
            case _ where yPanned > 25:
                scalingFactor = 1 - scalingSpeed * 25
                opacity = 0.0
                radius = 14.0
            default:
                scalingFactor = 1 - scalingSpeed * yPanned
                opacity = Float(1.0 - (yPanned * 4.0) / 100.0)
                radius = cornerSpeed * yPanned
            }
            
            headerView?.transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
            headerView?.layer.cornerRadius = radius
            buttonView.layer.opacity = opacity
            sender.setTranslation(CGPoint.zero, in: view)
            yPanned += (translation.y / 4.0)
        case .ended:
            if yPanned > 25 {
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

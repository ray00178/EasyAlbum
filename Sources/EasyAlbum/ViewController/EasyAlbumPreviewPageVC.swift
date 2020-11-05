//
//  EasyAlbumPreviewPageVC.swift
//  EasyAlbum
//
//  Created by Ray on 2019/8/26.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit
import Photos

class EasyAlbumPreviewPageVC: UIPageViewController {

    private var backButton: UIButton!
    private var numberButton: UIButton!
    private var smallNumberLabel: UILabel!
    private var sendButton: UIButton!
    private var toast: AlbumToast?
    
    private let photoManager: PhotoManager = PhotoManager.share
    
    /// Be remove asset
    private var removeAsset: PHAsset?
    
    /// Control statusbar need hidden，default = false
    private var hide: Bool = false
    
    private var currentViewController: EasyAlbumPageContentVC? {
        return viewControllers?.first as? EasyAlbumPageContentVC
    }
    
    var limit: Int = EasyAlbumCore.LIMIT
    var pickColor: UIColor = EasyAlbumCore.PICK_COLOR
    var message: String = EasyAlbumCore.MESSAGE
    var orientation: UIInterfaceOrientationMask = EasyAlbumCore.ORIENTATION
    
    /// The cell frame，default = .zero
    var cellFrame: CGRect = .zero
    
    var currentItem: Int = 0
    
    /// Origin all assets
    var assets: PHFetchResult<PHAsset>?
    
    /// Record selected assets and pick number
    var selectedPhotos: [PhotoData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override var prefersStatusBarHidden: Bool {
        return hide
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientation
    }

    private func setup() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        view.backgroundColor = .black
        
        backButton = UIButton(type: .system)
        backButton.setImage(UIImage.bundle(image: .close), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self,
                             action: #selector(back(_:)),
                             for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        numberButton = UIButton(type: .custom)
        numberButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        numberButton.setTitleColor(UIColor.white, for: .normal)
        numberButton.layer.cornerRadius = 15.0
        numberButton.layer.borderColor = UIColor.white.cgColor
        numberButton.layer.borderWidth = 3.0
        numberButton.addTarget(self,
                               action: #selector(clickedNumberPhoto(_:)),
                               for: .touchUpInside)
        numberButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(numberButton)
        
        let padding: CGFloat = 14.0
        sendButton = UIButton(type: .custom)
        sendButton.setImage(UIImage.bundle(image: .done), for: .normal)
        sendButton.imageEdgeInsets = UIEdgeInsets(top: padding,
                                                  left: padding,
                                                  bottom: padding,
                                                  right: padding)
        sendButton.backgroundColor = .white
        sendButton.layer.cornerRadius = 25.0
        sendButton.addTarget(self,
                             action: #selector(done(_:)),
                             for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        
        smallNumberLabel = UILabel(frame: .zero)
        smallNumberLabel.text = "\(selectedPhotos.count)"
        smallNumberLabel.textColor = .white
        smallNumberLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        smallNumberLabel.textAlignment = .center
        smallNumberLabel.backgroundColor = pickColor
        smallNumberLabel.layer.cornerRadius = 11.0
        smallNumberLabel.layer.masksToBounds = true
        smallNumberLabel.isHidden = selectedPhotos.count == 0
        smallNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(smallNumberLabel)
        
        // AutoLayout Start
        var btnWH: CGFloat = 23.0
        backButton.widthAnchor
                  .constraint(equalToConstant: btnWH)
                  .isActive = true
        backButton.heightAnchor
                  .constraint(equalToConstant: btnWH)
                  .isActive = true
        
        if #available(iOS 11.0, *) {
            backButton.topAnchor
                      .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0)
                      .isActive = true
            backButton.leadingAnchor
                      .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0)
                      .isActive = true
        } else {
            backButton.topAnchor
                      .constraint(equalTo: view.topAnchor, constant: 30.0)
                      .isActive = true
            backButton.leadingAnchor
                      .constraint(equalTo: view.leadingAnchor, constant: 16.0)
                      .isActive = true
        }
        
        btnWH = 30.0
        numberButton.widthAnchor
                    .constraint(equalToConstant: btnWH)
                    .isActive = true
        numberButton.heightAnchor
                    .constraint(equalToConstant: btnWH)
                    .isActive = true
        
        if #available(iOS 11.0, *) {
            numberButton.bottomAnchor
                        .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24.0)
                        .isActive = true
        } else {
            numberButton.bottomAnchor
                        .constraint(equalTo: view.bottomAnchor, constant: -24.0)
                        .isActive = true
        }
        
        numberButton.centerXAnchor
                    .constraint(equalTo: backButton.centerXAnchor)
                    .isActive = true
        
        btnWH = 50.0
        sendButton.widthAnchor
                  .constraint(equalToConstant: btnWH)
                  .isActive = true
        sendButton.heightAnchor
                  .constraint(equalToConstant: btnWH)
                  .isActive = true
        sendButton.centerYAnchor
                  .constraint(equalTo: numberButton.centerYAnchor)
                  .isActive = true
        
        if #available(iOS 11.0, *) {
            sendButton.trailingAnchor
                      .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22.0)
                      .isActive = true
        } else {
            sendButton.trailingAnchor
                      .constraint(equalTo: view.trailingAnchor, constant: -22.0)
                      .isActive = true
        }
        
        btnWH = 22.0
        smallNumberLabel.widthAnchor
                        .constraint(equalToConstant: btnWH)
                        .isActive = true
        smallNumberLabel.heightAnchor
                        .constraint(equalToConstant: btnWH)
                        .isActive = true
        smallNumberLabel.topAnchor
                        .constraint(equalTo: sendButton.topAnchor, constant: -5.0)
                        .isActive = true
        smallNumberLabel.trailingAnchor
                        .constraint(equalTo: sendButton.trailingAnchor, constant: 5.0)
                        .isActive = true
        // AutoLayou End
        
        dataSource = self
        delegate = self
        
        addContentViewController()
        addToastView()
        changeButtonNumber()
    }
    
    private func addContentViewController() {
        let vc = EasyAlbumPageContentVC()
        vc.cellFrame = cellFrame
        vc.asset = assets?[currentItem]
        vc.delegate = self
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }

    private func addToastView() {
        toast = AlbumToast(navigationVC: nil, barTintColor: nil)
        toast?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast!)
        
        toast?.topAnchor
              .constraint(equalTo: view.topAnchor)
              .isActive = true
        toast?.leadingAnchor
              .constraint(equalTo: view.leadingAnchor)
              .isActive = true
        toast?.trailingAnchor
              .constraint(equalTo: view.trailingAnchor)
              .isActive = true
        
        let height = UIScreen.statusBarHeight + 44.0
        toast?.heightAnchor
              .constraint(equalToConstant: height)
              .isActive = true
    }
    
    private func changeButtonNumber() {
        let current = assets?[currentItem]
        
        let pickNumber = selectedPhotos.first { $0.asset == current }?.number ?? 0
        numberButton.layer.borderColor = pickNumber > 0 ?
                                         pickColor.cgColor :
                                         UIColor(white: 1.0, alpha: 0.78).cgColor
        numberButton.backgroundColor = pickNumber > 0 ?
                                       pickColor :
                                       UIColor(hex: "000000", alpha: 0.1)
        numberButton.setTitle(pickNumber > 0 ? "\(pickNumber)" : "", for: .normal)
    }
    
    private func changePhotoNumber() {
        var reoloadItems: [Int] = []
        for (index, values) in selectedPhotos.enumerated() {
            selectedPhotos[index] = (values.asset, index + 1)
            
            if let i = assets?.index(of: values.asset) {
                reoloadItems.append(i)
            }
        }
        
        // Add remove asset of index
        if let remove = removeAsset,
           let i = assets?.index(of: remove) {
            reoloadItems.append(i)
        }
        
        // clear
        removeAsset = nil
        
        let notification = AlbumNotification(reloadItems: reoloadItems.map({ IndexPath(item: $0, section: 0) }),
                                             selectedPhotos: selectedPhotos)
        NotificationCenter.default.post(name: .EasyAlbumPhotoNumberDidChangeNotification,
                                        object: notification)
        
        smallNumberLabel.text = "\(selectedPhotos.count)"
        smallNumberLabel.isHidden = selectedPhotos.count == 0
    }
    
    @objc private func done(_ btn: UIButton) {
        NotificationCenter.default.post(name: .EasyAlbumPreviewPageDismissNotification,
                                        object: AlbumNotification(isSend: true))
        
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func back(_ btn: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func clickedNumberPhoto(_ btn: UIButton) {
        guard let asset = assets?[currentItem] else { return }
        
        let isCheck = selectedPhotos.contains { $0.asset == asset }
        
        if isCheck {
            removeAsset = asset
            selectedPhotos.removeAll { $0.asset == asset }
        } else {
            guard selectedPhotos.count <= (limit - 1) else {
                toast?.show(with: message)
                return
            }
            
            selectedPhotos.append((asset, selectedPhotos.count + 1))
        }
        
        changeButtonNumber()
        changePhotoNumber()
    }
}

// MARK: - UIPageViewControllerDataSource & UIPageViewControllerDelegate
extension EasyAlbumPreviewPageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? EasyAlbumPageContentVC,
           let asset = vc.asset,
            let index = assets?.index(of: asset),
            index - 1 >= 0 {
            let vc = EasyAlbumPageContentVC()
            vc.asset = assets?[index - 1]
            vc.delegate = self
            return vc
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? EasyAlbumPageContentVC,
           let asset = vc.asset,
            let index = assets?.index(of: asset),
            index + 1 < assets?.count ?? 0 {
            let vc = EasyAlbumPageContentVC()
            vc.asset = assets?[index + 1]
            vc.delegate = self
            return vc
        }

        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        guard let currentVC = currentViewController,
              let asset = currentVC.asset,
              let index = assets?.index(of: asset),
              completed == true
        else { return }

        currentItem = index
        changeButtonNumber()
    }
}

// MARK: - EAPageContentViewControllerDelegate
extension EasyAlbumPreviewPageVC: EasyAlbumPageContentVCDelegate {
    
    func singleTap(_ viewController: EasyAlbumPageContentVC) {
        hide.toggle()
        setNeedsStatusBarAppearanceUpdate()
        
        let views: [UIView] = [backButton, sendButton, smallNumberLabel]
        UIView.animate(withDuration: 0.32) {
            views.forEach({ $0.alpha = self.hide ? 0.0 : 1.0 })
        }
    }
    
    func panDidChanged(_ viewController: EasyAlbumPageContentVC, in targetView: UIView, alpha: CGFloat) {
        let views: [UIView] = [backButton, sendButton, smallNumberLabel]
        views.forEach({ $0.alpha = alpha })
        view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha)
    }
    
    func panDidEnded(_ viewController: EasyAlbumPageContentVC, in targetView: UIView) {
        dismiss(animated: false, completion: nil)
    }
}

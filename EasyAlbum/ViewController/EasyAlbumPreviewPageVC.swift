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

    private var mBackBtn: UIButton!
    private var mNumberBtn: UIButton!
    private var mSmallNumberLab: UILabel!
    private var mSendBtn: UIButton!
    private var mToast: AlbumToast?
    
    private let photoManager: PhotoManager = PhotoManager.share
    
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
    
    var selectedItem: Int = 0
    
    /// Origin all photos
    var mAlbumPhotos: [AlbumPhoto] = []
    
    /// Record selected photos
    var mSelectedPhotos: [AlbumPhoto] = []
    
    /// Record delete items
    var mRemoveItems: [Int] = []
    
    weak var pageDelegate: EasyAlbumPreviewPageVCDelegate?
    
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
        
        var btnWH: CGFloat = 26.0
        mBackBtn = UIButton(type: .system)
        mBackBtn.setImage(UIImage.bundle(image: .back), for: .normal)
        mBackBtn.tintColor = .white
        mBackBtn.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        mBackBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mBackBtn)
        
        mBackBtn.widthAnchor.constraint(equalToConstant: btnWH).isActive = true
        mBackBtn.heightAnchor.constraint(equalToConstant: btnWH).isActive = true
        if #available(iOS 11.0, *) {
            mBackBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0).isActive = true
            mBackBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22.0).isActive = true
        } else {
            mBackBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 28.0).isActive = true
            mBackBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22.0).isActive = true
        }
        
        btnWH = 30.0
        mNumberBtn = UIButton(type: .custom)
        mNumberBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        mNumberBtn.setTitleColor(UIColor.white, for: .normal)
        mNumberBtn.layer.cornerRadius = btnWH / 2
        mNumberBtn.layer.borderColor = UIColor.white.cgColor
        mNumberBtn.layer.borderWidth = 3.0
        mNumberBtn.addTarget(self, action: #selector(numberClicked(_:)), for: .touchUpInside)
        mNumberBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mNumberBtn)
        
        mNumberBtn.widthAnchor.constraint(equalToConstant: btnWH).isActive = true
        mNumberBtn.heightAnchor.constraint(equalToConstant: btnWH).isActive = true
        if #available(iOS 11.0, *) {
            mNumberBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24.0).isActive = true
        } else {
            mNumberBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24.0).isActive = true
        }
        mNumberBtn.centerXAnchor.constraint(equalTo: mBackBtn.centerXAnchor).isActive = true
        
        btnWH = 50.0
        let padding: CGFloat = 14.0
        mSendBtn = UIButton(type: .custom)
        mSendBtn.setImage(UIImage.bundle(image: .done), for: .normal)
        mSendBtn.imageEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        mSendBtn.backgroundColor = .white
        mSendBtn.layer.cornerRadius = btnWH / 2
        mSendBtn.addTarget(self, action: #selector(done(_:)), for: .touchUpInside)
        mSendBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mSendBtn)
        
        mSendBtn.widthAnchor.constraint(equalToConstant: btnWH).isActive = true
        mSendBtn.heightAnchor.constraint(equalToConstant: btnWH).isActive = true
        mSendBtn.centerYAnchor.constraint(equalTo: mNumberBtn.centerYAnchor).isActive = true
        if #available(iOS 11.0, *) {
            mSendBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22.0).isActive = true
        } else {
            mSendBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22.0).isActive = true
        }
        
        btnWH = 22.0
        mSmallNumberLab = UILabel(frame: .zero)
        mSmallNumberLab.text = "\(mSelectedPhotos.count)"
        mSmallNumberLab.textColor = .white
        mSmallNumberLab.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        mSmallNumberLab.textAlignment = .center
        mSmallNumberLab.backgroundColor = pickColor
        mSmallNumberLab.layer.cornerRadius = btnWH / 2
        mSmallNumberLab.layer.masksToBounds = true
        mSmallNumberLab.isHidden = mSelectedPhotos.count == 0
        mSmallNumberLab.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mSmallNumberLab)
        mSmallNumberLab.widthAnchor.constraint(equalToConstant: btnWH).isActive = true
        mSmallNumberLab.heightAnchor.constraint(equalToConstant: btnWH).isActive = true
        mSmallNumberLab.topAnchor.constraint(equalTo: mSendBtn.topAnchor, constant: -5.0).isActive = true
        mSmallNumberLab.trailingAnchor.constraint(equalTo: mSendBtn.trailingAnchor, constant: 5.0).isActive = true
        
        dataSource = self
        delegate = self
        
        addContentViewController()
        addToastView()
        changeButtonNumber()
    }
    
    private func addContentViewController() {
        let vc = EasyAlbumPageContentVC()
        vc.cellFrame = cellFrame
        vc.albumPhoto = mAlbumPhotos[selectedItem]
        vc.delegate = self
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }

    private func addToastView() {
        mToast = AlbumToast(navigationVC: nil, barTintColor: nil)
        mToast?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mToast!)
        
        mToast?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mToast?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mToast?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let height = UIScreen.statusBarHeight + 44.0
        mToast?.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    private func changeButtonNumber() {
        let photo = mAlbumPhotos[selectedItem]
        let pickNumber = photo.pickNumber
        mNumberBtn.layer.borderColor = pickNumber > 0 ?
            photo.pickColor.cgColor : UIColor(white: 1.0, alpha: 0.78).cgColor
        mNumberBtn.backgroundColor = pickNumber > 0 ?
            photo.pickColor : UIColor(hex: "000000", alpha: 0.1)
        mNumberBtn.setTitle(pickNumber > 0 ? "\(pickNumber)" : "", for: .normal)
    }
    
    private func changePhotoNumber() {
        for i in 0 ..< mSelectedPhotos.count {
            mSelectedPhotos[i].pickNumber = i + 1
            let asset = mSelectedPhotos[i].asset
            if let index = mAlbumPhotos.firstIndex(where: { return $0.asset == asset }) {
                mAlbumPhotos[index].pickNumber = i + 1
            }
        }
        
        mSmallNumberLab.text = "\(mSelectedPhotos.count)"
        mSmallNumberLab.isHidden = mSelectedPhotos.count == 0
    }
    
    @objc private func done(_ btn: UIButton) {
        pageDelegate?.easyAlbumPreviewPageVC(didSelectedWith: mSelectedPhotos, removeItems: mRemoveItems,
                                                         item: selectedItem, send: true)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func back(_ btn: UIButton) {
        pageDelegate?.easyAlbumPreviewPageVC(didSelectedWith: mSelectedPhotos, removeItems: mRemoveItems,
                                                         item: selectedItem, send: false)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func numberClicked(_ btn: UIButton) {
        let photo = mAlbumPhotos[selectedItem]
        let asset = photo.asset
        let isCheck = photo.isCheck
        
        if isCheck {
            if let i = mSelectedPhotos.firstIndex(where: { return $0.asset == asset }) {
                mSelectedPhotos.remove(at: i)
            }
            photo.pickNumber = 0
            mRemoveItems.append(selectedItem)
        } else {
            guard mSelectedPhotos.count <= (limit - 1) else {
                mToast?.show(with: message)
                return
            }
            
            photo.pickNumber = mSelectedPhotos.count + 1
            mSelectedPhotos.append(photo)
        }
        
        mAlbumPhotos[selectedItem].isCheck = !isCheck
        changeButtonNumber()
        changePhotoNumber()
    }
}

// MARK: - UIPageViewControllerDataSource & UIPageViewControllerDelegate
extension EasyAlbumPreviewPageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? EasyAlbumPageContentVC, let photo = vc.albumPhoto,
            let index = mAlbumPhotos.firstIndex(of: photo), index - 1 >= 0 {
            let vc = EasyAlbumPageContentVC()
            vc.albumPhoto = mAlbumPhotos[index - 1]
            vc.delegate = self
            return vc
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? EasyAlbumPageContentVC, let photo = vc.albumPhoto,
            let index = mAlbumPhotos.firstIndex(of: photo), index + 1 < mAlbumPhotos.count {
            let vc = EasyAlbumPageContentVC()
            vc.albumPhoto = mAlbumPhotos[index + 1]
            vc.delegate = self
            return vc
        }

        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let currentVC = currentViewController, let albumPhoto = currentVC.albumPhoto,
            let index = mAlbumPhotos.firstIndex(of: albumPhoto), completed else {
            return
        }
        
        selectedItem = index
        changeButtonNumber()
    }
}

// MARK: - EAPageContentViewControllerDelegate
extension EasyAlbumPreviewPageVC: EasyAlbumPageContentVCDelegate {
    func singleTap(_ viewController: EasyAlbumPageContentVC) {
        hide.toggle()
        setNeedsStatusBarAppearanceUpdate()
        let views: [UIView] = [mBackBtn, mSendBtn, mSmallNumberLab]
        UIView.animate(withDuration: 0.2) {
            views.forEach({ $0.alpha = self.hide ? 0.0 : 1.0 })
        }
    }
    
    func panDidChanged(_ viewController: EasyAlbumPageContentVC, in targetView: UIView, alpha: CGFloat) {
        let views: [UIView] = [mBackBtn, mSendBtn, mSmallNumberLab]
        views.forEach({ $0.alpha = alpha })
        view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: alpha)
    }
    
    func panDidEnded(_ viewController: EasyAlbumPageContentVC, in targetView: UIView) {
        pageDelegate?.easyAlbumPreviewPageVC(didSelectedWith: mSelectedPhotos, removeItems: mRemoveItems,
                                                         item: selectedItem, send: false)
        dismiss(animated: false, completion: nil)
    }
}

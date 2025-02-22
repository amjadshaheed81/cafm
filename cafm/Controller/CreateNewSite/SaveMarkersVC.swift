//
//  SaveMarkersVC.swift
//  cafm
//
//  Created by NS on 08/12/24.
//
//

import UIKit
import SCLAlertView
import SkeletonView
import SDWebImage

class SaveMarkersVC: UIViewController {
    
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var floorImageContainerView: UIView!
    @IBOutlet weak var floorView: UIView!
    @IBOutlet weak var floorViewWidth: NSLayoutConstraint!
    @IBOutlet weak var floorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floorImageView: UIImageView!
    
    private let loadingSCLAlertView = SCLAlertView(appearance: loadingSCLAppearance)
    private var loadingStatus: LoadingStatus = .default {
        didSet {
            if self.loadingStatus.hasData {
                self.mainView.isHidden = false
                self.emptyView.isHidden = true
            }else {
                if self.loadingStatus == .loading || self.loadingStatus.shouldReload {
                    self.emptyView.mainLbl.text = self.loadingStatus.rawValue
                    self.emptyView.isHidden = false
                    self.mainView.isHidden = true
                }else {
                    self.mainView.isHidden = false
                    self.emptyView.isHidden = true
                }
            }
        }
    }
    
    var siteLayoutModel: SiteLayoutModel?
    var siteLayoutDataArray: [SiteLayoutModel] = []
    
    private var filteredRoomItemArray: [SiteLayoutModel] = []
    private var saveMarkerItemArray: [MarkerModel] = [] {
        didSet {
            self.droppedMarkerItemArray = self.saveMarkerItemArray.filter { $0.roomId == self.siteLayoutModel?.id }
        }
    }
    private var droppedMarkerItemArray: [MarkerModel] = []
    private var markerViewArray: [MarkerView] = []
    private let responseSavedStr = "Floor Marker updated Successully."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureNavigationBar()
        self.emptyView.delegate = self
        self.setupViews()
        self.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.floorImageView.image == nil {
            let width = self.floorImageContainerView.frame.width
            let height = self.floorImageContainerView.frame.height
            self.floorViewWidth.constant = width
            self.floorViewHeight.constant = height
            self.floorView.frame.size = CGSize(width: width, height: height)
            self.floorImageView.layoutSkeletonIfNeeded()
        }
    }
    
    func configureNavigationBar() {
        if let node = self.siteLayoutModel, let parentNode = self.siteLayoutDataArray.first(where: { $0.id == node.parentNode }) {
            self.title = "\(parentNode.nodeName ?? ""): \(node.nodeName ?? "")"
        }
        
        let saveBtn = getPrimaryNavigationBtn(title: "Save Markers")
        saveBtn.addTarget(self, action: #selector(self.saveMarkersBtnClicked(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveBtn)
        
        self.configureNavigationBackButton()
        //let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.navCloseBtnClicked(_:)))
        //self.navigationItem.leftBarButtonItem = closeBtn
    }
    
    @objc func navCloseBtnClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveMarkersBtnClicked(_ sender: DefaultFontButton) {
        self.loadingSCLAlertView.showLoading()
        
        func startNext(index: Int) {
            if self.droppedMarkerItemArray.count > index {
                let markerItem = self.droppedMarkerItemArray[index]
                let model = MarkerModel()
                model.id = markerItem.id
                model.label = markerItem.label
                model.roomId = markerItem.roomId
                model.siteId = markerItem.siteId
                model.leftPositionDouble = markerItem.leftPositionDouble
                model.topPositionDouble = markerItem.topPositionDouble
                
                self.saveSiteMarkers(model: model) { [weak self] in
                    guard self != nil else { return }
                    startNext(index: index+1)
                }
            }else {
                self.getSaveMarker(fromReload: true)
            }
        }
        
        startNext(index: 0)
    }
    
}

//MARK: - EmptyViewDelegate
extension SaveMarkersVC: EmptyViewDelegate {
    func emptyViewDidTapView(_ view: EmptyView) {
        if self.loadingStatus.shouldReload {
            self.loadData()
        }
    }
    
    func hideLoadingAndShowError(message: String? = nil) {
        self.loadingSCLAlertView.hideView()
        let subTitle: String = message ?? "Something went wrong, Please try again!"
        SCLAlertView.showErrorAlert(title: "Error", message: subTitle, cancelButtonTitle: "OK")
    }
}

//MARK: - load data
extension SaveMarkersVC {
    
    func loadData() {
        self.getSaveMarker()
    }
    
    func getSaveMarker(fromReload: Bool = false) {
        guard let siteID = UserConstants.shared.selectedSiteID else {
            if fromReload {
                self.hideLoadingAndShowError()
            }else {
                self.loadingStatus = .failed
            }
            return
        }
        self.loadingStatus = .loading
        let apiService = ApiService.siteSaveMarkerAPI(siteId: siteID)
        APIClient.request(apiService) { [weak self] (result: Result<APIClient.MappableResult<MarkerModel>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let mappableResult):
                switch mappableResult {
                case .single:
                    if fromReload {
                        self.hideLoadingAndShowError()
                    }else {
                        self.loadingStatus = .failed
                    }
                    break
                case .array(let array):
                    self.saveMarkerItemArray = array
                    self.reloadViews()
                    if fromReload {
                        self.loadingSCLAlertView.hideView()
                        SCLAlertView().showSuccess("", subTitle: self.responseSavedStr)
                    }else {
                        self.loadingStatus = .failed
                    }
                    
                    self.loadingStatus = .default
                    break
                }
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                if fromReload {
                    self.hideLoadingAndShowError()
                }else {
                    self.loadingStatus = .failed
                }
            }
        }
    }
    
    typealias SuccessCompletion = (() -> Void)
    
    func saveSiteMarkers(model: MarkerModel, successCompletion: @escaping SuccessCompletion) {
        let apiService = ApiService.saveSiteMarkerAPI(model: model)
        APIClient.requestString(apiService) { [weak self] (result: Result<String, Error>) in
            guard let self else { return }
            switch result {
            case .success:
                successCompletion()
            case .failure(let error):
                print(apiService.api(), "Error:", error.localizedDescription)
                self.hideLoadingAndShowError()
            }
        }
    }
    
}

//MARK: - setup views
extension SaveMarkersVC {
    
    func setupViews() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func reloadViews() {
        if let item = self.siteLayoutModel {
            if let floorPlanUrl = item.floorPlanUrl, let url = URL(string: floorPlanUrl) {
                self.floorImageView.startSkeleton()
                self.floorImageView.sd_setImage(with: url) { [weak self] image, error, _, _ in
                    guard let self else { return }
                    if self.floorImageView.image != nil {
                        self.floorImageView.hideSkeleton()
                        self.setMarkers()
                    }
                }
            }else {
                self.loadingStatus = .failed
            }
        }
        
        // Filter rooms based on the selected floor's ID
        self.filteredRoomItemArray = self.siteLayoutDataArray.filter { $0.parentNode == self.siteLayoutModel?.id }
        self.collectionView.reloadData()
    }
    
    func setMarkers() {
        if let image = self.floorImageView.image {
            let maxSize = self.floorImageContainerView.frame.size
            let size = image.size
            var imageSize = maxSize
            if size.width >= size.height {
                imageSize.height = size.height * maxSize.width / size.width
                if imageSize.height > maxSize.height {
                    imageSize.height = maxSize.height
                    imageSize.width = size.width * maxSize.height / size.height
                }
            }else {
                imageSize.width = size.width * maxSize.height / size.height
                if imageSize.width > maxSize.width {
                    imageSize.width = maxSize.width
                    imageSize.height = size.height * maxSize.width / size.width
                }
            }
            self.floorViewWidth.constant = imageSize.width
            self.floorViewHeight.constant = imageSize.height
            self.floorView.frame.size = imageSize
            
            let wRatio = imageSize.width / size.width
            let hRatio = imageSize.height / size.height
            
            // set markers
            self.markerViewArray.forEach { $0.removeFromSuperview() }
            self.markerViewArray.removeAll()
            
            for markerItem in self.droppedMarkerItemArray {
                self.addMarkerViewToImage(markerItem: markerItem)
            }
        }
    }
    
    func addMarkerViewToImage(markerItem: MarkerModel) {
        if let image = self.floorImageView.image {
            let size = image.size
            let imageSize = self.floorView.frame.size
            let wRatio = imageSize.width / size.width
            let hRatio = imageSize.height / size.height
            
            if let xPos = markerItem.xPos, let yPos = markerItem.yPos {
                let newXPos = xPos * wRatio
                let newYPos = yPos * hRatio
                let defaultMarkerSize: CGFloat = 20
                let frame = CGRect(center: CGPoint(x: newXPos, y: newYPos), size: CGSize(width: defaultMarkerSize, height: defaultMarkerSize))
                
                let markerView = MarkerView(frame: frame)
                markerView.delegate = self
                markerView.setLabelText(text: markerItem.label ?? "")
                self.markerViewArray.append(markerView)
                markerView.tag = self.markerViewArray.count
                self.floorView.addSubview(markerView)
            }
        }
    }
    
    func getMarkerLabel(item: SiteLayoutModel) -> String {
        let comps = item.nodeName?.components(separatedBy: " ") ?? []
        if comps.count > 1 {
            return comps[1]
        }
        return ""
    }
    
}

extension SaveMarkersVC: MarkerViewDelegate {
    func markerViewDidTap(_ markerView: MarkerView) {
        if let droppedItem = self.droppedMarkerItemArray.first(where: { $0.label == markerView.label.text }) {
            let vc = siteAssetsSB.instantiateViewController(withIdentifier: "AssetRegisterVC") as! AssetRegisterVC
            vc.selectedMarker = droppedItem
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func markerViewDidMove(_ markerView: MarkerView) {
        if let image = self.floorImageView.image {
            let size = image.size
            let imageSize = self.floorView.frame.size
            
            let wRatio = imageSize.width / size.width
            let hRatio = imageSize.height / size.height
            
            if let droppedItem = self.droppedMarkerItemArray.first(where: { $0.label == markerView.label.text }) {
                let center = markerView.center
                droppedItem.leftPositionDouble = center.x / wRatio
                droppedItem.topPositionDouble = center.y / hRatio
            }
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension SaveMarkersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredRoomItemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarkerLabelCell", for: indexPath) as! MarkerLabelCell
        if self.filteredRoomItemArray.count > indexPath.row {
            let item = self.filteredRoomItemArray[indexPath.row]
            let label = getMarkerLabel(item: item)
            cell.isDisabled = self.droppedMarkerItemArray.contains(where: { $0.label == label })
            cell.markerLbl.text = label
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.filteredRoomItemArray.count > indexPath.row {
            let item = self.filteredRoomItemArray[indexPath.row]
            let label = getMarkerLabel(item: item)
            let isDisabled = self.droppedMarkerItemArray.contains(where: { $0.label == label })
            if !isDisabled {
                let markerItem = MarkerModel()
                markerItem.label = label
                markerItem.roomId = self.siteLayoutModel?.id
                markerItem.siteId = self.siteLayoutModel?.siteId
                markerItem.leftPositionDouble = (self.floorImageView.image?.size.width ?? 0)/2
                markerItem.topPositionDouble = (self.floorImageView.image?.size.height ?? 0)/2
                self.droppedMarkerItemArray.append(markerItem)
                addMarkerViewToImage(markerItem: markerItem)
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.filteredRoomItemArray.count > indexPath.row {
            let item = self.filteredRoomItemArray[indexPath.row]
            let label = getMarkerLabel(item: item)
            let width = getLabelSize(text: label, font: UIFont(name: .MontserratRegular, size: 15), minWidth: 10, widthAddition: 20).width
            return CGSize(width: width, height: collectionView.frame.height)
        }
        return CGSize.zero
    }
    
}

class MarkerLabelCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var markerLbl: DefaultFontLabel!
    
    var isDisabled: Bool = false {
        didSet {
            self.bgView.backgroundColor = isDisabled ? UIColor(hexString: "f0f0f0") : UIColor.white
            isUserInteractionEnabled = !isDisabled
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.backgroundColor = UIColor(hexString: "f0f0f0")
        self.bgView.addCorner(value: self.frame.height / 2)
        self.bgView.addBorder(width: 1, color: UIColor(hexString: "#808080"))
    }
}

class MarkerView: UIView, UIGestureRecognizerDelegate {
    
    let defaultMarkerSize: CGFloat = 20
    
    var mainView: UIView!
    var label: UILabel!
    
    weak var delegate: MarkerViewDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        self.frame = CGRect(x: CGFloat.zero, y: CGFloat.zero, width: defaultMarkerSize, height: defaultMarkerSize)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        mainView = UIView(frame: self.bounds)
        mainView.backgroundColor = UIColor(hexString: "#d34053")
        mainView.isOpaque = false
        self.addSubview(mainView)
        mainView.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleHeight, .flexibleBottomMargin]
        mainView.addCorner(value: mainView.frame.height / 2)
        
        label = UILabel(frame: mainView.bounds)
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: .MontserratRegular, size: 13)
        label.textColor = UIColor.white
        label.textAlignment = .center
        mainView.addSubview(label)
        label.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleHeight, .flexibleBottomMargin]
        
        addGesture()
    }
    
    func setLabelText(text: String) {
        label.text = text
        let width = getLabelSize(text: text, font: label.font, minWidth: 10, widthAddition: 10).width
        let center = self.center
        self.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: defaultMarkerSize))
        self.center = center
        mainView.frame = self.bounds
        label.frame = mainView.bounds
    }
    
    func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.delegate = self
        self.mainView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        self.mainView.addGestureRecognizer(panGesture)
        
        tapGesture.require(toFail: panGesture)
    }
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        self.delegate?.markerViewDidTap(self)
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            break
        case .ended:
            break
        default:
            let translation = recognizer.translation(in: self.superview)
            self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
            self.delegate?.markerViewDidMove(self)
            recognizer.setTranslation(.zero, in: self.superview)
        }
    }
    
}

protocol MarkerViewDelegate: AnyObject {
    func markerViewDidTap(_ markerView: MarkerView)
    func markerViewDidMove(_ markerView: MarkerView)
}

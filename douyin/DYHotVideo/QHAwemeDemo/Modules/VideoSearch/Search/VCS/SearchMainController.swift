//
//  SearchMainController.swift
//  DouCartoonDemo
//
//  Created by mac on 2019/6/3.
//  Copyright © 2019年 mac. All rights reserved.
//

import UIKit
import NicooNetwork

class SearchMainController: QHBaseViewController {
    
    private var searchView: SearchHeader = {
        guard let view = Bundle.main.loadNibNamed("SearchHeader", owner: nil, options: nil)?[0] as? SearchHeader else { return SearchHeader() }
        view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: statusBarHeight + 44)
        return view
    }()
    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: self.view.bounds, collectionViewLayout: SearchItemLayout())
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = true
        collection.backgroundColor = UIColor.clear
        collection.register(SearcHotCell.classForCoder(), forCellWithReuseIdentifier: SearcHotCell.cellId)
        collection.register(SearchSecHeadView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchSecHeadView.identifier)
        return collection
    }()
    private lazy var guessLikeApi: VideoSeriesListApi = {
        let api = VideoSeriesListApi()
        api.delegate = self
        api.paramSource = self
        return api
    }()
    
    var keyModels = [VideoCategoryModel]()
    
    var titles = [String]()
    private var historySearchs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = getHistorySearch() // 获取历史搜索
        view.addSubview(searchView)
        searchView.searchTf.delegate = self
        searchView.cancleAction = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        layouSearchView()
        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchView.searchTf.becomeFirstResponder()
    }
    
    private func setUpUI() {
        view.addSubview(collectionView)
        layouCollectionView()
    }
    
    // 数据请求
    private func loadData() {
        XSProgressHUD.showCustomAnimation(msg: nil, onView: self.view, imageNames: nil, bgColor: UIColor.clear, animated: false)
        let _ = guessLikeApi.loadData()
    }
    
    /// 存储搜索历史
    private func saveSearchHistoryItem(_ text: String?) {
        if text == nil { return }
        guard var hisList = UserDefaults.standard.array(forKey: UserDefaults.kSearchHistory) as? [String] else {
            var array = [String]()
            array.append(text!)
            UserDefaults.standard.set(array, forKey: UserDefaults.kSearchHistory)
            return
        }
        hisList.insert(text!, at: 0)
        if hisList.count > 9 {
            hisList.removeLast() // 移除最后一位
        }
        UserDefaults.standard.set(hisList, forKey: UserDefaults.kSearchHistory)
    }
    
    /// 清空搜索历史
    @objc private func deleteSearchHistory() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.kSearchHistory)
        historySearchs.removeAll()
        collectionView.reloadSections([0])
    }
    
    private func getHistorySearch() -> [String]? {
        if let hisList = UserDefaults.standard.array(forKey: UserDefaults.kSearchHistory) as? [String], hisList.count > 0 {
            historySearchs = hisList
            return hisList
        }
        return nil
    }
    
    /// - Parameter keyWord: 关键词
    private func searchWithKey(_ keyWord: String?) {
        searchView.searchTf.resignFirstResponder()
        searchView.searchTf.endEditing(true)
        // 跳转到搜索详情
        let searchRedvc = DiscoverSearchResultController()
        searchRedvc.searchkey = keyWord
        navigationController?.pushViewController(searchRedvc, animated: false)
    }
    
    func getwith(font: UIFont, height: CGFloat, string: String) -> CGSize {
        let size = CGSize.init(width: CGFloat(MAXFLOAT), height: height)
        let dic = [NSAttributedString.Key.font: font] // swift 4.2
        let strSize = string.boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: dic, context:nil).size
        return strSize
    }
}

extension SearchMainController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == nil || textField.text!.isEmpty {
            XSAlert.show(type: .error, text: "请输入搜索内容")
            return true
        }
        saveSearchHistoryItem(textField.text)
        searchWithKey(textField.text)
        return true
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchMainController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return historySearchs.count
        } else {
            return  keyModels.count > 10 ? 10 : keyModels.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearcHotCell.cellId, for: indexPath) as! SearcHotCell
        if indexPath.section == 0 {
            cell.titleLab.text = historySearchs[indexPath.item]
        } else {
            cell.titleLab.text = titles[indexPath.item]
            cell.titleLab.backgroundColor =  ConstValue.kViewLightColor
           
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.section == 0 { // 历史
            self.view.endEditing(true)
            self.searchView.searchTf.text = historySearchs[indexPath.item]
            searchWithKey(self.searchView.searchTf.text)
        } else if indexPath.section == 1 {
            self.view.endEditing(true)
            self.searchView.searchTf.text = titles[indexPath.item]
            searchWithKey(self.searchView.searchTf.text)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size: CGSize!
        if indexPath.section == 0 {
            size = self.getwith(font: UIFont.systemFont(ofSize: 13), height: 24, string: historySearchs[indexPath.item])
        } else {
            size = self.getwith(font: UIFont.systemFont(ofSize: 13), height: 24, string: titles[indexPath.item])
        }
        return CGSize(width: size.width + 30, height: 30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return historySearchs.count > 0 ? CGSize(width: UIScreen.main.bounds.width, height: 40) : CGSize.zero
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: 50)
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView:UICollectionReusableView?
        //是每组的头
        if kind == UICollectionView.elementKindSectionHeader {
            let searchReusable = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchSecHeadView.identifier, for: indexPath) as! SearchSecHeadView
            searchReusable.rightButton.setImage(UIImage(named: ["cleanASearchHis","searchLikeRefresh"][indexPath.section]), for: .normal)
            searchReusable.titleLable.text = ["历史搜索", "热门搜索"][indexPath.section]
            searchReusable.rightAction = { [weak self] in
                guard let strongSelf = self else { return }
                if indexPath.section == 0 {
                    strongSelf.deleteSearchHistory()
                } else if indexPath.section == 1 {
                    strongSelf.loadData()
                }
            }
            reusableView = searchReusable
        }
        return reusableView!
    }
    
}
// MARK: - NicooAPIManagerCallbackDelegate, NicooAPIManagerParamSourceDelegate
extension SearchMainController: NicooAPIManagerCallbackDelegate, NicooAPIManagerParamSourceDelegate {
    
    func paramsForAPI(_ manager: NicooBaseAPIManager) -> [String : Any]? {
        return [VideoSeriesListApi.kType: "SEARCH"]
    }
    
    func managerCallAPISuccess(_ manager: NicooBaseAPIManager) {
        XSProgressHUD.hide(for: view, animated: false)
        if manager is VideoSeriesListApi {
            if let modules = manager.fetchJSONData(VideoReformer()) as? CateTypeListModel {
                if let models = modules.data, models.count > 0 {
                    keyModels = models
                    var titleHot = [String]()
                    for cartom in keyModels {
                        if let titleComic = cartom.keys_title {
                            titleHot.append(titleComic)
                        } else {
                            titleHot.append("老湿")
                        }
                    }
                    titles = titleHot
                    setUpUI()
                }
            }
        }
    }
    
    func managerCallAPIFailed(_ manager: NicooBaseAPIManager) {
        XSProgressHUD.hide(for: view, animated: false)
        collectionView.reloadData()
    }
}

private extension SearchMainController {
    
    func layoutpageSubviews() {
        layouSearchView()
        layouCollectionView()
    }
    func layouSearchView() {
        searchView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(safeAreaTopHeight)
        }
    }
    
    func layouCollectionView() {
        collectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom)
            if #available(iOS 11.0, *) {
                 make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
}

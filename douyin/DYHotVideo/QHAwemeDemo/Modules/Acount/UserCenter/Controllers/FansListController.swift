//
//  FansListController.swift
//  QHAwemeDemo
//
//  Created by mac on 2019/8/31.
//  Copyright © 2019年 AnakinChen Network Technology. All rights reserved.
//  粉丝列表

import UIKit
import NicooNetwork
import MJRefresh

class FansListController: QHBaseViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.clear
        table.showsVerticalScrollIndicator = false
        table.allowsSelection = true
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.register(UINib(nibName: "AttListCell", bundle: Bundle.main), forCellReuseIdentifier: AttListCell.cellId)
        table.mj_header = refreshView
        table.mj_footer = loadMoreView
        return table
    }()
    lazy private var loadMoreView: MJRefreshAutoNormalFooter = {
        weak var weakSelf = self
        let loadmore = MJRefreshAutoNormalFooter(refreshingBlock: {
            weakSelf?.loadNextpage()
        })
        loadmore?.setTitle("", for: .idle)
        loadmore?.setTitle("已经到底了", for: .noMoreData)
        loadmore?.stateLabel.font = ConstValue.kRefreshLableFont
        return loadmore!
    }()
    
    lazy private var refreshView: MJRefreshGifHeader = {
        weak var weakSelf = self
        let mjRefreshHeader = MJRefreshGifHeader(refreshingBlock: {
            weakSelf?.firstRefresh()
        })
        var gifImages = [UIImage]()
        for string in ConstValue.refreshImageNames {
            gifImages.append(UIImage(named: string)!)
        }
        mjRefreshHeader?.setImages(gifImages, for: .refreshing)
        mjRefreshHeader?.setImages(gifImages, for: .idle)
        mjRefreshHeader?.stateLabel.font = ConstValue.kRefreshLableFont
        mjRefreshHeader?.lastUpdatedTimeLabel.font = ConstValue.kRefreshLableFont
        return mjRefreshHeader!
    }()
    
    private lazy var fansApis: UserFansListApi =  {
        let api = UserFansListApi()
        api.delegate = self
        api.paramSource = self
        return api
    }()
    
    var listModel: FollowListModel?
    var items = [FlowUsers]()
    
    var userId: Int = 0
    
    var isSelf: Bool = false
    
    private let userViewModel = UserInfoViewModel()
    
    ///取消关注和关注选择的indexPath
    var selectIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ConstValue.kVcViewColor
        view.addSubview(tableView)
        layoutPageSubviews()
        loadFollows()
        userAddFollowCallBack()
        userCancelFollowCallBack()
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        tableView.contentInset = UIEdgeInsets(top: UIDevice.current.isXSeriesDevices() ? 80 : 53, left: 0, bottom: UIDevice.current.isiPhoneXSeriesDevices() ? 83 : 46 , right: 0)
    }
    
    private func loadFollows() {
        NicooErrorView.removeErrorMeesageFrom(view)
        XSProgressHUD.showCustomAnimation(msg: nil, onView: view, imageNames: nil, bgColor: nil, animated: false)
        _ = fansApis.loadData()
    }
    
    private func firstRefresh() {
        _ = fansApis.loadData()
    }
    
    private func loadNextpage() {
        _ = fansApis.loadNextPage()
    }
    
    private func eendRefreshing() {
        tableView.mj_header.endRefreshing()
        tableView.mj_footer.endRefreshing()
    }
}

// MARK: - Privite Funs
private extension FansListController {
    
    func loadDataSuccess(_ listModel: FollowListModel) {
        eendRefreshing()
        if let datas = listModel.item {
            if fansApis.pageNumber == 1 {
                items = datas
                if items.count == 0 {
                    NicooErrorView.showErrorMessage(isSelf ? "您还没有粉丝，快去拍片吧~" : "这家伙很惨，还没有粉丝～", on: self.view, customerTopMargin: safeAreaTopHeight + 90, clickHandler: nil)
                }
            } else {
                items.append(contentsOf: datas)
            }
            loadMoreView.isHidden = datas.count < 10
            tableView.reloadData()
        }
    }
    
    ///刷新关注和取消关注状态
    func refreshFollowStatus(_ model: FollowStatu) {
        for followUser in items {
            if model.status == 1 {  //已关注
                followUser.flag = RelationShip.myFollow
            } else {  //未关注
                followUser.flag = RelationShip.notRelate
            }
        }
        tableView.reloadData()
    }
    
    ///关注和取消关注的状态
    private func userAddFollowCallBack() {
        userViewModel.followAddOrCancelSuccessHandler = { [weak self] isAdd, model in
            guard let strongSelf = self else {
                return
            }
            DLog("======\(String(describing: model?.uid))=====")
            
            if isAdd {
                for followUser in strongSelf.items {
                    if let uid = model?.uid {
                        if "\(uid)" == (followUser.uid ?? "0") {
                            if followUser.flag == RelationShip.notRelate {
                                followUser.flag = RelationShip.myFollow
                            } else if followUser.flag == RelationShip.follwMe {
                                followUser.flag = RelationShip.followEachOther
                            }
                        }
                    }
                }
            } else {
                for followUser in strongSelf.items {
                    let userId = followUser.uid ?? ""
                    if let uid = model?.uid {
                        if "\(uid)" == userId {
                            if followUser.flag == RelationShip.followEachOther {
                                followUser.flag = RelationShip.follwMe
                            } else if followUser.flag == RelationShip.follwMe {
                                followUser.flag = RelationShip.notRelate
                            } else if followUser.flag == RelationShip.myFollow {
                                followUser.flag = RelationShip.notRelate
                            }
                        }

                    }
                }
            }
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    
    private func userCancelFollowCallBack() {
        userViewModel.followOrCancelFailureHandler = { (isAdd, msg) in
            XSAlert.show(type: .error, text: msg)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FansListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AttListCell.cellId, for: indexPath) as! AttListCell
        let model = items[indexPath.row]
        cell.setModel(model)
        cell.didClickFollowHandler = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            if model.flag == RelationShip.notRelate ||  model.flag == RelationShip.follwMe { //无关系，我的粉丝
                strongSelf.userViewModel.loadAddFollowApi([UserFollowStatuApi.kUserId: model.id ?? 0, UserFollowStatuApi.kSelfId: UserModel.share().userInfo?.id ?? 0])
            } else if model.flag == RelationShip.followEachOther || model.flag == RelationShip.myFollow { //互相关注， 我关注了他
                strongSelf.userViewModel.loadCancleFollowApi([UserFollowStatuApi.kUserId: model.id ?? 0, UserFollowStatuApi.kSelfId: UserModel.share().userInfo?.id ?? 0])
            } else if model.flag == RelationShip.isMySelf { //是自己
                
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let model = items[indexPath.row]
        if model.id != UserModel.share().userInfo?.id { // 不是自己
            let userCenter = UserMCenterController()
            let user = UserInfoModel()
            user.id = model.id
            user.cover_path = model.cover_path
            user.nikename = model.nikename
            userCenter.user = user
            navigationController?.pushViewController(userCenter, animated: true)
        } else {
            let userinfoEditVC = UserInfoEditController()
            navigationController?.pushViewController(userinfoEditVC, animated: true)
        }
    }
    
}

//// MARK: - NicooAPIManagerParamSourceDelegate, NicooAPIManagerCallbackDelegate
extension FansListController: NicooAPIManagerParamSourceDelegate, NicooAPIManagerCallbackDelegate {

    func paramsForAPI(_ manager: NicooBaseAPIManager) -> [String : Any]? {
        var params = [String : Any]()
        if manager is UserFansListApi || manager is UserCancleFollowApi || manager is UserAddFollowApi {
            params[UserFansListApi.kUserId] = userId
            params[UserFansListApi.kSelfId] = UserModel.share().userInfo?.id
        }
        return params
    }

    func managerCallAPISuccess(_ manager: NicooBaseAPIManager) {
        XSProgressHUD.hide(for: view, animated: false)
        if manager is UserFansListApi {
            if let listModel = manager.fetchJSONData(UserReformer()) as? FollowListModel {
                loadDataSuccess(listModel)
            }
        }
    }

    func managerCallAPIFailed(_ manager: NicooBaseAPIManager) {
        XSProgressHUD.hide(for: view, animated: false)
        if manager is UserFansListApi {
            NicooErrorView.showErrorMessage(.noNetwork, on: view, topMargin: safeAreaTopHeight + 20) {
                self.loadFollows()
            }
        }
    }
}


// MARK: - Layout
private extension FansListController {
    
    func layoutPageSubviews() {
        layoutTableView()
    }
    
    func layoutTableView() {
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.leading.trailing.top.equalToSuperview()
        }
    }
}

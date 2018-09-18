//
//  BadgeValueSegmentHelper.swift
//  jiyunorg
//
//  Created by 万杰 on 2018/8/28.
//  Copyright © 2018年 com.banksteel. All rights reserved.
//

import UIKit
import SnapKit
private let badgeValueSegmentHelpeReuseIdentifier = "BadgeValueSegmentHelpeReuseIdentifier"
private let badgeHeight:CGFloat = 16
private let badgeTopSapce:CGFloat = 6
private let bottomLineHeight:CGFloat = 2
struct  BadgeValueSegmentHelperCellModel{
    var title:String?
    var badgeValue:String?
    var isSelected:Bool?
    
    init(title:String,badgeValue:String?,isSelected:Bool) {
        self.title = title
        self.badgeValue = badgeValue
        self.isSelected = isSelected
    }
}

class BadgeValueSegmentHelperCell: UICollectionViewCell {
    
    ///标题文字label
    var titleLabel:UILabel!
    ///BadgeLabel
    var badgeLabel:UILabel!
    //下标
    var bottomLine:UIImageView!
    ///indexRow
    var indexRow:Int?
    ///
    var grayImageView:UIImageView?
    
    
    var model:BadgeValueSegmentHelperCellModel?{
        willSet{
            if let value = newValue{
                titleLabel.text = value.title
                
                if String.isEmptyOrNil(string: value.badgeValue) || value.badgeValue == "0"{
                    badgeLabel.isHidden = true
                }else
                {
                    badgeLabel.isHidden = false
                    let numb = Int(value.badgeValue!)
                    if numb! > 99{
                        badgeLabel.text = "99+"
                    }else
                    {
                        badgeLabel.text = value.badgeValue
                    }
                }
                if value.isSelected! {
                    //                    bottomLine.isHidden = false
                    titleLabel.textColor = RGB(r: 0, g: 126, b: 228)
                }else
                {
                    //                    bottomLine.isHidden = true
                    titleLabel.textColor = RGB(r: 51, g: 51, b: 51)
                }
            }
        }
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        
        
        titleLabel.snp.remakeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        badgeLabel.snp.remakeConstraints { (maker) in
            maker.top.equalTo(badgeTopSapce)
            maker.height.equalTo(badgeHeight)
            maker.width.greaterThanOrEqualTo(23)
            //            maker.centerX.equalTo(self.snp.centerX).offset(35)
            maker.right.equalTo(-7)
        }
    }
    //MARK: - privat Method
    fileprivate func setUp(){
        self.backgroundColor = UIColor.white
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = RGB(r: 51, g: 51, b: 51)
        self.addSubview(titleLabel)
        
        badgeLabel = UILabel()
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.layer.masksToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.font = UIFont.systemFont(ofSize: 14)
        badgeLabel.backgroundColor = .red
        badgeLabel.textColor = .white
        self.addSubview(badgeLabel)
    }
    
   
}


class SegmentCollectionView: UICollectionView {

}

//extension SegmentCollectionView{
//func getAssociatedObject<T>(ofType: T.Type, key: UnsafeRawPointer,
//                                defaultValue: @autoclosure () -> T) -> T {
//
//        // or: return objc_getAssociatedObject(self, key) as? T ?? defaultValue()
//        guard let actualValue = objc_getAssociatedObject(self, key) as? T else {
//            return defaultValue()
//        }
//        return actualValue
//    }
//}
class BadgeValueSegmentHelper: UIView {
    //    var didScrollView:Bool = false//选中后是否滚动
    var countChange = 0;
    var collectionView:SegmentCollectionView?
    var scrollView:UIScrollView?
    var lineView:UIImageView?
    var imageView:UIImageView!
    ///屏幕上最多有多少item
    var visibleMaxCount:Int = 4
    ///标题数组
    var titleArray:[String]?
    ///badge数组
    var badgeArray:[String]?
    ///选择item后回调
    var valueChange:((Int)->Void)?
    
    var modelArray = [BadgeValueSegmentHelperCellModel]()
    //当前的index
    var currentIndex:Int = -1
    
    deinit {
        self.collectionView?.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public  init(withTitles titles:[String],visibleMaxCount:Int,frame: CGRect,valueChange:@escaping ((Int)->Void)) {
        super.init(frame: frame)
        self.visibleMaxCount = visibleMaxCount
        self.titleArray = titles
        self.valueChange = valueChange
        for index in 0..<titles.count{
            if index == 0{
                let model = BadgeValueSegmentHelperCellModel.init(title: titles[index], badgeValue: nil, isSelected: true)
                self.modelArray.append(model)
            }else{
                let model = BadgeValueSegmentHelperCellModel.init(title: titles[index], badgeValue: nil, isSelected: false)
                self.modelArray.append(model)
            }
        }
        setUp()
    }
    
    //MARK: - public method
    public func updateBadgeValue(withValues values:[String?]){
        for index in 0..<self.modelArray.count{
            self.modelArray[index].badgeValue = values[index]
        }
        self.collectionView?.reloadData()
        
    }
    
    public func selectedIndex(indexRow:Int){
        if indexRow == currentIndex{
            
        }else{
            //修改model
            for index in 0..<self.modelArray.count{
                if indexRow == index{
                    self.modelArray[index].isSelected = true
                }else{
                    self.modelArray[index].isSelected = false
                }
            }
            self.currentIndex = indexRow
            self.collectionView?.reloadData()
            //滚动居中
             UIView.animate(withDuration: 0.2) {
                self.collectionView?.scrollToItem(at: IndexPath.init(row: indexRow, section: 0), at: .centeredHorizontally, animated: false)
            }
            valueChange!(indexRow)
        }
    }
    //
    public func setX(x:CGFloat){
        self.lineView?.x = x
    }
  //MARK: - override method
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView?.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height-2)
        scrollView?.frame = CGRect.init(x: 0, y:  self.frame.height-2, width: self.frame.width, height: 2)
        imageView?.frame = CGRect.init(x: 0, y: 1, width: self.frame.width, height: 1)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        for index in 0..<self.modelArray.count{
            let model = modelArray[index]
            if (model.isSelected)!{
                UIView.animate(withDuration: 0.2) {
                    let x = UIApplication.shared.keyWindow?.convert((self.collectionView?.collectionViewLayout.layoutAttributesForItem(at: IndexPath.init(row: index, section: 0))?.frame)!, from: self.collectionView).origin.x
                    self.lineView?.frame.origin.x = x!
                    self.scrollView?.layoutIfNeeded()
                }
            }
        }
        
    }
    //MARK: - privatMethod
    fileprivate func setUp(){
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = SegmentCollectionView.init(frame: self.bounds, collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(BadgeValueSegmentHelperCell.classForCoder(), forCellWithReuseIdentifier: badgeValueSegmentHelpeReuseIdentifier)
        collectionView?.isPagingEnabled = true
        collectionView?.dataSource = self
        collectionView?.delegate = self
        self.addSubview(collectionView!)
        collectionView?.reloadData()
        //跟随下标
        let scrollView = UIScrollView()
        self.scrollView = scrollView
        scrollView.contentSize = CGSize.init(width: ScreenRect_Width/CGFloat(visibleMaxCount) * CGFloat(titleArray!.count), height: 1)
        scrollView.bounces = false
       
        let imageView = UIImageView()
        self.imageView = imageView
        imageView.backgroundColor = UIColor.groupTableViewBackground
        scrollView.addSubview(imageView)
        let line = UIImageView()
        line.backgroundColor = RGB(r: 0, g: 126, b: 228)
        line.frame = CGRect.init(x: 0, y: 0, width: ScreenRect_Width/CGFloat(visibleMaxCount), height: 2)
        self.lineView = line
        scrollView.addSubview(line)
        self.addSubview(scrollView)
        
        self.collectionView?.addObserver(self, forKeyPath: "contentSize", options: [.old,.new], context: nil)
        
    }
    fileprivate func selfHeight()->CGFloat{
        return self.bounds.size.height - 2
    }
}
//MARK: - UICollectionViewDelegate UICollectionViewDataSource
extension BadgeValueSegmentHelper:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemW = ScreenRect_Width/CGFloat(visibleMaxCount)
        let itemH = selfHeight()
        return CGSize.init(width: itemW, height: itemH)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (titleArray?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeValueSegmentHelpeReuseIdentifier, for: indexPath) as! BadgeValueSegmentHelperCell
        if self.titleArray == nil{
            return UICollectionViewCell()
        }
        guard (self.titleArray?.count)!>0 else {
            return UICollectionViewCell()
        }
        
        cell.model = self.modelArray[indexPath.row]
        
        cell.indexRow = indexPath.row
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == currentIndex{
            
        }else{
            //修改model
            for index in 0..<self.modelArray.count{
                if index == indexPath.row{
                    self.modelArray[index].isSelected = true
                }else{
                    self.modelArray[index].isSelected = false
                }
            }
            self.currentIndex = indexPath.row
            self.collectionView?.reloadData()
            //滚动居中
            UIView.animate(withDuration: 0.2) {
                self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }
        
            valueChange!(indexPath.row)
        }
        
    }

    
}

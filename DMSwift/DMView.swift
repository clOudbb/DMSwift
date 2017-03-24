//
//  DMView.swift
//  DanmuSwift
//
//  Created by 袁祎凯 on 16/10/14.
//  Copyright © 2016年 paladin. All rights reserved.
//

import UIKit

protocol DMViewDataSource {
    func DMViewWith(dmView : DMView, index : Int) -> DMCell;
    ///轨道数
    func DMViewWith(numberOfDmView dmView : DMView) -> Int;
}

class DMView: UIView {
    /// cell重用池
    fileprivate var reusingCellPoll : [DMCell] = [];
    /// DataSource协议
    public var dataSource : DMViewDataSource?
    /// 数据源
    fileprivate var dataArray : [DMModel] = [];
    // 轨道数
    fileprivate var number : Int?
    // 正在展示的cell
    fileprivate var currentCells : NSMutableArray = [];
    // 普通类型弹幕数据
    fileprivate var normalSource : NSMutableArray = [];
    fileprivate var topSource : NSMutableArray = [];
    fileprivate var bottomSource : NSMutableArray = [];
    
    private let cellHeight = 20;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// 发送弹幕
    ///
    /// - parameter array:  数据源
    /// - parameter isShow: 是否立即显示
    public func sendDM(array : [DMModel], isShow : Bool) -> Void {
        self.dataArray = array;
        if  isShow {
            for model  in self.dataArray {
                let dmCell : DMCell = (self.dataSource?.DMViewWith(dmView: self, index: (self.dataArray.index(of: model))!))!;
                self.number = self.dataSource?.DMViewWith(numberOfDmView: self);
                /* 如果包含从重用池中移除 */
                if self.reusingCellPoll.contains(dmCell) {
                    self.reusingCellPoll.remove(at: self.reusingCellPoll.index(of: dmCell)!);
                }
                let animationDuration : TimeInterval = dmCell.calculateAnimationDuration(width: self.frame.size.width, cellWidth:model.cellWidth());
                let row : Int = dmCell.checkOutAvailablyCell(number: self.number!, currentShowCells:self.currentCells);
                
                self.classifyWith(model: model, dmCell: dmCell);
                dmCell.frame = self.calculateCellFrame(row: row, cellWidth: model.cellWidth());
                if !self.subviews.contains(dmCell) {
                    self.addSubview(dmCell);
                }
                dmCell.startAnimation(duration: animationDuration, ready: {
                    currentCells.add(dmCell);
                }, completion: {
                    self.reusingCellPoll.append(dmCell);   /* 加入重用池 */
                    self.currentCells.remove(dmCell);
                    dmCell.removeFromSuperview();
                });
            }
            //            self.dataArray?.removeAll();
        }
    }
    
     /*
       * 这里很大的坑，目前不知如何解决，主要需要继承DMCell的CustomCell去接收一个父类对象，但由于Swift的类型检查导致无法实现
       */
    ///注册重用池
    public func registerDmCellPoll(_ cellClass : DMCell, identifier : String) -> Void {
        self.number = self.dataSource?.DMViewWith(numberOfDmView: self);
        for _ in 0..<self.number! {
            self.reusingCellPoll.append(cellClass);
        }
    }
   
    /// 从重用池中取回cell
    public func dequeueReusableCell(identifier : String) -> DMCell? {
        guard self.reusingCellPoll.count > 0 else {
            return nil;
        }
        for cell  in self.reusingCellPoll {
            if cell.DMCellIdentifier .isEqual(identifier){
                return cell;
            }
        }
        return nil;
    }
    
    //检测可用轨道
    fileprivate func checkAvailablyCell(currentCell : DMCell) -> Int {
        return currentCell.checkOutAvailablyCell(number: self.number!, currentShowCells: self.currentCells);
    }
    
    //将数据分类
    fileprivate func classifyWith(model : DMModel , dmCell : DMCell) -> Void {
        //设定dmcell类型
        dmCell.cellType = model.cellType;
        if model.cellType == DMCellType.DMCellNormal{
            self.normalSource.add(model);
        } else if model.cellType == DMCellType.DMCellTop{
            self.topSource.add(model);
        } else if model.cellType == DMCellType.DMCellBottom{
            self.bottomSource.add(model);
        }
    }
    
    //计算cell初始位置
    fileprivate func calculateCellFrame(row : Int, cellWidth : CGFloat) -> CGRect {
        if  row >= 0 {
            return CGRect.init(x: self.frame.size.width, y: CGFloat(Int(self.frame.size.height) / self.number! * row), width: cellWidth, height: CGFloat(cellHeight))
        } else {
            return CGRect.init(x: self.frame.size.width, y: 0, width: cellWidth, height: CGFloat(cellHeight))
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

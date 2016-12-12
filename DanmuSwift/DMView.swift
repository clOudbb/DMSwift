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

class DMView: UIView{
    /// cell重用池
    var reusingCellPoll : [DMCell]?
    /// DataSource协议
    var dataSource : DMViewDataSource?
    /// 数据源
    var dataArray : [DMModel] = [];
    // 轨道数
    var number : Int?
    // 正在展示的cell
    var currentCells : NSMutableArray = [];
    // 普通类型弹幕数据
    var normalSource : NSMutableArray = [];
    var topSource : NSMutableArray = [];
    var bottomSource : NSMutableArray = [];
    
    let cellHeight = 20;
    
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
    func sendDM(array : [DMModel], isShow : Bool) -> Void {
        self.dataArray = array;
        self.number = self.dataSource?.DMViewWith(numberOfDmView: self);
        if  isShow {
            for model  in self.dataArray {
                let dmCell : DMCell = (self.dataSource?.DMViewWith(dmView: self, index: (self.dataArray.index(of: model))!))!;
                let animationDuration : TimeInterval = dmCell.calculateAnimationDuration(width: self.frame.size.width, cellWidth:model.cellWidth());
                let row : Int = dmCell.checkOutAvailablyCell(number: self.number!, currentShowCells:self.currentCells);
                
                self.classifyWith(model: model);
                dmCell.frame = self.calculateCellFrame(row: row, cellWidth: model.cellWidth());
                if !self.subviews.contains(dmCell) {
                    self.addSubview(dmCell);
                }
                dmCell.startAnimation(duration: animationDuration, ready: {
                    currentCells.add(dmCell);
                }, completion: {
                    self.currentCells.remove(dmCell);
                });
            }
            //            self.dataArray?.removeAll();
        }
    }
    
    /// 从重用池中取回cell
    func dequeueReusableCell(identifier : String) -> DMCell {
        let aCell : DMCell = DMCell();
        for aCell in self.reusingCellPoll! {
            if aCell.DMCellIdentifier .isEqual(to: identifier){
                return aCell;
            }
        }
        return aCell;
    }
    //检测可用轨道
    func checkAvailablyCell(currentCell : DMCell) -> Int {
        return currentCell.checkOutAvailablyCell(number: self.number!, currentShowCells: self.currentCells);
    }
    
    //将数据分类
    func classifyWith(model : DMModel) -> Void {
        if model.configuration.cellType == DMCellType.DMCellNormal{
            self.normalSource.add(model);
        } else if model.configuration.cellType == DMCellType.DMCellTop{
            self.topSource.add(model);
        } else if model.configuration.cellType == DMCellType.DMCellBottom{
            self.bottomSource.add(model);
        }
    }
    
    //计算cell初始位置
    func calculateCellFrame(row : Int, cellWidth : CGFloat) -> CGRect {
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

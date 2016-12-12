//
//  DMCell.swift
//  DanmuSwift
//
//  Created by 袁祎凯 on 16/10/14.
//  Copyright © 2016年 paladin. All rights reserved.
//

import UIKit

class DMCell: UIView, CAAnimationDelegate{
    public let DMCellIdentifier : NSString = "DMCellIdentifierWithLeft";
    public var startTime : NSDate?   // 弹幕开始时间
    public var stopTime : NSDate?
    public var row : Int?    //弹幕所在轨道
    public var duration : TimeInterval?
    public var cellWidth : CGFloat?
    public var speed : CGFloat = 100;
    // 弹幕文字
    public var content : NSString? {
        willSet
        {
            print(newValue as Any);
            self.label.text = newValue as String!;
        }
        didSet
        {
            print(oldValue as Any);
        }
    }
    
    lazy var label : UILabel =
        {
            let label : UILabel = UILabel.init();
            label.font = UIFont.systemFont(ofSize: 12);
            label.textColor = UIColor.white;
            return label;
    }();
    
    lazy var imgView : UIImageView =
        {
            let imgView : UIImageView = UIImageView.init();
            imgView.layer.masksToBounds = true;
            imgView.layer.cornerRadius = 10;
            return imgView;
    }();
    
    var model : DMModel? {
        willSet{
            self.imgView.image = UIImage.init(named: "kiminonamai.jpg");
            self.label.text = newValue?.content;
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.blue;
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = 10;
        
        self.addSubview(self.imgView);
        self.imgView.snp.makeConstraints { (make) in
            make.left.equalTo(5);
            make.centerY.equalToSuperview();
            make.size.equalTo(CGSize.init(width: 20, height: 20));
        }
        
        self.addSubview(self.label);
        self.label.snp.makeConstraints { (make) in
            make.left.equalTo(self.imgView.snp.right).offset(10);
            make.top.bottom.right.equalTo(0);
        }
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var completion : () -> Void = {
        () in
        return;
    }
    /// 使用CABasic动画中keyPath不同会所计算的坐标不同 改用UIView动画
    /// position是控件中心点坐标，计算时需计算控件本身二分之一
    ///
    /// - Parameters:
    ///   - duration: 动画时间
    ///   - ready: 动画开始闭包
    ///   - completion: 动画完成逃逸闭包
    func startAnimation(duration : TimeInterval, ready : () -> Void, completion : @escaping () -> Void){
        ready();
        self.startTime = NSDate.init(timeIntervalSinceNow: 0);
        self.duration = duration;
        
        let animation : CABasicAnimation = CABasicAnimation.init();
        animation.keyPath = "transform.translation.x";
        animation.toValue = NSValue.init(cgPoint: CGPoint.init(x: -(self.frame.origin.x + self.frame.size.width), y: self.frame.size.height));
        animation.duration = duration;
        animation.delegate = self;
        animation.isRemovedOnCompletion = true;
        self.layer.add(animation, forKey: nil);
        self.completion = completion;

//                UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
//                    self.frame = CGRect.init(x: toPoint.x, y: toPoint.y, width: self.frame.size.width, height: self.frame.size.height);
//                    }) { (true) in
//                }
    }
    //检出一个轨道判断
    func checkOutAvailablyCell(number : Int, currentShowCells : NSMutableArray) -> Int {
        let availableArray : NSMutableArray = NSMutableArray.init();   //可用轨道
        let freeArray : NSMutableArray = NSMutableArray.init();           // 空闲轨道
        currentShowCells.sort(usingComparator: { (first, second) -> ComparisonResult in
            let f = first as! DMCell;
            let s = second as! DMCell;
            return (f.startTime?.compare(s.startTime as! Date))!;
        });
        NSLog("当前屏幕有%d个弹幕", currentShowCells.count);
        for row in 0..<number{
            if currentShowCells.count == 0 {
                freeArray.add(row);
            } else {
                //flag表示当前轨道是否有弹幕
                var flag : Bool = false;
                let count = currentShowCells.count;
                
                if count > 0 {
//                    for var index in (0..<count).reversed() {
                    for index in 0..<count {
                        let cell : DMCell = currentShowCells[index] as! DMCell;
                        if cell.row == row {
                            //检测是否碰撞(有问题)
                            flag = true;
                            if self.checkColide(cell: cell) == false {
                                if !availableArray.contains(row) {
                                    availableArray.add(row);
                                }
                                NSLog("%d有弹幕未碰撞", row);
                            } else {
                                // 如果弹幕碰撞，若原来包含当前row，移除掉
                                if availableArray.contains(row) {
                                    availableArray.remove(row);
                                } else if freeArray.contains(row) {
                                    freeArray.remove(row);
                                }
                                NSLog("%d有弹幕碰撞", row);
                            }
                        }
                    }
                }
                if !flag {
                    if !freeArray.contains(row) {
                        freeArray.add(row);
                    }
                    NSLog("%d未碰撞   空闲轨道 = %@", row,freeArray);
                }
            }
        }
        NSLog("空闲轨道 = %d", freeArray.count);
        NSLog("有弹幕可用轨道 = %d, %@", availableArray.count, availableArray);
        if availableArray.count == 0 && freeArray.count == 0 {
            let freeRow : UInt32 = arc4random() % UInt32(number);
            self.row = Int(freeRow);
        } else {
            //优先从上面开始显示
            if freeArray.count > 0 && availableArray.count == 0{
                let num : Int = freeArray.firstObject as! Int;
                self.row = num;
            } else if  freeArray.count > 0 && availableArray.count > 0 {
                let availableRow : Int = availableArray.firstObject as! Int;
                let freeRow : Int = freeArray.firstObject as! Int;
                if availableRow <= freeRow {
                    self.row = availableRow;
                } else {
                    let num : Int = freeArray.firstObject as! Int;
                    self.row = num;
                }
            } else {
                //轨道都有弹幕则随机取
                let freeRow : UInt32 = arc4random() % UInt32(availableArray.count);
                let num : Int = availableArray[Int(freeRow)] as! Int;
                self.row = num;
            }
        }
        NSLog("轨道 = %d", self.row as Int!);
        freeArray.removeAllObjects();
        availableArray.removeAllObjects();
        return self.row!;
    }
    
//    func compare(firstD : NSDate, secondD : NSDate) -> ComparisonResult {
//        return firstD.compare(secondD as Date);
//    }
    
    ///检测是否碰撞 (目前检测碰撞 或者 计算动画时间 有问题 导致轨道检测不准确)
    func checkColide(cell : DMCell) -> Bool {
        let t : TimeInterval = self.duration! - (TimeInterval)(self.cellWidth! / self.speed);
        var now : NSDate = NSDate.init(timeIntervalSinceNow: 0);
        if self.stopTime != nil {
            now = self.stopTime!;
        }
        let nowDate : TimeInterval = now.timeIntervalSince1970 + t;
        let sDate : TimeInterval = (cell.startTime?.timeIntervalSince1970)! + cell.duration!;
        NSLog("比对Cell时间 = %f", sDate);
        NSLog("当前Cell时间 = %f", nowDate);
        if sDate < nowDate {
            return false;
        } else {
            return true;
        }
    }
    /// 计算动画时间
    func calculateAnimationDuration(width : CGFloat, cellWidth : CGFloat) -> TimeInterval {
        self.cellWidth = cellWidth;
        self.duration = (TimeInterval)((cellWidth + width) / self.speed);
        return self.duration!;
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.completion();
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

//
//  CustomCell.swift
//  DanmuSwift
//
//  Created by 袁祎凯 on 2016/12/12.
//  Copyright © 2016年 paladin. All rights reserved.
//

import UIKit

class CustomCell: DMCell {
    
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
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

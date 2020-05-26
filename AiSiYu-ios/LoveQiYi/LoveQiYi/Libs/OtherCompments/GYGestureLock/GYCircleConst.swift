//
//  GYCircleConst.swift
//  GYGestureUnlock
//
//  Created by zhuguangyang on 16/8/19.
//  Copyright © 2016年 Giant. All rights reserved.
//

import UIKit


let kScreenW = UIScreen.main.bounds.size.width

let kScreenH = UIScreen.main.bounds.size.height

/// 单个圆的背景色
let CircleBackgroundColor = UIColor.clear

/// 解锁背景色
let CircleViewBackgroundColor = UIColor.colorWithRgba(52, g: 52, b: 52, a: 0.8)

/// 普通状态下外空心颜色
let CircleStateNormalOutsideColor = UIColor.colorWithRgba(241, g: 241, b: 241, a: 1)

/// 选中状态下外空心圆颜色
let CircleStateSelectedOutsideColor = UIColor.colorWithRgba(11, g: 190, b: 6, a: 0.8)

/// 错误状态下外空心圆颜色
let CircleStateErrorOutsideColor = UIColor.colorWithRgba(254, g: 82, b: 92, a: 1)

/// 普通状态下内实心圆颜色
let CircleStateNormalInsideColor = UIColor.clear

/// 选中状态下内实心圆颜色
let CircleStateSelectedInsideColor = UIColor.colorWithRgba(11, g: 190, b: 6, a: 0.8)

/// 错误状态内实心圆颜色
let CircleStateErrorInsideColor = UIColor.colorWithRgba(254, g: 82, b: 92, a: 1)

/// 普通状态下三角形颜色
let CircleStateNormalTrangleColor = UIColor.clear

/// 选中状态下三角形颜色
let CircleStateSelectedTrangleColor = UIColor.colorWithRgba(11, g: 190, b: 6, a: 0.8)

/// 错误状态三角形颜色
let CircleStateErrorTrangleColor = UIColor.colorWithRgba(254, g: 82, b: 92, a: 1)

/// 三角形边长
let kTrangleLength:CGFloat = 10.0

/// 普通时连线颜色
let CircleConnectLineNormalColor = UIColor.colorWithRgba(11, g: 190, b: 6, a: 0.8)

/// 错误时连线颜色
let CircleConnectLineErrorColor = UIColor.colorWithRgba(254, g: 82, b: 92, a: 1)

/// 连线宽度
let CircleConnectLineWidth:CGFloat = 1.0

/// 单个圆的半径
let CircleRadius:CGFloat = 30.0

/// 单个圆的圆心
let CircleCenter = CGPoint(x: CircleRadius, y: CircleRadius)

/// 空心圆圆环宽度
let CircleEdgeWidth:CGFloat = 1.0

/// 九宫格展示infoView 单个圆的半径
let CircleInfoRadius:CGFloat = 5.0

/// 内部实心圆占空心圆的比例系数
let CircleRadio:CGFloat = 0.4

/// 整个解锁View居中时，距离屏幕左边和右边的距离
let CircleViewEdgeMargin:CGFloat = 30.0

/// 整个解锁View的Center.y值 在当前屏幕的3/5位置
let CircleViewCenterY = kScreenH * 1/2

/// 连接的圆最少的个数
let CircleSetCountLeast = 4

/// 错误状态下回显的时间
let kdisplayTime:CGFloat = 1.0

/// 最终的手势密码存储key
let gestureFinalSaveKey = "gestureFinalSaveKey"

/// 第一个手势密码存储key
let gestureOneSaveKey = "gestureOneSaveKey"

/// 普通状态下文字提示的颜色
let textColorNormalState = UIColor.colorWithRgba(241, g: 241, b: 241, a: 1)

/// 警告状态下文字提示的颜色
let textColorWarningState = UIColor.colorWithRgba(254, g: 82, b: 92, a: 1)

/// 绘制解锁界面准备好时，提示文字
let gestureTextBeforeSet = "绘制解锁图案"

/// 设置时，连线个数少，提示文字
let gestureTextConnectLess = NSString(format: "最少连接%@点,请重新输入",CircleSetCountLeast)

/// 确认图案，提示再次绘制
let gestureTextDrawAgain = "再次绘制解锁图案"

/// 再次绘制不一致，提示文字
let gestureTextDrawAgainError = "与上次绘制不一致，请重新绘制"

/// 设置成功
let gestureTextSetSuccess = "设置成功"

/// 请输入原手势密码
let gestureTextOldGesture = "请输入原手势密码"

/// 密码错误
let gestureTextGestureVerifyError = "密码错误"




class GYCircleConst: NSObject {
    /**
     偏好设置:存字符串(手势密码)
     
     - parameter gesture: 字符串对象
     - parameter key:     存储key
     */
    
    static func saveGesture(_ gesture: String?,key: String) {
        UserDefaults.standard.set(gesture, forKey: key)
        UserDefaults.standard.synchronize()
        
    }
    
    /**
     取字符串手势密码
     
     - parameter key: 字符串对象
     */
    static func getGestureWithKey(_ key: String) -> String?{
        
        return UserDefaults.standard.object(forKey: key) as? String ?? nil
    }
    
    
    
}

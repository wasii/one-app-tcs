//
//  CustomPieChartRenderer.swift
//  tcs_one_app
//
//  Created by TCS on 06/10/2021.
//  Copyright © 2021 Personal. All rights reserved.
//

import Foundation
import Charts
import CoreMedia
import CoreMIDI

class CustomPieChartRenderer: PieChartRenderer {
    let pieChartView: PieChartView
    let circleRadius: CGFloat
    
    init(pieChartView: PieChartView, radius: CGFloat) {
        self.pieChartView = pieChartView
        self.circleRadius = radius
        
        super.init(chart: pieChartView, animator: pieChartView.chartAnimator, viewPortHandler: pieChartView.viewPortHandler)
    }
    
    override func drawValues(context: CGContext) {
        guard
            let chart = chart,
            let data = chart.data
            else { return }

        let center = chart.centerCircleBox

        // get whole the radius
        let radius = chart.radius
        let rotationAngle = chart.rotationAngle
        let drawAngles = chart.drawAngles
        let absoluteAngles = chart.absoluteAngles

        let phaseX = animator.phaseX
        let phaseY = animator.phaseY

        var labelRadiusOffset = radius / 10.0 * 3.0

        if chart.drawHoleEnabled
        {
            labelRadiusOffset = (radius - (radius * chart.holeRadiusPercent)) / 2.0
        }

        let labelRadius = radius - labelRadiusOffset

        let dataSets = data.dataSets

        let yValueSum = (data as! PieChartData).yValueSum

        let drawEntryLabels = chart.isDrawEntryLabelsEnabled
        let usePercentValuesEnabled = chart.usePercentValuesEnabled

        var angle: CGFloat = 0.0
        var xIndex = 0

        context.saveGState()
        defer { context.restoreGState() }

        for i in 0 ..< dataSets.count
        {
            guard let dataSet = dataSets[i] as? IPieChartDataSet else { continue }

            let drawValues = dataSet.isDrawValuesEnabled

            if !drawValues && !drawEntryLabels && !dataSet.isDrawIconsEnabled
            {
                continue
            }

            let iconsOffset = dataSet.iconsOffset

            let xValuePosition = dataSet.xValuePosition
            let yValuePosition = dataSet.yValuePosition

            let valueFont = dataSet.valueFont
            let entryLabelFont = dataSet.entryLabelFont ?? chart.entryLabelFont
            let lineHeight = valueFont.lineHeight

            guard let formatter = dataSet.valueFormatter else { continue }

            for j in 0 ..< dataSet.entryCount
            {
                guard let e = dataSet.entryForIndex(j) else { continue }
                let pe = e as? PieChartDataEntry

                if xIndex == 0
                {
                    angle = 0.0
                }
                else
                {
                    angle = absoluteAngles[xIndex - 1] * CGFloat(phaseX)
                }

                let sliceAngle = drawAngles[xIndex]
                let sliceSpace = getSliceSpace(dataSet: dataSet)
                let sliceSpaceMiddleAngle = sliceSpace / labelRadius.DEG2RAD

                // offset needed to center the drawn text in the slice
                let angleOffset = (sliceAngle - sliceSpaceMiddleAngle / 2.0) / 2.0

                angle = angle + angleOffset

                let transformedAngle = rotationAngle + angle * CGFloat(phaseY)

                let value = usePercentValuesEnabled ? e.y / yValueSum * 100.0 : e.y
                let valueText = formatter.stringForValue(
                    value,
                    entry: e,
                    dataSetIndex: i,
                    viewPortHandler: viewPortHandler)

                let sliceXBase = cos(transformedAngle.DEG2RAD)
                let sliceYBase = sin(transformedAngle.DEG2RAD)

                let drawXOutside = drawEntryLabels && xValuePosition == .outsideSlice
                let drawYOutside = drawValues && yValuePosition == .outsideSlice
                let drawXInside = drawEntryLabels && xValuePosition == .insideSlice
                let drawYInside = drawValues && yValuePosition == .insideSlice

                let valueTextColor = dataSet.valueTextColorAt(j)
                var valueTextColorPercentage = dataSet.valueTextColorAt(j)
                let entryLabelColor = dataSet.entryLabelColor ?? chart.entryLabelColor

                // This is working with when property set to outside slice. We need to make this customize
                if drawXOutside || drawYOutside
                {
                    let valueLineLength1 = dataSet.valueLinePart1Length
                    let valueLineLength2 = dataSet.valueLinePart2Length
                    let valueLinePart1OffsetPercentage = dataSet.valueLinePart1OffsetPercentage

                    var pt2: CGPoint
                    var labelPoint: CGPoint
                    var align: NSTextAlignment

                    var line1Radius: CGFloat

                    if chart.drawHoleEnabled
                    {
                        line1Radius = (radius - (radius * chart.holeRadiusPercent)) * valueLinePart1OffsetPercentage + (radius * chart.holeRadiusPercent)
                    }
                    else
                    {
                        line1Radius = radius * valueLinePart1OffsetPercentage
                    }

                    let polyline2Length = dataSet.valueLineVariableLength
                        ? labelRadius * valueLineLength2 * abs(sin(transformedAngle.DEG2RAD))
                        : labelRadius * valueLineLength2

                    let pt0 = CGPoint(
                        x: line1Radius * sliceXBase + center.x,
                        y: line1Radius * sliceYBase + center.y)

                    let pt1 = CGPoint(
                        x: labelRadius * (1 + valueLineLength1) * sliceXBase + center.x,
                        y: labelRadius * (1 + valueLineLength1) * sliceYBase + center.y)
                    
                    var pt2xBandage = CGFloat(0)

                    if transformedAngle.truncatingRemainder(dividingBy: 360.0) >= 90.0 && transformedAngle.truncatingRemainder(dividingBy: 360.0) <= 270.0
                    {
                        pt2 = CGPoint(x: pt1.x - polyline2Length, y: pt1.y)
                        align = .right
                        labelPoint = CGPoint(x: pt2.x - 5, y: pt2.y - lineHeight)
                        pt2xBandage = pt2.x - (circleRadius * 4) //adding space between circle and lebels
                    }
                    else
                    {
                        pt2 = CGPoint(x: pt1.x + polyline2Length, y: pt1.y)
                        align = .left
                        labelPoint = CGPoint(x: pt2.x + 5, y: pt2.y - lineHeight)
                        pt2xBandage = pt2.x + (circleRadius * 4) //adding space between circle and lebels
                    }

                    DrawLine: do
                    {
                        if dataSet.useValueColorForLine
                        {
                            context.setStrokeColor(dataSet.color(atIndex: j).cgColor)
                            valueTextColorPercentage = UIColor(cgColor: dataSet.color(atIndex: j).cgColor)
                        }
                        else if let valueLineColor = dataSet.valueLineColor
                        {
                            context.setStrokeColor(valueLineColor.cgColor)
                        }
                        else
                        {
                            return
                        }
                        
                        //Don't move it below add lines. It will stop displaying circles.
                        context.setLineWidth(circleRadius * 2)
                        context.addArc(center: CGPoint(x: pt2.x, y: pt2.y), radius: circleRadius, startAngle: 0, endAngle: 2.0*CGFloat.pi, clockwise: false)
                        context.strokePath()
                    
                        
                        context.setLineWidth(dataSet.valueLineWidth)

                        context.move(to: CGPoint(x: pt0.x, y: pt0.y))
                        context.addLine(to: CGPoint(x: pt1.x, y: pt1.y))
                        context.addLine(to: CGPoint(x: pt2.x, y: pt2.y))

                        context.drawPath(using: CGPathDrawingMode.stroke)
                        
                    }
                    
                    //Customize work for drawing Labels
                    
                    if pe?.label != nil {
                        if let splitLabel = pe?.label?.split(separator: "*") {
                            
                            if splitLabel.count > 0 {
                                var xAxis = pt2xBandage
                                var yAxis = pt2.y

                                for index in 0 ..< splitLabel.count {
                                    switch(index) {
                                        /*
                                        * NOTE: pt2y is almost parallel to circle but not exactly parallel.
                                        * Also, i have add and subtract few numbers to give space between heading.
                                        * If you want to give space below pt2y then add otherwise subtract it.
                                        * */
                                    case 0: //it's printing percentage with color value
                                        yAxis = CGFloat(Int(pt2.y) + Int(lineHeight))
                                        ChartUtils.drawText(
                                            context: context,
                                            text: String(splitLabel[index]),
                                            point: CGPoint(x: xAxis, y: yAxis),
                                            align: align,
                                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColorPercentage]
                                        )
                                        break
                                        
                                    case 1: //it's printing shipments numbers/value
                                        yAxis = CGFloat(Int(pt2.y))
                                        ChartUtils.drawText(
                                            context: context,
                                            text: String(splitLabel[index]),
                                            point: CGPoint(x: xAxis, y: yAxis),
                                            align: align,
                                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
                                        )
                                        break
                                        
                                    case 2: //it's printing shipments heading
                                        yAxis = CGFloat(Int(pt2.y) - Int(lineHeight))
                                        ChartUtils.drawText(
                                            context: context,
                                            text: String(splitLabel[index]),
                                            point: CGPoint(x: xAxis, y: yAxis),
                                            align: align,
                                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
                                        )
                                        break
                                        
                                    case 3: //it's printing status (After KPI , With KPI etc)
                                        yAxis = CGFloat(Int(pt2.y) - Int(lineHeight) - Int(lineHeight))
                                        ChartUtils.drawText(
                                            context: context,
                                            text: String(splitLabel[index]),
                                            point: CGPoint(x: xAxis, y: yAxis),
                                            align: align,
                                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
                                        )
                                        break
                                        
                                    default: break //Do nothing

                                    }
                                }
                                
                            } else {
                                ChartUtils.drawText(
                                    context: context,
                                    text: valueText,
                                    point: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight / 2.0),
                                    align: align,
                                    attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
                                )
                            }
                        } else {
                            ChartUtils.drawText(
                                context: context,
                                text: valueText,
                                point: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight / 2.0),
                                align: align,
                                attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
                            )
                        }
                    } else {
                        ChartUtils.drawText(
                            context: context,
                            text: valueText,
                            point: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight / 2.0),
                            align: align,
                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
                        )
                    }
                    
//                    if drawXOutside && drawYOutside
//                    {
//                        ChartUtils.drawText(
//                            context: context,
//                            text: valueText,
//                            point: labelPoint,
//                            align: align,
//                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
//                        )
//
//                        if j < data.entryCount && pe?.label != nil
//                        {
//                            ChartUtils.drawText(
//                                context: context,
//                                text: pe!.label!,
//                                point: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight),
//                                align: align,
//                                attributes: [
//                                    NSAttributedString.Key.font: entryLabelFont ?? valueFont,
//                                    NSAttributedString.Key.foregroundColor: entryLabelColor ?? valueTextColor]
//                            )
//                        }
//                    }
//                    else if drawXOutside
//                    {
//                        if j < data.entryCount && pe?.label != nil
//                        {
//                            ChartUtils.drawText(
//                                context: context,
//                                text: pe!.label!,
//                                point: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight / 2.0),
//                                align: align,
//                                attributes: [
//                                    NSAttributedString.Key.font: entryLabelFont ?? valueFont,
//                                    NSAttributedString.Key.foregroundColor: entryLabelColor ?? valueTextColor]
//                            )
//                        }
//                    }
//                    else if drawYOutside
//                    {
//                        ChartUtils.drawText(
//                            context: context,
//                            text: valueText,
//                            point: CGPoint(x: labelPoint.x, y: labelPoint.y + lineHeight / 2.0),
//                            align: align,
//                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
//                        )
//                    }
                }

                //No need to customize it.
                if drawXInside || drawYInside
                {
                    // calculate the text position
                    let x = labelRadius * sliceXBase + center.x
                    let y = labelRadius * sliceYBase + center.y - lineHeight

                    if drawXInside && drawYInside
                    {
                        ChartUtils.drawText(
                            context: context,
                            text: valueText,
                            point: CGPoint(x: x, y: y),
                            align: .center,
                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
                        )

                        if j < data.entryCount && pe?.label != nil
                        {
                            ChartUtils.drawText(
                                context: context,
                                text: pe!.label!,
                                point: CGPoint(x: x, y: y + lineHeight),
                                align: .center,
                                attributes: [
                                    NSAttributedString.Key.font: entryLabelFont ?? valueFont,
                                    NSAttributedString.Key.foregroundColor: entryLabelColor ?? valueTextColor]
                            )
                        }
                    }
                    else if drawXInside
                    {
                        if j < data.entryCount && pe?.label != nil
                        {
                            ChartUtils.drawText(
                                context: context,
                                text: pe!.label!,
                                point: CGPoint(x: x, y: y + lineHeight / 2.0),
                                align: .center,
                                attributes: [
                                    NSAttributedString.Key.font: entryLabelFont ?? valueFont,
                                    NSAttributedString.Key.foregroundColor: entryLabelColor ?? valueTextColor]
                            )
                        }
                    }
                    else if drawYInside
                    {
                        ChartUtils.drawText(
                            context: context,
                            text: valueText,
                            point: CGPoint(x: x, y: y + lineHeight / 2.0),
                            align: .center,
                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueTextColor]
                        )
                    }
                }

                if let icon = e.icon, dataSet.isDrawIconsEnabled
                {
                    // calculate the icon's position

                    let x = (labelRadius + iconsOffset.y) * sliceXBase + center.x
                    var y = (labelRadius + iconsOffset.y) * sliceYBase + center.y
                    y += iconsOffset.x

                    ChartUtils.drawImage(context: context,
                                         image: icon,
                                         x: x,
                                         y: y,
                                         size: icon.size)
                }

                xIndex += 1
            }
        }
    }
}

extension FloatingPoint
{
    var DEG2RAD: Self
    {
        return self * .pi / 180
    }

    var RAD2DEG: Self
    {
        return self * 180 / .pi
    }

    /// - Note: Value must be in degrees
    /// - Returns: An angle between 0.0 < 360.0 (not less than zero, less than 360)
    var normalizedAngle: Self
    {
        let angle = truncatingRemainder(dividingBy: 360)
        return (sign == .minus) ? angle + 360 : angle
    }
}

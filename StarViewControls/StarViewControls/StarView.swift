import Foundation
import UIKit

@IBDesignable
public class StarView : UIView
{
	@IBInspectable public var numOfPoints: Int = 5
	{
		didSet
		{
			if numOfPoints <= 1
			{
				numOfPoints = 1
			}
			
			calcStarBasedOnCurrentSize()
			setNeedsDisplay()			
		}
	}
	
	@IBInspectable public var ratioOfOuterToInnerRadius: Double = 2.6
	{
		didSet
		{
			if ratioOfOuterToInnerRadius <= 1.0
			{
				ratioOfOuterToInnerRadius = 1.0
			}
			
			calcStarBasedOnCurrentSize()
			setNeedsDisplay()
		}
	}
	
	@IBInspectable public var percentageToFill: Double = 50.0
	@IBInspectable public var lineWidth: CGFloat = 5
	@IBInspectable public var useSimpleFill: Bool = true
	@IBInspectable public var strokeColor: UIColor = UIColor.redColor()
	{
		didSet
		{
			cgStrokeColor = strokeColor.CGColor
		}
	}
	
	@IBInspectable public var fillColor: UIColor = UIColor.redColor()
	{
		didSet
		{
			cgFillColor = fillColor.CGColor
		}
	}
	
	private var cgStrokeColor: CGColor = UIColor.redColor().CGColor
	private var cgFillColor: CGColor = UIColor.redColor().CGColor
	private var innerPoints = [CGPoint]()
	private var outerPoints = [CGPoint]()
	private var centre: CGPoint?
	private var outerRadius = 0.0
	
	public required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		contentMode = UIViewContentMode.Redraw
	}
	
	public override init(frame: CGRect)
	{
		super.init(frame: frame)
		contentMode = UIViewContentMode.Redraw		
	}
	
	public convenience init()
	{
		self.init(frame: CGRect.null)
	}
		
	public override func layoutSubviews()
	{
		calcStarBasedOnCurrentSize()
	}
	
	public override func drawRect(rect: CGRect)
	{
		guard let ctx = UIGraphicsGetCurrentContext() else
		{
			return
		}

		CGContextSetStrokeColorWithColor(ctx, cgStrokeColor)
		CGContextSetFillColorWithColor(ctx, cgFillColor)
		CGContextSetLineWidth(ctx, lineWidth)
		CGContextSetLineJoin(ctx, CGLineJoin.Round)
		
		CGContextSaveGState(ctx)
			
		drawStarIntoContext(ctx, innerPoints: innerPoints, outerPoints: outerPoints)
			
		CGContextClip(ctx)
		
		useSimpleFill ? fillSimple(ctx) : fillStarAsArc(ctx)
			
		CGContextFillPath(ctx)
			
		CGContextRestoreGState(ctx)
		
		drawStarIntoContext(ctx, innerPoints: innerPoints, outerPoints: outerPoints)
		
		CGContextStrokePath(ctx)
		
		// Debugging
		/*
		drawLineFromPoints(ctx, points: outerPoints)
		CGContextStrokePath(ctx)
		
		drawLineFromPoints(ctx, points: innerPoints)
		CGContextStrokePath(ctx)
		*/
	}
	
	func drawStarIntoContext(ctx: CGContext, innerPoints: [CGPoint], outerPoints: [CGPoint])
	{
		guard innerPoints.count == outerPoints.count && innerPoints.isEmpty == false else
		{
			return
		}

		CGContextMoveToPoint(ctx, innerPoints[0].x, innerPoints[0].y)
		
		for i in 0..<innerPoints.count
		{
			let outerIndex = (i + 1) % innerPoints.count
			
			CGContextAddLineToPoint(ctx, outerPoints[outerIndex].x, outerPoints[outerIndex].y)
			CGContextAddLineToPoint(ctx, innerPoints[outerIndex].x, innerPoints[outerIndex].y)
		}
		
		CGContextClosePath(ctx)
	}
	
	func fillSimple(ctx: CGContextRef)
	{
		let squareSideLen = min(bounds.width, bounds.height)
		let width = squareSideLen * CGFloat(percentageToFill / 100.0)
		
		guard let centre = centre else
		{
			return
		}
		
		CGContextAddRect(ctx, CGRect(origin: CGPoint(x: centre.x - squareSideLen / 2, y: centre.y - squareSideLen / 2), size: CGSize(width: width, height: squareSideLen)))
	}
	
	func fillStarAsArc(ctx: CGContextRef)
	{
		guard let centre = centre else
		{
			return
		}
		
		CGContextMoveToPoint(ctx, centre.x, centre.y)
		
		let startAngle = CGFloat(M_PI)
		let endAngle = startAngle + CGFloat((M_PI * 2.0) * (percentageToFill / 100.0))
		
		CGContextAddArc(ctx, centre.x, centre.y, CGFloat(outerRadius), startAngle, endAngle, Int32(0));
	}
	
	func calcStarBasedOnCurrentSize()
	{
		//print("calcStarBasedOnCurrentSize:\(frame)")

		centre = CGPoint(x: frame.size.width / 2, y:frame.height / 2)
		outerRadius = Double(((min(frame.size.width, frame.size.height) - lineWidth) / 2))

		calcStarForOuterRadius(outerRadius, withRatioOfOuterToInnerRadiusOf: ratioOfOuterToInnerRadius)
	}
	
	func calcStarForOuterRadius(outerRadius: Double,  withRatioOfOuterToInnerRadiusOf ratioOfOuterToInnerRadius: Double)
	{
		let angleOffsetInDegress = Double((360 / numOfPoints) / 2)
		
		outerPoints = plotPointsOfCircleWithRadius(outerRadius, numOfPoints: numOfPoints, startingAngle: StarView.degreesToRadians(-18))
		
		let innerRadius = outerRadius / ratioOfOuterToInnerRadius
		
		innerPoints = plotPointsOfCircleWithRadius(innerRadius, numOfPoints: numOfPoints, startingAngle: StarView.degreesToRadians(-18 + angleOffsetInDegress))
	}
	
	func plotPointsOfCircleWithRadius(radius: Double, numOfPoints: Int, startingAngle: Double) -> [CGPoint]
	{
		var points = [CGPoint]()
		
		for i in 0..<numOfPoints
		{
			let angle = startingAngle + (((M_PI * 2) / Double(numOfPoints)) * Double(i))
			
			let x = CGFloat(radius * cos(angle)) + (centre?.x ?? 0)
			let y = CGFloat(radius * sin(angle)) + (centre?.y ?? 0)
			
			points.append(CGPoint(x: x, y: y))
		}
		
		return points
	}
	
	class func degreesToRadians(degrees: Double) -> Double
	{
		return ((M_PI * 2) / 360) * degrees
	}

	//
	// Useful for debugging look & feel issues
	//
	func drawCircle(ctx: CGContext)
	{
		CGContextSetLineWidth(ctx, 10);
		CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
		CGContextAddArc(ctx, CGFloat(200.0), CGFloat(200.0), CGFloat(50.0), CGFloat(0.0), CGFloat(M_PI * 2.0), Int32(1));
	}
	
	func drawLineFromPoints(ctx: CGContext, points: [CGPoint])
	{
		CGContextMoveToPoint(ctx, points[0].x, points[0].y)
		
		for i in 1..<outerPoints.count
		{
			CGContextAddLineToPoint(ctx, points[i].x, points[i].y)
		}
		
		CGContextClosePath(ctx)
	}
}
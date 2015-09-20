@IBDesignable
public class StarRatingView : UIView
{
	@IBInspectable public var maxRating : Int = 1
	{
		didSet
		{
			if maxRating <= 0
			{
				maxRating = 1
			}
			
			createSubViews()
			setNeedsUpdateConstraints()
		}
	}
	
	@IBInspectable public var rating : Double = 0
	{
		didSet
		{
			if rating < 0
			{
				rating = 0.0
			}
			
			drawRating()
		}
	}
	
	@IBInspectable public var ratioOfOuterToInnerRadius: Double = 2.6
	{
		didSet
		{
			subviews.forEach { ($0 as? StarView)?.ratioOfOuterToInnerRadius = ratioOfOuterToInnerRadius }
		}
	}
	
	@IBInspectable public var lineWidth: CGFloat = 5
	{
		didSet
		{
			subviews.forEach { ($0 as? StarView)?.lineWidth = lineWidth }
		}
	}
	
	@IBInspectable public var useSimpleFill: Bool = true
	{
		didSet
		{
			subviews.forEach { ($0 as? StarView)?.useSimpleFill = useSimpleFill }
		}
	}
	
	@IBInspectable public var numOfPoints: Int = 5
	{
		didSet
		{
			subviews.forEach { ($0 as? StarView)?.numOfPoints = numOfPoints }
		}
	}
	
	private var subViewLayoutConstraints = [NSLayoutConstraint]()
		
	override public class func requiresConstraintBasedLayout() -> Bool
	{
		return true
	}
	
	private func createSubViews()
	{
		translatesAutoresizingMaskIntoConstraints = false
		contentMode = UIViewContentMode.Redraw
		
		subviews.forEach { $0.removeFromSuperview() }
						
		for _ in 0..<maxRating
		{
			let view = StarView()
			
			view.translatesAutoresizingMaskIntoConstraints = false
			view.backgroundColor = self.backgroundColor
			view.ratioOfOuterToInnerRadius = self.ratioOfOuterToInnerRadius
			view.lineWidth = self.lineWidth

			addSubview(view)
		}
		
		drawRating()
	}
	
	public override func updateConstraints()
	{
		defer
		{
			super.updateConstraints()
		}
		
		removeConstraints(subViewLayoutConstraints)
		
		subViewLayoutConstraints = [NSLayoutConstraint]()
		
		if subviews.isEmpty == false
		{
			for subViewPos in 0..<subviews.count
			{
				subViewLayoutConstraints += createConstrantsForStarViewAtPosition(subViewPos)
			}
			
			addConstraints(subViewLayoutConstraints)			
		}
	}
	
	func createConstrantsForStarViewAtPosition(pos: Int) -> [NSLayoutConstraint]
	{
		var constraints = [NSLayoutConstraint]()
		
		let starView = subviews[pos]
		
		if pos == 0
		{
			constraints += NSLayoutConstraint.constraintsWithVisualFormat(
				"H:|-0-[star]",
				options: NSLayoutFormatOptions.AlignAllCenterY,
				metrics: nil,
				views: ["star":starView])
		}
		else
		{
			constraints += NSLayoutConstraint.constraintsWithVisualFormat(
				"H:[left]-0-[star]",
				options: NSLayoutFormatOptions.AlignAllCenterY,
				metrics: nil,
				views: ["left":subviews[pos - 1], "star":starView])
			
		}
		
		constraints += NSLayoutConstraint.constraintsWithVisualFormat(
			"V:|[star]",
			options: NSLayoutFormatOptions.AlignAllTop,
			metrics: nil,
			views: ["star":starView])
		
		constraints.append(NSLayoutConstraint(item: starView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1.0 / CGFloat(maxRating), constant: 0.0))
		
		constraints.append(NSLayoutConstraint(item: starView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0))
		
		return constraints
	}
	
	func drawRating()
	{
		var rating = self.rating
		
		for view in subviews
		{
			if let view = view as? StarView
			{
				if rating >= 1
				{
					view.percentageToFill = 100.0
				}
				else if rating == 0
				{
					view.percentageToFill = 0.0
				}
				else
				{
					view.percentageToFill = rating * 100.0
				}
			}
			
			rating = max(0, rating - 1)
		}
	}
}

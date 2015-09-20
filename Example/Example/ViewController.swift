import UIKit
import StarViewControls

class ViewController: UIViewController
{
	@IBOutlet weak var starView: StarView!
	@IBOutlet weak var starRatingView: StarRatingView!

	@IBAction func onRatioChanged(sender: UISlider)
	{
		starView.ratioOfOuterToInnerRadius = Double(sender.value)
	}
	
	@IBAction func onNumOfPointsChanged(sender: UISlider)
	{
		starView.numOfPoints = Int(sender.value)
	}
	
	@IBAction func onMaxRatingChanged(sender: UISlider)
	{
		starRatingView.maxRating = Int(sender.value)
	}
}


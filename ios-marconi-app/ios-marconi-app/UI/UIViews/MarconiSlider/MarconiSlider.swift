import UIKit

class MarconiSlider: UISlider {

    weak var delegate: MarconiSeekDelegate?
    
    private var _minValueColor: UIColor = .lightGray
    private var _maxValueColor: UIColor = .black
    
    private var _lastUserActionValue: Float = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupThumb()
        _setupTrack()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupThumb()
        _setupTrack()
    }
    
    private func _setupThumb() {
        setThumbImage(UIImage(), for: .normal)
        setThumbImage(UIImage(), for: .highlighted)
        contentMode = .redraw
    }
    
    private func _setupTrack() {
        setMaximumTrackImage(UIImage(color: _minValueColor), for: .normal)
        setMaximumTrackImage(UIImage(color: _minValueColor), for: .highlighted)
        
        setMinimumTrackImage(UIImage(color: _maxValueColor), for: .normal)
        setMinimumTrackImage(UIImage(color: _maxValueColor), for: .highlighted)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        delegate?.seekBegan(value, slider: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        _lastUserActionValue = value
        delegate?.seekInProgress(_lastUserActionValue, slider: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        delegate?.seekEnded(_lastUserActionValue, slider: self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        delegate?.seekEnded(_lastUserActionValue, slider: self)
    }
}

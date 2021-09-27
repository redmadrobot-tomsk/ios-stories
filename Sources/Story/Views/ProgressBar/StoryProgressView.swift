//
//  StoryProgressView.swift
//  Stories
//

import UIKit

class StoryProgressView: UIProgressView {
  
  // MARK: - Properties
  
  private var beginTime: TimeInterval = 0.0
  private var timeOffset: TimeInterval = 0.0
  private var duration: TimeInterval = 0.0
  
  private var completion: ((_ finished: Bool) -> Void)?
  private var isPaused: Bool = true
  
  // MARK: - Overrides
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = frame.height / 2
  }
  
  // MARK: - Simulation
  
  func simulateProgress(withDuration duration: TimeInterval,
                        completion: ((_ finished: Bool) -> Void)?) {
    guard isPaused else { return }
    
    self.duration = duration
    
    removeAllAnimations()
    
    self.completion = completion
    
    beginTime = Date.timeIntervalSinceReferenceDate
    
    isPaused = false
    
    UIView.animate(withDuration: duration,
                   delay: 0,
                   options: .curveLinear,
                   animations: { [unowned self] in
                    self.setProgress(1.0, animated: false)
                    self.layoutIfNeeded()
      }, completion: { finished in
        if finished {
          self.isPaused = true
        }
        
        completion?(finished)
    })
  }
  
  func resetProgress() {
    removeAllAnimations()
    
    setProgress(0.0, animated: false)
    layoutIfNeeded()
    
    completion = nil
    isPaused = true
    
    beginTime = 0.0
    timeOffset = 0.0
  }
  
  func pauseSimulation() {
    if !isPaused {
      layer.sublayers?.forEach {
        let pausedTime = $0.convertTime(CACurrentMediaTime(), from: nil)
        $0.speed = 0.0
        $0.timeOffset = pausedTime
      }
      
      timeOffset += Date.timeIntervalSinceReferenceDate - beginTime
      isPaused = true
    }
  }
  
  func updatePausedSimulationProgress() {
    if isPaused {
      guard duration > 0 else { return }
      let defaultDuration = duration
      let remainingDuration = defaultDuration - timeOffset
      let progress = 1.0 - remainingDuration / defaultDuration
      
      setProgress(Float(progress), animated: false)
      layoutIfNeeded()
    }
  }
  
  func resumeSimulation() {
    updatePausedSimulationProgress()
    if isPaused {
      let remainingDuration = duration - timeOffset
      
      simulateProgress(withDuration: remainingDuration, completion: self.completion)
      isPaused = false
    }
  }
  
  private func removeAllAnimations() {
    layer.removeAllAnimations()
    layer.sublayers?.forEach {
      $0.removeAllAnimations()
      $0.speed = 1.0
      $0.timeOffset = 0.0
      $0.beginTime = 0.0
    }
  }
  
}

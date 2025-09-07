//
//  LiveWaveformView.swift
//  Voice Record Kit
//
//  Created by berken on 1.08.2025.
//

import UIKit
import AVFoundation

public final class LiveWaveformView: UIView {
  private var displayLink: CADisplayLink?
  private var waveformLayers: [CAShapeLayer] = []
  private var amplitudeSamples: [Float] = []
  private let maxSamples = 100
  private var isAnimating = false
  
  public var waveColor: UIColor = .systemIndigo {
    didSet {
      updateWaveformColors()
    }
  }
  
  public var waveWidth: CGFloat = 2.0 {
    didSet {
      setupWaveformLayers()
    }
  }
  
  public var waveSpacing: CGFloat = 4.0 {
    didSet {
      setupWaveformLayers()
    }
  }
  
  public var maxAmplitude: Float = 1.0
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    
    setupView()
  }
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setupView()
  }
  
  private func setupView() {
    backgroundColor = .clear
    
    clipsToBounds = true
    
    amplitudeSamples = Array(repeating: 0.0, count: maxSamples)
    
    setupWaveformLayers()
  }
  
  private func setupWaveformLayers() {
    waveformLayers.forEach { $0.removeFromSuperlayer() }
    waveformLayers.removeAll()
    
    let totalWidth = frame.width
    let waveCount = Int(totalWidth / (waveWidth + waveSpacing))
    let actualWaveCount = min(waveCount, maxSamples)
    
    for _ in 0..<actualWaveCount {
      let layer = CAShapeLayer()
      layer.strokeColor = waveColor.cgColor
      layer.fillColor = UIColor.clear.cgColor
      layer.lineWidth = waveWidth
      layer.lineCap = .round
      layer.lineJoin = .round
      
      self.layer.addSublayer(layer)
      waveformLayers.append(layer)
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    setupWaveformLayers()
    
    updateWaveform()
  }
  
  public func startAnimating() {
    guard !isAnimating else { return }
    
    isAnimating = true
  }
  
  public func stopAnimating() {
    isAnimating = false
    
    amplitudeSamples = Array(repeating: 0.0, count: maxSamples)
    
    updateWaveform()
  }
  
  public func updateWithAudioLevel(_ level: Float) {
    guard isAnimating else { return }
    
    let normalizedLevel = min(max(level, 0.0), maxAmplitude)
    
    addAmplitudeSample(normalizedLevel)
    
    updateWaveform()
  }
  
  private func addAmplitudeSample(_ amplitude: Float) {
    amplitudeSamples.removeFirst()
    amplitudeSamples.append(amplitude)
  }
  
  private func updateWaveform() {
    guard !waveformLayers.isEmpty else { return }
    
    let centerY = frame.height / 2
    let maxHeight = centerY - 10
    
    for (index, layer) in waveformLayers.enumerated() {
      let sampleIndex = max(0, amplitudeSamples.count - waveformLayers.count + index)
      let amplitude = sampleIndex < amplitudeSamples.count ? amplitudeSamples[sampleIndex] : 0.0
      
      let waveHeight = CGFloat(amplitude) * maxHeight
      
      let xPosition = CGFloat(index) * (waveWidth + waveSpacing) + waveWidth / 2
      
      let path = UIBezierPath()
      path.move(to: CGPoint(x: xPosition, y: centerY - waveHeight))
      path.addLine(to: CGPoint(x: xPosition, y: centerY + waveHeight))
      
      layer.path = path.cgPath
      
      let fadeAlpha = CGFloat(index) / CGFloat(waveformLayers.count - 1)
      layer.opacity = Float(0.3 + (0.7 * fadeAlpha))
    }
  }
  
  private func updateWaveformColors() {
    waveformLayers.forEach { layer in
      layer.strokeColor = waveColor.cgColor
    }
  }
}

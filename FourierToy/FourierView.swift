import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

class FourierView: UIView {
    // MARK: - Public properties

    var isPaused: Bool {
        set { displayLinker.isPaused = newValue }
        get { return displayLinker.isPaused }
    }

    var primaryGraphColor = Colors.primary
    var secondaryGraphColor = Colors.secondary
    var axesColor = Colors.axes
    var circlesColor = Colors.circles
    var vectorsColor = Colors.vectors
    var primaryGraphLineWidth: CGFloat = 3
    var coefficients: [Double] = [Double]() {
        didSet {
            recalculateSamples()
        }
    }

    // MARK: - Private properties

    private var displayLinker: DisplayLinker!
    private static let period = 1.0
    private static let numberOfSamplesForPeriod = 260
    private static let samplingStep = period / Double(numberOfSamplesForPeriod - 1)
    private let domain = 0.0 ... 1.5
    private let range = -1.5 ... 1.5
    private var currentSampleIndex = 0
    private var graphFrame = CGRect.zero
    private var samples = [Sample]()
    private var graphPath: CGPath!
    private var trajectoryPath: CGPath!

    // MARK: - Constructors

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - UIView overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        let splitRatio: CGFloat = 0.3
        let w1 = frame.width * splitRatio
        let w2 = frame.width * (1.0 - splitRatio)
        graphFrame = CGRect(x: frame.minX + w1, y: frame.minY, width: w2, height: frame.height)

        recalculateSamples()
    }

    override func draw(_: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("UIGraphicsGetCurrentContext returned nil")
        }

        let markerCircleRadius: CGFloat = 2.0

        let xAxisScale = graphFrame.width / CGFloat(domain.upperBound - domain.lowerBound)
        let yAxisScale = graphFrame.height / CGFloat(range.upperBound - range.lowerBound)
        let origin = CGPoint(x: graphFrame.minX, y: 0.5 * graphFrame.height)

        // Axes

        context.setStrokeColor(axesColor.cgColor)
        context.setLineWidth(1.0)
        context.strokeLineSegments(between: [
            // Horizontal
            CGPoint(x: frame.minX, y: 0.5 * frame.height), CGPoint(x: frame.maxX, y: 0.5 * frame.height),

            // Vertical
            CGPoint(x: graphFrame.minX, y: 0), CGPoint(x: graphFrame.minX, y: frame.height),

        ])

        // Origin

        context.strokeCircle(at: CGPoint(x: graphFrame.minX, y: graphFrame.midY), radius: 5)

        // Graphs

        context.saveGState()
        context.clip(to: graphFrame)

        context.saveGState()
        context.translateBy(x: origin.x, y: origin.y)
        context.scaleBy(x: xAxisScale, y: yAxisScale)

        var offset = CGFloat(-Double(currentSampleIndex) * FourierView.samplingStep)
        while offset < CGFloat(domain.upperBound) {
            context.saveGState()
            context.translateBy(x: offset, y: 0)
            context.addPath(graphPath)
            offset += CGFloat(FourierView.period)
            context.restoreGState()
        }
        context.restoreGState()

        context.setStrokeColor(primaryGraphColor.cgColor)
        context.setLineWidth(primaryGraphLineWidth)
        context.strokePath()

        context.restoreGState()

        context.translateBy(x: origin.x, y: origin.y)
        context.scaleBy(x: yAxisScale, y: yAxisScale)

        // Current Y value marker

        let currentSample = samples[currentSampleIndex]

        let point = CGPoint(x: 0, y: currentSample.y.last!.partialSum)
        context.setFillColor(primaryGraphColor.cgColor)
        context.fillCircle(at: point, radius: 2 * markerCircleRadius / yAxisScale)

        // Circles

        context.setLineWidth(1.0 / yAxisScale)
        var currentCenter = CGPoint.zero

        context.setFillColor(vectorsColor.cgColor)

        for i in 0 ..< coefficients.count {
            context.setStrokeColor(circlesColor.cgColor)
            context.strokeCircle(at: currentCenter, radius: CGFloat(coefficients[i]))

            let currentPoint = CGPoint(x: currentSample.x[i].partialSum, y: currentSample.y[i].partialSum)
            context.setStrokeColor(vectorsColor.cgColor)
            context.fillCircle(at: currentPoint, radius: markerCircleRadius / yAxisScale)
            context.strokeLineSegments(between: [
                currentCenter,
                currentPoint,
            ])

            currentCenter = currentPoint
        }

        context.setStrokeColor(primaryGraphColor.cgColor)
        context.strokeLineSegments(between: [
            currentCenter,
            CGPoint(x: 0, y: currentCenter.y),
        ])

        context.addPath(trajectoryPath)
        context.strokePath()
    }

    // MARK: - Private functions

    private func setup() {
        displayLinker = DisplayLinker {
            [unowned self] delta in self.update(delta: delta)
        }

        backgroundColor = UIColor.white
        coefficients = PredefinedCoefficients.square.calculate(6)
    }

    private func update(delta _: CFTimeInterval) {
        currentSampleIndex = (currentSampleIndex + 1) % samples.count
        setNeedsDisplay()
    }

    private func recalculateSamples() {
        samples.removeAll(keepingCapacity: true)

        var currentArgument = 0.0
        for _ in 0 ..< FourierView.numberOfSamplesForPeriod {
            samples.append(calculateFourierSample(currentArgument, coefficients: coefficients))
            currentArgument += FourierView.samplingStep
        }

        // Update paths

        let mutableGraphPath = CGMutablePath()

        let graphPoints = samples.map {
            (sample) -> CGPoint in
            let x = sample.argument
            let y = sample.y.last!.partialSum
            return CGPoint(x: x, y: y)
        }
        mutableGraphPath.addLines(between: graphPoints)
        graphPath = mutableGraphPath

        let mutableTrajectoryPath = CGMutablePath()
        let trajectoryPoints = samples.map {
            (sample) -> CGPoint in
            let x = sample.x.last!.partialSum
            let y = sample.y.last!.partialSum
            return CGPoint(x: x, y: y)
        }
        mutableTrajectoryPath.addLines(between: trajectoryPoints)
        trajectoryPath = mutableTrajectoryPath
    }
}

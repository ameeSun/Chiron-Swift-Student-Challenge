//
//  WaveResultView.swift
//  Chiron
//
//  Created by ak on 2/8/25.
//

import SwiftUI
import PencilKit
import CoreML


struct WaveResultView: View {
    @Binding var path: NavigationPath
    @State private var test_result: String = ""
    @State private var drawing_stats: String = ""
    @State private var drawingStats: DrawingStats = DrawingStats()
    var canvasView:PKCanvasView
    
    init(path: Binding<NavigationPath>, canvasView: PKCanvasView) {
        self._path = path
        self.canvasView = canvasView
        
    }
    
    struct Resp: Decodable, CustomStringConvertible {
        let result: String
        //let name: String
        
        
        var description: String {
            return "Resp: { result: \(result) }"
        }
    }
    
    var body: some View {
        NavigationStack{
            Form{
                Image("Chiron-3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Section{
                    //Text(test_result)
                    if test_result.uppercased() == "PARKINSON"{
                        HStack{
                            Text("You ***are*** at risk for Parkinson's Disease")
                                .font(.headline)
                            
                            Image("Chiron-4")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    else {
                        HStack{
                            Text("You ***are not*** at risk for Parkinson's Disease")
                                .font(.headline)
                            
                            Image("Chiron-5")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                        }
                    }
                    Text("Parkinson’s disease is a progressive disorder that is caused by degeneration of nerve cells in the part of the brain called the substantia nigra, which controls movement. Symptoms usually begin gradually and worsen over time. As the disease progresses, people may have difficulty walking and talking. They may also have mental and behavioral changes, sleep problems, depression, memory difficulties, and fatigue. \n\nFor more information, visit the \"Learn\" tab in the app.")
                        .font(.callout)
                }header: {
                    Text("Result")
                }.onAppear{
                    statsImage()
                    analyzeImage()
                    canvasView.drawing=PKDrawing()
                }
                Section{
                    VStack(spacing: 10.0){
                        ExtractedView(fieldValue: drawingStats.totalTime,fieldText: "Time",fieldInfo: "Time in completing the test")
                        ExtractedView(fieldValue: drawingStats.length,fieldText: "Length",fieldInfo: "Length of the drawing")
                        ExtractedView(fieldValue: drawingStats.velocitySD,fieldText: "Velocity SD",fieldInfo: "Velocity Standard Deviation")
                        
                    }
                }header: {
                    Text("Test Statistics")
                }
                Section{
                    NavigationLink("Try Again") {
                        TestsView()
                    }.font(.headline)
                    //.fontWeight(.bold)
                        .padding(20)
                    //.foregroundColor(.pink)
                    NavigationLink("Return Home") {
                        HomeView()
                    }.font(.headline)
                    //.fontWeight(.bold)
                        .padding(20)
                    NavigationLink("View Dashboard") {
                        DashView()
                    }.font(.headline)
                    //.fontWeight(.bold)
                        .padding(20)
                }header: {
                    Text("Exit")
                }
                
            }
            .navigationBarTitle("Test Results")
        }
        
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
    }
    
    func standardDeviation(arr : [Double]) -> Double
    {
        let length = Double(arr.count)
        let avg = arr.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, +)
        return sqrt(sumOfSquaredAvgDiff / (length-1))
    }
    
    func statsImage() {
        
        let strokeCount = canvasView.drawing.strokes.count
        var count : Int=0
        var velocity : [Double] = []
        var total_time: Double=0
        var length: Double = 0
        for stroke in canvasView.drawing.strokes {
            let paths = stroke.path
            var path_starttime: Date = paths.creationDate
            if (paths.count<3) {
                continue
            }
            for i in 1...paths.count-1 {
                var point_cur:PKStrokePoint=paths[i]
                var point_prev:PKStrokePoint=paths[i-1]
                //print("cur time:\(point_cur.timeOffset), prev time: \(point_prev.timeOffset)")
                //print("cur x:\(point_cur.location.x), prev x: \(point_prev.location.x),cur y:\(point_cur.location.y), prev y: \(point_prev.location.y) ")
                var time_offset:Double=point_cur.timeOffset-point_prev.timeOffset
                total_time+=time_offset
                if point_cur.timeOffset != 0 {
                    var instantDistance=CGPointDistance(from:point_prev.location,to: point_cur.location)
                    length+=instantDistance
                    var instantVelocity=instantDistance/time_offset
                    velocity.append(instantVelocity)
                    /*print("distance:",CGPointDistance(from:point_prev.location,to: point_cur.location),"time:",String(time_offset), "velocity",instantVelocity)
                     */
                }
                /*var point_time=path_starttime + point.timeOffset
                 drawing_stats=drawing_stats+"("+String(format: "%.1f",point.location.x)+","+String(format:"%.1f",point.location.y)+","+String(format: "%.3f",point_time.timeIntervalSince1970)+"),"
                 */
            }
        }
        drawingStats.totalTime=String(format: "%.1f",total_time)
        drawingStats.length=String(format: "%.1f",length)
        drawingStats.velocitySD=String(format:"%.1f",standardDeviation(arr: velocity))
        
        
    }
    
    func convertToGrayScale(image: UIImage) -> UIImage? {
        let width = image.size.width
        let height = image.size.height
        let imageRect:CGRect = CGRect(x:0, y:0, width:width, height: height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        if let cgImg = image.cgImage {
            context?.draw(cgImg, in: imageRect)
            if let makeImg = context?.makeImage() {
                let imageRef = makeImg
                let newImage = UIImage(cgImage: imageRef)
                return newImage
            }
        }
        return UIImage()
    }
    
    
    func prepareImage(image: UIImage) -> UIImage? {
        let width = 128
        let height = 128
        
        //resize the image to 128x128
        let context = CIContext()
        let ciimage = CIImage(image: image)
        let scale = (Double)(height) / (Double)(image.size.height)
        let aspectRatio = (Double)(width)/(Double)((image.size.width) * scale)
        //print("scale: ", scale)
        let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!
        resizeFilter.setValue(ciimage, forKey: kCIInputImageKey)
        resizeFilter.setValue(NSNumber(value:scale), forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey:kCIInputAspectRatioKey)
        
        let outputImage = resizeFilter.outputImage
        let renderedImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let imageNew = UIImage(cgImage: renderedImage!)
        
        let imageNewWhiteBG=imageNew.redrawing(overColor: .white)
        let imageNewGray=convertToGrayScale(image: imageNewWhiteBG)
        /*print("image size:",imageNewGray!.size)
         let alphaInfo=imageNewGray!.cgImage?.alphaInfo
         let cgImage=imageNewGray!.cgImage
         print("alpha info:", cgImage?.alphaInfo.rawValue)
         print("bitsPerComponent:",cgImage?.bitsPerComponent)
         print("bitsPerPixel:",cgImage?.bitsPerPixel)
         print("data provider: ", cgImage)
         //print("data provider: ", cgImage?.dataProvider?.data)
         */
        
        return imageNewGray
    }
    
    func analyzeImage(){
        
        let image = canvasView.drawing.image(from: canvasView.drawing.bounds, scale: 1.0).withTintColor(.systemGray6, renderingMode: .alwaysOriginal)
        
        do{
            let resultImage=prepareImage(image: image)!
            let config=MLModelConfiguration()
            let model=try parkinson_wave(configuration: config)
            let pinput=parkinson_waveInput(input_1: resultImage.mlMultiArrayGrayScale(scale:1))
            
            
            let predictions=try model.prediction(input: pinput)
            let result_value=(predictions.Identity)
            print("prediction",result_value)
            if (Double(result_value[0]) > Double(0.5)) {
                test_result="Healthy"
            }
            else{
                test_result="Parkinson"
            }
        }
        catch{
            print("error ")
        }
        
    }
    
}

struct WaveResultView_Previews: PreviewProvider {
    static var previews: some View {
        @State  var path: NavigationPath=NavigationPath()
        WaveResultView(path: $path, canvasView: PKCanvasView())
    }
}

struct ExtractedView: View {
    @State private var showingPopover = false
    let fieldValue: String
    let fieldText: String
    let fieldInfo: String
    
    var body: some View {
        HStack {
            Button(){
                showingPopover = true
            } label: {
                Label(fieldText, systemImage: "info.circle").labelStyle(.trailingIcon).frame(width: 180, alignment: .trailing).font(.headline)
            }
            .popover(isPresented: $showingPopover,
                     attachmentAnchor: .point(.bottom),
                     arrowEdge: .top,
                     content: {
                Text(fieldInfo)
                //                        .presentationCompactAdaptation(.none)
                    .padding()
            })
            .cornerRadius(0.0)
            
            Text(fieldValue)
                .frame(width: 200, alignment: .center).font(.callout)
        }
    }
}


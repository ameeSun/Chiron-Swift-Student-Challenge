//
//  parkinson_spiral.swift
//  Chiron
//
//  Created by ak on 2/15/25.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class parkinson_spiralInput : MLFeatureProvider {

    /// input_1 as 1 × 128 × 128 × 1 4-dimensional array of floats
    var input_1: MLMultiArray

    var featureNames: Set<String> {
        get {
            return ["input_1"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "input_1") {
            return MLFeatureValue(multiArray: input_1)
        }
        return nil
    }
    
    init(input_1: MLMultiArray) {
        self.input_1 = input_1
    }

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    convenience init(input_1: MLShapedArray<Float>) {
        self.init(input_1: MLMultiArray(input_1))
    }

}


/// Model Prediction Output Type
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class parkinson_spiralOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// Identity as multidimensional array of floats
    var Identity: MLMultiArray {
        return self.provider.featureValue(for: "Identity")!.multiArrayValue!
    }

    /// Identity as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var IdentityShapedArray: MLShapedArray<Float> {
        return MLShapedArray<Float>(self.Identity)
    }

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(Identity: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["Identity" : MLFeatureValue(multiArray: Identity)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class parkinson_spiral {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "parkinson_spiral", withExtension:"mlmodelc")!
    }

    /**
        Construct parkinson_spiral instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of parkinson_spiral.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `parkinson_spiral.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct parkinson_spiral instance by automatically loading the model from the app's bundle.
    */
    @available(*, deprecated, message: "Use init(configuration:) instead and handle errors appropriately.")
    convenience init() {
        try! self.init(contentsOf: type(of:self).urlOfModelInThisBundle)
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct parkinson_spiral instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct parkinson_spiral instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<parkinson_spiral, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct parkinson_spiral instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> parkinson_spiral {
        return try await self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct parkinson_spiral instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    @available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<parkinson_spiral, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(parkinson_spiral(model: model)))
            }
        }
    }

    /**
        Construct parkinson_spiral instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> parkinson_spiral {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return parkinson_spiral(model: model)
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as parkinson_spiralInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as parkinson_spiralOutput
    */
    func prediction(input: parkinson_spiralInput) throws -> parkinson_spiralOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as parkinson_spiralInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as parkinson_spiralOutput
    */
    func prediction(input: parkinson_spiralInput, options: MLPredictionOptions) throws -> parkinson_spiralOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return parkinson_spiralOutput(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        - parameters:
           - input: the input to the prediction as parkinson_spiralInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as parkinson_spiralOutput
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
    func prediction(input: parkinson_spiralInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> parkinson_spiralOutput {
        let outFeatures = try await model.prediction(from: input, options:options)
        return parkinson_spiralOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - input_1 as 1 × 128 × 128 × 1 4-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as parkinson_spiralOutput
    */
    func prediction(input_1: MLMultiArray) throws -> parkinson_spiralOutput {
        let input_ = parkinson_spiralInput(input_1: input_1)
        return try self.prediction(input: input_)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - input_1 as 1 × 128 × 128 × 1 4-dimensional array of floats

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as parkinson_spiralOutput
    */

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func prediction(input_1: MLShapedArray<Float>) throws -> parkinson_spiralOutput {
        let input_ = parkinson_spiralInput(input_1: input_1)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        - parameters:
           - inputs: the inputs to the prediction as [parkinson_spiralInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [parkinson_spiralOutput]
    */
    func predictions(inputs: [parkinson_spiralInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [parkinson_spiralOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [parkinson_spiralOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  parkinson_spiralOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}

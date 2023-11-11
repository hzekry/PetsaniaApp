import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'dart:convert';

Future<dynamic> performSentimentAnalysis(String review) async {
  String modelPath = 'assets/SA/best_model.pkl';
  String vectorizerPath = 'assets/SA/vectorizer.pkl';

  String modelData = await rootBundle.loadString(modelPath);
  String vectorizerData = await rootBundle.loadString(vectorizerPath);

  // Perform sentiment analysis
  final sentimentAnalysisChannel = MethodChannel('sentiment_analysis');
  final Map<String, dynamic> analysisResult =
  await sentimentAnalysisChannel.invokeMethod('performSentimentAnalysis', {
    'review': review,
    'modelData': modelData,
    'vectorizerData': vectorizerData,
  });

  // Extract sentiment score and label from the analysis result
  double sentimentScore = analysisResult['sentimentScore'];
  String sentimentLabel = analysisResult['sentimentLabel'];

  // Return the sentiment score and label
  return {'sentimentScore': sentimentScore, 'sentimentLabel': sentimentLabel};
}

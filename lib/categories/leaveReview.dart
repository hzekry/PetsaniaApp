import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class leaveReview extends StatefulWidget {
  final String businessID;
  const leaveReview({Key? key, required this.businessID}) : super(key: key);
  @override
  State<leaveReview> createState() => _leaveReviewState();
}

class _leaveReviewState extends State<leaveReview> {
  final _formKey = GlobalKey<FormState>();
  double _stars = 0;
  String _review = '';
  String _errorMessage = '';
  String _sentimentLabel = '';
  var _sentimentScore ;
Timer? _timer;
bool _showSentiment = false;
  void _saveReviewAndStars() async {
    final CollectionReference reviewsRef =
    FirebaseFirestore.instance.collection('review');


    final url = Uri.parse('http://192.168.43.83:5000/sentiment-analysis');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'review': _review}),
      );
      print('Response: ${response.body}');

      if (response.statusCode == 200 && response.body != null) {
        final sentimentAnalysis = json.decode(response.body);
        final sentimentScore = sentimentAnalysis['sentiment_score'];
        final sentimentLabel = sentimentAnalysis['sentiment_label'];
        final businessDocRef = FirebaseFirestore.instance
            .collection('businesses')
            .doc(widget.businessID);

        final businessDocSnapshot = await businessDocRef.get();
        final commonKeywordsSentiment = Map<String, dynamic>.from(businessDocSnapshot.data()!['common_words_sentiment'] ?? {});

        final words = _review.split(' ');
        for (final word in words) {
          if (commonKeywordsSentiment.containsKey(word)) {
            final keywordData = commonKeywordsSentiment[word];
            final count = keywordData['count'] ?? 0;
            commonKeywordsSentiment[word]['count'] = count + 1;
          }
        }

        await businessDocRef.update({'common_words_sentiment': commonKeywordsSentiment});




        FirebaseFirestore.instance.runTransaction((transaction) async {
          final businessDoc = await transaction.get(businessDocRef);
          final currentReviewCount = businessDoc.data()!['review_count'];
          final currentTotalSentimentScore =
          businessDoc.data()!['total_sentiment_score'];
          final newTotalSentimentScore =
              (currentTotalSentimentScore * currentReviewCount + sentimentScore) /
                  (currentReviewCount + 1);
          transaction.update(
            businessDocRef,
            {'total_sentiment_score': newTotalSentimentScore,
              'review_count': currentReviewCount + 1},
          );
        });
        setState(() {
          _sentimentLabel = sentimentLabel;
          _sentimentScore = sentimentScore ;
          _showSentiment = true;
        });
        reviewsRef.add({
          'businessID': widget.businessID,
          'stars': _stars,
          'text': _review,
          'timestamp': FieldValue.serverTimestamp(),
          'sentiment_score': sentimentScore,
          'sentiment_label': sentimentLabel,
        });

        _formKey.currentState!.reset();
        _stars = 0;
        _review = '';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Review submitted'),
            duration: Duration(seconds: 2),
          ),
        );
        _timer?.cancel();
        _timer = Timer(Duration(seconds: 5), () {
          setState(() {
            _showSentiment =false;
          });
        });
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error submitting review: $error');

    }
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          RatingBar.builder(
            initialRating: 0,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _stars = rating;
              });
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter your review',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a review';
              }
              return null;
            },
            onSaved: (value) {
              _review = value!;
            },
          ),
          SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                _saveReviewAndStars();
              }
            },
            child: Text('Submit'),
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
              backgroundColor: MaterialStateProperty.all<Color>(Color(0xff3E54AC)),
            ),
          ),
          SizedBox(height: 10,),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.red),
          ),

          Visibility(
            visible: _showSentiment,
            child: Column(
              children: [
                Text(
                  'Sentiment Label: $_sentimentLabel',
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  'Sentiment Score: $_sentimentScore',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}

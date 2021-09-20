import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:http/http.dart' as http;
import 'package:number_trivvia/core/error/exceptions.dart';
import 'package:number_trivvia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivvia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientError404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a GET request on a URL with number
     being the endpoint and with application/json header''', () async {
      //Arrange
      setUpMockHttpClientSuccess200();
      //Act
      dataSource.getConcreteNumberTrivia(tNumber);
      //Assert
      verify(mockHttpClient.get(
        Uri.parse('http://numbersapi.com/$tNumber'),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should return number trivia when response code is 200 (sucess)', () async {
      //Arrange
      setUpMockHttpClientSuccess200();
      //Act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      //Assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the response is 404 or other', () async {
      //Arrange
      setUpMockHttpClientError404();
      //Act
      final call = dataSource.getConcreteNumberTrivia;
      //Assert
      expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a GET request on a URL with number
     being the endpoint and with application/json header''', () async {
      //Arrange
      setUpMockHttpClientSuccess200();
      //Act
      dataSource.getRandomNumberTrivia();
      //Assert
      verify(mockHttpClient.get(
        Uri.parse('http://numbersapi.com/random'),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should return number trivia when response code is 200 (sucess)', () async {
      //Arrange
      setUpMockHttpClientSuccess200();
      //Act
      final result = await dataSource.getRandomNumberTrivia();
      //Assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the response is 404 or other', () async {
      //Arrange
      setUpMockHttpClientError404();
      //Act
      final call = dataSource.getRandomNumberTrivia;
      //Assert
      expect(() => call(), throwsA(TypeMatcher<ServerException>()));
    });
  });
}

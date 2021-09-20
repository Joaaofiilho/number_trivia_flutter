import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart';
import 'package:number_trivvia/core/error/exceptions.dart';
import 'package:number_trivvia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivvia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia_cache.json')));

    test('should return number trivia from shared preferences when there is one in the cache', () async {
      //Arrange
      when(mockSharedPreferences.getString(any)).thenReturn(fixture('trivia_cache.json'));
      //Act
      final result = await dataSource.getLastNumberTrivia();
      //Assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a cache exception when there is not a cached value', () async {
      //Arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      //Act
      final call = dataSource.getLastNumberTrivia;
      //Assert
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'test trivia', number: 1);

    test('should call shared preferences', () async {
      //Act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      //Assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:satulemari/features/browse/presentation/bloc/browse_bloc.dart';

void main() {
  group('BrowseBloc Speech-to-Text Filter Management', () {
    test('initial state should have isFromSpeechToText as false', () {
      // Test that the initial state has the correct default value
      final initialState = BrowseState.initial();
      expect(initialState.isFromSpeechToText, false);
    });

    test('copyWith should preserve isFromSpeechToText when not specified', () {
      // Test that copyWith preserves the flag when not explicitly changed
      final state = BrowseState.initial().copyWith(isFromSpeechToText: true);
      expect(state.isFromSpeechToText, true);

      final newState = state.copyWith(query: 'test');
      expect(newState.isFromSpeechToText, true);
    });

    test('copyWith should update isFromSpeechToText when specified', () {
      // Test that copyWith can change the flag
      final state = BrowseState.initial().copyWith(isFromSpeechToText: true);
      expect(state.isFromSpeechToText, true);

      final newState = state.copyWith(isFromSpeechToText: false);
      expect(newState.isFromSpeechToText, false);
    });

    test('state equality should include isFromSpeechToText', () {
      // Test that the flag is included in equality comparison
      final state1 = BrowseState.initial().copyWith(isFromSpeechToText: true);
      final state2 = BrowseState.initial().copyWith(isFromSpeechToText: false);
      final state3 = BrowseState.initial().copyWith(isFromSpeechToText: true);

      expect(state1 == state2, false);
      expect(state1 == state3, true);
    });

    test('state props should include isFromSpeechToText', () {
      // Test that the flag is included in the props list for Equatable
      final state = BrowseState.initial();
      expect(state.props.contains(state.isFromSpeechToText), true);
    });

    test('speech-to-text filters should be applied correctly', () {
      // Test that AI filters are applied directly without fallback to existing state
      final initialState = BrowseState.initial();
      final stateWithAiFilters = initialState.copyWith(
        categoryId: 'ai_category',
        size: 'M',
        isFromSpeechToText: true,
      );

      expect(stateWithAiFilters.categoryId, 'ai_category');
      expect(stateWithAiFilters.size, 'M');
      expect(stateWithAiFilters.isFromSpeechToText, true);
    });
  });
}

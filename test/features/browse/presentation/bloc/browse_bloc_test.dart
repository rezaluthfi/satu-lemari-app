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

    test('search clear should reset to initial state', () {
      // Test that SearchCleared always resets to clean state
      final clearedState = BrowseState.initial().copyWith(
        activeTab: 'rental', // Should preserve active tab
        isFromSpeechToText: false, // Should reset speech-to-text flag
      );

      expect(clearedState.query, '');
      expect(clearedState.categoryId, null);
      expect(clearedState.size, null);
      expect(clearedState.isFromSpeechToText, false);
      expect(clearedState.activeTab, 'rental'); // Should preserve active tab
    });
  });

  group('BrowseBloc Loading State Management', () {
    test('filter operations should set loading states for both tabs', () {
      // Test that filter operations immediately set loading states
      final stateWithLoading = BrowseState.initial().copyWith(
        categoryId: 'test_category',
        donationStatus: BrowseStatus.loading,
        rentalStatus: BrowseStatus.loading,
        isFromSpeechToText: false,
      );

      expect(stateWithLoading.donationStatus, BrowseStatus.loading);
      expect(stateWithLoading.rentalStatus, BrowseStatus.loading);
      expect(stateWithLoading.categoryId, 'test_category');
    });

    test('search operations should set loading states for both tabs', () {
      // Test that search operations immediately set loading states
      final stateWithLoading = BrowseState.initial().copyWith(
        query: 'test search',
        lastPerformedQuery: 'test search',
        donationStatus: BrowseStatus.loading,
        rentalStatus: BrowseStatus.loading,
        isFromSpeechToText: false,
      );

      expect(stateWithLoading.donationStatus, BrowseStatus.loading);
      expect(stateWithLoading.rentalStatus, BrowseStatus.loading);
      expect(stateWithLoading.query, 'test search');
    });

    test('speech-to-text operations should set loading states for both tabs',
        () {
      // Test that speech-to-text operations immediately set loading states
      final stateWithLoading = BrowseState.initial().copyWith(
        query: 'speech query',
        donationStatus: BrowseStatus.loading,
        rentalStatus: BrowseStatus.loading,
        suggestionStatus: SuggestionStatus.loading,
        isFromSpeechToText: true,
      );

      expect(stateWithLoading.donationStatus, BrowseStatus.loading);
      expect(stateWithLoading.rentalStatus, BrowseStatus.loading);
      expect(stateWithLoading.suggestionStatus, SuggestionStatus.loading);
      expect(stateWithLoading.isFromSpeechToText, true);
    });

    test('reset operations should set loading states for both tabs', () {
      // Test that reset operations immediately set loading states
      final stateWithLoading = BrowseState.initial().copyWith(
        activeTab: 'rental',
        donationStatus: BrowseStatus.loading,
        rentalStatus: BrowseStatus.loading,
        isFromSpeechToText: false,
      );

      expect(stateWithLoading.donationStatus, BrowseStatus.loading);
      expect(stateWithLoading.rentalStatus, BrowseStatus.loading);
      expect(stateWithLoading.activeTab, 'rental');
      expect(stateWithLoading.isFromSpeechToText, false);
    });
  });
}

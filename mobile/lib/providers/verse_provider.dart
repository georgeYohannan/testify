import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/verse.dart';

class VerseProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Verse? _dailyVerse;
  List<Verse> _allVerses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Verse? get dailyVerse => _dailyVerse;
  List<Verse> get allVerses => _allVerses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  VerseProvider() {
    _loadDailyVerse();
  }

  Future<void> _loadDailyVerse() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get a random verse for the day
      final response = await _supabase
          .from('verses')
          .select()
          .limit(1)
          .order('created_at', ascending: false);

      if (response != null && response.isNotEmpty) {
        // For now, just get the first verse
        // In a production app, you might want to implement a proper daily verse system
        _dailyVerse = Verse.fromJson(response.first);
      }
    } catch (e) {
      _errorMessage = 'Failed to load daily verse: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllVerses() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase
          .from('verses')
          .select()
          .order('created_at', ascending: false);

      if (response != null) {
        _allVerses = (response as List)
            .map((json) => Verse.fromJson(json))
            .toList();
      }
    } catch (e) {
      _errorMessage = 'Failed to load verses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDailyVerse() async {
    await _loadDailyVerse();
  }

  Future<bool> addVerse({
    required String text,
    required String reference,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase
          .from('verses')
          .insert({
            'text': text,
            'reference': reference,
          })
          .select()
          .single();

      if (response != null) {
        final newVerse = Verse.fromJson(response);
        _allVerses.insert(0, newVerse);
        
        // If this is the first verse, set it as daily verse
        if (_dailyVerse == null) {
          _dailyVerse = newVerse;
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to add verse: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVerse({
    required String id,
    String? text,
    String? reference,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updateData = <String, dynamic>{};
      if (text != null) updateData['text'] = text;
      if (reference != null) updateData['reference'] = reference;

      final response = await _supabase
          .from('verses')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      if (response != null) {
        final updatedVerse = Verse.fromJson(response);
        
        // Update in allVerses list
        final index = _allVerses.indexWhere((v) => v.id == id);
        if (index != -1) {
          _allVerses[index] = updatedVerse;
        }
        
        // Update daily verse if it's the same
        if (_dailyVerse?.id == id) {
          _dailyVerse = updatedVerse;
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update verse: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVerse(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabase
          .from('verses')
          .delete()
          .eq('id', id);

      // Remove from allVerses list
      _allVerses.removeWhere((v) => v.id == id);
      
      // If daily verse was deleted, load a new one
      if (_dailyVerse?.id == id) {
        await _loadDailyVerse();
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete verse: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Verse>> searchVerses(String query) async {
    try {
      if (query.isEmpty) {
        return _allVerses;
      }

      final response = await _supabase
          .from('verses')
          .select()
          .or('text.ilike.%$query%,reference.ilike.%$query%')
          .order('created_at', ascending: false);

      if (response != null) {
        return (response as List)
            .map((json) => Verse.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      _errorMessage = 'Failed to search verses: $e';
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get verse by reference
  Verse? getVerseByReference(String reference) {
    try {
      return _allVerses.firstWhere(
        (verse) => verse.reference.toLowerCase() == reference.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get random verse (excluding daily verse)
  Verse? getRandomVerse() {
    if (_allVerses.isEmpty) return null;
    
    final availableVerses = _allVerses
        .where((v) => v.id != _dailyVerse?.id)
        .toList();
    
    if (availableVerses.isEmpty) return _allVerses.first;
    
    availableVerses.shuffle();
    return availableVerses.first;
  }
}

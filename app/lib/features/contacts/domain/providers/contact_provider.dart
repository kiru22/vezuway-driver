import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/providers/auth_provider.dart';
import '../../../packages/data/models/package_model.dart';
import '../../data/models/contact_model.dart';
import '../../data/repositories/contact_repository.dart';

/// Provider del repositorio de contactos
final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ContactRepository(apiService);
});

/// Estado de la lista de contactos
class ContactsState {
  final List<ContactModel> contacts;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const ContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  ContactsState copyWith({
    List<ContactModel>? contacts,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Notifier para gestionar la lista de contactos
class ContactsNotifier extends StateNotifier<ContactsState> {
  final ContactRepository _repository;

  ContactsNotifier(this._repository) : super(const ContactsState());

  String? _currentSearch;
  bool? _currentVerifiedFilter;

  /// Cargar contactos (inicial o con búsqueda/filtros)
  Future<void> loadContacts({
    String? search,
    bool? verified,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

    // Si es refresh, resetear estado
    if (refresh) {
      state = const ContactsState(isLoading: true);
      _currentSearch = search;
      _currentVerifiedFilter = verified;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final contacts = await _repository.getContacts(
        search: search,
        verified: verified,
        page: refresh ? 1 : state.currentPage,
      );

      state = state.copyWith(
        contacts: refresh ? contacts : [...state.contacts, ...contacts],
        isLoading: false,
        hasMore: contacts.length >= 20, // Asumiendo perPage = 20
        currentPage: refresh ? 2 : state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cargar más contactos (paginación)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    await loadContacts(
      search: _currentSearch,
      verified: _currentVerifiedFilter,
    );
  }

  /// Refrescar lista
  Future<void> refresh() async {
    await loadContacts(
      search: _currentSearch,
      verified: _currentVerifiedFilter,
      refresh: true,
    );
  }

  /// Buscar contactos
  Future<void> search(String query) async {
    await loadContacts(search: query, refresh: true);
  }

  /// Filtrar por verificados
  Future<void> filterVerified(bool verified) async {
    await loadContacts(verified: verified, refresh: true);
  }

  /// Crear nuevo contacto
  Future<ContactModel> createContact({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final contact = await _repository.createContact(
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
    );

    // Añadir al principio de la lista
    state = state.copyWith(
      contacts: [contact, ...state.contacts],
    );

    return contact;
  }

  /// Actualizar contacto existente
  Future<ContactModel> updateContact(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final updatedContact = await _repository.updateContact(id, updates);

    // Actualizar en la lista
    final updatedList = state.contacts.map((c) {
      return c.id == id ? updatedContact : c;
    }).toList();

    state = state.copyWith(contacts: updatedList);

    return updatedContact;
  }

  /// Eliminar contacto
  Future<void> deleteContact(String id) async {
    await _repository.deleteContact(id);

    // Eliminar de la lista
    final updatedList = state.contacts.where((c) => c.id != id).toList();
    state = state.copyWith(contacts: updatedList);
  }
}

/// Provider de la lista de contactos
final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  final repository = ref.read(contactRepositoryProvider);
  return ContactsNotifier(repository);
});

/// Provider para obtener el detalle de un contacto
final contactDetailProvider =
    FutureProvider.family<ContactModel, String>((ref, id) async {
  final repository = ref.read(contactRepositoryProvider);
  return repository.getContact(id);
});

/// Provider para búsqueda typeahead
final contactSearchProvider =
    FutureProvider.family<List<ContactModel>, String>((ref, query) async {
  if (query.length < 2) return [];

  final repository = ref.read(contactRepositoryProvider);
  return repository.searchContacts(query);
});

/// Provider para obtener paquetes de un contacto
final contactPackagesProvider =
    FutureProvider.family<List<PackageModel>, String>((ref, contactId) async {
  final repository = ref.read(contactRepositoryProvider);
  return repository.getContactPackages(contactId);
});

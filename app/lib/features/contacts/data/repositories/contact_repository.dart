import '../../../../core/services/api_service.dart';
import '../../../packages/data/models/package_model.dart';
import '../models/contact_model.dart';

class ContactRepository {
  final ApiService _apiService;

  ContactRepository(this._apiService);

  /// Obtener lista de contactos con búsqueda y paginación
  Future<List<ContactModel>> getContacts({
    String? search,
    bool? verified,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (verified != null) {
      queryParams['verified'] = verified;
    }

    final response =
        await _apiService.get('/contacts', queryParameters: queryParams);
    final data = response.data['data'] as List;
    return data.map((json) => ContactModel.fromJson(json)).toList();
  }

  /// Búsqueda rápida para typeahead (máximo 10 resultados)
  Future<List<ContactModel>> searchContacts(String query) async {
    if (query.length < 2) return [];

    final response = await _apiService.get(
      '/contacts/search',
      queryParameters: {'q': query},
    );

    final data = response.data['data'] as List;
    return data.map((json) => ContactModel.fromJson(json)).toList();
  }

  /// Obtener detalle de un contacto
  Future<ContactModel> getContact(String id) async {
    final response = await _apiService.get('/contacts/$id');
    return ContactModel.fromJson(response.data['data']);
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
    Map<String, dynamic>? metadata,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (notes != null) 'notes': notes,
      if (metadata != null) 'metadata': metadata,
    };

    final response = await _apiService.post('/contacts', data: data);
    return ContactModel.fromJson(response.data['data']);
  }

  /// Actualizar contacto existente
  Future<ContactModel> updateContact(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiService.put('/contacts/$id', data: updates);
    return ContactModel.fromJson(response.data['data']);
  }

  /// Eliminar contacto (soft delete)
  Future<void> deleteContact(String id) async {
    await _apiService.delete('/contacts/$id');
  }

  /// Obtener histórico de paquetes de un contacto
  Future<List<PackageModel>> getContactPackages(
    String contactId, {
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiService.get(
      '/contacts/$contactId/packages',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    final data = response.data['data'] as List;
    return data.map((json) => PackageModel.fromJson(json)).toList();
  }
}

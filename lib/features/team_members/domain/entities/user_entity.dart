class CoordinatesEntity {
  final double lat;
  final double lng;

  CoordinatesEntity({required this.lat, required this.lng});
}

class AddressEntity {
  final String address;
  final String city;
  final String state;
  final String stateCode;
  final String postalCode;
  final CoordinatesEntity coordinates;
  final String country;

  AddressEntity({
    required this.address,
    required this.city,
    required this.state,
    required this.stateCode,
    required this.postalCode,
    required this.coordinates,
    required this.country,
  });
}

class CompanyEntity {
  final String title;
  CompanyEntity({required this.title});
}

class UserEntity {
  final int id;
  final String firstName;
  final String lastName;
  final String image;
  final CompanyEntity company;

  UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.company,
  });
} 
 
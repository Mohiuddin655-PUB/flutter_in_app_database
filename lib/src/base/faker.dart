import 'dart:math';

const List<String> _kUsernames = [
  'john_doe',
  'emma_smith',
  'mike_jones',
  'lisa_wong',
  'peter_brown',
  'sarah_carter',
  'james_taylor',
  'sophia_clark',
  'daniel_white',
  'olivia_adams'
];

const List<String> _kDomains = [
  'example.com',
  'test.com',
  'demo.com',
  'gmail.com',
  'yahoo.com',
  'hotmail.com',
  'outlook.com'
];

const List<String> _kCountries = [
  'USA',
  'Canada',
  'UK',
  'Australia',
  'Germany',
  'France',
  'Japan',
  'Brazil',
  'China',
  'India'
];

const List<String> _kPhotos = [
  'https://example.com/photos/photo1.jpg',
  'https://example.com/photos/photo2.jpg',
  'https://example.com/photos/photo3.jpg',
  'https://example.com/photos/photo4.jpg',
  'https://example.com/photos/photo5.jpg'
];

abstract class Faker {
  Faker._();

  factory Faker.user({
    List<String> usernames = _kUsernames,
    List<String> domains = _kDomains,
    List<String> countries = _kCountries,
    List<String> photos = _kPhotos,
  }) {
    return UserFaker(
      usernames: usernames,
      domains: domains,
      countries: countries,
      photos: photos,
    );
  }

  List<Map<String, dynamic>> generate(int length);
}

class UserFaker extends Faker {
  final List<String> usernames;
  final List<String> domains;
  final List<String> countries;
  final List<String> photos;

  UserFaker({
    this.usernames = _kUsernames,
    this.domains = _kDomains,
    this.countries = _kCountries,
    this.photos = _kPhotos,
  }) : super._();

  static UserFaker? _i;

  static UserFaker get i => _i ??= UserFaker();

  static Random? _r;

  static Random get _random => _r ??= Random();

  static int get age => _random.nextInt(50) + 20;

  static String get email {
    return '$username@${i.domains[_random.nextInt(i.domains.length)]}';
  }

  static String get username {
    return i.usernames[_random.nextInt(i.usernames.length)];
  }

  static String get country {
    return i.countries[_random.nextInt(i.countries.length)];
  }

  static String get photoUrl {
    return i.photos[_random.nextInt(i.photos.length)];
  }

  static List<Map<String, dynamic>> get users => generateUsers(100);

  static List<Map<String, dynamic>> generateUsers(int length) {
    return i.generate(length);
  }

  @override
  List<Map<String, dynamic>> generate(int length) {
    List<Map<String, dynamic>> data = [];
    final random = Random();
    for (int i = 0; i < length; i++) {
      String username = usernames[random.nextInt(usernames.length)];
      String email = '$username@${domains[random.nextInt(domains.length)]}';
      int age = random.nextInt(50) + 20;
      String country = countries[random.nextInt(countries.length)];
      String photoUrl = photos[random.nextInt(photos.length)];
      data.add({
        'username': username,
        'email': email,
        'age': age,
        'country': country,
        'photoUrl': photoUrl,
      });
    }
    return data;
  }
}

import 'package:findfood_app/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cloudinary photos are fetched at the size they are shown', () {
    const original = 'https://res.cloudinary.com/demo/image/upload/v17/findfood/menu/jollof.jpg';
    expect(ApiService.sizedImage(original, width: 400),
        'https://res.cloudinary.com/demo/image/upload/q_auto,c_limit,w_400/v17/findfood/menu/jollof.jpg');
    // Without a width, or for other hosts, nothing changes.
    expect(ApiService.sizedImage(original), original);
    expect(ApiService.sizedImage('https://lh3.googleusercontent.com/a/photo', width: 100),
        'https://lh3.googleusercontent.com/a/photo');
    // Never transformed twice.
    final once = ApiService.sizedImage(original, width: 400);
    expect(ApiService.sizedImage(once, width: 900), once);
  });
}

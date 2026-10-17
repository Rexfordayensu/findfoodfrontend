import 'package:findfood_app/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restaurants type prices in cedis', () {
    expect(parseCedis('50'), 5000);
    expect(parseCedis('45.50'), 4550);
    expect(parseCedis('45.5'), 4550);
    expect(parseCedis(' 12 '), 1200);
    expect(parseCedis('GH₵ 1,200'), 120000);
    expect(parseCedis('GHS 30'), 3000);
    expect(parseCedis('0.99'), 99);
  });

  test('anything that is not a price is refused', () {
    expect(parseCedis(''), isNull);
    expect(parseCedis('0'), isNull);
    expect(parseCedis('abc'), isNull);
    expect(parseCedis('45.505'), isNull, reason: 'pesewas have two places');
    expect(parseCedis('-5'), isNull);
    expect(parseCedis('4.5.0'), isNull);
  });

  test('saved prices come back as cedis in the edit form', () {
    expect(cedisInput(5000), '50');
    expect(cedisInput(4550), '45.50');
    expect(cedisInput(99), '0.99');
    expect(parseCedis(cedisInput(4550)), 4550);
  });
}

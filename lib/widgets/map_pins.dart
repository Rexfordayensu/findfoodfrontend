import 'dart:math' as math;

/// What a pin on a FindFood map stands for.
enum PinKind { shop, home, rider }

/// One point on a map: the restaurant, the drop-off or a rider.
class MapPin {
  final String id;
  final PinKind kind;
  final double lat, lng;
  final String? label;

  /// For riders: false when the position is a few minutes old (drawn grey).
  final bool live;

  const MapPin({
    required this.id,
    required this.kind,
    required this.lat,
    required this.lng,
    this.label,
    this.live = true,
  });

  MapPin at(double lat, double lng) =>
      MapPin(id: id, kind: kind, lat: lat, lng: lng, label: label, live: live);
}

/// Rough travel distance in km (straight line, stretched for real roads),
/// the same estimate the delivery fee uses.
double travelKm(double lat1, double lng1, double lat2, double lng2) {
  const radius = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dp = rad(lat2 - lat1), dl = rad(lng2 - lng1);
  final a = math.pow(math.sin(dp / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dl / 2), 2);
  return 2 * radius * math.asin(math.sqrt(a)) * 1.3;
}

/// Minutes for a rider to cover [km] in city traffic (about 20 km/h).
int travelMinutes(double km) => math.max(1, (km / 20 * 60).ceil());

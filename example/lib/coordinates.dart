import 'utils/strings.dart';
import 'utils/numbers.dart';

class Coordinates {
  String latitude;
  String longitude;

  Coordinates({
    this.latitude = Strings.noLatitude,
    this.longitude = Strings.noLongitude,
  });

  void setCoordinates(Map<dynamic, dynamic> snapshotData) {
    if (!snapshotData.containsKey(Strings.status)) {
      latitude = snapshotData[Strings.latitude]
          .toStringAsFixed(Numbers.numberCoordinates);
      longitude = snapshotData[Strings.longitude]
          .toStringAsFixed(Numbers.numberCoordinates);
    } else {
      latitude = Strings.noLatitude;
      longitude = Strings.noLongitude;
    }
  }
}

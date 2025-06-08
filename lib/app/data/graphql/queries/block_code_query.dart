class BlockCodeQuery {

  static String blockCode = r'''
    query	GeoData($latitude: Float!, $longitude: Float!) {
      geoData(latitude: $latitude, longitude: $longitude) {
        blockCode
        region
        zone
        area
      }
    }
  ''';
}
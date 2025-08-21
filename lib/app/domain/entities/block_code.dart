class BlockCode {
  final String blockCode;
  final String region;
  final String zone;
  final String area;


  BlockCode({
    required this.blockCode,
    required this.region,
    required this.zone,
    required this.area,
  });

  factory BlockCode.fromJson(Map<String, dynamic> json) {
    return BlockCode(
        blockCode: json['blockCode'] ?? '',
        region: json['region'] ?? '',
        zone: json['zone'] ?? '',
        area: json['area'] ?? ''
    );
  }

  @override
  String toString() {
    return 'BlockCode(blockCode: $blockCode, region: $region, zone: $zone, area: $area)';
  }
}
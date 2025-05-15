class BlockCode {
  final String blockCode;
  final String region;
  final String zone;


  BlockCode({
    required this.blockCode,
    required this.region,
    required this.zone,
  });

  factory BlockCode.fromJson(Map<String, dynamic> json) {
    return BlockCode(
        blockCode: json['blockCode'] ?? '',
        region: json['region'] ?? '',
        zone: json['zone'] ?? ''
    );
  }

  @override
  String toString() {
    return 'BlockCode(blockCode: $blockCode, region: $region, zone: $zone)';
  }
}
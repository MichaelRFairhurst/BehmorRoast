import 'package:freezed_annotation/freezed_annotation.dart';

part 'bean.freezed.dart';
part 'bean.g.dart';

enum Continent {
  africa,
  southAmerica,
  centralAmerica,
  asia,
  indonesia,
  other,
}

@Freezed()
class Bean with _$Bean {
  const factory Bean({
    @JsonKey(ignore: true) String? id,
    required String name,
    required String ownerId,
    @Default(false) bool archived,
  }) = _Bean;

  factory Bean.fromJson(Map<String, dynamic> json) => _$BeanFromJson(json);
}

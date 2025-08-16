class BaseResponse<T> {
  final bool success;
  final String? message;
  final int? code;
  final T? data;

  BaseResponse({
    required this.success,
    this.message,
    this.code,
    this.data,
  });

  factory BaseResponse.fromJson(
      Map<String, dynamic> json, {
        T Function(Object? json)? dataParser,
      }) {
    return BaseResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String?,
      code: json['code'] is int ? json['code'] as int : null,
      data: dataParser != null ? dataParser(json['data']) : null,
    );
  }
}

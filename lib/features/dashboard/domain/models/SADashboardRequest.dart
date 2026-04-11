import 'dart:convert';

class SADashboardRequest {
  String? flsId;

  SADashboardRequest({
    this.flsId,
  });

  factory SADashboardRequest.fromRawJson(String str) => SADashboardRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SADashboardRequest.fromJson(Map<String, dynamic> json) => SADashboardRequest(
    flsId: json["flsId"],
  );

  Map<String, dynamic> toJson() => {
    "flsId": flsId,
  };
}

library datahandling;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataHandlerResponse<T> {
  int code;
  bool success;
  T content;
  bool isJson;
}

abstract class DataSource {
  Future<DataHandlerResponse> getAsync(String source,
      {Map<String, dynamic> headers});
  Future<DataHandlerResponse> postAsync(String source,
      {@required Map<String, dynamic> body, Map<String, dynamic> headers});
  Future<DataHandlerResponse> putAsync(String source,
      {@required Map<String, dynamic> body, Map<String, dynamic> headers});
  Future<DataHandlerResponse> deleteAsync(String source,
      {Map<String, dynamic> headers});
}

class HttpRestClient implements DataSource {
  static final HttpRestClient _instance = HttpRestClient._internal();
  factory HttpRestClient() => _instance;
  HttpRestClient._internal();

  @override
  Future<DataHandlerResponse> getAsync(String source,
      {Map<String, dynamic> headers}) async {
    if (headers == null) headers = _setDefaultHeaders();

    var r = await http.get(source, headers: headers);
    return _processResponse(r);
  }

  @override
  Future<DataHandlerResponse> postAsync(String source,
      {@required Map<String, dynamic> body,
      Map<String, dynamic> headers}) async {
    if (headers == null) headers = _setDefaultHeaders();

    var r = await http.post(source, headers: headers, body: json.encode(body));
    return _processResponse(r);
  }

  @override
  Future<DataHandlerResponse> putAsync(String source,
      {@required Map<String, dynamic> body,
      Map<String, dynamic> headers}) async {
    if (headers == null) headers = _setDefaultHeaders();

    var r = await http.put(source, body: json.encode(body), headers: headers);
    return _processResponse(r);
  }

  @override
  Future<DataHandlerResponse> deleteAsync(String source,
      {Map<String, dynamic> headers}) async {
    if (headers == null) headers = _setDefaultHeaders();

    var r = await http.delete(source, headers: headers);
    return _processResponse(r);
  }

  Map<String, dynamic> _setDefaultHeaders() =>
      {"Content-Type": "application/json"};

  DataHandlerResponse _processResponse(http.Response response) {
    var headers = response.headers;
    var res = DataHandlerResponse();
    res.isJson = true;

    if (headers['Content-Type'] == "application/json") {
      res.success = _statusChecking(response);
      res.code = response.statusCode;

      if (res.success) {
        res.content = json.decode(response.body);
      } else {
        // set error in content
        if (response.body != null) {
          res.content = json.decode(response.body);
        } else {
          res.content = response.reasonPhrase;
          res.isJson = false;
        }
      }
    } else {
      res.content = response.body;
      res.isJson = false;
    }

    return res;
  }

  bool _statusChecking(http.Response response) {
    if (!((response.statusCode < 200) ||
        (response.statusCode >= 300) ||
        (response.body == null))) {
      return true;
    }
    return false;
  }
}

import 'package:flutter/foundation.dart';

const devHostUrl = 'http://192.168.0.43:8000';
const mainHostUrl = 'https://cp.i-teach.uz';

const hostUrl = kDebugMode ? devHostUrl : mainHostUrl;
// const hostUrl = mainHostUrl;

const apiVersion = 2;

const baseApiUrl = '$hostUrl/api/v$apiVersion/';

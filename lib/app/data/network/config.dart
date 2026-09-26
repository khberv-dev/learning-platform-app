import 'package:flutter/foundation.dart';

const devHostUrl = 'http://172.20.10.8:8000';
const mainHostUrl = 'https://cp.i-teach.uz';

const hostUrl = kDebugMode ? devHostUrl : mainHostUrl;
// const hostUrl = mainHostUrl;

const apiVersion = 2;

const baseApiUrl = '$hostUrl/api/v$apiVersion/';

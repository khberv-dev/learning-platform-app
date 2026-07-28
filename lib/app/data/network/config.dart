import 'package:flutter/foundation.dart';

const devHostUrl = 'http://169.254.38.122:8000';
const mainHostUrl = 'https://cp.i-teach.uz';

const hostUrl = kDebugMode ? devHostUrl : mainHostUrl;

const baseApiUrl = '$hostUrl/api/';
const baseCdnUrl = '$hostUrl/public';

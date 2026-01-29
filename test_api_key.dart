import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  const storage = FlutterSecureStorage();
  await storage.write(
    key: 'usda_api_key',
    value: 'TTIlwNUKcd28AV8y9JZbsmqGHtAabSo8J7G9nkgc',
  );
  print('API 키가 설정되었습니다.');
}

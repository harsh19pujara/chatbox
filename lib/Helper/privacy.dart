import 'package:encrypt/encrypt.dart';

class MessagePrivacy {
  static Encrypted? encrypted;
  static String key = "Kya thi lauv 32 bit ne key he...";

  static String encryption(String plainText) {
    final cipherKey = Key.fromUtf8(key);
    final encryptionService = Encrypter(AES(cipherKey, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(key.substring(0,16));
    final result = encryptionService.encrypt(plainText, iv: initVector);
    print("encrypted  " + result.base64);
    return result.base64;
  }

  static decryption(String encryptedText) {
    final cipherKey = Key.fromUtf8(key);
    final encryptionService = Encrypter(AES(cipherKey, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(key.substring(0, 16));
    final result = encryptionService.decrypt(Encrypted.from64(encryptedText), iv: initVector);
    print("decrypted  " + result);
    return result;
  }
}

import 'package:encrypt/encrypt.dart' as encrypt;

class Encryption {
  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static encryptAES(plainText) {
    return encrypter.encrypt(plainText, iv: iv);
  }

  static decryptAES(cipherText) {
    return encrypter.decrypt(cipherText, iv: iv);
  }
}

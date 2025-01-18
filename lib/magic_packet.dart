import 'dart:typed_data';

class MagicPacket{
  static Uint8List create(String mac){
    List<String> macParts = mac.split(':');
    List<int> macBytes = macParts.map((part) => int.parse(part, radix: 16)).toList();
    Uint8List magicPacket = Uint8List(6 + 16 * macBytes.length);
    for (int i = 0; i < 6; i++) {
      magicPacket[i] = 0xFF;
    }
    for(int i=0; i<16; i++){
      magicPacket.setRange(6+i * macBytes.length, 6+(i+1)*macBytes.length, macBytes);
    }
    return magicPacket;
  }
}
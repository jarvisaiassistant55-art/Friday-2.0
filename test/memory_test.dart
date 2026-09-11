import 'package:flutter_test/flutter_test.dart';
import 'package:friday_2_0/memory/memory_manager.dart';
void main(){test('memory manager starts empty',()async{final m=MemoryManager();await m.load();expect(m.items,isEmpty);});}

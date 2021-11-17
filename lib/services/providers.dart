import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = StateProvider<String>((_) => 'member_id_A');
final targetProvider = StateProvider<String>((_) => '');

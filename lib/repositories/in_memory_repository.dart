import 'repository.dart';

class InMemoryRepository<T> implements Repository<T> {
  final List<T> _items = [];

  @override
  void add(T item) {
    _items.add(item);
  }

  @override
  List<T> getAll() {
    return List<T>.unmodifiable(_items);
  }

  @override
  void remove(T item) {
    _items.remove(item);
  }

  void replaceAll(Iterable<T> items) {
    _items
      ..clear()
      ..addAll(items);
  }
}

abstract class Repository<T> {
  void add(T item);

  List<T> getAll();
  void remove(T item);
}

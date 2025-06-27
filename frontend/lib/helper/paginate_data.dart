import '../global/global_value.dart';

List<T> getPaginatedData<T>({
  required List<T> data,
  required int currentPage,
  int itemsPerPage = GlobalValue.nbrePerPage,
}) {
  int start = currentPage * itemsPerPage;
  int end = start + itemsPerPage;
  return data.sublist(
    start,
    end > data.length ? data.length : end,
  );
}

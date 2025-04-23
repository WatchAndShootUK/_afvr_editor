void sortList(List<Map<String, dynamic>> input) {
  input.sort(
    (a, b) => a['name'].toString().toLowerCase().compareTo(
      b['name'].toString().toLowerCase(),
    ),
  );
}

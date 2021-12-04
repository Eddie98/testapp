class Helpers {
  static findById(list, id) {
    var result = list.where((obj) => obj.id == id);
    return result.length > 0 ? result.first : null;
  }
}

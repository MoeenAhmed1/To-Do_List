class PhotoItemModel {
  String imgURL;
  String notes;
  DateTime dueDate;
  bool completionStatus;
  DateTime reminderAt;
  PhotoItemModel(
      {this.imgURL,
      this.notes,
      this.completionStatus,
      this.dueDate,
      this.reminderAt});
}

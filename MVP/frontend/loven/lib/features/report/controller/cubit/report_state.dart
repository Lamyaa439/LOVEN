abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportSuccess extends ReportState {}

class ReportFailure extends ReportState {
  final String message;

  ReportFailure(this.message);
}

class ReportsLoaded extends ReportState {
  final List<dynamic> reports;

  ReportsLoaded(this.reports);
}
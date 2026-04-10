class PrayerModel {
  String fajr;
  String dhuhr;
  String asr;
  String maghrib;
  String isha;
  String date;
  String hijriDate;
  String hijriMonth;
  String hijriYear;

  PrayerModel({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
  });

factory PrayerModel.fromJsonApi(Map<String, dynamic> json) {
  final timings = json['timings'];
  final gregorian = json['date']['gregorian'];
  final hijri = json['date']['hijri'];

  String clean(String time) => time.split(" ").first;

  return PrayerModel(
    fajr: clean(timings["Fajr"]),
    dhuhr: clean(timings["Dhuhr"]),
    asr: clean(timings["Asr"]),
    maghrib: clean(timings["Maghrib"]),
    isha: clean(timings["Isha"]),
    date: gregorian['date'],
    hijriDate: hijri['day'],
    hijriMonth: hijri['month']['en'],
    hijriYear: hijri['year'],
  );
}

  factory PrayerModel.fromJsonDB(Map<String, dynamic> json) {
    return PrayerModel(
      fajr: json["fajr"],
      dhuhr: json["dhuhr"],
      asr: json["asr"],
      maghrib: json["maghrib"],
      isha: json["isha"],
      date: json["date"],
      hijriDate: json["hijriDate"],
      hijriMonth: json["hijriMonth"],
      hijriYear: json["hijriYear"],
    );
  }

  Map<String, dynamic> toJson() => {
    "Fajr": fajr,
    "Dhuhr": dhuhr,
    "Asr": asr,
    "Maghrib": maghrib,
    "Isha": isha,
    "date": date,
    "hijriDate": hijriDate,
    "hijriMonth": hijriMonth,
    "hijriYear": hijriYear,
  };
}

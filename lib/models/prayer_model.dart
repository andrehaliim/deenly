class PrayerModel {
    String fajr;
    String dhuhr;
    String asr;
    String maghrib;
    String isha;
    String date;

    PrayerModel({
        required this.fajr,
        required this.dhuhr,
        required this.asr,
        required this.maghrib,
        required this.isha,
        required this.date,
    });

    factory PrayerModel.fromJson(Map<String, dynamic> json) {
        final timings = json['timings'];
        final dateName = json['date']['readable'];
        return PrayerModel(
        fajr: timings["Fajr"],
        dhuhr: timings["Dhuhr"],
        asr: timings["Asr"],
        maghrib: timings["Maghrib"],
        isha: timings["Isha"],
        date: dateName,
    );
    }
    factory PrayerModel.fromJsonSaved(Map<String, dynamic> json) {
        return PrayerModel(
        fajr: json["Fajr"],
        dhuhr: json["Dhuhr"],
        asr: json["Asr"],
        maghrib: json["Maghrib"],
        isha: json["Isha"],
        date: json["date"],
    );
    }

    Map<String, dynamic> toJson() => {
        "Fajr": fajr,
        "Dhuhr": dhuhr,
        "Asr": asr,
        "Maghrib": maghrib,
        "Isha": isha,
        "date": date,
    };
}
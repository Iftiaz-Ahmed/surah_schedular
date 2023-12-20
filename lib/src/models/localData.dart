import 'package:localstorage/localstorage.dart';
import 'package:surah_schedular/src/models/formInputs.dart';
import 'package:surah_schedular/src/models/adhan.dart';


class LocalData {

  LocalData();

  Future<void> saveInfo(FormInputs formInputs, AdhanItem adhanItem, List<String> tasks, List azaanVolumes, var castDevice, bool isInputs) async {
    try {
      final LocalStorage storage = LocalStorage('surah_schedular.json');
      if (isInputs) await storage.setItem('formInputs', formInputs.toString());
      await storage.setItem('selectedAdhan', adhanItem);
      await storage.setItem('tasks', tasks);
      await storage.setItem('azaanVolumes', azaanVolumes);
      await storage.setItem('castDevice', castDevice);

    } catch (e) {}
  }

}

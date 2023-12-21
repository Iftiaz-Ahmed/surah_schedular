import 'package:localstorage/localstorage.dart';
import 'package:surah_schedular/src/models/formInputs.dart';
import 'package:surah_schedular/src/models/adhan.dart';


class LocalData {

  LocalData();

  Future<void> saveInfo(FormInputs formInputs, AdhanItem adhanItem, List<String> tasks, List azaanVolumes, var castDevice, String calledFrom) async {
    try {
      final LocalStorage storage = LocalStorage('surah_schedular.json');
      if (calledFrom == 'home') await storage.setItem('formInputs', formInputs.toString());
      if (calledFrom == 'settings') await storage.setItem('selectedAdhan', adhanItem);
      if (calledFrom == 'schedular') await storage.setItem('tasks', tasks);
      if (calledFrom == 'settings') await storage.setItem('azaanVolumes', azaanVolumes);
      if (calledFrom == 'cast') await storage.setItem('castDevice', castDevice);

    } catch (e) {}
  }

}

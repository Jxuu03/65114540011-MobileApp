import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'apiService.dart';

class TeamController extends GetxController {
  var team = <String>[].obs;
  var teamName = ''.obs;
  var members = <String>[].obs;
  final storage = GetStorage();
  final ApiService api = Get.find();

  @override
  void onInit() {
    super.onInit();

    team.value = List<String>.from(storage.read('team') ?? []);
    teamName.value = storage.read('teamName') ?? 'My Team';

    ever(team, (_) => storage.write('team', team));
    ever(teamName, (_) => storage.write('teamName', teamName.value));

    loadMembers();
  }

  void setTeamName(String name) => teamName.value = name;

  void loadMembers() async {
    final fetched = await api.fetchPokemons();
    members.value = fetched;
  }

  void toggleMember(String member) {
    if (team.contains(member)) {
      team.remove(member);
    } else if (team.length < 3) {
      team.add(member);
    } else {
      Get.snackbar("Limit Reached", "You can only select 3 members!");
    }
  }

  void removeMember(String member) {
    team.remove(member);
  }
}

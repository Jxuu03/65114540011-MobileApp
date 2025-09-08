import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'apiService.dart';

class TeamController extends GetxController {
  var team = <Map<String, String>>[].obs;     // selected team
  var teamName = ''.obs;
  var members = <Map<String, String>>[].obs;  // available pokemons
  final storage = GetStorage();
  final ApiService api = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();

    // Load saved team
    team.value = List<Map<String, String>>.from(
      storage.read('team') ?? [],
    );
    teamName.value = storage.read('teamName') ?? 'My Team';

    // Auto-save whenever team or teamName changes
    ever(team, (_) => storage.write('team', team));
    ever(teamName, (_) => storage.write('teamName', teamName.value));

    loadMembers();
  }

  void setTeamName(String name) => teamName.value = name;

  void loadMembers() async {
    final fetched = await api.fetchPokemons();
    members.value = fetched;
  }

  void toggleMember(Map<String, String> member) {
    if (team.contains(member)) {
      team.remove(member);
    } else if (team.length < 3) {
      team.add(member);
    } else {
      Get.snackbar("Limit Reached", "You can only select 3 members!");
    }
  }

  void removeMember(Map<String, String> member) {
    team.remove(member);
  }
}

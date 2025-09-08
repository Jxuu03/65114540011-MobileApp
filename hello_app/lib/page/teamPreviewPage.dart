import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/teamController.dart';

class TeamPreviewPage extends StatefulWidget {
  const TeamPreviewPage({super.key});

  @override
  State<TeamPreviewPage> createState() => _TeamPreviewPageState();
}

class _TeamPreviewPageState extends State<TeamPreviewPage> {
  final TeamController teamCtrl = Get.find();
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: teamCtrl.teamName.value);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Current Team")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editable Team Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Team Name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => teamCtrl.setTeamName(value),
            ),
            const SizedBox(height: 20),

            const Text(
              "Team Members:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // List of selected team members
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: teamCtrl.team.length,
                  itemBuilder: (context, index) {
                    final member = teamCtrl.team[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Image.network(
                          member['imageUrl']!,
                          width: 40,
                          height: 40,
                        ),
                        title: Text(
                          member['name']!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

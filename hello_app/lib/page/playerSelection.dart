import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/teamController.dart';
import 'teamPreviewPage.dart';

class TeamPage extends StatelessWidget {
  TeamPage({super.key});

  final TeamController teamCtrl = Get.put(TeamController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Team Member")),
      body: Column(
        children: [
          // Show Current Team
          Obx(
            () => Container(
              padding: const EdgeInsets.all(8),
              height: 100,
              color: Colors.grey[200],
              child: Row(
                children: [
                  // Scrollable chips
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: teamCtrl.team
                          .map(
                            (member) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Chip(
                                label: Text(member),
                                onDeleted: () => teamCtrl.removeMember(member),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  // Reset button on the right
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.red),
                    onPressed: () => teamCtrl.team.clear(),
                    tooltip: 'Reset Team',
                  ),
                ],
              ),
            ),
          ),

          // Reset Button
          const SizedBox(height: 10),

          // Navigate to preview screen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => Get.to(() => TeamPreviewPage()),
              child: const Text("Preview Team"),
            ),
          ),

          const Divider(),

          // Display Member List
          Expanded(
            child: Obx(() {
              final members = teamCtrl.members;
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return Obx(() {
                    final isSelected = teamCtrl.team.contains(member);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(member),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color: isSelected ? Colors.green : Colors.grey,
                        ),
                        onTap: () => teamCtrl.toggleMember(member),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

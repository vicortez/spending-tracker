import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/models/domain/domain_state.dart';

class ManageDomainsPage extends StatefulWidget {
  const ManageDomainsPage({super.key});

  @override
  State<ManageDomainsPage> createState() => _ManageDomainsPageState();
}

class _ManageDomainsPageState extends State<ManageDomainsPage> {
  final _currentDomainNameTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FocusNode myFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var domainState = context.watch<DomainState>();
    var categoryState = context.watch<CategoryState>();

    var domains = domainState.domains;
    domains.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false; // Prevents the automatic pop of the current
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text("Manage domains"),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        controller: _currentDomainNameTextController,
                        decoration: const InputDecoration(hintText: 'New domain'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Domain must have a name";
                          }
                          bool isDuplicate = domains.any((dom) => dom.name == value);
                          if (isDuplicate) {
                            return "Domain already exists";
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          if (_formKey.currentState!.validate()) {
                            submitDomain();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Domain added')),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        submitDomain();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Domain added')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_outlined),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: SelectionArea(
              child: ListView(
                children: [
                  for (var domain in domains)
                    Card(
                      child: ListTile(
                        title: Text(domain.name),
                        trailing: IconButton(
                          onPressed: () {
                            if (canRemoveDomain(domain.id, categoryState)) {
                              domainState.removeDomain(domain.id);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Can\'t delete domain. Delete categories using it')),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  void submitDomain() {
    String currentText = _currentDomainNameTextController.text;
    var domainState = context.read<DomainState>();
    domainState.addDomain(currentText);
    _currentDomainNameTextController.clear();
    myFocusNode.requestFocus();
  }

  bool canRemoveDomain(int domId, CategoryState categoryState) {
    return !categoryState.existsCategoryWithDomain(domId);
  }
}

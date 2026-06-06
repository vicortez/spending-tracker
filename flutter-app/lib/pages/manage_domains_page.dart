import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/utils/toast_utils.dart';

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
    var domainProvider = context.watch<DomainProvider>();
    var categoryProvider = context.watch<CategoryProvider>();

    var domains = domainProvider.domains;
    domains.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false; // Prevents the automatic pop of the current
      },
      child: Scaffold(
        appBar: AppBar(leading: const BackButton(), title: const Text('Manage domains')),
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                            return 'Domain must have a name';
                          }
                          bool isDuplicate = domainProvider.existsDomainWithName(value);
                          if (isDuplicate) {
                            return 'Domain already exists';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) async {
                          if (_formKey.currentState!.validate()) {
                            await submitDomain();
                            if (mounted) {
                              showToast(context, 'Domain added');
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await submitDomain();
                        if (mounted) {
                          showToast(context, 'Domain added');
                        }
                      }
                    },
                    icon: const Icon(Icons.add_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SelectionArea(
                child: ListView(
                  children: [
                    for (var domain in domains)
                      Card(
                        child: ListTile(
                          title: Text(domain.name),
                          trailing: IconButton(
                            onPressed: () async {
                              if (canRemoveDomain(domain.id, categoryProvider)) {
                                await domainProvider.removeDomain(domain.id);
                              } else {
                                if (mounted) {
                                  showToast(
                                    context,
                                    'Can\'t delete domain. Delete categories using it',
                                    duration: const Duration(seconds: 4),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitDomain() async {
    String currentText = _currentDomainNameTextController.text;
    var domainProvider = context.read<DomainProvider>();
    await domainProvider.addDomain(currentText);
    _currentDomainNameTextController.clear();
    myFocusNode.requestFocus();
  }

  bool canRemoveDomain(int domId, CategoryProvider categoryProvider) {
    return !categoryProvider.existsCategoryWithDomain(domId);
  }
}

// Global state
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/models/domain/domain.dart';

class DomainState extends ChangeNotifier {
  List<Domain> domains = [];
  SharedPreferences? prefs;
  String persistName = Domain.PERSIST_NAME;

  void setDomains(List<Domain> domains, {bool syncStorage = true}) {
    this.domains = domains;
    notifyListeners();
    if (syncStorage && prefs != null) {
      updateLocalStorage();
    }
  }

  void setDataFromImport(dynamic data) {
    dynamic value = data ?? "[]";
    updateLocalStorageFromRawData(value);
    loadFromLocalStorage(prefs!);
  }

  void updateLocalStorageFromRawData(dynamic data) {
    prefs?.setString(persistName, data);
  }

  bool updateDomain(int id, String newName) {
    Domain? domain = domains.firstWhereOrNull((dom) => dom.id == id);
    if (domain == null) {
      return false;
    }

    domain.name = newName;

    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
    return true;
  }

  void loadFromLocalStorage(SharedPreferences prefs) {
    this.prefs = prefs;
    final String? domainsStr = prefs?.getString(persistName);
    if (domainsStr != null) {
      domains = Domain.decodeMany(domainsStr);
      notifyListeners();
    }
  }

  void addDomain(String name) {
    Domain domain = Domain(id: getNextId(), name: name);
    domains.add(domain);

    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void removeDomain(int id) {
    domains.removeWhere((dom) => dom.id == id);
    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void removeALl() {
    domains.clear();
    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void updateLocalStorage() {
    prefs?.setString(persistName, Domain.encodeMany(domains));
  }

  int getNextId() {
    if (domains.isEmpty) {
      return 1;
    } else {
      return domains.map((el) => el.id).reduce(max) + 1;
    }
  }
}

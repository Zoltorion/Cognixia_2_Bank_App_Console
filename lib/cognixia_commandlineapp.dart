import 'dart:io';

final List<Account> _accounts = [];
final List<User> _users = [];
bool _isPopulated = false;

void populateCustomers() {
  if (!_isPopulated) {
    _users.add(Customer('johndoe22', 'hunter2', 1, 'John Doe'));
    _users.add(Customer('jane32', 'password1', 2, 'Jane Smith'));
    _isPopulated = true;
  }
}

void welcome() {
  print('Welcome to ABC Digital Bank');
}

LoginResults login() {
  print('Please enter username and password, space separated');

  String input = stdin.readLineSync() ?? '';
  List<String> splitInput = input.split(' ');
  String username = splitInput[0];
  String password = splitInput[1];

  if (username == 'admin' && password == 'admin123') {
    return LoginResults('admin', true);
  }

  for (User user in _users) {
    if (username == user.username && password == user.password) {
      return LoginResults(user.username, true);
    }
  }

  return LoginResults(username, false);
}

void customerDashboard(String username) {
  Customer? customer;
  for (User user in _users) {
    if (username == user.username && user.runtimeType == Customer) {
      customer = user as Customer;
    }
  }
  if (customer == null) {
    print('Error: user not found');
    return;
  }

  print('\nWelcome customer, ${customer.username}');

  while (true) {
    //switch case to present options: See his account, read account-balance
    print(
      '------------------------------------------------\n'
      'Please select an option to proceed:\n'
      '1) Create Account\n'
      '2) View All Accounts\n'
      '3) Deposit\n'
      '4) Withdraw\n'
      '5) Transfer\n'
      '6) Close Account\n'
      '7) Exit\n',
    );

    String input = stdin.readLineSync() ?? '';

    if (input.isEmpty || input.length > 1) {
      print('Invalid input\n');
      continue;
    }
    int option = int.parse(input);
    switch (option) {
      case 1:
        createAccount(customer);
      case 2:
        viewAllAccounts(customer);
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      default:
        print('Invalid input\n');
        continue;
    }
  }
}

void createAccount(Customer customer) {
  while (true) {
    print('Please confirm your name');
    String input = stdin.readLineSync() ?? '';

    if (input != customer.name) {
      print('Invalid info, please try again');
      continue;
    }

    break;
  }

  while (true) {
    print(
      '\nEnter 1 to create a Checking account or 2 to create a Savings account',
    );
    String input = stdin.readLineSync() ?? '';
    if (input.isEmpty || input.length > 1) {
      print('Invalid input\n');
      continue;
    }

    int inputInt = int.parse(input);
    switch (inputInt) {
      case 1:
        CheckingAccount account = CheckingAccount(
          Account.getNextAccountID(),
          customer,
          0,
        );
        customer.addAccount(account);
        _accounts.add(account);
        print('\nCreated Checking account\n');
        return;
      case 2:
        SavingsAccount account = SavingsAccount(
          Account.getNextAccountID(),
          customer,
          0,
        );
        customer.addAccount(account);
        _accounts.add(account);
        print('\nCreated Savings account\n');
        return;
      default:
        print('Invalid input\n');
        continue;
    }
  }
}

void viewAllAccounts(Customer customer) {
  print('\nAll active accounts:');
  if (customer.accounts.isEmpty) {
    print('No accounts created');
  }
  for (Account account in customer.accounts) {
    print('Account ID: ${account.accountID} | Balance: ${account.balance}');
  }
}

void adminDashboard() {
  print('Welcome Admin');
  //switch case to present option: See all customer, see all accounts, delete any account
}

class LoginResults {
  late String _username;
  late bool _isValid;

  LoginResults(this._username, this._isValid);

  String get username => _username;
  set username(value) => _username = value;

  bool get isValid => _isValid;
  set isValid(value) => _isValid = value;
}

abstract interface class ITransaction {
  void printReceipt();
}

class User {
  late String _username;
  late String _password;

  User(this._username, this._password);

  String get username => _username;
  set username(value) => _username = value;

  String get password => _password;
  set password(value) => _password = value;
}

class Customer extends User {
  late int _id;
  late String _name;
  late List<Account> _accounts;

  Customer(super._username, super._password, this._id, this._name) {
    _accounts = [];
  }

  int get id => _id;
  set id(value) => _id = value;

  String get name => _name;
  set name(value) => _name = value;

  List<Account> get accounts => _accounts;
  set accounts(value) => _accounts = value;

  void addAccount(Account account) {
    _accounts.add(account);
  }
}

class Admin extends User {
  late int _id;
  static const String _usernameStatic = 'admin';
  static const String _passwordStatic = 'admin123';

  Admin() : _id = -1, super(_usernameStatic, _passwordStatic);
}

abstract class Account {
  late final int _accountID;
  late final Customer _accountHolder;
  late double _balance;

  Account(this._accountID, this._accountHolder, this._balance);

  int get accountID => _accountID;
  set accountID(value) => _accountID = value;

  Customer get accountHolder => _accountHolder;
  set accountHolder(value) => _accountHolder = value;

  double get balance => _balance;
  set balance(value) => _balance = value;

  static int getNextAccountID() {
    return _accounts.isEmpty ? 1 : _accounts.last.accountID + 1;
  }

  void deposit(double amount) {
    _balance += amount;
  }

  void withdraw(double amount);
}

class CheckingAccount extends Account {
  late double _overdraftLimit;

  CheckingAccount(super._accountID, super._accountHolder, super._balance) {
    // default $100 overdraft limit (balance can go as low as -$100)
    _overdraftLimit = -100;
  }

  @override
  void withdraw(double amount) {
    if (_balance - amount < _overdraftLimit) {
      print(
        'This withdrawal is not allowed as you would exceed your overdraft limit',
      );
    } else {
      _balance -= amount;
      print('Withdrawal successful');
    }
  }
}

class SavingsAccount extends Account {
  late double _interestRate;

  SavingsAccount(super._accountID, super._accountHolder, super._balance) {
    _interestRate = 0.02; // default 2% interest rate
  }

  @override
  void withdraw(double amount) {
    if (_balance - amount < 100) {
      print(
        'This withdrawal is not allowed as it would bring your balance below \$100',
      );
    } else {
      _balance -= amount;
      print('Withdrawal successful');
    }
  }
}

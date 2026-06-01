import 'package:cognixia_commandlineapp/cognixia_commandlineapp.dart' as cli;

void main(List<String> arguments) {
  cli.populateCustomers();
  cli.welcome();

  while (true) {
    cli.LoginResults results = cli.login();
    if (!results.isValid) {
      print('Login failed, credentials invalid');
    } else if (results.username == 'admin') {
      cli.adminDashboard();
    } else {
      cli.customerDashboard(results.username);
    }
  }
}

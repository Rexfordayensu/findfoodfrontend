import 'package:findfood_app/screens/auth/google_oauth_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each Google sign-in failure is explained with what to do next', () {
    String say(String serverReason) => GoogleOAuthFlowService.displayErrorMessage(serverReason);
    expect(say('Invalid OAuth state parameter.'), contains('started twice'));
    expect(say('OAuth session expired or is invalid.'), contains('took too long'));
    expect(say('Google authentication service is unavailable right now.'), contains("couldn't confirm"));
    expect(say('This account has been suspended. Contact support.'), contains('suspended'));
    expect(say('Google account email is not verified.'), contains("isn't verified"));
    expect(say('Google sign-in was cancelled.'), 'Google sign-in was cancelled.');
    expect(say('Something new'), contains('sign in with email'));
  });
}

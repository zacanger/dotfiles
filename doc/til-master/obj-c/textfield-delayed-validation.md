# Delayed Validatation for NSTextField
NSTextFields can easily be wired to send api validation request when a user pauses typing using `performSelector` and `cancelPreviousPerformRequestsWithTarget`.

## Example

1) Create the validation method you want to be executed when the user pauses typing.
```objc
- (void)validateEmail {
  NSString *email = _emailInput.stringValue;
  NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
  NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailReg];

  // Verify email isn't empty and that it is an actual email address
  if (email.length > 0 && [emailTest evaluateWithObject:email]) {

    // Send the email string to the server to see if it is linked to a user account
    [[SomeAPIClient sharedClient] validateUserByEmail:email success:^(BOOL emailExists) {

      // Enabled a button if the email is valid
      [_someActionButton setEnabled:emailExists];

      // Turn the text red if the email doesnt belong to an existing user
      // And reset to dark gray if the user does exist
      if (emailExists) { [_emailInput setTextColor:[NSColor darkGrayColor]]; }
      else { [_emailInput setTextColor:[NSColor redColor]]; }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
      NSLog(@"Email Validation Error: %@", error);
    }];
  }
  else if (![emailTest evaluateWithObject:email]) {
    // Turn text red if not a valid email
    [_emailInput setTextColor:[NSColor redColor]];
  }
}
```

2) Implement controlTextDidChange method and ensure that your NSTextField's Delegate is attached to Files Owner.
```objc
- (void)controlTextDidChange:(NSNotification *)obj {
  // Ensure the notification object is the object you're validating
  if (obj.object == _emailInput) {
    // Reset color of field prior to validation
    [_emailInput setTextColor:[NSColor darkGrayColor]];

    // Ensure that your action button is disabled, until the validation occurs
    [_someActionButton setEnabled:NO];

    // Create a selector using the validation method created in step 1
    SEL validateEmail = @selector(validateEmail);

    // Cancel the previous validation selector
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:validateEmail object:nil];

    // Perform the validation after 0.5 seconds. Previous validation requests will be cancelled
    // by the previous line of code until the user pauses for greater 0.5 seconds
    [self performSelector:validateEmail withObject:nil afterDelay:0.5];
  }
}
```

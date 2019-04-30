# Auth0Example

Frontend Tech Challenge prepared by Phill Aitken for Laurent Parent and [Wellthon](http://www.wellthon.com).

See a live demo [here](https://youtu.be/QBt5-Dulbek).

## Choices
* [Auth0](http://www.auth0.com) presents two options out of the box: native and web. I sampled both flows and found that I preferred the native flow because with the web flow, iOS (for security reasons) forces the user to agree to the following message:

![Web Flow](http://www.whyiloveandrea.com/assets/auth0-web-flow-screenshot.png)

* This breaks the flow and looks _phishy_ to users, which will act as a barrier to entry.

## Problems
* Using the native flow, sign-up worked right away, but logging in kept failing, so I:
 1. Added `onError` callback to get more information. Simply got message `couldNotLogin`... not helpful.
 2. Searched for `couldNotLogin` in [Lock.swift](https://github.com/auth0/Lock.swift) code to get more info... wasn't helpful.
 3. Added a breakpoint to see where in `Lock` the error was happening... didn't go anywhere.
 4. Searched the documentation for way to enable logging. Luckily I found it. Had I not, I would have used a [web debugging proxy](https://www.charlesproxy.com/) to see if the network traffic could give me a hint.
 5. Found in the logs: `Grant type ‘password’ not allowed for the client.` 
 6. Found [this](https://community.auth0.com/t/error-grant-type-password-not-allowed-for-the-client-for-resource-owner-password-flow/6951) page in the Auth0 Community Forums which allowed me to solve the problem.

## Paths for improvement
* See all the `TODO` comments for places marked for improvement.
* Move much of the logic from the `MainViewController` into a management class.
* Improve flexibility of animations and UI.
* Allow user to make profile changes.
* Save credentials using `CloudKit` to sync credentials between user's many devices.


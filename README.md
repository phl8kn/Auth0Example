# Auth0Example

Frontend Tech Challenge prepared by Phill Aitken for Laurent Parent and [Wellthon](http://www.wellthon.com).

## Choices
* Auth0 present two options out of the box, native and web. I sampled both flows and found that I preferred the native flow because with the web flow, iOS (for security reasons) forces the user to agree to the following message:
![Web Flow](http://www.whyiloveandrea.com/assets/auth0-web-flow-screenshot.png)
* This breaks the flow and looks _phishy_ to users, which will act as a barrier to entry.

## Problems
1. Using the native flow, sign-up worked right away, but logging in kept failing.
* Added API `onError` to get more information. Simply got message `couldNotLogin`... not helpful.
* Searched for `couldNotLogin` in [Lock.swift](https://github.com/auth0/Lock.swift) code to get more info... wasn't helpful.
* Added breakpoint... wasn't helpful.
* Searched documentation for way to enable logging. Luckily I found it. Had I not, I would have used a [web debugging proxy](https://www.charlesproxy.com/) to see if the network traffic could give me a hint.
2. Found in the logs: `Grant type ‘password’ not allowed for the client.` 
3. Found [this](https://community.auth0.com/t/error-grant-type-password-not-allowed-for-the-client-for-resource-owner-password-flow/6951) page in the Auth0 Community Forums which allowed me to solve the problem.

## Paths for improvement
* See all the `TODO` comments for places marked for improvement.
* Move much of the logic from the `MainViewController` into a management class.
* Improve flexibility of animations.
* Allow user to make profile changes.
* Save credentials using `CloudKit` to sync credentials between user's many devices.


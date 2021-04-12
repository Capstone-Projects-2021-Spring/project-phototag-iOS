# Project overview
PhotoTag is a mobile application on both Android and iOS which is designed to eliminate time spent by the user searching in their gallery for a specific image. With PhotoTag, users will be able to attach keywords to their existing photos with suggested tags from an image processing API, or choose to add their own custom keywords. These keywords can be used to search through the image collection for a smaller subset, for less total time spent searching for the user. Options involving the tagging method are available to the user so that they can select whether they want their photos to be processed by an on-device image labeling API, or by making a connection to a specialized server and sending the photos for processing. Users may also create schedules so that photos taken within a specified time range are automatically tagged with certain phrases, as well as see all photos with location data on the map. 

# Feature List
* Manual user-entered tagging of photos
* Automatic tagging
  * On-device tagging using MLKit
  * Remote tagging using server
* Search photos by tag (using voice or text)
* Tag scheduling
* Map view

# Contributors
* Alex J St.Clair (Cross-platform, project leader)
* James Coolen (Android)
* Matthew Day (Android)
* Sebastian Tota (iOS, Git)
* Reed Ceniviva (Android)
* Ryan O' Connor (iOS)
* Tadeusz J Rzepka (Android, Git, Scrum-master)

***
# Testing Document
<https://tuprd.sharepoint.com/:x:/s/PhotoTag/ERevMYmlenpCgUyQsPsEZe4BNDv7zJY_jYF4JbRz6R4Shg?e=gB8asz>
***

# Instructions for buliding

**NOTE: The building process requires the user to build via XCode on an Apple computer. Please download the latest version of XCode if you do not already have it and continue the steps below. This process also only allows for usage of the app for a few days, at which point access to the app will be revoked. For this release, to continue using the application after this occurs, uninstall the application and repeat the steps below.**

1. Click the green "Code" button above, and select "Open in XCode".
2. Ensure that "main" is the branch checked out in the resulting pop-up.
3. Clone the repository into your XcodeProjects folder.
4. Open your terminal, and cd into your XcodeProjects directory, into the cloned directory. (ex. "cd XcodeProjects/project-phototag-iOS")
5. run the command "pod install". This may take a few minutes. 
7. Connect iPhone to computer running XCode via USB cable and prepare to run the app by doing the following:
    1. Unlock the phone and select "trust" on the pop-up.
    2. On your computer, open XCode and click the button on the top that says "any iOS device", and select your phone. 
    3. If necessary, open the left pane by clicking the top-left button and then the leftmost icon (project navigator), select PhotoTag under Targets, then select the "signing and capabilities" tab and change the development team to your own personal team. 
8. Click the play button in the top-left and allow XCode to build the application onto your iPhone. This will take slightly longer than the pod installation done in step 5. 
9. After this completes, a pop-up will occur in XCode because your phone has not explicitly trusted the developer. To do this, open Settings -> General -> Device Management -> Apple Development: ...
10. Click "Trust Apple Development: ...", and trust again in the resulting pop-up. 
    **NOTE**: The message that appears in this pop-up applies to any application downloaded using this method, including PhotoTag. With this being said, PhotoTag does not track any user interactions, and has read permissions to only the local photos on your device. 
12. PhotoTag should be on your home screen at this point. Back on your computer, you can click "ok" in the pop-up, leave the application, and unplug your phone from the computer. PhotoTag is now ready to use. 

***

# Starting Guide

When permission is granted to read local photos, and you log in successfully using an email/password or with Google, the application will load all of your photos into a gallery view. At this point, you may begin selecting photos and adding tags. In the settings page you will find an option to enable/disable auto-tagging, a feature where the application automatically processes your photos and applies searchable tags. PhotoTag offers two options for auto-tagging: on-device or server processing. On-device uses Google's ML Kit API, and server processing uses a more extensive library of photo labels for increased accuracy. 

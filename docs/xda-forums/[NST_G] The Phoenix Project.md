---
title: "[NST/G] The Phoenix Project"
source: "https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/"
author:
  - "[[nmyshkin]]"
published: 2024-05-28
created: 2025-08-18
description: "\"What is the Phoenix Project?\"It is an effort to provide a variety of options for the continued use of the Nook Simple Touch (and with Glowlight) after..."
tags:
---
#### nmyshkin

##### Recognized Contributor

**"What is the Phoenix Project?"**  
  
It is an effort to provide a variety of options for the continued use of the Nook Simple Touch (and with Glowlight) after the end-of-life action by B&N, June 2024.  
  
The project has three phases:  
  
1\. CWM backup images of registered devices running FW 1.2.2, not rooted, including the US and UK versions.  
2\. CWM backup images of registered devices running FW 1.2.2, rooted, with a heavily modified UI, additional reader options and much custom software.  
3\. CWM backup images of devices running FW 1.2.2 or 1.1.5, rooted, with the B&N system removed and replaced with with a heavily modified UI, various reader options and much custom software.  
  
**"Why bother with all this? Can't I just skip registration on an old device and use it as-is?"**  
  
You can certainly do that, but I do not recommend it. The device (with the B&N software intact) was designed to function with occasional contact with the B&N servers, especially during initialization. If that contact is frustrated (no registration) the system expends a lot of time (read: battery power) trying to sort out the lack of contact. My experiments with the same device registered, and not registered (skipped OOBE) show a dramatic difference in battery charge life. Starting with a full charge and left to idle for 7 days, a registered device dropped to 89%. A device which was not registered was dead by the time I checked it after 7 days. So if you want to use the B&N stuff (reader, library, dictionary) as it was intended (minus purchasing and downloading ebooks from B&N), the device needs to be registered. Hence phase 1 of this project.  
  
Some people may like the basic B&N system but also have a desire for more capability in the device (read other formats, etc.). And some of those "some" may go on to root the device and customize to their liking. Others may be less sure of their hacking skills or simply don't want to get their hands dirty. That's what phase 2 of this project is for. It's a heavily customized e-reader which uses the basic B&N system (it's registered) but also includes additional reader options and many new features. It may not suit everyone.  
  
Properly removing the B&N system and installing alternative apps (phase 3) gives power consumption similar to a registered device. Without the B&N system, alternative readers, dictionaries, etc., become a necessity. I have created 4 options which are the same except for the principal reader app. I've used reader apps which have been frequently mentioned on the forum as worthy of use on the device. If you're looking for something other than B&N, one of these may suit you.  
  
**Getting your** **in a row**  
  
All of the magic depends on ClockworkMod (CWM). If you don't have a CWM card for the NST/G, making one is perhaps the most "difficult" thing you'll do for the project. I will guide you through that now. If you already have a card or don't need/want the hand-holding, take your prepared CWM card and move on to phases 1, 2, 3 and decide what might be the best fit for you.  
  
**Make a CWM card**  
  
1\. Not all microSDcards are created equal. The vast majority (unless defective) are fine for storage. A subset of these is better for creating bootable cards. I've always used SanDisk class 10 cards and have never had problems, but I have spent a lot of time trying to help others who are using whatever they had sitting around. If you have problems, it's almost always the card itself.  
2\. You will want at least a 1 GB sdcard for your CWM card so there will be room for backups. Backups for the stock system are about 240 MB while those for the custom systems are more than 300 MB.  
3\. Download the zip for either the [2 GB](https://www.mediafire.com/file/fll6rassbgez91v/sd_2gb_clockwork-rc2.zip/file) (must have a 2 GB card or larger) or [128 MB](https://www.mediafire.com/file/9jl7aiu1k04lafd/sd_128mb_clockwork-rc2.zip/file) (minimum 1 GB card) sdcard version. Unzip to reveal img file. If you do not already have some kind of disk imaging software and you are using Windows, download [win32diskimager](https://www.mediafire.com/file/stzqsp59ixln6z1/win32diskimager-v0.9-binary.zip/file) and unzip. The application runs directly from the.exe file in the folder and does not require installation.  
  
**Q.** Why are there two different versions of CWM?  
**A.** When someone creates a disk image (.img file) they are trying to make portable an exact copy of their card for others to reproduce. Sometimes this is because the formatting on the card has special flags set to make it bootable. The actual files for CWM take up very little space (about 4.6 MB), but there should be room on a card for flashable zips, backups, etc. "Room" means empty space. That will be part of the image. How big a file do you want someone to have to download which is mostly empty space? Probably the smallest possible, without a lot of empty space. Hence the two sizes, although without further efforts the 128 MB image is not useful at all for what we want to do. But we can fix that. Keep in mind that a larger image takes longer to write to the card.  
  
4\. Insert the sdcard you want to use for CWM into the slot on your PC.  
5\. Run win32diskimager. To do so, right-click on the \*.exe file in the folder you unzipped and choose "Run as Administrator". *This appears to be important, so don't just double-click on the \*.exe file and hope for the best*.  
![win32diskimager1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/win32diskimager1.png "win32diskimager1.png")  
Check to be sure the disk listed is the same letter as the sdcard in the slot. Navigate to the.img file you downloaded for CWM and then click on "Write".  
![win32diskimager2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/win32diskimager2.png "win32diskimager2.png")  
  
After the image is written the card will probably have a name like "boot". I suggest you rename it "CWM" just so it's obvious when you put it in your PC what you're looking at.  
  
If you used the 2 GB image on a larger card and don't care about recovering additional space, you can skip what's next and go on to #6. If you used the 128 MB image on a 1 GB card or larger (or used the 2 GB and do care about the extra space), keep reading.  
  
When the disk image is written the sdcard is defacto partitioned. The primary partition is either 2 GB or 128 MB, depending on which version you downloaded. The rest of the space is "unallocated" (wasted). Windows will not see this and will say your card is either 2 GB or 128 MB after writing the image. To reclaim the entire card for use (adding zips to flash, storing backups, for example) download [MiniTool Partition Wizard](https://www.mediafire.com/file/0dax0o5yj7epxjz/pw102-free.exe/file). Install and run with your CWM sdcard in the PC slot (do not update the program if asked to do so).  
![partitionwizard1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard1.png "partitionwizard1.png")  
At the lower part of the screen you will see the sdcard listed (compare drive letter with what Windows has assigned to your sdcard--write this letter down now, just in case).  
![partitionwizard2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard2.png "partitionwizard2.png")  
Right-click on the primary partition of the sdcard. Select "Extend" from the context menu.  
![partitionwizard3.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard3.png "partitionwizard3.png")  
  
Drag the resizing arrow all the way to the right so that the primary partition occupies the entire sdcard capacity. Click on OK.  
![partitionwizard4.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard4.png "partitionwizard4.png")  
On the main screen click on "Apply". Exit when done.  
![partitionwizard6.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard6.png "partitionwizard6.png")  
The sdcard is now fully usable with only a single partition. Do not click randomly on other stuff in the partition wizard. You could seriously mess up your PC hard drive if you do.  
  
Occasionally after repartitioning the card becomes invisible to Windows although it is fully functional. That can be easily fixed. In Windows Explorer click in the top menu "System" section on "Manage". A "Computer Management" window opens and there you want to click in the side bar on "Disk Management". Information about the various storage devices fills the panel. The sdcard is down at the bottom. In the image mine is OK, showing as drive "E". If you are doing this, it's because your drive letter is missing. Right-click on the box representing the drive and a context menu will open. Select "Change Drive Letter and Paths".  
![fixcard1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/fixcard1.png "fixcard1.png")  
Again, in my image the drive letter shows as "E", but yours will be missing (i.e., the box is blank). Click on "Add".  
![fixcard2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/fixcard2.png "fixcard2.png")  
Select the first option,"Assign the following drive letter" and then choose from the drop-down whatever the drive letter was for the sdcard before these evil things befell you. "OK" your way out of the various windows. You'll see your sdcard again represented in Windows Explorer.  
  
6\. We're going to add a couple of folders to the CWM card that would normally be generated when you make your first backup. By adding them now we can save some card swapping. Viewing the contents of your CWM card on your PC, make a folder on the card called "clockworkmod". Inside that folder make another folder called "backup". Be sure to get those folder names correct.  
![cwm_files1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/cwm_files1.png "cwm_files1.png")  
  
![cwm_files2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/cwm_files2.png "cwm_files2.png")  
  
Done! I promise you, that was the hardest part.  
  
**Acknowledgements**  
  
It's been over 10 years since the Nook Simple Touch arrived on the scene. Many of the people who did important work on the device are long gone from the forum (with one exception) and in some cases long gone from XDA. We still use their discoveries, insights and creations all the time and it seems right to give them the credit that is due for their efforts. I know this list won't have everyone in it (I'll add more when I realize I've left someone out!), but I feel a personal debt to these and more. None of this could have been done without them.  
  
[@jeff\_kz](https://xdaforums.com/m/4935755/), [@mali100](https://xdaforums.com/m/499922/), [@verygreen](https://xdaforums.com/m/3654172/), [@marspeople](https://xdaforums.com/m/4163417/), [@Renate](https://xdaforums.com/m/4474482/), [@wskelly](https://xdaforums.com/m/3101826/), [@pinguy1982](https://xdaforums.com/m/4636254/), [@ros87](https://xdaforums.com/m/3047119/), [@nivieru](https://xdaforums.com/m/5548765/), [@Yura80](https://xdaforums.com/m/2711583/), [@similardilemma](https://xdaforums.com/m/3893866/), [@Ahmed hamouda](https://xdaforums.com/m/4514149/) and the many patient people at the Google Groups Tasker forum

Last edited:

Reactions:[Kramar111, bisbal, ukros and 3 others](https://xdaforums.com/posts/89533446/reactions)

#### nmyshkin

##### Recognized Contributor

**The Phoenix Project--Phase 1--The stock system, registered, unrooted  
![nst_stock.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/nst_stock.png "nst_stock.png")**  
  
Nook Simple Touch (BNRV300)  
  
[NST-US-Stock-Reg.zip](https://www.mediafire.com/file/aprvg4uw9fx13le/NST-US-Stock-Reg.zip/file) (133 MB)  
\[MD5: 67e99606ec178434463ab318b4476e73\]  
  
[NST-UK-Stock-Reg.zip](https://www.mediafire.com/file/ge10qb1wcyxqxiq/NST-UK-Stock-Reg.zip/file) (133 MB)  
\[MD5: 5495a88f33fe490cca19f0e5b4d2ec26\]  
  
Nook Simple Touch w/Glowlight (BNRV350)  
  
[NSTG-US-Stock-Reg.zip](https://www.mediafire.com/file/6cyxa1z7h3qezp6/NSTG-US-Stock-Reg.zip/file) (133 MB)  
\[MD5: 2f55ba12707abdaa22be63b595e408aa\]  
  
[NSTG-UK-Stock-Reg.zip](https://www.mediafire.com/file/9zmw2v2ogzm0hcj/NSTG-UK-Stock-Reg.zip/file) (133 MB)  
\[MD5: 31b8160912481a22d2545e93c12f9885\]  
  
**"What are these?"**  
  
Each download zip contains a CWM backup of a stock, registered, unrooted NST/G. This presents the device as it was meant to be, minus the connectivity with B&N to purchase/download books (no longer possible after June 2024). It will boot up as a newly registered device. You'll only need to set the time format and zone. You can side-load epubs. You can download epubs on your PC from your library Overdrive/Libby system, and then transfer them to the device using Adobe Digital Editions (for Windows I recommend ver. 3).  
  
The registered backup was made by performing a factory re-image on the device and updating to FW 1.2.2. The device was registered to a new account opened solely for this purpose. Once all that was done, a CWM backup was created (/boot, /system, /data, /cache). Restoring this backup to another device leaves the /rom partition untouched so device hardware information (serial #, MAC address, etc.) remains unchanged.  
  
**"Who are these for?"**  
  
These backups are for people who have purchased an unregistered device after B&N ends registration for the NST/G in June of 2024. Running the device in an unregistered state with all the B&N stuff intact sets up a large amount of hidden activity which drains the battery quickly. Since it will be impossible to register an NST/G after June 2024, this is an attempt to ensure that the devices remain useful as designed, except for purchasing/downloading books from B&N.  
  
These backups may also be useful to people who discover an NST/G at the bottom of a sock drawer and wonder if they can still use it. Only a device registered with FW 1.2.2 is likely to still work properly, so if the device has not been updated, this may be an avenue to restore it to a useful state.  
  
Finally, these may be useful to people who want to start with the working stock system and root and customize to their own liking.  
  
**"What's the difference between the US and UK versions?"**  
  
There is no hardware difference. Any device can work as either. The US version splash screen at boot says "Read Forever". The UK version has a multilingual text display. In registering the UK version you set the device to display in one of the supported languages (English, French, Spanish, German, Italian). When I registered I chose "English", but you can change this in Settings. However...  
  
The other main difference is the dictionary. The US version uses the Merriam-Webster Collegiate while the UK version uses a version of the Oxford English dictionary. People have their preferences. Unfortunately there is no way to get a non-English dictionary for the UK version to match a particular system language you might select for the device. There is a Settings option for additional dictionaries but it doesn't seem like it ever worked as there has never been any sign of these dictionaries on the various forums.  
  
Also, while it is not possible to do anything with the dictionaries for the stock reader on non-rooted devices, it is possible to swap dictionaries on rooted devices-- but only for the US version, as far as I know. The dictionary formats for the different versions are not the same and while I have been able to produce a number of non-English dictionaries for the US version, I have had no luck duplicating the format of the dictionary for the UK version. So what I am saying is that in terms of non-English capability, the UK version is basically just a show horse. System text will be in whatever language you select but you are stuck with an English dictionary whether or not you eventually root and customize--unless you were to remove all the B&N stuff.  
  
**Warnings**  
  
I cannot guarantee that these will work for you. They work for me.  
  
**"What do I have to do?"**  
  
The briefest possible description is: make a backup, wipe your device, restore the downloaded backup, reboot. Here's a little more detail, followed by a lot more detail (real instructions!):  
  
1\. Download the zip package of your choice and unzip  
2\. Copy the folder from the zip to the /clockworkmod/backup folder on your CWM card (didn't make one? go back to post #1)  
3\. Backup your device (CWM)  
4\. Wipe the device (CWM)  
5\. Restore the downloaded backup (CWM)  
6\. Reboot!  
  
**Note: there is no specific preparation required to use these backups. As long as the device is in working order and has about a 60% battery charge, you're good to go. It doesn't matter whether the device was currently registered in some older firmware, rooted, skipped OOBE. None of that matters as everything will be wiped.**  
  
**To Restore an NST/G backup (the deets!)**  
  
1\. Power down  
2\. Insert the CWM card with the backup image you downloaded  
3\. Power up.  
  
If CWM fails to reach the first menu screen (i.e., is stuck on the splash screen), press the lower right hardware button.  
  
To navigate in CWM: Upper Left hardware button > previous menu, Upper Right hardware button > move up, Lower Right hardware button > move down, "n" button > select  
  
4\. Select backup/restore  
5\. Press "n" to backup your device as it is now  
![Image1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image1.png "Image1.png")  
Backups end up in folders with dates for names, inside /clockworkmod/backup. You can rename these folders with the card in your PC. For example, you might rename this folder as "original" or similar (no spaces allowed in folder name). At the conclusion of the backup you should be returned to the main menu.  
  
6\. Select wipe data / factory reset  
7\. Confirm  
![Image2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image2.png "Image2.png")  
If after any wipe or restore operation CWM freezes, repeatedly press and hold the power button until the device reboots back into CWM. **Don't panic**. Hold the power button while counting to ten. Release it. If nothing happens, count to ten and try again. Eventually the device will reboot. This is the tool we have and it's not perfect, but it does work.  

The device is accessible to ADB while running CWM. If you plug in the USB cable once CWM is running you can connect:  

Code:

```
adb devices
```

This should result in a "11223344556677 recovery" response. You're connected.  
  
Now, when CWM inevitably freezes after a wipe or restore, you can simply type:  

Code:

```
adb reboot
```

No struggling with the power button trying to get an interrupt through the haze of the freeze. The device will simply reboot back into CWM and you continue with the next step.  
  
When you get to the last step (the "restore") and are ready for the final reboot, swap out the CWM card for your storage sdcard, then once again type:  

Code:

```
adb reboot
```

As soon as the screen turns white or when you see that your PC has "lost" recognition of the device as connected, remove the USB connector.

  
8\. Select advanced  
9\. Select Wipe Dalvik Cache  
10\. Confirm  
![Image3.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image3.png "Image3.png")  
If CWM has frozen after the wipe, repeatedly press and hold the power button until the device reboots.  
  
11\. Select backup and restore  
12\. Select restore  
13\. Select folder to restore (you copied one onto the card, remember?)  
14\. Confirm.  
![Image4.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image4.png "Image4.png")  
15\. When restore is complete, remove the CWM card from your device and replace it with your regular storage sdcard if you are using one.  
16\. Press the "n" button to reboot.  
![CWM13.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/CWM13.png "CWM13.png")  
If CWM has frozen after the restore, repeatedly press and hold the power button until the device reboots.  
  
17\. Swipe the screensaver unlocker. Press the "n" button to bring up the QuickNav bar. Tap on "Settings". There tap on "Time" and select your desired time format and time zone. If by chance the time displayed on the device is not correct, you might try connecting to your home WiFi network briefly to see if that sorts it (Settings>Wireless).  
18\. If you're not familiar with how the device works, there are two user guides in the "Library". Most navigation is done via the QuickNav bar (press the "n" button), but if you're on the home screen you can access the most recent read by tapping on the book cover under "Reading now".  
19\. Just a final reminder: none of the stuff about shopping or previewing or downloading, etc., works. B&N has severed ties with these devices as of June 2024 except for a minimal server connection which allows the devices to continue operating without a fault if WiFi is used. But as I said, if you are using the stock configuration, there really is no need for WiFi at all.  
  
You're done!

Last edited:

Reactions:[Kramar111, bisbal, ianmlq and 1 other person](https://xdaforums.com/posts/89533447/reactions)

#### nmyshkin

##### Recognized Contributor

**The Phoenix Project--Phase 2--The stock B&N system, registered, rooted, with new UI and more**  
![nst_newUI.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/nst_newUI.png "nst_newUI.png")  
  
Nook Simple Touch (BNRV300)  
  
[NST-US-newUI-Reg.zip](https://www.mediafire.com/file/fc3e44y8euljtn3/NST-US-newUI-Reg.zip/file) (250 MB)  
\[MD5: 7691cfa6741bf509264ae332e777b0f5\]  
  
Nook Simple Touch w/Glowlight (BNRV350)  
  
[NSTG-US-newUI-Reg.zip](https://www.mediafire.com/file/3ycyvkp2d7jcunz/NSTG-US-newUI-Reg.zip/file) (250 MB)  
\[MD5: bd0f9a36cbd1d0d9d6dc4624c6509eed\]  
  
[NST User Guide](https://www.mediafire.com/file/3qzs9qqrepiyi80/UserGuide.pdf/file)  
[NSTG User Guide](https://www.mediafire.com/file/4ec5w6s3dta6c4x/UserGuide_GL.pdf/file)  
  
**Note:** while the User Guides actually look rather good in EBookDroid, they contain some embedded hyperlinks which EBookDroid can't handle. Also, they were made with interaction in mind, so better to display them on your PC with your device near at hand. These are NOT the old B&N User Guides and contain important information about the new software, setup, widgets, etc.  
  
**Custom UI app update - 6/5/25**  

**What this update does**  
  
This is a Revision 1 update of the previously posted app.  
  
*I came across some issues that I didn't like in the first update. They are now fixed. The description below is still correct, but some bugs have been eradicated.*  
  
1\. Combines the functions of NST UI and SetCover4 into one app, reducing system overhead.  
2\. Forces a Media Scanner refresh every time the stock Library app is opened (finally!). This means no more playing around with moving books that were transferred via FTP, no rebooting just to see new books.  
3\. Moves manual Set Cover function from hardware button assignment to context-driven temporary invisible overlay. This results in less stress on the hardware button rubber covers which are gradually becoming more brittle.  
  
*This update is optional. If you are happy with the way things are working and the three items above don't interest you, skip it.*  
  
**How to update**  
  
These instructions assume some familiarity with the systems to be updated. Most apps made with Tasker don't take well to updates because of problems with new variables. If you want to make the update, please follow these instructions.  
  
1\. Download appropriate updated app. Please note, the apps below are NOT interchangeable. If you have an NSTG, you MUST use the app for the Glowlight model. If you have an NST you MUST use the app for the NST without glowlight.  
  
[For the BNRV300 (NST)](https://www.mediafire.com/file/pr7ejewctzv1cjv/NST_UI.2Rev1.apk/file)  
  
[For the BNRV350 (NSTG)](https://www.mediafire.com/file/ts8kdgbwuitpq3f/NSTG_UI.2Rev1.apk/file)  
  
Transfer to your device (maybe /sdcard/Download?).  
  
If you installed the previous update:  
  
2\. Uninstall NST UI. You can do this from the App Manager. The easiest access is from the app drawer three-dot menu in the upper right ("Manage apps"). You can also access from ES File Explorer (top row of buttons, "AppMgr") or from Settings>Apps.  
  
3\. Install the new NST UI app you downloaded in #1 (tap on the apk file in ES File Explorer).  
  
4\. The new app needs to be initialized (some variables will be set, others cleared). To do this, tap on the "reading now" button in the upper left corner of the home screen. After a small delay you will see a SuperUser prompt. Approve this.  
  
The new app is now functional, but any old data is gone. That means if you are in the process of reading a book, you will need to open that book from its library app again (don't worry, you won't lose your place). In the case of a non-DRM epub with the stock reader, the cover will reset automatically when the book is opened via the Library. For Adobe DRM books or any epub/pdf for which the stock reader does not display a library thumbnail, the manual cover capture routine will activate. For files read with the Kindle app, EBookDroid, or Perfect Viewer, any time the respective library app is opened a small invisible overlay (40x40) will appear in the upper left corner of the screen for 2 minutes. If you do not access that area the overlay will disappear after 2 minutes. If you tap there before the end of 2 minutes, a screenshot will be taken (hopefully of the cover) and placed in the right spots and the overlay disappears. The function of the "reading now" button will also be appropriately set. So if you are in the middle of a book with any of these readers while doing this update, you will have to temporarily return to the cover page, manually set the cover (tap in the upper left) and then return to your reading position. The manual cover capture routine ONLY activates when you open one of the library apps, so subsequent taps on the reading now button or the book cover widget will not make it start.  
  
If you are installing this update without having used the previous one:  
  
2\. Uninstall NST UI and SetCover4 from your device. You can do this from the App Manager. The easiest access is from the app drawer three-dot menu in the upper right ("Manage apps"). You can also access from ES File Explorer (top row of buttons, "AppMgr") or from Settings>Apps.  
  
3\. Install the new NST UI app you downloaded in #1 (tap on the apk file in ES File Explorer).  
  
4\. The new app needs to be initialized (some variables will be set, others cleared). To do this, tap on the "reading now" button in the upper left corner of the home screen. After a small delay you will see a SuperUser prompt. Approve this.  
  
The new app is now functional, but any old data is gone. That means if you are in the process of reading a book, you will need to open that book from its library app again (don't worry, you won't lose your place). In the case of a non-DRM epub with the stock reader, the cover will reset automatically when the book is opened via the Library. For Adobe DRM books or any epub/pdf for which the stock reader does not display a library thumbnail, the manual cover capture routine will activate. For files read with the Kindle app, EBookDroid, or Perfect Viewer, any time the respective library app is opened a small invisible overlay (40x40) will appear in the upper left corner of the screen for 2 minutes. If you do not access that area the overlay will disappear after 2 minutes. If you tap there before the end of 2 minutes, a screenshot will be taken (hopefully of the cover) and placed in the right spots and the overlay disappears. The function of the "reading now" button will also be appropriately set. So if you are in the middle of a book with any of these readers while doing this update, you will have to temporarily return to the cover page, manually set the cover (tap in the upper left) and then return to your reading position. The manual cover capture routine ONLY activates when you open one of the library apps, so subsequent taps on the reading now button or the book cover widget will not make it start.  
  
5\. Cleanup  
  
You can skip this step if you want. Go to Settings>Buttons>Nook Touch ModManager>Side Hardware Buttons (Long Press). The last entry (Side Button - Bottom Right) was assigned for the uninstalled app SetCover4. Tap there (access is slow, be patient). When the selection options appear, choose the first one ("Default"). Then back out of the Settings app with the status bar "back" button.

  
**"What are these?"**  
  
The download zip contains three components:  
1) a CWM backup of a pre-configured NST/G  
2) the contents of an sdcard used for storage  
3) the contents of the /media partition (i.e., the "Nook" drive).  
  
The pre-configured NST/G was made by performing a factory re-image on the device and updating to FW 1.2.2. The device was registered to a new account opened solely for this purpose and then rooted with an updated NookManager card ("Traditional" version). The kernel was updated for multi-touch, NoRefresh, and USB Host (including Audio). Finally, custom applications were added to create the new UI. Once all the configuration was done, a CWM backup was created (/boot, /system, /data, /cache). Restoring this backup to another device leaves the /rom partition untouched so device hardware information (serial #, MAC address, etc.) remains unchanged. Since CWM cannot backup /media or /sdcard, separate folders containing those files are in the zip along with the backup (an sdcard is required for all of this to work properly).  
  
This build is based on [earlier work of mine](https://xdaforums.com/\(https://xdaforums.com/t/the-nstg-turns-10-time-for-a-makeover.4488695/) to update the UI of the NST/G and deploy a number of custom apps which (hopefully) enhance the capabilities of the device. You can take a look at a video of this build in action in that post. In the video, USB Audio is part of the build, but I did not include it in this version. However, all the needed software is in place and the User Guide contains detailed information regarding the required setup for those who are interested in this feature. While similar to my earlier work, this build contains more custom software developed for this project.  
  
Additional reader apps include customized versions of Amazon Kindle, EBookDroid and Perfect Viewer. The "reading now" button in the status bar will open any reader currently in use, not just the stock B&N reader.  
  
**Please note**: **As of May 26, 2025, Amazon will no longer support downloads (**[**dictionaries**](https://www.mediafire.com/folder/dww8eduzegz12/Kindle+Dictionaries)**, public library books) from this old app. It sounds as if registered copies will continue to function in offline mode as mobi readers and preliminary tests suggest that new registrations may be possible. Uninstalling the Kindle Library and Amazon Kindle apps is described in the User Guide.**  
  
It is possible to use the current book cover as a screensaver image.  
  
Additional dictionaries may be added for the stock reader (and the Kindle app, for that matter).  
  
Most apps have been lightly pre-configured to make for a better first experience and reduce the amount of time and effort it takes to get up and running. There are a few exceptions and this information is covered in more detail (along with initial setup instructions) in the "User Guides" for each version (separate download above).  
  
Unfortunately it is not possible for you to add additional or alternative reader apps to this build and not break the UI function with regard to the bookcover homescreen image/screensaver image and the "reading now" button. Other apps will work, of course, but only as stand-alone entities.  
  
**"Who are these for?"**  
  
People who do not have a B&N registration for their device and want more than the stock system has to offer may find these useful. Also, people who do have a valid registration for their device but don't see the point in that without actual B&N services yet like the basic B&N reader/library/dictionary combination might want to try these out to see if the new UI and added functionality suits them. A backup prior to trying these will ensure an easy return to the previous state in the event of buyer's remorse.  
  
**"Why is there no UK version?"**  
  
I could have made one but did not see the point. This build can do everything that the UK version can do and more (there is an Oxford English dictionary included as an option). I'm sorry for the folks who are attached to the multilingual splash screens, but this package really is more versatile when based on the US version.  
  
**Warnings**  
  
I cannot guarantee that these will work for you. They work for me.  
  
**"What do I have to do?"**  
  
The briefest possible description is: make a backup, wipe your device, restore the custom backup, reboot. Here's a little more detail, followed by a lot more detail (real instructions!):  
  
1\. Download the zip package of your choice and unzip  
2\. Delete the contents of the "Nook" drive (/media) and copy the contents of the "media" folder to the "Nook" drive  
3\. Copy the contents of the "sdcard" folder to a clean, formatted sdcard  
4\. Copy the folder with the long name (like "NST-US-newUI-Reg") to the /clockworkmod/backup folder on your CWM card (didn't make a card? go back to post #1)  
5\. Backup your device (CWM)  
6\. Wipe the device (CWM)  
7\. Restore the custom backup (CWM)  
8\. Reboot!  
  
**Note: there is no specific preparation required to use these backups. As long as the device is in working order and has about a 60% battery charge, you're good to go. It doesn't matter whether the device was currently registered in some older firmware, rooted, skipped OOBE. None of that matters as everything will be wiped.  
  
To Restore an NST/G backup (the deets!)**  
  
1\. If your device is in a state where you can make a USB connection with your PC and see the "Nook" drive, connect the device and backup any files present that you may want (books, etc.) then delete the contents of the "Nook" drive (this is /media). DO NOT delete the drive itself, just the contents.  
  
There is sometimes a "System Volume Information" folder in /media which appears to Windows to be read-only. Rather than mess with that, just ignore it if Windows cannot remove the folder. When you copy the new contents onto the card you will be asked if you want to replace the files in that folder with new ones. The answer is "yes".  
  
2\. Copy the contents of the "media" folder from the zip you downloaded to the "Nook" drive. Eject from the USB connection.  
  
*If your device is not in a state where you can get a connection to your PC, wait to do steps 1 and 2 until the very end.*  
  
3\. Power down.  
4\. Remove the storage sdcard (if there is one) and insert it (or a new one) into your PC.  
5\. Back up any books or other files you want elsewhere for now, then delete all files on your storage sdcard.  
  
There is sometimes a "System Volume Information" folder on sdcards that have been used in the device which appears to Windows to be read-only. Rather than mess with that, just ignore it if Windows cannot remove the folder. When you copy the new contents onto the card you will be asked if you want to replace the files in that folder with new ones. The answer is "yes".  
  
6\. Copy the contents of the "sdcard" folder that you downloaded onto your clean sdcard and set aside (the card should be formatted FAT32--if in doubt, reformat before copying content onto the card).  
7\. Copy the backup folder from the zip you downloaded (named like "NST-US-newUI-Reg") to /clockworkmod/backup on the CWM card. Remove the CWM card from your PC and insert it into the device.  
8\. Power up.  
  
If CWM fails to reach the first menu screen (i.e., is stuck on the splash screen), press the lower right hardware button.  
  
To navigate in CWM: Upper Left hardware button > previous menu, Upper Right hardware button > move up, Lower Right hardware button > move down, "n" button > select  
  
9\. Select backup/restore.  
10\. Press "n" to backup your device as it is now.  
![Image1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image1.png "Image1.png")  
Backups end up in folders with dates for names, inside /clockworkmod/backup. You can rename these folders with the card in your PC. For example, you might rename this folder as "original" or similar (no spaces allowed in folder name). At the conclusion of the backup you should be returned to the main menu.  
  
11\. Select wipe data / factory reset.  
12\. Confirm.  
![Image2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image2.png "Image2.png")  
If after any wipe or restore operation CWM freezes, repeatedly press and hold the power button until the device reboots back into CWM. **Don't panic**. Hold the power button while counting to ten. Release it. If nothing happens, count to ten and try again. Eventually the device will reboot. This is the tool we have and it's not perfect, but it does work.  

The device is accessible to ADB while running CWM. If you plug in the USB cable once CWM is running you can connect:  

Code:

```
adb devices
```

This should result in a "11223344556677 recovery" response. You're connected.  
  
Now, when CWM inevitably freezes after a wipe or restore, you can simply type:  

Code:

```
adb reboot
```

No struggling with the power button trying to get an interrupt through the haze of the freeze. The device will simply reboot back into CWM and you continue with the next step.  
  
When you get to the last step (the "restore") and are ready for the final reboot, swap out the CWM card for your storage sdcard, then once again type:  

Code:

```
adb reboot
```

As soon as the screen turns white or when you see that your PC has "lost" recognition of the device as connected, remove the USB connector.

  
13\. Select advanced.  
14\. Select Wipe Dalvik Cache.  
15\. Confirm.  
![Image3.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image3.png "Image3.png")  
If CWM has frozen after the wipe, repeatedly press and hold the power button until the device reboots.  
  
16\. Select backup and restore.  
17\. Select restore.  
18\. Select folder to restore (you copied one onto the card, remember?).  
19\. Confirm.  
![Image4.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image4.png "Image4.png")  
20\. When restore is complete, remove the CWM card from your device and replace it with your regular storage sdcard (with the new files/folders)  
21\. Press the "n" button to reboot.  
  
If CWM has frozen after the restore, repeatedly press and hold the power button until the device reboots.  
  
22\. Once the device begins the boot sequence, swipe the screensaver unlocker when you get to that screen. When boot is complete your screen should look like this:  
![1717017194348.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/1717017194348.png "1717017194348.png")  
  
If there are messages about not being able to load the widget image it's because you have not restored the contents of /media yet. Do that next. Otherwise, skip to #27.  
  
23\. Attach the device to your PC via USB cable.  
24\. Backup any content you want from the "Nook" drive, then delete all files/folders in the "Nook" drive (not the drive itself!!! just any random files/folders).  
25\. Copy the contents of the "media" folder that you downloaded to the "Nook" drive.  
26\. Eject your device (i.e., disconnect USB properly)  
  
The messages about the widget should cease. If they do not, power down and up again.  
  
27\. Refer to your "User Guide" (separate download above) for initialization instructions and other information about your version.  
  
You're done!

Last edited:

Reactions:[Kramar111, ianmlq and TheGreatMcMurphy](https://xdaforums.com/posts/89533449/reactions)

#### nmyshkin

##### Recognized Contributor

**The Phoenix Project--Phase 3--B&N system removed, new software added, with new UI and more**  
  
![phase3.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/phase3.png "phase3.png")  
  
Featuring AlReader  
[NST-US-newUI-AlR115.zip](https://www.mediafire.com/file/m7sab0eu0b4ogxd/NST-US-newUI-AlR115.zip/file) (236 MB) (Nook Simple Touch, BNRV300)  
\[MD5: 37d127ac2a2916585d0fbb49e1357006\]  
[NSTG-US-newUI-AlR115.zip](https://www.mediafire.com/file/gw62pl7p7n14ot7/NSTG-US-newUI-AlR115.zip/file) (239 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
\[MD5: c4b28bbbd4041d2db60c7168c583ffec\]  
***Experimental RTL builds*** (see **Spoiler** below)  
[NST-US-newUI-AlR115RTL.zip](https://www.mediafire.com/file/m8dxy4t51fv9nmo/NST-US-newUI-AlR115-RTL.zip/file) (294 MB) (Nook Simple Touch, BNRV300)  
\[MD5: e7f6c15e103807866232397e81f93ea7\]  
[NSTG-US-newUI-AlR115RTL.zip](https://www.mediafire.com/file/fru1g9ox8bug74s/NSTG-US-newUI-AlR115-RTL.zip/file) (299 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
\[MD5: 79990bc17eb9eef7d60552a6dfdbd5e8\]  
  
Featuring Cool Reader  
[NST-US-newUI-CR115.zip](https://www.mediafire.com/file/hred14nka0zlonb/NST-US-newUI-CR115.zip/file) (264 MB) (Nook Simple Touch, BNRV300)  
\[MD5: 5e185aa3e721a2457a3e8bf436e1b7b0\]  
[NSTG-US-newUI-CR115.zip](https://www.mediafire.com/file/h8ayu98px0ry7g7/NSTG-US-newUI-CR115.zip/file) (237 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
\[MD5: 1d4c0c1d5659c7b5657ee2d848b66fec\]  
  
Featuring FBReader  
[NST-US-newUI-FB.zip](https://www.mediafire.com/file/hmhszuvooja599v/NST-US-newUI-FB.zip/file) (234 MB) (Nook Simple Touch, BNRV300)  
\[MD5: a759f1ccd82d8cf9dabe9132b627133a\]  
[NSTG-US-newUI-FB.zip](https://www.mediafire.com/file/mxvblydxn2izxm8/NSTG-US-newUI-FB.zip/file) (235 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
\[MD5: 5a88fe9f74b8aa831228ada116523611\]  
  
Featuring Mantano Reader  
[NST-US-newUI-Man.zip](https://www.mediafire.com/file/gflogiqevpz212f/NST-US-newUI-Man.zip/file) (241 MB) (Nook Simple Touch, BNRV300)  
\[MD5: 81a1f73771a57a9069e886869f13abaf\]  
[NSTG-US-newUI-Man.zip](https://www.mediafire.com/file/u48wixcnscvoihq/NSTG-US-newUI-Man.zip/file) (242 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
\[MD5: 6a629f1a478f2a681aecba230f50a988\]  
  
[NST User Guide](https://www.mediafire.com/file/dngf48fie1bw21j/Al_UserGuide115.pdf/file) (w/AlReader)  
[NSTG User Guide](https://www.mediafire.com/file/4j2vh3yp9lm9qf8/Al_UserGuide_GL115.pdf/file) (w/AlReader)  
[NST User Guide](https://www.mediafire.com/file/55lp0d16m07r6md/Al_UserGuide115RTL.pdf/file) (w/AlReader RTL build) \[see Spoiler below\]  
[NSTG User Guide](https://www.mediafire.com/file/wta29umvgk0ckl0/Al_UserGuide_GL115RTL.pdf/file) (w/AlReader RTL build) \[see Spoiler below\]  
[AlReader Help File](https://www.mediafire.com/file/7gmghioslo5crgl/AlReaderHelp.zip/file) (HTML, tr.)  
[NST User Guide](https://www.mediafire.com/file/oltdn9932wf8dyd/CR_UserGuide115.pdf/file) (w/Cool Reader)  
[NSTG User Guide](https://www.mediafire.com/file/ugka1aedb7oj6vd/CR_UserGuide_GL115.pdf/file) (w/Cool Reader)  
[NST User Guide](https://www.mediafire.com/file/1zoh2747et57b4b/FB_UserGuide.pdf/file) (w/FBReader)  
[NSTG User Guide](https://www.mediafire.com/file/i2miwi73eokkrpv/FB_UserGuide_GL.pdf/file) (w/FBReader)  
[NST User Guide](https://www.mediafire.com/file/del81yd40dwnr4n/M_UserGuide.pdf/file) (w/Mantano)  
[NSTG User Guide](https://www.mediafire.com/file/9wz4sepjecv97xd/M_UserGuide_GL.pdf/file) (w/Mantano)  
  
**Note:** while the User Guides actually look rather good in EBookDroid, they contain some embedded hyperlinks which EBookDroid can't handle. Also, they were made with interaction in mind, so better to display them on your PC with your device near at hand. These are NOT the old B&N User Guides and contain important information about the new software, setup, widgets, etc.  
  
**"What are these?"**  
  
Each download zip contains three components:  
1) a CWM backup of a pre-configured NST/G  
2) the contents of an sdcard used for storage  
3) the contents of the /media partition (i.e., the "Nook" drive).  
  
The pre-configured NST/G was made by performing a factory re-image on the device and updating to FW 1.2.2 or FW 1.1.5 (see "Spoiler" below). The device was rooted with an updated NookManager card ("Traditional" version). NookManager was used to remove the B&N account and system. The kernel was updated for multi-touch, NoRefresh, and USB Host (including Audio). Finally, custom applications were added to create the new UI. Once all the configuration was done, a CWM backup was created (/boot, /system, /data, /cache). Restoring this backup to another device leaves the /rom partition untouched so device hardware information (serial #, MAC address, etc.) remains unchanged. Since CWM cannot backup /media or /sdcard, separate folders containing those files are included in the zip (an sdcard is required for all of this to work properly).  
  
There are currently 5 versions (for both the standard NST and also the NSTG) which differ by the principal reader app (for epubs and perhaps a few other formats) and custom software needed for the UI:  
  
AlReader  
AlReader, RTL version  
Cool Reader  
FBReader  
Mantano Reader  
  
Colordict is integrated as a dictionary source for the principal reader apps and both the Merriam-Webster and Oxford English dictionaries are provided. Other dictionaries in StarDict format can be added.  
  
Additional reader apps on all versions include customized versions of Amazon Kindle, EBookDroid and Perfect Viewer.  
  
**Please note**: **As of May 26, 2025, Amazon will no longer support downloads (**[**dictionaries**](https://www.mediafire.com/folder/dww8eduzegz12/Kindle+Dictionaries)**, public library books) from this old app. It sounds as if registered copies will continue to function in offline mode as mobi readers and preliminary tests suggest new registrations may still be possible. Directions for uninstalling the Kindle Library and Amazon Kindle apps are in the User Guide.**  
  
Most apps have been lightly pre-configured to make for a better first experience and reduce the amount of time and effort it takes to get up and running. There are a few exceptions and this information is covered in more detail (along with initial setup instructions) in the "User Guides" for each version (separate download above).  
  
Unfortunately it is not possible to try out one version and then replace the principal reader app or add another reader app and not break the UI components since each reader app handles cover images differently. Of course you can always add a reader app to try it out (the various UI features will not work for it) and then perhaps decide you like it better. In that case you would then have to do a complete install of the version with that reader (including the files in /media and on the sdcard) for a fully functional system.  
  
If you have no experience with any of the principal reader apps, the chart below may be helpful but is certainly not an exhaustive comparison of the various features, strengths, weaknesses, etc. In my opinion, the reader app most like the B&N stock reader in terms of simplicity and format capabilities (except for font support) is Mantano, but its screen UI elements are quite small.  
  
![E-reader apps.png](https://xdaforums.com/attachments/e-reader-apps-png.6257740/ "E-reader apps.png")  
  

In the change from FW 1.1.x to 1.2.x, B&N altered the EPD (Electronic Paper Display) controller code. This affects how and when the e-ink screen is refreshed. It is the reason why there are two versions of the NoRefresh app. Unfortunately, both Cool Reader and AlReader ended up on the older side of this change and were never updated. That means the "partial refresh" feature which they have does not work with FW 1.2.x  
  
What, exactly, does "partial refresh" mean? If you're not familiar with the stock reader (absent from these builds) the easiest way to describe "partial refresh" is to say that the text on a page does a sort of rapid dissolve, to be replaced by the text of the new page. This continues along for 5-6 pages. At that point a total screen refresh is done. This is detected as a rather quick flash of black over the entire screen and the appearance of the next page. In a reader app lacking the "partial refresh" ability, each page change comes with a flash or flicker of this sort. For some people (including me) this is visually distracting. The NoRefresh app can be used to eliminate this, but since the screen never refreshes, there can be ghosting artifacts eventually (they clear up, of course, once out of NoRefresh mode). Some people are more sensitive to this than others. Also, because the NoRefresh app flattens the grey-scale to two colors, font antialiasing gets lost and text can look a tiny bit rough. Again, some people are more bothered by this than others.  
  
So it's desirable for most to have the option to use "partial refresh". The only way to get that with Cool Reader or AlReader is to return to FW 1.1.x  
  
The early Glowlight models were shipped with FW 1.1.5. This is a Glowlight-exclusive firmware but it does contain little bits of what would eventually happen: the merging of the firmwares. I originally intended to use FW 1.1.2 on the non-Glowlight version but it was impossible to make the needed patches to run NookTouch ModManager. Before you say "so what?", a little historical perspective is needed. Prior to NTMM, control of the "n" button and the stabilization of the "back" and "menu" status bar soft buttons was a problem. These are problems I lack the expertise to address, so I ended up forcing FW 1.1.5 on the non-Glowlight builds as well. This caused only a few problems, one of which I chose to ignore because it is already addressed by QuickTiles. I could *not* ignore the refusal of the "Display" screen in Settings to open, and I could not figure out what was going on. So I synthesized a new "Display" and "Screen" for the Nook Settings app.  
  
There are some things FW 1.1.5 lacks which users of FW 1.2.x might notice. For the most part, these are minor (like the absence of actual screensaver banner text which first appears in the framework for FW 1.2.x), but I do want to mention here--in case it's a deal-breaker for some--that NookTouch Mod Manager is more limited on FW 1.1.5. The chief limitation is the inability to control the four side hardware buttons. The code simply isn't there and the original developer mentions this in the app posting. You can make some changes to the behavior of the side buttons by editing a text file. Complete information about this and other issues is in an Appendix added to the User Guides for these builds (**note**: there is a much more detailed description of the button assignment procedure in the FAQ post immediately following this post). In the end I decided to modify NTMM so that it would only show the things that worked on FW 1.1.5.  
  
If you're familiar with the later firmware and the functions of NTMM you may be thinking "hmm.....I might be able to live without partial refresh." I have anticipated that possibility and so here are the links to the original builds (using FW 1.2.2) and their User Guides. After all that work I wasn't just going to delete them!  
  
Featuring AlReader  
[NST-US-newUI-AlR.zip](https://www.mediafire.com/file/uuke2txekg60syp/NST-US-newUI-AlR.zip/file) (235 MB) (Nook Simple Touch, BNRV300)  
\[MD5: 88017876f5a473ca5b426e87246f9692\]  
[NSTG-US-newUI-AlR.zip](https://www.mediafire.com/file/py90w8hv9nz2jsx/NSTG-US-newUI-AlR.zip/file) (237 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
\[MD5: 69c7a767cf0a62a867a83c5981009826\]  
  
Featuring Cool Reader  
[NST-US-newUI-CR.zip](https://www.mediafire.com/file/orz63uar4vfzqej/NST-US-newUI-CR.zip/file) (263 MB) (Nook Simple Touch, BNRV300)  
\[MD5: d3b99e00d42410413e069b2cf80adf75\]  
[NSTG-US-newUI-CR.zip](https://www.mediafire.com/file/72tlkbjpjfdhcrz/NSTG-US-newUI-CR.zip/file) (234 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
\[MD5: e77e3ba3618b9a88361932f271c2bfa0\]  
  
[NST User Guide](https://www.mediafire.com/file/e2rjapokpl0opvb/Al_UserGuide.pdf/file) (w/AlReader)  
[NSTG User Guide](https://www.mediafire.com/file/py90w8hv9nz2jsx/NSTG-US-newUI-AlR.zip/file) (w/AlReader)  
[AlReader Help File](https://www.mediafire.com/file/7gmghioslo5crgl/AlReaderHelp.zip/file) (HTML, tr.)  
[NST User Guide](https://www.mediafire.com/file/8nygdxfns9yziob/CR_UserGuide.pdf/file) (w/Cool Reader)  
[NSTG User Guide](https://www.mediafire.com/file/80b2xbfcmlqq6jw/CR_UserGuide_GL.pdf/file) (w/Cool Reader)

**Overview**  
  
There have been posts about enabling RTL on the NST/G from the very early days. The posts were mostly focused on Arabic, with a few comments about Hebrew thrown in. Some detective work brought me back to [a post](https://xdaforums.com/t/tutorial-how-to-fix-rtl-arabic-ardu-farsi-hebrew-stock-custom-roms-gt-s5830.1970521/) by [@Ahmed hamouda](https://xdaforums.com/m/4514149/) which supplied a Java routine for patching ROMs to enable RTL and produce the ligatures in Arabic script properly.  
  
Fortunately this seemed to work on the NST/G ROM, although it did give an error about Hebrew. My subsequent work with the patches seems to indicate that Hebrew is fine. If that's not the case, I expect I will hear about it.  
  
Patching the OS was one thing. Finding a reader app that would run on the NST/G and was RTL-capable was another. The stock reader uses only the tiny universe hidden in ReaderRMSDK by Adobe. It does not see the DroidSansFallback font and does not respond to the system patches. I tried pretty much everything else and found that only Moon+Reader and AlReader were able to display RTL text properly (even on the same page with LTR text). After a lot of testing I finally gave up on Moon+Reader. I know it has been praised in the past on the forum, but I don't get it. It had just too many issues to list. I'll just note that it does not have partial screen refresh and move on.  
  
That left me with AlReader and that meant FW 1.1.5 if partial refresh was going to work. I started with the Phase 3 build featuring AlReader, patched the ROM, and then began testing with any epub material I could find in the four common RTL languages: Arabic, Hebrew, Persian (Farsi), and Urdu. I found that a lot of what is available in these languages is PDFs, mostly from optical scans. EBookDroid and Perfect Viewer are capable of handling these without any special patches to the OS. I finally did track down a few epubs in each language. I converted a few to PDFs with Calibre just to see if text-based PDFs would also be displayed correctly in EBookDroid and Perfect Viewer. They were, but I can't guarantee that books from other sources will also work.  
  
**Note:** because my familiarity with these languages could be accurately described as "by name only", I can't say with any certainty that the patches yield any kind of useful result when coupled with the abilities of AlReader. I was not able to get much feedback prior to starting the build and could only rely on Google Translate of screencaps to determine whether the texts might be readable by at least a machine. In particular I have no idea whether the ligature patches for Arabic are also suitable for Persian and/or Urdu. Below is a sample of texts in the four languages. I hope that if someone who has the knowledge determines that these builds are not really useful, they will let me know.  
  
![RTL.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/RTL.png "RTL.png")  
  
Fonts are a big issue. The DroidSansFallback font supplied with the NST/G does not have either Arabic or Hebrew (never mind the others which are derived from Arabic script). I first tried DejaVuSans as it supposedly supports Arabic, Hebrew and Persian 100%. Urdu is 92%. But again there were issues, mostly with dictionaries which frequently referred to other languages like Hindi or Sanskrit and thus displayed a bunch of boxes rather than text. Eventually I came across a huge font (ArialUnicodeMS-Regular.ttf) which probably even contains Martian. I made that DroidSansFallback and there were far fewer empty boxes in the dictionaries. This also means that where possible in a given app, Arabic characters or Hebrew--or Martian--can be properly displayed (like in the file explorer, for example). With that as Fallback and DejaVuSans as the selected font, all four languages displayed without any dropouts I could detect in my testing. Of course, dedicated fonts for a particular language are bound to be better so I have included a variety of fonts in /system/fonts from which you can choose. There are many, many more available online for free.  
  
A small nuisance is that AlReader requires four settings to catch all instances of a font. No one-setting-to-rule-them-all. Of course if you are not too persnickety, you could change only the main text font and let DroidSansFallback pick up the slack. This is discussed in the User Guide.  
  
An additional font issue is diacritic marks. I have a test epub file from a fellow on the Mobileread forum and the correct output in image form. It is clear from this that the engine in AlReader does not generally handle diacritics well. They are out of alignment in Hebrew, regardless of what font I tried. Surprisingly the "best" results seem to be DejaVuSans rather than one of the actual Hebrew fonts. But it's still bad. In the three languages that use some form of Arabic script, that same generic font (backed up by DroidSansFallback) appears to give complete coverage, as long as diacritic marks are not used. With diacritics there are positioning issues and sometimes outright mushing of characters together. The severity of these problems differs with the selected font. It pays to shop around.  
  
Compounding the issue, the reader app cannot properly select words for dictionary lookup if diacritics are present. You generally get only the first character, no matter what the selection looks like on the screen.  
  
Those strike me as real problems, but it may be that reading material without diacritics is common? Based on the sample epub I used for testing it must be that the use of diacritics is controlled by the contents of the epub file since the same sample lines were displayed on the same page, with and without diacritics. I guess that means it would be possible to open up an epub file and disable the diacritics if they are used. None of the epubs I managed to scare up for the four languages used diacritic marks.  
  
For those reasons, this build is described as "experimental". I don't know how useful it might be to someone who would like to read in one of the RTL languages, but it is the best I could do with the tools (and limited knowledge) at my disposal.  
  
**The build**  
  
In no particular order, these are the things that I did to the standard Phase 3 AlReader build to produce this special version:  
  
1\. Patched framework.jar, lib\_\_bcore.so, libandroid\_runtime.so, libwebcore.so, and added libicuuc-arabic.so  
2\. Replaced DroidSansFallback with a renamed ArialUnicodeMS-Regular.ttf  
3\. Added a variety of fonts for the four languages to /system/fonts, as well as DejaVuSans.ttf  
4\. Added many single-language or translation dictionaries, and two thesauruses  
5\. Configured all the reader apps for RTL pagination (page turns to advance are controlled by left screen taps and buttons)  
6\. Removed the Amazon Kindle app. It cannot display RTL text, Amazon is abandoning it at the end of May 2025, and AlReader can read non-DRM.mobi books anyway.  
  
All of the reader apps can still read LTR languages, but the controls for page changes will be "backwards" from what LTR readers would expect. These, of course, can be changed to suit, generally involving 4 settings (two for the screen and two for the buttons) except for Perfect Viewer which has a one-tap control to toggle all four settings at once These adjustments are discussed in the User Guide.

**"Who are these for?"**  
  
Anyone with a working device in any state can use these since they do not include or rely on any account information. However, if you currently have a device with a valid B&N connection, it would be wise to make a total device backup before trying out these images. CWM does not make a total backup. NookManager can do that. That way if none of this is to your liking you can easily restore your device to it's original condition.  
  
**"What do I have to do?"**  
  
The preparation and installation instructions are identical to those found in [post #3 above](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/post-89533449) (for "phase 2") except for the name of the backup file to be restored. Please refer to that post under "What do I have to do?"

Last edited:

Reactions:[Kramar111, bisbal, ianmlq and 1 other person](https://xdaforums.com/posts/89533450/reactions)

#### nmyshkin

##### Recognized Contributor

**The Phoenix Project--FAQ**  
  
Rooting  
USB Audio  

Yes, I'm afraid I left out a tiny detail. To enable full spectrum microphone recording you need to make a small edit in /system/etc/permissions/platform.xml. Copy the file to the sdcard or your PC. Using either ES Note Editor or something like Notepad++ on your PC, add the line in bold below to the permission shown:  
  
<permission name="android.permission.WRITE\_EXTERNAL\_STORAGE" >  
<group gid="sdcard\_rw" />  
**<group gid="audio" />**  
</permission>  
  
Move the file back to overwrite the original and then reboot. In an app like "Record That Note", this should enable all of the various microphone recording options.

Hardware button mapping for Phase 2  

This is not something I ever really looked at until [@NewConfusedNookUser](https://xdaforums.com/m/13156126/) brought the issue to my attention. I don't use buttons to change pages but I know there are people who very much want that--except maybe not all in the same way. So I left the lower buttons, the stock reader settings, and the keylayout file in the default state. The only change I made to the buttons was to use NTMM to assign the upper buttons to Back and Menu.  
  
How you approach the button assignments is very important. You must take care of the stock reader first because the assignments you make will impact settings you make in the other readers.  
  
The stock reader: for a logical assignment of the lower left to PREVIOUS PAGE and the lower right to NEXT PAGE (this mimics the screen taps), go to Settings>Buttons>Nook Touch Mod Manager and assign the lower right hardware button ONLY to "Tap Right (Next Page)". This corrects for the bizarre B&N notion that "previous" and "next" should be controlled by upper and lower buttons.  
  
**Do not use NTMM to assign any other page turns.**  
  
For the Kindle app there is a setting to use the Volume controls for page turns, but if you use that, the stock reader will not work, so forget it.  
  
In EBookDroid you can only change the button assignments when a book is open (they "stick", though, for all future books). Tap in the center of the screen and then tap "More" in the bottom menu. Then Settings>Configure keys. You want the "Management keys" for the right lower button setting. The app sees that button as DPAD DOWN (20) after the assignment made in NTMM. Make this "Scroll Forward" to advance a screen. The app sees the lower left button as 93, which is in the range of the "Keyboard keys" (way down on the list). Make that "Scroll Back" to move to the previous screen of text.  
  
Perfect Viewer is similar in that it recognizes the bottom buttons as the entities I described above for EBookDroid. But it lacks "93" in its list. Fortunately it has the option to add a key. From the library shelves, tap on the "tool" button. Now you're in Settings>Control & hardware key>Hardware key management. You will see DPAD DOWN (20) there. Assign that to "Scroll Forward". Then at the top of the screen tap on "Add key". A dialog box opens and you are asked to press a key/button. Press the lower left button. "93" should appear in the dialog box. Name it something like "lower left" and then assign it to "Scroll Backward".  
  
And that's the whole sordid story about button assignments.

Hardware button mapping for Cool Reader and AlReader  

I could have been more detailed in the User Guide, I guess.  
  
The file in question is /system/usr/keylayout/TWL4030\_Keypad.kl. The first thing to know about this file is that it is plain text. The second thing to know about it is that the file is "in use" as of boot and if you try to do anything with it you may trigger a spontaneous reboot.  
  
So long-press on the file and from the context menu select "copy". Then navigate back to the root of the sdcard and tap on "paste". Now you have a copy of the file to work with and you won't annoy the system.  
  
To open the file, long-press on it again and this time select "open as" from the context menu. Choose "text". The file will open in ES Note Editor. Scroll down to the end of the file. The last four entries control the four hardware buttons. You will see that I have changed two of them from their original default values to "BACK" (key 412) and "MENU" (key 407). These are just two of the options in the very long list that makes up the rest of the file.  
  
Let's say you want to assign VOLUME\_DOWN to the lower left button (key 139). All you have to do is delete "LEFT\_PREVPAGE" and replace it with VOLUME\_DOWN. If you want the lower right button to complete the set, then replace "RIGHT\_PREVPAGE" with VOLUME\_UP.  
  
As you back out of the file, you'll be asked whether you want to save the changes (yes).  
  
Now long-press on the file once again and select "copy". Then navigate back to  
/system/usr/keylayout/ and tap on the "paste" button. You will be asked about overwriting. The answer is "yes".  
  
The last and most important step is to reboot. This is required because the file was loaded during boot and it's not going to be looked at again until another boot. Your changes will take effect after the fresh boot.  
  
A note about VOLUME\_UP and VOLUME\_DOWN: these are common options for reader apps which can use buttons for page changes (or other actions). On the NST/G they will work in the same way, but outside the reader apps they will bring up the volume control toast, so if that's going to bother you, it might be a good idea to choose some other pair of button assignments that the reader app could use (CoolReader does not have the option to use VOLUME\_UP and VOLUME\_DOWN anyway).

Kindle cover images  

Some Kindle books seem to come with cover pages that have a small cover image on a white background. That doesn't make for a great cover image widget or screensaver. There is, however, an undocumented trick for enlarging the view of the cover, although it comes with a trade-off.  
  
A double-tap on the cover image will enlarge it to fill the screen (at least the vertical dimension, usually). A manual cover capture of this view is better but it will include a resizing indicator at the bottom. The only way to escape from the enlarged view is with the "back" button (upper left hardware button).  
  
Alternatively, you can capture the smaller view and then use QuickPic to crop the images in /media/NowReading and /media/screensavers/CurrentBookCover. Obviously that is more tedious, although you only have to fix one and then copy the image to the other location. This method will result in a lower resolution image because you are enlarging what was a small screenshot into a larger one. Also you must refresh the bookcover widget (app drawer>Desktop Visualizer>status bar "menu">(at bottom right) refresh widgets (normal). You will lose the "Kindle" badge, though.

Last edited:

Reactions:[Kramar111, ianmlq and TheGreatMcMurphy](https://xdaforums.com/posts/89533452/reactions)

#### NookSimpleTouchFan2024

##### Member

Hey everyone!!  
...so i had a couple questions about the instructions... in a nutshell... do i make the CWM sd card and then back up the Nook... then on the same micro sd, restore with the stock image US/UK... if yes, will there be enough space on the formatted micro sd to hold both images.... I plan on using a 32gb micro sd card but i also realize then when making a CWM micro sd card a lot of space is essentially unusable... i just wanna make sure i am understanding things correctly.

#### nmyshkin

##### Recognized Contributor

> [NookSimpleTouchFan2024 said:](https://xdaforums.com/goto/post?id=89554398)
> 
> Hey everyone!!  
> ...so i had a couple questions about the instructions... in a nutshell... do i make the CWM sd card and then back up the Nook... then on the same micro sd, restore with the stock image US/UK... if yes, will there be enough space on the formatted micro sd to hold both images.... I plan on using a 32gb micro sd card but i also realize then when making a CWM micro sd card a lot of space is essentially unusable... i just wanna make sure i am understanding things correctly.
> 
> Click to expand...
> 
> Click to collapse

You have the right idea. A 32 GB card seems excessive, but if it's what you have, it will work. Backups run from 200-300 MB or so, so you do the math.  
  
If you use the 2 GB CWM image and do nothing to reclaim the "lost" 30 GB, you can always copy off backups to your PC.  
  
That said, using the partition software to reclaim the space is not really difficult. It just looks intimidating.

Reactions:[TheGreatMcMurphy](https://xdaforums.com/posts/89554413/reactions)

#### NookSimpleTouchFan2024

##### Member

> [nmyshkin said:](https://xdaforums.com/goto/post?id=89554413)
> 
> You have the right idea. A 32 GB card seems excessive, but if it's what you have, it will work. Backups run from 200-300 MB or so, so you do the math.  
>   
> If you use the 2 GB CWM image and do nothing to reclaim the "lost" 30 GB, you can always copy off backups to your PC.  
>   
> That said, using the partition software to reclaim the space is not really difficult. It just looks intimidating.
> 
> Click to expand...
> 
> Click to collapse

good point... i hadn't thought about reclaiming the lost space via mini partition wizard. I believe you had mentioned this as well, so my apologies for that. thank You again.

#### NookSimpleTouchFan2024

##### Member

hey everyone...  
so i finally got my used Nook from ebay and i made a backup with Nook Manager... then i went to make a 2gb micro sd carrd \[ i tried both Win32diskImager, and Rufus\] using RUN AS ADMIN on both programs i have but i am unable to get the nook to turn on with the micro sd card installed... all 3x sd cards I have bought are SanDisk 32gb. I followed the instructions to the letter... and yes i even extended the unallocated space to make room for a backup or two on the micro sd card\[the orginal +the US-REG backup from here which i ultimately wanna use to restore the reader with\]...  
  
I had mentioned i have multiple sd cards... they are all the same.. SanDisk 32gb, from Walmart... they are used as follows...  
1 = the Nook Manager Nook backup Image  
1 = CWM micro-SD  
1 = for side loading books...  
  
but just to recap... i have been unable to get the CWM micro sd card to load up when holding the power button down on the nook simple touch \[BNRV300\]... any help would be appreciated, thank you as always

Reactions:[TheGreatMcMurphy](https://xdaforums.com/posts/89561682/reactions)

#### nmyshkin

##### Recognized Contributor

> [NookSimpleTouchFan2024 said:](https://xdaforums.com/goto/post?id=89561682)
> 
> hey everyone...  
> so i finally got my used Nook from ebay and i made a backup with Nook Manager... then i went to make a 2gb micro sd carrd \[ i tried both Win32diskImager, and Rufus\] using RUN AS ADMIN on both programs i have but i am unable to get the nook to turn on with the micro sd card installed... all 3x sd cards I have bought are SanDisk 32gb. I followed the instructions to the letter... and yes i even extended the unallocated space to make room for a backup or two on the micro sd card\[the orginal +the US-REG backup from here which i ultimately wanna use to restore the reader with\]...  
>   
> I had mentioned i have multiple sd cards... they are all the same.. SanDisk 32gb, from Walmart... they are used as follows...  
> 1 = the Nook Manager Nook backup Image  
> 1 = CWM micro-SD  
> 1 = for side loading books...  
>   
> but just to recap... i have been unable to get the CWM micro sd card to load up when holding the power button down on the nook simple touch \[BNRV300\]... any help would be appreciated, thank you as always
> 
> Click to expand...
> 
> Click to collapse

So...the NookManager card works, right? And, presumably a 32 GB card works for storage?  
  
I dunno...there was a time when people were warning about 32 GB cards as not working in early Nook devices. 16 GB seemed to be the limit. But I know I have come across people saying they were working fine.  
  
FWIW, this is what I get with my CWM card in MiniTool Partition Wizard for a right-click on the partition and a look at "Properties":  
![1718404251728.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/1718404251728.png "1718404251728.png")  
Do you by any chance have something smaller to try out?

Last edited:

Reactions:[TheGreatMcMurphy](https://xdaforums.com/posts/89561722/reactions)

#### NookSimpleTouchFan2024

##### Member

> [nmyshkin said:](https://xdaforums.com/goto/post?id=89561722)
> 
> So...the NookManager card works, right? And, presumably a 32 GB card works for storage?  
>   
> I dunno...there was a time hen people were warning about 32 GB cards as not working in early Nook devices. 16 GB seemed to be the limit. But I know I have come across people saying they were working fine.  
>   
> Do you by any chance have something smaller to try out?
> 
> Click to expand...
> 
> Click to collapse

i tried using a 16gb micro sd card \[PNY\] but i was unsuccessful with getting that card to load up anything... Nook manager included.  
  
should i try partitioning one of the 32gb micro sd cards to a smaller size and then maybe see if it will load up...? also... could i use one of the US-REG backups with Nook manager and re-image the NST that way, or does it have to be via CWM?

#### nmyshkin

##### Recognized Contributor

> [NookSimpleTouchFan2024 said:](https://xdaforums.com/goto/post?id=89561729)
> 
> i tried using a 16gb micro sd card \[PNY\] but i was unsuccessful with getting that card to load up anything... Nook manager included.  
>   
> should i try partitioning one of the 32gb micro sd cards to a smaller size and then maybe see if it will load up...? also... could i use one of the US-REG backups with Nook manager and re-image the NST that way, or does it have to be via CWM?
> 
> Click to expand...
> 
> Click to collapse

We crossed posts. Look back above to an edit I made.  
  
I don't recommend a clone with NookManager because it results in a mismatch of hardware vs. software in terms of serial number, MAC address, etc. This may or may not be any longer a problem with a registered device. But I don't know. You'd be far better served by solving this CWM issue.  
  
Perhaps try burning the 128 MB image?

Last edited:

Reactions:[TheGreatMcMurphy](https://xdaforums.com/posts/89561739/reactions)

#### NookSimpleTouchFan2024

##### Member

> [nmyshkin said:](https://xdaforums.com/goto/post?id=89561739)
> 
> We crossed posts. Look back above to an edit I made.  
>   
> I don't recommend a clone with NookManager because it results in a mismatch of hardware vs. software in terms of serial number, MAC address, etc. This may or may not be any longer a problem with a registered device. But I don't know. You'd be far better served by solving this CWM issue.  
>   
> Perhaps try burning the 128 GB image?
> 
> Click to expand...
> 
> Click to collapse

  
  
thank you for the picture... i have not tried using FAT16... Ive been only using FAT32 formatted cards via mini partion \[even though i am sure the 32gb cards ive been buying are formatted fat32 by default\], better to be safe than sorry i feel like...i will try this next.

Reactions:[TheGreatMcMurphy](https://xdaforums.com/posts/89561754/reactions)

#### NookSimpleTouchFan2024

##### Member

> [nmyshkin said:](https://xdaforums.com/goto/post?id=89561764)
> 
> Well, I didn't do anything special with that card to begin with. I'm just saying that's what it shows.
> 
> Click to expand...
> 
> Click to collapse

  
\*\*UPDATE\*\*  
I got it working!!  
  
your last message or two got me thinking... and what ultimately ended up helping and working int he end... the card size and card manufacturer really make or break it with these readers... here is what worked for me....  
  
Sandisk 32gb micro sd **\[formatted with a 2gb partition as FAT/FAT16**\], then opened Windisk32Imager \[RUN AS ADMIN\] opened the 2gb image "2gb\_clockwork-rc2", then write image to designated micro-sd, following the instruction as per making the folder "clockworkmod" then the nested folder "backup" and then drag and dropping the US-REG folder in the nested "backup" folder... then powered down the NST, inserted the sd card, and made a back up...  
  
Thank You a million times over for all of this work... IT WORKS!!!!!

Last edited:

Reactions:[TheGreatMcMurphy and nmyshkin](https://xdaforums.com/posts/89561814/reactions)

#### NookSimpleTouchFan2024

##### Member

so it's been almost 20hrs or so since i got my reader, a new battery, 3x Sandisk Micro Sd cards and started this whole ebay project haha.. and so far the NST is still at 100% battery life almost a day later. In fact I find the reader works better than what it was brand new and walking out of B&N.  
  
I was considering using this with a Nook Simple Touch with Glowlight, would the same US-REG work with the glowlight feature/backlight to read at night or int he dark? I only tested this on a BNRV300 standard NST model first.  
also, included is a picture of the micro sd cards I have bought and used from Walmart for Phoenix Project as well as NookManager in case anyone was looking for a good micro sd card to try this out on.

#### Attachments

- [![sandisk 32gb micro sd.jpg](https://xdaforums.com/data/attachments/4600/4600300-ac28de2c7fd5690304f2fb95d4f82276.jpg)](https://xdaforums.com/attachments/sandisk-32gb-micro-sd-jpg.6113831/)
	sandisk 32gb micro sd.jpg
	133.7 KB · Views: 148

Last edited:

Reactions:[TheGreatMcMurphy](https://xdaforums.com/posts/89563169/reactions)

#### nmyshkin

##### Recognized Contributor

> [NookSimpleTouchFan2024 said:](https://xdaforums.com/goto/post?id=89563169)
> 
> I was considering using this with a Nook Simple Touch with Glowlight, would the same US-REG work with the glowlight feature/backlight to read at night or int he dark? I only tested this on a BNRV300 standard NST model first
> 
> Click to expand...
> 
> Click to collapse

Yes, just be sure to download and restore the version for the glowlight. Even if you didn't it would probably more or less work since the firmwares are the same, but since I bought and registered an actual glowlight you might as well take full advantage of that.  
  
Edit: having said that, I should also point out that the files are not identical as the MD5 strings show. This is because the different hardware has interacted differently with the firmware during setup and registration, so if you have a BNRV350 you should use the NSTG file just to avoid any issues

Last edited:

Reactions:[TheGreatMcMurphy](https://xdaforums.com/posts/89563252/reactions)

#### NookSimpleTouchFan2024

##### Member

> [nmyshkin said:](https://xdaforums.com/goto/post?id=89563252)
> 
> Yes, just be sure to download and restore the version for the glowlight. Even if you didn't it would probably more or less work since the firmwares are the same, but since I bought and registered an actual glowlight you might as well take full advantage of that.  
>   
> Edit: having said that, I should also point out that the files are not identical as the MD5 strings show. This is because the different hardware has interacted differently with the firmware during setup and registration, so if you have a BNRV350 you should use the NSTG file just to avoid any issues
> 
> Click to expand...
> 
> Click to collapse

i just realized you uploaded files for both readers as NSTG = G= Glowlight, yup...real bright moment for me lol...  
  
also if you re name any part of the folder name in the backup0folder..NO-SPACES in the folder name when restoring for what its worth lol

Reactions:[TheGreatMcMurphy](https://xdaforums.com/posts/89563281/reactions)

#### NookSimpleTouchFan2024

##### Member

> [nmyshkin said:](https://xdaforums.com/goto/post?id=89563252)
> 
> Yes, just be sure to download and restore the version for the glowlight. Even if you didn't it would probably more or less work since the firmwares are the same, but since I bought and registered an actual glowlight you might as well take full advantage of that.  
>   
> Edit: having said that, I should also point out that the files are not identical as the MD5 strings show. This is because the different hardware has interacted differently with the firmware during setup and registration, so if you have a BNRV350 you should use the NSTG file just to avoid any issues
> 
> Click to expand...
> 
> Click to collapse

SO far I have tested this on 2 NST readers... I have had a little trial and error but mainly this was me getting use to how things work... I might test this out on a NSTG possibly at some point and what not....but so far everything is on point!!  
  
but yeah, when re-naming a folder in the "backup" folder..NO-SPACES....Otherwise an MD5 mismatch error will pop up... It's best like you have it set up, just drag and drop the firmware/REG folder you want directly to the Micro sd card and if possible don't mess with the folder name unless you really want to..again NO SPACES with the folder name.

Reactions:[TheGreatMcMurphy and nmyshkin](https://xdaforums.com/posts/89563290/reactions)

#### TheGreatMcMurphy

##### New member

I wanted to thank you, [@nmyshkin](https://xdaforums.com/m/5562185/) for your effort and dedication into this project, it is obviously a labor of love for this incredible e-reader.  
  
To give you a little bit of context, I got my first NST about 6 years ago, and I started tinkering with it, I rooted it, and I added ReLaunch for a UI. It worked great. I loved the freedom of side loading EPUBs, PDFs, etc. The NoRefresh feature was amazing.  
  
Unfortunately, I suffer from severe OCD, which means that I got obsessed with this device, and I got a few of them (NST and NSTG), and stored them as backups.  
  
Life got really busy and I had to deal with some challenging things, so I lost track a little bit of the NST. But recently I went back to it, and I found out that Barnes and Noble were disconnecting the Registration Servers. I knew that an unregistered NST consumes a lot of battery, and I become really disappointed with myself for not registering all those NST and NSTG devices.  
  
But then I found this wonderful project, and I wanted you to sincerely thank you for all the time you have put into it.  
  
I will be posting a few questions later as well.

Last edited:

Reactions:[nmyshkin](https://xdaforums.com/posts/89564586/reactions)

### Similar threads

### Top Liked Posts

- There are no posts matching your filters.
- 1
	**[nmyshkin](https://xdaforums.com/m/nmyshkin.5562185/)**
	> [Cenotaph2000 said:](https://xdaforums.com/goto/post?id=90210433)
	> 
	> Is there any similar projects for Nook Glowlight? The one with the soft touch rubber around and more importantly, no SD cards?  
	> Can this method be adapted for that ereader?
	> 
	> Click to expand...
	> 
	> Click to collapse
	If anyone has done something like this for the BNRV500 they are not sharing it.  
	  
	The lack of an sdcard makes everything more difficult. Also a lot of people did a LOT of work on the NST in the now-distant past. Part of that was the time period itself, but also no subsequent e-ink reader seems to have captured the imagination of so many people since the NST.  
	  
	In theory the UI could be changed (maybe even using some of the same apps), but it would be a lot of work. Someone would have to love the device enough to adopt it.  
	  
	There is also the issue of registration. That ship has sailed and I don't know whether the device has the same battery issue as the NST when not registered.
	[View](https://xdaforums.com/posts/90210818/)
- 6
	**[nmyshkin](https://xdaforums.com/m/nmyshkin.5562185/)**
	**"What is the Phoenix Project?"**  
	  
	It is an effort to provide a variety of options for the continued use of the Nook Simple Touch (and with Glowlight) after the end-of-life action by B&N, June 2024.  
	  
	The project has three phases:  
	  
	1\. CWM backup images of registered devices running FW 1.2.2, not rooted, including the US and UK versions.  
	2\. CWM backup images of registered devices running FW 1.2.2, rooted, with a heavily modified UI, additional reader options and much custom software.  
	3\. CWM backup images of devices running FW 1.2.2 or 1.1.5, rooted, with the B&N system removed and replaced with with a heavily modified UI, various reader options and much custom software.  
	  
	**"Why bother with all this? Can't I just skip registration on an old device and use it as-is?"**  
	  
	You can certainly do that, but I do not recommend it. The device (with the B&N software intact) was designed to function with occasional contact with the B&N servers, especially during initialization. If that contact is frustrated (no registration) the system expends a lot of time (read: battery power) trying to sort out the lack of contact. My experiments with the same device registered, and not registered (skipped OOBE) show a dramatic difference in battery charge life. Starting with a full charge and left to idle for 7 days, a registered device dropped to 89%. A device which was not registered was dead by the time I checked it after 7 days. So if you want to use the B&N stuff (reader, library, dictionary) as it was intended (minus purchasing and downloading ebooks from B&N), the device needs to be registered. Hence phase 1 of this project.  
	  
	Some people may like the basic B&N system but also have a desire for more capability in the device (read other formats, etc.). And some of those "some" may go on to root the device and customize to their liking. Others may be less sure of their hacking skills or simply don't want to get their hands dirty. That's what phase 2 of this project is for. It's a heavily customized e-reader which uses the basic B&N system (it's registered) but also includes additional reader options and many new features. It may not suit everyone.  
	  
	Properly removing the B&N system and installing alternative apps (phase 3) gives power consumption similar to a registered device. Without the B&N system, alternative readers, dictionaries, etc., become a necessity. I have created 4 options which are the same except for the principal reader app. I've used reader apps which have been frequently mentioned on the forum as worthy of use on the device. If you're looking for something other than B&N, one of these may suit you.  
	  
	**Getting your** **in a row**  
	  
	All of the magic depends on ClockworkMod (CWM). If you don't have a CWM card for the NST/G, making one is perhaps the most "difficult" thing you'll do for the project. I will guide you through that now. If you already have a card or don't need/want the hand-holding, take your prepared CWM card and move on to phases 1, 2, 3 and decide what might be the best fit for you.  
	  
	**Make a CWM card**  
	  
	1\. Not all microSDcards are created equal. The vast majority (unless defective) are fine for storage. A subset of these is better for creating bootable cards. I've always used SanDisk class 10 cards and have never had problems, but I have spent a lot of time trying to help others who are using whatever they had sitting around. If you have problems, it's almost always the card itself.  
	2\. You will want at least a 1 GB sdcard for your CWM card so there will be room for backups. Backups for the stock system are about 240 MB while those for the custom systems are more than 300 MB.  
	3\. Download the zip for either the [2 GB](https://www.mediafire.com/file/fll6rassbgez91v/sd_2gb_clockwork-rc2.zip/file) (must have a 2 GB card or larger) or [128 MB](https://www.mediafire.com/file/9jl7aiu1k04lafd/sd_128mb_clockwork-rc2.zip/file) (minimum 1 GB card) sdcard version. Unzip to reveal img file. If you do not already have some kind of disk imaging software and you are using Windows, download [win32diskimager](https://www.mediafire.com/file/stzqsp59ixln6z1/win32diskimager-v0.9-binary.zip/file) and unzip. The application runs directly from the.exe file in the folder and does not require installation.  
	  
	**Q.** Why are there two different versions of CWM?  
	**A.** When someone creates a disk image (.img file) they are trying to make portable an exact copy of their card for others to reproduce. Sometimes this is because the formatting on the card has special flags set to make it bootable. The actual files for CWM take up very little space (about 4.6 MB), but there should be room on a card for flashable zips, backups, etc. "Room" means empty space. That will be part of the image. How big a file do you want someone to have to download which is mostly empty space? Probably the smallest possible, without a lot of empty space. Hence the two sizes, although without further efforts the 128 MB image is not useful at all for what we want to do. But we can fix that. Keep in mind that a larger image takes longer to write to the card.  
	  
	4\. Insert the sdcard you want to use for CWM into the slot on your PC.  
	5\. Run win32diskimager. To do so, right-click on the \*.exe file in the folder you unzipped and choose "Run as Administrator". *This appears to be important, so don't just double-click on the \*.exe file and hope for the best*.  
	![win32diskimager1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/win32diskimager1.png "win32diskimager1.png")  
	Check to be sure the disk listed is the same letter as the sdcard in the slot. Navigate to the.img file you downloaded for CWM and then click on "Write".  
	![win32diskimager2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/win32diskimager2.png "win32diskimager2.png")  
	  
	After the image is written the card will probably have a name like "boot". I suggest you rename it "CWM" just so it's obvious when you put it in your PC what you're looking at.  
	  
	If you used the 2 GB image on a larger card and don't care about recovering additional space, you can skip what's next and go on to #6. If you used the 128 MB image on a 1 GB card or larger (or used the 2 GB and do care about the extra space), keep reading.  
	  
	When the disk image is written the sdcard is defacto partitioned. The primary partition is either 2 GB or 128 MB, depending on which version you downloaded. The rest of the space is "unallocated" (wasted). Windows will not see this and will say your card is either 2 GB or 128 MB after writing the image. To reclaim the entire card for use (adding zips to flash, storing backups, for example) download [MiniTool Partition Wizard](https://www.mediafire.com/file/0dax0o5yj7epxjz/pw102-free.exe/file). Install and run with your CWM sdcard in the PC slot (do not update the program if asked to do so).  
	![partitionwizard1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard1.png "partitionwizard1.png")  
	At the lower part of the screen you will see the sdcard listed (compare drive letter with what Windows has assigned to your sdcard--write this letter down now, just in case).  
	![partitionwizard2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard2.png "partitionwizard2.png")  
	Right-click on the primary partition of the sdcard. Select "Extend" from the context menu.  
	![partitionwizard3.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard3.png "partitionwizard3.png")  
	  
	Drag the resizing arrow all the way to the right so that the primary partition occupies the entire sdcard capacity. Click on OK.  
	![partitionwizard4.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard4.png "partitionwizard4.png")  
	On the main screen click on "Apply". Exit when done.  
	![partitionwizard6.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/partitionwizard6.png "partitionwizard6.png")  
	The sdcard is now fully usable with only a single partition. Do not click randomly on other stuff in the partition wizard. You could seriously mess up your PC hard drive if you do.  
	  
	Occasionally after repartitioning the card becomes invisible to Windows although it is fully functional. That can be easily fixed. In Windows Explorer click in the top menu "System" section on "Manage". A "Computer Management" window opens and there you want to click in the side bar on "Disk Management". Information about the various storage devices fills the panel. The sdcard is down at the bottom. In the image mine is OK, showing as drive "E". If you are doing this, it's because your drive letter is missing. Right-click on the box representing the drive and a context menu will open. Select "Change Drive Letter and Paths".  
	![fixcard1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/fixcard1.png "fixcard1.png")  
	Again, in my image the drive letter shows as "E", but yours will be missing (i.e., the box is blank). Click on "Add".  
	![fixcard2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/fixcard2.png "fixcard2.png")  
	Select the first option,"Assign the following drive letter" and then choose from the drop-down whatever the drive letter was for the sdcard before these evil things befell you. "OK" your way out of the various windows. You'll see your sdcard again represented in Windows Explorer.  
	  
	6\. We're going to add a couple of folders to the CWM card that would normally be generated when you make your first backup. By adding them now we can save some card swapping. Viewing the contents of your CWM card on your PC, make a folder on the card called "clockworkmod". Inside that folder make another folder called "backup". Be sure to get those folder names correct.  
	![cwm_files1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/cwm_files1.png "cwm_files1.png")  
	  
	![cwm_files2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/cwm_files2.png "cwm_files2.png")  
	  
	Done! I promise you, that was the hardest part.  
	  
	**Acknowledgements**  
	  
	It's been over 10 years since the Nook Simple Touch arrived on the scene. Many of the people who did important work on the device are long gone from the forum (with one exception) and in some cases long gone from XDA. We still use their discoveries, insights and creations all the time and it seems right to give them the credit that is due for their efforts. I know this list won't have everyone in it (I'll add more when I realize I've left someone out!), but I feel a personal debt to these and more. None of this could have been done without them.  
	  
	[@jeff\_kz](https://xdaforums.com/m/4935755/), [@mali100](https://xdaforums.com/m/499922/), [@verygreen](https://xdaforums.com/m/3654172/), [@marspeople](https://xdaforums.com/m/4163417/), [@Renate](https://xdaforums.com/m/4474482/), [@wskelly](https://xdaforums.com/m/3101826/), [@pinguy1982](https://xdaforums.com/m/4636254/), [@ros87](https://xdaforums.com/m/3047119/), [@nivieru](https://xdaforums.com/m/5548765/), [@Yura80](https://xdaforums.com/m/2711583/), [@similardilemma](https://xdaforums.com/m/3893866/), [@Ahmed hamouda](https://xdaforums.com/m/4514149/) and the many patient people at the Google Groups Tasker forum
	[View](https://xdaforums.com/posts/89533446/)
	4
	**[nmyshkin](https://xdaforums.com/m/nmyshkin.5562185/)**
	**The Phoenix Project--Phase 1--The stock system, registered, unrooted  
	![nst_stock.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/nst_stock.png "nst_stock.png")**  
	  
	Nook Simple Touch (BNRV300)  
	  
	[NST-US-Stock-Reg.zip](https://www.mediafire.com/file/aprvg4uw9fx13le/NST-US-Stock-Reg.zip/file) (133 MB)  
	\[MD5: 67e99606ec178434463ab318b4476e73\]  
	  
	[NST-UK-Stock-Reg.zip](https://www.mediafire.com/file/ge10qb1wcyxqxiq/NST-UK-Stock-Reg.zip/file) (133 MB)  
	\[MD5: 5495a88f33fe490cca19f0e5b4d2ec26\]  
	  
	Nook Simple Touch w/Glowlight (BNRV350)  
	  
	[NSTG-US-Stock-Reg.zip](https://www.mediafire.com/file/6cyxa1z7h3qezp6/NSTG-US-Stock-Reg.zip/file) (133 MB)  
	\[MD5: 2f55ba12707abdaa22be63b595e408aa\]  
	  
	[NSTG-UK-Stock-Reg.zip](https://www.mediafire.com/file/9zmw2v2ogzm0hcj/NSTG-UK-Stock-Reg.zip/file) (133 MB)  
	\[MD5: 31b8160912481a22d2545e93c12f9885\]  
	  
	**"What are these?"**  
	  
	Each download zip contains a CWM backup of a stock, registered, unrooted NST/G. This presents the device as it was meant to be, minus the connectivity with B&N to purchase/download books (no longer possible after June 2024). It will boot up as a newly registered device. You'll only need to set the time format and zone. You can side-load epubs. You can download epubs on your PC from your library Overdrive/Libby system, and then transfer them to the device using Adobe Digital Editions (for Windows I recommend ver. 3).  
	  
	The registered backup was made by performing a factory re-image on the device and updating to FW 1.2.2. The device was registered to a new account opened solely for this purpose. Once all that was done, a CWM backup was created (/boot, /system, /data, /cache). Restoring this backup to another device leaves the /rom partition untouched so device hardware information (serial #, MAC address, etc.) remains unchanged.  
	  
	**"Who are these for?"**  
	  
	These backups are for people who have purchased an unregistered device after B&N ends registration for the NST/G in June of 2024. Running the device in an unregistered state with all the B&N stuff intact sets up a large amount of hidden activity which drains the battery quickly. Since it will be impossible to register an NST/G after June 2024, this is an attempt to ensure that the devices remain useful as designed, except for purchasing/downloading books from B&N.  
	  
	These backups may also be useful to people who discover an NST/G at the bottom of a sock drawer and wonder if they can still use it. Only a device registered with FW 1.2.2 is likely to still work properly, so if the device has not been updated, this may be an avenue to restore it to a useful state.  
	  
	Finally, these may be useful to people who want to start with the working stock system and root and customize to their own liking.  
	  
	**"What's the difference between the US and UK versions?"**  
	  
	There is no hardware difference. Any device can work as either. The US version splash screen at boot says "Read Forever". The UK version has a multilingual text display. In registering the UK version you set the device to display in one of the supported languages (English, French, Spanish, German, Italian). When I registered I chose "English", but you can change this in Settings. However...  
	  
	The other main difference is the dictionary. The US version uses the Merriam-Webster Collegiate while the UK version uses a version of the Oxford English dictionary. People have their preferences. Unfortunately there is no way to get a non-English dictionary for the UK version to match a particular system language you might select for the device. There is a Settings option for additional dictionaries but it doesn't seem like it ever worked as there has never been any sign of these dictionaries on the various forums.  
	  
	Also, while it is not possible to do anything with the dictionaries for the stock reader on non-rooted devices, it is possible to swap dictionaries on rooted devices-- but only for the US version, as far as I know. The dictionary formats for the different versions are not the same and while I have been able to produce a number of non-English dictionaries for the US version, I have had no luck duplicating the format of the dictionary for the UK version. So what I am saying is that in terms of non-English capability, the UK version is basically just a show horse. System text will be in whatever language you select but you are stuck with an English dictionary whether or not you eventually root and customize--unless you were to remove all the B&N stuff.  
	  
	**Warnings**  
	  
	I cannot guarantee that these will work for you. They work for me.  
	  
	**"What do I have to do?"**  
	  
	The briefest possible description is: make a backup, wipe your device, restore the downloaded backup, reboot. Here's a little more detail, followed by a lot more detail (real instructions!):  
	  
	1\. Download the zip package of your choice and unzip  
	2\. Copy the folder from the zip to the /clockworkmod/backup folder on your CWM card (didn't make one? go back to post #1)  
	3\. Backup your device (CWM)  
	4\. Wipe the device (CWM)  
	5\. Restore the downloaded backup (CWM)  
	6\. Reboot!  
	  
	**Note: there is no specific preparation required to use these backups. As long as the device is in working order and has about a 60% battery charge, you're good to go. It doesn't matter whether the device was currently registered in some older firmware, rooted, skipped OOBE. None of that matters as everything will be wiped.**  
	  
	**To Restore an NST/G backup (the deets!)**  
	  
	1\. Power down  
	2\. Insert the CWM card with the backup image you downloaded  
	3\. Power up.  
	  
	If CWM fails to reach the first menu screen (i.e., is stuck on the splash screen), press the lower right hardware button.  
	  
	To navigate in CWM: Upper Left hardware button > previous menu, Upper Right hardware button > move up, Lower Right hardware button > move down, "n" button > select  
	  
	4\. Select backup/restore  
	5\. Press "n" to backup your device as it is now  
	![Image1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image1.png "Image1.png")  
	Backups end up in folders with dates for names, inside /clockworkmod/backup. You can rename these folders with the card in your PC. For example, you might rename this folder as "original" or similar (no spaces allowed in folder name). At the conclusion of the backup you should be returned to the main menu.  
	  
	6\. Select wipe data / factory reset  
	7\. Confirm  
	![Image2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image2.png "Image2.png")  
	If after any wipe or restore operation CWM freezes, repeatedly press and hold the power button until the device reboots back into CWM. **Don't panic**. Hold the power button while counting to ten. Release it. If nothing happens, count to ten and try again. Eventually the device will reboot. This is the tool we have and it's not perfect, but it does work.  
	The device is accessible to ADB while running CWM. If you plug in the USB cable once CWM is running you can connect:  
	Code:
	```
	adb devices
	```
	This should result in a "11223344556677 recovery" response. You're connected.  
	  
	Now, when CWM inevitably freezes after a wipe or restore, you can simply type:  
	Code:
	```
	adb reboot
	```
	No struggling with the power button trying to get an interrupt through the haze of the freeze. The device will simply reboot back into CWM and you continue with the next step.  
	  
	When you get to the last step (the "restore") and are ready for the final reboot, swap out the CWM card for your storage sdcard, then once again type:  
	Code:
	```
	adb reboot
	```
	As soon as the screen turns white or when you see that your PC has "lost" recognition of the device as connected, remove the USB connector.
	  
	8\. Select advanced  
	9\. Select Wipe Dalvik Cache  
	10\. Confirm  
	![Image3.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image3.png "Image3.png")  
	If CWM has frozen after the wipe, repeatedly press and hold the power button until the device reboots.  
	  
	11\. Select backup and restore  
	12\. Select restore  
	13\. Select folder to restore (you copied one onto the card, remember?)  
	14\. Confirm.  
	![Image4.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image4.png "Image4.png")  
	15\. When restore is complete, remove the CWM card from your device and replace it with your regular storage sdcard if you are using one.  
	16\. Press the "n" button to reboot.  
	![CWM13.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/CWM13.png "CWM13.png")  
	If CWM has frozen after the restore, repeatedly press and hold the power button until the device reboots.  
	  
	17\. Swipe the screensaver unlocker. Press the "n" button to bring up the QuickNav bar. Tap on "Settings". There tap on "Time" and select your desired time format and time zone. If by chance the time displayed on the device is not correct, you might try connecting to your home WiFi network briefly to see if that sorts it (Settings>Wireless).  
	18\. If you're not familiar with how the device works, there are two user guides in the "Library". Most navigation is done via the QuickNav bar (press the "n" button), but if you're on the home screen you can access the most recent read by tapping on the book cover under "Reading now".  
	19\. Just a final reminder: none of the stuff about shopping or previewing or downloading, etc., works. B&N has severed ties with these devices as of June 2024 except for a minimal server connection which allows the devices to continue operating without a fault if WiFi is used. But as I said, if you are using the stock configuration, there really is no need for WiFi at all.  
	  
	You're done!
	[View](https://xdaforums.com/posts/89533447/)
	4
	**[nmyshkin](https://xdaforums.com/m/nmyshkin.5562185/)**
	**The Phoenix Project--Phase 3--B&N system removed, new software added, with new UI and more**  
	  
	![phase3.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/phase3.png "phase3.png")  
	  
	Featuring AlReader  
	[NST-US-newUI-AlR115.zip](https://www.mediafire.com/file/m7sab0eu0b4ogxd/NST-US-newUI-AlR115.zip/file) (236 MB) (Nook Simple Touch, BNRV300)  
	\[MD5: 37d127ac2a2916585d0fbb49e1357006\]  
	[NSTG-US-newUI-AlR115.zip](https://www.mediafire.com/file/gw62pl7p7n14ot7/NSTG-US-newUI-AlR115.zip/file) (239 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
	\[MD5: c4b28bbbd4041d2db60c7168c583ffec\]  
	***Experimental RTL builds*** (see **Spoiler** below)  
	[NST-US-newUI-AlR115RTL.zip](https://www.mediafire.com/file/m8dxy4t51fv9nmo/NST-US-newUI-AlR115-RTL.zip/file) (294 MB) (Nook Simple Touch, BNRV300)  
	\[MD5: e7f6c15e103807866232397e81f93ea7\]  
	[NSTG-US-newUI-AlR115RTL.zip](https://www.mediafire.com/file/fru1g9ox8bug74s/NSTG-US-newUI-AlR115-RTL.zip/file) (299 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
	\[MD5: 79990bc17eb9eef7d60552a6dfdbd5e8\]  
	  
	Featuring Cool Reader  
	[NST-US-newUI-CR115.zip](https://www.mediafire.com/file/hred14nka0zlonb/NST-US-newUI-CR115.zip/file) (264 MB) (Nook Simple Touch, BNRV300)  
	\[MD5: 5e185aa3e721a2457a3e8bf436e1b7b0\]  
	[NSTG-US-newUI-CR115.zip](https://www.mediafire.com/file/h8ayu98px0ry7g7/NSTG-US-newUI-CR115.zip/file) (237 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
	\[MD5: 1d4c0c1d5659c7b5657ee2d848b66fec\]  
	  
	Featuring FBReader  
	[NST-US-newUI-FB.zip](https://www.mediafire.com/file/hmhszuvooja599v/NST-US-newUI-FB.zip/file) (234 MB) (Nook Simple Touch, BNRV300)  
	\[MD5: a759f1ccd82d8cf9dabe9132b627133a\]  
	[NSTG-US-newUI-FB.zip](https://www.mediafire.com/file/mxvblydxn2izxm8/NSTG-US-newUI-FB.zip/file) (235 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
	\[MD5: 5a88fe9f74b8aa831228ada116523611\]  
	  
	Featuring Mantano Reader  
	[NST-US-newUI-Man.zip](https://www.mediafire.com/file/gflogiqevpz212f/NST-US-newUI-Man.zip/file) (241 MB) (Nook Simple Touch, BNRV300)  
	\[MD5: 81a1f73771a57a9069e886869f13abaf\]  
	[NSTG-US-newUI-Man.zip](https://www.mediafire.com/file/u48wixcnscvoihq/NSTG-US-newUI-Man.zip/file) (242 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
	\[MD5: 6a629f1a478f2a681aecba230f50a988\]  
	  
	[NST User Guide](https://www.mediafire.com/file/dngf48fie1bw21j/Al_UserGuide115.pdf/file) (w/AlReader)  
	[NSTG User Guide](https://www.mediafire.com/file/4j2vh3yp9lm9qf8/Al_UserGuide_GL115.pdf/file) (w/AlReader)  
	[NST User Guide](https://www.mediafire.com/file/55lp0d16m07r6md/Al_UserGuide115RTL.pdf/file) (w/AlReader RTL build) \[see Spoiler below\]  
	[NSTG User Guide](https://www.mediafire.com/file/wta29umvgk0ckl0/Al_UserGuide_GL115RTL.pdf/file) (w/AlReader RTL build) \[see Spoiler below\]  
	[AlReader Help File](https://www.mediafire.com/file/7gmghioslo5crgl/AlReaderHelp.zip/file) (HTML, tr.)  
	[NST User Guide](https://www.mediafire.com/file/oltdn9932wf8dyd/CR_UserGuide115.pdf/file) (w/Cool Reader)  
	[NSTG User Guide](https://www.mediafire.com/file/ugka1aedb7oj6vd/CR_UserGuide_GL115.pdf/file) (w/Cool Reader)  
	[NST User Guide](https://www.mediafire.com/file/1zoh2747et57b4b/FB_UserGuide.pdf/file) (w/FBReader)  
	[NSTG User Guide](https://www.mediafire.com/file/i2miwi73eokkrpv/FB_UserGuide_GL.pdf/file) (w/FBReader)  
	[NST User Guide](https://www.mediafire.com/file/del81yd40dwnr4n/M_UserGuide.pdf/file) (w/Mantano)  
	[NSTG User Guide](https://www.mediafire.com/file/9wz4sepjecv97xd/M_UserGuide_GL.pdf/file) (w/Mantano)  
	  
	**Note:** while the User Guides actually look rather good in EBookDroid, they contain some embedded hyperlinks which EBookDroid can't handle. Also, they were made with interaction in mind, so better to display them on your PC with your device near at hand. These are NOT the old B&N User Guides and contain important information about the new software, setup, widgets, etc.  
	  
	**"What are these?"**  
	  
	Each download zip contains three components:  
	1) a CWM backup of a pre-configured NST/G  
	2) the contents of an sdcard used for storage  
	3) the contents of the /media partition (i.e., the "Nook" drive).  
	  
	The pre-configured NST/G was made by performing a factory re-image on the device and updating to FW 1.2.2 or FW 1.1.5 (see "Spoiler" below). The device was rooted with an updated NookManager card ("Traditional" version). NookManager was used to remove the B&N account and system. The kernel was updated for multi-touch, NoRefresh, and USB Host (including Audio). Finally, custom applications were added to create the new UI. Once all the configuration was done, a CWM backup was created (/boot, /system, /data, /cache). Restoring this backup to another device leaves the /rom partition untouched so device hardware information (serial #, MAC address, etc.) remains unchanged. Since CWM cannot backup /media or /sdcard, separate folders containing those files are included in the zip (an sdcard is required for all of this to work properly).  
	  
	There are currently 5 versions (for both the standard NST and also the NSTG) which differ by the principal reader app (for epubs and perhaps a few other formats) and custom software needed for the UI:  
	  
	AlReader  
	AlReader, RTL version  
	Cool Reader  
	FBReader  
	Mantano Reader  
	  
	Colordict is integrated as a dictionary source for the principal reader apps and both the Merriam-Webster and Oxford English dictionaries are provided. Other dictionaries in StarDict format can be added.  
	  
	Additional reader apps on all versions include customized versions of Amazon Kindle, EBookDroid and Perfect Viewer.  
	  
	**Please note**: **As of May 26, 2025, Amazon will no longer support downloads (**[**dictionaries**](https://www.mediafire.com/folder/dww8eduzegz12/Kindle+Dictionaries)**, public library books) from this old app. It sounds as if registered copies will continue to function in offline mode as mobi readers and preliminary tests suggest new registrations may still be possible. Directions for uninstalling the Kindle Library and Amazon Kindle apps are in the User Guide.**  
	  
	Most apps have been lightly pre-configured to make for a better first experience and reduce the amount of time and effort it takes to get up and running. There are a few exceptions and this information is covered in more detail (along with initial setup instructions) in the "User Guides" for each version (separate download above).  
	  
	Unfortunately it is not possible to try out one version and then replace the principal reader app or add another reader app and not break the UI components since each reader app handles cover images differently. Of course you can always add a reader app to try it out (the various UI features will not work for it) and then perhaps decide you like it better. In that case you would then have to do a complete install of the version with that reader (including the files in /media and on the sdcard) for a fully functional system.  
	  
	If you have no experience with any of the principal reader apps, the chart below may be helpful but is certainly not an exhaustive comparison of the various features, strengths, weaknesses, etc. In my opinion, the reader app most like the B&N stock reader in terms of simplicity and format capabilities (except for font support) is Mantano, but its screen UI elements are quite small.  
	  
	![E-reader apps.png](https://xdaforums.com/attachments/e-reader-apps-png.6257740/ "E-reader apps.png")  
	  
	In the change from FW 1.1.x to 1.2.x, B&N altered the EPD (Electronic Paper Display) controller code. This affects how and when the e-ink screen is refreshed. It is the reason why there are two versions of the NoRefresh app. Unfortunately, both Cool Reader and AlReader ended up on the older side of this change and were never updated. That means the "partial refresh" feature which they have does not work with FW 1.2.x  
	  
	What, exactly, does "partial refresh" mean? If you're not familiar with the stock reader (absent from these builds) the easiest way to describe "partial refresh" is to say that the text on a page does a sort of rapid dissolve, to be replaced by the text of the new page. This continues along for 5-6 pages. At that point a total screen refresh is done. This is detected as a rather quick flash of black over the entire screen and the appearance of the next page. In a reader app lacking the "partial refresh" ability, each page change comes with a flash or flicker of this sort. For some people (including me) this is visually distracting. The NoRefresh app can be used to eliminate this, but since the screen never refreshes, there can be ghosting artifacts eventually (they clear up, of course, once out of NoRefresh mode). Some people are more sensitive to this than others. Also, because the NoRefresh app flattens the grey-scale to two colors, font antialiasing gets lost and text can look a tiny bit rough. Again, some people are more bothered by this than others.  
	  
	So it's desirable for most to have the option to use "partial refresh". The only way to get that with Cool Reader or AlReader is to return to FW 1.1.x  
	  
	The early Glowlight models were shipped with FW 1.1.5. This is a Glowlight-exclusive firmware but it does contain little bits of what would eventually happen: the merging of the firmwares. I originally intended to use FW 1.1.2 on the non-Glowlight version but it was impossible to make the needed patches to run NookTouch ModManager. Before you say "so what?", a little historical perspective is needed. Prior to NTMM, control of the "n" button and the stabilization of the "back" and "menu" status bar soft buttons was a problem. These are problems I lack the expertise to address, so I ended up forcing FW 1.1.5 on the non-Glowlight builds as well. This caused only a few problems, one of which I chose to ignore because it is already addressed by QuickTiles. I could *not* ignore the refusal of the "Display" screen in Settings to open, and I could not figure out what was going on. So I synthesized a new "Display" and "Screen" for the Nook Settings app.  
	  
	There are some things FW 1.1.5 lacks which users of FW 1.2.x might notice. For the most part, these are minor (like the absence of actual screensaver banner text which first appears in the framework for FW 1.2.x), but I do want to mention here--in case it's a deal-breaker for some--that NookTouch Mod Manager is more limited on FW 1.1.5. The chief limitation is the inability to control the four side hardware buttons. The code simply isn't there and the original developer mentions this in the app posting. You can make some changes to the behavior of the side buttons by editing a text file. Complete information about this and other issues is in an Appendix added to the User Guides for these builds (**note**: there is a much more detailed description of the button assignment procedure in the FAQ post immediately following this post). In the end I decided to modify NTMM so that it would only show the things that worked on FW 1.1.5.  
	  
	If you're familiar with the later firmware and the functions of NTMM you may be thinking "hmm.....I might be able to live without partial refresh." I have anticipated that possibility and so here are the links to the original builds (using FW 1.2.2) and their User Guides. After all that work I wasn't just going to delete them!  
	  
	Featuring AlReader  
	[NST-US-newUI-AlR.zip](https://www.mediafire.com/file/uuke2txekg60syp/NST-US-newUI-AlR.zip/file) (235 MB) (Nook Simple Touch, BNRV300)  
	\[MD5: 88017876f5a473ca5b426e87246f9692\]  
	[NSTG-US-newUI-AlR.zip](https://www.mediafire.com/file/py90w8hv9nz2jsx/NSTG-US-newUI-AlR.zip/file) (237 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
	\[MD5: 69c7a767cf0a62a867a83c5981009826\]  
	  
	Featuring Cool Reader  
	[NST-US-newUI-CR.zip](https://www.mediafire.com/file/orz63uar4vfzqej/NST-US-newUI-CR.zip/file) (263 MB) (Nook Simple Touch, BNRV300)  
	\[MD5: d3b99e00d42410413e069b2cf80adf75\]  
	[NSTG-US-newUI-CR.zip](https://www.mediafire.com/file/72tlkbjpjfdhcrz/NSTG-US-newUI-CR.zip/file) (234 MB) (Nook Simple Touch w/Glowlight, BNRV350)  
	\[MD5: e77e3ba3618b9a88361932f271c2bfa0\]  
	  
	[NST User Guide](https://www.mediafire.com/file/e2rjapokpl0opvb/Al_UserGuide.pdf/file) (w/AlReader)  
	[NSTG User Guide](https://www.mediafire.com/file/py90w8hv9nz2jsx/NSTG-US-newUI-AlR.zip/file) (w/AlReader)  
	[AlReader Help File](https://www.mediafire.com/file/7gmghioslo5crgl/AlReaderHelp.zip/file) (HTML, tr.)  
	[NST User Guide](https://www.mediafire.com/file/8nygdxfns9yziob/CR_UserGuide.pdf/file) (w/Cool Reader)  
	[NSTG User Guide](https://www.mediafire.com/file/80b2xbfcmlqq6jw/CR_UserGuide_GL.pdf/file) (w/Cool Reader)
	**Overview**  
	  
	There have been posts about enabling RTL on the NST/G from the very early days. The posts were mostly focused on Arabic, with a few comments about Hebrew thrown in. Some detective work brought me back to [a post](https://xdaforums.com/t/tutorial-how-to-fix-rtl-arabic-ardu-farsi-hebrew-stock-custom-roms-gt-s5830.1970521/) by [@Ahmed hamouda](https://xdaforums.com/m/4514149/) which supplied a Java routine for patching ROMs to enable RTL and produce the ligatures in Arabic script properly.  
	  
	Fortunately this seemed to work on the NST/G ROM, although it did give an error about Hebrew. My subsequent work with the patches seems to indicate that Hebrew is fine. If that's not the case, I expect I will hear about it.  
	  
	Patching the OS was one thing. Finding a reader app that would run on the NST/G and was RTL-capable was another. The stock reader uses only the tiny universe hidden in ReaderRMSDK by Adobe. It does not see the DroidSansFallback font and does not respond to the system patches. I tried pretty much everything else and found that only Moon+Reader and AlReader were able to display RTL text properly (even on the same page with LTR text). After a lot of testing I finally gave up on Moon+Reader. I know it has been praised in the past on the forum, but I don't get it. It had just too many issues to list. I'll just note that it does not have partial screen refresh and move on.  
	  
	That left me with AlReader and that meant FW 1.1.5 if partial refresh was going to work. I started with the Phase 3 build featuring AlReader, patched the ROM, and then began testing with any epub material I could find in the four common RTL languages: Arabic, Hebrew, Persian (Farsi), and Urdu. I found that a lot of what is available in these languages is PDFs, mostly from optical scans. EBookDroid and Perfect Viewer are capable of handling these without any special patches to the OS. I finally did track down a few epubs in each language. I converted a few to PDFs with Calibre just to see if text-based PDFs would also be displayed correctly in EBookDroid and Perfect Viewer. They were, but I can't guarantee that books from other sources will also work.  
	  
	**Note:** because my familiarity with these languages could be accurately described as "by name only", I can't say with any certainty that the patches yield any kind of useful result when coupled with the abilities of AlReader. I was not able to get much feedback prior to starting the build and could only rely on Google Translate of screencaps to determine whether the texts might be readable by at least a machine. In particular I have no idea whether the ligature patches for Arabic are also suitable for Persian and/or Urdu. Below is a sample of texts in the four languages. I hope that if someone who has the knowledge determines that these builds are not really useful, they will let me know.  
	  
	![RTL.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/RTL.png "RTL.png")  
	  
	Fonts are a big issue. The DroidSansFallback font supplied with the NST/G does not have either Arabic or Hebrew (never mind the others which are derived from Arabic script). I first tried DejaVuSans as it supposedly supports Arabic, Hebrew and Persian 100%. Urdu is 92%. But again there were issues, mostly with dictionaries which frequently referred to other languages like Hindi or Sanskrit and thus displayed a bunch of boxes rather than text. Eventually I came across a huge font (ArialUnicodeMS-Regular.ttf) which probably even contains Martian. I made that DroidSansFallback and there were far fewer empty boxes in the dictionaries. This also means that where possible in a given app, Arabic characters or Hebrew--or Martian--can be properly displayed (like in the file explorer, for example). With that as Fallback and DejaVuSans as the selected font, all four languages displayed without any dropouts I could detect in my testing. Of course, dedicated fonts for a particular language are bound to be better so I have included a variety of fonts in /system/fonts from which you can choose. There are many, many more available online for free.  
	  
	A small nuisance is that AlReader requires four settings to catch all instances of a font. No one-setting-to-rule-them-all. Of course if you are not too persnickety, you could change only the main text font and let DroidSansFallback pick up the slack. This is discussed in the User Guide.  
	  
	An additional font issue is diacritic marks. I have a test epub file from a fellow on the Mobileread forum and the correct output in image form. It is clear from this that the engine in AlReader does not generally handle diacritics well. They are out of alignment in Hebrew, regardless of what font I tried. Surprisingly the "best" results seem to be DejaVuSans rather than one of the actual Hebrew fonts. But it's still bad. In the three languages that use some form of Arabic script, that same generic font (backed up by DroidSansFallback) appears to give complete coverage, as long as diacritic marks are not used. With diacritics there are positioning issues and sometimes outright mushing of characters together. The severity of these problems differs with the selected font. It pays to shop around.  
	  
	Compounding the issue, the reader app cannot properly select words for dictionary lookup if diacritics are present. You generally get only the first character, no matter what the selection looks like on the screen.  
	  
	Those strike me as real problems, but it may be that reading material without diacritics is common? Based on the sample epub I used for testing it must be that the use of diacritics is controlled by the contents of the epub file since the same sample lines were displayed on the same page, with and without diacritics. I guess that means it would be possible to open up an epub file and disable the diacritics if they are used. None of the epubs I managed to scare up for the four languages used diacritic marks.  
	  
	For those reasons, this build is described as "experimental". I don't know how useful it might be to someone who would like to read in one of the RTL languages, but it is the best I could do with the tools (and limited knowledge) at my disposal.  
	  
	**The build**  
	  
	In no particular order, these are the things that I did to the standard Phase 3 AlReader build to produce this special version:  
	  
	1\. Patched framework.jar, lib\_\_bcore.so, libandroid\_runtime.so, libwebcore.so, and added libicuuc-arabic.so  
	2\. Replaced DroidSansFallback with a renamed ArialUnicodeMS-Regular.ttf  
	3\. Added a variety of fonts for the four languages to /system/fonts, as well as DejaVuSans.ttf  
	4\. Added many single-language or translation dictionaries, and two thesauruses  
	5\. Configured all the reader apps for RTL pagination (page turns to advance are controlled by left screen taps and buttons)  
	6\. Removed the Amazon Kindle app. It cannot display RTL text, Amazon is abandoning it at the end of May 2025, and AlReader can read non-DRM.mobi books anyway.  
	  
	All of the reader apps can still read LTR languages, but the controls for page changes will be "backwards" from what LTR readers would expect. These, of course, can be changed to suit, generally involving 4 settings (two for the screen and two for the buttons) except for Perfect Viewer which has a one-tap control to toggle all four settings at once These adjustments are discussed in the User Guide.
	**"Who are these for?"**  
	  
	Anyone with a working device in any state can use these since they do not include or rely on any account information. However, if you currently have a device with a valid B&N connection, it would be wise to make a total device backup before trying out these images. CWM does not make a total backup. NookManager can do that. That way if none of this is to your liking you can easily restore your device to it's original condition.  
	  
	**"What do I have to do?"**  
	  
	The preparation and installation instructions are identical to those found in [post #3 above](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/post-89533449) (for "phase 2") except for the name of the backup file to be restored. Please refer to that post under "What do I have to do?"
	[View](https://xdaforums.com/posts/89533450/)
	3
	**[nmyshkin](https://xdaforums.com/m/nmyshkin.5562185/)**
	**The Phoenix Project--Phase 2--The stock B&N system, registered, rooted, with new UI and more**  
	![nst_newUI.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/nst_newUI.png "nst_newUI.png")  
	  
	Nook Simple Touch (BNRV300)  
	  
	[NST-US-newUI-Reg.zip](https://www.mediafire.com/file/fc3e44y8euljtn3/NST-US-newUI-Reg.zip/file) (250 MB)  
	\[MD5: 7691cfa6741bf509264ae332e777b0f5\]  
	  
	Nook Simple Touch w/Glowlight (BNRV350)  
	  
	[NSTG-US-newUI-Reg.zip](https://www.mediafire.com/file/3ycyvkp2d7jcunz/NSTG-US-newUI-Reg.zip/file) (250 MB)  
	\[MD5: bd0f9a36cbd1d0d9d6dc4624c6509eed\]  
	  
	[NST User Guide](https://www.mediafire.com/file/3qzs9qqrepiyi80/UserGuide.pdf/file)  
	[NSTG User Guide](https://www.mediafire.com/file/4ec5w6s3dta6c4x/UserGuide_GL.pdf/file)  
	  
	**Note:** while the User Guides actually look rather good in EBookDroid, they contain some embedded hyperlinks which EBookDroid can't handle. Also, they were made with interaction in mind, so better to display them on your PC with your device near at hand. These are NOT the old B&N User Guides and contain important information about the new software, setup, widgets, etc.  
	  
	**Custom UI app update - 6/5/25**  
	**What this update does**  
	  
	This is a Revision 1 update of the previously posted app.  
	  
	*I came across some issues that I didn't like in the first update. They are now fixed. The description below is still correct, but some bugs have been eradicated.*  
	  
	1\. Combines the functions of NST UI and SetCover4 into one app, reducing system overhead.  
	2\. Forces a Media Scanner refresh every time the stock Library app is opened (finally!). This means no more playing around with moving books that were transferred via FTP, no rebooting just to see new books.  
	3\. Moves manual Set Cover function from hardware button assignment to context-driven temporary invisible overlay. This results in less stress on the hardware button rubber covers which are gradually becoming more brittle.  
	  
	*This update is optional. If you are happy with the way things are working and the three items above don't interest you, skip it.*  
	  
	**How to update**  
	  
	These instructions assume some familiarity with the systems to be updated. Most apps made with Tasker don't take well to updates because of problems with new variables. If you want to make the update, please follow these instructions.  
	  
	1\. Download appropriate updated app. Please note, the apps below are NOT interchangeable. If you have an NSTG, you MUST use the app for the Glowlight model. If you have an NST you MUST use the app for the NST without glowlight.  
	  
	[For the BNRV300 (NST)](https://www.mediafire.com/file/pr7ejewctzv1cjv/NST_UI.2Rev1.apk/file)  
	  
	[For the BNRV350 (NSTG)](https://www.mediafire.com/file/ts8kdgbwuitpq3f/NSTG_UI.2Rev1.apk/file)  
	  
	Transfer to your device (maybe /sdcard/Download?).  
	  
	If you installed the previous update:  
	  
	2\. Uninstall NST UI. You can do this from the App Manager. The easiest access is from the app drawer three-dot menu in the upper right ("Manage apps"). You can also access from ES File Explorer (top row of buttons, "AppMgr") or from Settings>Apps.  
	  
	3\. Install the new NST UI app you downloaded in #1 (tap on the apk file in ES File Explorer).  
	  
	4\. The new app needs to be initialized (some variables will be set, others cleared). To do this, tap on the "reading now" button in the upper left corner of the home screen. After a small delay you will see a SuperUser prompt. Approve this.  
	  
	The new app is now functional, but any old data is gone. That means if you are in the process of reading a book, you will need to open that book from its library app again (don't worry, you won't lose your place). In the case of a non-DRM epub with the stock reader, the cover will reset automatically when the book is opened via the Library. For Adobe DRM books or any epub/pdf for which the stock reader does not display a library thumbnail, the manual cover capture routine will activate. For files read with the Kindle app, EBookDroid, or Perfect Viewer, any time the respective library app is opened a small invisible overlay (40x40) will appear in the upper left corner of the screen for 2 minutes. If you do not access that area the overlay will disappear after 2 minutes. If you tap there before the end of 2 minutes, a screenshot will be taken (hopefully of the cover) and placed in the right spots and the overlay disappears. The function of the "reading now" button will also be appropriately set. So if you are in the middle of a book with any of these readers while doing this update, you will have to temporarily return to the cover page, manually set the cover (tap in the upper left) and then return to your reading position. The manual cover capture routine ONLY activates when you open one of the library apps, so subsequent taps on the reading now button or the book cover widget will not make it start.  
	  
	If you are installing this update without having used the previous one:  
	  
	2\. Uninstall NST UI and SetCover4 from your device. You can do this from the App Manager. The easiest access is from the app drawer three-dot menu in the upper right ("Manage apps"). You can also access from ES File Explorer (top row of buttons, "AppMgr") or from Settings>Apps.  
	  
	3\. Install the new NST UI app you downloaded in #1 (tap on the apk file in ES File Explorer).  
	  
	4\. The new app needs to be initialized (some variables will be set, others cleared). To do this, tap on the "reading now" button in the upper left corner of the home screen. After a small delay you will see a SuperUser prompt. Approve this.  
	  
	The new app is now functional, but any old data is gone. That means if you are in the process of reading a book, you will need to open that book from its library app again (don't worry, you won't lose your place). In the case of a non-DRM epub with the stock reader, the cover will reset automatically when the book is opened via the Library. For Adobe DRM books or any epub/pdf for which the stock reader does not display a library thumbnail, the manual cover capture routine will activate. For files read with the Kindle app, EBookDroid, or Perfect Viewer, any time the respective library app is opened a small invisible overlay (40x40) will appear in the upper left corner of the screen for 2 minutes. If you do not access that area the overlay will disappear after 2 minutes. If you tap there before the end of 2 minutes, a screenshot will be taken (hopefully of the cover) and placed in the right spots and the overlay disappears. The function of the "reading now" button will also be appropriately set. So if you are in the middle of a book with any of these readers while doing this update, you will have to temporarily return to the cover page, manually set the cover (tap in the upper left) and then return to your reading position. The manual cover capture routine ONLY activates when you open one of the library apps, so subsequent taps on the reading now button or the book cover widget will not make it start.  
	  
	5\. Cleanup  
	  
	You can skip this step if you want. Go to Settings>Buttons>Nook Touch ModManager>Side Hardware Buttons (Long Press). The last entry (Side Button - Bottom Right) was assigned for the uninstalled app SetCover4. Tap there (access is slow, be patient). When the selection options appear, choose the first one ("Default"). Then back out of the Settings app with the status bar "back" button.
	  
	**"What are these?"**  
	  
	The download zip contains three components:  
	1) a CWM backup of a pre-configured NST/G  
	2) the contents of an sdcard used for storage  
	3) the contents of the /media partition (i.e., the "Nook" drive).  
	  
	The pre-configured NST/G was made by performing a factory re-image on the device and updating to FW 1.2.2. The device was registered to a new account opened solely for this purpose and then rooted with an updated NookManager card ("Traditional" version). The kernel was updated for multi-touch, NoRefresh, and USB Host (including Audio). Finally, custom applications were added to create the new UI. Once all the configuration was done, a CWM backup was created (/boot, /system, /data, /cache). Restoring this backup to another device leaves the /rom partition untouched so device hardware information (serial #, MAC address, etc.) remains unchanged. Since CWM cannot backup /media or /sdcard, separate folders containing those files are in the zip along with the backup (an sdcard is required for all of this to work properly).  
	  
	This build is based on [earlier work of mine](https://xdaforums.com/\(https://xdaforums.com/t/the-nstg-turns-10-time-for-a-makeover.4488695/) to update the UI of the NST/G and deploy a number of custom apps which (hopefully) enhance the capabilities of the device. You can take a look at a video of this build in action in that post. In the video, USB Audio is part of the build, but I did not include it in this version. However, all the needed software is in place and the User Guide contains detailed information regarding the required setup for those who are interested in this feature. While similar to my earlier work, this build contains more custom software developed for this project.  
	  
	Additional reader apps include customized versions of Amazon Kindle, EBookDroid and Perfect Viewer. The "reading now" button in the status bar will open any reader currently in use, not just the stock B&N reader.  
	  
	**Please note**: **As of May 26, 2025, Amazon will no longer support downloads (**[**dictionaries**](https://www.mediafire.com/folder/dww8eduzegz12/Kindle+Dictionaries)**, public library books) from this old app. It sounds as if registered copies will continue to function in offline mode as mobi readers and preliminary tests suggest that new registrations may be possible. Uninstalling the Kindle Library and Amazon Kindle apps is described in the User Guide.**  
	  
	It is possible to use the current book cover as a screensaver image.  
	  
	Additional dictionaries may be added for the stock reader (and the Kindle app, for that matter).  
	  
	Most apps have been lightly pre-configured to make for a better first experience and reduce the amount of time and effort it takes to get up and running. There are a few exceptions and this information is covered in more detail (along with initial setup instructions) in the "User Guides" for each version (separate download above).  
	  
	Unfortunately it is not possible for you to add additional or alternative reader apps to this build and not break the UI function with regard to the bookcover homescreen image/screensaver image and the "reading now" button. Other apps will work, of course, but only as stand-alone entities.  
	  
	**"Who are these for?"**  
	  
	People who do not have a B&N registration for their device and want more than the stock system has to offer may find these useful. Also, people who do have a valid registration for their device but don't see the point in that without actual B&N services yet like the basic B&N reader/library/dictionary combination might want to try these out to see if the new UI and added functionality suits them. A backup prior to trying these will ensure an easy return to the previous state in the event of buyer's remorse.  
	  
	**"Why is there no UK version?"**  
	  
	I could have made one but did not see the point. This build can do everything that the UK version can do and more (there is an Oxford English dictionary included as an option). I'm sorry for the folks who are attached to the multilingual splash screens, but this package really is more versatile when based on the US version.  
	  
	**Warnings**  
	  
	I cannot guarantee that these will work for you. They work for me.  
	  
	**"What do I have to do?"**  
	  
	The briefest possible description is: make a backup, wipe your device, restore the custom backup, reboot. Here's a little more detail, followed by a lot more detail (real instructions!):  
	  
	1\. Download the zip package of your choice and unzip  
	2\. Delete the contents of the "Nook" drive (/media) and copy the contents of the "media" folder to the "Nook" drive  
	3\. Copy the contents of the "sdcard" folder to a clean, formatted sdcard  
	4\. Copy the folder with the long name (like "NST-US-newUI-Reg") to the /clockworkmod/backup folder on your CWM card (didn't make a card? go back to post #1)  
	5\. Backup your device (CWM)  
	6\. Wipe the device (CWM)  
	7\. Restore the custom backup (CWM)  
	8\. Reboot!  
	  
	**Note: there is no specific preparation required to use these backups. As long as the device is in working order and has about a 60% battery charge, you're good to go. It doesn't matter whether the device was currently registered in some older firmware, rooted, skipped OOBE. None of that matters as everything will be wiped.  
	  
	To Restore an NST/G backup (the deets!)**  
	  
	1\. If your device is in a state where you can make a USB connection with your PC and see the "Nook" drive, connect the device and backup any files present that you may want (books, etc.) then delete the contents of the "Nook" drive (this is /media). DO NOT delete the drive itself, just the contents.  
	  
	There is sometimes a "System Volume Information" folder in /media which appears to Windows to be read-only. Rather than mess with that, just ignore it if Windows cannot remove the folder. When you copy the new contents onto the card you will be asked if you want to replace the files in that folder with new ones. The answer is "yes".  
	  
	2\. Copy the contents of the "media" folder from the zip you downloaded to the "Nook" drive. Eject from the USB connection.  
	  
	*If your device is not in a state where you can get a connection to your PC, wait to do steps 1 and 2 until the very end.*  
	  
	3\. Power down.  
	4\. Remove the storage sdcard (if there is one) and insert it (or a new one) into your PC.  
	5\. Back up any books or other files you want elsewhere for now, then delete all files on your storage sdcard.  
	  
	There is sometimes a "System Volume Information" folder on sdcards that have been used in the device which appears to Windows to be read-only. Rather than mess with that, just ignore it if Windows cannot remove the folder. When you copy the new contents onto the card you will be asked if you want to replace the files in that folder with new ones. The answer is "yes".  
	  
	6\. Copy the contents of the "sdcard" folder that you downloaded onto your clean sdcard and set aside (the card should be formatted FAT32--if in doubt, reformat before copying content onto the card).  
	7\. Copy the backup folder from the zip you downloaded (named like "NST-US-newUI-Reg") to /clockworkmod/backup on the CWM card. Remove the CWM card from your PC and insert it into the device.  
	8\. Power up.  
	  
	If CWM fails to reach the first menu screen (i.e., is stuck on the splash screen), press the lower right hardware button.  
	  
	To navigate in CWM: Upper Left hardware button > previous menu, Upper Right hardware button > move up, Lower Right hardware button > move down, "n" button > select  
	  
	9\. Select backup/restore.  
	10\. Press "n" to backup your device as it is now.  
	![Image1.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image1.png "Image1.png")  
	Backups end up in folders with dates for names, inside /clockworkmod/backup. You can rename these folders with the card in your PC. For example, you might rename this folder as "original" or similar (no spaces allowed in folder name). At the conclusion of the backup you should be returned to the main menu.  
	  
	11\. Select wipe data / factory reset.  
	12\. Confirm.  
	![Image2.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image2.png "Image2.png")  
	If after any wipe or restore operation CWM freezes, repeatedly press and hold the power button until the device reboots back into CWM. **Don't panic**. Hold the power button while counting to ten. Release it. If nothing happens, count to ten and try again. Eventually the device will reboot. This is the tool we have and it's not perfect, but it does work.  
	The device is accessible to ADB while running CWM. If you plug in the USB cable once CWM is running you can connect:  
	Code:
	```
	adb devices
	```
	This should result in a "11223344556677 recovery" response. You're connected.  
	  
	Now, when CWM inevitably freezes after a wipe or restore, you can simply type:  
	Code:
	```
	adb reboot
	```
	No struggling with the power button trying to get an interrupt through the haze of the freeze. The device will simply reboot back into CWM and you continue with the next step.  
	  
	When you get to the last step (the "restore") and are ready for the final reboot, swap out the CWM card for your storage sdcard, then once again type:  
	Code:
	```
	adb reboot
	```
	As soon as the screen turns white or when you see that your PC has "lost" recognition of the device as connected, remove the USB connector.
	  
	13\. Select advanced.  
	14\. Select Wipe Dalvik Cache.  
	15\. Confirm.  
	![Image3.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image3.png "Image3.png")  
	If CWM has frozen after the wipe, repeatedly press and hold the power button until the device reboots.  
	  
	16\. Select backup and restore.  
	17\. Select restore.  
	18\. Select folder to restore (you copied one onto the card, remember?).  
	19\. Confirm.  
	![Image4.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/Image4.png "Image4.png")  
	20\. When restore is complete, remove the CWM card from your device and replace it with your regular storage sdcard (with the new files/folders)  
	21\. Press the "n" button to reboot.  
	  
	If CWM has frozen after the restore, repeatedly press and hold the power button until the device reboots.  
	  
	22\. Once the device begins the boot sequence, swipe the screensaver unlocker when you get to that screen. When boot is complete your screen should look like this:  
	![1717017194348.png](https://xdaforums.com/t/nst-g-the-phoenix-project.4673934/1717017194348.png "1717017194348.png")  
	  
	If there are messages about not being able to load the widget image it's because you have not restored the contents of /media yet. Do that next. Otherwise, skip to #27.  
	  
	23\. Attach the device to your PC via USB cable.  
	24\. Backup any content you want from the "Nook" drive, then delete all files/folders in the "Nook" drive (not the drive itself!!! just any random files/folders).  
	25\. Copy the contents of the "media" folder that you downloaded to the "Nook" drive.  
	26\. Eject your device (i.e., disconnect USB properly)  
	  
	The messages about the widget should cease. If they do not, power down and up again.  
	  
	27\. Refer to your "User Guide" (separate download above) for initialization instructions and other information about your version.  
	  
	You're done!
	[View](https://xdaforums.com/posts/89533449/)
	3
	**[nmyshkin](https://xdaforums.com/m/nmyshkin.5562185/)**
	**The Phoenix Project--FAQ**  
	  
	Rooting  
	USB Audio  
	Yes, I'm afraid I left out a tiny detail. To enable full spectrum microphone recording you need to make a small edit in /system/etc/permissions/platform.xml. Copy the file to the sdcard or your PC. Using either ES Note Editor or something like Notepad++ on your PC, add the line in bold below to the permission shown:  
	  
	<permission name="android.permission.WRITE\_EXTERNAL\_STORAGE" >  
	<group gid="sdcard\_rw" />  
	**<group gid="audio" />**  
	</permission>  
	  
	Move the file back to overwrite the original and then reboot. In an app like "Record That Note", this should enable all of the various microphone recording options.
	Hardware button mapping for Phase 2  
	This is not something I ever really looked at until [@NewConfusedNookUser](https://xdaforums.com/m/13156126/) brought the issue to my attention. I don't use buttons to change pages but I know there are people who very much want that--except maybe not all in the same way. So I left the lower buttons, the stock reader settings, and the keylayout file in the default state. The only change I made to the buttons was to use NTMM to assign the upper buttons to Back and Menu.  
	  
	How you approach the button assignments is very important. You must take care of the stock reader first because the assignments you make will impact settings you make in the other readers.  
	  
	The stock reader: for a logical assignment of the lower left to PREVIOUS PAGE and the lower right to NEXT PAGE (this mimics the screen taps), go to Settings>Buttons>Nook Touch Mod Manager and assign the lower right hardware button ONLY to "Tap Right (Next Page)". This corrects for the bizarre B&N notion that "previous" and "next" should be controlled by upper and lower buttons.  
	  
	**Do not use NTMM to assign any other page turns.**  
	  
	For the Kindle app there is a setting to use the Volume controls for page turns, but if you use that, the stock reader will not work, so forget it.  
	  
	In EBookDroid you can only change the button assignments when a book is open (they "stick", though, for all future books). Tap in the center of the screen and then tap "More" in the bottom menu. Then Settings>Configure keys. You want the "Management keys" for the right lower button setting. The app sees that button as DPAD DOWN (20) after the assignment made in NTMM. Make this "Scroll Forward" to advance a screen. The app sees the lower left button as 93, which is in the range of the "Keyboard keys" (way down on the list). Make that "Scroll Back" to move to the previous screen of text.  
	  
	Perfect Viewer is similar in that it recognizes the bottom buttons as the entities I described above for EBookDroid. But it lacks "93" in its list. Fortunately it has the option to add a key. From the library shelves, tap on the "tool" button. Now you're in Settings>Control & hardware key>Hardware key management. You will see DPAD DOWN (20) there. Assign that to "Scroll Forward". Then at the top of the screen tap on "Add key". A dialog box opens and you are asked to press a key/button. Press the lower left button. "93" should appear in the dialog box. Name it something like "lower left" and then assign it to "Scroll Backward".  
	  
	And that's the whole sordid story about button assignments.
	Hardware button mapping for Cool Reader and AlReader  
	I could have been more detailed in the User Guide, I guess.  
	  
	The file in question is /system/usr/keylayout/TWL4030\_Keypad.kl. The first thing to know about this file is that it is plain text. The second thing to know about it is that the file is "in use" as of boot and if you try to do anything with it you may trigger a spontaneous reboot.  
	  
	So long-press on the file and from the context menu select "copy". Then navigate back to the root of the sdcard and tap on "paste". Now you have a copy of the file to work with and you won't annoy the system.  
	  
	To open the file, long-press on it again and this time select "open as" from the context menu. Choose "text". The file will open in ES Note Editor. Scroll down to the end of the file. The last four entries control the four hardware buttons. You will see that I have changed two of them from their original default values to "BACK" (key 412) and "MENU" (key 407). These are just two of the options in the very long list that makes up the rest of the file.  
	  
	Let's say you want to assign VOLUME\_DOWN to the lower left button (key 139). All you have to do is delete "LEFT\_PREVPAGE" and replace it with VOLUME\_DOWN. If you want the lower right button to complete the set, then replace "RIGHT\_PREVPAGE" with VOLUME\_UP.  
	  
	As you back out of the file, you'll be asked whether you want to save the changes (yes).  
	  
	Now long-press on the file once again and select "copy". Then navigate back to  
	/system/usr/keylayout/ and tap on the "paste" button. You will be asked about overwriting. The answer is "yes".  
	  
	The last and most important step is to reboot. This is required because the file was loaded during boot and it's not going to be looked at again until another boot. Your changes will take effect after the fresh boot.  
	  
	A note about VOLUME\_UP and VOLUME\_DOWN: these are common options for reader apps which can use buttons for page changes (or other actions). On the NST/G they will work in the same way, but outside the reader apps they will bring up the volume control toast, so if that's going to bother you, it might be a good idea to choose some other pair of button assignments that the reader app could use (CoolReader does not have the option to use VOLUME\_UP and VOLUME\_DOWN anyway).
	Kindle cover images  
	Some Kindle books seem to come with cover pages that have a small cover image on a white background. That doesn't make for a great cover image widget or screensaver. There is, however, an undocumented trick for enlarging the view of the cover, although it comes with a trade-off.  
	  
	A double-tap on the cover image will enlarge it to fill the screen (at least the vertical dimension, usually). A manual cover capture of this view is better but it will include a resizing indicator at the bottom. The only way to escape from the enlarged view is with the "back" button (upper left hardware button).  
	  
	Alternatively, you can capture the smaller view and then use QuickPic to crop the images in /media/NowReading and /media/screensavers/CurrentBookCover. Obviously that is more tedious, although you only have to fix one and then copy the image to the other location. This method will result in a lower resolution image because you are enlarging what was a small screenshot into a larger one. Also you must refresh the bookcover widget (app drawer>Desktop Visualizer>status bar "menu">(at bottom right) refresh widgets (normal). You will lose the "Kindle" badge, though.
	[View](https://xdaforums.com/posts/89533452/)

### New posts

- [Samsung note 10 lite one ui 6.1 custom rom](https://xdaforums.com/t/samsung-note-10-lite-one-ui-6-1-custom-rom.4674289/post-90242492)
	- Latest: Android Artisan
	[Samsung Galaxy Note 10 Lite Questions & Answers](https://xdaforums.com/f/samsung-galaxy-note-10-lite-questions-answers.9799/)
- [Question fastboot oem get\_unlock\_data returns command failed.](https://xdaforums.com/t/fastboot-oem-get_unlock_data-returns-command-failed.4753989/post-90242491)
	- Latest: pawelmiernik
	[Motorola Edge 40 Pro / Moto X40 (China)](https://xdaforums.com/f/motorola-edge-40-pro-moto-x40-china.12731/)
- [General Official List of Sideloaded Apps and Workarounds For Wear OS (Tested on Galaxy Watch)](https://xdaforums.com/t/official-list-of-sideloaded-apps-and-workarounds-for-wear-os-tested-on-galaxy-watch.4379825/post-90242490)
	- Latest: Amaeloeze07
	[Samsung Galaxy Watch 4](https://xdaforums.com/f/samsung-galaxy-watch-4.12439/)
- [🔧 \[MODULE\] Play Integrity Fix](https://xdaforums.com/t/module-play-integrity-fix.4607985/post-90242489)
	- Latest: fbirraque
	[Magisk](https://xdaforums.com/f/magisk.5903/)
- [General \[Internal Beta Thread\] \[Beta 1 - 5\] \[ONE UI 8\] ONE UI 8 BETA ZIP FOR S24/S24+/S24U](https://xdaforums.com/t/internal-beta-thread-beta-1-5-one-ui-8-one-ui-8-beta-zip-for-s24-s24-s24u.4738842/post-90242487)
	- Latest: kuuky
	[Samsung Galaxy S24 Ultra](https://xdaforums.com/f/samsung-galaxy-s24-ultra.12819/)